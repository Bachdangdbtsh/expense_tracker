abstract class FinancialManagerExceptions implements Exception {
  final String message;
  final String? errorCode;

  FinancialManagerExceptions(this.message, {this.errorCode});

  @override 
  String toString() => message;
}

class WalletExistedException extends FinancialManagerExceptions {
  WalletExistedException([super.message = "Vi da ton tai. Vui long dat ten khac cho vi!"]) 
    : super(errorCode: "WALLET_EXISTED");
}

class ExceedMasterVaultLimitException extends FinancialManagerExceptions {
  ExceedMasterVaultLimitException([super.message = "Tong tien cac vi vuot qua han muc cua Tai khoan chinh!"]) 
    : super(errorCode: "EXCEED_MASTER_VAULT_LIMIT");
}

class WalletNotFoundException extends FinancialManagerExceptions {
  WalletNotFoundException([super.message = "Thong tin cua vi khong ton tai!"]) 
    : super(errorCode: "WALLET_NOT_FOUND");
}

class ExceedBalanceException extends FinancialManagerExceptions {
  ExceedBalanceException([super.message = "So du khong du de thuc hien giao dich!"]) 
    : super(errorCode: "EXCEED_BALANCE_LIMIT");
}

class PhoneNumberNotFoundException extends FinancialManagerExceptions {
  PhoneNumberNotFoundException([super.message = "Khong tim thay thong tin thue bao!"]) 
    : super(errorCode: "PHONE_NUMMBER_NOT_FOUND");
}

class InvalidDataPackageException extends FinancialManagerExceptions {
  InvalidDataPackageException([super.message = "Goi cuoc du lieu di dong khong hop le!"]) 
    : super(errorCode: "INVALID_DATA_PACKAGE");
}

class InactiveWalletException extends FinancialManagerExceptions {
  InactiveWalletException([super.message = "Vi khong hoat dong!"]) 
    : super(errorCode: "INACTIVE_WALLET");
}