import 'dart:convert' show json;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:demo_unit_tests/services/api_service.dart';

// สร้าง Mock classes ด้วย annotation
@GenerateMocks([HttpClient])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Mock Tests', () {
    late ApiService apiService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      apiService = ApiService(mockHttpClient);
    });

    group('Basic Mock Tests', () {
      test('should return user data when API call is successful', () async {
        // Arrange
        const userId = 1;
        final mockResponse = http.Response(
          '{"id": 1, "name": "John Doe"}',
          200,
        );
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.fetchUser(userId);

        // Assert
        expect(result['id'], equals(1));
        expect(result['name'], equals('John Doe'));
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should throw exception when API returns 404', () async {
        // Arrange
        const userId = 1;
        final mockResponse = http.Response('Not Found', 404);
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert — ตรวจสอบข้อความ error เฉพาะเจาะจง (Flutter docs: test for each condition)
        expect(
          () => apiService.fetchUser(userId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('User not found'),
            ),
          ),
        );
      });

      test(
        'should throw exception when API returns server error (5xx)',
        () async {
          // Arrange
          const userId = 1;
          final mockResponse = http.Response('Internal Server Error', 500);
          when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

          // Act & Assert — ทดสอบ else branch ที่ status code ไม่ใช่ 200 หรือ 404
          expect(
            () => apiService.fetchUser(userId),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Failed to fetch user: 500'),
              ),
            ),
          );
        },
      );

      test('should handle network errors', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(Exception('Network error'));

        // Act & Assert — จำลองกรณีไม่มี internet/network ล้มเหลว
        expect(
          () => apiService.fetchUser(1),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Network error'),
            ),
          ),
        );
      });
    });

    group('Verification Tests', () {
      test('should verify call count', () async {
        // Arrange
        final mockResponse = http.Response('{"id": 1}', 200);
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await apiService.fetchUser(1);
        await apiService.fetchUser(2);

        // Assert
        verify(mockHttpClient.get(any)).called(2);
      });

      test('should verify specific URL calls', () async {
        // Arrange
        final mockResponse = http.Response('{"id": 1}', 200);
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await apiService.fetchUser(1);

        // Assert
        verify(
          mockHttpClient.get(
            Uri.parse('https://jsonplaceholder.typicode.com/users/1'),
          ),
        ).called(1);
      });
    });

    group('Advanced Mock Patterns', () {
      test('should handle different responses for different users', () async {
        // Arrange
        when(
          mockHttpClient.get(
            Uri.parse('https://jsonplaceholder.typicode.com/users/1'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{"id": 1, "name": "John"}', 200),
        );

        when(
          mockHttpClient.get(
            Uri.parse('https://jsonplaceholder.typicode.com/users/2'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{"id": 2, "name": "Jane"}', 200),
        );

        // Act
        final user1 = await apiService.fetchUser(1);
        final user2 = await apiService.fetchUser(2);

        // Assert
        expect(user1['name'], equals('John'));
        expect(user2['name'], equals('Jane'));
      });

      test('should capture and verify arguments', () async {
        // Arrange
        final mockResponse = http.Response('{"id": 1}', 200);
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await apiService.fetchUser(123);

        // Assert & Capture
        final captured = verify(mockHttpClient.get(captureAny)).captured;
        expect(captured.first.toString(), contains('users/123'));
      });

      test('should verify no more interactions', () async {
        // Arrange
        final mockResponse = http.Response('{"id": 1}', 200);
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await apiService.fetchUser(1);

        // Assert
        verify(mockHttpClient.get(any)).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      });
    });

    group('createPost Tests', () {
      test('should create post successfully', () async {
        // Arrange
        final mockResponse = http.Response(
          '{"id": 101, "userId": 1, "title": "Test Title", "body": "Test Body"}',
          201,
        );
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.createPost(
          userId: 1,
          title: 'Test Title',
          body: 'Test Body',
        );

        // Assert
        expect(result['id'], equals(101));
        expect(result['title'], equals('Test Title'));
        expect(result['body'], equals('Test Body'));
        verify(
          mockHttpClient.post(
            Uri.parse('https://jsonplaceholder.typicode.com/posts'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('should throw exception when createPost fails', () async {
        // Arrange
        final mockResponse = http.Response('Server Error', 500);
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => apiService.createPost(userId: 1, title: 'T', body: 'B'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'toString',
              contains('Failed to create post: 500'),
            ),
          ),
        );
      });

      test('should send correct content-type header', () async {
        // Arrange
        final mockResponse = http.Response('{"id": 101}', 201);
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await apiService.createPost(userId: 1, title: 'T', body: 'B');

        // Assert
        final captured = verify(
          mockHttpClient.post(
            any,
            headers: captureAnyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).captured;
        expect(
          captured.first,
          containsPair('Content-Type', 'application/json'),
        );
      });

      test('should send correct request body', () async {
        // Arrange — ตรวจสอบว่า body ที่ส่งไป API ถูกต้อง (Flutter docs: verify arguments)
        final mockResponse = http.Response('{"id": 101}', 201);
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await apiService.createPost(
          userId: 5,
          title: 'My Title',
          body: 'My Body',
        );

        // Assert — capture body และตรวจสอบเนื้อหา
        final captured = verify(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: captureAnyNamed('body'),
          ),
        ).captured;
        final sentBody = json.decode(captured.first as String);
        expect(sentBody['userId'], equals(5));
        expect(sentBody['title'], equals('My Title'));
        expect(sentBody['body'], equals('My Body'));
      });
    });

    group('fetchUserPosts Tests', () {
      test('should return list of posts for valid userId', () async {
        // Arrange
        final mockResponse = http.Response(
          '[{"id": 1, "title": "Post 1"}, {"id": 2, "title": "Post 2"}]',
          200,
        );
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.fetchUserPosts(1);

        // Assert
        expect(result.length, equals(2));
        expect(result[0]['title'], equals('Post 1'));
        expect(result[1]['title'], equals('Post 2'));
        verify(
          mockHttpClient.get(
            Uri.parse('https://jsonplaceholder.typicode.com/users/1/posts'),
          ),
        ).called(1);
      });

      test('should return empty list when user has no posts', () async {
        // Arrange
        final mockResponse = http.Response('[]', 200);
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await apiService.fetchUserPosts(999);

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when fetchUserPosts fails', () async {
        // Arrange
        final mockResponse = http.Response('Server Error', 500);
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => apiService.fetchUserPosts(1),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'toString',
              contains('Failed to fetch user posts: 500'),
            ),
          ),
        );
      });
    });
  });
}
