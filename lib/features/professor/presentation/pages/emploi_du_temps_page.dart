import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/core/supabase/supabase_client.dart';
import 'package:school_app/core/theme/app_theme.dart';
import 'package:school_app/features/professor/data/datasources/emploi_datasource.dart';

class EmploiDuTempsPage extends StatefulWidget {
  const EmploiDuTempsPage({super.key});

  @override
  State<EmploiDuTempsPage> createState() => _EmploiDuTempsPageState();
}

class _EmploiDuTempsPageState extends State<EmploiDuTempsPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<int> _niveauIds = [];
  List<String> _levelLabels = [];
  List<bool> _selectedLevels = [];
  List<String?> _selectedMatiereParNiveau = [];

  @override
  void initState() {
    super.initState();
    _loadNiveaux();
  }

  void _loadNiveaux() async {
    try {
      final client = SupabaseClientProvider.client;
      final response = await client.from('niveau').select();
      _levelLabels = (response as List).map((n) => n['nom']?.toString() ?? '').toList();
      _niveauIds = (response).map((n) => n['id_niveau'] as int).toList();
      _selectedLevels = List.filled(_levelLabels.length, false);
      _selectedMatiereParNiveau = List.filled(_levelLabels.length, null);

      // Charger les emplois existants pour pré-sélectionner
      try {
        final datasource = EmploiDatasource(client);
        final existingEmplois = await datasource.getExistingEmplois();
        
        for (var emploi in existingEmplois) {
          final seanceRaw = emploi['seance'];
          if (seanceRaw == null) continue;
          final List<dynamic> seanceList = seanceRaw is List ? seanceRaw : <dynamic>[seanceRaw];
          if (seanceList.isEmpty) continue;
          final Map<String, dynamic> seance = Map<String, dynamic>.from(seanceList.first);

          final coursRaw = seance['cours'];
          if (coursRaw == null) continue;
          final List<dynamic> coursList = coursRaw is List ? coursRaw : <dynamic>[coursRaw];
          if (coursList.isEmpty) continue;
          final Map<String, dynamic> cours = Map<String, dynamic>.from(coursList.first);

          final idNiveau = cours['id_niveau'] as int?;
          final matiere = cours['matiere']?.toString();
          if (idNiveau == null || matiere == null) continue;

          final niveauIndex = _niveauIds.indexOf(idNiveau);
          if (niveauIndex >= 0) {
            _selectedLevels[niveauIndex] = true;
            final current = _selectedMatiereParNiveau[niveauIndex] ?? '';
            final newMatiere = '$current$matiere';
            _selectedMatiereParNiveau[niveauIndex] = newMatiere.isEmpty ? null : newMatiere;
          }
        }
      } catch (e) {
        debugPrint('Erreur chargement emplois existants: $e');
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible de charger les données depuis la base de données.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppBreakpoints.tablet;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.5)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildTopBar(isMobile),
                const SizedBox(height: 20),
                _buildMainTitleSection(isMobile),
                const SizedBox(height: 20),
                Expanded(child: _buildGridOfLevels(isMobile)),
                _buildContinueButton(),
                const SizedBox(height: 20),
                _buildBottomNavigationBar(isMobile),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ghizlane',
            style: TextStyle(
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Column(
            children: [
              Text(
                'Étape 1 sur 3',
                style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.white70, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Container(
                width: 50,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            ],
          ),
          Row(
            children: [
              const Icon(Icons.dark_mode_outlined, size: 20),
              const SizedBox(width: 12),
              const Icon(Icons.notifications_none_outlined, size: 22),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.23), width: 1),
                ),
                child: const CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage('lib/assets/images/icon.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainTitleSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMobile)
            Image.asset(
              'lib/assets/images/icon.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          if (!isMobile) const SizedBox(width: 24),
          Expanded(
            child: Text(
              'Quels niveaux enseignez-vous ?',
              style: TextStyle(
                fontSize: isMobile ? 18 : 36,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFBB000),
                fontFamily: isMobile ? null : 'Impact',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOfLevels(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _levelLabels.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : 3,
          crossAxisSpacing: isMobile ? 12 : 24,
          mainAxisSpacing: isMobile ? 12 : 20,
          childAspectRatio: 2.75,
        ),
        itemBuilder: (context, index) {
          final isSelected = _selectedLevels[index];
          final matieresSelectionnees = _selectedMatiereParNiveau[index] ?? '';

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedLevels[index] = !isSelected;
              });
            },
            child: Container(
              width: 368,
              height: 160,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFBB000) : Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? null : Border.all(
                  color: Colors.white.withValues(alpha: 0.30),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 11 : 13,
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 6 : 12),
                      Expanded(
                        child: Text(
                          _levelLabels[index],
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black87 : Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (isSelected) ...[
                    Text(
                      'Matières :',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: [
                        FilterChip(
                          label: const Text('Arabe', style: TextStyle(fontSize: 10)),
                          selected: matieresSelectionnees.contains('Arabe'),
                          onSelected: (s) {
                            setState(() {
                              if (s) {
                                _selectedMatiereParNiveau[index] = 
                                  '${_selectedMatiereParNiveau[index] ?? ''}Arabe';
                              } else {
                                _selectedMatiereParNiveau[index] = 
                                  (_selectedMatiereParNiveau[index] ?? '').replaceAll('Arabe', '');
                              }
                              if (_selectedMatiereParNiveau[index]?.isEmpty ?? true) {
                                _selectedMatiereParNiveau[index] = null;
                              }
                            });
                          },
                          selectedColor: Colors.orange.shade200,
                          backgroundColor: Colors.black26,
                          labelStyle: TextStyle(
                            color: matieresSelectionnees.contains('Arabe') ? Colors.black : Colors.white,
                            fontSize: 10,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        FilterChip(
                          label: const Text('Français', style: TextStyle(fontSize: 10)),
                          selected: matieresSelectionnees.contains('Français'),
                          onSelected: (s) {
                            setState(() {
                              if (s) {
                                _selectedMatiereParNiveau[index] = 
                                  '${_selectedMatiereParNiveau[index] ?? ''}Français';
                              } else {
                                _selectedMatiereParNiveau[index] = 
                                  (_selectedMatiereParNiveau[index] ?? '').replaceAll('Français', '');
                              }
                              if (_selectedMatiereParNiveau[index]?.isEmpty ?? true) {
                                _selectedMatiereParNiveau[index] = null;
                              }
                            });
                          },
                          selectedColor: Colors.orange.shade200,
                          backgroundColor: Colors.black26,
                          labelStyle: TextStyle(
                            color: matieresSelectionnees.contains('Français') ? Colors.black : Colors.white,
                            fontSize: 10,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () async {
        List<Map<String, dynamic>> jobs = [];
        for (int i = 0; i < _levelLabels.length; i++) {
          if (_selectedLevels[i]) {
            final niveau = _levelLabels[i];
            final idNiveau = _niveauIds[i];
            final matieresStr = _selectedMatiereParNiveau[i] ?? '';
            final List<String> matieres = [];
            if (matieresStr.contains('Arabe')) matieres.add('Arabe');
            if (matieresStr.contains('Français')) matieres.add('Français');
            for (final matiere in matieres) {
              jobs.add({
                'niveau': niveau,
                'matiere': matiere,
                'id_niveau': idNiveau,
              });
            }
          }
        }
        if (jobs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner au moins un niveau et une matière')),
          );
          return;
        }
        final datasource = EmploiDatasource(SupabaseClientProvider.client);
        for (final job in jobs) {
          final idNiveau = job['id_niveau'] as int? ?? 0;
          final matiere = job['matiere']?.toString() ?? '';
          final res = await datasource.getCoursByNiveauAndMatiere(idNiveau, matiere);
          debugPrint('Étape 1 -> Niveau=${job['niveau']}, Matiere=$matiere, total titre_cours=${res.length}');
        }
        if (!mounted) return;
        GoRouter.of(context).push('/prof/emploi/create', extra: jobs);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFBB000),
        minimumSize: const Size(180, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
      ),
      child: const Text(
        'Continuer',
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isMobile) {
    if (isMobile) {
      return NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (_) {},
        destinations: const [
          NavigationDestination(icon: Icon(Icons.layers_outlined), label: 'Cours'),
          NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Mat'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Emploi'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Rech'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      );
    }
    return Container(
      width: 420,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.all(Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.layers_outlined, color: Colors.black87, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.import_contacts_outlined, color: Colors.black87, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.black87, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Colors.black87, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}