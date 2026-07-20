import 'dart:io';
import 'dart:async';  // delay time
import 'package:expense_tracker/features/transaction/domain/financial_manager.dart';
import 'package:expense_tracker/features/transaction/domain/mobile_data.dart';

void main() {

  final manager = FinancialManager();
  manager.createWallet("Tien mat", "Vi Sinh hoat", 2000000);
  manager.createWallet("Ngan hang", "Hu Tiet kiem", 10000000);

  bool canExit = false;
  while (!canExit) {
    print('\n==================================================');
    print('---- Ung dung quan ly chi tieu 247ExpenTraker ----');
    print('==================================================');
    print('1. Vi chi tieu & Lich su giao dich');
    print('2. Thuc hien giao dich (Chuyen tien nội bộ)');
    print('3. Nap tien dien thoai / Internet');
    print('4. Thong ke tai chinh');
    print('5. Thoat');
    stdout.write('Nhap lua chon cua ban (1-5): ');

    String? input = stdin.readLineSync();
    switch (input) {
      case '1':
        print('\n--- VI CHI TIEU & LICH SU GIAO DICH ---');
        print('1. Them vi chi tieu moi');
        print('2. Xoa vi chi tieu');
        print('3. Xem danh sach vi chi tieu & Lich su giao dich');
        stdout.write('Chon dich vu (1-3): ');
        String? serviceChoice = stdin.readLineSync();

        if (serviceChoice == '1') {
          stdout.write('Nhap ten Vi chi tieu: ');
          String name = stdin.readLineSync() ?? '';
          stdout.write('Nhap hang muc chi tieu: ');
          String category = stdin.readLineSync()?? '';
          stdout.write('Nhap so tien nap vao Vi chi tieu: ');
          int amount = int.parse(stdin.readLineSync() ?? '0');
          manager.createWallet(name, category, amount);
        } 
        
        else if (serviceChoice == '2') {
          stdout.write('Nhap ID vi can xoa: ');
          int deleteID = int.parse(stdin.readLineSync() ?? '0');
          manager.deleteWallet(deleteID);
        }

        else if (serviceChoice == '3') {
          print('\n--- THONG TIN TAI KHOAN ---');
          manager.showWalletList();
          print('');
          manager.showTransactionHistory();
        }
        break;

      case '2':
        print('\n--- THU_HIEN_CHUYEN_TIEN ---');
        stdout.write('Nhap ID vi nguon: ');
        int fromID = int.parse(stdin.readLineSync() ?? '0');
        stdout.write('Nhap ID vi dich: ');
        int toID = int.parse(stdin.readLineSync() ?? '0');
        stdout.write('Nhap so tien muon chuyen: ');
        int amount = int.parse(stdin.readLineSync() ?? '0');
        stdout.write('Nhap noi dung chuyen tien: ');
        String desc = stdin.readLineSync() ?? '';

        manager.transferMoney(fromID, toID, amount, desc);
        break;

      case '3':
        print('\n--- NAP TIEN DICH VU ---');
        print('1. Nap tien dien thoai');
        print('2. Mua goi cuoc Data Internet');
        stdout.write('Chon dich vu (1-2): ');
        String? serviceChoice = stdin.readLineSync();

        stdout.write('Nhap ID vi dung de thanh toan: ');
        int walletID = int.parse(stdin.readLineSync() ?? '0');
        stdout.write('Nhap so dien thoai thu huong: ');
        String phone = stdin.readLineSync() ?? '';

        if (serviceChoice == '1') {
          stdout.write('Nhap so tien nap: ');
          int creditAmount = int.parse(stdin.readLineSync() ?? '0');
          manager.topUpPhoneCredit(walletID, creditAmount, phone);
        } 
        
        else if (serviceChoice == '2') {
          print('Cac goi cuoc kha dung: MD1 (5k), MD2 (10k), MD3 (15k), BD3 (50k)...');
          stdout.write('Nhap ma goi cuoc: ');
          String plan = stdin.readLineSync() ?? '';
          // Mac dinh chon Viettel lam nha mang mau
          manager.purchaseMobileData(walletID, InternetServiceProvider.viettel, plan, phone);
        }
        break;

      case '4':
        manager.financialStatistic();
        break;

      case '5':
        print("Dang thoat khoi ung dung... Cam on ban da su dung!");
        canExit = true;
        break;
        
      default:
        print("Lua chon khong hop le! Vui long nhap tu 1 den 5.");
        break;
    }
  }
}