import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    required this.title,
    this.isEnabled = true,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.blue.withOpacity(0.1),
        primary: Colors.blue.withOpacity(isEnabled ? 1 : 0.5),
        // maximumSize: const Size(200, 40),
      ),
      onPressed: onPressed,
      child: Text(title),
    );
  }
}
