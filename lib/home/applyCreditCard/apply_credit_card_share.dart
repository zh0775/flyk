import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ApplyCreditCardShareBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ApplyCreditCardShareController>(ApplyCreditCardShareController());
  }
}

class ApplyCreditCardShareController extends GetxController {
  Map homeData = {};

  @override
  void onInit() {
    homeData = AppDefault().homeData;
    super.onInit();
  }
}

class ApplyCreditCardShare extends GetView<ApplyCreditCardShareController> {
  const ApplyCreditCardShare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF343434),
        body: getInputBodyNoBtn(
          context,
          buttonHeight: 0,
          contentColor: Colors.transparent,
          build: (boxHeight, context) {
            return SingleChildScrollView(
                child: SizedBox(
              width: 375.w,
              height: boxHeight,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: paddingSizeTop(context),
                    ),
                    child: sbRow([
                      defaultBackButton(context, color: Colors.white),
                      getDefaultAppBarTitile("我要推广",
                          titleStyle: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      gwb(50)
                    ]),
                  ),
                  centClm([
                    ghb(10),
                    Container(
                      width: 345.w,
                      decoration: getDefaultWhiteDec(),
                      child: Column(
                        children: [
                          ghb(25.5),
                          centRow([
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22.5.w),
                              child: CustomNetworkImage(
                                src: AppDefault().imageUrl +
                                    (controller.homeData["userAvatar"] ?? ""),
                                width: 45.w,
                                height: 45.w,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            gwb(20),
                            centClm([
                              getSimpleText(
                                  controller.homeData["nickName"] ?? "",
                                  17,
                                  AppColor.textBlack,
                                  isBold: true),
                              ghb(8),
                              getSimpleText(
                                  controller.homeData["u_Mobile"] ?? "",
                                  14,
                                  AppColor.textBlack,
                                  isBold: true),
                            ], crossAxisAlignment: CrossAxisAlignment.start),
                          ]),
                          ghb(24),
                          Container(
                            width: 287.w,
                            height: 181.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.w),
                                color: const Color(0xFF343434)),
                          ),
                          ghb(11),
                          getSimpleText(
                              "消费享双倍积分 现金分期7折优惠", 13, AppColor.textGrey),
                          ghb(15),
                          SizedBox(
                            width: 109.w,
                            height: 109.w,
                          ),
                          ghb(30.5),
                        ],
                      ),
                    )
                  ]),
                  centClm([
                    sbRow([
                      gline(18.5, 1, color: Colors.white),
                      getSimpleText("分享图片到", 14, Colors.white),
                      gline(18.5, 1, color: Colors.white),
                    ], width: 150),
                    ghb(20),
                    CustomButton(
                      onPressed: () {},
                      child: centClm([
                        Image.asset(
                          assetsName("share/save"),
                          width: 23.5.w,
                          fit: BoxFit.fitWidth,
                        ),
                        ghb(8),
                        getSimpleText("保存图片", 12, Colors.white)
                      ]),
                    ),
                  ]),
                ],
              ),
            ));
          },
        ));
  }
}
