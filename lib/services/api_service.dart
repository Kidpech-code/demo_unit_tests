import 'dart:convert';
import 'package:http/http.dart' as http;

/// Interface สำหรับ HTTP Client — **หัวใจของ Dependency Injection (DI)**
///
/// ## ใช้ทำอะไร?
/// สร้าง abstract class เป็น "สัญญา" (contract) ว่า HTTP Client ต้องมีอะไรบ้าง
/// ทำให้ [ApiService] ไม่ขึ้นกับ implementation ตรงๆ
///
/// ## แนวคิดที่สอน: Dependency Injection (DI)
/// ```
/// [ApiService] ← รับ [HttpClient] ผ่าน constructor
///                     ↑
///          ┌──────────┴──────────┐
///    [RealHttpClient]      [MockHttpClient]
///    (ใช้จริง)             (ใช้ใน test)
/// ```
///
/// ### ทำไมต้องทำ DI?
/// - **ทดสอบได้** — inject mock แทนของจริง ไม่ต้องเรียก API จริง
/// - **เร็ว** — ไม่ต้องรอ network response
/// - **เสถียร** — ไม่ขึ้นกับ server ว่าจะ online หรือเปล่า
///
/// ### ใช้ Mockito สร้าง Mock
/// ```dart
/// @GenerateMocks([HttpClient])
/// // จะได้ MockHttpClient ที่ใช้ when().thenAnswer() ได้
/// ```
///
/// ## ต่อยอดได้อย่างไร?
/// - เพิ่ม `put()`, `delete()`, `patch()` methods
/// - เพิ่ม interceptors สำหรับ auth token, logging
/// - ใช้ package `dio` แทน `http` สำหรับ feature เพิ่ม
abstract class HttpClient {
  Future<http.Response> get(Uri uri);
  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  });
}

/// Implementation จริงของ HTTP Client — ใช้ package `http`
///
/// ใช้ใน production code เท่านั้น
/// ใน test จะใช้ MockHttpClient แทน (สร้างจาก Mockito)
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

  /// ปิด connection — ควรเรียกเมื่อไม่ใช้แล้ว
  void dispose() {
    _client.close();
  }
}

/// Service สำหรับเรียก REST API ด้วย Dependency Injection
///
/// ## ใช้ทำอะไร?
/// จัดการการเรียก HTTP API ทั้งหมดไว้ในที่เดียว
/// รับ [HttpClient] ผ่าน constructor → สามารถ mock ได้ใน test
///
/// ## แนวคิดที่สอน
/// - **Dependency Injection** — inject HttpClient ผ่าน constructor
/// - **HTTP Status Code Handling** — จัดการ 200, 201, 404, อื่นๆ
/// - **JSON Serialization** — ใช้ `json.encode/decode`
/// - **Async Testing** — ทุกฟังก์ชันเป็น `Future` ต้องใช้ `async/await` ใน test
///
/// ## ใช้อย่างไร?
/// ```dart
/// // Production
/// final api = ApiService(RealHttpClient());
///
/// // Test — ใช้ Mock
/// final mockClient = MockHttpClient();
/// when(mockClient.get(any)).thenAnswer((_) async => http.Response('{"id":1}', 200));
/// final api = ApiService(mockClient);
/// ```
class ApiService {
  final HttpClient _httpClient;

  ApiService(this._httpClient);

  /// ดึงข้อมูลผู้ใช้จาก API
  ///
  /// ## Status Code Handling
  /// - 200 → return Map จาก JSON body
  /// - 404 → throw Exception('User not found')
  /// - อื่นๆ → throw Exception('Failed to fetch user: {statusCode}')
  ///
  /// ## ทดสอบ (Mock Pattern)
  /// ```dart
  /// when(mockClient.get(any)).thenAnswer(
  ///   (_) async => http.Response('{"id":1,"name":"Test"}', 200),
  /// );
  /// final result = await apiService.fetchUser(1);
  /// expect(result['name'], equals('Test'));
  /// ```
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

  /// สร้างโพสต์ใหม่ (HTTP POST)
  ///
  /// ## แนวคิด Testing: Verify Arguments
  /// ใช้ `verify()` ตรวจว่า mock ถูกเรียกด้วย arguments ที่ถูกต้อง:
  /// ```dart
  /// verify(mockClient.post(
  ///   any,
  ///   headers: {'Content-Type': 'application/json'},
  ///   body: anyNamed('body'),
  /// )).called(1);
  /// ```
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

  /// ดึงโพสต์ทั้งหมดของผู้ใช้ — return `List<Map>`
  ///
  /// ทดสอบ: mock ให้ return JSON Array แล้วตรวจจำนวนและเนื้อหา
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
