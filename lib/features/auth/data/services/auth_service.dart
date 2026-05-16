import 'package:dio/dio.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final TokenStorage _tokenStorage = TokenStorage();

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
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {
          'first_name': firstName,
          'second_name': secondName,
          'third_name': thirdName,
          'last_name': lastName,
          'gender': gender,
          'country_code': countryCode,
          'phone': phone,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['access_token'] != null) {
        await _tokenStorage.saveToken(data['access_token'].toString());
      }

      return data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'phone': phone,
          'password': password,
        },
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['access_token'] != null) {
        await _tokenStorage.saveToken(data['access_token'].toString());
      }

      return data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConfig.me);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post(ApiConfig.logout);
      await _tokenStorage.deleteToken();
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<bool> isLoggedIn() async {
    return await _tokenStorage.hasToken();
  }

  Future<String?> getToken() async {
    return await _tokenStorage.getToken();
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          return data['message'].toString();
        }

        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }

      return 'Request failed with status: ${e.response?.statusCode}';
    }

    return e.message ?? 'Unknown error occurred';
  }
}