import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/transaction/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/transaction/presentation/cubit/wallet_state.dart';
import 'package:expense_tracker/features/transaction/presentation/cubit/phone_service_cubit.dart';
import 'package:expense_tracker/features/transaction/presentation/cubit/phone_service_state.dart';
import 'package:expense_tracker/features/transaction/domain/mobile_data.dart';

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
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    
    showDialog (
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Nap tien dien thoai"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "So dien thoai: ",
                  hintText: "VD: 0123456789",
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder()
                ),
              ),

              TextField(  
                controller: amountController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration (
                  labelText: "Nhap so tien can nap: ",
                  hintText: "VD: 10000, 20000, ...",
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder()
                )
              ),
            ],
          ),
          actions: [
            // Nút Hủy
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Đóng dialog
              child: const Text('Huy!'),
            ),

            // Nút XÁC NHẬN
            ElevatedButton(
              onPressed: () {
                final phone = phoneController.text.trim();
                final amountText = amountController.text.trim();

                // Kiếm tra nhập liệu cơ bản
                if (phone.isEmpty || amountText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
                  );
                  return;
                }

                final amount = int.tryParse(amountText) ?? 0;

                // Goi Cubit thuc hien nap tien dien thoai
                context.read<PhoneServiceCubit>().topUpPhoneCredit(
                      fromWalletID: masterVaultId,
                      amount: amount,
                      phoneNumber: phone,
                    );

                // Dong dialog sau khi bam "nap tien"
                Navigator.pop(dialogContext);
              },
              child: const Text('Nap ngay!'),
            ),
          ],
        );
      },
    );
  }

  // Dialog gọi hàm Mua gói cước Data
  void _showMobileDataDialog(BuildContext context, String masterVaultId) {
    final phoneController = TextEditingController();
    
    // Giá trị mặc định khi mở Dialog
    InternetServiceProvider selectedIsp = InternetServiceProvider.viettel;
    String selectedPlan = "MD2"; // Giả sử MD2 là gói cước mặc định có trong commonMobileDataPlan

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          // StatefulBuilder giup cap nhat UI ben trong Dialog khi chon Dropdown
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Mua goi cuoc Data'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // O nhap SDT
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'So dien thoai: ',
                      prefixIcon: Icon(Icons.phone_android),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dropdown chon nha mang (ISP)
                  DropdownButtonFormField<InternetServiceProvider>(
                    initialValue: selectedIsp,
                    decoration: const InputDecoration(
                      labelText: 'Nha cung cap dich vu Internet: ',
                      prefixIcon: Icon(Icons.cell_tower), // Icon ISP
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
                        setState(() => selectedIsp = newValue);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Dropdown chon Goi cuoc (commonMobileDataPlan)
                  DropdownButtonFormField<String>(
                    initialValue: selectedPlan,
                    decoration: const InputDecoration(
                      labelText: 'Goi Data',
                      prefixIcon: Icon(Icons.wifi_tethering), // Icon Wifi/Data
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
                        setState(() => selectedPlan = newValue);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Huy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final phone = phoneController.text.trim();
                    if (phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui long nhap so dien thoai!')),
                      );
                      return;
                    }

                    // Gọi Cubit thực hiện mua Data
                    context.read<PhoneServiceCubit>().purchaseMobileData(
                          fromWalletID: masterVaultId,
                          isp: selectedIsp,
                          mobileDataplan: selectedPlan,
                          phoneNumber: phone,
                        );

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Mua ngay'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}