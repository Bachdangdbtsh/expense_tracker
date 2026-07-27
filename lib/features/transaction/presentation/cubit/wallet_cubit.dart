import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/transaction/domain/financial_manager.dart';
import 'package:expense_tracker/features/transaction/domain/master_wallet.dart';
import 'package:expense_tracker/core/errors/financial_manager_exceptions.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletStates> {
  final FinancialManager _manager;
  late MasterVault _masterVault;

  WalletCubit(this._manager) : super(WalletInitial());

  // 1. Khoi tao app va loadData
  Future<void> loadInitialData() async {
    emit(WalletLoading());
    try {
      final vault = await _manager.initData();

      if (vault != null) {
        _masterVault = vault;
      } else {
        _masterVault = MasterVault(
          accountID: "Unknown", 
          ownerName: "Unknown", 
          totalBalance: 0,
        );
      }

      // Tính toán thống kê ngay khi tải dữ liệu thành công
      final stat = _manager.financialStatistic(_masterVault);

      emit(WalletLoaded(
        vault: _masterVault,
        walletList: List.from(_manager.wallet),
        statistic: stat,
      ));
    } catch (error) {
      emit(WalletError(message: "Khong the nap du lieu: ${error.toString()}"));
    }
  }

  Future<void> createWallet({
    required String name, 
    required String category,
    required int balance,
  }) async {
    try {
      await _manager.createWallet(_masterVault, name, category, balance);

      emit(WalletLoaded(
        vault: _masterVault,
        walletList: List.from(_manager.wallet),
        statistic: _manager.financialStatistic(_masterVault),
      ));
    } on FinancialManagerExceptions catch (error) {
      emit(WalletError(message: error.toString()));
    } catch (error) {
      emit(WalletError(message: "Loi chua xac dinh (createWallet)!"));
    }
  }

  Future<void> deleteWallet({ required String deleteID }) async {
    try {
      await _manager.deleteWallet(_masterVault, deleteID);
      
      emit(WalletLoaded(
        vault: _masterVault,
        walletList: List.from(_manager.wallet),
        statistic: _manager.financialStatistic(_masterVault),
      ));
    } on FinancialManagerExceptions catch (error) {
      emit(WalletError(message: error.toString()));
    } catch (error) {
      emit(WalletError(message: "Loi chua xac dinh (deleteWallet)"));
    }
  }

  Future<void> transferMoney({
    required String fromWalletID,
    required String toWalletID,
    required int amount,
    required String description,
  }) async {
    try {
      await _manager.transferMoney(_masterVault, fromWalletID, toWalletID, amount, description);

      emit(WalletLoaded(
        vault: _masterVault,
        walletList: List.from(_manager.wallet),
        statistic: _manager.financialStatistic(_masterVault),
      ));
    } on FinancialManagerExceptions catch (error) {
      emit(WalletError(message: error.toString()));
    } catch (error) {
      emit(WalletError(message: "Loi chua xac dinh (transferMoney)"));
    }
  }

  Future<void> updateMasterVaultInfo({
    required String ownerName,
    required int initialBalance,
  }) async {
    try {
      await _manager.updateMasterVaultInfo(_masterVault, ownerName, initialBalance);

      emit(WalletLoaded(
        vault: _masterVault,
        walletList: List.from(_manager.wallet),
        statistic: _manager.financialStatistic(_masterVault),
      ));
    } on FinancialManagerExceptions catch (error) {
      emit(WalletError(message: error.toString()));
    } catch (error) {
      emit(WalletError(message: "Loi chua xac dinh (updateMasterVault)"));
    }
  }

  // Hàm thủ công để lấy / làm mới thống kê khi cần
  void getStatistic() {
    try {
      final stat = _manager.financialStatistic(_masterVault); 
      emit(WalletLoaded(
        vault: _masterVault,
        walletList: List.from(_manager.wallet), 
        statistic: stat,
      ));
    } on FinancialManagerExceptions catch (error) {
      emit(WalletError(message: error.toString())); 
    }
  }
}