import 'package:school_app/features/professor/data/datasources/emploi_datasource.dart';

class EmploiRepository {
  final EmploiDatasource _datasource;

  EmploiRepository(this._datasource);

  Future<List<Map<String, dynamic>>) fetchNiveaux() async {
    return await _datasource.getNiveaux();
  }

  Future<List<Map<String, dynamic>>) fetchMatieres() async {
    return await _datasource.getMatieres();
  }

  Future<List<Map<String, dynamic>>) fetchJours() async {
    return await _datasource.getJours();
  }

  Future<List<Map<String, dynamic>>) fetchHoraires() async {
    return await _datasource.getHoraires();
  }

  Future<void> saveEmploi({
    required String niveau,
    required String langue,
    required String jour,
    required String heureDebut,
    required String contenu,
  }) async {
    final niveaux = await _datasource.getNiveaux();
    final idNiveau = niveaux.firstWhere((n) => n['nom'] == niveau)['id_niveau'] as int;

    final matieres = await _datasource.getMatieres();
    final idMatiere = matieres.firstWhere((m) => m['nom'] == matiere)['id_matiere'] as int;

    final coursResponse = await _datasource._client
        .from('cours')
        .insert({'id_niveau': idNiveau, 'id_matiere': idMatiere}).select();
    final idCours = coursResponse.first['id_cours'] as int;

    final jours = await _datasource.getJours();
    final idJour = jours.firstWhere((j) => j['nom'] == jour)['id_jour'] as int;

    final horaires = await _datasource.getHoraires();
    final idHoraire = horaires.firstWhere((h) => h['heure_debut'] == heureDebut)['id_horaire'] as int;

    final seanceResponse = await _datasource._client
        .from('seance')
        .insert({'contenu': contenu}).select();
    final idSeance = seanceResponse.first['id_seance'] as int;

    await _datasource.createEmploi(
      idCours: idCours,
      idJour: idJour,
      idHoraire: idHoraire,
      idSeance: idSeance,
    );
  }

  Future<List<Map<String, dynamic>>) fetchEmploiByNiveau(String niveau) async {
    final niveaux = await _datasource.getNiveaux();
    final idNiveau = niveaux.firstWhere((n) => n['nom'] == niveau)['id_niveau'] as int;

    final response = await _datasource._client
        .from('cours')
        .select('*, emploi_du_temps(*), matiere(*)')
        .eq('id_niveau', idNiveau);

    return List<Map<String, dynamic>>.from(response);
  }
}