import 'package:sanad_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sanad_app/features/auth/data/services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl(this.authService);

  @override
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    return await authService.login(
      phone: phone,
      password: password,
    );
  }

  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String secondName,
    required String thirdName,
    required String lastName,
    required String gender,
    required String countryCode,
    required String phone,
    String? email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await authService.register(
      firstName: firstName,
      secondName: secondName,
      thirdName: thirdName,
      lastName: lastName,
      gender: gender,
      countryCode: countryCode,
      phone: phone,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await authService.getCurrentUser();
  }

  @override
  Future<Map<String, dynamic>> logout() async {
    return await authService.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await authService.isLoggedIn();
  }
}