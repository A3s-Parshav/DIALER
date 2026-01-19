import 'package:advayx/pages/splash.dart';
import 'package:flutter/material.dart';
import 'service/contact_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load local storage before the UI even appears
  await ContactService.init();

  runApp(const advayx());
}

class advayx extends StatelessWidget {
  const advayx({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Splash());
  }
}
