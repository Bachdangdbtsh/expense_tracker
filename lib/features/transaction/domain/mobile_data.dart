enum InternetServiceProvider {
  vinaphone,
  mobiphone, 
  viettel,
  fptTelecom
}

Map<String, int> commonMobileDataPlan = {
  'MD1' : 5000,   // Goi cuoc MD1: 5000d cho 500MB. HSD 24h tinh tu thoi diem dang ki.
  'MD2' : 10000,  // Goi cuoc MD2: 10000d cho 1GB. HSD 24h tinh tu thoi diem dang ki.
  'MD3' : 15000,  // Goi cuoc MD3: 15000d cho 2GB. HSD 48h tinh tu thoi diem dang ki.
  'MD7' : 20000,  // Goi cuoc MD7: 20000d cho 2GB. HSD 72h tinh tu thoi diem dang ki. 
  'BD1' : 30000,  // Goi cuoc BD1: 30000d cho 1GB/ngay. HSD 1 tuan tu thoi diem dang ki.
  'BD3' : 50000,  // Goi cuoc BD3: 50000d cho 1GB/ngay. HSD 1 thang tu thoi diem dang ki.
  'BD6' : 60000,  // Goi cuoc BD6: 30000d cho 2GB/ngay. HSD 1 thang tu thoi diem dang ki.
  'BD12': 120000  // Goi cuoc BD12: 120000d cho 2GB/ngay. HSD 3 thang ke tu thoi diem dang ki.
}; 

