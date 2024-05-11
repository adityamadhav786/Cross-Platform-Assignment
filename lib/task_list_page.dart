import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart'; // For date formatting
import 'package:quick_task_app_assignment/login_page.dart'; // Import the login page

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class Task {
  final String taskId; // Unique identifier for each task
  String taskName;
  DateTime taskDueDate;
  String taskDesc;
  bool isCompleted;

  Task({
    required this.taskId,
    required this.taskName,
    required this.taskDueDate,
    required this.taskDesc,
    this.isCompleted = false,
  });
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        backgroundColor: Color.fromARGB(255, 94, 212, 252),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Wrap(
          children: tasks.map((task) {
            return GestureDetector(
              onTap: () {
                _editTask(context, task);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 2 - 20,
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 204, 205, 205)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          task.taskName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            setState(() {
                              task.isCompleted = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Due: ${DateFormat('yyyy-MM-dd').format(task.taskDueDate)}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      task.taskDesc,
                      style: TextStyle(
                        color: Color.fromARGB(255, 109, 218, 227),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _editTask(context, task);
                          },
                          child: Text('Modify'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _deleteTask(task);
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTask(context);
        },
        child: Icon(Icons.edit),
        backgroundColor: Color.fromARGB(255, 129, 223, 254),
      ),
    );
  }

  void _editTask(BuildContext context, Task task) {
    TextEditingController nameController =
        TextEditingController(text: task.taskName);
    TextEditingController dueDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(task.taskDueDate));
    TextEditingController descController =
        TextEditingController(text: task.taskDesc);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modify Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save edited task
                setState(() {
                  task.taskName = nameController.text;
                  task.taskDueDate =
                      DateFormat('yyyy-MM-dd').parse(dueDateController.text);
                  task.taskDesc = descController.text;
                });
                // Call method to save changes to your backend (back4app)
                _saveTaskToBackend(task);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
    // Call method to delete task from your backend (back4app)
    _deleteTaskFromBackend(task);
  }

  void _addTask(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();
    TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Create new task
                Task newTask = Task(
                  taskId: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(), // Generate unique taskId
                  taskName: nameController.text,
                  taskDueDate:
                      DateFormat('yyyy-MM-dd').parse(dueDateController.text),
                  taskDesc: descController.text,
                );
                // Add new task to the list
                setState(() {
                  tasks.add(newTask);
                });
                // Call method to save new task to your backend (back4app)
                _saveTaskToBackend(newTask);
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTaskToBackend(Task task) async {
    final taskObject = ParseObject('TaskDetails')
      ..set('taskId', task.taskId)
      ..set('taskName', task.taskName)
      ..set('taskDueDate', task.taskDueDate)
      ..set('taskDesc', task.taskDesc);

    try {
      final response = await taskObject.save();
      if (response.success) {
        _showToast('Task saved successfully');
      } else {
        throw Exception('Failed to save task: ${response.error?.message}');
      }
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  Future<void> _deleteTaskFromBackend(Task task) async {
    try {
      // Create a query to find the task in your back4app database based on the taskId
      final query = QueryBuilder(ParseObject('TaskDetails'))
        ..whereEqualTo('taskId', task.taskId);

      // Execute the query
      final response = await query.query();
      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        // If task is found, delete it
        final tasksToDelete = response.results!;
        final deleteResponse = await tasksToDelete[0].delete();
        if (deleteResponse.success) {
          // Task deleted successfully
          _showToast('Task deleted successfully');
        } else {
          // Failed to delete task
          throw Exception(
              'Failed to delete task: ${deleteResponse.error?.message}');
        }
      } else {
        // Task not found
        throw Exception('Task not found');
      }
    } catch (e) {
      // Handle errors
      _showToast('Error: $e');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
