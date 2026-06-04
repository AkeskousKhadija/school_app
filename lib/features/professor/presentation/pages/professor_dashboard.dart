import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/features/auth/presentation/viewmodels/auth_notifier.dart';
import 'package:school_app/core/theme/app_theme.dart';

class ProfessorDashboard extends ConsumerStatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  ConsumerState<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends ConsumerState<ProfessorDashboard> {
  String level = 'primaire';

  void setTheme(String newLevel) {
    setState(() {
      level = newLevel;
    });
  }

  Color getBgColor() {
    switch (level) {
      case 'college':
        return const Color(0xFFBBDEFB);
      case 'lycee':
        return const Color(0xFFC5CAE9);
      default:
        return const Color(0xFFE1F5FE);
    }
  }

  Color getActiveColor() {
    switch (level) {
      case 'college':
        return const Color(0xFF2196F3);
      case 'lycee':
        return const Color(0xFF3F51B5);
      default:
        return const Color(0xFF03A9F4);
    }
  }

  Future<void> logout() async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppBreakpoints.tablet;

    return Scaffold(
      backgroundColor: getBgColor(),
      drawer: isMobile ? _buildMobileDrawer(context, user) : null,
      body: isMobile 
        ? _buildMobileLayout(context, user)
        : _buildDesktopLayout(context, user),
    );
  }

  Widget _buildMobileLayout(BuildContext context, dynamic user) {
    return Column(
      children: [
        _buildMobileAppBar(context),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMainContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, dynamic user) {
    return Row(
      children: [
        _buildSidebar(context, user),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: _buildMainContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, dynamic user) {
    return Container(
      width: 280,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                child: user?.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user!.avatarUrl!,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Text('👦'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.fullName ?? 'Professeur', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Niveau $level', style: TextStyle(color: getActiveColor(), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          _navItem(Icons.map, 'Mon Parcours', true),
          _navItem(Icons.message, 'Messages', false),
          _navItem(Icons.notifications, 'Notifications', false),
          _navItem(Icons.show_chart, 'Mes Progrès', false),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text('Score: 1250 XP', style: TextStyle(color: const Color(0xFF1A4A7A), fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: 0.65, backgroundColor: Colors.white, color: Colors.lightBlue),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, dynamic user) {
    return Drawer(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade200,
                  child: user?.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            user!.avatarUrl!,
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Text('👦'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? 'Professeur', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Niveau $level', style: TextStyle(color: getActiveColor(), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),
            _navItem(Icons.map, 'Mon Parcours', true),
            _navItem(Icons.message, 'Messages', false),
            _navItem(Icons.notifications, 'Notifications', false),
            _navItem(Icons.show_chart, 'Mes Progrès', false),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text('Score: 1250 XP', style: TextStyle(color: const Color(0xFF1A4A7A), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: 0.65, backgroundColor: Colors.white, color: Colors.lightBlue),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      color: getBgColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {}),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 12)),
                child: const Text('Déconnexion', style: TextStyle(fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppBreakpoints.tablet;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) _buildTopBar(context),
          if (isMobile) _buildMobileTopBar(context),
          const SizedBox(height: 20),
          _buildActionButtons(context, isMobile),
          const SizedBox(height: 20),
          if (!isMobile) _buildRoadmapCards(),
          if (isMobile) _buildMobileCardsGrid(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _levelBtn('primaire'),
              const SizedBox(width: 8),
              _levelBtn('college'),
              const SizedBox(width: 8),
              _levelBtn('lycee'),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: logout, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Déconnexion')),
          ],
        )
      ],
    );
  }

  Widget _buildMobileTopBar(BuildContext context) {
    return Wrap(spacing: 8, children: [ _levelBtn('primaire'), _levelBtn('college'), _levelBtn('lycee') ]);
  }

  Widget _buildActionButtons(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/prof/emploi/list'),
              icon: const Icon(Icons.list),
              label: const Text('Liste des Emplois'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/prof/emploi'),
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Mon Emploi du Temps'),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/prof/emploi/list'),
          icon: const Icon(Icons.list),
          label: const Text('Liste des Emplois'),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => context.go('/prof/emploi'),
          icon: const Icon(Icons.edit_calendar),
          label: const Text('Mon Emploi du Temps'),
        ),
      ],
    );
  }

  Widget _buildRoadmapCards() {
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlue.withValues(alpha: 0.3), width: 5),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),
          _card(Icons.calculate, 'Maths Quests', 0, 0, true),
          _card(Icons.text_fields, 'Word Adventures', 0.15, 0.25, true),
          _card(Icons.science, 'Science Explorers', 0.45, 0.45, false),
          _card(Icons.history, 'History Mystery', 0.7, 0.7, null),
        ],
      ),
    );
  }

  Widget _buildMobileCardsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: [
        _buildMobileCard(Icons.calculate, 'Maths Quests', true),
        _buildMobileCard(Icons.text_fields, 'Word Adventures', true),
        _buildMobileCard(Icons.science, 'Science Explorers', false),
        _buildMobileCard(Icons.history, 'History Mystery', null),
      ],
    );
  }

  Widget _buildMobileCard(IconData icon, String title, bool? status) {
    Color badgeColor;
    if (status == true) badgeColor = Colors.lightBlue;
    else if (status == false) badgeColor = Colors.grey;
    else badgeColor = Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)),
            child: Center(child: Icon(icon, size: 40, color: Colors.blue)),
          ),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Icon(Icons.circle, size: 12, color: badgeColor),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: active ? Colors.grey.shade100 : Colors.transparent, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [ Icon(icon, color: Colors.grey), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold)) ]),
    );
  }

  Widget _levelBtn(String lvl) {
    final isActive = level == lvl;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.white : Colors.grey.shade200,
          foregroundColor: isActive ? getActiveColor() : Colors.grey,
        ),
        onPressed: () => setTheme(lvl),
        child: Text(lvl),
      ),
    );
  }

  Widget _card(IconData icon, String title, double top, double left, bool? status) {
    Color badgeColor;
    if (status == true) badgeColor = Colors.lightBlue;
    else if (status == false) badgeColor = Colors.grey;
    else badgeColor = Colors.blue;

    return Positioned(
      top: 100 + (top * 200),
      left: 50 + (left * 200),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)),
              child: Center(child: Icon(icon, size: 40, color: Colors.blue)),
            ),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Icon(Icons.circle, size: 12, color: badgeColor),
          ],
        ),
      ),
    );
  }
}