import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'company_login_screen.dart'; // Importe a tela de login da empresa

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isUser = true; // Variável para controlar o estado do toggle

  // Variáveis para controlar o erro de login
  bool _hasLoginError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _hasLoginError = false;
    });

    try {
      // Autenticar com Firebase usando email e senha
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        // Se o email não estiver verificado, mostrar uma mensagem e deslogar o usuário
        await FirebaseAuth.instance.signOut();
        setState(() {
          _hasLoginError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, verifique seu e-mail antes de fazer login.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Navegar para a HomeScreen se o login for bem-sucedido e o e-mail estiver verificado
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _hasLoginError = true;
      });

      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado. Verifique seu email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta. Tente novamente.';
      } else {
        errorMessage = 'Erro ao realizar login: ${e.message}';
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(errorMessage)),
      // );
    } catch (e) {
      setState(() {
        _hasLoginError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Cabeçalho fixo com o logo
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 45.0), // Adiciona um padding se necessário
                child: Image.asset(
                  'assets/logo.png', // Caminho para o logo
                  width: 250, // Ajuste o tamanho conforme necessário
                  height: 250, // Ajuste o tamanho conforme necessário
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // Toggle entre "Sou Usuário" e "Sou Empresa"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey.shade300,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isUser = true;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: _isUser ? Colors.black : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    'Sou Usuário',
                                    style: TextStyle(
                                      color: _isUser ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isUser = false;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CompanyLoginScreen(),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: !_isUser ? Colors.black : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    'Sou Empresa',
                                    style: TextStyle(
                                      color: !_isUser ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    // Campo de Email
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: _hasLoginError ? 'Dados inválidos' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _hasLoginError ? Colors.red : Colors.grey,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 30),
                    // Campo de Senha
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        errorText: _hasLoginError ? 'Dados inválidos' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _hasLoginError ? Colors.red : Colors.grey,
                          ),
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
                    ),
                    const SizedBox(height: 30),
                    // Botão de Login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Ícones de login social
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google
                        IconButton(
                          icon: const Icon(
                            FontAwesome.google, // Ícone do Google
                            size: 40,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            // Implementar a lógica para login com Google
                          },
                        ),
                        const SizedBox(width: 20),
                        // Apple
                        IconButton(
                          icon: const Icon(
                            FontAwesome.apple, // Ícone da Apple
                            size: 40,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            // Implementar a lógica para login com Apple
                          },
                        ),
                        const SizedBox(width: 20),
                        // Facebook
                        IconButton(
                          icon: const Icon(
                            FontAwesome.facebook, // Ícone do Facebook
                            size: 40,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            // Implementar a lógica para login com Facebook
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Texto de Cadastro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Não tem uma conta? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const SignupScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end);
                                  var offsetAnimation =
                                      animation.drive(tween.chain(CurveTween(curve: curve)));
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                              ),
                            );
                          },
                          child: const Text(
                            'Cadastre-se',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Texto de Recuperação de Senha
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordScreen(), // Navegue para a tela de recuperação de senha
                          ),
                        );
                      },
                      child: const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
