import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Service สำหรับจัดการ WebView Controller
class WebViewService {
  WebViewController? controller;

  /// เริ่มต้น WebView Controller
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

  /// โหลด URL ใหม่
  Future<void> loadUrl(String url) async {
    if (controller != null) {
      await controller!.loadRequest(Uri.parse(url));
    }
  }

  /// กลับไปหน้าก่อนหน้า
  Future<void> goBack() async {
    if (controller != null && await controller!.canGoBack()) {
      await controller!.goBack();
    }
  }

  /// ไปหน้าถัดไป
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

  /// เรียกใช้ JavaScript
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

  /// ล้างข้อมูล
  void dispose() {
    controller = null;
  }
}
