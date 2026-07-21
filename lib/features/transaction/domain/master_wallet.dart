// Vi tong, nam giu so tien toan cuc
class MasterVault {
  final String accountID;
  String ownerName;
  int totalBalance;

  MasterVault({
    required this.accountID,
    required this.ownerName,
    required this.totalBalance
  });

  bool canAllocate(int amount, int currentAllocatedSum) {
    return (currentAllocatedSum + amount) <= totalBalance;
  }
}