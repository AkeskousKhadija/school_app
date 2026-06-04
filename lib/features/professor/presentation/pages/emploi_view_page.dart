import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/core/supabase/supabase_client.dart';

class EmploiViewPage extends StatefulWidget {
  const EmploiViewPage({super.key});

  @override
  State<EmploiViewPage> createState() => _EmploiViewPageState();
}

class _EmploiViewPageState extends State<EmploiViewPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSeances();
  }

  Future<void> _loadSeances() async {
    final emploi = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    if (emploi == null) return;

    try {
      final client = SupabaseClientProvider.client;
      final coursId = emploi['id_cours'] as int?;
      if (coursId != null) {
        final response = await client
            .from('seance')
            .select()
            .eq('id_cours', coursId)
            .order('numero_jour');
        if (!mounted) return;
        setState(() {
          _sessions = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur chargement séances: $e';
        _isLoading = false;
      });
    }
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Niveau: ${emploi['niveau'] ?? 'N/A'}'),
                  Text('Matière: ${emploi['matiere'] ?? 'N/A'}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(child: Center(child: Text(_errorMessage!)))
            else if (_sessions.isEmpty)
              const Expanded(child: Center(child: Text('Aucune séance programmée')))
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    final session = _sessions.firstWhere(
                      (s) => s['numero_jour'] == index + 1,
                      orElse: () => {},
                    );
                    final hasSession = session.isNotEmpty;
                    return Container(
                      decoration: BoxDecoration(
                        color: hasSession ? Colors.orange : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: hasSession
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    session['contenu'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '${session['duree']} min',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}