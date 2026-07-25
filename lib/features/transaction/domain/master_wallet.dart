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

  // JSON serialization / deserialization
  Map <String, dynamic> toMap() {
    return {
      'accountID': accountID,
      'ownerName': ownerName,
      'totalBalance': totalBalance
    };
  }

  factory MasterVault.fromMap(Map<String, dynamic> map) {
    return MasterVault(
      accountID: map['accountID'] as String,
      ownerName: map['ownerName'] as String,
      totalBalance: map['totalBalance'] as int
    );
  }
}