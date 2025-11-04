import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static Future<String?> _getToken() async {
    return await StorageService.getToken();
  }

  static Future<Map<String, String>> _getHeaders({
    Map<String, String>? extra,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?extra,
    };

    final token = await _getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    try {
      String fullUrl = url;
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        fullUrl = uri.toString();
      }

      final response = await http
          .get(Uri.parse(fullUrl), headers: await _getHeaders())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - server took too long to respond',
              );
            },
          );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error': error['error'] ?? 'Request failed',
          };
        } catch (_) {
          return {
            'success': false,
            'error': 'Request failed with status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      // Better error messages for common issues
      String errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') ||
          errorMsg.contains('lookup')) {
        errorMsg =
            'Network error: Unable to reach server. Please check your internet connection.';
      } else if (errorMsg.contains('timeout')) {
        errorMsg =
            'Request timeout: Server took too long to respond. Please try again.';
      } else if (errorMsg.contains('SocketException')) {
        errorMsg =
            'Network error: Unable to connect to server. Please check your internet connection.';
      }
      return {'success': false, 'error': errorMsg};
    }
  }

  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - server took too long to respond',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error': error['error'] ?? 'Request failed',
          };
        } catch (_) {
          return {
            'success': false,
            'error': 'Request failed with status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      // Better error messages for common issues
      String errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') ||
          errorMsg.contains('lookup')) {
        errorMsg =
            'Network error: Unable to reach server. Please check your internet connection.';
      } else if (errorMsg.contains('timeout')) {
        errorMsg =
            'Request timeout: Server took too long to respond. Please try again.';
      } else if (errorMsg.contains('SocketException')) {
        errorMsg =
            'Network error: Unable to connect to server. Please check your internet connection.';
      }
      return {'success': false, 'error': errorMsg};
    }
  }

  static Future<Map<String, dynamic>> patch(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse(url),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - server took too long to respond',
              );
            },
          );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error': error['error'] ?? 'Request failed',
          };
        } catch (_) {
          return {
            'success': false,
            'error': 'Request failed with status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      // Better error messages for common issues
      String errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') ||
          errorMsg.contains('lookup')) {
        errorMsg =
            'Network error: Unable to reach server. Please check your internet connection.';
      } else if (errorMsg.contains('timeout')) {
        errorMsg =
            'Request timeout: Server took too long to respond. Please try again.';
      } else if (errorMsg.contains('SocketException')) {
        errorMsg =
            'Network error: Unable to connect to server. Please check your internet connection.';
      }
      return {'success': false, 'error': errorMsg};
    }
  }

  static Future<Map<String, dynamic>> delete(String url) async {
    try {
      final response = await http
          .delete(Uri.parse(url), headers: await _getHeaders())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - server took too long to respond',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error': error['error'] ?? 'Request failed',
          };
        } catch (_) {
          return {
            'success': false,
            'error': 'Request failed with status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      // Better error messages for common issues
      String errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') ||
          errorMsg.contains('lookup')) {
        errorMsg =
            'Network error: Unable to reach server. Please check your internet connection.';
      } else if (errorMsg.contains('timeout')) {
        errorMsg =
            'Request timeout: Server took too long to respond. Please try again.';
      } else if (errorMsg.contains('SocketException')) {
        errorMsg =
            'Network error: Unable to connect to server. Please check your internet connection.';
      }
      return {'success': false, 'error': errorMsg};
    }
  }
}
