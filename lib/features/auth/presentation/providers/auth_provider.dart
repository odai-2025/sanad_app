import 'package:flutter/material.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final TokenStorage _tokenStorage = TokenStorage();

  AuthProvider({
    required this.authRepository,
  });

  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;
  String? _errorMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  Future<void> checkLoginStatus() async {
    _isCheckingAuth = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasToken = await _tokenStorage.hasToken();

      if (!hasToken) {
        _user = null;
        _isLoggedIn = false;
        return;
      }

      final result = await authRepository.getCurrentUser();
      _user = _extractUserFromResponse(result);
      _isLoggedIn = _user != null;

      if (!_isLoggedIn) {
        await _tokenStorage.deleteToken();
      }
    } catch (e) {
      _errorMessage = _cleanError(e);
      _user = null;
      _isLoggedIn = false;
      await _tokenStorage.deleteToken();
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
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

      _user = _extractUserFromResponse(result);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _user = null;
      _isLoggedIn = false;
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

      _user = _extractUserFromResponse(result);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _user = null;
      _isLoggedIn = false;
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
      _user = _extractUserFromResponse(result);
      _isLoggedIn = _user != null;

      if (!_isLoggedIn) {
        _errorMessage = 'Unable to load current user';
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = _cleanError(e);
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
      _errorMessage = _cleanError(e);
    } finally {
      _user = null;
      _isLoggedIn = false;
      _isCheckingAuth = false;
      await _tokenStorage.deleteToken();
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> clearSessionLocally() async {
    _user = null;
    _isLoggedIn = false;
    _errorMessage = null;
    _isCheckingAuth = false;
    await _tokenStorage.deleteToken();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  UserModel? _extractUserFromResponse(Map<String, dynamic> result) {
    try {
      if (result['user'] is Map<String, dynamic>) {
        return UserModel.fromJson(
          Map<String, dynamic>.from(result['user']),
        );
      }

      if (result['data'] is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(result['data']);

        if (data['user'] is Map<String, dynamic>) {
          return UserModel.fromJson(
            Map<String, dynamic>.from(data['user']),
          );
        }

        if (data.containsKey('id')) {
          return UserModel.fromJson(data);
        }
      }

      if (result.containsKey('id')) {
        return UserModel.fromJson(result);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  String _cleanError(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}