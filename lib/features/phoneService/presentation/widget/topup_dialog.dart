import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopupDialog extends StatefulWidget {
  final String fromWalletId;
  final int amount;
  final BuildContext parentContext;
  
  const TopupDialog({
    super.key,
    required this.fromWalletId,
    required this.amount,
    required this.parentContext
  });

  @override
  State<TopupDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<TopupDialog> {
  late final TextEditingController _phoneController;

  String? _selectedWalletId;
  int _selectedAmount = 20000;
  final List<int> _amounts = [10000, 20000, 30000, 50000, 70000, 100000, 120000, 150000, 200000, 300000, 500000];


  @override
  void initState() {
    _phoneController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nạp tiền điện thoại"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            // Dropdown menu chon vi thanh toan
            BlocBuilder<WalletCubit, WalletStates>(
              builder: (context, state) {
                if (state is WalletLoaded) {
                  final wallets = state.walletList;
                  if (wallets.isEmpty) {
                    return const Text(
                      "Chưa có ví nào để thanh toán. Vui lòng tạo ví trước!",
                      style: TextStyle(color: Colors.red),
                    );
                  }

                  _selectedWalletId ??= wallets.first.id;
                  return DropdownButtonFormField<String> (
                    initialValue: _selectedWalletId, 
                    decoration: const InputDecoration(
                      labelText: "Danh sách ví thanh toán",
                      prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                      border: OutlineInputBorder(),
                    ),

                    items: wallets.map((wallet) {
                      return DropdownMenuItem<String>(
                        value: wallet.id,
                        child: Text("${wallet.category} (wallet.balance)"),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        _selectedWalletId = value;
                      });
                    },
                  );
                }
                return const CircularProgressIndicator();
              }
            ),

            // TextField nhap so dien thoai
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                hintText: "0123456789",
                prefixIcon: Icon(Icons.phone_rounded),
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Chọn mệnh giá nạp:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _amounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return ChoiceChip(
                  label: Text(
                    "${amount ~/ 1000}k",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedAmount = amount;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Huỷ!")
        ),
        ElevatedButton(
          onPressed: () {
            final phone = _phoneController.text.trim();

            if (_selectedWalletId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn ví thanh toán!')),
              );
              return;
            }

            if (phone.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập số điện thoại!')),
              );
              return;
            }

            // Gọi Cubit để xử lý giao dịch
            widget.parentContext.read<PhoneServiceCubit>().topUpPhoneCredit(
                  fromWalletID: _selectedWalletId!,
                  amount: _selectedAmount,
                  phoneNumber: phone,
                );
            Navigator.pop(context);
          }, 
          child: const Text("Nạp ngay"))
      ],
    );
  }
}