import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_unit_tests/services/exception_examples.dart';

void main() {
  group('Exception Handling Tests', () {
    group('ValidationException Tests', () {
      late ValidationService validationService;

      setUp(() {
        validationService = ValidationService();
      });

      group('Email Validation', () {
        test('should pass with valid email', () {
          // Act & Assert - ไม่ควร throw exception
          expect(
            () => validationService.validateEmail('test@example.com'),
            returnsNormally,
          );
        });

        test('should throw ValidationException for null email', () {
          // Act & Assert
          expect(
            () => validationService.validateEmail(null),
            throwsA(
              isA<ValidationException>()
                  .having(
                    (e) => e.message,
                    'message',
                    contains('Email is required'),
                  )
                  .having((e) => e.field, 'field', equals('email')),
            ),
          );
        });

        test('should throw ValidationException for empty email', () {
          // Act & Assert
          expect(
            () => validationService.validateEmail(''),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.message,
                'message',
                contains('Email is required'),
              ),
            ),
          );
        });

        test('should throw ValidationException for invalid email format', () {
          // Test หลายรูปแบบที่ไม่ถูกต้อง
          final invalidEmails = [
            'invalid-email',
            '@example.com',
            'test@',
            'test.example.com',
            'test@.com',
          ];

          for (final email in invalidEmails) {
            expect(
              () => validationService.validateEmail(email),
              throwsA(
                isA<ValidationException>().having(
                  (e) => e.message,
                  'message',
                  contains('Invalid email format'),
                ),
              ),
              reason: 'Should reject invalid email: $email',
            );
          }
        });
      });

      group('Password Validation', () {
        test('should pass with strong password', () {
          // Act & Assert
          expect(
            () => validationService.validatePassword('StrongPass123'),
            returnsNormally,
          );
        });

        test('should throw ValidationException for null password', () {
          expect(
            () => validationService.validatePassword(null),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.message,
                'message',
                contains('Password is required'),
              ),
            ),
          );
        });

        test('should throw ValidationException for short password', () {
          expect(
            () => validationService.validatePassword('short'),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.message,
                'message',
                contains('at least 8 characters'),
              ),
            ),
          );
        });

        test(
          'should throw ValidationException for password without uppercase',
          () {
            expect(
              () => validationService.validatePassword('lowercase123'),
              throwsA(
                isA<ValidationException>().having(
                  (e) => e.message,
                  'message',
                  contains('uppercase letter'),
                ),
              ),
            );
          },
        );

        test(
          'should throw ValidationException for password without number',
          () {
            expect(
              () => validationService.validatePassword('NoNumbers'),
              throwsA(
                isA<ValidationException>().having(
                  (e) => e.message,
                  'message',
                  contains('contain number'),
                ),
              ),
            );
          },
        );

        test(
          'should validate multiple password requirements simultaneously',
          () {
            // Test password ที่ผิดหลายเงื่อนไข
            // ควร throw exception แรกที่เจอตามลำดับการ validate
            expect(
              () => validationService.validatePassword(
                'bad',
              ), // สั้น และไม่มีตัวพิมพ์ใหญ่ และไม่มีตัวเลข
              throwsA(
                isA<ValidationException>().having(
                  (e) => e.message,
                  'message',
                  contains('at least 8 characters'),
                ),
              ),
            );
          },
        );
      });

      group('Age Validation', () {
        test('should pass with valid age', () {
          expect(() => validationService.validateAge(25), returnsNormally);
          expect(() => validationService.validateAge(0), returnsNormally);
          expect(() => validationService.validateAge(150), returnsNormally);
        });

        test('should throw ValidationException for null age', () {
          expect(
            () => validationService.validateAge(null),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.message,
                'message',
                contains('Age is required'),
              ),
            ),
          );
        });

        test('should throw ValidationException for negative age', () {
          expect(
            () => validationService.validateAge(-1),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.message,
                'message',
                contains('cannot be negative'),
              ),
            ),
          );
        });

        test('should throw ValidationException for age over 150', () {
          expect(
            () => validationService.validateAge(151),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.message,
                'message',
                contains('cannot exceed 150'),
              ),
            ),
          );
        });
      });

      group('Multiple Validation Tests', () {
        test('should pass with all valid data', () {
          expect(
            () => validationService.validateUser(
              email: 'test@example.com',
              password: 'StrongPass123',
              age: 25,
            ),
            returnsNormally,
          );
        });

        test('should collect and report multiple validation errors', () {
          expect(
            () => validationService.validateUser(
              email: 'invalid-email',
              password: 'weak',
              age: -1,
            ),
            throwsA(
              isA<ValidationException>()
                  .having(
                    (e) => e.message,
                    'message',
                    contains('Multiple validation errors'),
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    contains('Invalid email format'),
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    contains('at least 8 characters'),
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    contains('cannot be negative'),
                  ),
            ),
          );
        });

        test('should handle partial validation failures', () {
          // Valid email, invalid password and age
          expect(
            () => validationService.validateUser(
              email: 'valid@example.com',
              password: 'bad',
              age: 200,
            ),
            throwsA(
              isA<ValidationException>()
                  .having(
                    (e) => e.message,
                    'message',
                    contains('Multiple validation errors'),
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    isNot(contains('email')),
                  ) // email ไม่ควรอยู่ใน error
                  .having(
                    (e) => e.message,
                    'message',
                    contains('at least 8 characters'),
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    contains('cannot exceed 150'),
                  ),
            ),
          );
        });
      });
    });

    group('NetworkException Tests', () {
      late NetworkService networkService;

      setUp(() {
        networkService = NetworkService();
      });

      test('should return data for valid endpoint', () async {
        // Act
        final result = await networkService.fetchData('/users');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['data'], equals('success'));
        expect(result['endpoint'], equals('/users'));
        expect(result['timestamp'], isA<String>());
      });

      test('should throw ArgumentError for empty endpoint', () async {
        // Act & Assert
        await expectLater(
          networkService.fetchData(''),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Endpoint cannot be empty'),
            ),
          ),
        );
      });

      test('should throw NetworkException with correct status codes', () async {
        final testCases = [
          {'endpoint': '/error/400', 'status': 400, 'message': 'Bad Request'},
          {'endpoint': '/error/401', 'status': 401, 'message': 'Unauthorized'},
          {'endpoint': '/error/404', 'status': 404, 'message': 'Not Found'},
          {
            'endpoint': '/error/500',
            'status': 500,
            'message': 'Internal Server Error',
          },
        ];

        for (final testCase in testCases) {
          await expectLater(
            networkService.fetchData(testCase['endpoint'] as String),
            throwsA(
              isA<NetworkException>()
                  .having(
                    (e) => e.statusCode,
                    'statusCode',
                    equals(testCase['status']),
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    equals(testCase['message']),
                  ),
            ),
            reason: 'Should handle ${testCase['endpoint']} correctly',
          );
        }
      });

      group('Retry Logic Tests', () {
        test('should succeed without retry for valid endpoint', () async {
          // Act
          final result = await networkService.fetchDataWithRetry('/users');

          // Assert
          expect(result['data'], equals('success'));
        });

        test('should not retry for client errors (4xx)', () async {
          // Client errors shouldn't be retried
          final clientErrors = ['/error/400', '/error/401', '/error/404'];

          for (final endpoint in clientErrors) {
            await expectLater(
              networkService.fetchDataWithRetry(endpoint, maxRetries: 3),
              throwsA(isA<NetworkException>()),
              reason: 'Should not retry $endpoint',
            );
          }
        });

        test('should retry for server errors (5xx)', () async {
          final stopwatch = Stopwatch()..start();

          await expectLater(
            networkService.fetchDataWithRetry('/error/500', maxRetries: 3),
            throwsA(
              isA<NetworkException>().having(
                (e) => e.statusCode,
                'statusCode',
                equals(500),
              ),
            ),
          );

          stopwatch.stop();
          // ควรใช้เวลามากกว่า 300ms (3 retries * 100ms delay)
          expect(stopwatch.elapsedMilliseconds, greaterThan(250));
        });

        test('should respect custom retry parameters', () async {
          const customRetries = 2;
          const customDelay = Duration(milliseconds: 50);

          final stopwatch = Stopwatch()..start();

          await expectLater(
            networkService.fetchDataWithRetry(
              '/error/500',
              maxRetries: customRetries,
              retryDelay: customDelay,
            ),
            throwsA(isA<NetworkException>()),
          );

          stopwatch.stop();
          // ควรใช้เวลาประมาณ 2 * 50ms = 100ms + execution time
          expect(stopwatch.elapsedMilliseconds, greaterThan(90));
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(300),
          ); // เพิ่มเวลาให้มากขึ้น
        });
      });

      group('Timeout Handling Tests', () {
        test('should handle timeout appropriately', () async {
          // ตั้ง timeout สั้นกว่าเวลาที่ service ใช้
          await expectLater(
            networkService
                .fetchData('/timeout')
                .timeout(Duration(milliseconds: 200)),
            throwsA(isA<TimeoutException>()),
          );
        });
      });
    });

    group('BusinessLogicException Tests', () {
      late AccountService accountService;

      setUp(() {
        accountService = AccountService();
      });

      group('Account Creation Tests', () {
        test('should create account successfully', () {
          // Act & Assert
          expect(
            () => accountService.createAccount('ACC001', 1000.0),
            returnsNormally,
          );

          expect(accountService.getBalance('ACC001'), equals(1000.0));
        });

        test('should throw BusinessLogicException for empty account ID', () {
          expect(
            () => accountService.createAccount('', 1000.0),
            throwsA(
              isA<BusinessLogicException>()
                  .having(
                    (e) => e.message,
                    'message',
                    contains('Account ID cannot be empty'),
                  )
                  .having(
                    (e) => e.errorCode,
                    'errorCode',
                    equals('INVALID_ACCOUNT_ID'),
                  ),
            ),
          );
        });

        test(
          'should throw BusinessLogicException for negative initial balance',
          () {
            expect(
              () => accountService.createAccount('ACC001', -100.0),
              throwsA(
                isA<BusinessLogicException>()
                    .having(
                      (e) => e.message,
                      'message',
                      contains('cannot be negative'),
                    )
                    .having(
                      (e) => e.errorCode,
                      'errorCode',
                      equals('NEGATIVE_BALANCE'),
                    ),
              ),
            );
          },
        );

        test('should throw BusinessLogicException for duplicate account', () {
          // Arrange
          accountService.createAccount('ACC001', 1000.0);

          // Act & Assert
          expect(
            () => accountService.createAccount('ACC001', 500.0),
            throwsA(
              isA<BusinessLogicException>().having(
                (e) => e.errorCode,
                'errorCode',
                equals('DUPLICATE_ACCOUNT'),
              ),
            ),
          );
        });
      });

      group('Transaction Tests', () {
        setUp(() {
          accountService.createAccount('ACC001', 1000.0);
          accountService.createAccount('ACC002', 500.0);
        });

        test('should deposit successfully', () {
          // Act
          accountService.deposit('ACC001', 200.0);

          // Assert
          expect(accountService.getBalance('ACC001'), equals(1200.0));
        });

        test(
          'should throw BusinessLogicException for deposit to non-existent account',
          () {
            expect(
              () => accountService.deposit('NON_EXISTENT', 100.0),
              throwsA(
                isA<BusinessLogicException>().having(
                  (e) => e.errorCode,
                  'errorCode',
                  equals('ACCOUNT_NOT_FOUND'),
                ),
              ),
            );
          },
        );

        test(
          'should throw BusinessLogicException for negative deposit amount',
          () {
            expect(
              () => accountService.deposit('ACC001', -50.0),
              throwsA(
                isA<BusinessLogicException>().having(
                  (e) => e.errorCode,
                  'errorCode',
                  equals('INVALID_AMOUNT'),
                ),
              ),
            );
          },
        );

        test('should withdraw successfully', () {
          // Act
          accountService.withdraw('ACC001', 300.0);

          // Assert
          expect(accountService.getBalance('ACC001'), equals(700.0));
        });

        test('should throw BusinessLogicException for insufficient funds', () {
          expect(
            () => accountService.withdraw('ACC001', 1500.0),
            throwsA(
              isA<BusinessLogicException>().having(
                (e) => e.errorCode,
                'errorCode',
                equals('INSUFFICIENT_FUNDS'),
              ),
            ),
          );
        });

        test('should withdraw exact balance successfully', () {
          // Act
          accountService.withdraw('ACC001', 1000.0);

          // Assert
          expect(accountService.getBalance('ACC001'), equals(0.0));
        });

        test('should throw for zero deposit amount', () {
          expect(
            () => accountService.deposit('ACC001', 0),
            throwsA(
              isA<BusinessLogicException>().having(
                (e) => e.errorCode,
                'errorCode',
                equals('INVALID_AMOUNT'),
              ),
            ),
          );
        });

        test('should throw for zero withdrawal amount', () {
          expect(
            () => accountService.withdraw('ACC001', 0),
            throwsA(
              isA<BusinessLogicException>().having(
                (e) => e.errorCode,
                'errorCode',
                equals('INVALID_AMOUNT'),
              ),
            ),
          );
        });

        test('should transfer successfully', () {
          // Act
          accountService.transfer('ACC001', 'ACC002', 200.0);

          // Assert
          expect(accountService.getBalance('ACC001'), equals(800.0));
          expect(accountService.getBalance('ACC002'), equals(700.0));
        });

        test(
          'should throw BusinessLogicException for same account transfer',
          () {
            expect(
              () => accountService.transfer('ACC001', 'ACC001', 100.0),
              throwsA(
                isA<BusinessLogicException>().having(
                  (e) => e.errorCode,
                  'errorCode',
                  equals('SAME_ACCOUNT_TRANSFER'),
                ),
              ),
            );
          },
        );

        test('should rollback transfer if destination account not found', () {
          // Arrange
          final initialBalance = accountService.getBalance('ACC001');

          // Act & Assert
          expect(
            () => accountService.transfer('ACC001', 'NON_EXISTENT', 100.0),
            throwsA(
              isA<BusinessLogicException>().having(
                (e) => e.errorCode,
                'errorCode',
                equals('ACCOUNT_NOT_FOUND'),
              ),
            ),
          );

          // Balance should be unchanged (rolled back)
          expect(accountService.getBalance('ACC001'), equals(initialBalance));
        });
      });

      group('Error Code Classification Tests', () {
        test('should categorize exceptions by error codes', () {
          final errorsByCategory = <String, List<String>>{
            'VALIDATION': [],
            'NOT_FOUND': [],
            'BUSINESS_RULE': [],
          };

          // Test different error scenarios and categorize them
          final testCases = [
            () => accountService.createAccount('', 100.0), // INVALID_ACCOUNT_ID
            () =>
                accountService.getBalance('NON_EXISTENT'), // ACCOUNT_NOT_FOUND
            () =>
                accountService.withdraw('ACC001', 2000.0), // INSUFFICIENT_FUNDS
          ];

          // First create a valid account for testing
          accountService.createAccount('ACC001', 1000.0);

          for (int i = 0; i < testCases.length; i++) {
            try {
              testCases[i]();
            } on BusinessLogicException catch (e) {
              if (e.errorCode.contains('INVALID') ||
                  e.errorCode.contains('NEGATIVE')) {
                errorsByCategory['VALIDATION']!.add(e.errorCode);
              } else if (e.errorCode.contains('NOT_FOUND')) {
                errorsByCategory['NOT_FOUND']!.add(e.errorCode);
              } else {
                errorsByCategory['BUSINESS_RULE']!.add(e.errorCode);
              }
            }
          }

          // Assert
          expect(
            errorsByCategory['VALIDATION'],
            contains('INVALID_ACCOUNT_ID'),
          );
          expect(errorsByCategory['NOT_FOUND'], contains('ACCOUNT_NOT_FOUND'));
          expect(
            errorsByCategory['BUSINESS_RULE'],
            contains('INSUFFICIENT_FUNDS'),
          );
        });
      });
    });

    group('Exception Type Tests', () {
      test('should distinguish between exception types', () {
        final validationService = ValidationService();
        final networkService = NetworkService();
        final accountService = AccountService();

        // Test different exception types
        expect(
          () => validationService.validateEmail('invalid'),
          throwsA(isA<ValidationException>()),
        );

        expect(
          networkService.fetchData('/error/404'),
          throwsA(isA<NetworkException>()),
        );

        expect(
          () => accountService.getBalance('NON_EXISTENT'),
          throwsA(isA<BusinessLogicException>()),
        );

        expect(networkService.fetchData(''), throwsA(isA<ArgumentError>()));
      });

      test('should have proper string representation', () {
        // Test exception toString methods
        final validationEx = ValidationException('Test error', field: 'test');
        final networkEx = NetworkException('Network error', statusCode: 500);
        final businessEx = BusinessLogicException(
          'Business error',
          'TEST_ERROR',
        );

        expect(validationEx.toString(), contains('ValidationException'));
        expect(validationEx.toString(), contains('field: test'));

        expect(networkEx.toString(), contains('NetworkException'));
        expect(networkEx.toString(), contains('status: 500'));

        expect(businessEx.toString(), contains('BusinessLogicException'));
        expect(businessEx.toString(), contains('code: TEST_ERROR'));
      });
    });

    group('Exception Recovery Tests', () {
      test('should provide meaningful error recovery information', () {
        final accountService = AccountService();

        // Test การแสดงข้อความ error ที่เป็นประโยชน์
        try {
          accountService.withdraw('NON_EXISTENT', 100.0);
          fail('Should have thrown an exception');
        } on BusinessLogicException catch (e) {
          expect(e.message, contains('Account not found'));
          expect(e.errorCode, equals('ACCOUNT_NOT_FOUND'));

          // ในแอปจริง เราสามารถใช้ error code เพื่อแสดง UI ที่เหมาะสม
          // เช่น แสดงหน้า create account หรือ search account
        }
      });

      test('should handle exception chaining', () async {
        final networkService = NetworkService();

        // Test nested exception handling
        try {
          await networkService.fetchDataWithRetry('/error/500', maxRetries: 2);
          fail('Should have thrown an exception');
        } on NetworkException catch (e) {
          expect(e.statusCode, equals(500));
          expect(e.message, contains('Internal Server Error'));

          // ในแอปจริง เราสามารถ log original exception และแสดง user-friendly message
        }
      });
    });
  });
}
