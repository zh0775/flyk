import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/mine/mine_account_manage.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/mine/mine_setting_aboutme.dart';
import 'package:cxhighversion2/mine/myWallet/receipt_setting.dart';
import 'package:cxhighversion2/mine/personal_information.dart';
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
  bool isAuth = false;

  final _isCanCancel = false.obs;
  get isCanCancel => _isCanCancel.value;
  set isCanCancel(v) => _isCanCancel.value = v;

  cancelAction() {
    showAlert(
      Global.navigatorKey.currentContext!,
      "1分钟“几百万”上下 确定留不住你？",
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
          after: () {},
        );
      },
    );
    // Get.until((route) {
    //   if (route is GetPageRoute) {
    //     if (route.binding is AppBinding) {
    //       return true;
    //     }
    //     return false;
    //   } else {
    //     return false;
    //   }
    // });
  }

  @override
  void onInit() {
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
    isAuth = (homeData["authentication"] ?? {})["isCertified"] ?? false;
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
                    "个人中心",
                    0,
                    t2: "${controller.isAuth ? "已" : "未"}认证",
                    onPressed: () {
                      push(const PersonalInformation(), context,
                          binding: PersonalInformationBinding());
                    },
                  );
                },
              ),

              ghb(15),
              cell(
                "安全中心",
                0,
                onPressed: () {
                  push(const MineChangePwdList(), context);
                },
              ),
              cell(
                "收款设置",
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
                "版本更新",
                0,
                t2: AppDefault().version,
                onPressed: () {},
              ),

              ghb(15),
              cell(
                "安全退出",
                0,
                onPressed: () {
                  showAlert(
                    context,
                    "确定要退出吗？",
                    confirmOnPressed: () {
                      setUserDataFormat(false, {}, {}, {})
                          .then((value) => popToLogin());
                    },
                  );
                },
              ),

              // ghb(15),

              // cell(
              //   "账号管理",
              //   0,
              //   onPressed: () {
              //     push(
              //       const MineAccountManage(),
              //       context,
              //       binding: MineAccountManageBinding(),
              //     );
              //   },
              // ),

              // cell(
              //   "地址管理",
              //   0,
              //   onPressed: () {
              //     Get.to(const MineAddressManager(),
              //         binding: MineAddressManagerBinding());
              //   },
              // ),

              // cell(
              //   "关于我们",
              //   0,
              //   onPressed: () {
              //     push(const MineSettingAboutMe(), context,
              //         binding: MineSettingAboutMeBinding());
              //   },
              // ),
              // cell(
              //   "设置支付密码",
              //   0,
              //   onPressed: () {
              //     push(
              //         const MineVerifyIdentity(
              //           type: MineVerifyIdentityType.setPayPassword,
              //         ),
              //         null,
              //         binding: MineVerifyIdentityBinding());
              //   },
              // ),
              // cell(
              //   "修改登陆密码",
              //   0,
              //   onPressed: () {
              //     push(
              //         const MineVerifyIdentity(
              //           type: MineVerifyIdentityType.changeLoginPassword,
              //         ),
              //         null,
              //         binding: MineVerifyIdentityBinding());
              //   },
              // ),
              // cell(
              //   "意见反馈",
              //   0,
              //   onPressed: () {
              //     Get.to(const MineFeedback(), binding: MineFeedbackBinding());
              //   },
              // ),
              // cell("当前版本", 1, onPressed: () {}, t2: "V${AppDefault().version}"),
              // GetX<MineSettingListController>(
              //   init: controller,
              //   builder: (_) {
              //     return controller.isCanCancel
              //         ? cell("注销账号", 2, onPressed: () {
              //             controller.cancelAction();
              //             // showAlert(
              //             //   context,
              //             //   "确定要注销您的账号吗？",
              //             //   confirmOnPressed: () {
              //             //     controller.cancelAction();
              //             //   },
              //             // );
              //           }, needLine: false)
              //         : ghb(0);
              //   },
              // ),
              // cell("退出登录", 2, onPressed: () {
              //   showAlert(
              //     context,
              //     "确定要退出吗？",
              //     confirmOnPressed: () {
              //       setUserDataFormat(false, {}, {}, {})
              //           .then((value) => popToLogin());
              //     },
              //   );
              // }, needLine: false)
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
                  ? getSimpleText("安全退出", 15, const Color(0xFFF93635))
                  : sbhRow([
                      centRow(
                          [gwb(6.5), getSimpleText(t1, 15, AppColor.text2)]),
                      centRow([
                        t2 != null
                            ? getSimpleText(t2, 15, AppColor.text3)
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
        )

        // centClm([
        //   sbhRow([
        //     getSimpleText(t1, 16, AppColor.textBlack, isBold: true),
        //     type == 0
        //         ? Image.asset(
        //             assetsName("common/icon_cell_right_arrow"),
        //             width: 20.w,
        //             fit: BoxFit.fitWidth,
        //           )
        //         : type == 1
        //             ? getSimpleText(t2 ?? "", 14, AppColor.textGrey)
        //             : const SizedBox(),
        //   ], height: 70, width: 345 - 19.5 * 2),
        //   needLine ? gline(345, 0.5) : const SizedBox(),
        // ]),
        );
  }

  showBackAlert(BuildContext context) {
    showAlert(
      context,
      "1分钟“几百万”上下 确定留不住你？",
      confirmOnPressed: () {
        Get.until((route) {
          if (route is GetPageRoute) {
            if (route.binding is MainPageBinding) {
              return true;
            }
            return false;
          } else {
            return false;
          }
        });
      },
    );
  }
}
