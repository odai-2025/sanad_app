abstract class AuthRepository {
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
  });

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  });

  Future<Map<String, dynamic>> getCurrentUser();

  Future<Map<String, dynamic>> logout();

  Future<bool> isLoggedIn();
}