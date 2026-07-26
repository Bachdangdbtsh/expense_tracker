import 'package:expense_tracker/features/transaction/presentation/cubit/phone_service_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/transaction/domain/financial_manager.dart';
import 'package:expense_tracker/features/transaction/domain/mobile_data.dart';
import 'package:expense_tracker/features/transaction/domain/master_wallet.dart';
import 'package:expense_tracker/core/errors/financial_manager_exceptions.dart';

class PhoneServiceCubit extends Cubit<PhoneServiceStates>{
  final MasterVault _masterVault;
  final FinancialManager _manager;

PhoneServiceCubit({
  required this._masterVault,
  required this._manager,
}) : super(PhoneServiceInitial());

  Future<void> topUpPhoneCredit({
    required String fromWalletID,
    required int amount,
    required String phoneNumber
  }) async {
    try {
      await _manager.topUpPhoneCredit(_masterVault, fromWalletID, amount, phoneNumber);

      emit(PhoneServiceLoaded( vault: _masterVault));
    } on FinancialManagerExceptions catch (error) {
      emit(PhoneServiceError(message: error.toString()));
    } catch (error) {
      emit(PhoneServiceError(message: "Loi chua xac dinh (topUp)!"));
    }
  }

  Future<void> purchaseMobileData({
    required String fromWalletID,
    required InternetServiceProvider isp, 
    required String mobileDataplan,
    required String phoneNumber
  }) async {
    try {
      await _manager.purchaseMobileData(_masterVault, fromWalletID, isp, mobileDataplan, phoneNumber);

      emit(PhoneServiceLoaded( vault: _masterVault));
    } on FinancialManagerExceptions catch (error) {
      emit(PhoneServiceError(message: error.toString()));
    } catch (error) {
      emit(PhoneServiceError(message: "Loi chua xac dinh (purchaseMobileData)!"));
    }
  }

}