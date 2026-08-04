import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:expense_tracker/features/wallet/domain/transaction.dart';

class TransactionHistoryScreen extends StatelessWidget{
  const TransactionHistoryScreen({super.key});

  Widget _buildTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return const CircleAvatar(
          backgroundColor: Colors.greenAccent,
          child: Icon(Icons.arrow_downward, color: Colors.green),
        );
      case TransactionType.expense:
        return const CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.arrow_upward, color: Colors.red),
        );
      case TransactionType.transfer:
        return const CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          child: Icon(Icons.swap_horiz, color: Colors.deepOrange),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
      ),
      body: BlocBuilder<WalletCubit, WalletStates>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletLoaded) {
            final transactions = state.transactionHistory;

            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Chưa có giao dịch nào được ghi nhận!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Sắp xếp giao dịch mới nhất lên đầu
            final sortedList = List.from(transactions)
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: sortedList.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final trans = sortedList[index];
                final isExpense = trans.type == TransactionType.expense;
                final isIncome = trans.type == TransactionType.income;

                // Format tiền tệ đơn giản
                final prefix = isExpense ? '-' : (isIncome ? '+' : '');
                final amountColor = isExpense
                    ? Colors.red
                    : (isIncome ? Colors.green : Colors.blue);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  leading: _buildTransactionIcon(trans.type),
                  title: Text(
                    trans.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (trans.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(trans.description, style: const TextStyle(fontSize: 13)),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${trans.dateTime.day}/${trans.dateTime.month}/${trans.dateTime.year} ${trans.dateTime.hour}:${trans.dateTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '$prefix${trans.amount} VND',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: amountColor,
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Không thể tải lịch sử giao dịch.'));
        },
      ),
    );
  }
}