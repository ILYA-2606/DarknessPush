import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    required this.title,
    this.isEnabled = true,
    this.fontSize = 20,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final bool isEnabled;
  final double fontSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: TextStyle(fontSize: fontSize, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFFE6F0F9),
        primary: Colors.blue.withOpacity(isEnabled ? 1 : 0.5),
      ),
      onPressed: onPressed,
      child: Text(title),
    );
  }
}
