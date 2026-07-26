import 'package:expense_tracker/features/transaction/domain/master_wallet.dart';

abstract class PhoneServiceStates {}

class PhoneServiceInitial extends PhoneServiceStates {}

class PhoneServiceLoading extends PhoneServiceStates {}

class PhoneServiceLoaded extends PhoneServiceStates {
  final MasterVault vault;

  PhoneServiceLoaded({
    required this.vault
  });
}

class PhoneServiceError extends PhoneServiceStates {
  final String message;

  PhoneServiceError({required this.message});
}