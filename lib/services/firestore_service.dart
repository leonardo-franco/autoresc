import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<String>> getCompanyNames() async {
    List<String> companyNames = [];
    try {
      QuerySnapshot snapshot = await _db.collection('companies').get();
      for (var doc in snapshot.docs) {
        companyNames.add(doc['companyName']);
      }
    } catch (e) {
      print('Erro ao buscar nomes das empresas: $e');
    }
    return companyNames;
  }
}
