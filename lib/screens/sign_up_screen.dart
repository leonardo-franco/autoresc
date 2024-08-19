import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isPasswordFocused = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 6) strength += 20;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 20;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 20;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 20;
    if (password.length >= 12) strength += 20;
    return strength;
  }

  String _getStrengthText(int strength) {
    if (strength < 40) {
      return 'Fraca';
    } else if (strength < 80) {
      return 'Moderada';
    } else {
      return 'Forte';
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Criação do usuário
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Enviar e-mail de verificação
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();

          Fluttertoast.showToast(
            msg: "Um link de verificação foi enviado para seu e-mail. Por favor, verifique-o.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // Desloga o usuário para que só possa logar após verificar o e-mail
          await FirebaseAuth.instance.signOut();
        }

        // Redirecionar ou fazer outra ação necessária
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          msg: e.message ?? "Erro ao cadastrar usuário.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: "Você deve aceitar os termos e permissões.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Campo de Nome
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value!.isEmpty ? 'Nome é obrigatório' : null,
                ),
                const SizedBox(height: 20),
                // Campo de Sobrenome
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: 'Sobrenome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value!.isEmpty ? 'Sobrenome é obrigatório' : null,
                ),
                const SizedBox(height: 20),
                // Campo de Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value!.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value) ? 'Email inválido' : null,
                ),
                const SizedBox(height: 20),
                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => value!.isEmpty || value.length < 6 ? 'Senha deve ter pelo menos 6 caracteres' : null,
                  onChanged: (value) {
                    setState(() {
                      _isPasswordFocused = value.isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 10),
                // Indicador de Força da Senha (exibido apenas se o usuário começar a digitar)
                if (_isPasswordFocused) ...[
                  LinearProgressIndicator(
                    value: _calculatePasswordStrength(_passwordController.text) / 100,
                    color: _calculatePasswordStrength(_passwordController.text) < 40
                        ? Colors.red
                        : (_calculatePasswordStrength(_passwordController.text) < 80
                            ? Colors.orange
                            : Colors.green),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _getStrengthText(_calculatePasswordStrength(_passwordController.text)),
                    style: TextStyle(
                      color: _calculatePasswordStrength(_passwordController.text) < 40
                          ? Colors.red
                          : (_calculatePasswordStrength(_passwordController.text) < 80
                              ? Colors.orange
                              : Colors.green),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Campo de Confirmar Senha
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => value != _passwordController.text ? 'Senhas não conferem' : null,
                ),
                const SizedBox(height: 20),
                // Checkbox de Termos e Condições
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Aqui você pode adicionar a navegação para a tela de termos e condições
                        },
                        child: const Text(
                          'Aceito os termos e condições',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Botão de Cadastro
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
