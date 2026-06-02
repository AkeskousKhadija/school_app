import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/core/supabase/supabase_client.dart';

class CreateEmploiPage extends StatelessWidget {
  const CreateEmploiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouter.of(context).state.extra as List<Map<String, dynamic>>?;
    final List<Map<String, dynamic>> jobs = extra ?? [];
    
    if (jobs.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Aucun emploi à créer')),
      );
    }

    return ScheduleScreen(jobs: jobs);
  }
}

class ScheduleScreen extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;
  const ScheduleScreen({required this.jobs, super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int currentIndex = 0;

  void _showMatiereDialog(int index) {
    final currentJob = widget.jobs[currentIndex];
    final sessionsList = List<Map<String, dynamic>>.from(
      currentJob['sessions'] ?? []
    );
    final sessionAtIndex = sessionsList.isNotEmpty 
        ? sessionsList.firstWhere((s) => (s['index'] as int?) == index, orElse: () => {})
        : {};

    final matiereCtrl = TextEditingController(text: sessionAtIndex['matiere'] ?? '');
    final dureeCtrl = TextEditingController(text: sessionAtIndex['duree'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Matières enseignées",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Comic Sans MS',
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "la matière :",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: matiereCtrl,
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (matiereCtrl.text.isNotEmpty && dureeCtrl.text.isNotEmpty) {
                    final sessions = List<Map<String, dynamic>>.from(
                      currentJob['sessions'] ?? [],
                    );
                    
                    // Supprimer l'ancienne entrée à cet index
                    sessions.removeWhere((s) => (s['index'] as int?) == index);
                    
                    // Ajouter la nouvelle entrée
                    sessions.add({
                      'index': index,
                      'matiere': matiereCtrl.text,
                      'duree': dureeCtrl.text,
                    });
                    
                    currentJob['sessions'] = sessions;
                    setState(() {});
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Enregistrer la matière",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAllEmplois() async {
    try {
      final client = SupabaseClientProvider.client;
      
      for (var job in widget.jobs) {
        // Use IDs if provided, otherwise fallback to lookup by name
        int idNiveau = job['id_niveau'] ?? 0;
        int idMatiere = job['id_matiere'] ?? 0;

        // 1. Get niveau ID if not provided
        if (idNiveau == 0) {
          final niveauResult = await client
              .from('niveau')
              .select('id_niveau')
              .eq('nom', job['niveau'])
              .maybeSingle();
              
          if (niveauResult == null) {
            throw Exception('Niveau non trouvé: ${job['niveau']}');
          }
          idNiveau = niveauResult['id_niveau'];
        }

        // 2. Get matiere ID if not provided
        if (idMatiere == 0) {
          final matiereResult = await client
              .from('matiere')
              .select('id_matiere')
              .eq('nom', job['matiere'])
              .maybeSingle();
              
          if (matiereResult == null) {
            throw Exception('Matière non trouvée: ${job['matiere']}');
          }
          idMatiere = matiereResult['id_matiere'];
        }

        // 3. Create cours
        final coursResult = await client
            .from('cours')
            .insert({'id_niveau': idNiveau, 'id_matiere': idMatiere})
            .select('id_cours')
            .maybeSingle();
            
        if (coursResult == null) {
          throw Exception('Échec de création du cours');
        }
        final int idCours = coursResult['id_cours'];

        // 4. Create titre_cours
        final titreResult = await client
            .from('titre_cours')
            .insert({'nom': job['matiere'], 'id_cours': idCours})
            .select('id_titre')
            .maybeSingle();
            
        if (titreResult == null) {
          throw Exception('Échec de création du titre_cours');
        }
        final int idTitre = titreResult['id_titre'];

        // 5. Create seance for each session with duration from popup
        final sessions = List<Map<String, dynamic>>.from(job['sessions'] ?? []);
        for (var session in sessions) {
          final duree = session['duree'] ?? '45'; // Default to 45 if not provided
          final seanceResult = await client
              .from('seance')
              .insert({
                'contenu': session['matiere'] ?? 'Séance',
                'numero_ordre': 1,
                'duree': int.tryParse(duree) ?? 45,
                'id_titre': idTitre,
              })
              .select('id_seance')
              .maybeSingle();
              
          if (seanceResult == null) {
            throw Exception('Échec de création de la séance');
          }
          final int idSeance = seanceResult['id_seance'];

          // 6. Create emploi_du_temps
          await client.from('emploi_du_temps').insert({
            'id_cours': idCours,
            'id_jour': 1,
            'id_seance': idSeance,
          });
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emplois sauvegardés avec succès')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
      );
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
    final sessionsList = List<Map<String, dynamic>>.from(
      currentJob['sessions'] ?? []
    );

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
            color: Colors.black.withOpacity(0.5),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildAppBar(currentIndex + 1, widget.jobs.length),
                const SizedBox(height: 20),
                _buildHeader(currentJob),
                Expanded(child: _buildGrid()),
                _buildFooter(),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 50,
            right: 50,
            child: _buildFloatingNavBar(),
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
          Row(
            children: const [
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
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/images/icon.png',
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              "Créer l'emploi pour ${job['niveau']} - ${job['matiere']}",
              style: const TextStyle(
                fontSize: 24,
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
    
    final sessionsList = List<Map<String, dynamic>>.from(
      widget.jobs[currentIndex]['sessions'] ?? []
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (i) => Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.orange, width: 2)),
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
              ),
              itemCount: 24,
              itemBuilder: (context, index) {
                final sessionAtIndex = sessionsList.isNotEmpty 
                    ? sessionsList.firstWhere((s) => (s['index'] as int?) == index, orElse: () => {})
                    : {};
                final hasSession = sessionAtIndex.isNotEmpty;

                return GestureDetector(
                  onTap: () => _showMatiereDialog(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: hasSession 
                          ? const Color(0xFFFF7F50).withOpacity(0.7)
                          : Colors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: hasSession
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  sessionAtIndex['matiere'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '${sessionAtIndex['duree']} min',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            )
                          : const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(200, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            if (currentIndex < widget.jobs.length - 1) {
              setState(() {
                currentIndex++;
              });
            } else {
              await _saveAllEmplois();
            }
          },
          child: Text(
            currentIndex < widget.jobs.length - 1 
                ? "Suivant" 
                : "Terminer",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.layers_outlined, color: Colors.black54),
          Icon(Icons.book_outlined, color: Colors.black54),
          Icon(Icons.calendar_month, color: Colors.black),
          Icon(Icons.search, color: Colors.black54),
          Icon(Icons.person_outline, color: Colors.black54),
        ],
      ),
    );
  }
}