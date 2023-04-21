import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductStoreOrderListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductStoreOrderListController>(
        ProductStoreOrderListController(datas: Get.arguments));
  }
}

class ProductStoreOrderListController extends GetxController {
  final dynamic datas;
  ProductStoreOrderListController({this.datas});

  int levelType = 1;
  @override
  void onInit() {
    // 1:礼包 2:采购 3:兑换
    levelType = (datas ?? {})["levelType"] ?? 1;
    super.onInit();
  }
}

class ProductStoreOrderList extends GetView<ProductStoreOrderListController> {
  const ProductStoreOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "订单列表"),
    );
  }
}
