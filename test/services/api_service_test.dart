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

      test('should throw exception when API returns error', () async {
        // Arrange
        const userId = 1;
        final mockResponse = http.Response('Not Found', 404);
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(() => apiService.fetchUser(userId), throwsException);
      });

      test('should handle network errors', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => apiService.fetchUser(1), throwsException);
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
  });
}
