import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SignLearnApp());
}

class SignLearnApp extends StatelessWidget {
  const SignLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignLearn Web',
      debugShowCheckedModeBanner: false, // Quita la etiqueta de "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Definimos la pantalla inicial
      home: const LoginScreen(), 
    );
  }
}