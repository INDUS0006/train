import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static Future<ApiResponse> login(String email, String password) async {
    final response = await ApiService.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    if (response.success && response.data != null) {
      final tokens = response.data['tokens'];
      final userJson = response.data['user'];
      if (tokens != null) {
        await StorageService.saveTokens(
          access: tokens['access'],
          refresh: tokens['refresh'],
        );
      }
      if (userJson != null) {
        await StorageService.saveUserData(jsonEncode(userJson));
      }
    }
    return response;
  }

  static Future<ApiResponse> register({
    required String username,
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
  }) async {
    final response = await ApiService.post(
      ApiConstants.register,
      body: {
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      },
    );

    if (response.success && response.data != null) {
      final tokens = response.data['tokens'];
      final userJson = response.data['user'];
      if (tokens != null) {
        await StorageService.saveTokens(
          access: tokens['access'],
          refresh: tokens['refresh'],
        );
      }
      if (userJson != null) {
        await StorageService.saveUserData(jsonEncode(userJson));
      }
    }
    return response;
  }

  static Future<ApiResponse> guestLogin() async {
    final response = await ApiService.post(
      ApiConstants.guestLogin,
      body: {},
    );

    if (response.success && response.data != null) {
      final tokens = response.data['tokens'];
      final userJson = response.data['user'];
      if (tokens != null) {
        await StorageService.saveTokens(
          access: tokens['access'],
          refresh: tokens['refresh'],
        );
      }
      if (userJson != null) {
        await StorageService.saveUserData(jsonEncode(userJson));
      }
    }
    return response;
  }

  static Future<UserModel?> getCurrentUser() async {
    final userJson = await StorageService.getUserData();
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (_) {}
    }
    return null;
  }

  static Future<void> logout() async {
    await StorageService.clearAuth();
  }
}
