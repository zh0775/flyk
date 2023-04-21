import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductStoreOrderDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductStoreOrderDetailController>(
        ProductStoreOrderDetailController(datas: Get.arguments));
  }
}

class ProductStoreOrderDetailController extends GetxController {
  final dynamic datas;
  ProductStoreOrderDetailController({this.datas});

  Map orderData = {};
  int levelType = 1;
  @override
  void onInit() {
    // 列表传过来的商品数据
    orderData = (datas ?? {})["data"] ?? {};
    // 1:礼包 2:采购 3:兑换
    levelType = (datas ?? {})["levelType"] ?? 1;
    super.onInit();
  }
}

class ProductStoreOrderDetail
    extends GetView<ProductStoreOrderDetailController> {
  const ProductStoreOrderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "订单详情"),
    );
  }
}
