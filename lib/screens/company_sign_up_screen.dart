// ignore_for_file: unused_local_variable

import 'package:autoresc/screens/terms_conditions_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

bool validateCNPJ(String cnpj) {
  // Remove caracteres não numéricos
  cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

  if (cnpj.length != 14) return false;

  int v1 = 0, v2 = 0;

  // Primeiro dígito verificador
  for (int i = 0, j = 5; i < 12; i++, j--) {
    if (j < 2) j = 9;
    v1 += int.parse(cnpj[i]) * j;
  }

  v1 = (v1 % 11 < 2) ? 0 : 11 - (v1 % 11);

  // Segundo dígito verificador
  for (int i = 0, j = 6; i < 13; i++, j--) {
    if (j < 2) j = 9;
    v2 += int.parse(cnpj[i]) * j;
  }

  v2 = (v2 % 11 < 2) ? 0 : 11 - (v2 % 11);

  return v1 == int.parse(cnpj[12]) && v2 == int.parse(cnpj[13]);
}

class CompanySignupScreen extends StatefulWidget {
  const CompanySignupScreen({super.key});

  @override
  _CompanySignupScreenState createState() => _CompanySignupScreenState();
}

class _CompanySignupScreenState extends State<CompanySignupScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final MaskedTextController _cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final TextEditingController _addressController = TextEditingController();
  final MaskedTextController _phoneController = MaskedTextController(mask: '(00) 00000-0000');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> companyData = {};
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  File? _selectedImage;
  String? _imageUrl;

  @override
  void dispose() {
    _companyNameController.dispose();
    _cnpjController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      Fluttertoast.showToast(
        msg: "Nenhuma foto selecionada.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('company_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = imageRef.putFile(_selectedImage!);

      final snapshot = await uploadTask.whenComplete(() {});
      _imageUrl = await snapshot.ref.getDownloadURL();

      // Atualizar o Firestore com a URL da imagem
      await FirebaseFirestore.instance.collection('companies').doc(companyData['id']).update({
        'licenseUrl': _imageUrl,
      });
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Adicionar a empresa ao Firestore com licenseUrl como string vazia
        final companyRef = await FirebaseFirestore.instance.collection('companies').add({
          'companyName': _companyNameController.text.trim(),
          'cnpj': _cnpjController.text.trim(),
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'licenseUrl': '',  // Inicialize com string vazia
        });

        // Atualizar o companyData com o ID do documento
        companyData = {
          'id': companyRef.id,
          'companyName': _companyNameController.text.trim(),
          'cnpj': _cnpjController.text.trim(),
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'licenseUrl': '',  // Inicialize com string vazia
        };

        // Fazer o upload da imagem e atualizar o Firestore com a URL
        await _uploadImage();

        Fluttertoast.showToast(
          msg: "Cadastro realizado com sucesso!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

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
        title: const Text('Cadastro de Empresa'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Campo de Nome da Empresa
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    labelText: 'Nome da Empresa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.business),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value!.isEmpty ? 'Nome da empresa é obrigatório' : null,
                ),
                const SizedBox(height: 20),
                // Campo de CNPJ
                TextFormField(
                  controller: _cnpjController,
                  decoration: InputDecoration(
                    labelText: 'CNPJ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.assignment),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    value = value!.trim();
                    if (value.isEmpty) {
                      return 'CNPJ é obrigatório';
                    } else if (value.length != 18) {
                      return 'CNPJ inválido';
                    } else if (!validateCNPJ(value)) {
                      return 'CNPJ inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Campo de Endereço
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Endereço',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value!.isEmpty ? 'Endereço é obrigatório' : null,
                ),
                const SizedBox(height: 20),
                // Campo de Telefone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value!.isEmpty || value.length != 15 ? 'Telefone inválido' : null,
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
                  textInputAction: TextInputAction.next,
                  validator: (value) => value!.isEmpty || value.length < 6 ? 'Senha deve ter pelo menos 6 caracteres' : null,
                ),
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
                  textInputAction: TextInputAction.done,
                  validator: (value) => value != _passwordController.text ? 'Senhas não coincidem' : null,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Foto de sua CNH',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Botão para selecionar imagem
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Selecionar Imagem',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // Visualização da Imagem Selecionada
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 20),
                // Aceitar termos e condições
                CheckboxListTile(
                  title: Row(
                    children: [
                      const Text('Li e aceito os '),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TermsConditionsScreen(),
                            )
                          );
                        },
                        child: const Text(
                          'Termos e condições',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline
                          ),
                        ),
                      ),
                    ],
                  ),
                  value: _acceptedTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Botão de Cadastro
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
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
                            'Cadastrar',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 50)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
