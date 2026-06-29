import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  String? _accessToken;

  Future<void> setAccessToken(String? token) async {
    _accessToken = token;
  }

  Future<void> loadToken() async {
    _accessToken = await TokenStorage.getAccessToken();
  }

  Map<String, String> _headers({bool auth = true, bool json = true}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) headers['Content-Type'] = 'application/json';
    if (auth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalized').replace(queryParameters: query);
  }

  dynamic _decode(http.Response response) {
    dynamic body;
    if (response.body.isNotEmpty) {
      body = jsonDecode(response.body);
    }
    if (response.statusCode >= 400) {
      String message = 'Request failed (${response.statusCode})';
      if (body is Map) {
        final detail = body['detail'];
        if (detail is String) {
          message = detail;
        } else if (detail is List && detail.isNotEmpty) {
          message = detail.first.toString();
        }
      }
      throw ApiException(response.statusCode, message);
    }
    return body;
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
    Duration? timeout,
  }) async {
    final response = await http
        .get(
          _uri(path, query),
          headers: _headers(auth: auth),
        )
        .timeout(timeout ?? const Duration(seconds: 20));
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    Duration? timeout,
  }) async {
    final uri = _uri(path);
    if (kDebugMode) {
      debugPrint('[API] POST $uri body=$body');
    }
    try {
      final response = await http
          .post(
            uri,
            headers: _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout ?? const Duration(seconds: 15));
      if (kDebugMode) {
        debugPrint('[API] ${response.statusCode} ${response.body}');
      }
      return _decode(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[API] ERROR POST $uri -> $e');
      }
      rethrow;
    }
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await http.patch(
      _uri(path),
      headers: _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final response = await http.delete(
      _uri(path),
      headers: _headers(auth: auth),
    );
    return _decode(response);
  }

  Future<dynamic> multipart(
    String path, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(_headers(auth: auth, json: false));
    request.fields.addAll(fields);
    request.files.addAll(files);
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }
}
