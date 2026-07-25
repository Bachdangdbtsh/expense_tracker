import 'package:expense_tracker/core/errors/financial_manager_exceptions.dart';
import 'package:expense_tracker/core/utils/local_storage_service.dart';
import 'package:expense_tracker/features/transaction/domain/financial_statistic.dart';
import 'package:expense_tracker/features/transaction/domain/mobile_data.dart';
import 'package:expense_tracker/features/transaction/domain/mp_wallet.dart';
import 'package:expense_tracker/features/transaction/domain/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/master_wallet.dart';
import 'dart:developer' as dev;

class FinancialManager {
  final List<Wallet> _walletLists = [];
  final List<TransactionModel> _transactionHistory = [];
  final LocalStorageService _storageService = LocalStorageService();

  // Getters
  List<Wallet> get wallet => _walletLists;
  List<TransactionModel> get transHistory => _transactionHistory;

  Future<MasterVault?> initData() async {
    final data = await _storageService.loadData();
    if (data == null) return null; // App mới chưa có dữ liệu

    // ap lai danh sach vi
    _walletLists.clear();
    final List<dynamic> walletsJson = data['wallets'];
    for (var item in walletsJson) {
      _walletLists.add(Wallet.fromMap(item));
    }

    // Nap lai lich su giao dich
    _transactionHistory.clear();
    final List<dynamic> transJson = data['transactions'];
    for (var item in transJson) {
      _transactionHistory.add(TransactionModel.fromMap(item));
    }

    // Nạp lại Master Vault
    return MasterVault.fromMap(data['masterVault']);
  }

  // 2. Hàm hỗ trợ lưu State hiện tại xuống ổ cứng
  Future<void> _autoSave(MasterVault vault) async {
    await _storageService.saveData(
      masterVaultMap: vault.toMap(),
      walletListMaps: _walletLists.map((w) => w.toMap()).toList(),
      transactionListMaps: _transactionHistory.map((t) => t.toMap()).toList(),
    );
  }
  

  //--------------------------------------------------------------------------//
  // Cac thao tac tao, xoa, in danh sach cua walletList va transactionHistory //
  //--------------------------------------------------------------------------//

  Future<bool> createWallet(MasterVault vault, String newName, String newCategory, int initialBalance) async{
    bool duplicateCategory = _walletLists.any((wallet) => wallet.category == newCategory);
    if (duplicateCategory) {
      throw WalletExistedException();
    }

    // Kiem tra tong ngan sach cua _walletList co vuot qua totalBalance cua Master account hay khong
    int currentTotalAllocated = _walletLists.fold(0, (sum, w) => sum + w.balance);
    if (!vault.canAllocate(initialBalance, currentTotalAllocated)) {
      throw ExceedMasterVaultLimitException();
    }

    final newWallet = Wallet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: newName,
      balance: initialBalance,
      isActive:  true
    );
    _walletLists.add(newWallet);

    await _autoSave(vault);
    dev.log(
      'Khoi tao vi $newCategory, ID: ${newWallet.id} thanh cong!',
      name: 'FINANCIAL_MANAGER::CREATE_WALLET'
    );
    return true;
  }

  Future<void> deleteWallet(MasterVault vault,  deleteID) async {
    int index = searchWalletIndex(deleteID);
    if (index != -1) {
      dev.log(
        'Xoa vi ${_walletLists[index].category}, ID: ${_walletLists[index].id} thanh cong!',
        name: 'FINANCIAL_MANAGER::DELETE_WALLET'
      );
      _walletLists.removeAt(index);
      await _autoSave(vault);

    } 
    else {
      throw WalletNotFoundException();
    }
  }
 
  Future<void> updateMasterVaultInfo(MasterVault motherVault, String ownerName, int initialBalance) async{
    motherVault.ownerName = ownerName;
    motherVault.totalBalance = initialBalance;
    dev.log(
      'Cap nhat thong tin Tai khoan chinh thanh cong!',
      name: 'FINANCIAL_MANAGER::MASTER_VAULT'
    );

    await _autoSave(motherVault);
    dev.log(
      'ID Tai khoan chinh: ${motherVault.accountID} \n Ten chu so huu: ${motherVault.ownerName} \n Tong han muc tai khoan: ${motherVault.totalBalance}',
      name: 'FINANCIAL_MANAGER::MASTER_VAULT'
    );
  }

  //----------------------------------------------------------------------------//
  // Cac phuong thuc nghiep vu: Giao dich, kiem ke, dich vu
  //----------------------------------------------------------------------------//

  Future<bool> transferMoney(MasterVault vault, String fromWalletID, String toWalletID, int amount, String description) async{
    int fromIndex = searchWalletIndex(fromWalletID);
    int toIndex = searchWalletIndex(toWalletID);

    if (fromIndex == -1) throw WalletNotFoundException();
    if (toIndex == -1) throw WalletNotFoundException();

    final Wallet fromWallet = _walletLists[fromIndex];
    final Wallet toWallet = _walletLists[toIndex];

    if (!fromWallet.canWithdraw(amount)) {
      throw ExceedBalanceException();
    }

    final TransactionModel transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
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

    await _autoSave(vault);
    dev.log(
      'Chuyen $amount VND tu vi ${fromWallet.category} sang vi ${toWallet.category} thanh cong!',
      name: 'FINANCIAL_MANAGER::TRANSFER'
    );
    return true;
  }

  Future<bool> topUpPhoneCredit(MasterVault vault, String fromWalletID, int amount, String phoneNumber) async {
    if (!isValidVietnamesePhoneCredit(phoneNumber)) {
      throw PhoneNumberNotFoundException();
    }
    
    int fromIndex = searchWalletIndex(fromWalletID);
    if (fromIndex == -1 ) throw WalletNotFoundException();

    final Wallet fromWallet = _walletLists[fromIndex];
    if (!fromWallet.canWithdraw(amount)) throw ExceedBalanceException();

    final TransactionModel transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: TransactionType.expense,
      category: "Nap tien dien thoai",
      fromWalletId: fromWalletID.toString(),
      amount: amount,
      description: "Nap $amount VND cho thue bao $phoneNumber",
      dateTime: DateTime.now()
    );

    fromWallet.withdraw(amount);
    _transactionHistory.add(transaction);

    await _autoSave(vault);
    dev.log(
      'Nap $amount VND cho so $phoneNumber thanh cong tu vi ${fromWallet.category}!',
      name: 'FINANCIAL_MANAGER::TOPUP'
    );
    return true;
  }
  
  Future<bool> purchaseMobileData(MasterVault vault, String fromWalletID, InternetServiceProvider isp, String mobileDataplan, String phoneNumber) async {

    int fromIndex = searchWalletIndex(fromWalletID);
    if (fromIndex == -1 ) throw WalletNotFoundException();

    final Wallet fromWallet = _walletLists[fromIndex];
    
    // Tim gia tien ung voi goi cuoc mobileDataplan
    int? amount = commonMobileDataPlan[mobileDataplan];
    if (amount == null) throw InvalidDataPackageException();

    if (!fromWallet.canWithdraw(amount)) {
      throw ExceedBalanceException();
    }

    final TransactionModel transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: TransactionType.expense,
      category: "Mua goi cuoc Data",
      fromWalletId: fromWalletID.toString(),
      amount: amount,
      description: "Mua goi cuoc Data ${isp.name.toUpperCase()} $mobileDataplan voi gia $amount VND cho thue bao $phoneNumber thanh cong!",
      dateTime: DateTime.now()
    );

    fromWallet.withdraw(amount);
    _transactionHistory.add(transaction);

    await _autoSave(vault);
    dev.log(
      'Mua goi cuoc data $mobileDataplan tri gia $amount VND cho thue bao $phoneNumber thanh cong!',
      name: 'FINANCIAL_MANAGER::MOBILE_DATA'
    );
    return true;
  }
  
  FinancialStatistic financialStatistic(MasterVault vault) {
    bool accountCondition = validateSystemIntegrity(vault);
    int totalAllocated = _walletLists.fold(0, (sum, w) => sum + w.balance);
    int totalIncome = 0;
    int totalExpense = 0;
    Map<String, int> expenseSortedByCategory = {};

    for (var trans in _transactionHistory) {
      if (trans.type == TransactionType.income) {
        totalIncome += trans.amount;
      } 
      else if (trans.type == TransactionType.expense) {
        totalExpense += trans.amount;
        
        // Gom nhom tien theo category
        expenseSortedByCategory[trans.category] = (expenseSortedByCategory[trans.category] ?? 0) + trans.amount;
      }
    }
    
    return FinancialStatistic(
      isAccountSafe: accountCondition,
      totalMasterBalance: vault.totalBalance,
      totalAllocated: totalAllocated,
      remainingBudget: vault.totalBalance - totalAllocated,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      expenseByCategory: expenseSortedByCategory,
    );
  }

  
  //----------------------------------------------------------------------//
  // Cac ham phu tro (helper function)
  //----------------------------------------------------------------------//

  int searchWalletIndex(String targetID) {
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
    
    if (totalInSubWallets > vault.totalBalance) {
      throw ExceedMasterVaultLimitException();
    }
    return true;
  }
}