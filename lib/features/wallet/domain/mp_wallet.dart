import 'dart:developer' as dev;

import 'package:expense_tracker/core/errors/financial_manager_exceptions.dart';
class Wallet {
  final String id;  // ID duy nhat cua 1 vi (1 vi = 1 muc dich tieu dung) 
  String category;  // muc dich su dung vi
  int balance;  // so du tai khoan (vnd)
  bool isActive; // trang thai hoat dong cua vi

  // Default constructor
  Wallet({
      required this.id,
      required this.category, 
      required this.balance,
      required this.isActive
    }
  );

  bool canWithdraw(int amount) {
    return isActive && amount <= balance;
  }

  void withdraw(int amount) {
    if (canWithdraw(amount)) {
      balance -= amount;
      dev.log(
        '(Wallet ID: $id): Rut $amount VND thanh cong!\nCurrent balance: $balance',
        name: 'WALLET::WITHDRAW'
      );
    } 
    else {
      throw ExceedBalanceException();
    }
  }

  void deposit(int amount) {
    if (isActive) {
      balance += amount;
      dev.log(
        '(WalleT\'s ID: $id): Nap $amount VND thanh cong! \nCurrent balance: $balance',
        name: 'WALLET::WITHDRAW'
      );
    } 
    else {
      throw InactiveWalletException();
    }
  }

  // Cac phuong thuc Serialization / Deserialization JSON

  // Serialization (Ma hoa tu Map sang JSON)
  Map<String, dynamic> toMap() {
    return {
      'wallet_id' : id,
      'category'  : category,
      'balance'   : balance,
      'isActive'  : isActive
    };
  }
  // Deserialization (Giai ma tu JSON sang Map)
  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['wallet_id'] as String,
      category: map['category'] as String,
      balance: map['balance'] as int,
      isActive: map['isActive'] as bool
    );
  }
}