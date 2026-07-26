// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/transaction/presentation/cubit/wallet_cubit.dart';

import 'package:expense_tracker/features/transaction/presentation/cubit/wallet_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý chi tiêu')),
      body: BlocConsumer<WalletCubit, WalletStates>(
        // BlocListener: Chuyên dùng để hứng thông báo Lỗi hoặc Thành công (Hiển thị SnackBar)
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        // BlocBuilder: Chuyên dùng để vẽ lại UI theo State
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (state is WalletLoaded) {
            return ListView(
              children: [
                // Hiển thị thông tin Master Vault
                Text('Chủ tài khoản: ${state.vault.ownerName}'),
                Text('Hạn mức: ${state.vault.totalBalance} VND'),
                const Divider(),
                
                // Hiển thị danh sách các Wallet
                ...state.walletList.map((wallet) => ListTile(
                  title: Text(wallet.category),
                  subtitle: Text('Số dư: ${wallet.balance} VND'),
                )),
              ],
            );
          }

          return const Center(child: Text('Bấm nút để bắt đầu'));
        },
      ),
    );
  }
}