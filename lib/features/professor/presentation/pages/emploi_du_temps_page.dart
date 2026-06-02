import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/core/supabase/supabase_client.dart';
import 'package:school_app/features/professor/data/datasources/emploi_datasource.dart';
import 'package:school_app/features/professor/data/repositories/emploi_repository.dart';

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
  List<Map<String, dynamic>> _matieresList = [];
  List<List<bool>> _matiereSelections = [];

  @override
  void initState() {
    super.initState();
    _loadNiveaux();
  }

void _loadNiveaux() async {
    try {
      final client = SupabaseClientProvider.client;
      final repository = EmploiRepository(EmploiDatasource(client));

      // Fetch levels
      final niveaux = await repository.fetchNiveaux();
      debugPrint('Niveaux récupérés : $niveaux');

      // Fetch matiere data (for selection UI)
      debugPrint('Starting matiere fetch...');
      try {
        final response = await client
            .from('matiere')
            .select('id_matiere, nom')
            .order('nom')
            .limit(100);

        debugPrint('Raw response: $response');
        debugPrint('Response type: ${response.runtimeType}');

        if (response == null || (response as List).isEmpty) {
          debugPrint('Empty matiere response!');
          _matieresList = [];
        } else {
          _matieresList = (response as List).cast<Map<String, dynamic>>().toList();
        }
      } catch (e) {
        debugPrint('Matiere fetch error: $e');
        _matieresList = [];
      }

      // Extract level names and IDs
      _levelLabels = niveaux.map((n) => n['nom']?.toString() ?? '').toList();
      _niveauIds = niveaux.map((n) => n['id_niveau'] as int).toList();

      // Initialize selection arrays
      _selectedLevels = List.filled(_levelLabels.length, false);
      _matiereSelections = List.generate(
        _levelLabels.length,
        (_) => List.filled(_matieresList.length, false),
      );

      // Check for existing emploi to modify (after initialization)
      try {
        final existing = await repository.getExistingEmploi();
        if (existing != null && existing.isNotEmpty) {
          for (var emploi in existing) {
            final idNiveau = emploi['id_niveau'] as int?;
            final idMatiere = emploi['id_matiere'] as int?;
            if (idNiveau != null && idMatiere != null) {
              final niveauIndex = _niveauIds.indexOf(idNiveau);
              final matiereIndex = _matieresList.indexWhere((m) => m['id_matiere'] == idMatiere);
              if (niveauIndex >= 0 && matiereIndex >= 0) {
                _selectedLevels[niveauIndex] = true;
                _matiereSelections[niveauIndex][matiereIndex] = true;
              }
            }
          }
          debugPrint('Existing emploi loaded for modification: ${existing.length} items');
        }
      } catch (e) {
        debugPrint('No existing emploi found or error loading: $e');
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible de charger les données depuis la base de données.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildTopBar(),
                const SizedBox(height: 20),
                _buildMainTitleSection(),
                const SizedBox(height: 20),
                Expanded(child: _buildGridOfLevels()),
                _buildContinueButton(),
                const SizedBox(height: 20),
                _buildBottomNavigationBar(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ghizlane',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Column(
            children: [
              const Text(
                'Étape 1 sur 3',
                style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Container(
                width: 65,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            ],
          ),
          Row(
            children: [
              const Icon(Icons.dark_mode_outlined, size: 22),
              const SizedBox(width: 20),
              const Icon(Icons.notifications_none_outlined, size: 24),
              const SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.23), width: 1),
                ),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage('lib/assets/images/icon.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainTitleSection() {
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
          const Expanded(
            child: Text(
              'Quels niveaux enseignez-vous ?',
              style: TextStyle(
                fontSize: 36,
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

  Widget _buildGridOfLevels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _levelLabels.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 20,
          childAspectRatio: 1.8,
        ),
        itemBuilder: (context, index) {
          final isSelected = _selectedLevels[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedLevels[index] = !isSelected;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFBB000) : Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? null : Border.all(
                  color: Colors.white.withOpacity(0.30),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _levelLabels[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black87 : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: List.generate(
                          _matieresList.length,
                          (matiereIndex) {
                            final matiere = _matieresList[matiereIndex];
                            final isMatiereSelected = _matiereSelections[index][matiereIndex];
                            return _buildMatiereChip(
                              matiere['nom'] as String,
                              isSelected,
                              isMatiereSelected,
                              () {
                                setState(() {
                                  _matiereSelections[index][matiereIndex] = !isMatiereSelected;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.check, size: 16, color: Color(0xFFFBB000)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatiereChip(
      String label,
      bool cardSelected,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (cardSelected ? Colors.white : const Color(0xFFFBB000))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (cardSelected ? Colors.black54 : Colors.white54),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: cardSelected ? const Color(0xFFFBB000) : Colors.black,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (cardSelected ? const Color(0xFFFBB000) : Colors.black)
                    : (cardSelected ? Colors.black87 : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        final jobs = <Map<String, dynamic>>[];
        for (int i = 0; i < _levelLabels.length; i++) {
          if (_selectedLevels[i]) {
            final niveau = _levelLabels[i];
            final idNiveau = _niveauIds[i];
            for (int j = 0; j < _matieresList.length; j++) {
              if (_matiereSelections[i][j]) {
                final matiere = _matieresList[j];
                jobs.add({
                  'niveau': niveau,
                  'matiere': matiere['nom'],
                  'id_niveau': idNiveau,
                  'id_matiere': matiere['id_matiere'],
                });
              }
            }
          }
        }
        if (jobs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner au moins un niveau et une matière')),
          );
          return;
        }
        GoRouter.of(context).push('/prof/emploi/create', extra: jobs);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFBB000),
        minimumSize: const Size(200, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
      ),
      child: const Text(
        'Continuer',
        style: TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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