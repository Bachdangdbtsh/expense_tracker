import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_cubit.dart';

class TopUpDialog extends StatefulWidget {
  final String masterVaultId;
  final BuildContext parentContext;

  const TopUpDialog({
    super.key,
    required this.masterVaultId,
    required this.parentContext,
  });

  @override
  State<TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<TopUpDialog> {
  late final TextEditingController _phoneController;
  late final TextEditingController _amountController;
  String? _selectedWalletId;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = widget.parentContext.read<WalletCubit>().state;
    List<dynamic> walletList = [];
    if (walletState is WalletLoaded) {
      walletList = walletState.walletList;
    }

    return AlertDialog(
      title: const Text('Nạp tiền điện thoại'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedWalletId,
              decoration: const InputDecoration(
                labelText: 'Ví thanh toán',
                prefixIcon: Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Chọn ví thanh toán'),
              items: walletList.map((wallet) {
                return DropdownMenuItem<String>(
                  value: wallet.id,
                  child: Text('${wallet.category} (${wallet.balance} VND)'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedWalletId = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                hintText: "VD: 0123456789",
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số tiền nạp (VND)',
                hintText: 'VD: 10000, 20000, 50000,...',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: () {
            final phone = _phoneController.text.trim();
            final amountText = _amountController.text.trim();
            final amount = int.tryParse(amountText) ?? 0;

            if (_selectedWalletId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn ví thanh toán!')),
              );
              return;
            }

            if (phone.isEmpty || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Số điện thoại hoặc số tiền không hợp lệ!')),
              );
              return;
            }

            widget.parentContext.read<PhoneServiceCubit>().topUpPhoneCredit(
                  fromWalletID: _selectedWalletId!,
                  amount: amount,
                  phoneNumber: phone,
                );

            Navigator.pop(context);
          },
          child: const Text('Nạp ngay'),
        ),
      ],
    );
  }
}