import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_cubit.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_state.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';

class TopupScreen extends StatefulWidget {
  const TopupScreen({super.key});

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  late final TextEditingController _phoneController;

  String? _selectedWalletId;
  int _selectedAmount = 20000;

  // Danh sách mệnh giá nạp
  final List<int> _amounts = [
    10000,
    20000,
    30000,
    50000,
    70000,
    100000,
    120000,
    150000,
    200000,
    300000,
    500000
  ];

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitTopup() {
    final phone = _phoneController.text.trim();

    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ví thanh toán!')),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại!')),
      );
      return;
    }

    // Gọi Cubit để thực hiện giao dịch nạp tiền
    context.read<PhoneServiceCubit>().topUpPhoneCredit(
          fromWalletID: _selectedWalletId!,
          amount: _selectedAmount,
          phoneNumber: phone,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhoneServiceCubit, PhoneServiceStates>(
      listener: (context, state) {
        if (state is PhoneServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is PhoneServiceLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nạp tiền điện thoại thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          // Cập nhật lại số dư ví sau khi nạp thành công
          context.read<WalletCubit>().loadInitialData();
          Navigator.pop(context); // Đóng màn hình
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Image.asset(
              'Assets/247_LOGO.png',
              fit: BoxFit.contain,
            ),
          ),
          
          title: const Text("Nạp tiền điện thoại"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CHỌN VÍ THANH TOÁN
              const Text(
                "Nguồn tiền thanh toán",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              BlocBuilder<WalletCubit, WalletStates>(
                builder: (context, state) {
                  if (state is WalletLoaded) {
                    final wallets = state.walletList;
                    if (wallets.isEmpty) {
                      return const Card(
                        color: Colors.redAccent,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            "Chưa có ví nào để thanh toán. Vui lòng tạo ví trước!",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    _selectedWalletId ??= wallets.first.id;

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedWalletId,
                      decoration: const InputDecoration(
                        labelText: "Danh sách ví thanh toán",
                        prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                        border: OutlineInputBorder(),
                      ),
                      items: wallets.map((wallet) {
                        return DropdownMenuItem<String>(
                          value: wallet.id,
                          child: Text("${wallet.category} (${wallet.balance} VND)"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWalletId = value;
                        });
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),

              const SizedBox(height: 24),

              // 2. NHẬP SỐ ĐIỆN THOẠI
              const Text(
                "Thông tin người nhận",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại",
                  hintText: "0123456789",
                  prefixIcon: Icon(Icons.phone_rounded),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // 3. CHỌN MỆNH GIÁ NẠP
              const Text(
                "Chọn mệnh giá nạp",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: _amounts.map((amount) {
                  final isSelected = _selectedAmount == amount;
                  return ChoiceChip(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    label: Text(
                      "${amount ~/ 1000}k",
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedAmount = amount;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // 4. NÚT XÁC NHẬN NẠP TIỀN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitTopup,
                  icon: const Icon(Icons.flash_on_rounded),
                  label: Text(
                    "Nạp ${_selectedAmount ~/ 1000}k Ngay",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}