class Wallet {
  final int id;  // ID duy nhat cua 1 vi (1 vi = 1 muc dich tieu dung) 
  String category;  // muc dich su dung vi
  int balance;  // so du tai khoan (vnd)
  bool isActive; // trang thai hoat dong cua vi

  // Default constructor
  Wallet({
      required this.id,
      required this.category, 
      required this.balance,
      required this.isActive
    }
  );

  bool canWithdraw(int amount) {
    return isActive && amount <= balance;
  }

  void withdraw(int amount) {
    if (canWithdraw(amount)) {
      balance -= amount;
      print("[WALLET::WITHDRAW] (Wallet ID: $id): Withdraw $amount VND successfully! Purpose: $category.");
      print("Current balance: $balance");
    } else {
      print("[WALLET::WITHDRAW] (Wallet ID: $id): Withdraw failed! Please deposit more.");
    }
  }

  void deposit(int amount) {
    if (isActive) {
      balance += amount;
      print("[WALLET::DEPOSIT] (WalleT's ID: $id): Deposit $amount successfully! Purpose: $category.");
      print("Current balance: $balance");
    } else {
      print("[WALLER::DEPOSIT] (Wallet's ID: $id): Deposit failed! Wallet is not active!");
    }
  }

  void showWalletInfo() {
    print("-------------------------------");
    print("Ma so Id: $id");
    print("Phan loai chi tieu: $category");
    print("So du hien tai: $balance (VND)");
    print("Trang thai hoat dong: ${isActive? "Con hoat dong" : "Ngung hoat dong"}");
  }
}