import 'package:school_app/features/professor/data/datasources/emploi_datasource.dart';

class EmploiRepository {
  final EmploiDatasource datasource;

  EmploiRepository(this.datasource);

  Future<List<Map<String, dynamic>>> fetchNiveaux() async {
    return await datasource.getNiveaux();
  }

  Future<List<Map<String, dynamic>>> fetchMatieres() async {
    return await datasource.getMatieres();
  }

  Future<List<Map<String, dynamic>>> fetchJours() async {
    return await datasource.getJours();
  }

  Future<List<Map<String, dynamic>>> fetchHoraires() async {
    return await datasource.getHoraires();
  }

  Future<void> saveEmploi({
    required String niveau,
    required String langue,
    required String jour,
    required String heureDebut,
    required String contenu,
  }) async {
    final niveaux = await datasource.getNiveaux();
    final idNiveau = niveaux.firstWhere((n) => n['nom'] == niveau)['id_niveau'] as int;

    final matieres = await datasource.getMatieres();
    final idMatiere = matieres.firstWhere((m) => m['nom'] == langue)['id_matiere'] as int;

    final coursResponse = await datasource.client
        .from('cours')
        .insert({'id_niveau': idNiveau, 'id_matiere': idMatiere}).select();
    final idCours = coursResponse.first['id_cours'] as int;

    final jours = await datasource.getJours();
    final idJour = jours.firstWhere((j) => j['nom'] == jour)['id_jour'] as int;

    // id_horaire removed per new schema

    final seanceResponse = await datasource.client
        .from('seance')
        .insert({'contenu': contenu}).select();
    final idSeance = seanceResponse.first['id_seance'] as int;

    await datasource.createEmploi(
      idCours: idCours,
      idJour: idJour,
      // idHoraire removed
      idSeance: idSeance,
    );
  }

  Future<List<Map<String, dynamic>>> fetchEmploiByNiveau(String niveau) async {
    final niveaux = await datasource.getNiveaux();
    final idNiveau = niveaux.firstWhere((n) => n['nom'] == niveau)['id_niveau'] as int;

    final response = await datasource.client
        .from('cours')
        .select('*, emploi_du_temps(*), matiere(*)')
        .eq('id_niveau', idNiveau);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllEmploisWithDetails() async {
    final response = await datasource.client
        .from('cours')
        .select('id_niveau, id_matiere, niveau(nom), matiere(nom)')
        .limit(100);
    
    // Flatten the nested objects
    final List<Map<String, dynamic>> result = [];
    for (var item in response) {
      result.add({
        'id_niveau': item['id_niveau'],
        'id_matiere': item['id_matiere'],
        'niveau': item['niveau'] is Map ? item['niveau']['nom'] : item['niveau'],
        'matiere': item['matiere'] is Map ? item['matiere']['nom'] : item['matiere'],
      });
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getExistingEmploi() async {
    final response = await datasource.client
        .from('cours')
        .select('id_niveau, id_matiere')
        .limit(10);
    
    return List<Map<String, dynamic>>.from(response);
  }
}