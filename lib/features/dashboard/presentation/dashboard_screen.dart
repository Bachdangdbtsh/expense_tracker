import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_cubit.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_state.dart';
import 'package:expense_tracker/features/phoneService/domain/mobile_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Lắng nghe thông báo lỗi từ WalletCubit
        BlocListener<WalletCubit, WalletStates>(
          listener: (context, state) {
            if (state is WalletError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
        ),
        // Lắng nghe kết quả từ PhoneServiceCubit (Topup/Data)
        BlocListener<PhoneServiceCubit, PhoneServiceStates>(
          listener: (context, state) {
            if (state is PhoneServiceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is PhoneServiceLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Giao dịch dịch vụ viễn thông thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Tải lại dữ liệu ví mới nhất để cập nhật lại số dư trên UI
              context.read<WalletCubit>().loadInitialData();
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý chi tiêu'),
          actions: [
            // Nút bấm làm mới / tính toán lại Thống kê
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                context.read<WalletCubit>().getStatistic();
              },
            ),
          ],
        ),
        body: BlocBuilder<WalletCubit, WalletStates>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletLoaded) {
              final stat = state.statistic; // Lấy dữ liệu thống kê

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 1. THONG TIN MASTER VAULT & STATISTIC (FinancialStatistic)
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chủ tài khoản: ${state.vault.ownerName}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Tổng hạn mức: ${state.vault.totalBalance} VND'),
                          const Divider(),
                          Text('Tổng đã chi: ${stat?.totalExpense} VND',
                              style: const TextStyle(color: Colors.red)),
                          Text('Tổng thu nhập: ${stat?.totalIncome} VND',
                              style: const TextStyle(color: Colors.green)),
                          Text('Ngân sách còn lại: ${stat?.remainingBudget} VND'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. DICH VU VIEN THONG (Topup & Mobile Data)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Nút Nạp tiền điện thoại
                      ElevatedButton.icon(
                        icon: const Icon(Icons.phone_android),
                        label: const Text('Nạp ĐT'),
                        onPressed: () {
                          _showTopUpDialog(context, state.vault.accountID);
                        },
                      ),
                      // Nút Mua Data 3G/4G
                      ElevatedButton.icon(
                        icon: const Icon(Icons.wifi),
                        label: const Text('Mua Data'),
                        onPressed: () {
                          _showMobileDataDialog(context, state.vault.accountID);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text('Danh sách ví:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  // 3. DANH SÁCH CÁC VÍ
                  ...state.walletList.map((wallet) => ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: Text(wallet.category),
                        subtitle: Text('Số dư: ${wallet.balance} VND'),
                      )),
                ],
              );
            }

            return const Center(child: Text('Chưa có dữ liệu.'));
          },
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, String masterVaultId) {
    showDialog(
      context: context,
      builder: (dialogContext) => _TopUpDialog(
        masterVaultId: masterVaultId,
        parentContext: context,
      ),
    );
  }
  // Dialog gọi hàm Mua gói cước Data
  void _showMobileDataDialog(BuildContext context, String masterVaultId) {
    showDialog(
      context: context,
      builder: (dialogContext) => _MobileDataDialog(
        masterVaultId: masterVaultId,
        parentContext: context,
      ),
    );
  }


}

class _TopUpDialog extends StatefulWidget {
  final String masterVaultId;
  final BuildContext parentContext;

  const _TopUpDialog({
    required this.masterVaultId,
    required this.parentContext
  });
  @override
  State<_TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<_TopUpDialog> {
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
  Widget build(BuildContext content) {
    final walletState = widget.parentContext.read<WalletCubit>().state;
    List<dynamic> walletList = [];
    if (walletState is WalletLoaded) {
      walletList = walletState.walletList;
    }

    return AlertDialog(
      title: const Text('Nap dien dien thoai'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedWalletId,
              decoration: const InputDecoration(
                labelText: 'Vi thanh toan',
                prefixIcon: Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Chon vi thanh toan'),
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
                labelText: "So dien thoai: ",
                hintText: "VD: 0123456789",
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder()
              ),
            ),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'So tien nap (VND)',
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
          child: const Text("Cancel")
        ),
        
        ElevatedButton(
          onPressed: () {
            final phone = _phoneController.text.trim();
            final amountText = _amountController.text.trim();
            final amount = int.tryParse(amountText) ?? 0;

            if (_selectedWalletId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui long chon vi thanh toan!')),
              );
              return;
            }

            if (phone.isEmpty || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('So dien thoai hoac so tien khong hop le!')),
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
          child: const Text('Nap ngay!'),
        ),
      ],
    );
  }
}
class _MobileDataDialog extends StatefulWidget {
  final String masterVaultId;
  final BuildContext parentContext;

  const _MobileDataDialog({
    required this.masterVaultId,
    required this.parentContext,
  });

  @override
  State<_MobileDataDialog> createState() => _MobileDataDialogState();
}

class _MobileDataDialogState extends State<_MobileDataDialog> {
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
            // Ô chọn Ví thanh toán
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

            // Ô nhập Số điện thoại
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

            // Dropdown chọn Nhà mạng (ISP)
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

            // Dropdown chọn Gói Data
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

            // Goi Cubit
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