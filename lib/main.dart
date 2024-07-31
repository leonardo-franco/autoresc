import 'package:flutter/material.dart';
import 'screens/login_screen.dart';  // Importa o arquivo da tela de login

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),  // Define a tela de login como a tela inicial
      debugShowCheckedModeBanner: false,  // Remove a marca d'água de debug
    );
  }
}
