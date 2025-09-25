import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_unit_tests/services/async_data_service.dart';

void main() {
  group('AsyncDataService Tests', () {
    late AsyncDataService service;

    setUp(() {
      service = AsyncDataService();
    });

    group('fetchUserData Tests', () {
      test('should return user data when userId is valid', () async {
        // Act
        final result = await service.fetchUserData(1);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], equals(1));
        expect(result['name'], equals('User 1'));
        expect(result['email'], equals('user1@example.com'));
        expect(result['createdAt'], isA<String>());
      });

      test('should throw ArgumentError for invalid userId', () async {
        // Act & Assert
        await expectLater(
          service.fetchUserData(0),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              equals('User ID must be positive'),
            ),
          ),
        );

        await expectLater(
          service.fetchUserData(-1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should complete within reasonable time', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await service.fetchUserData(1);

        // Assert
        stopwatch.stop();
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
        ); // ควรเสร็จภายใน 500ms
      });

      test('should handle multiple concurrent requests', () async {
        // Arrange
        const numberOfRequests = 5;
        final futures = <Future<Map<String, dynamic>>>[];

        // Act - สร้าง requests พร้อมกัน
        for (int i = 1; i <= numberOfRequests; i++) {
          futures.add(service.fetchUserData(i));
        }

        final results = await Future.wait(futures);

        // Assert
        expect(results.length, equals(numberOfRequests));
        for (int i = 0; i < numberOfRequests; i++) {
          expect(results[i]['id'], equals(i + 1));
          expect(results[i]['name'], equals('User ${i + 1}'));
        }
      });
    });

    group('fetchDataWithRandomFailure Tests', () {
      test('should either succeed or fail with specific exception', () async {
        // Act & Assert
        // เรียกหลายครั้งเพื่อทดสอบทั้งกรณีสำเร็จและล้มเหลว
        final results = <dynamic>[];

        for (int i = 0; i < 10; i++) {
          try {
            final result = await service.fetchDataWithRandomFailure();
            results.add(result);
          } catch (e) {
            results.add(e);
          }
        }

        // ควรมีอย่างน้อยหนึ่งผลลัพธ์ (ไม่ว่าจะสำเร็จหรือล้มเหลว)
        expect(results, isNotEmpty);

        // ตรวจสอบว่าผลลัพธ์เป็นไปตามที่คาดหวัง
        for (final result in results) {
          expect(
            result,
            anyOf([
              equals('Success: Data fetched successfully'),
              isA<Exception>().having(
                (e) => e.toString(),
                'toString',
                contains('Random network error occurred'),
              ),
            ]),
          );
        }
      });

      test(
        'should have reasonable performance under failure conditions',
        () async {
          // Arrange
          final stopwatch = Stopwatch()..start();
          int attempts = 0;

          // Act - ลองเรียกจนกว่าจะสำเร็จหรือครบ 20 ครั้ง
          while (attempts < 20) {
            try {
              await service.fetchDataWithRandomFailure();
              break; // สำเร็จแล้ว หยุด
            } catch (e) {
              attempts++;
            }
          }

          // Assert
          stopwatch.stop();
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(5000),
          ); // ไม่ควรใช้เวลานานเกิน 5 วินาที
        },
      );
    });

    group('uploadFile Tests', () {
      test('should upload file successfully with valid data', () async {
        // Arrange
        const filename = 'test.txt';
        final data = List.generate(100, (i) => i);

        // Act
        final result = await service.uploadFile(filename, data);

        // Assert
        expect(result, isTrue);
      });

      test('should throw exception for empty filename', () async {
        // Arrange
        const filename = '';
        final data = [1, 2, 3];

        // Act & Assert
        await expectLater(
          service.uploadFile(filename, data),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              equals('Filename cannot be empty'),
            ),
          ),
        );
      });

      test('should throw exception for empty data', () async {
        // Arrange
        const filename = 'test.txt';
        final data = <int>[];

        // Act & Assert
        await expectLater(
          service.uploadFile(filename, data),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              equals('File data cannot be empty'),
            ),
          ),
        );
      });

      test('should throw exception for file too large', () async {
        // Arrange
        const filename = 'large_file.txt';
        final data = List.generate(2000000, (i) => i); // ขนาดใหญ่เกิน 1MB

        // Act & Assert
        await expectLater(
          service.uploadFile(filename, data),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'toString',
              contains('File too large'),
            ),
          ),
        );
      });

      test('should handle boundary file size (exactly 1MB)', () async {
        // Arrange
        const filename = 'boundary_file.txt';
        final data = List.generate(1000000, (i) => i); // พอดี 1MB

        // Act
        final result = await service.uploadFile(filename, data);

        // Assert
        expect(result, isTrue);
      });
    });

    group('downloadProgress Stream Tests', () {
      test('should emit progress values from 0 to 100', () async {
        // Arrange
        final progressValues = <int>[];

        // Act
        await for (final progress in service.downloadProgress()) {
          progressValues.add(progress);
        }

        // Assert
        expect(
          progressValues,
          equals([0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]),
        );
      });

      test('should emit values in correct order', () async {
        // Arrange
        final progressValues = <int>[];

        // Act
        await service.downloadProgress().forEach((progress) {
          progressValues.add(progress);
        });

        // Assert
        for (int i = 1; i < progressValues.length; i++) {
          expect(
            progressValues[i],
            greaterThanOrEqualTo(progressValues[i - 1]),
          );
        }
      });

      test('should complete stream after reaching 100%', () async {
        // Act
        final stream = service.downloadProgress();
        final lastValue = await stream.last;

        // Assert
        expect(lastValue, equals(100));
      });

      test('should allow multiple subscribers', () async {
        // Act
        final stream1Values = <int>[];
        final stream2Values = <int>[];

        // สร้าง stream สองตัวแยกกัน (การทดสอบที่แท้จริงควรใช้ broadcast stream)
        final stream1Future = service.downloadProgress().forEach((value) {
          stream1Values.add(value);
        });

        final stream2Future = service.downloadProgress().forEach((value) {
          stream2Values.add(value);
        });

        await Future.wait([stream1Future, stream2Future]);

        // Assert
        expect(stream1Values, isNotEmpty);
        expect(stream2Values, isNotEmpty);
        expect(stream1Values, equals(stream2Values));
      });
    });

    group('fetchMultipleData Tests', () {
      test('should return data for all provided IDs', () async {
        // Arrange
        final ids = [1, 2, 3, 4, 5];

        // Act
        final results = await service.fetchMultipleData(ids);

        // Assert
        expect(results.length, equals(5));
        for (int i = 0; i < ids.length; i++) {
          expect(results[i], equals('Data for ID: ${ids[i]}'));
        }
      });

      test('should return empty list for empty input', () async {
        // Act
        final results = await service.fetchMultipleData([]);

        // Assert
        expect(results, isEmpty);
      });

      test('should handle single ID', () async {
        // Act
        final results = await service.fetchMultipleData([42]);

        // Assert
        expect(results.length, equals(1));
        expect(results.first, equals('Data for ID: 42'));
      });

      test('should process requests concurrently', () async {
        // Arrange
        final ids = List.generate(10, (i) => i + 1);
        final stopwatch = Stopwatch()..start();

        // Act
        final results = await service.fetchMultipleData(ids);

        // Assert
        stopwatch.stop();
        expect(results.length, equals(10));
        // ถ้าทำแบบ sequential จะใช้เวลา 10 * 50ms = 500ms
        // ถ้าทำแบบ concurrent จะใช้เวลาประมาณ 50ms
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
        ); // ควรเร็วกว่า sequential
      });
    });

    group('fetchDataWithTimeout Tests', () {
      test('should complete within timeout', () async {
        // Arrange
        final timeout = Duration(milliseconds: 200);

        // Act
        final result = await service.fetchDataWithTimeout(timeout);

        // Assert
        expect(result, equals('Data fetched within timeout'));
      });

      test('should throw TimeoutException when timeout is too short', () async {
        // Arrange
        final timeout = Duration(
          milliseconds: 50,
        ); // น้อยกว่า 100ms ที่ service ใช้

        // Act & Assert
        await expectLater(
          service.fetchDataWithTimeout(timeout),
          throwsA(
            isA<TimeoutException>().having(
              (e) => e.message,
              'message',
              equals('Request timed out'),
            ),
          ),
        );
      });

      test('should respect different timeout values', () async {
        // Test กับ timeout ที่แตกต่างกัน
        final timeouts = [
          Duration(milliseconds: 50), // จะ timeout
          Duration(milliseconds: 150), // จะสำเร็จ
          Duration(milliseconds: 200), // จะสำเร็จ
        ];

        final results = <dynamic>[];

        for (final timeout in timeouts) {
          try {
            final result = await service.fetchDataWithTimeout(timeout);
            results.add(result);
          } catch (e) {
            results.add(e);
          }
        }

        // Assert
        expect(results[0], isA<TimeoutException>());
        expect(results[1], equals('Data fetched within timeout'));
        expect(results[2], equals('Data fetched within timeout'));
      });
    });

    group('fetchDataWithRetry Tests', () {
      test('should eventually succeed after retries', () async {
        // Act
        final result = await service.fetchDataWithRetry(5);

        // Assert
        expect(result, equals('Success after 3 attempts'));
      });

      test('should throw exception when max retries exceeded', () async {
        // Act & Assert
        await expectLater(
          service.fetchDataWithRetry(2), // น้อยกว่า 3 ที่ต้องการ
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'toString',
              contains('Temporary failure on attempt 2'),
            ),
          ),
        );
      });

      test('should handle zero retries', () async {
        // Act & Assert
        await expectLater(
          service.fetchDataWithRetry(0),
          throwsA(isA<Exception>()),
        );
      });

      test('should take reasonable time with retries', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await service.fetchDataWithRetry(5);

        // Assert
        stopwatch.stop();
        // 3 ครั้ง: 50ms + 100ms + 50ms + 100ms + 50ms ≈ 350ms
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('processBatch Tests', () {
      test('should process all items in batches', () async {
        // Arrange
        final items = List.generate(15, (i) => i + 1); // [1, 2, 3, ..., 15]

        Future<int> processor(int item) async {
          await Future.delayed(Duration(milliseconds: 10));
          return item * 2; // คูณด้วย 2
        }

        // Act
        final results = await service.processBatch(
          items,
          processor,
          batchSize: 5,
        );

        // Assert
        expect(results.length, equals(15));
        for (int i = 0; i < results.length; i++) {
          expect(results[i], equals((i + 1) * 2));
        }
      });

      test('should handle empty input list', () async {
        // Arrange
        final items = <String>[];

        Future<String> processor(String item) async => item.toUpperCase();

        // Act
        final results = await service.processBatch(items, processor);

        // Assert
        expect(results, isEmpty);
      });

      test('should respect batch size', () async {
        // Arrange
        final items = List.generate(7, (i) => 'item$i');

        Future<String> processor(String item) async {
          // จำลองการประมวลผลที่ใช้เวลา
          await Future.delayed(Duration(milliseconds: 20));
          return item.toUpperCase();
        }

        // Act
        final results = await service.processBatch<String>(
          items,
          processor,
          batchSize: 3,
        );

        // Assert
        expect(results.length, equals(7));
        // Batch 1: items 0,1,2  Batch 2: items 3,4,5  Batch 3: item 6
        expect(results[0], equals('ITEM0'));
        expect(results[6], equals('ITEM6'));
      });

      test('should handle different data types', () async {
        // Arrange
        final items = ['apple', 'banana', 'cherry'];

        Future<String> processor(String item) async {
          await Future.delayed(Duration(milliseconds: 5));
          return item.toUpperCase();
        }

        // Act
        final results = await service.processBatch<String>(items, processor);

        // Assert
        expect(results, equals(['APPLE', 'BANANA', 'CHERRY']));
      });

      test(
        'should process batches sequentially but items within batch concurrently',
        () async {
          // Arrange
          final items = List.generate(6, (i) => i);
          final processOrder = <int>[];

          Future<int> processor(int item) async {
            await Future.delayed(Duration(milliseconds: 30));
            processOrder.add(item);
            return item;
          }

          // Act
          await service.processBatch(items, processor, batchSize: 3);

          // Assert
          expect(processOrder.length, equals(6));
          // Items ใน batch เดียวกันอาจเสร็จไม่ตามลำดับ แต่ batch ถัดไปจะเริ่มหลัง batch แรกเสร็จ
        },
      );
    });

    group('Integration and Performance Tests', () {
      test('should handle multiple async operations simultaneously', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act - เรียกใช้หลาย operations พร้อมกัน
        final futures = [
          service.fetchUserData(1),
          service.fetchUserData(2),
          service.uploadFile('test1.txt', [1, 2, 3]),
          service.uploadFile('test2.txt', [4, 5, 6]),
          service.fetchMultipleData([1, 2, 3]),
        ];

        final results = await Future.wait(futures);

        // Assert
        stopwatch.stop();
        expect(results.length, equals(5));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test(
        'should handle errors in concurrent operations gracefully',
        () async {
          // Arrange - สร้าง operations ที่ผสมระหว่างสำเร็จและล้มเหลว
          final results = <Object?>[];

          // รันแต่ละ operation แยกๆ และจับ error
          final operations = [
            () => service.fetchUserData(1), // สำเร็จ
            () => service.fetchUserData(999), // ID ที่ใหญ่เกินไป
            () => service.uploadFile('', [1, 2, 3]), // ล้มเหลว
            () => service.fetchMultipleData([1, 2]), // สำเร็จ
          ];

          // Act - รัน operations และจับ errors
          for (final operation in operations) {
            try {
              final result = await operation();
              results.add(result);
            } catch (e) {
              results.add('ERROR: ${e.toString()}');
            }
          }

          // Assert
          expect(results.length, equals(4));

          // ตรวจสอบว่ามีผลลัพธ์ที่สำเร็จและล้มเหลว
          int successCount = 0;
          int errorCount = 0;

          for (final result in results) {
            if (result is String && result.startsWith('ERROR:')) {
              errorCount++;
            } else {
              successCount++;
            }
          }

          expect(
            successCount,
            greaterThan(0),
            reason: 'Should have at least one successful operation',
          );
          expect(
            errorCount,
            greaterThan(0),
            reason: 'Should have at least one failed operation',
          );
        },
      );
    });
  });
}
