class FinancialStatistic {
  final bool isAccountSafe;
  final int totalMasterBalance;
  final int totalAllocated;
  final int remainingBudget;
  final int totalIncome;
  final int totalExpense;
  final Map<String, int> expenseByCategory;

  FinancialStatistic({
    required this.isAccountSafe,
    required this.totalMasterBalance,
    required this.totalAllocated,
    required this.remainingBudget,
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseByCategory,
  });

  // Getter tinh percentage cua category
  double getExpensePercentage(String category) {
    if (totalExpense == 0) return 0.0;
    int amount = expenseByCategory[category] ?? 0;
    return (amount / totalExpense) * 100;
  }
}