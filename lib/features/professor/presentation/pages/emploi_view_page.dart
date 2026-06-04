import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/core/supabase/supabase_client.dart';
import 'package:school_app/features/professor/data/datasources/emploi_datasource.dart';

class EmploiViewPage extends StatefulWidget {
  const EmploiViewPage({super.key});

  @override
  State<EmploiViewPage> createState() => _EmploiViewPageState();
}

class _EmploiViewPageState extends State<EmploiViewPage> {
  Map<String, dynamic>? emploi;
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    emploi = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (emploi != null) {
      _loadSessions();
    } else {
      isLoading = false;
    }
  }

  Future<void> _loadSessions() async {
    try {
      final idEmploi = emploi?['id_emploi'] as int?;
      if (idEmploi == null) throw Exception('id_emploi manquant');

      final datasource = EmploiDatasource(SupabaseClientProvider.client);
      final result = await datasource.client
          .from('seance')
          .select('id_seance, contenu, duree, numero_jour, numero_ordre, id_cours, cours!inner(matiere, titre_cours)')
          .eq('id_emploi', idEmploi)
          .order('numero_ordre');

      final List<dynamic> raw = List<dynamic>.from(result);
      final List<Map<String, dynamic>> loaded =
          raw.map((e) => Map<String, dynamic>.from(e)).toList();

      if (!mounted) return;
      setState(() {
        sessions = loaded;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (emploi == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun emploi sélectionné')),
      );
    }

    final emploiId = emploi!['id_emploi']?.toString() ?? '';
    final niveau = emploi!['niveau']?.toString() ?? 'N/A';
    final matiere = emploi!['matiere']?.toString() ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Emploi #$emploiId'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Niveau: $niveau'),
                    subtitle: Text('Matière: $matiere'),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildGrid()),
                ],
              ),
            ),
    );
  }

  Widget _buildGrid() {
    if (sessions.isEmpty) {
      return const Center(child: Text('Aucune séance pour cet emploi'));
    }

    List<Map<String, dynamic>> getSessionsByDay(int dayIndex) {
      return sessions.where((s) {
        final jour = s['numero_jour'] as int? ?? 0;
        return jour == dayIndex + 1;
      }).toList();
    }

    Widget buildSessionCell(Map<String, dynamic> session) {
      final duree = session['duree']?.toString() ?? '';
      final titre = session['contenu']?.toString() ?? '';

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$duree min',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildDayColumn(int dayIndex) {
      final daySessions = getSessionsByDay(dayIndex);
      final maxRows = daySessions.isEmpty ? 1 : daySessions.length;

      return Expanded(
        child: Column(
          children: List.generate(maxRows, (rowIdx) {
            final session =
                daySessions.length > rowIdx ? daySessions[rowIdx] : null;
            return Expanded(
              child: session != null
                  ? buildSessionCell(session)
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                    ),
            );
          }),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 120,
                height: 36,
                alignment: Alignment.center,
              ),
              const SizedBox(width: 8),
              ...List.generate(
                6,
                (i) => Expanded(
                  child: Container(
                    height: 36,
                    margin: const EdgeInsets.only(right: 0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: const Text(
                    'Partie',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(
                  6,
                  (dayIndex) => buildDayColumn(dayIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
