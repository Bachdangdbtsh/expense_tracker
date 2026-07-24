// Thuc hien tat ca cac thao tac: Chuyen tien, nhan tien, luan chuyen giua cac wallet
import 'dart:developer' as dev;

enum TransactionType {
  expense,
  income, 
  transfer
}
class TransactionModel {
  final int id;
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
}