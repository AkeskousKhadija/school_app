import 'package:school_app/core/errors/failures.dart';
import 'package:school_app/features/shared/domain/entities/user.dart' as domainUser;
import 'package:fpdart/fpdart.dart';
import 'package:school_app/features/shared/domain/entities/user_role.dart';

abstract class AuthRepository {
  Future<Either<Failure, domainUser.User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, domainUser.User>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? department,
    String? specialization,
    String? phone,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, domainUser.User?>> getCurrentUser();

  Stream<domainUser.User?> watchAuthChanges();
}
