import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _user?.isGuest ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    _user = await AuthService.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AuthService.login(email, password);
    _isLoading = false;

    if (response.success && response.data != null) {
      _user = UserModel.fromJson(response.data['user']);
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error ?? 'Invalid email or password.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AuthService.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    _isLoading = false;

    if (response.success && response.data != null) {
      _user = UserModel.fromJson(response.data['user']);
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error ?? 'Registration failed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> enterGuestDemo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AuthService.guestLogin();
    _isLoading = false;

    if (response.success && response.data != null) {
      _user = UserModel.fromJson(response.data['user']);
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error ?? 'Failed to initialize guest demo session.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
