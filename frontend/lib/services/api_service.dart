import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });
}

class ApiService {
  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await StorageService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<ApiResponse> get(String url, {bool requireAuth = false, Map<String, String>? queryParams}) async {
    try {
      Uri uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 12));

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Network error or backend unreachable: $e',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResponse> post(String url, {dynamic body, bool requireAuth = false}) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 12));

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Network error or backend unreachable: $e',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResponse> patch(String url, {dynamic body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 12));

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Network error or backend unreachable: $e',
        statusCode: 0,
      );
    }
  }

  static ApiResponse _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      decoded = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        success: true,
        data: decoded,
        statusCode: response.statusCode,
      );
    } else {
      String errorMessage = 'Request failed (${response.statusCode})';
      if (decoded is Map) {
        if (decoded.containsKey('detail')) {
          errorMessage = decoded['detail'].toString();
        } else if (decoded.containsKey('message')) {
          errorMessage = decoded['message'].toString();
        } else {
          errorMessage = decoded.values.first.toString();
        }
      }
      return ApiResponse(
        success: false,
        error: errorMessage,
        data: decoded,
        statusCode: response.statusCode,
      );
    }
  }
}
