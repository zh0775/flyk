import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MallOrderAftersaleorderDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MallOrderAftersaleorderDetailController>(
        MallOrderAftersaleorderDetailController(datas: Get.arguments));
  }
}

class MallOrderAftersaleorderDetailController extends GetxController {
  final dynamic datas;
  MallOrderAftersaleorderDetailController({this.datas});
}

class MallOrderAftersaleorderDetail extends StatelessWidget {
  const MallOrderAftersaleorderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "售后详情"),
    );
  }
}
