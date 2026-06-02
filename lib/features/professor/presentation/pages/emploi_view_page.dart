import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmploiViewPage extends StatelessWidget {
  const EmploiViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emploi = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    
    if (emploi == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun emploi sélectionné')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    emploi['matiere'] ?? 'Emploi du Temps',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/prof/emploi/list'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 100,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Niveau: ${emploi['niveau'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Matière: ${emploi['matiere'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Interface d\'affichage de l\'emploi du temps',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}