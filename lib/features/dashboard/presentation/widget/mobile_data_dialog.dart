import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_cubit.dart';
import 'package:expense_tracker/features/phoneService/domain/mobile_data.dart';

class MobileDataDialog extends StatefulWidget {
  final String masterVaultId;
  final BuildContext parentContext;

  const MobileDataDialog({
    super.key,
    required this.masterVaultId,
    required this.parentContext,
  });

  @override
  State<MobileDataDialog> createState() => _MobileDataDialogState();
}

class _MobileDataDialogState extends State<MobileDataDialog> {
  late final TextEditingController _phoneController;
  String? _selectedWalletId;
  InternetServiceProvider _selectedIsp = InternetServiceProvider.viettel;
  String _selectedPlan = "MD2";

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
      title: const Text('Mua gói cước Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedWalletId,
              decoration: const InputDecoration(
                labelText: 'Trừ tiền từ ví',
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
                labelText: 'Số điện thoại',
                hintText: 'VD: 0901234567',
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<InternetServiceProvider>(
              initialValue: _selectedIsp,
              decoration: const InputDecoration(
                labelText: 'Nhà mạng',
                prefixIcon: Icon(Icons.cell_tower),
                border: OutlineInputBorder(),
              ),
              items: InternetServiceProvider.values.map((isp) {
                return DropdownMenuItem(
                  value: isp,
                  child: Text(isp.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedIsp = newValue);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedPlan,
              decoration: const InputDecoration(
                labelText: 'Gói Data',
                prefixIcon: Icon(Icons.wifi_tethering),
                border: OutlineInputBorder(),
              ),
              items: commonMobileDataPlan.keys.map((planKey) {
                final price = commonMobileDataPlan[planKey];
                return DropdownMenuItem(
                  value: planKey,
                  child: Text('$planKey ($price VND)'),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedPlan = newValue);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
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

            widget.parentContext.read<PhoneServiceCubit>().purchaseMobileData(
                  fromWalletID: _selectedWalletId!,
                  isp: _selectedIsp,
                  mobileDataplan: _selectedPlan,
                  phoneNumber: phone,
                );

            Navigator.pop(context);
          },
          child: const Text('Mua ngay'),
        ),
      ],
    );
  }
}