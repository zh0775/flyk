import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VipLevelupBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<VipLevelupController>(VipLevelupController(datas: Get.arguments));
  }
}

class VipLevelupController extends GetxController {
  final dynamic datas;
  VipLevelupController({this.datas});
  Map homeData = {};

  @override
  void onInit() {
    homeData = AppDefault().homeData;
    super.onInit();
  }
}

class VipLevelup extends GetView<VipLevelupController> {
  const VipLevelup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "升级攻略"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 375.w,
              height: 212.w,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(assetsName("mine/vip/bg_top")))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  centClm([
                    ghb(74.5),
                    getSimpleText("当前成长值", 14, const Color(0xFFFD4536)),
                    ghb(5),
                    getSimpleText("45962", 36, AppColor.theme, isBold: true),
                  ]),
                  Container(
                    width: 375.w,
                    height: 45.w,
                    color: Colors.white.withOpacity(0.3),
                    alignment: Alignment.center,
                    child: sbRow([
                      Text.rich(TextSpan(
                          text: "升级还需",
                          style: TextStyle(
                              fontSize: 12.sp, color: AppColor.textBlack),
                          children: [
                            TextSpan(
                                text: "6140",
                                style: TextStyle(
                                    fontSize: 12.sp, color: AppColor.theme)),
                            const TextSpan(text: "成长值，可享更多权益")
                          ])),
                      Container(
                        width: 65.w,
                        height: 24.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColor.theme,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: getSimpleText("去升级", 12, Colors.white),
                      )
                    ], width: 345),
                  )
                ],
              ),
            ),
            vipBarView()
          ],
        ),
      ),
    );
  }

  Widget vipBarView() {
    return Container(
      width: 375.w,
      padding: EdgeInsets.only(top: 18.5.w, bottom: 19.w),
      color: Colors.white,
    );
  }
}
