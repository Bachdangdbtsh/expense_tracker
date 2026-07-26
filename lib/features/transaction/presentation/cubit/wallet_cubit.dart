
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/transaction/domain/financial_manager.dart';
import 'package:expense_tracker/features/transaction/domain/master_wallet.dart';
import 'package:expense_tracker/core/errors/financial_manager_exceptions.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletStates>{
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
        emit(WalletLoaded(
          vault: _masterVault,
          walletList: List.from(_manager.wallet)
        ));
      }
      else {
        _masterVault = MasterVault(
          accountID: "Unknown", 
          ownerName: "Unknown", 
          totalBalance: 0
        );
        emit(WalletLoaded(
          vault: _masterVault,
          walletList: List.from(_manager.wallet)
        ));
      }
    }
    catch(error) {
      emit(WalletError(message: "Khong the nap du lieu: ${error.toString()}"));
    }
  }
  
  Future<void> createWallet({
    required String name, 
    required String category,
    required int balance
  }) async {
    try {
      await _manager.createWallet(_masterVault, name, category, balance);

      emit(WalletLoaded(
        vault: _masterVault,
        walletList: List.from(_manager.wallet))
      );
    } 
    on FinancialManagerExceptions catch (e) {
      emit(WalletError(message: e.toString()));
    } catch (e) {
      emit(WalletError(message: "Loi hanh vi chua xac dinh!"));
    }
  }
}