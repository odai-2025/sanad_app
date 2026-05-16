import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl(this.authService);

  @override
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) {
    return authService.login(
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
  }) {
    return authService.register(
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
  Future<Map<String, dynamic>> getCurrentUser() {
    return authService.getCurrentUser();
  }

  @override
  Future<Map<String, dynamic>> logout() {
    return authService.logout();
  }

  @override
  Future<bool> isLoggedIn() {
    return authService.isLoggedIn();
  }
}