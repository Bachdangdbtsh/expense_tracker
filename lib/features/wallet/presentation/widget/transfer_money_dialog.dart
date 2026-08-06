import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/domain/mp_wallet.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';

class TransferMoneyDialog extends StatefulWidget {
  final Wallet sourceWallet;
  final List<Wallet> walletList;

  const TransferMoneyDialog({
    super.key,
    required this.sourceWallet,
    required this.walletList
  });

  @override
  State<TransferMoneyDialog> createState() => _TransferMoneyDialogState();
}

class _TransferMoneyDialogState extends State<TransferMoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String? _targetWalletId;

  @override
  void initState() {
    super.initState();
    final availableWallets = widget.walletList.where((wallet) => wallet.id != widget.sourceWallet.id).toList();
    if (availableWallets.isNotEmpty) {
      _targetWalletId = availableWallets.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitTransfer() {
    if (_formKey.currentState!.validate() && _targetWalletId != null) {
      final amount = int.parse(_amountController.text.trim());
      final description = _descController.text.trim().isEmpty
          ? "Chuyển tiền nội bộ"
          : _descController.text.trim();

      context.read<WalletCubit>().transferMoney(
            fromWalletID: widget.sourceWallet.id,
            toWalletID: _targetWalletId!,
            amount: amount,
            description: description,
          );

      Navigator.of(context).pop();
    }
  }


  @override 
  Widget build(BuildContext context) {
    final validTargets = widget.walletList.where((w) => w.id != widget.sourceWallet.id).toList();

    return AlertDialog(
      title: Text("Chuyển tiền từ ví ${widget.sourceWallet.category}"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chọn ví nhận
              DropdownButtonFormField<String>(
                initialValue: _targetWalletId,
                decoration: const InputDecoration(
                  labelText: "Chuyển đến ví",
                  border: OutlineInputBorder(),
                ),
                items: validTargets.map((wallet) {
                  return DropdownMenuItem<String>(
                    value: wallet.id,
                    child: Text("${wallet.category} (${wallet.balance} VND)"),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    _targetWalletId = value;
                  });
                },
                validator: (val) => val == null ? "Vui lòng chọn ví nhận" : null),
              const SizedBox(height: 16),

              // Nhập số tiền
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: "Số tiền chuyển",
                  hintText: "Tối đa ${widget.sourceWallet.balance} VND",
                  border: const OutlineInputBorder(),
                  suffixText: "VND",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Vui lòng nhập số tiền";
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return "Số tiền không hợp lệ";
                  }
                  if (parsed > widget.sourceWallet.balance) {
                    return "Số dư ví không đủ!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nhập ghi chú
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Ghi chú (Không bắt buộc)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: _submitTransfer,
          child: const Text("Xác nhận"),
        ),
      ],
    );
  }
}