import 'dart:convert';
import 'package:http/http.dart' as http;

/// Interface สำหรับ HTTP Client เพื่อใช้ในการ mock
abstract class HttpClient {
  Future<http.Response> get(Uri uri);
  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  });
}

/// Implementation จริงของ HTTP Client
class RealHttpClient implements HttpClient {
  final http.Client _client = http.Client();

  @override
  Future<http.Response> get(Uri uri) {
    return _client.get(uri);
  }

  @override
  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client.post(uri, headers: headers, body: body);
  }

  void dispose() {
    _client.close();
  }
}

/// Service สำหรับจัดการข้อมูล API
class ApiService {
  final HttpClient _httpClient;

  ApiService(this._httpClient);

  /// ดึงข้อมูลผู้ใช้จาก API
  Future<Map<String, dynamic>> fetchUser(int userId) async {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/users/$userId');

    final response = await _httpClient.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  }

  /// สร้างโพสต์ใหม่
  Future<Map<String, dynamic>> createPost({
    required int userId,
    required String title,
    required String body,
  }) async {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');

    final requestBody = json.encode({
      'userId': userId,
      'title': title,
      'body': body,
    });

    final response = await _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }

  /// ดึงข้อมูลโพสต์ทั้งหมดของผู้ใช้
  Future<List<Map<String, dynamic>>> fetchUserPosts(int userId) async {
    final uri = Uri.parse(
      'https://jsonplaceholder.typicode.com/users/$userId/posts',
    );

    final response = await _httpClient.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch user posts: ${response.statusCode}');
    }
  }
}
