import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:demo_unit_tests/services/webview_service.dart';

// Mock class สำหรับ WebViewController
class MockWebViewController extends Mock implements WebViewController {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  late WebViewService webViewService;
  late MockWebViewController mockController;

  setUp(() {
    mockController = MockWebViewController();
    webViewService = WebViewService();
  });

  tearDown(() {
    webViewService.dispose();
  });

  group('WebViewService', () {
    test('should load URL when controller exists', () async {
      // Arrange
      const testUrl = 'https://example.com';
      when(() => mockController.loadRequest(any())).thenAnswer((_) async {});
      webViewService.controller = mockController;

      // Act
      await webViewService.loadUrl(testUrl);

      // Assert
      verify(() => mockController.loadRequest(Uri.parse(testUrl))).called(1);
    });

    test('should go back when canGoBack returns true', () async {
      // Arrange
      when(() => mockController.canGoBack()).thenAnswer((_) async => true);
      when(() => mockController.goBack()).thenAnswer((_) async {});
      webViewService.controller = mockController;

      // Act
      await webViewService.goBack();

      // Assert
      verify(() => mockController.goBack()).called(1);
    });

    test('should not go back when canGoBack returns false', () async {
      // Arrange
      when(() => mockController.canGoBack()).thenAnswer((_) async => false);
      webViewService.controller = mockController;

      // Act
      await webViewService.goBack();

      // Assert
      verifyNever(() => mockController.goBack());
    });

    test('should go forward when canGoForward returns true', () async {
      // Arrange
      when(() => mockController.canGoForward()).thenAnswer((_) async => true);
      when(() => mockController.goForward()).thenAnswer((_) async {});
      webViewService.controller = mockController;

      // Act
      await webViewService.goForward();

      // Assert
      verify(() => mockController.goForward()).called(1);
    });

    test('should reload when controller exists', () async {
      // Arrange
      when(() => mockController.reload()).thenAnswer((_) async {});
      webViewService.controller = mockController;

      // Act
      await webViewService.reload();

      // Assert
      verify(() => mockController.reload()).called(1);
    });

    test('should run JavaScript and return result', () async {
      // Arrange
      const script = 'document.title';
      const expectedResult = 'Test Title';
      when(
        () => mockController.runJavaScriptReturningResult(script),
      ).thenAnswer((_) async => expectedResult);
      webViewService.controller = mockController;

      // Act
      final result = await webViewService.runJavaScript(script);

      // Assert
      expect(result, expectedResult);
      verify(
        () => mockController.runJavaScriptReturningResult(script),
      ).called(1);
    });

    test(
      'should return null when running JavaScript without controller',
      () async {
        // Arrange
        const script = 'document.title';

        // Act
        final result = await webViewService.runJavaScript(script);

        // Assert
        expect(result, isNull);
      },
    );

    test('should return false for canGoBack when controller is null', () async {
      // Act
      final result = await webViewService.canGoBack();

      // Assert
      expect(result, isFalse);
    });

    test(
      'should return false for canGoForward when controller is null',
      () async {
        // Act
        final result = await webViewService.canGoForward();

        // Assert
        expect(result, isFalse);
      },
    );

    test('should dispose controller correctly', () {
      // Arrange
      webViewService.controller = mockController;

      // Act
      webViewService.dispose();

      // Assert
      expect(webViewService.controller, isNull);
    });

    test('should not throw when loading URL without controller', () async {
      // Act & Assert - ไม่มี controller แต่ไม่ควร throw
      await webViewService.loadUrl('https://example.com');
    });

    test('should not throw when reloading without controller', () async {
      await webViewService.reload();
    });

    test('should not go forward when canGoForward returns false', () async {
      // Arrange
      when(() => mockController.canGoForward()).thenAnswer((_) async => false);
      webViewService.controller = mockController;

      // Act
      await webViewService.goForward();

      // Assert
      verifyNever(() => mockController.goForward());
    });
  });
}
