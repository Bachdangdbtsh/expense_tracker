import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';

class DeleteWalletDialog extends StatelessWidget {
  final String walletId;
  final String walletName;
  final BuildContext parentContext;

  const DeleteWalletDialog({
    super.key,
    required this.walletId,
    required this.walletName,
    required this.parentContext
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Xác nhận xoá ví"),
      content: Text("Bạn có chắc chắn muốn xoá ví $walletName? (Không thể hoàn tác)"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text ("Huỷ")
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white
          ),
          onPressed: () {
            parentContext.read<WalletCubit>().deleteWallet(deleteID: walletId);
          }, 
          child: const Text("Xoá ví"))
      ],

    );
  }

}
