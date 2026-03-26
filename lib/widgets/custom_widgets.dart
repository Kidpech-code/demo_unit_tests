import 'dart:async';
import 'package:flutter/material.dart';

/// ===================================================================
/// Custom Widgets — สอน Widget Testing ด้วย Flutter Test
/// ===================================================================
///
/// ## ภาพรวม
/// ไฟล์นี้รวม Widget ตัวอย่างที่สอนแนวคิด Widget Testing:
///
/// | Widget | ประเภท | สิ่งที่สอน |
/// |--------|--------|----------|
/// | [UserCard] | StatelessWidget | find.text(), find.byType(), callback testing |
/// | [CounterWidget] | StatefulWidget | tap(), state change, boundary testing |
/// | [AddUserForm] | StatefulWidget + Form | enterText(), form validation, async submit |
/// | [LoadingWidget] | StatelessWidget | enum-based rendering, conditional UI |
/// | [SearchWidget] | StatefulWidget | debounce, Timer, clear button |
///
/// ## Flutter Widget Testing Basics
/// ```dart
/// testWidgets('description', (WidgetTester tester) async {
///   // 1. สร้าง widget ใน test environment
///   await tester.pumpWidget(MaterialApp(home: MyWidget()));
///
///   // 2. ค้นหา widget ด้วย Finder
///   expect(find.text('Hello'), findsOneWidget);
///
///   // 3. จำลองการกระทำ
///   await tester.tap(find.byIcon(Icons.add));
///   await tester.pump(); // rebuild widget
///
///   // 4. ตรวจผลลัพธ์
///   expect(find.text('1'), findsOneWidget);
/// });
/// ```
///
/// ## pump() vs pumpAndSettle()
/// - `pump()` — rebuild widget 1 ครั้ง (ใช้กับ setState)
/// - `pump(Duration)` — rebuild หลังผ่าน duration (ใช้กับ animation/delay)
/// - `pumpAndSettle()` — rebuild จนไม่มี frame ค้าง (ใช้กับ animation)
///
/// ## Finder ที่ใช้บ่อย
/// - `find.text('Hello')` — ค้นหาด้วยข้อความ
/// - `find.byType(ElevatedButton)` — ค้นหาด้วย type ของ widget
/// - `find.byIcon(Icons.add)` — ค้นหาด้วย icon
/// - `find.byKey(Key('myKey'))` — ค้นหาด้วย key
/// - `find.byTooltip('Edit User')` — ค้นหาด้วย tooltip
///
/// ## Matcher ที่ใช้บ่อย
/// - `findsOneWidget` — เจอ 1 ตัว
/// - `findsNothing` — ไม่เจอเลย
/// - `findsNWidgets(3)` — เจอ N ตัว
/// - `findsWidgets` — เจออย่างน้อย 1 ตัว

/// Widget แสดงข้อมูลผู้ใช้เป็น Card — **StatelessWidget**
///
/// ## สิ่งที่สอนใน Widget Test
/// - **find.text()** — ค้นหาชื่อ, อีเมลที่แสดง
/// - **find.byType()** — ค้นหา CircleAvatar, IconButton
/// - **Callback Testing** — ตรวจว่า onTap, onEditPressed ถูกเรียก
///   ```dart
///   bool tapped = false;
///   await tester.pumpWidget(MaterialApp(
///     home: UserCard(name: 'Test', email: 'a@b.c', onTap: () => tapped = true),
///   ));
///   await tester.tap(find.byType(UserCard));
///   expect(tapped, isTrue);
///   ```
/// - **Conditional Rendering** — ถ้า onEditPressed == null → ไม่แสดง edit button
class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final bool isSelected;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.onTap,
    this.onEditPressed,
    this.onDeletePressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8.0 : 2.0,
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                    : null,
              ),
              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              if (onEditPressed != null || onDeletePressed != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEditPressed != null)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onEditPressed,
                        tooltip: 'Edit User',
                      ),
                    if (onDeletePressed != null)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: onDeletePressed,
                        tooltip: 'Delete User',
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Counter Widget — **StatefulWidget** ที่สอนการทดสอบ State Changes
///
/// ## สิ่งที่สอนใน Widget Test
/// - **tap() + pump()** — กดปุ่มเพิ่ม/ลดแล้วตรวจค่า
///   ```dart
///   await tester.tap(find.byIcon(Icons.add));
///   await tester.pump(); // rebuild เพื่อเห็นค่าใหม่
///   expect(find.text('Counter: 1'), findsOneWidget);
///   ```
/// - **Boundary Testing** — ถ้า maxValue=5 กด + เกิน 5 ไม่ได้
/// - **Conditional UI** — ปุ่มเปลี่ยนสีเมื่อ disabled
/// - **Callback Testing** — ตรวจว่า onValueChanged ถูกเรียกพร้อมค่าใหม่
/// - **Description Mapping** — ค่า 0 แสดง "Zero", บวกแสดง "Positive", ลบแสดง "Negative"
class CounterWidget extends StatefulWidget {
  final int initialValue;
  final int? maxValue;
  final int? minValue;
  final ValueChanged<int>? onValueChanged;

  const CounterWidget({
    super.key,
    this.initialValue = 0,
    this.maxValue,
    this.minValue,
    this.onValueChanged,
  });

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int _counter;

  @override
  void initState() {
    super.initState();
    _counter = widget.initialValue;
  }

  void _increment() {
    if (widget.maxValue == null || _counter < widget.maxValue!) {
      setState(() {
        _counter++;
      });
      widget.onValueChanged?.call(_counter);
    }
  }

  void _decrement() {
    if (widget.minValue == null || _counter > widget.minValue!) {
      setState(() {
        _counter--;
      });
      widget.onValueChanged?.call(_counter);
    }
  }

  String get _counterDescription {
    if (_counter == 0) return 'Zero';
    if (_counter > 0) return 'Positive';
    return 'Negative';
  }

  Color get _counterColor {
    if (_counter == 0) return Colors.grey;
    if (_counter > 0) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final bool canIncrement =
        widget.maxValue == null || _counter < widget.maxValue!;
    final bool canDecrement =
        widget.minValue == null || _counter > widget.minValue!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Counter: $_counter',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _counterDescription,
          style: TextStyle(
            fontSize: 16,
            color: _counterColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: canDecrement ? _decrement : null,
              heroTag: 'decrement',
              backgroundColor: canDecrement ? Colors.red : Colors.grey,
              child: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: canIncrement ? _increment : null,
              heroTag: 'increment',
              backgroundColor: canIncrement ? Colors.blue : Colors.grey,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Range: ${widget.minValue ?? 'No limit'} to ${widget.maxValue ?? 'No limit'}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

/// Form Widget สำหรับเพิ่มผู้ใช้ — สอน **Form Validation + Async Submit**
///
/// ## สิ่งที่สอนใน Widget Test
/// - **enterText()** — พิมพ์ข้อความในช่อง input
///   ```dart
///   await tester.enterText(find.byType(TextFormField).first, 'สมชาย');
///   ```
/// - **Form Validation** — กด submit โดยไม่กรอก → แสดง error message
///   ```dart
///   await tester.tap(find.text('Add User'));
///   await tester.pump(); // trigger validation
///   expect(find.text('Name is required'), findsOneWidget);
///   ```
/// - **Async Submit** — กด submit → แสดง loading → เรียก callback
///   ```dart
///   await tester.tap(find.text('Add User'));
///   await tester.pump(); // เริ่ม loading
///   expect(find.byType(CircularProgressIndicator), findsOneWidget);
///   await tester.pump(Duration(milliseconds: 500)); // รอ async เสร็จ
///   ```
/// - **Callback Verification** — ตรวจว่า onSubmit ถูกเรียกพร้อม name, email
class AddUserForm extends StatefulWidget {
  final void Function(String name, String email)? onSubmit;
  final String? initialName;
  final String? initialEmail;

  const AddUserForm({
    super.key,
    this.onSubmit,
    this.initialName,
    this.initialEmail,
  });

  @override
  State<AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _emailController.text = widget.initialEmail ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        _isLoading = true;
      });

      // จำลองการโหลด
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        widget.onSubmit?.call(
          _nameController.text.trim(),
          _emailController.text.trim(),
        );

        // Clear form after submit
        _nameController.clear();
        _emailController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: _validateName,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading Widget — สอน **Enum-based Conditional Rendering**
///
/// ## สิ่งที่สอนใน Widget Test
/// - **Type-based Testing** — ตรวจว่า widget ที่แสดงตรงกับ LoadingType
///   ```dart
///   // circular → CircularProgressIndicator
///   // linear → LinearProgressIndicator
///   // dots → Container 3 ตัว (custom dots)
///   ```
/// - **Conditional Message** — ถ้ามี message → แสดง Text, ไม่มี → ไม่แสดง
class LoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingType type;

  const LoadingWidget({
    super.key,
    this.message,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    Widget indicator;

    switch (type) {
      case LoadingType.circular:
        indicator = const CircularProgressIndicator();
        break;
      case LoadingType.linear:
        indicator = const LinearProgressIndicator();
        break;
      case LoadingType.dots:
        indicator = Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

enum LoadingType { circular, linear, dots }

/// Search Widget — สอน **Debounce Pattern + Timer Testing**
///
/// ## สิ่งที่สอนใน Widget Test
/// - **enterText() + pump(debounceDelay)** — พิมพ์แล้วรอ debounce
///   ```dart
///   await tester.enterText(find.byType(TextField), 'flutter');
///   await tester.pump(Duration(milliseconds: 500)); // รอ debounce
///   expect(searchQuery, equals('flutter'));
///   ```
/// - **Clear Button** — พิมพ์ข้อความ → ปุ่ม X ปรากฏ → กด X → ข้อความหายไป
/// - **Debounce Testing** — พิมพ์เร็วๆ → callback ถูกเรียกแค่ครั้งเดียว
///
/// ## Debounce คืออะไร?
/// เมื่อ user พิมพ์ จะรอ 500ms หลังหยุดพิมพ์ก่อนค่อยเรียก callback
/// ป้องกันการเรียก API ทุกตัวอักษร (ลด network requests)
class SearchWidget extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onSearchChanged;
  final Duration debounceDelay;

  const SearchWidget({
    super.key,
    this.hintText = 'Search...',
    this.onSearchChanged,
    this.debounceDelay = const Duration(milliseconds: 500),
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {}); // Rebuild when text changes
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDelay, () {
      widget.onSearchChanged?.call(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  _onSearchChanged('');
                },
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
