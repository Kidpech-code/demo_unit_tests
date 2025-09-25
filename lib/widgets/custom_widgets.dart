import 'dart:async';
import 'package:flutter/material.dart';

/// Custom Widget สำหรับแสดงข้อมูลผู้ใช้
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

/// Counter Widget พร้อมการแสดงข้อความที่เปลี่ยนแปลง
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

/// Form Widget สำหรับเพิ่มผู้ใช้ใหม่
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

/// Loading Widget แบบต่างๆ
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

/// Search Widget
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
