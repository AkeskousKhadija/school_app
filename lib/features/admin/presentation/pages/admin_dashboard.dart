import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_app/features/auth/presentation/viewmodels/auth_notifier.dart';
import 'package:school_app/core/theme/app_theme.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppBreakpoints.tablet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin - Betif'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: isMobile 
          ? _buildMobileContent(context, user)
          : _buildDesktopContent(context, user),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context, dynamic user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Bienvenue Admin : ${user?.fullName ?? ''}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'Gestion utilisateurs, classes, statistiques globales',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        _buildAdminActions(context),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context, dynamic user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue Admin : ${user?.fullName ?? ''}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Panneau d\'administration complet'),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildAdminActions(context),
        ),
      ],
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _actionCard(Icons.people, 'Utilisateurs', Colors.blue),
        _actionCard(Icons.class_, 'Classes', Colors.green),
        _actionCard(Icons.bar_chart, 'Statistiques', Colors.orange),
        _actionCard(Icons.settings, 'Paramètres', Colors.purple),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
