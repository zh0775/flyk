import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/mine_account_manage.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/mine/mine_certificate_authorization.dart';
import 'package:cxhighversion2/mine/mine_protocol_page.dart';
import 'package:cxhighversion2/mine/myWallet/receipt_setting.dart';
import 'package:cxhighversion2/mine/personal_information.dart';
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MineSettingListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineSettingListController>(MineSettingListController());
  }
}

class MineSettingListController extends GetxController {
  final _notifierOpen = false.obs;
  set notifierOpen(value) => _notifierOpen.value = value;
  get notifierOpen => _notifierOpen.value;

  Map homeData = {};

  final _isCanCancel = false.obs;
  get isCanCancel => _isCanCancel.value;
  set isCanCancel(v) => _isCanCancel.value = v;

  final _userAgreement = Rx<Map>({});
  Map get userAgreement => _userAgreement.value;
  set userAgreement(v) => _userAgreement.value = v;

  final _privacyAgreement = Rx<Map>({});
  Map get privacyAgreement => _privacyAgreement.value;
  set privacyAgreement(v) => _privacyAgreement.value = v;
  loadAgreement() {
    simpleRequest(
      url: Urls.agreementListByID(1),
      params: {},
      success: (success, json) {
        if (success) {
          userAgreement = json["data"] ?? {};
        }
      },
      after: () {},
    );
  }

  loadPrivacy() {
    simpleRequest(
      url: Urls.agreementListByID(5),
      params: {},
      success: (success, json) {
        if (success) {
          privacyAgreement = json["data"] ?? {};
        }
      },
      after: () {},
    );
  }

  cancelAction() {
    showAlert(Global.navigatorKey.currentContext!, "1分钟“几百万”上下 确定留不住你？",
        confirmOnPressed: () {
      simpleRequest(
          url: Urls.userCancel,
          params: {},
          success: (success, json) {
            if (success) {
              ShowToast.normal("注销成功");
              setUserDataFormat(false, {}, {}, {})
                  .then((value) => popToLogin());
            }
          },
          after: () {});
    });
  }

  @override
  void onReady() {
    loadAgreement();
    loadPrivacy();
    super.onReady();
  }

  String aboutMeInfoContent = "";
  @override
  void onInit() {
    if (HttpConfig.baseUrl.contains(AppDefault.oldSystem)) {
      aboutMeInfoContent = (AppDefault().publicHomeData["webSiteInfo"] ??
              {})["System_Introduction"] ??
          "";
    } else {
      aboutMeInfoContent =
          ((AppDefault().publicHomeData["webSiteInfo"] ?? {})["app"] ??
                  {})["apP_Introduction"] ??
              "";
    }
    isCanCancel = homeData["isCanCancel"] ?? false;
    loadData();
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onInit();
  }

  homeDataNotify(arg) {
    loadData();
  }

  loadData() {
    homeData = AppDefault().homeData;
    // isAuth = (homeData["authentication"] ?? {})["isCertified"] ?? false;
    update();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onClose();
  }
}

class MineSettingList extends GetView<MineSettingListController> {
  const MineSettingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "设置", color: Colors.white),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ghb(1),
              GetBuilder<MineSettingListController>(
                builder: (_) {
                  return cell(
                    "编辑资料",
                    0,
                    t2: "修改",
                    onPressed: () {
                      push(const PersonalInformation(), context,
                          binding: PersonalInformationBinding());
                    },
                  );
                },
              ),
              ghb(15),
              cell(
                "账户安全",
                0,
                onPressed: () {
                  push(const MineChangePwdList(), context);
                },
              ),
              cell(
                "更换手机号",
                0,
                onPressed: () {
                  push(const ReceiptSetting(), context,
                      binding: ReceiptSettingBinding());
                },
              ),
              cell(
                "地址管理",
                0,
                onPressed: () {
                  push(const MineAddressManager(), context,
                      binding: MineAddressManagerBinding());
                },
              ),
              ghb(15),
              cell(
                "相关协议",
                0,
                onPressed: () {
                  if (controller.userAgreement.isEmpty) {
                    ShowToast.normal("正在获取数据，请稍后...");
                    return;
                  }
                  push(
                      OtherPolicyPage(
                          userRegistPolicy:
                              controller.userAgreement["content"] ?? "",
                          userServicePolicy:
                              controller.userAgreement["content"] ?? ""),
                      context);
                },
              ),
              cell(
                "授权证书",
                0,
                onPressed: () {
                  push(const MineCertificateAuthorization(), context,
                      binding: MineCertificateAuthorizationBinding());
                },
              ),
              cell(
                "隐私政策",
                0,
                onPressed: () {
                  if (controller.privacyAgreement.isEmpty) {
                    ShowToast.normal("正在获取数据，请稍后...");
                    return;
                  }
                  push(
                      MineProtocolPage(
                        title: "隐私政策",
                        src: controller.privacyAgreement["content"] ?? "",
                      ),
                      context);
                },
              ),
              ghb(15),
              cell(
                "关于我们",
                0,
                onPressed: () {
                  push(
                      MineProtocolPage(
                        title: "关于我们",
                        src: controller.aboutMeInfoContent,
                      ),
                      context);
                },
              ),
              cell(
                "版本更新",
                0,
                t2: "V ${AppDefault().version}.${AppDefault().buildNumber}",
                onPressed: () {},
              ),
              ghb(15),
              cell(
                "安全退出",
                0,
                onPressed: () {
                  showAlert(
                    context,
                    "您确定要退出当前账户吗",
                    title: "退出登录",
                    cancelText: "取消",
                    confirmBtnColor: Colors.white,
                    confirmStyle:
                        TextStyle(fontSize: 16.sp, color: AppColor.theme),
                    confirmOnPressed: () {
                      setUserDataFormat(false, {}, {}, {})
                          .then((value) => popToLogin());
                    },
                  );
                },
              ),
            ],
          ),
        ));
  }

  Widget cell(String t1, int type,
      {Function()? onPressed,
      String? t2,
      bool needLine = true,
      bool topLine = false}) {
    // String img = "icon_zhgl";
    switch (t1) {
      case "账号管理":
        // img = "icon_zhgl";
        break;
      case "关于我们":
        // img = "icon_aboutme";
        break;
      case "注销账号":
        // img = "icon_zxzh";
        break;
      case "退出登录":
        // img = "icon_logout";
        break;
    }

    return CustomButton(
        onPressed: onPressed,
        child: Center(
          child: Container(
            width: 375.w,
            height: 55.w,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: t1 == "安全退出"
                  ? getSimpleText("安全退出", 16, const Color(0xFFF93635))
                  : sbhRow([
                      centRow([
                        gwb(6.5),
                        getSimpleText(t1, 16, AppColor.textBlack)
                      ]),
                      centRow([
                        t2 != null
                            ? getSimpleText(t2, 16, AppColor.textGrey5)
                            : gwb(0),
                        Image.asset(
                          assetsName("statistics/icon_arrow_right_gray"),
                          width: 18.w,
                          fit: BoxFit.fitWidth,
                        )
                      ])
                    ], width: 375 - 24.5 * 2, height: 55),
            ),
          ),
        ));
  }
}

// 相关协议
class OtherPolicyPage extends StatelessWidget {
  final String userServicePolicy;
  final String userRegistPolicy;
  const OtherPolicyPage(
      {super.key, this.userServicePolicy = "", this.userRegistPolicy = ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "相关协议"),
        body: Column(
          children: [
            gline(375, 0.5),
            ...List.generate(
                2,
                (index) => CustomButton(
                      onPressed: () {
                        push(
                            MineProtocolPage(
                                title: index == 0 ? "用户服务协议" : "用户注册协议",
                                src: index == 0
                                    ? userServicePolicy
                                    : userRegistPolicy),
                            context);
                      },
                      child: Container(
                        width: 375.w,
                        height: 55.w,
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: sbRow([
                          getSimpleText(index == 0 ? "用户服务协议" : "用户注册协议", 16,
                              AppColor.textBlack),
                          Image.asset(
                            assetsName("statistics/icon_arrow_right_gray"),
                            width: 18.w,
                            fit: BoxFit.fitWidth,
                          )
                        ], width: 375 - 24 * 2),
                      ),
                    ))
          ],
        ));
  }
}
