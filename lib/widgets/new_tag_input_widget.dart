import 'package:drift/drift.dart';
import 'package:drift_tutorial/data/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class NewTagInput extends StatefulWidget {
  const NewTagInput({super.key});

  @override
  State<NewTagInput> createState() => _NewTagInputState();
}

class _NewTagInputState extends State<NewTagInput> {
  static const Color DEFAULT_COLOR = Colors.red;

  Color? pickedTagColor = DEFAULT_COLOR;
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
      child: Row(children: [
        _buildTextField(context),
        _buildColorPickerButton(context),
      ]),
    );
  }

  Flexible _buildTextField(BuildContext context) {
    return Flexible(
        flex: 1,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Tag Name'),
          onSubmitted: (inputName) {
            final dao = Provider.of<TagDao>(context, listen: false);
            final tag = TagsCompanion(
              name: Value(inputName),
              color: pickedTagColor != null
                  ? Value(pickedTagColor!.value)
                  : const Value.absent(),
            );
            dao.insertTag(tag);
            resetValuesAfterSubmit();
          },
        ));
  }

  Widget _buildColorPickerButton(BuildContext context) {
    return Flexible(
        flex: 1,
        child: GestureDetector(
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pickedTagColor,
            ),
          ),
          onTap: () {
            _showColorPickerDialog(context);
          },
        ));
  }

  Future _showColorPickerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: MaterialColorPicker(
              allowShades: false,
              selectedColor: DEFAULT_COLOR,
              onMainColorChange: (colorSwatch) {
                setState(() {
                  pickedTagColor = colorSwatch;
                });
                Navigator.of(context).pop();
              }),
        );
      },
    );
  }

  void resetValuesAfterSubmit() {
    setState(() {
      pickedTagColor = DEFAULT_COLOR;
      controller.clear();
    });
  }
}
