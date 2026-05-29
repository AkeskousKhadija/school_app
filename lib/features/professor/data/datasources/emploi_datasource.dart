import 'package:supabase_flutter/supabase_flutter.dart';

class EmploiDatasource {
  final SupabaseClient client;

  EmploiDatasource(this.client);

  Future<List<Map<String, dynamic>>> getNiveaux() async {
    final response = await client.from('niveau').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMatieres() async {
    final response = await client.from('matiere').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getJours() async {
    final response = await client.from('numero_jour').select().order('numero');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getHoraires() async {
    final response = await client.from('horaire').select().order('heure_debut');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createEmploi({
    required int idCours,
    required int idJour,
    required int idHoraire,
    required int idSeance,
  }) async {
    final response = await client.from('emploi_du_temps').insert({
      'id_cours': idCours,
      'id_jour': idJour,
      'id_horaire': idHoraire,
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
}