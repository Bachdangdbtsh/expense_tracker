import 'package:expense_tracker/features/transaction/domain/mobile_data.dart';
import 'package:expense_tracker/features/transaction/domain/mp_wallet.dart';
import 'package:expense_tracker/features/transaction/domain/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/master_wallet.dart';

class FinancialManager {
  final List<Wallet> _walletLists = [];
  final List<TransactionModel> _transactionHistory = [];

  // Getters
  List<Wallet> get wallet => _walletLists;
  List<TransactionModel> get transHistory => _transactionHistory;
  

  //--------------------------------------------------------------------------//
  // Cac thao tac tao, xoa, in danh sach cua walletList va transactionHistory //
  //--------------------------------------------------------------------------//

  bool createWallet(MasterVault vault, String newName, String newCategory, int initialBalance) {
    bool duplicateCategory = _walletLists.any((wallet) => wallet.category == newCategory);
    if (duplicateCategory) {
      print("[FINANCIAL_MANAGER::CREATE_WALLET] Vi co ten $newCategory da ton tai!");
      return false;
    }

    // Kiem tra tong ngan sach cua _walletList co vuot qua totalBalance cua Master account hay khong
    int currentTotalAllocated = _walletLists.fold(0, (sum, w) => sum + w.balance);
    if (!vault.canAllocate(initialBalance, currentTotalAllocated)) {
      print("[FINANCIAL_MANAGER::CREATE_WALLET::ERROR] Khong the tao vi! Tong ngan sach phan bo se vuot qua han muc Tai khoan chinh!");
      return false;
    }

    final newWallet = Wallet(
      id: DateTime.now().millisecondsSinceEpoch,
      category: newName,
      balance: initialBalance,
      isActive:  true
    );
    _walletLists.add(newWallet);

    print("[FINANCIAL_MANAGER::CREATE_WALLET] Khoi tao vi $newCategory, ID: ${newWallet.id} thanh cong!");
    return true;
  }

  void deleteWallet(int deleteID) {
    int index = searchWalletIndex(deleteID);
    if (index != -1) {
      print("[FINANCIAL_MANAGER::DELETE_WALLET] Xoa vi ${_walletLists[index].category}, ID: ${_walletLists[index].id} thanh cong!");
      _walletLists.removeAt(index);
    } else {
      print ("[FINANCIAL_MANAGER::DELETE_WALLET] Vi co ten ${_walletLists[index].category} khong ton tai!");
    }
  }

  void showWalletList() 
  {
    if (_walletLists.isEmpty) {
      print("(Danh sach trong!)");
    }
    print("DANH SACH VI CUA BAN");
    for (Wallet wallet in _walletLists) {
      wallet.showWalletInfo();
    }
  }

  void showTransactionHistory() 
  {
    if (_transactionHistory.isEmpty) {
      print("(Danh sach trong!)");
    }
    print("LICH SU GIAO DICH:");
    for (TransactionModel trans in _transactionHistory) {
      trans.showTransactionInfo();
    }
  }
 
  void updateMasterVaultInfo(MasterVault motherVault, String ownerName, int initialBalance) {
    motherVault.ownerName = ownerName;
    motherVault.totalBalance = initialBalance;
    print("[FINANCIAL_MANAGER::MASTER_VAULT] Cap nhat thong tin Tai khoan chinh thanh cong!");

    print("ID Tai khoan chinh: ${motherVault.accountID}");
    print("Ten chu so huu: ${motherVault.ownerName}");
    print("Tong han muc tai khoan: ${motherVault.totalBalance}");

  }
  //----------------------------------------------------------------------------//
  // Cac phuong thuc nghiep vu: Giao dich, kiem ke, dich vu
  //----------------------------------------------------------------------------//

  bool transferMoney(int fromWalletID, int toWalletID, int amount, String description) {
    int fromIndex = searchWalletIndex(fromWalletID);
    int toIndex = searchWalletIndex(toWalletID);

    if (fromIndex == -1 || toIndex == -1) {
      print("[FINANCIAL_MANAGER::TRANSFER] Giao dich that bai. Khong tim thay ID vi nguon hoac vi dich!");
      return false;
    }

    final Wallet fromWallet = _walletLists[fromIndex];
    final Wallet toWallet = _walletLists[toIndex];

    if (!fromWallet.canWithdraw(amount)) {
      print("[FINANCIAL_MANAGER::TRANSFER] Giao dich that bai do STK nguon khong du so du!");
      return false;
    }

    final TransactionModel transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch,
      type: TransactionType.transfer,
      category: "Giao dich chuyen tien",
      fromWalletId: fromWalletID.toString(),
      toWalletId: toWalletID.toString(),
      amount: amount,
      description: description,
      dateTime: DateTime.now()
    );

    fromWallet.withdraw(amount);
    toWallet.deposit(amount);
    _transactionHistory.add(transaction);
    print("[FINANCIAL_MANAGER::TRANSFER] Chuyen $amount VND tu vi ${fromWallet.category} sang vi ${toWallet.category} thanh cong!");
    return true;
  }

  bool topUpPhoneCredit(int fromWalletID, int amount, String phoneNumber) {
    if (!isValidVietnamesePhoneCredit(phoneNumber)) {
      print("[FINANCIAL::PHONE_TOPUP] So thue bao $phoneNumber khong hop le de nap tien!");
      return false;
    }
    
    int fromIndex = searchWalletIndex(fromWalletID);

    if (fromIndex == -1 ) {
      print("[FINANCIAL_MANAGER::PHONE_TOPUP] Giao dich that bai. Khong tim thay ID vi nguon!");
      return false;
    }

    final Wallet fromWallet = _walletLists[fromIndex];
    if (!fromWallet.canWithdraw(amount)) {
      print("[FINANCIAL_MANAGER::PHONE_TOPUP] Nap tien that bai do so du vi khong du!");
      return false;
    }
    final TransactionModel transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch,
      type: TransactionType.expense,
      category: "Nap tien dien thoai",
      fromWalletId: fromWalletID.toString(),
      amount: amount,
      description: "Nap $amount VND cho thue bao $phoneNumber",
      dateTime: DateTime.now()
    );

    fromWallet.withdraw(amount);
    _transactionHistory.add(transaction);
    print("[FINANCIAL_MANAGER::PHONE_TOPUP] Nap $amount VND cho so $phoneNumber thanh cong tu vi ${fromWallet.category}!");
    return true;
  }
  
  bool purchaseMobileData(int fromWalletID, InternetServiceProvider isp, String mobileDataplan, String phoneNumber) {
    int fromIndex = searchWalletIndex(fromWalletID);

    if (fromIndex == -1 ) {
      print("[FINANCIAL_MANAGER::MOBILE_DATA] Giao dich that bai. Khong tim thay ID vi nguon!");
      return false;
    }

    final Wallet fromWallet = _walletLists[fromIndex];
    
    // Tim gia tien ung voi goi cuoc mobileDataplan
    int? amount = commonMobileDataPlan[mobileDataplan];
    if (amount == null) {
      print("[FINANCIAL_MANAGER::MOBILE_DATA] Goi cuoc data $mobileDataplan khong kha dung!");
      return false;
    }

    if (!fromWallet.canWithdraw(amount)) {
      print("[FINANCIAL_MANAGER::MOBILE_DATA] Mua goi cuoc that bai do so du vi khong du!");
      return false;
    }

    final TransactionModel transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch,
      type: TransactionType.expense,
      category: "Mua goi cuoc Data",
      fromWalletId: fromWalletID.toString(),
      amount: amount,
      description: "Mua goi cuoc Data ${isp.name.toUpperCase()} $mobileDataplan voi gia $amount VND cho thue bao $phoneNumber thanh cong!",
      dateTime: DateTime.now()
    );

    fromWallet.withdraw(amount);
    _transactionHistory.add(transaction);
    print("[FINANCIAL_MANAGER::MOBILE_DATA] Mua goi cuoc data $mobileDataplan tri gia $amount VND cho thue bao $phoneNumber thanh cong!");
    return true;
  }
  
  void financialStatistic(MasterVault vault) {

    bool isSystemHealthy = validateSystemIntegrity(vault);
    print("\n=============================================");
    print("          THONG KE TAI CHINH TOAN CUC       ");
    print("=============================================");

    print(" Trang thai tai khoan: ${isSystemHealthy ? "Can doi" : "Vuot han muc"}");
    print(" Tong so tien Tai khoan chinh: ${vault.totalBalance} VND");

    // Tinh tong tien trong _walletList
    int totalAllocated = _walletLists.fold(0, (sum, w) => sum + w.balance);
    print(" Tong so tien da phan bo vao cac Vi: $totalAllocated VND");
    print(" Han muc con trong co the cap phat: ${vault.totalBalance - totalAllocated} VND");
    print("---------------------------------------------");

    // 2. Tinh tong thu / tong chi / thong ke hang muc chi tieu
    int totalIncome = 0;
    int totalExpense = 0;
    Map<String, int> expenseByCategory = {};

    for (var trans in _transactionHistory) {
      if (trans.type == TransactionType.income) {
        totalIncome += trans.amount;
      } else if (trans.type == TransactionType.expense) {
        totalExpense += trans.amount;
        
        // Gom nhom tien theo category
        expenseByCategory[trans.category] = 
            (expenseByCategory[trans.category] ?? 0) + trans.amount;
      }
    }

    print(" Tong dong tien thu nhap: +$totalIncome VND");
    print(" Tong dong tien chi tieu: -$totalExpense VND");
    print("---------------------------------------------");
    print(" CHI TIET CHI TIEU THEO HANG MUC:");
    
    if (expenseByCategory.isEmpty) {
      print(" Chua co du lieu nao!");
    } 
    else {
      expenseByCategory.forEach((category, amount) {
        // Tinh phan tram dong gop cua tung hang muc
        double percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0;
        print("  + $category: $amount VND (${percentage.toStringAsFixed(1)}%)");
      });
    }
    print("=============================================\n");
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

  bool isValidVietnamesePhoneCredit(String phoneNumber) {
    final RegExp phoneRegExp = RegExp(r'^(03|05|07|08|09)\d{8}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  bool validateSystemIntegrity(MasterVault vault) {
  int totalInSubWallets = _walletLists.fold(0, (sum, w) => sum + w.balance);
  
  // Tổng tiền trong các ví chi tiêu KHÔNG ĐƯỢC VƯỢT QUÁ tổng tiền Ví Mẹ
  if (totalInSubWallets > vault.totalBalance) {
    print("[CRITICAL ERROR] Tổng tiền các ví phụ ($totalInSubWallets) vượt quá Tài khoản chính (${vault.totalBalance})!");
    return false;
  }
  return true;
}
}