import 'package:flutter/material.dart';
import 'package:isolation/home.dart';
import 'package:worker_manager/worker_manager.dart';

void main() async{
  workerManager.log = true;
  await workerManager.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
