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
  Tag? selectedTag;
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
          _buildTagSelector(context),
          _buildDateButton(context),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Expanded(
      flex: 1,
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Task Name'),
        onSubmitted: (inputName) {
          final taskDao = Provider.of<TaskDao>(context, listen: false);
          final task = TasksCompanion(
            name: Value(inputName),
            dueDate: Value(newTaskDate),
            tagName: Value(selectedTag?.name),
          );

          print("insertTask: $task");

          taskDao.insertTask(task);
          _resetValuesAfterSubmit();
        },
      ),
    );
  }

  StreamBuilder<List<Tag>> _buildTagSelector(BuildContext context) {
    return StreamBuilder<List<Tag>>(
      stream: Provider.of<TagDao>(context).watchTags(),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? [];

        DropdownMenuItem<Tag> dropdownFromTag(Tag tag) {
          return DropdownMenuItem(
            value: tag,
            child: Row(
              children: <Widget>[
                Text(tag.name),
                const SizedBox(width: 5),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(tag.color),
                  ),
                ),
              ],
            ),
          );
        }

        final dropdownMenuItems =
            tags.map((tag) => dropdownFromTag(tag)).toList()
              // Add a "no tag" item as the first element of the list
              ..insert(
                0,
                DropdownMenuItem(
                  value: null,
                  child: Text('No Tag'),
                ),
              );

        return Expanded(
          child: DropdownButton(
            onChanged: (tag) {
              setState(() {
                selectedTag = tag;
              });
            },
            isExpanded: true,
            value: selectedTag,
            items: dropdownMenuItems,
          ),
        );
      },
    );
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
      selectedTag = null;
      controller.clear();
    });
  }
}
