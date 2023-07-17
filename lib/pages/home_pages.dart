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
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [_buildCompletedOnlySwitch()],
      ),
      body: Column(children: [
        Expanded(child: _buildTaskList(context)),
        NewTaskInput(),
      ]),
    );
  }

  Widget _buildCompletedOnlySwitch() {
    return Row(
      children: [
        const Text('Completed only'),
        Switch(
          value: showCompleted,
          activeColor: Colors.white,
          onChanged: (newValue) {
            setState(() {
              showCompleted = newValue;
            });
          },
        )
      ],
    );
  }

  StreamBuilder<List<Task>> _buildTaskList(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    return StreamBuilder(
      //=== Test 1st version ===
      stream: showCompleted
          ? database.taskDao.watchCompletedTasks()
          : database.taskDao.watchAllTasks(),

      //=== Test 2nd version ===
      // stream: showCompleted
      //     ? database.taskDao.completedTasksGenerated().watch()
      //     : database.taskDao.watchAllTasks(),

      //=== Test 3rd version ===
      // stream: showCompleted
      //     ? database.taskDao.watchCompletedTasksCustom()
      //     : database.taskDao.watchAllTasks(),

      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final itemTask = tasks[index];
            return _buildListItem(itemTask, database.taskDao);
          },
        );
      },
    );
  }

  Widget _buildListItem(Task itemTask, TaskDao dao) {
    return Slidable(
        key: const ValueKey(0),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (e) => dao.deleteTask(itemTask),
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
            dao.updateTask(itemTask.copyWith(completed: newValue));
          },
        ));
  }
}
