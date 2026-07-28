import 'package:expense_tracker/features/wallet/domain/mp_wallet.dart';
import 'package:expense_tracker/features/wallet/domain/master_wallet.dart';
import 'package:expense_tracker/features/wallet/domain/financial_statistic.dart';
abstract class WalletStates {}

class WalletInitial extends WalletStates {}
class WalletLoading extends WalletStates {}

class WalletLoaded extends WalletStates {
  final MasterVault vault;
  final List<Wallet> walletList;
  final FinancialStatistic? statistic;

  WalletLoaded({
    required this.vault,
    required this.walletList,
    this.statistic
  });
}
class WalletError extends WalletStates {
  final String message;

  WalletError({required this.message});
}
