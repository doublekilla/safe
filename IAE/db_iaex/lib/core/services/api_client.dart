import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// HTTP API client with Sanctum token authentication
class ApiClient {
  final StorageService _storage;
  final String baseUrl;

  ApiClient({
    required StorageService storage,
    this.baseUrl = AppConstants.apiBaseUrl,
  }) : _storage = storage;

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<ApiResponse> get(String endpoint, {bool withAuth = true, Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _headers(withAuth: withAuth));
      return ApiResponse.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse(statusCode: 0, body: {}, error: e.toString());
    }
  }

  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body, bool withAuth = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(withAuth: withAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return ApiResponse.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse(statusCode: 0, body: {}, error: e.toString());
    }
  }

  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return ApiResponse.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse(statusCode: 0, body: {}, error: e.toString());
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(),
      );
      return ApiResponse.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse(statusCode: 0, body: {}, error: e.toString());
    }
  }

  Future<ApiResponse> postMultipart(String endpoint, {required Map<String, String> fields, String? fileField, String? filePath}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      final headers = await _headers();
      headers.remove('Content-Type'); // MultipartRequest sets its own content type with boundary
      request.headers.addAll(headers);
      
      request.fields.addAll(fields);
      
      if (fileField != null && filePath != null) {
        request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return ApiResponse.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse(statusCode: 0, body: {}, error: e.toString());
    }
  }
}

/// Standardized API response wrapper
class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> body;
  final String? error;

  const ApiResponse({required this.statusCode, required this.body, this.error});

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isUnauthorized => statusCode == 401;
  String get message {
    if (body.containsKey('message') && body['message'] != null) {
      return body['message'] as String;
    }
    if (body.containsKey('errors')) {
      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstErrorList = errors[firstKey];
        if (firstErrorList is List && firstErrorList.isNotEmpty) {
          return firstErrorList.first.toString();
        }
      }
    }
    return error ?? 'Unknown error';
  }
  dynamic get data => body['data'];

  factory ApiResponse.fromHttpResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = {'message': response.body};
    }
    return ApiResponse(statusCode: response.statusCode, body: body);
  }
}
