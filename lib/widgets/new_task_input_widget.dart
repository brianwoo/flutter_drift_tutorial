import 'package:drift/drift.dart';
import 'package:drift_tutorial/data/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewTaskInput extends StatefulWidget {
  const NewTaskInput({super.key});

  @override
  State<NewTaskInput> createState() => _NewTaskInputState();
}

class _NewTaskInputState extends State<NewTaskInput> {
  DateTime? newTaskDate;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildTextField(context),
          _buildDateButton(context),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Expanded(
        child: TextField(
      controller: controller,
      decoration: InputDecoration(hintText: 'Task Name'),
      onSubmitted: (inputName) {
        final database = Provider.of<AppDatabase>(context, listen: false);
        final task = TasksCompanion(
          name: Value(inputName),
          dueDate: Value(newTaskDate),
        );
        database.insertTask(task);
        _resetValuesAfterSubmit();
      },
    ));
  }

  Widget _buildDateButton(BuildContext context) {
    return IconButton(
      onPressed: () async {
        newTaskDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2010),
          lastDate: DateTime(2050),
        );
      },
      icon: const Icon(Icons.calendar_today),
    );
  }

  void _resetValuesAfterSubmit() {
    setState(() {
      newTaskDate = null;
      controller.clear();
    });
  }
}
