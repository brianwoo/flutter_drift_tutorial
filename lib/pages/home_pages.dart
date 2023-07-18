import 'package:drift_tutorial/data/database.dart';
import 'package:drift_tutorial/widgets/new_tag_input_widget.dart';
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
        // actions: [_buildCompletedOnlySwitch()],
      ),
      body: Column(children: [
        Expanded(child: _buildTaskList(context)),
        const NewTaskInput(),
        const NewTagInput(),
      ]),
    );
  }

  // Widget _buildCompletedOnlySwitch() {
  //   return Row(
  //     children: [
  //       const Text('Completed only'),
  //       Switch(
  //         value: showCompleted,
  //         activeColor: Colors.white,
  //         onChanged: (newValue) {
  //           setState(() {
  //             showCompleted = newValue;
  //           });
  //         },
  //       )
  //     ],
  //   );
  // }

  StreamBuilder<List<TaskWithTag>> _buildTaskList(BuildContext context) {
    final dao = Provider.of<TaskDao>(context);

    return StreamBuilder(
      //=== Test 1st version ===
      // stream: showCompleted
      //     ? database.taskDao.watchCompletedTasks()
      //     : database.taskDao.watchAllTasks(),

      //=== Test 2nd version ===
      // stream: showCompleted
      //     ? database.taskDao.completedTasksGenerated().watch()
      //     : database.taskDao.watchAllTasks(),

      //=== Test 3rd version ===
      // stream: showCompleted
      //     ? database.taskDao.watchCompletedTasksCustom()
      //     : database.taskDao.watchAllTasks(),

      stream: dao.watchAllTasks(),

      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final itemTask = tasks[index];
            return _buildListItem(itemTask, dao);
          },
        );
      },
    );
  }

  Widget _buildListItem(TaskWithTag itemTask, TaskDao dao) {
    if (itemTask.task == null) {
      return Container();
    }

    final task = itemTask.task!;
    return Slidable(
        key: const ValueKey(0),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (e) => dao.deleteTask(task),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: CheckboxListTile(
          title: Text(task.name),
          subtitle: Text(task.dueDate?.toString() ?? 'No date'),
          secondary: _buildTag(itemTask.tag),
          value: task.completed,
          onChanged: (newValue) {
            dao.updateTask(task.copyWith(completed: newValue));
          },
        ));
  }

  Column _buildTag(Tag? tag) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (tag != null) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(tag.color),
            ),
          ),
          Text(
            tag.name,
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }
}
