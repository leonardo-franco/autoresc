import 'package:autoresc/screens/company_sign_up_screen.dart';
import 'package:autoresc/screens/login_screen.dart';
import 'package:autoresc/screens/select_segment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class CompanyLoginScreen extends StatefulWidget {
  const CompanyLoginScreen({super.key});

  @override
  _CompanyLoginScreenState createState() => _CompanyLoginScreenState();
}

class _CompanyLoginScreenState extends State<CompanyLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isUser = false; // Variável para controlar o estado do toggle
  bool _obscurePassword = true;

  // Variáveis de controle para erros
  bool _isEmailInvalid = false;
  bool _isPasswordInvalid = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _isEmailInvalid = false;
      _isPasswordInvalid = false;
      _errorMessage = '';
    });

    try {
      // Autenticar com Firebase usando email e senha
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        // Buscar o documento da empresa pelo email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot companyDoc = querySnapshot.docs.first;

          // Verificar se o campo 'segment' já existe
          if ((companyDoc.data() as Map<String, dynamic>).containsKey('segment')) {
            // Navegar para a tela principal se o campo 'segment' já existir
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            // Navegar para a tela de seleção de segmento se o campo 'segment' não existir
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SelectSegmentScreen()),
            );
          }
        } else {
          // Documento não encontrado, navegue para a tela de seleção de segmento
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SelectSegmentScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = 'Dados inválidos';
        _isEmailInvalid = true;
        _isPasswordInvalid = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado: $e';
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                        errorText: _isEmailInvalid ? 'Dados inválidos' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _isEmailInvalid ? Colors.red : Colors.grey,
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
                        errorText: _isPasswordInvalid ? 'Dados inválidos' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _isPasswordInvalid ? Colors.red : Colors.grey,
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
                                    const CompanySignupScreen(),
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
                    const SizedBox(height: 10),

                    // Esqueceu a senha
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        'Esqueceu sua senha?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
