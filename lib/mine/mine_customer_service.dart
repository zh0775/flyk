import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MineCustomerServiceBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineCustomerServiceController>(MineCustomerServiceController());
  }
}

class MineCustomerServiceController extends GetxController {
  Map publicHomeData = {};
  Map webSiteInfo = {};

  @override
  void onInit() {
    publicHomeData = AppDefault().publicHomeData;
    if (HttpConfig.baseUrl.contains(AppDefault.oldSystem)) {
      webSiteInfo = (publicHomeData["systemInfo"] ?? {})["system"] ?? {};
    } else {
      webSiteInfo = (publicHomeData["systemInfo"] ?? {})["system"] ?? {};
    }

    super.onInit();
  }
}

class MineCustomerService extends GetView<MineCustomerServiceController> {
  const MineCustomerService({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          getDefaultAppBar(context, "联系客服", white: true, blueBackground: true),
      backgroundColor: AppColor.pageBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
              child: SingleChildScrollView(
            child: Column(
              children: [
                ghb(24),
                sbRow([
                  getSimpleText("联系方式", 18, Colors.black, fw: FontWeight.w500),
                ], width: 375 - 24 * 2),
                ghb(3),
                getWidthText(
                    "您可拨打电话联系客服", 14, const Color(0xFF4D4D4D), 375 - 24 * 2, 2),
                ghb(13),
                GetBuilder<MineCustomerServiceController>(
                  init: controller,
                  builder: (_) {
                    return serviceCell(
                      "share/icon_kf_phone",
                      controller.webSiteInfo != null &&
                              controller.webSiteInfo["system_ServiceHotline"] !=
                                  null
                          ? controller.webSiteInfo["system_ServiceHotline"]
                          : "",
                      null,
                      "拨号",
                      onPressed: () {
                        if (controller.webSiteInfo != null &&
                            controller.webSiteInfo["system_ServiceHotline"] !=
                                null &&
                            controller.webSiteInfo["system_ServiceHotline"] !=
                                "暂无") {
                          callPhone(
                              controller.webSiteInfo["system_ServiceHotline"]);
                        } else {
                          ShowToast.normal("暂未配置咨询电话，请联系管理员");
                        }
                      },
                    );
                  },
                ),
                // ghb(13),
                // GetBuilder<MineCustomerServiceController>(
                //   init: controller,
                //   builder: (_) {
                //     return serviceCell(
                //       "share/icon_kf_wx",
                //       "微信号",
                //       // controller.webSiteInfo != null &&
                //       //         controller.webSiteInfo["System_WeChat"] != null
                //       //     ? controller.webSiteInfo["System_WeChat"]
                //       //     : "",
                //       null,
                //       "",
                //       onPressed: () {
                //         if (controller.webSiteInfo != null &&
                //             controller.webSiteInfo["system_WeChat"] != null &&
                //             controller.webSiteInfo["system_WeChat"] != "暂无") {
                //           copyClipboard(
                //               controller.webSiteInfo["system_WeChat"]);
                //         } else {
                //           ShowToast.normal("暂未配置客服微信，请联系管理员");
                //         }
                //       },
                //     );
                //   },
                // ),
                // ghb(controller.webSiteInfo["system_WeChatOfficial"] == null ||
                //         controller.webSiteInfo["system_WeChatOfficial"].isEmpty
                //     ? 0
                //     : 13),
                // GetBuilder<MineCustomerServiceController>(
                //   init: controller,
                //   builder: (_) {
                //     return controller.webSiteInfo["system_WeChatOfficial"] ==
                //                 null ||
                //             controller
                //                 .webSiteInfo["system_WeChatOfficial"].isEmpty
                //         ? ghb(0)
                //         : serviceCell(
                //             "share/icon_kf_gzh",
                //             "微信公众号",
                //             null,
                //             "保存",
                //             onPressed: () {
                //               if (controller.webSiteInfo != null &&
                //                   controller.webSiteInfo[
                //                           "system_WeChatOfficial"] !=
                //                       null &&
                //                   controller
                //                           .webSiteInfo["system_WeChatOfficial"]
                //                           .length >
                //                       0) {
                //                 copyClipboard(controller
                //                     .webSiteInfo["system_WeChatOfficial"]);
                //                 // saveNetWorkImgToAlbum(AppDefault().imageUrl +
                //                 //     controller.webSiteInfo["system_WeChatQRCode"]);
                //               } else {
                //                 ShowToast.normal("暂未配置微信公众号，请联系管理员");
                //               }
                //             },
                //           );
                //   },
                // ),
                ghb(50),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget serviceCell(String? img, String t1, String? t2, String btnTitle,
      {Function()? onPressed}) {
    return Container(
        width: 345.w,
        height: 70.w,
        decoration: getDefaultWhiteDec2(),
        child: Center(
          child: sbhRow([
            centRow([
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                    AppDefault().getThemeColor() ?? Colors.white,
                    BlendMode.modulate),
                child: Image.asset(
                  img != null && img.isNotEmpty
                      ? assetsName(img)
                      : assetsName("share/wx_friend"),
                  width: 40.w,
                  // height: 40.w,
                  fit: BoxFit.fitWidth,
                ),
              ),
              gwb(25),
              getSimpleText(t1, 20, Colors.black, fw: FontWeight.w500),
            ]),
            CustomButton(
              onPressed: onPressed,
              child: SizedBox(
                width: 30.w,
                height: 70.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    assetsName("share/icon_kf_copy"),
                    width: 18.w,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            )
          ], width: 345 - 15 * 2, height: 70),
        )

        // Column(
        //   children: [
        //     ghb(18),
        //     sbRow([
        //       Image.asset(
        //         img != null && img.isNotEmpty
        //             ? assetsName(img)
        //             : assetsName("share/wx_friend"),
        //         width: 40.w,
        //         // height: 40.w,
        //         fit: BoxFit.fitWidth,
        //       ),
        //       centClm([
        //         getSimpleText(t1, 16, AppColor.textBlack, isBold: true),
        //         ghb(10),
        //         sbRow(
        //           [
        //             getSimpleText(t2, 16, AppColor.textBlack),
        //             CustomButton(
        //               onPressed: onPressed,
        //               child: Container(
        //                 width: 47.w,
        //                 height: 22.w,
        //                 decoration: BoxDecoration(
        //                     color: AppColor.textBlack,
        //                     borderRadius: BorderRadius.circular(5.w)),
        //                 child: Center(
        //                     child: getSimpleText(btnTitle, 12, Colors.white)),
        //               ),
        //             )
        //           ],
        //           width: 215,
        //         )
        //       ], crossAxisAlignment: CrossAxisAlignment.start),
        //     ], width: 317 - 21 * 2),
        //     ghb(18),
        //   ],
        // ),
        );
  }
}
