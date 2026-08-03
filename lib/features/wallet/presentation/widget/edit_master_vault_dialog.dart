import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/domain/master_wallet.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';

class EditMasterVaultDialog extends StatefulWidget{
  final MasterVault currentVault;

  const EditMasterVaultDialog({
    super.key,
    required this.currentVault
  });

  @override
  State<StatefulWidget> createState() => _EditMasterVaultDialogState();
}

class _EditMasterVaultDialogState extends State<EditMasterVaultDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentVault.ownerName);
    _balanceController = TextEditingController(text: widget.currentVault.totalBalance.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final balance = int.parse(_balanceController.text.trim());

      context.read<WalletCubit>().updateMasterVaultInfo(
        ownerName: name, 
        initialBalance: balance
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.admin_panel_settings_rounded, color: Colors.indigo),
          SizedBox(height: 8),
          Text("Chỉnh sửa Ví nguồn")
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Tên chủ tài khoản",
                hintText: "VD: Nguyễn Văn A, ...",
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder()
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Vui lòng nhập tên chủ tài khoản!";
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Tổng ngân sách chính (VND)",
                prefixIcon: Icon(Icons.account_balance_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Vui lòng nhập tổng số tiền!";
                }
                final parsed = int.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return "Số tiền không hợp lệ!";
                }
                return null;
              },
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
          onPressed: _submitUpdate, 
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text("Cập nhật"))
      ],
    );
  }
}