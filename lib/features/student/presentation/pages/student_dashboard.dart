import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_app/features/auth/presentation/viewmodels/auth_notifier.dart';
import 'package:school_app/core/theme/app_theme.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppBreakpoints.tablet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Étudiant - Betif'),
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
      children: [
        Text(
          'Bienvenue ${user?.fullName ?? ''}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'Ici : mes notes, emploi du temps, cours, devoirs',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue ${user?.fullName ?? ''}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Prêt pour vos études aujourd\'hui ?'),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildQuickActions(context),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _actionCard(Icons.book, 'Cours', Colors.blue),
        _actionCard(Icons.assignment, 'Devoirs', Colors.green),
        _actionCard(Icons.schedule, 'Emploi du temps', Colors.orange),
        _actionCard(Icons.bar_chart, 'Notes', Colors.purple),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, Color color) {
    return Container(
      width: 120,
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
