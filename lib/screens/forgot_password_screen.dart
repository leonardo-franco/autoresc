// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Certifique-se de que o caminho está correto

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = 'Por favor, insira seu email.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Enviar o link de redefinição de senha
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        _message = 'Um link de redefinição de senha foi enviado para $email, se ele estiver registrado.';
      });
    } catch (e) {
      setState(() {
        _message = 'Erro ao enviar o link de redefinição: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white, // Cor da seta
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        title: const Text('Recuperar Senha'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
        backgroundColor: Colors.black, // Cor da barra de aplicativos
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Digite seu email para receber um link de recuperação de senha.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Enviar Link de Redefinição'),
                  ),
                  if (_message.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      _message,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
