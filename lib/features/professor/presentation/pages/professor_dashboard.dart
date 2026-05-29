import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/features/auth/presentation/viewmodels/auth_notifier.dart';

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

    return Scaffold(
      backgroundColor: getBgColor(),
      body: Row(
        children: [
          // SIDEBAR
          Container(
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
          ),

          // MAIN
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  // TOP BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [ _levelBtn('primaire'), _levelBtn('college'), _levelBtn('lycee') ]),

                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: logout, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Déconnexion'))
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () => context.go('/prof/emploi/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un Emploi'),
                  ),

                  const SizedBox(height: 20),

                  // ROADMAP / CARDS
                  Expanded(
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 300,
                            height: 500,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.lightBlue.withOpacity(0.3), width: 5),
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
                  )
                ],
              ),
            ),
          ),
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
      top: 200 + (top * 300),
      left: 100 + (left * 200),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10) ],
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)),
              child: Center(
                child: Icon(icon, size: 40, color: Colors.blue),
              ),
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
