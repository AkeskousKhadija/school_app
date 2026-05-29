import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NiveauLangue {
  final String niveau;
  final String langue;

  NiveauLangue({
    required this.niveau,
    required this.langue,
  });
}

class EmploiDuTempsPage extends StatefulWidget {
  const EmploiDuTempsPage({super.key});

  @override
  State<EmploiDuTempsPage> createState() => _EmploiDuTempsPageState();
}

class _EmploiDuTempsPageState extends State<EmploiDuTempsPage> {
  int currentStep = 0;
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  String errorMessage = '';

  List<String> niveaux = [];
  List<String> niveauxSelectionnes = [];
  Map<String, List<String>> languesParNiveau = {};
  List<NiveauLangue> emploisAGenerer = [];

  List<String> jours = [];
  List<String> horaires = [];

  final List<String> matieres = ['Français', 'Arabe'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      debugPrint('Starting to load data from Supabase...');
      
      final niveauxData = await supabase.from('niveau').select();
      debugPrint('Niveaux raw data: $niveauxData');
      debugPrint('Niveaux count: ${niveauxData.length}');

      final joursData = await supabase.from('jour').select().order('numero');

      final horairesData = await supabase.from('horaire').select().order('heure_debut');

      setState(() {
        niveaux = (niveauxData as List).map((e) => e['nom'] as String).toList();
        jours = (joursData as List).map((e) => e['nom'] as String).toList();
        horaires = (horairesData as List)
            .map((e) {
              final debut = e['heure_debut'] as String;
              return debut.substring(0, 5);
            })
            .toList();
        isLoading = false;
      });
      
      debugPrint('Loaded niveaux: $niveaux');
      debugPrint('Loaded jours: $jours');
      debugPrint('Loaded horaires: $horaires');
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void genererEmplois() {
    emploisAGenerer.clear();

    for (var niveau in niveauxSelectionnes) {
      List<String> langues = languesParNiveau[niveau] ?? [];

      for (var langue in langues) {
        emploisAGenerer.add(
          NiveauLangue(
            niveau: niveau,
            langue: langue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.school,
                    size: 35,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'Création Emploi du Temps',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 30),

              LinearProgressIndicator(
                value: (currentStep + 1) / 3,
                minHeight: 10,
                borderRadius: BorderRadius.circular(20),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: buildStep(),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  if (currentStep > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      child: const Text('Retour'),
                    ),

                  const Spacer(),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 18,
                      ),
                    ),
                    onPressed: () {
                      if (currentStep == 0) {
                        if (niveauxSelectionnes.isNotEmpty) {
                          setState(() {
                            currentStep++;
                          });
                        }
                      } else if (currentStep == 1) {
                        genererEmplois();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EmploiFillScreen(
                              emplois: emploisAGenerer,
                              jours: jours,
                              horaires: horaires,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      currentStep == 1 ? 'Commencer' : 'Suivant',
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStep() {
    if (currentStep == 0) {
      return buildNiveauxStep();
    }

    return buildLanguesStep();
  }

  Widget buildNiveauxStep() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $errorMessage', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text('Réessayer')),
          ],
        ),
      );
    }
    if (niveaux.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text('Aucun niveau disponible', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                const Text('Vérifiez la connexion Supabase et les données', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _loadData, child: Text('Actualiser')),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisir les niveaux',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Le professeur peut enseigner plusieurs niveaux.',
          style: TextStyle(
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 30),

        Expanded(
          child: GridView.builder(
            itemCount: niveaux.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (context, index) {
              final niveau = niveaux[index];

              bool selected = niveauxSelectionnes.contains(niveau);

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    if (selected) {
                      niveauxSelectionnes.remove(niveau);
                    } else {
                      niveauxSelectionnes.add(niveau);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      niveau,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget buildLanguesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisir les matières par niveau',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        Expanded(
          child: ListView.builder(
            itemCount: niveauxSelectionnes.length,
            itemBuilder: (context, index) {
              String niveau = niveauxSelectionnes[index];

              languesParNiveau.putIfAbsent(niveau, () => []);

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FD),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          niveau,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => _showNiveauDetailDialog(context, niveau),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 15,
                      children: matieres.map((m) => buildLangueChip(niveau, m)).toList(),
                    ),
                    if (languesParNiveau[niveau]!.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        children: languesParNiveau[niveau]!
                            .map((l) => InkWell(
                                onTap: () => _showLangueDetailDialog(context, niveau, l),
                                child: Chip(
                                    label: Text(l),
                                    backgroundColor: Colors.blue.shade100)))
                            .toList(),
                      ),
                    ]
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget buildLangueChip(String niveau, String langue) {
    bool selected = languesParNiveau[niveau]!.contains(langue);

    return FilterChip(
      label: Text(langue),
      selected: selected,
      onSelected: (value) {
        setState(() {
          if (value) {
            languesParNiveau[niveau]!.add(langue);
          } else {
            languesParNiveau[niveau]!.remove(langue);
          }
        });
      },
    );
  }

  void _showNiveauDetailDialog(BuildContext context, String niveau) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Détails - $niveau'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Matières sélectionnées',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...languesParNiveau[niveau]!.isNotEmpty
                ? languesParNiveau[niveau]!
                    .map((l) => ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(l),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showLangueDetailDialog(context, niveau, l),
                        ))
                    .toList()
                : [const Text('Aucune matière sélectionnée')],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLangueDetailDialog(BuildContext context, String niveau, String langue) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$langue - $niveau'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Matières disponibles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.calculate),
                  title: Text('Mathématiques'),
                ),
                ListTile(
                  leading: Icon(Icons.text_fields),
                  title: Text('Français'),
                ),
                ListTile(
                  leading: Icon(Icons.text_rotation_angledown),
                  title: Text('Arabe'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class EmploiFillScreen extends StatefulWidget {
  final List<NiveauLangue> emplois;
  final List<String> jours;
  final List<String> horaires;

  const EmploiFillScreen({
    super.key,
    required this.emplois,
    required this.jours,
    required this.horaires,
  });

  @override
  State<EmploiFillScreen> createState() => _EmploiFillScreenState();
}

class _EmploiFillScreenState extends State<EmploiFillScreen> {
  int currentIndex = 0;
  final supabase = Supabase.instance.client;

  final List<String> matieres = ['Français', 'Arabe'];

  final Map<String, List<String>> titres = {
    'Français': ['Lecture', 'Grammaire', 'Expression'],
    'Arabe': ['Texte', 'Expression', 'Compréhension'],
  };

  final Map<String, List<String>> seances = {
    'Lecture': ['S1', 'S2'],
    'Grammaire': ['S1', 'S2'],
    'Expression': ['S1', 'S2'],
    'Texte': ['S1', 'S2'],
    'Compréhension': ['S1', 'S2'],
  };

  Map<String, String> emploi = {};

  NiveauLangue get currentEmploi => widget.emplois[currentIndex];

  Future<void> enregistrerDansBase() async {
    for (var entry in emploi.entries) {
      final key = entry.key;
      final value = entry.value;
      final parts = value.split('\n');
      final matiere = parts[0];
      final titre = parts.length > 1 ? parts[1] : '';
      final seanceNom = parts.length > 2 ? parts[2] : '';

      final niveau = currentEmploi.niveau;
      final langue = currentEmploi.langue;

      try {
        final niveauxResponse = await supabase
            .from('niveau')
            .select()
            .eq('nom', niveau)
            .limit(1);
        final idNiveau = niveauxResponse[0]['id_niveau'] as int;

        int idMatiere;
        try {
          final matieresResponse = await supabase
              .from('matiere')
              .select()
              .eq('nom', matiere)
              .limit(1);
          if (matieresResponse.isNotEmpty) {
            idMatiere = matieresResponse[0]['id_matiere'] as int;
          } else {
            idMatiere = matiere == 'Français' ? 1 : 2;
          }
        } catch (_) {
          idMatiere = matiere == 'Français' ? 1 : 2;
        }

        final coursResponse = await supabase
            .from('cours')
            .select()
            .eq('id_niveau', idNiveau)
            .eq('id_matiere', idMatiere)
            .limit(1);
        
        int idCours;
        if (coursResponse.isEmpty) {
          final insertCours = await supabase
              .from('cours')
              .insert({'id_niveau': idNiveau, 'id_matiere': idMatiere})
              .select();
          idCours = insertCours[0]['id_cours'] as int;
        } else {
          idCours = coursResponse[0]['id_cours'] as int;
        }

        final joursResponse = await supabase
            .from('jour')
            .select()
            .eq('nom', key.split('-')[0])
            .limit(1);
        final idJour = joursResponse[0]['id_jour'] as int;

        final horairesResponse = await supabase
            .from('horaire')
            .select()
            .eq('heure_debut', key.split('-')[1])
            .limit(1);
        final idHoraire = horairesResponse[0]['id_horaire'] as int;

        final seanceResponse = await supabase
            .from('seance')
            .select()
            .eq('contenu', '$matiere\n$titre\n$seanceNom')
            .limit(1);
        
        int idSeance;
        if (seanceResponse.isEmpty) {
          final insertSeance = await supabase
              .from('seance')
              .insert({'contenu': '$matiere\n$titre\n$seanceNom'})
              .select();
          idSeance = insertSeance[0]['id_seance'] as int;
        } else {
          idSeance = seanceResponse[0]['id_seance'] as int;
        }

        await supabase.from('emploi_du_temps').insert({
          'id_cours': idCours,
          'id_jour': idJour,
          'id_horaire': idHoraire,
          'id_seance': idSeance,
        });

        debugPrint('Sauvegardé: $niveau - $langue - $key');
      } catch (e) {
        debugPrint('Erreur sauvegarde: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${currentEmploi.niveau} - ${currentEmploi.langue}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF2563EB),
                    size: 35,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Emploi ${currentIndex + 1} / ${widget.emplois.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Horaire')),
                      ...widget.jours.map((j) => DataColumn(label: Text(j))),
                    ],
                    rows: widget.horaires.map((h) {
                      return DataRow(cells: [
                        DataCell(Text(h)),
                        ...widget.jours.map((j) {
                          String key = '$j-$h';

                          return DataCell(
                            InkWell(
                              onTap: () {
                                if (emploi[key] != null) {
                                  _showEmploiDetailDialog(context, key, emploi[key]!);
                                } else {
                                  _showAddSeanceDialog(context, key);
                                }
                              },
                              child: Container(
                                width: 170,
                                height: 90,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: emploi[key] != null
                                      ? Colors.green.shade100
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: emploi[key] == null
                                    ? const Center(child: Icon(Icons.add))
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          emploi[key]!,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentIndex--;
                      });
                    },
                    child: const Text('Retour'),
                  ),

                const Spacer(),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 18,
                    ),
                  ),
                  onPressed: () async {
                    await enregistrerDansBase();

                    if (currentIndex < widget.emplois.length - 1) {
                      setState(() {
                        currentIndex++;
                        emploi = {};
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tous les emplois sont enregistrés'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: Text(
                    currentIndex == widget.emplois.length - 1
                        ? 'Terminer'
                        : 'Enregistrer et Continuer',
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAddSeanceDialog(BuildContext context, String key) {
    String? matiere;
    String? titre;
    String? seance;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Ajouter séance'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Matière'),
                      items: matieres.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) {
                        setModalState(() {
                          matiere = v;
                          titre = null;
                          seance = null;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Titre'),
                      items: (titres[matiere] ?? []).map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) {
                        setModalState(() {
                          titre = v;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Séance'),
                      items: (seances[titre] ?? []).map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) {
                        setModalState(() {
                          seance = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      emploi[key] = '$matiere\n$titre\n$seance';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEmploiDetailDialog(BuildContext context, String key, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Détails - $key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Contenu de la séance', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(content, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}