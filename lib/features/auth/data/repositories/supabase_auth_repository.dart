import 'package:fpdart/fpdart.dart';
import 'package:school_app/core/errors/failures.dart';
import 'package:school_app/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:school_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_app/features/shared/domain/entities/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:school_app/features/shared/domain/entities/user.dart' as domainUser;

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseAuthDatasource datasource;

  SupabaseAuthRepository(this.datasource);

  @override
  Future<Either<Failure, domainUser.User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await datasource.signInWithEmail(
        email: email,
        password: password,
      );

      final user = _mapSupabaseUserToDomain(response.user);
      if (user == null) {
        return left(const AuthFailure('Utilisateur introuvable'));
      }
      return right(user);
    } on supa.AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domainUser.User>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? department,
    String? specialization,
    String? phone,
  }) async {
    try {
      final response = await datasource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        department: department,
        specialization: specialization,
        phone: phone,
      );

      final user = _mapSupabaseUserToDomain(response.user);
      if (user == null) {
        return left(const AuthFailure('Inscription échouée'));
      }
      return right(user);
    } on supa.AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('rate') || msg.contains('too many') || msg.contains('rate limit') || msg.contains('exceeded')) {
        return left(const AuthFailure("Limite d'envoi d'email atteinte. Réessayez dans quelques minutes."));
      }
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await datasource.signOut();
      return right(null);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domainUser.User?>> getCurrentUser() async {
    try {
      final supabaseUser = datasource.getCurrentUser();
      return right(_mapSupabaseUserToDomain(supabaseUser));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<domainUser.User?> watchAuthChanges() {
    return datasource.authStateChanges.map((state) {
      return _mapSupabaseUserToDomain(state.session?.user);
    });
  }

  domainUser.User? _mapSupabaseUserToDomain(supa.User? user) {
    if (user == null) return null;

    final metadata = user.userMetadata ?? {};
    final roleStr = metadata['role'] as String? ?? 'student';

    return domainUser.User(
      id: user.id,
      email: user.email ?? '',
      fullName: metadata['full_name'] as String? ?? 'Utilisateur',
      role: UserRoleX.fromString(roleStr),
      avatarUrl: metadata['avatar_url'] as String?,
      createdAt: user.createdAt != null ? DateTime.tryParse(user.createdAt!) : null,
    );
  }
}
