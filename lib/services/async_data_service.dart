import 'dart:async';
import 'dart:math';

/// คลาสสำหรับจำลองการทำงาน Async
class AsyncDataService {
  final Random _random = Random();

  /// จำลองการดึงข้อมูลจาก API (สำเร็จ)
  Future<Map<String, dynamic>> fetchUserData(int userId) async {
    await Future.delayed(Duration(milliseconds: 100)); // จำลองความล่าช้า

    if (userId <= 0) {
      throw ArgumentError('User ID must be positive');
    }

    return {
      'id': userId,
      'name': 'User $userId',
      'email': 'user$userId@example.com',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// จำลองการดึงข้อมูลที่อาจล้มเหลว
  Future<String> fetchDataWithRandomFailure() async {
    await Future.delayed(Duration(milliseconds: 50));

    if (_random.nextBool()) {
      throw Exception('Random network error occurred');
    }

    return 'Success: Data fetched successfully';
  }

  /// จำลองการอัปโหลดไฟล์
  Future<bool> uploadFile(String filename, List<int> data) async {
    await Future.delayed(Duration(milliseconds: 200));

    if (filename.isEmpty) {
      throw ArgumentError('Filename cannot be empty');
    }

    if (data.isEmpty) {
      throw ArgumentError('File data cannot be empty');
    }

    // จำลองการล้มเหลวสำหรับไฟล์ขนาดใหญ่
    if (data.length > 1000000) {
      throw Exception('File too large');
    }

    return true;
  }

  /// จำลองการดาวน์โหลดข้อมูลแบบ Stream
  Stream<int> downloadProgress() async* {
    for (int progress = 0; progress <= 100; progress += 10) {
      await Future.delayed(Duration(milliseconds: 10));
      yield progress;
    }
  }

  /// จำลองการดึงข้อมูลหลายรายการพร้อมกัน
  Future<List<String>> fetchMultipleData(List<int> ids) async {
    if (ids.isEmpty) {
      return [];
    }

    List<Future<String>> futures = ids.map((id) async {
      await Future.delayed(Duration(milliseconds: 50));
      return 'Data for ID: $id';
    }).toList();

    return await Future.wait(futures);
  }

  /// จำลองการทำงานที่มี timeout
  Future<String> fetchDataWithTimeout(Duration timeout) async {
    return await Future.delayed(
      Duration(milliseconds: 100),
      () => 'Data fetched within timeout',
    ).timeout(
      timeout,
      onTimeout: () => throw TimeoutException('Request timed out', timeout),
    );
  }

  /// จำลองการ retry เมื่อเกิดข้อผิดพลาด
  Future<String> fetchDataWithRetry(int maxRetries) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        await Future.delayed(Duration(milliseconds: 50));

        // จำลองความล้มเหลวใน 2 ครั้งแรก
        if (attempt < 2) {
          throw Exception('Temporary failure on attempt ${attempt + 1}');
        }

        return 'Success after ${attempt + 1} attempts';
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // หน่วงเวลาก่อน retry
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// จำลองการทำงานแบบ batch processing
  Future<List<T>> processBatch<T>(
    List<T> items,
    Future<T> Function(T) processor, {
    int batchSize = 5,
  }) async {
    if (items.isEmpty) return [];

    List<T> results = [];

    for (int i = 0; i < items.length; i += batchSize) {
      int end = (i + batchSize < items.length) ? i + batchSize : items.length;
      List<T> batch = items.sublist(i, end);

      List<Future<T>> batchFutures = batch.map(processor).toList();
      List<T> batchResults = await Future.wait(batchFutures);
      results.addAll(batchResults);

      // หน่วงเวลาระหว่าง batch
      if (end < items.length) {
        await Future.delayed(Duration(milliseconds: 10));
      }
    }

    return results;
  }
}
