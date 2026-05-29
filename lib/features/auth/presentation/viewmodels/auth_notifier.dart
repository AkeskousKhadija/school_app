import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_app/features/shared/domain/entities/user.dart';
import 'package:school_app/features/shared/domain/entities/user_role.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository must be overridden in main.dart');
});

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  late final AuthRepository _repository;

  @override
  Future<User?> build() async {
    _repository = ref.read(authRepositoryProvider);
    final result = await _repository.getCurrentUser();
    return result.fold(
      (failure) => null,
      (user) => user,
    );
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? department,
    String? specialization,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      department: department,
      specialization: specialization,
      phone: phone,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }
}
