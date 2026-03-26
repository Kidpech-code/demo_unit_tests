import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Service สำหรับจัดการ WebView Controller
///
/// ## ใช้ทำอะไร?
/// ห่อ [WebViewController] ด้วย Service class → ทำให้ทดสอบได้ง่ายขึ้น
///
/// ## แนวคิดที่สอน: Mocktail (ไม่ต้อง Code Generation)
/// ไฟล์นี้ใช้ **Mocktail** แทน Mockito เพราะ:
/// - `WebViewController` เป็น class จาก package ภายนอก → สร้าง mock ยาก
/// - Mocktail ไม่ต้อง `@GenerateMocks` + `build_runner`
///
/// ### เปรียบเทียบ Mockito vs Mocktail
/// | Feature | Mockito | Mocktail |
/// |---------|---------|----------|
/// | Code Gen | ต้อง `@GenerateMocks` + `build_runner` | ไม่ต้อง |
/// | Syntax | `when(mock.fn()).thenAnswer(...)` | `when(() => mock.fn()).thenReturn(...)` |
/// | Any | `any` (ต้อง import) | `any()` (function call) |
/// | Verify | `verify(mock.fn())` | `verify(() => mock.fn())` |
///
/// ### ตัวอย่าง Test ด้วย Mocktail
/// ```dart
/// class MockWebViewController extends Mock implements WebViewController {}
///
/// test('loadUrl calls loadRequest', () async {
///   final mock = MockWebViewController();
///   when(() => mock.loadRequest(any())).thenAnswer((_) async {});
///
///   service.controller = mock;
///   await service.loadUrl('https://flutter.dev');
///
///   verify(() => mock.loadRequest(any())).called(1);
/// });
/// ```
///
/// ## ต่อยอดได้อย่างไร?
/// - เพิ่ม `evaluateJavascript()`, `getTitle()`, `getProgress()`
/// - เพิ่ม history management
/// - ใช้ Riverpod/Provider ทำ DI แทน direct assignment
class WebViewService {
  /// WebView Controller — null ถ้ายังไม่ได้ initialize
  ///
  /// ทุกฟังก์ชันตรวจ `controller != null` ก่อนทำงาน
  /// ถ้า null → ไม่ทำอะไร (fail silently)
  WebViewController? controller;

  /// เริ่มต้น WebView Controller พร้อมตั้งค่า
  ///
  /// ## ตั้งค่า
  /// - JavaScript: unrestricted
  /// - Background: transparent
  /// - YouTube: ป้องกัน (NavigationDecision.prevent)
  /// - Default URL: https://flutter.dev
  Future<void> initializeController() async {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  /// โหลด URL ใหม่ — ไม่ทำอะไรถ้า controller เป็น null
  Future<void> loadUrl(String url) async {
    if (controller != null) {
      await controller!.loadRequest(Uri.parse(url));
    }
  }

  /// กลับไปหน้าก่อนหน้า — ตรวจ canGoBack() ก่อน
  Future<void> goBack() async {
    if (controller != null && await controller!.canGoBack()) {
      await controller!.goBack();
    }
  }

  /// ไปหน้าถัดไป — ตรวจ canGoForward() ก่อน
  Future<void> goForward() async {
    if (controller != null && await controller!.canGoForward()) {
      await controller!.goForward();
    }
  }

  /// รีโหลดหน้าเว็บ
  Future<void> reload() async {
    if (controller != null) {
      await controller!.reload();
    }
  }

  /// เรียกใช้ JavaScript ใน WebView — return ผลลัพธ์
  ///
  /// ใช้ `runJavaScriptReturningResult` ที่ return ค่ากลับมาได้
  Future<Object?> runJavaScript(String script) async {
    if (controller != null) {
      return await controller!.runJavaScriptReturningResult(script);
    }
    return null;
  }

  /// ตรวจสอบว่าสามารถกลับไปได้หรือไม่
  Future<bool> canGoBack() async {
    if (controller != null) {
      return await controller!.canGoBack();
    }
    return false;
  }

  /// ตรวจสอบว่าสามารถไปต่อได้หรือไม่
  Future<bool> canGoForward() async {
    if (controller != null) {
      return await controller!.canGoForward();
    }
    return false;
  }

  /// ล้างข้อมูล — ตั้ง controller เป็น null
  void dispose() {
    controller = null;
  }
}
