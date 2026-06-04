import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/core/supabase/supabase_client.dart';
import 'package:school_app/features/professor/data/datasources/emploi_datasource.dart';

class CreateEmploiPage extends StatefulWidget {
  const CreateEmploiPage({super.key});

  @override
  State<CreateEmploiPage> createState() => _CreateEmploiPageState();
}

class _CreateEmploiPageState extends State<CreateEmploiPage> {
  @override
  Widget build(BuildContext context) {
    final extra = GoRouter.of(context).state.extra as List<Map<String, dynamic>>?;
    final int? idNiveau = extra != null && extra.isNotEmpty ? (extra.first['id_niveau'] as int?) : null;

    if (extra == null || extra.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Aucun emploi à créer')),
      );
    }

    return ScheduleScreen(jobs: extra, idNiveau: idNiveau);
  }
}

class ScheduleScreen extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;
  final int? idNiveau;

  const ScheduleScreen({required this.jobs, this.idNiveau, super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadExistingSessions();
  }

  Future<void> _loadExistingSessions() async {
    try {
      final client = SupabaseClientProvider.client;
      for (int jobIdx = 0; jobIdx < widget.jobs.length; jobIdx++) {
        final job = widget.jobs[jobIdx];
        final idNiveau = job['id_niveau'] as int?;
        final matiere = job['matiere']?.toString() ?? '';
        if (idNiveau == null || matiere.isEmpty) continue;

        widget.jobs[jobIdx]['sessions'] = [];

        final datasource = EmploiDatasource(client);
        final existingSessions = await datasource.getSessionsForJob(idNiveau, matiere);
        final currentIdEmploi = job['id_emploi'] as int?;
        final filtered = currentIdEmploi == null
            ? existingSessions
            : existingSessions.where((s) => s['id_emploi'] == currentIdEmploi).toList();

        final existingIndexed = <Map<String, dynamic>>[];
        final grouped = <int, List<Map<String, dynamic>>>{};
        for (final s in filtered) {
          final jour = s['numero_jour'] as int?;
          if (jour == null) continue;
          grouped.putIfAbsent(jour, () => []).add(s);
        }
        final sortedDays = grouped.keys.toList()..sort();
        for (final jour in sortedDays) {
          final list = grouped[jour]!;
          list.sort((a, b) => (a['numero_ordre'] ?? 0).compareTo(b['numero_ordre'] ?? 0));
          for (var i = 0; i < list.length; i++) {
            final s = list[i];
            existingIndexed.add({
              'index': i * 6 + (jour - 1),
              'titre_cours': s['contenu']?.toString() ?? '',
              'id_cours': s['id_cours'],
              'id_seance': s['id_seance'],
              'id_emploi': s['id_emploi'],
              'duree': s['duree']?.toString() ?? (s['numero_ordre']?.toString() ?? ''),
              'numero_ordre': s['numero_ordre'],
            });
          }
        }

        final currentList = List<Map<String, dynamic>>.from(widget.jobs[jobIdx]['sessions'] ?? []);
        final currentIndexes = currentList.map((s) => s['index'] as int? ?? -1).toSet();

        for (var existing in existingIndexed) {
          if (!currentIndexes.contains(existing['index'] as int?)) {
            currentList.add(existing);
          }
        }
        widget.jobs[jobIdx]['sessions'] = currentList;
        final first = currentList.firstOrNull;
        if (first != null && first['id_emploi'] != null) {
          widget.jobs[jobIdx]['id_emploi'] = first['id_emploi'];
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement sessions existantes: $e');
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= widget.jobs.length) {
      return const Scaffold(
        body: Center(child: Text('Terminé')),
      );
    }

    final currentJob = widget.jobs[currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/bg.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildAppBar(currentIndex + 1, widget.jobs.length),
                const SizedBox(height: 10),
                _buildHeader(currentJob),
                Expanded(child: _buildGrid()),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(int step, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("QAMAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text("Étape $step sur $total", style: const TextStyle(color: Colors.white70)),
          const Row(
            children: [
              Icon(Icons.nights_stay_outlined, size: 20),
              SizedBox(width: 15),
              Icon(Icons.notifications_none, size: 20),
              SizedBox(width: 15),
              CircleAvatar(radius: 15, backgroundImage: AssetImage('lib/assets/images/icon.png')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/images/icon.png',
            height: 90,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Créer l'emploi pour ${job['niveau']} - ${job['matiere']}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFBB000),
                fontFamily: 'Impact',
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 3.0,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (widget.jobs.isEmpty || currentIndex >= widget.jobs.length) {
      return const Center(child: Text('Aucun emploi disponible'));
    }

    final sessionsList = List<Map<String, dynamic>>.from(widget.jobs[currentIndex]['sessions'] ?? []);

    List<Map<String, dynamic>> getSessionsByDay(int dayIndex) {
      return sessionsList.where((s) {
        final idx = s['index'] as int? ?? 0;
        final col = idx % 6;
        return col == dayIndex;
      }).toList();
    }

  Widget buildSessionCell(Map<String, dynamic> session) {
    final hasSession = session.isNotEmpty;
    final duree = session['duree'];
    final titreCours = session['titre_cours']?.toString() ?? session['matiere']?.toString() ?? '';
    final showContent = hasSession && (titreCours.isNotEmpty || (duree != null && duree != 0));

    return GestureDetector(
      onTap: () => _showMatiereDialog((session['index'] as int?) ?? 0),
      child: Container(
        decoration: BoxDecoration(
          color: showContent ? const Color(0xFFFF7F50).withValues(alpha: 0.8) : Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
        ),
        child: Stack(
          children: [
            Center(
              child: showContent
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          titreCours,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${duree ?? 0} min',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    )
                  : const Icon(Icons.add, color: Colors.orange, size: 18),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () => _deleteCell((session['index'] as int?) ?? 0, hasContent: showContent),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget buildDayColumn(int dayIndex) {
      final daySessions = getSessionsByDay(dayIndex);
      return Expanded(
        child: Column(
          children: [
            ...daySessions.map((s) => Expanded(child: buildSessionCell(s))),
            GestureDetector(
              onTap: () => _addNewCell(dayIndex),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // HEADER JOURS
          Row(
            children: [
              Container(
                width: 120,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Parties", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              ...List.generate(
                6,
                (i) => Expanded(
                  child: Container(
                    height: 45,
                    margin: const EdgeInsets.only(right: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("Jour ${i + 1}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const RotatedBox(
                    quarterTurns: 3,
                    child: Text("1ère Partie", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(
                  6,
                  (dayIndex) => buildDayColumn(dayIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewCell(int dayIndex) {
    final job = widget.jobs[currentIndex];
    final sessions = List<Map<String, dynamic>>.from(job['sessions'] ?? []);

    final sameDaySessions = sessions.where((s) {
      final idx = s['index'] as int? ?? 0;
      final col = idx % 6;
      return col == dayIndex;
    }).toList();

    final nextPosition = sameDaySessions.length;
    final globalIndex = nextPosition * 6 + dayIndex;

    sessions.add({
      'index': globalIndex,
      'dayIndex': dayIndex,
      'titre_cours': '',
      'duree': 0,
    });

    widget.jobs[currentIndex]['sessions'] = sessions;

    setState(() {});
  }

  void _deleteCell(int index, {required bool hasContent}) {
    final job = widget.jobs[currentIndex];
    final sessions = List<Map<String, dynamic>>.from(job['sessions'] ?? []);

    if (!hasContent) {
      sessions.removeWhere((s) => (s['index'] as int?) == index);
      widget.jobs[currentIndex]['sessions'] = sessions;
      setState(() {});
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette séance ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
            TextButton(
              onPressed: () async {
                final int? idSeance = sessions.firstWhere((s) => (s['index'] as int?) == index, orElse: () => {})['id_seance'] as int?;
                if (idSeance != null) {
                  try {
                    final client = SupabaseClientProvider.client;
                    await client.from('seance').delete().eq('id_seance', idSeance);
                  } catch (e) {
                    debugPrint('Erreur suppression seance: $e');
                  }
                }
                sessions.removeWhere((s) => (s['index'] as int?) == index);
                widget.jobs[currentIndex]['sessions'] = sessions;
                Navigator.of(ctx).pop();
                setState(() {});
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFooter() {
    final isLast = widget.jobs.isNotEmpty && currentIndex == widget.jobs.length - 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(140, 42),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: currentIndex > 0
              ? () {
                  setState(() {
                    currentIndex--;
                  });
                }
              : null,
          child: const Text(
            "Précédent",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(140, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await _saveAllEmplois();
                if (!mounted) return;
                if (!isLast) {
                  setState(() {
                    currentIndex++;
                  });
                } else {
                  GoRouter.of(context).push('/prof/emploi/finalisation');
                }
              },
              child: const Text(
                "Suivant",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(180, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await _saveAllEmplois();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Emploi enregistré')),
                );
              },
              child: const Text(
                "Enregistrer",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


  void _showMatiereDialog(int index) {
    final currentJob = widget.jobs[currentIndex];
    final sessionsList = List<Map<String, dynamic>>.from(currentJob['sessions'] ?? []);
    final sessionAtIndex = sessionsList.isNotEmpty
        ? sessionsList.firstWhere((s) => (s['index'] as int?) == index, orElse: () => {})
        : {};

    String? selectedCours = sessionAtIndex['titre_cours'] as String?;
    int? selectedIdCours = sessionAtIndex['id_cours'] as int?;
    final dureeCtrl = TextEditingController(text: sessionAtIndex['duree']?.toString() ?? '45');
    final matiere = currentJob['matiere']?.toString() ?? 'Arabe';
    final idNiveau = widget.idNiveau ?? (currentJob['id_niveau'] as int? ?? 0);
    final coursCtrl = TextEditingController(text: selectedCours ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: () async {
              final datasource = EmploiDatasource(SupabaseClientProvider.client);
              return await datasource.getCoursByNiveauAndMatiere(idNiveau, matiere);
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  width: 120,
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final coursList = (snapshot.data ?? const [])
                  .where((c) => (c['titre_cours']?.toString() ?? '').isNotEmpty)
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Matières enseignées",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "La matière :",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: coursCtrl,
                      decoration: InputDecoration(
                        hintText: 'Saisir ou choisir une matière',
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        selectedCours = val.isEmpty ? null : val;
                        selectedIdCours = null;
                      },
                    ),
                    if (coursList.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: coursList.map((c) {
                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                coursCtrl.text = c['titre_cours']?.toString() ?? '';
                                selectedCours = coursCtrl.text;
                                selectedIdCours = c['id_cours'] as int?;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade100,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text(c['titre_cours']?.toString() ?? ''),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Durée de la séance :",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dureeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if ((selectedCours ?? '').isNotEmpty && dureeCtrl.text.isNotEmpty) {
                            final sessions = List<Map<String, dynamic>>.from(currentJob['sessions'] ?? []);
                            sessions.removeWhere((s) => (s['index'] as int?) == index);
                            sessions.add({
                              'index': index,
                              'matiere': matiere,
                              'titre_cours': selectedCours,
                              'id_cours': selectedIdCours,
                              'duree': dureeCtrl.text,
                              'id_seance': sessionAtIndex['id_seance'],
                            });
                            widget.jobs[currentIndex]['sessions'] = sessions;
                          }
                          if (mounted) Navigator.of(context).pop();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Enregistrer la matière",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _saveAllEmplois() async {
    try {
      final client = SupabaseClientProvider.client;

        for (final job in widget.jobs) {
          final sessions = List<Map<String, dynamic>>.from(job['sessions'] ?? []);
          if (sessions.isEmpty) continue;
          final idNiveau = job['id_niveau'] as int?;
          final matiere = job['matiere']?.toString() ?? 'Arabe';
          if (idNiveau == null) continue;

          final indexed = sessions.where((s) => s['index'] != null).toList();
          indexed.sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));

          final expanded = <Map<String, dynamic>>[];
          for (final session in indexed) {
            final dureeRaw = session['duree'] ?? '45';
            final duree = int.tryParse(dureeRaw.toString()) ?? 45;
            final partCount = (duree / 135).ceil();
            for (int i = 0; i < partCount; i++) {
              final partDuree = i == partCount - 1 ? duree - 135 * i : 135;
              if (partDuree <= 0) continue;
              final copy = Map<String, dynamic>.from(session);
              copy['duree'] = partDuree;
              copy['_partIndex'] = i;
              expanded.add(copy);
            }
          }
          final byIndex = <int, List<Map<String, dynamic>>>{};
          for (final item in expanded) {
            final idx = item['index'] as int? ?? 0;
            byIndex.putIfAbsent(idx, () => []).add(item);
          }
          final finalIndexed = <Map<String, dynamic>>[];
          final counts = <String, int>{};
          for (final idx in byIndex.keys.toList()..sort()) {
            final group = byIndex[idx]!;
            group.sort((a, b) => (a['_partIndex'] as int).compareTo(b['_partIndex'] as int));
            for (final item in group) {
              final key = (item['titre_cours'] ?? item['matiere'] ?? '').toString();
              counts[key] = (counts[key] ?? 0) + 1;
              item['numero_ordre'] = counts[key];
              finalIndexed.add(item);
            }
          }

          int? idEmploi = job['id_emploi'] as int?;
          if (idEmploi == null) {
            final emploiResponse = await client
                .from('emploi_du_temps')
                .insert({})
                .select()
                .maybeSingle();
            if (emploiResponse == null || emploiResponse['id_emploi'] == null) {
              throw Exception('Échec création emploi_du_temps');
            }
            idEmploi = emploiResponse['id_emploi'] as int;
            job['id_emploi'] = idEmploi;
          }

          final idCoursList = finalIndexed.map((s) => s['id_cours'] as int?).whereType<int>().toSet().toList();
          final existingRows = idCoursList.isEmpty ? [] : await client
              .from('seance')
              .select('id_seance')
              .eq('id_emploi', idEmploi)
              .inFilter('id_cours', idCoursList);
          final existingIds = (existingRows as List).map((e) => e['id_seance'] as int).toSet();
          final remainingIds = finalIndexed.map((s) => s['id_seance'] as int? ).whereType<int>().toSet();
          final toDelete = existingIds.where((id) => !remainingIds.contains(id)).toList();
          for (final idSeance in toDelete) {
            await client.from('seance').delete().eq('id_seance', idSeance);
          }

          for (final session in finalIndexed) {
            final duree = session['duree'] ?? 45;
            final index = session['index'] as int? ?? 0;
            final numeroJour = (index % 6) + 1;
            final titreCours = session['titre_cours']?.toString() ?? '';
            int? sessionIdCours = session['id_cours'] as int?;
            if (sessionIdCours == null && titreCours.isNotEmpty) {
              final existing = await client
                  .from('cours')
                  .select('id_cours')
                  .eq('id_niveau', idNiveau)
                  .eq('titre_cours', titreCours)
                  .maybeSingle();
              if (existing != null) {
                sessionIdCours = existing['id_cours'] as int;
              } else {
                final nouveauCours = await client
                    .from('cours')
                    .insert({
                      'id_niveau': idNiveau,
                      'matiere': matiere,
                      'titre_cours': titreCours,
                    })
                    .select('id_cours')
                    .maybeSingle();
                if (nouveauCours != null) {
                  sessionIdCours = nouveauCours['id_cours'] as int;
                }
              }
            }
            final idSeance = session['id_seance'] as int?;
            final data = <String, dynamic>{
              'contenu': session['titre_cours'] ?? session['matiere'] ?? '',
              'numero_ordre': session['numero_ordre'] as int?,
              'duree': duree is int ? duree : int.tryParse(duree.toString()),
              'numero_jour': numeroJour,
              'id_emploi': idEmploi,
              'id_cours': sessionIdCours,
            };
            if (idSeance != null) {
              await client.from('seance').update(data).eq('id_seance', idSeance);
            } else {
              await client.from('seance').insert(data);
            }
          }
          job['sessions'] = finalIndexed;
        }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emplois sauvegardés avec succès')),
      );
    } catch (e, st) {
      debugPrint('Erreur sauvegarde: $e');
      debugPrint('Stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
      );
    }
  }
}
