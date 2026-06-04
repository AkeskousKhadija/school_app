import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmploiFinalisationPage extends StatelessWidget {
  const EmploiFinalisationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Finalisation'),
      ),
      body: const Center(
        child: Text('Étape de finalisation de l’emploi.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/prof/dashboard'),
        label: const Text('Terminer'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
