import 'package:drift_tutorial/data/database.dart';
import 'package:drift_tutorial/widgets/new_task_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(children: [
        Expanded(child: _buildTaskList(context)),
        NewTaskInput(),
      ]),
    );
  }
}

StreamBuilder<List<Task>> _buildTaskList(BuildContext context) {
  final database = Provider.of<AppDatabase>(context);
  return StreamBuilder(
    stream: database.watchAllTasks(),
    builder: (context, snapshot) {
      final tasks = snapshot.data ?? [];

      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final itemTask = tasks[index];
          return _buildListItem(itemTask, database);
        },
      );
    },
  );
}

Widget _buildListItem(Task itemTask, AppDatabase database) {
  return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (e) => database.deleteTask(itemTask),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: CheckboxListTile(
        title: Text(itemTask.name),
        subtitle: Text(itemTask.dueDate?.toString() ?? 'No date'),
        value: itemTask.completed,
        onChanged: (newValue) {
          database.updateTask(itemTask.copyWith(completed: newValue));
        },
      ));
}
