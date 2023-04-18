import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/login/user_agreement_view.dart';
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MineSettingAboutMeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineSettingAboutMeController>(MineSettingAboutMeController());
  }
}

class MineSettingAboutMeController extends GetxController {
  Map appInfo = {};
  Map userAgreement = {};
  Map privacyAgreement = {};

  loadAgreement(int t) {
    simpleRequest(
      url: Urls.agreementListByID(t),
      params: {},
      success: (success, json) {
        if (success) {
          if (t == 1) {
            userAgreement = json["data"] ?? {};
          } else if (t == 5) {
            privacyAgreement = json["data"] ?? {};
          }

          update();
        }
      },
      after: () {},
    );
  }

  @override
  void onInit() {
    loadAgreement(1);
    loadAgreement(5);
    Map publicHomeData = AppDefault().publicHomeData;
    // Map info = (publicHomeData["webSiteInfo"] ?? {})["app"] ?? {};
    appInfo = {};
    if (!HttpConfig.baseUrl.contains("woliankeji")) {
      Map info = (publicHomeData["webSiteInfo"] ?? {})["app"] ?? {};
      Map systemInfo = (publicHomeData["systemInfo"] ?? {})["system"] ?? {};
      appInfo = {
        "introduction": info["apP_Introduction"] ?? "",
        "copyright": info["apP_Copyright"] ?? "",
        "System_Home_Name": info["apP_Name"] ?? "",
        "System_Home_Logo": info["apP_Logo"] ?? "",
        "System_ServiceHotline": systemInfo["system_ServiceHotline"] ?? "",
      };
    } else if (HttpConfig.baseUrl.contains("woliankeji")) {
      appInfo = publicHomeData["webSiteInfo"] ?? {};
    }
    super.onInit();
  }

  @override
  void onClose() {}
}

class MineSettingAboutMe extends GetView<MineSettingAboutMeController> {
  const MineSettingAboutMe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "关于我们",
            white: true, blueBackground: true),
        body: Stack(
          children: [
            Positioned(
                top: 39.w,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    CustomNetworkImage(
                      src: AppDefault().imageUrl +
                          (controller.appInfo["System_Home_Logo"] ?? ""),
                      height: 85.w,
                      fit: BoxFit.fitHeight,
                    ),
                    ghb(28),
                    getWidthText("${controller.appInfo["introduction"] ?? ""}",
                        15, AppColor.textBlack4, 375 - 22 * 2, 10,
                        strutStyle: const StrutStyle(height: 2.2),
                        textAlign: TextAlign.center,
                        alignment: Alignment.center),
                  ],
                )),
            Positioned(
                bottom: paddingSizeBottom(context) + 26,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    getSimpleText(
                        "版本：${AppDefault().version}.${AppDefault().buildNumber}",
                        14,
                        AppColor.textBlack7),
                    ghb(5),
                    getSimpleText(
                        "服务热线：${controller.appInfo["System_ServiceHotline"] ?? ""}",
                        14,
                        AppColor.textBlack7),
                    ghb(5),
                    getSimpleText("版权所有：${controller.appInfo["copyright"]}", 14,
                        AppColor.textGrey5),
                    ghb(8),
                    policyView(context),
                  ],
                ))
          ],
        ));
  }

  Widget policyView(BuildContext context) {
    return GetBuilder<MineSettingAboutMeController>(
      // id: controller.appInfobuildId,
      initState: (_) {},
      builder: (_) {
        return CustomButton(
          onPressed: () {
            // controller.confirmProtocol = !controller.confirmProtocol;
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getSimpleText("${controller.appInfo["System_Home_Name"] ?? ""}",
                  14, AppColor.textBlack7,
                  textHeight: 1.1),
              CustomButton(
                onPressed: () {
                  if (controller.userAgreement == null ||
                      controller.userAgreement.isEmpty) {
                    ShowToast.normal("请稍等，正在接收数据");
                    return;
                  }
                  pushAg(false, controller.userAgreement["name"] ?? "",
                      controller.userAgreement["content"] ?? "");
                },
                child: getSimpleText("《用户协议》", 14,
                    AppDefault().getThemeColor() ?? AppColor.theme,
                    textHeight: 1.1),
              ),
              getSimpleText("和", 14, AppColor.textBlack7, textHeight: 1.1),
              CustomButton(
                onPressed: () {
                  pushAg(false, controller.privacyAgreement["name"] ?? "",
                      controller.privacyAgreement["content"] ?? "");
                },
                child: getSimpleText("《隐私政策》", 14,
                    AppDefault().getThemeColor() ?? AppColor.theme,
                    textHeight: 1.1),
              ),
            ],
          ),
        );
      },
    );
  }

  void pushAg(bool isP, String t, String u) {
    push(
        () => UserAgreementView(
              isPrivacy: isP,
              title: t,
              url: u,
            ),
        null,
        binding: UserAgreementViewBinding());
  }
}
