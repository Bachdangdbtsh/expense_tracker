import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  static const String _fileName = "expense_data.json";

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
  
  // Ghi toan bo state (MasterVault, Wallets, Transactions) xuong File JSON
  Future<void> saveData({
    required Map<String, dynamic> masterVaultMap,
    required List<Map<String, dynamic>> walletListMaps,
    required List<Map<String, dynamic>> transactionListMaps,
  }) async {
    final file = await _getLocalFile();

    final Map<String, dynamic> fullData = {
      'masterVault': masterVaultMap,
      'wallets': walletListMaps,
      'transactions': transactionListMaps,
    };

    // jsonEncode() chuyen Map/List thanh chuoi JSON Text
    String jsonString = jsonEncode(fullData);
    await file.writeAsString(jsonString, flush: true);
  }

  // Doc du lieu tu File JSON khi mo app
  Future<Map<String, dynamic>?> loadData() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) return null;

      String jsonString = await file.readAsString();
      // jsonDecode() chuyển chuỗi JSON Text thành Map/List trong Dart
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}