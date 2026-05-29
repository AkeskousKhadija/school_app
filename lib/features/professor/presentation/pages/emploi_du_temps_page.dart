import 'package:flutter/material.dart';

class EmploiDuTempsPage extends StatefulWidget {
  const EmploiDuTempsPage({super.key});

  @override
  State<EmploiDuTempsPage> createState() => _EmploiDuTempsPageState();
}

class _EmploiDuTempsPageState extends State<EmploiDuTempsPage> {
  // État de sélection pour les 6 niveaux (tous sélectionnés par défaut comme sur l'image)
  final List<bool> _selectedLevels = List.generate(6, (index) => true);

  final List<String> _levelLabels = [
    '1ère année',
    '2ème année',
    '3ème année',
    '4ème année',
    '5ème année',
    '6ème année',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Image de fond avec filtre d'assombrissement
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('img/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // 2. Contenu de la page
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

  // --- Barre supérieure (Header) ---
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'QAMAR',
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
                  backgroundImage: AssetImage('img/icon.png'), // Mini-avatar en haut à droite
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section Titre avec l'Avatar Enseignant ---
  Widget _buildMainTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'img/icon.png',
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
                color: Color(0xFFFBB000), // Jaune/Orange vif de l'interface
                fontFamily: 'Impact', // Optionnel : à remplacer par votre police personnalisée compacte
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

  // --- Grille de cartes (3 Colonnes x 2 Lignes) ---
  Widget _buildGridOfLevels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 20,
          childAspectRatio: 2.3, // Gère le ratio rectangulaire exact des cartes
        ),
        itemBuilder: (context, index) {
          final isSelected = _selectedLevels[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedLevels[index] = !_selectedLevels[index];
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFBB000) : Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.30), width: 1.5),
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
                          // Index du niveau en haut à gauche
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
                          // Indicateurs de Langues (Français / Arabe)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLanguageRow('Français', isSelected),
                              const SizedBox(height: 4),
                              _buildLanguageRow('Arab', isSelected),
                            ],
                          )
                        ],
                      ),
                      // Intitulé du niveau (ex: 1ère année)
                      Text(
                        _levelLabels[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Checkmark blanc en haut à droite
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

  Widget _buildLanguageRow(String language, bool isCardSelected) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 15,
          color: isCardSelected ? Colors.black87 : Colors.white60,
        ),
        const SizedBox(width: 6),
        Text(
          language,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isCardSelected ? Colors.black87 : Colors.white,
          ),
        ),
      ],
    );
  }

  // --- Bouton Continuer ---
  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {},
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

  // --- Barre de Navigation Flottante Blanche/Gris Clair ---
  Widget _buildBottomNavigationBar() {
    return Container(
      width: 420,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
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