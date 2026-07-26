import 'package:expense_tracker/features/transaction/domain/mp_wallet.dart';
import 'package:expense_tracker/features/transaction/domain/master_wallet.dart';

abstract class WalletStates {}

class WalletInitial extends WalletStates {}
class WalletLoading extends WalletStates {}

class WalletLoaded extends WalletStates {
  final MasterVault vault;
  final List<Wallet> walletList;

  WalletLoaded({
    required this.vault,
    required this.walletList
  });
}
class WalletError extends WalletStates {
  final String message;

  WalletError({required this.message});
}
