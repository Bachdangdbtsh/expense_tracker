import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_cubit.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_state.dart';

// Import các Dialog từ folder widgets
import 'package:expense_tracker/features/dashboard/presentation/widget/top_up_dialog.dart';
import 'package:expense_tracker/features/dashboard/presentation/widget/mobile_data_dialog.dart';
import 'package:expense_tracker/features/wallet/presentation/widget/edit_master_vault_dialog.dart';
import 'package:expense_tracker/features/wallet/presentation/statistic_screen.dart';
import 'package:expense_tracker/features/wallet/domain/master_wallet.dart';
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});


  void _showEditMasterVaultDialog(BuildContext context, MasterVault currentVault) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditMasterVaultDialog(
        currentVault: currentVault,
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, String masterVaultId) {
    showDialog(
      context: context,
      builder: (dialogContext) => TopUpDialog(
        masterVaultId: masterVaultId,
        parentContext: context,
      ),
    );
  }

  void _showMobileDataDialog(BuildContext context, String masterVaultId) {
    showDialog(
      context: context,
      builder: (dialogContext) => MobileDataDialog(
        masterVaultId: masterVaultId,
        parentContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WalletCubit, WalletStates>(
          listener: (context, state) {
            if (state is WalletError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
        ),
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
              context.read<WalletCubit>().loadInitialData();
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý chi tiêu'),
          actions: [
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                context.read<WalletCubit>().getStatistic();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticScreen()),
                );
              },
            )
          ],
        ),
        body: BlocBuilder<WalletCubit, WalletStates>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletLoaded) {
              final stat = state.statistic;

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 1. THÔNG TIN MASTER VAULT & STATISTIC
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Chủ tài khoản: ${state.vault.ownerName}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              // Nút bấm mở Dialog chỉnh sửa Master Vault
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.indigo),
                                tooltip: 'Chỉnh sửa tài khoản nguồn',
                                onPressed: () {
                                  _showEditMasterVaultDialog(
                                      context, state.vault);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Tổng hạn mức: ${state.vault.totalBalance} VND',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          const Divider(),
                          Text('Tổng đã chi: ${stat?.totalExpense ?? 0} VND',
                              style: const TextStyle(color: Colors.red)),
                          Text('Tổng thu nhập: ${stat?.totalIncome ?? 0} VND',
                              style: const TextStyle(color: Colors.green)),
                          Text('Ngân sách còn lại: ${stat?.remainingBudget ?? 0} VND',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. DỊCH VỤ VIỄN THÔNG (Topup & Mobile Data)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.phone_android),
                        label: const Text('Nạp ĐT'),
                        onPressed: () {
                          _showTopUpDialog(context, state.vault.accountID);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.four_g_mobiledata_rounded),
                        label: const Text('Mua Data 4G/5G'),
                        onPressed: () {
                          _showMobileDataDialog(context, state.vault.accountID);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text('Danh sách ví:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

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
}