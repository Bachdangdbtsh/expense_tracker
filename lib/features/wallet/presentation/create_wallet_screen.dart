import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:expense_tracker/features/wallet/presentation/widget/create_wallet_dialog.dart';
import 'package:expense_tracker/features/wallet/presentation/widget/delete_wallet_dialog.dart';

class CreateWalletScreen extends StatelessWidget {
  const CreateWalletScreen({super.key});

  void _showCreateWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CreateWalletDialog(
        parentContext: context,
      ),
    );
  }

  void _showDeleteWalletDialog(BuildContext context, String walletId, String walletName) {
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteWalletDialog(
        walletId: walletId,
        walletName: walletName,
        parentContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletCubit, WalletStates>(
      listener: (context, state) {
        if (state is WalletError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý & Tạo ví mới"),
          actions: [
            IconButton(
              onPressed: () => _showCreateWalletDialog(context),
              icon: const Icon(Icons.add_card_rounded),
              tooltip: "Tạo ví mới",
            ),
          ],
        ),
        body: BlocBuilder<WalletCubit, WalletStates>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletLoaded) {
              final wallets = state.walletList;

              if (wallets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, 
                          size: 64, color: Colors.grey
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Chưa có ví chi tiêu nào!",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateWalletDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text("Tạo ví ngay"),
                      )
                    ],
                  ),
                );
              }

              // tinh tong tien kha dung cua cac vi
              final totalWalletBalance = wallets.fold<num>(
                0,
                (sum, wallet) => sum + wallet.balance,
              );

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hien thi tong so vi + so du
                    Card(
                      elevation: 2,
                      color: Colors.indigo.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Tổng số ví: ",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54
                                  ),
                                ),
                                Text(
                                  "${wallets.length} ví",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Tổng tiền các ví",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54
                                  ),
                                ),
                                Text(
                                  "$totalWalletBalance VND",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Danh sách ví khả dụng",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // 2. Danh sach vi dang Card
                    Expanded(
                      child: ListView.builder(
                        itemCount: wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = wallets[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade100,
                                child: const Icon(Icons.wallet, color: Colors.indigo),
                              ),
                              title: Text(
                                wallet.category,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${wallet.balance} VND",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              // Nút bấm xóa ví trực tiếp từng item
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_outlined, color: Colors.redAccent),
                                tooltip: "Xóa ví này",
                                onPressed: () {
                                  _showDeleteWalletDialog(
                                    context,
                                    wallet.id,
                                    wallet.category,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text("Không thể tải dữ liệu ví."));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateWalletDialog(context),
          icon: const Icon(Icons.add),
          label: const Text("Ví mới"),
        ),
      ),
    );
  }
}