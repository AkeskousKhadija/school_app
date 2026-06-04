import 'package:school_app/features/professor/data/datasources/emploi_datasource.dart';

class EmploiRepository {
  final EmploiDatasource datasource;

  EmploiRepository(this.datasource);

  Future<List<Map<String, dynamic>>> fetchNiveaux() async {
    return await datasource.getNiveaux();
  }

  Future<List<Map<String, dynamic>>> fetchJours() async {
    return await datasource.getJours();
  }

  Future<List<Map<String, dynamic>>> fetchHoraires() async {
    return await datasource.getHoraires();
  }

  Future<List<Map<String, dynamic>>> fetchMatieres() async {
    return await datasource.getMatieres();
  }

  Future<List<Map<String, dynamic>>> getExistingEmploi() async {
    final response = await datasource.client
        .from('cours')
        .select('id_niveau, id_matiere')
        .limit(10);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllEmploisWithDetails() async {
    return await datasource.getAllEmploisWithDetails();
  }

  Future<List<Map<String, dynamic>>> fetchCoursByNiveauAndMatiere(int idNiveau, String matiere) async {
    return await datasource.getCoursByNiveauAndMatiere(idNiveau, matiere);
  }
}