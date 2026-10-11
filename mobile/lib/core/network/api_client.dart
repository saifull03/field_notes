import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  final StorageService storageService;
  final http.Client _client = http.Client();

  ApiClient(this.storageService);

  String get baseUrl => storageService.getBaseUrl();

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = storageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    var url = baseUrl;
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }

    final uriString = '$url$endpoint';
    if (queryParams != null && queryParams.isNotEmpty) {
      final cleanParams = <String, String>{};
      queryParams.forEach((k, v) {
        if (v != null && v.toString().isNotEmpty) {
          cleanParams[k] = v.toString();
        }
      });
      return Uri.parse(uriString).replace(queryParameters: cleanParams);
    }
    return Uri.parse(uriString);
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client.get(uri, headers: _buildHeaders()).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection or backend unreachable.');
    } on http.ClientException {
      throw ApiException('Network connection failed.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection or backend unreachable.');
    } on http.ClientException {
      throw ApiException('Network connection failed.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .put(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection or backend unreachable.');
    } on http.ClientException {
      throw ApiException('Network connection failed.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.delete(uri, headers: _buildHeaders()).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection or backend unreachable.');
    } on http.ClientException {
      throw ApiException('Network connection failed.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<String> uploadPhoto(String filePath) async {
    try {
      final uri = _buildUri(ApiConstants.endpointUploadPhoto);
      final request = http.MultipartRequest('POST', uri);

      final token = storageService.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      final data = _processResponse(response);
      if (data is Map && data.containsKey('photoUrl')) {
        return data['photoUrl'] as String;
      }
      throw ApiException('Invalid upload response from server');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to upload photo: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Request failed with status: ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          errorMessage = body['message'] as String;
        }
      } catch (_) {}
      throw ApiException(errorMessage, response.statusCode);
    }
  }
}

