import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider(this.authRepository);

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await authRepository.login(
        phone: phone,
        password: password,
      );

      _isLoggedIn = true;

      if (result['user'] != null && result['user'] is Map<String, dynamic>) {
        _user = UserModel.fromJson(result['user']);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
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
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await authRepository.register(
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

      _isLoggedIn = true;

      if (result['user'] != null && result['user'] is Map<String, dynamic>) {
        _user = UserModel.fromJson(result['user']);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCurrentUser() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await authRepository.getCurrentUser();

      if (result['user'] != null && result['user'] is Map<String, dynamic>) {
        _user = UserModel.fromJson(result['user']);
      } else if (result['data'] != null &&
          result['data'] is Map<String, dynamic>) {
        _user = UserModel.fromJson(result['data']);
      } else if (result is Map<String, dynamic>) {
        _user = UserModel.fromJson(result);
      }

      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await authRepository.logout();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _user = null;
      _isLoggedIn = false;
      _setLoading(false);
      notifyListeners();
    }
  }

  void clearSessionLocally() {
    _user = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}