import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AppScanBarcodeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AppScanBarcodeController>(AppScanBarcodeController());
  }
}

class AppScanBarcodeController extends GetxController {
  MobileScannerController cameraController = MobileScannerController();
  bool isPop = false;
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class AppScanBarcode extends GetView<AppScanBarcodeController> {
  final Function(String barCode)? barcodeCallBack;
  const AppScanBarcode({Key? key, this.barcodeCallBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "扫描条形码", action: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => controller.cameraController.toggleTorch(),
          ),
        ]),
        body: MobileScanner(
            allowDuplicates: false,
            controller: controller.cameraController,
            onDetect: (barcode, args) {
              print("barcode == $barcode");
              if (barcode.rawValue == null) {
                // debugPrint('Failed to scan Barcode');
              } else {
                final String code = barcode.rawValue!;
                // debugPrint('Barcode found! $code');
                if (barcodeCallBack != null) {
                  barcodeCallBack!(code);
                }

                // Navigator.pop(context);
                if (!controller.isPop) {
                  Get.back();
                  controller.isPop = true;
                }
              }
            }));
  }
}
