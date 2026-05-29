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

    final horaires = await datasource.getHoraires();
    final idHoraire = horaires.firstWhere((h) => h['heure_debut'] == heureDebut)['id_horaire'] as int;

    final seanceResponse = await datasource.client
        .from('seance')
        .insert({'contenu': contenu}).select();
    final idSeance = seanceResponse.first['id_seance'] as int;

    await datasource.createEmploi(
      idCours: idCours,
      idJour: idJour,
      idHoraire: idHoraire,
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
}