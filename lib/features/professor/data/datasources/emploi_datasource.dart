import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmploiDatasource {
  final SupabaseClient client;

  EmploiDatasource(this.client);

  Future<List<Map<String, dynamic>>> getNiveaux() async {
    final response = await client.from('niveau').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getJours() async {
    final response = await client.from('jour').select().order('numero');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMatieres() async {
    final response = await client.from('matiere').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getCoursByNiveauAndMatiere(int idNiveau, String matiere) async {
    final response = await client
        .from('cours')
        .select('id_cours, titre_cours')
        .eq('id_niveau', idNiveau)
        .eq('matiere', matiere);
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
    debugPrint('getCoursByNiveauAndMatiere: idNiveau=$idNiveau, matiere=$matiere, total=${data.length}');
    return data;
  }

  Future<List<Map<String, dynamic>>> getHoraires() async {
    final response = await client.from('horaire').select().order('heure_debut');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getExistingEmplois() async {
    final response = await client
        .from('emploi_du_temps')
        .select('id_emploi, seance!inner(id_cours, cours!inner(id_niveau, matiere))');
    final List<dynamic> raw = List<dynamic>.from(response);
    return raw.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getSessionsForJob(int idNiveau, String matiere) async {
    final coursResponse = await client
        .from('cours')
        .select('id_cours')
        .eq('id_niveau', idNiveau)
        .eq('matiere', matiere);
    final List<dynamic> coursList = List<dynamic>.from(coursResponse);
    if (coursList.isEmpty) return [];

    final idsCours = coursList.map((c) => c['id_cours'] as int).toList();
    final seancesResponse = await client
        .from('seance')
        .select('id_seance, contenu, numero_ordre, duree, numero_jour, id_cours, id_emploi')
        .inFilter('id_cours', idsCours)
        .order('numero_jour')
        .order('numero_ordre');
    return List<Map<String, dynamic>>.from(seancesResponse);
  }

  Future<Map<String, dynamic>> createEmploi({
    required int idCours,
    required int idJour,
    required int idSeance,
  }) async {
    final response = await client.from('emploi_du_temps').insert({
      'id_cours': idCours,
      'id_jour': idJour,
      // 'id_horaire' removed per new schema
      'id_seance': idSeance,
    }).select();
    return response.first;
  }

  Future<List<Map<String, dynamic>>> getEmploiByCours(int idCours) async {
    final response = await client
        .from('emploi_du_temps')
        .select('*, numero_jour(*), horaire(*), seance(*), titre_cours(*), cours(*), matiere(*)')
        .eq('id_cours', idCours);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllEmploisWithDetails() async {
    final response = await client
        .from('seance')
        .select('id_emploi, cours!inner(id_cours, matiere, id_niveau, niveau!inner(id_niveau, nom))');
    final List<dynamic> raw = List<dynamic>.from(response);
    final Map<int, Map<String, dynamic>> uniqueEmplois = {};
    for (final item in raw) {
      final map = Map<String, dynamic>.from(item);
      final idEmploi = map['id_emploi'] as int?;
      if (idEmploi != null && !uniqueEmplois.containsKey(idEmploi)) {
        final cours = Map<String, dynamic>.from(map['cours'] ?? {});
        final niveau = Map<String, dynamic>.from(cours['niveau'] ?? {});
        uniqueEmplois[idEmploi] = {
          'id_emploi': idEmploi,
          'id_niveau': cours['id_niveau'],
          'niveau': niveau['nom'],
          'matiere': cours['matiere'],
        };
      }
    }
    return uniqueEmplois.values.toList();
  }
}
