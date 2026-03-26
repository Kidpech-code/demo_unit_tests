import 'dart:async';
import 'dart:math';

/// Service สำหรับสาธิตการทำงานแบบ Asynchronous (Async Patterns)
///
/// ## ใช้ทำอะไร?
/// สอนรูปแบบ async ต่างๆ ที่พบบ่อยในแอป Flutter:
/// - **Future** — ทำงานแล้วรอผลลัพธ์
/// - **Stream** — ส่งข้อมูลหลายครั้งแบบต่อเนื่อง
/// - **Retry Pattern** — ลองใหม่เมื่อล้มเหลว
/// - **Batch Processing** — ประมวลผลเป็นชุด
/// - **Timeout** — กำหนดเวลาสูงสุดที่รอได้
///
/// ## แนวคิด Testing ที่สอน
/// - **async test** — ใช้ `async/await` ใน test body
///   ```dart
///   test('fetch data', () async {
///     final result = await service.fetchUserData(1);
///     expect(result['id'], equals(1));
///   });
///   ```
/// - **Stream testing** — ใช้ `emitsInOrder()`, `emits()`, `emitsDone`
///   ```dart
///   expect(service.downloadProgress(), emitsInOrder([0, 10, 20, ...]));
///   ```
/// - **Exception testing** — ใช้ `throwsA()` กับ async functions
///   ```dart
///   expect(() => service.fetchUserData(-1), throwsA(isA<ArgumentError>()));
///   ```
/// - **Timeout testing** — ทดสอบกรณีหมดเวลา
///
/// ## ต่อยอดได้อย่างไร?
/// - เพิ่ม CancelToken สำหรับยกเลิก request
/// - เพิ่ม exponential backoff ใน retry logic
/// - ใช้ `StreamController` สำหรับ real-time data
class AsyncDataService {
  final Random _random = Random();

  /// จำลองการดึงข้อมูลผู้ใช้จาก API (ใช้ delay จำลอง network)
  ///
  /// ## ข้อจำกัด
  /// - userId ต้อง > 0 ไม่งั้น throw [ArgumentError]
  /// - มี delay 100ms จำลอง network latency
  ///
  /// ## ทดสอบ
  /// ```dart
  /// test('fetch success', () async {
  ///   final result = await service.fetchUserData(1);
  ///   expect(result['id'], equals(1));
  ///   expect(result['name'], equals('User 1'));
  /// });
  /// test('fetch invalid id', () {
  ///   expect(() => service.fetchUserData(0), throwsA(isA<ArgumentError>()));
  /// });
  /// ```
  Future<Map<String, dynamic>> fetchUserData(int userId) async {
    await Future.delayed(const Duration(milliseconds: 100));

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

  /// จำลองการดึงข้อมูลที่มีโอกาสล้มเหลวแบบ random
  ///
  /// ใช้ `Random().nextBool()` → ล้มเหลว 50% ของเวลา
  /// ⚠️ ทดสอบฟังก์ชันแบบนี้ยากเพราะ non-deterministic
  /// → ต่อยอด: inject Random เพื่อควบคุมผลลัพธ์ใน test ได้
  Future<String> fetchDataWithRandomFailure() async {
    await Future.delayed(const Duration(milliseconds: 50));

    if (_random.nextBool()) {
      throw Exception('Random network error occurred');
    }

    return 'Success: Data fetched successfully';
  }

  /// จำลองการอัปโหลดไฟล์ — ตรวจชื่อไฟล์, ขนาดข้อมูล
  ///
  /// ## ข้อจำกัด
  /// - filename ว่าง → throw ArgumentError
  /// - data ว่าง → throw ArgumentError
  /// - data > 1,000,000 → throw Exception (ไฟล์ใหญ่เกินไป)
  ///
  /// ## ทดสอบ: Multiple Edge Cases
  /// ต้องทดสอบทั้ง 3 กรณีที่ throw + 1 กรณีสำเร็จ
  Future<bool> uploadFile(String filename, List<int> data) async {
    await Future.delayed(const Duration(milliseconds: 200));

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

  /// จำลองการดาวน์โหลดแบบ **Stream** — ส่ง progress 0%, 10%, ... 100%
  ///
  /// ## แนวคิด Testing: Stream Testing
  /// ใช้ `emitsInOrder()` ตรวจว่า stream ส่งค่าตามลำดับ:
  /// ```dart
  /// expect(
  ///   service.downloadProgress(),
  ///   emitsInOrder([0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]),
  /// );
  /// ```
  /// หรือใช้ `expectLater()` สำหรับ async matcher
  Stream<int> downloadProgress() async* {
    for (int progress = 0; progress <= 100; progress += 10) {
      await Future.delayed(const Duration(milliseconds: 10));
      yield progress;
    }
  }

  /// จำลองการดึงข้อมูลหลายรายการพร้อมกัน — ใช้ `Future.wait()`
  ///
  /// ## แนวคิด Testing: Parallel Async
  /// ทดสอบว่า return ครบทุก id + ids ว่างให้ return list ว่าง
  Future<List<String>> fetchMultipleData(List<int> ids) async {
    if (ids.isEmpty) {
      return [];
    }

    List<Future<String>> futures = ids.map((id) async {
      await Future.delayed(const Duration(milliseconds: 50));
      return 'Data for ID: $id';
    }).toList();

    return await Future.wait(futures);
  }

  /// จำลองการทำงานที่มี timeout — throw [TimeoutException] ถ้าเกินเวลา
  ///
  /// ## แนวคิด Testing: Timeout
  /// - timeout นาน → สำเร็จ
  /// - timeout สั้น → throw TimeoutException
  /// ```dart
  /// expect(
  ///   () => service.fetchDataWithTimeout(Duration(milliseconds: 10)),
  ///   throwsA(isA<TimeoutException>()),
  /// );
  /// ```
  Future<String> fetchDataWithTimeout(Duration timeout) async {
    return await Future.delayed(
      const Duration(milliseconds: 100),
      () => 'Data fetched within timeout',
    ).timeout(
      timeout,
      onTimeout: () => throw TimeoutException('Request timed out', timeout),
    );
  }

  /// จำลอง Retry Pattern — ลองใหม่เมื่อล้มเหลว
  ///
  /// ## Behavior
  /// - ล้มเหลว 2 ครั้งแรกเสมอ (จำลอง temporary failure)
  /// - ครั้งที่ 3 ขึ้นไปสำเร็จ
  /// - ถ้า maxRetries < 3 → throw Exception (retry ไม่พอ)
  ///
  /// ## ทดสอบ
  /// - maxRetries = 3 → สำเร็จ (ล้มเหลว 2 ครั้ง + สำเร็จครั้งที่ 3)
  /// - maxRetries = 2 → throw (retry ไม่พอ)
  Future<String> fetchDataWithRetry(int maxRetries) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        await Future.delayed(const Duration(milliseconds: 50));

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
          const Duration(milliseconds: 100),
        ); // หน่วงเวลาก่อน retry
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// จำลอง Batch Processing — ประมวลผลเป็นชุดย่อยๆ
  ///
  /// ## Parameters
  /// - `items` — ข้อมูลทั้งหมดที่จะประมวลผล
  /// - `processor` — ฟังก์ชันที่ใช้ประมวลผลแต่ละ item
  /// - `batchSize` — จำนวน item ต่อ batch (default: 5)
  ///
  /// ## แนวคิด Testing: Higher-Order Function
  /// ทดสอบโดยส่ง processor function เข้ามา:
  /// ```dart
  /// final result = await service.processBatch<int>(
  ///   [1, 2, 3],
  ///   (item) async => item * 2,
  /// );
  /// expect(result, equals([2, 4, 6]));
  /// ```
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
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }

    return results;
  }
}
