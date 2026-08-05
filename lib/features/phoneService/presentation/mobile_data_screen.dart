import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/phoneService/domain/mobile_data.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_cubit.dart';
import 'package:expense_tracker/features/phoneService/presentation/cubit/phone_service_state.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:expense_tracker/features/wallet/presentation/cubit/wallet_state.dart';

class MobileDataScreen extends StatefulWidget {
  const MobileDataScreen({super.key});

  @override
  State<MobileDataScreen> createState() => _MobileDataScreenState();
}

class _MobileDataScreenState extends State<MobileDataScreen> {
  late final TextEditingController _phoneController;

  String? _selectedWalletId;
  InternetServiceProvider _selectedISP = InternetServiceProvider.viettel;
  String _selectedPlan = "MD1";

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

    // Gọi Cubit xử lý giao dịch
    context.read<PhoneServiceCubit>().purchaseMobileData(
          fromWalletID: _selectedWalletId!,
          isp: _selectedISP,
          mobileDataplan: _selectedPlan,
          phoneNumber: phone,
        );
  }

  String _getIspLogoPath(InternetServiceProvider isp) {
    switch (isp) {
      case InternetServiceProvider.viettel:
        return 'Assets/viettel_logo.png';
      case InternetServiceProvider.vinaphone:
        return 'Assets/vinaphone_logo.png';
      case InternetServiceProvider.mobiphone:
        return 'Assets/mobifone_logo.png';
      case InternetServiceProvider.fptTelecom:
        return 'Assets/fpt_logo.png';
    }
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
            SnackBar(
              content: Text('Mua gói cước $_selectedPlan thành công !'),
              backgroundColor: Colors.green,
            ),
          );
          // Cập nhật lại số dư các ví sau khi nạp thành công
          context.read<WalletCubit>().loadInitialData();
          Navigator.pop(context); // Quay về màn hình trước
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
          
          title: const Text("Mua dữ liệu di động"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CHỌN VÍ THANH TOÁN
              const Text(
                "Danh sách ví thanh toán",
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

              // 2. CHỌN NHÀ MẠNG (ISP)
              const Text(
                "Chọn nhà mạng",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              SegmentedButton<InternetServiceProvider>(
                segments: InternetServiceProvider.values.map((isp) {
                  return ButtonSegment<InternetServiceProvider>(
                    value: isp,
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Image.asset(
                        _getIspLogoPath(isp),
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }).toList(),
                selected: {_selectedISP},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedISP = newSelection.first;
                  });
                },
              ),

              const SizedBox(height: 24),

              // 3. NHẬP SỐ ĐIỆN THOẠI
              const Text(
                "Thông tin thuê bao",
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

              // 4. CHỌN GÓI CƯỚC DATA
              const Text(
                "Chọn gói cước khả dụng",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10
                ),
                itemCount: commonMobileDataPlan.length,
                itemBuilder: (context, index) {
                  final planKey = commonMobileDataPlan.keys.elementAt(index);
                  final price = commonMobileDataPlan.values.elementAt(index);
                  final isSelected = _selectedPlan == planKey;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPlan = planKey;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.15) : Colors.grey.shade100,
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          width: isSelected ? 2 : 1
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            planKey,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${price ~/ 1000}k VND",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  );
                },
              ),

              // 5. XÁC NHẬN MUA GÓI DATA
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitTopup, 
                  label: Text(
                    "Đăng ký gói $_selectedPlan (${(commonMobileDataPlan[_selectedPlan] ?? 0) ~/ 1000}k)", 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}