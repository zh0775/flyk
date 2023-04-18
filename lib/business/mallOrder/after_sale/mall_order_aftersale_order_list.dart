import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class MallOrderAftersaleOrderListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MallOrderAftersaleOrderListController>(
        MallOrderAftersaleOrderListController(datas: Get.arguments));
  }
}

class MallOrderAftersaleOrderListController extends GetxController {
  final dynamic datas;
  MallOrderAftersaleOrderListController({this.datas});
}

class MallOrderAftersaleOrderList extends StatelessWidget {
  const MallOrderAftersaleOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "我的售后"),
    );
  }
}
