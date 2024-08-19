import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class CompanyProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<String> _companyNames = [];

  List<String> get companyNames => _companyNames;

  Future<void> fetchCompanyNames() async {
    _companyNames = await _firestoreService.getCompanyNames();
    notifyListeners();
  }
}
