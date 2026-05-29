import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:school_app/features/shared/domain/entities/user.dart';
import 'package:school_app/features/shared/domain/entities/user_role.dart';

class SupabaseAuthDatasource {
  final supa.SupabaseClient client;

  SupabaseAuthDatasource(this.client);

  Future<supa.AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<supa.AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? department,
    String? specialization,
    String? phone,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.value,
      },
    );

    if (response.user != null) {
      final userRecord = {
        'id': response.user!.id,
        'full_name': fullName,
        'role': role.value,
        'email': email,
      };

      // Upsert into application 'users' table
      await client.from('users').upsert(userRecord);

      // If professor, upsert additional professor-specific fields
      if (role == UserRole.professor) {
        final professorRecord = {
          'id': response.user!.id,
          if (department != null) 'department': department,
          if (specialization != null) 'specialization': specialization,
          if (phone != null) 'phone': phone,
        };
        await client.from('professor').upsert(professorRecord);
      }
    }

    return response;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  supa.User? getCurrentUser() {
    return client.auth.currentUser;
  }

  Stream<supa.AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
