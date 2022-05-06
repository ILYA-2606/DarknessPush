import 'package:darkness_push/widget/app_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DarknessPush',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AppWidget(title: 'DarknessPush'),
    );
  }
}
