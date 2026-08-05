import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset(
            'Assets/247_LOGO.png',
            fit: BoxFit.contain,
          ),
        ),

        title: const Text('Thống kê chi tiêu'),
      ),
      body: BlocBuilder<WalletCubit, WalletStates>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletLoaded) {
            final stat = state.statistic;
            if (stat == null) {
              return const Center(child: Text('Chưa có dữ liệu thống kê.'));
            }

            final expenseMap = stat.expenseByCategory;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Cảnh báo an toàn tài khoản
                if (!stat.isAccountSafe)
                  const Card(
                    color: Colors.redAccent,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Cảnh báo: Tổng ngân sách các ví vượt quá hạn mức Master Vault!',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // 2. Tổng quan Thu - Chi - Ngân sách
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Tổng thu nhập'),
                          trailing: Text('${stat.totalIncome} VND',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                        ListTile(
                          title: const Text('Tổng chi tiêu'),
                          trailing: Text('${stat.totalExpense} VND',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Ngân sách còn lại'),
                          trailing: Text('${stat.remainingBudget} VND',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Chi tiêu theo danh mục',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // 3. Danh sách chi tiêu theo Category (% + Tiến trình)
                if (expenseMap.isEmpty)
                  const Text('Chưa có giao dịch chi tiêu nào.')
                else
                  ...expenseMap.entries.map((entry) {
                    final category = entry.key;
                    final amount = entry.value;
                    final percentage = stat.getExpensePercentage(category);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('$amount VND (${percentage.toStringAsFixed(1)}%)'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.indigo,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          }

          return const Center(child: Text('Không thể tải thống kê.'));
        },
      ),
    );
  }
}