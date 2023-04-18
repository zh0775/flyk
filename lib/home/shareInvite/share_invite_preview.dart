import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/asperct_raio_image.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class ShareInvitePreviewBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ShareInvitePreviewController>(ShareInvitePreviewController());
  }
}

class ShareInvitePreviewController extends GetxController {
  Map homeData = {};

  @override
  void onInit() {
    homeData = AppDefault().homeData;
    super.onInit();
  }
}

class ShareInvitePreview extends GetView<ShareInvitePreviewController> {
  final bool haveInfo;
  final String image;
  const ShareInvitePreview(
      {Key? key, required this.haveInfo, required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: getDefaultAppBar(context, "", leading: gwb(0), action: [
          CustomButton(
            onPressed: () {
              Get.back();
            },
            child: SizedBox(
              width: 70.w,
              height: kToolbarHeight,
              child: Center(
                child:
                    getSimpleText("取消", 14, AppColor.textBlack, isBold: true),
              ),
            ),
          ),
        ]),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                // AsperctRaioImage.asset(
                //   assetsName(image),
                //   builder: (context, snapshot, url) {
                //     return Image.asset(assetsName(image),width: 375.w,fit: BoxFit.fitWidth,);
                //   },
                // )
                Image.asset(
                  assetsName(image),
                  width: 375.w,
                  fit: BoxFit.fitWidth,
                ),
                Container(
                  width: 375.w,
                  height: 70.w,
                  color: Colors.white,
                  child: Center(
                    child: sbRow([
                      haveInfo
                          ? centClm([
                              getSimpleText(
                                  controller.homeData["nickName"].isEmpty
                                      ? controller.homeData["u_Mobile"]
                                      : controller.homeData["nickName"],
                                  20,
                                  AppColor.textBlack,
                                  isBold: true),
                              ghb(8),
                              getSimpleText(
                                  "推荐码：${controller.homeData["u_Number"] ?? ""}",
                                  13,
                                  AppColor.textBlack),
                            ], crossAxisAlignment: CrossAxisAlignment.start)
                          : gwb(0),
                      // Image.asset("",width: 60.5.w,height: 60.w,),
                    ], width: 375 - 24 * 2),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
