import 'package:flutter/material.dart';

class Recordpage1 extends StatefulWidget {
  // Adding 'const' here allows you to use 'const Recordpage1()'
  const Recordpage1({super.key});

  @override
  State<Recordpage1> createState() => _Recordpage1State();
}

class _Recordpage1State extends State<Recordpage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recordings")),
      body: const Center(child: Text("Recording History")),
    );
  }
}
