import 'package:cxhighversion2/component/custom_background.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class MemberChargeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MemberChargeController>(MemberChargeController());
  }
}

class MemberChargeController extends GetxController {
  Map homeData = {};
  Map publicHomeData = {};

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  List levelDatas = [];

  loadData() {
    simpleRequest(
        url: Urls.memberCharge,
        params: {},
        success: (success, json) {
          if (success) {
            levelDatas = json["data"] ?? [];
            update();
          }
        },
        after: () {},
        useCache: true);
  }
}

class MemberCharge extends GetView<MemberChargeController> {
  const MemberCharge({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getDefaultAppBar(context, "市场政策",
          flexibleSpace: const CustomBackground()),
      body: Stack(
        children: [
          const Positioned.fill(child: CustomBackground()),
          Positioned.fill(child: GetBuilder<MemberChargeController>(
            builder: (_) {
              return PageView.builder(
                itemCount: controller.levelDatas.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 345.w,
                      child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              ghb(20),
                              HtmlWidget(controller.levelDatas[index]
                                      ["content"] ??
                                  ""),
                              ghb(20),
                            ],
                          )),
                    ),
                  );
                },
              );
            },
          ))
        ],
      ),
    );
  }
}
