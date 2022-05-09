import 'package:flutter/material.dart';

class FieldWidget extends StatelessWidget {
  const FieldWidget({
    Key? key,
    required this.controller,
    required this.title,
    this.errorText,
    this.maxLines = 1,
    this.suffix,
  }) : super(key: key);

  final TextEditingController controller;
  final String title;
  final String? errorText;
  final int? maxLines;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      controller: controller,
      decoration:
          InputDecoration(border: const OutlineInputBorder(), labelText: title, errorText: errorText, suffix: suffix),
    );
  }
}
