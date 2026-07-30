import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';

class CreateWalletDialog extends StatefulWidget {
  final BuildContext parentContext;

  const CreateWalletDialog({
    super.key,
    required this.parentContext
  });

  @override
  State<CreateWalletDialog> createState() => _CreateWalletDialogState();

}

class _CreateWalletDialogState extends State<CreateWalletDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _amountController;

  @override 
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) {

    return AlertDialog(
      title: const Text("Tạo ví mới"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12), 
            TextField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: "Tên của ví",
                hintText: "VD: Học phí, tiền nhà, ...",
                prefixIcon: Icon(Icons.wallet_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12), 
            TextField(
              controller: _categoryController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: "Phân loại chi tiêu:",
                hintText: "VD: Mua quà, ăn uống",
                prefixIcon: Icon(Icons.sort),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12), 
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số tiền nạp vào ví",
                hintText: "VD: 200000, 5000000, ...",
                prefixIcon: Icon(Icons.monetization_on_rounded),
                border: OutlineInputBorder(),
              ),
            )
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
            final name = _nameController.text.trim();
            final category = _categoryController.text.trim();
            final amountText = _amountController.text.trim();
            final amount = int.tryParse(amountText) ?? 0;

            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập tên ví!')),
              );
              return;
            }

            if (category.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng phân loại chi tiêu cho ví!')),
              );
              return;
            }

            if (amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('số tiền nạp vào không hợp lệ!')),
              );
              return;
            }

            widget.parentContext.read<WalletCubit>().createWallet(
                  name: name,
                  category: category,
                  initialBalance: amount,
                );

            Navigator.pop(context);
          },
          child: const Text('Tạo ví!'),
        ),
      ],
    );
  }
}