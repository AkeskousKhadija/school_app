import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/core/supabase/supabase_client.dart';
import 'package:school_app/features/professor/data/datasources/emploi_datasource.dart';
import 'package:school_app/features/professor/data/repositories/emploi_repository.dart';

class EmploiListPage extends StatefulWidget {
  const EmploiListPage({super.key});

  @override
  State<EmploiListPage> createState() => _EmploiListPageState();
}

class _EmploiListPageState extends State<EmploiListPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _emplois = [];

  @override
  void initState() {
    super.initState();
    _loadEmplois();
  }

  Future<void> _loadEmplois() async {
    try {
      final client = SupabaseClientProvider.client;
      final repository = EmploiRepository(EmploiDatasource(client));
      
      final emplois = await repository.getAllEmploisWithDetails();
      
      if (!mounted) return;
      setState(() {
        _emplois = emplois;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible de charger les emplois: $e';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes Emplois du Temps',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/prof/dashboard'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _emplois.isEmpty
                  ? const Center(child: Text('Aucun emploi créé'))
                  : ListView.builder(
                      itemCount: _emplois.length,
                      itemBuilder: (context, index) {
                        final emploi = _emplois[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(emploi['matiere']?.toString() ?? 'Sans titre'),
                            subtitle: Text('Niveau: ${emploi['niveau']?.toString() ?? 'N/A'}'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              context.go('/prof/emploi/view', extra: emploi);
                            },
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