import 'dart:io';
import 'dart:async';  // delay time

void main() {

  bool canExit = false;
  while (!canExit) {
    print('---- Ung dung quan ly chi tieu 247ExpenTraker ----');
    print('1. Xem danh sach vi & Lich su giao dich');
    print('2. Thuc hien giao dich');
    print('3. Nap tien dien thoai / Internet');
    print('4. Thong ke tai chinh');
    print('5. Thoat');

    String? input = stdin.readLineSync();
    switch (input) {
      case '1':
        // Code hien thi vi chi tieu
        break;
      case '2':
        // Code thuc hien giao dich
        break;
      case '3':
        // Code nap tien dien thoai / internet
        break;
      case '4':
        // Code thong ke tai chinh
        break;
      case '5':
        // Code thoat khoi ung dung;
        print("Dang thoat khoi ung dung...");
        Future.delayed(Duration(seconds: 1));
        canExit = true;
        break;
      default:
        print("Lua chon khong hop le!");
        break;
    }
  }
}