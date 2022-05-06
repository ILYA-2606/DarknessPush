import 'package:flutter/material.dart';

class FieldWidget extends StatelessWidget {
  const FieldWidget({
    Key? key,
    required this.controller,
    required this.title,
    required this.errorText,
    this.maxLines = 1,
  }) : super(key: key);

  final TextEditingController controller;
  final String title;
  final String? errorText;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      decoration: InputDecoration(border: const OutlineInputBorder(), labelText: title, errorText: errorText),
    );
  }
}
