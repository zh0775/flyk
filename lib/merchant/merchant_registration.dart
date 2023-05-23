// 商户注册页面

import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineRegisterBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineRegisterController>(MachineRegisterController());
  }
}

class MachineRegisterController extends GetxController {
  bool topAnimation = false;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final PageController pageCtrl = PageController();

  final _topCurrentIndex = 0.obs;
  int get topCurrentIndex => _topCurrentIndex.value;
  set topCurrentIndex(v) {
    if (!topAnimation) {
      _topCurrentIndex.value = v;
    }
  }

  List merchantRegistrationData = [
    {
      "brandId": 1,
      "brandName": "电银",
      "qrcode": [
        {"qrcodeId": 1, "qrcodeSrc": "https://dummyimage.com/200x100"},
        {"qrcodeId": 2, "qrcodeSrc": "https://dummyimage.com/200x100"},
      ]
    }
  ];
}

class MachineRegisterPage extends GetView<MachineRegisterController> {
  const MachineRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, '商户注册'),
      body: Stack(
        children: [],
      ),
    );
  }

  // 头部
  Widget topBar() {
    return Container(
      width: 375.w,
      height: 51.w,
      child: ListView(
        children: [],
      ),
    );
  }
}
