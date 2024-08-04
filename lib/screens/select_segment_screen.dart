import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class SelectSegmentScreen extends StatelessWidget {
  const SelectSegmentScreen({Key? key}) : super(key: key);

  Future<void> _selectSegment(BuildContext context, String segment) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Obter o email do usuário
        String email = user.email!;

        // Buscar o documento da empresa pelo email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Se o documento existir, atualize o documento
          DocumentReference companyRef = querySnapshot.docs.first.reference;
          await companyRef.update({
            'segment': segment,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Segmento selecionado com sucesso!')),
          );

          // Navegue para a tela principal ou de boas-vindas, por exemplo:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Se o documento não existir, crie um novo documento com o campo 'segment'
          DocumentReference companyRef = FirebaseFirestore.instance.collection('companies').doc(user.uid);
          await companyRef.set({
            'email': email,
            'segment': segment,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Segmento selecionado com sucesso!')),
          );

          // Navegue para a tela principal ou de boas-vindas, por exemplo:
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => const HomeScreen()),
          // );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar segmento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione seu Segmento'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => _selectSegment(context, 'tow_truck'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Guincho',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => _selectSegment(context, 'gas_station'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Gasolina',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => _selectSegment(context, 'locksmith'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Chaveiro',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
