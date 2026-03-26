import 'package:flutter/material.dart';
import 'package:demo_unit_tests/models/user.dart';
import 'package:demo_unit_tests/services/user_service.dart';
import 'package:demo_unit_tests/widgets/custom_widgets.dart';

/// หน้าจอหลักสำหรับจัดการผู้ใช้
class UserManagementPage extends StatefulWidget {
  final UserService? userService;

  const UserManagementPage({super.key, this.userService});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late UserService _userService;
  late List<User> _users;
  late List<User> _filteredUsers;
  String _searchQuery = '';
  bool _isLoading = false;
  User? _selectedUser;

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? UserService();
    _users = [];
    _filteredUsers = [];
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _users = _userService.getAllUsers();
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<void> _addUser(String name, String email) async {
    setState(() {
      _isLoading = true;
    });

    // จำลองการบันทึกข้อมูล
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final maxId = _users.isEmpty
          ? 0
          : _users.map((u) => u.id).reduce((a, b) => a > b ? a : b);
      final newUser = User(
        id: maxId + 1,
        name: name,
        email: email,
        age: 25, // ค่า default
      );

      _userService.addUser(newUser);
      _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User $name added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _userService.removeUser(user.id);
              _loadUsers();
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _selectUser(User user) {
    setState(() {
      _selectedUser = _selectedUser?.id == user.id ? null : user;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchWidget(
              hintText: 'Search users by name or email...',
              onSearchChanged: _onSearchChanged,
            ),
          ),

          // Users Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Total Users: ${_users.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'Showing: ${_filteredUsers.length}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Users List
          Expanded(
            child: _isLoading
                ? const LoadingWidget(
                    message: 'Loading users...',
                    type: LoadingType.circular,
                  )
                : _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.people_outline
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No users found.\nAdd your first user!'
                              : 'No users match your search.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: UserCard(
                          name: user.name,
                          email: user.email,
                          isSelected: _selectedUser?.id == user.id,
                          onTap: () => _selectUser(user),
                          onDeletePressed: () => _deleteUser(user),
                          onEditPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Edit functionality not implemented yet',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: AddUserForm(onSubmit: _addUser),
              ),
            ),
          );
        },
        label: const Text('Add User'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}

/// หน้าจอตัวนับแบบง่าย
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _currentValue = 0;
  final List<int> _history = [];

  void _onValueChanged(int value) {
    setState(() {
      if (_currentValue != value) {
        _history.add(_currentValue);
        _currentValue = value;
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _history.add(_currentValue);
      _currentValue = 0;
    });
  }

  void _undoLastChange() {
    if (_history.isNotEmpty) {
      setState(() {
        _currentValue = _history.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _undoLastChange,
              tooltip: 'Undo Last Change',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCounter,
            tooltip: 'Reset Counter',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CounterWidget(
                initialValue: _currentValue,
                minValue: -10,
                maxValue: 10,
                onValueChanged: _onValueChanged,
              ),
            ),
          ),
          if (_history.isNotEmpty) ...[
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'History:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: _history
                        .map(
                          (value) => Chip(
                            label: Text(value.toString()),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
