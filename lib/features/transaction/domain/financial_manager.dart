import 'package:expense_tracker/features/transaction/domain/mp_wallet.dart';
import 'package:expense_tracker/features/transaction/domain/transaction.dart';

class FinancialManager {
  final List<Wallet> _walletLists = [];
  final List<TransactionModel> _transactionHistory = [];

  // Getters
  List<Wallet> get wallet => _walletLists;
  List<TransactionModel> get transHistory => _transactionHistory;
  

  //--------------------------------------------------------------------------//
  // Cac thao tac tao, xoa, in danh sach cua walletList va transactionHistory //
  //--------------------------------------------------------------------------//

  void createWallet(String newName, String newCategory, int initialBalance) {
    bool duplicateCategory = _walletLists.any((wallet) => wallet.category == newCategory);
    if (duplicateCategory) {
      print("[FINANCIAL_MANAGER::CREATE_WALLET] Vi co ten $newCategory da ton tai!");
      return;
    }
    final newWallet = Wallet(
      id: DateTime.now().millisecondsSinceEpoch,
      category: newName,
      balance: initialBalance,
      isActive:  true
    );
    _walletLists.add(newWallet);
    print("[FINANCIAL_MANAGER::CREATE_WALLET] Khoi tao vi $newCategory, ID: $newWallet.id thanh cong!");
  }

  void deleteWallet(int deleteID) {
    int index = searchWalletIndex(deleteID);
    if (index != -1) {
      _walletLists.removeAt(index);
      print("[FINANCIAL_MANAGER::DELETE_WALLET] Xoa vi ${_walletLists[index].category}, ID: ${_walletLists[index].id} da ton tai!");
    } else {
      print ("[FINANCIAL_MANAGER::DELETE_WALLET] Vi co ten ${_walletLists[index].category} da ton tai!");
    }
  }

  void showWalletList() 
  {
    print("DANH SACH VI CUA BAN");
    for (Wallet wallet in _walletLists) {
      wallet.showWalletInfo();
    }
  }

  void showTransactionHistory() 
  {
    print("LICH SU GIAO DICH:");
    for (TransactionModel trans in _transactionHistory) {
      trans.showTransactionInfo();
    }
  }
  //----------------------------------------------------------------------------//
  // Cac phuong thuc nghiep vu: Giao dich, kiem ke, dich vu
  //----------------------------------------------------------------------------//

  bool transferMoney(int fromWalletID, int toWalletID, int amount, String category, String description) {
    final Wallet fromWallet = _walletLists[searchWalletIndex(fromWalletID)];
    final Wallet toWallet = _walletLists[searchWalletIndex(toWalletID)];

    if (!fromWallet.canWithdraw(amount)) {
      print("[FINANCIAL_MANAGER::TRANSFER] Giao dich that bai do STK nguon khong du so du!");
      return false;
    }

    final TransactionModel transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch,
      type: TransactionType.transfer,
      category: category,
      amount: amount,
      description: description,
      dateTime: DateTime.now()
    );

    fromWallet.withdraw(amount);
    toWallet.deposit(amount);
    _transactionHistory.add(transaction);
    return true;
  }


  //----------------------------------------------------------------------//
  // Cac ham phu tro (helper function)
  //----------------------------------------------------------------------//

  int searchWalletIndex(int targetID) {
    int index = -1;
    for (int i = 0; i < _walletLists.length; i++) {
      if (_walletLists[i].id == targetID) {
        index = i;
        break;
      }
    }
    return index;
  }
}