// Thuc hien tat ca cac thao tac: Chuyen tien, nhan tien, luan chuyen giua cac wallet

enum TransactionType {
  expense,
  income, 
  transfer
}
class TransactionModel {
  final String id;
  final TransactionType type;
  final String category;
  final String? fromWalletId;
  final String? toWalletId;
  final int amount;
  final String description;
  final DateTime dateTime;

  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    this.fromWalletId,
    this.toWalletId,
    required this.amount,
    required this.description,
    required this.dateTime
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'category': category,
      'fromWalletId': fromWalletId,
      'toWalletId':  toWalletId,
      'amount': amount,
      'description': description,
      'dateTime': dateTime.toIso8601String()
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      type: TransactionType.values.byName(map['type'] as String),
      category: map['category'] as String,
      fromWalletId: map['fromWalletId'] as String?,
      toWalletId: map['toWalletId'] as String?,
      amount: map['amount'] as int,
      description: map['description'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String)
    );
  }
}