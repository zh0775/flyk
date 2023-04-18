import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/mine_change_password.dart';
import 'package:cxhighversion2/mine/mine_change_phone.dart';
import 'package:cxhighversion2/mine/mine_verify_identity.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MineAccountManageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineAccountManageController>(MineAccountManageController());
  }
}

class MineAccountManageController extends GetxController {
  final _openBackPhone = false.obs;
  bool get openBackPhone => _openBackPhone.value;
  set openBackPhone(v) => _openBackPhone.value = v;

  final _isHaveBackPhone = false.obs;
  bool get isHaveBackPhone => _isHaveBackPhone.value;
  set isHaveBackPhone(v) => _isHaveBackPhone.value = v;

  Map homeData = {};

  @override
  void onInit() {
    getHomeData();
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);

    super.onInit();
  }

  getHomeDataNotify(arg) {
    getHomeData();
  }

  getHomeData() {
    homeData = AppDefault().homeData;
    openBackPhone = (homeData["isMobile"] ?? 0) == 1;
    isHaveBackPhone = (homeData["u_Mobile2"] ?? "").isNotEmpty;
    update();
  }

  useBackPhoneAction() {
    simpleRequest(
      url: Urls.userIsBackupMobile,
      params: {},
      success: (success, json) {
        if (success) {
          Get.find<HomeController>().refreshHomeData();
          if (json["messages"] != null && json["messages"].isNotEmpty) {
            ShowToast.normal(json["messages"]);
          }
        }
      },
      after: () {},
    );
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    super.onClose();
  }
}

class MineAccountManage extends GetView<MineAccountManageController> {
  const MineAccountManage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "账号管理"),
      body: GetBuilder<MineAccountManageController>(
        init: controller,
        initState: (_) {},
        builder: (_) {
          return Column(
            children: [
              ghb(15),
              cell("手机号", 0,
                  needArrow: false,
                  t2: "${controller.homeData["u_Mobile"] ?? ""}"),
              cell("用户ID", 1,
                  needArrow: false,
                  t2: "${controller.homeData["u_Number"] ?? ""}"),
              cell(
                "密码设置",
                2,
                onPressed: () {
                  push(const MineChangePwdList(), context);
                },
              ),
              cell(
                "备用手机号",
                3,
                t2: "${controller.homeData["u_Mobile2"] == null || controller.homeData["u_Mobile2"].isEmpty ? "未设置" : controller.homeData["u_Mobile2"]}",
                onPressed: () {
                  push(const MineChangePhone(), context,
                      binding: MineChangePhoneBinding());
                },
              ),
              GetX<MineAccountManageController>(
                builder: (_) {
                  return controller.isHaveBackPhone
                      ? cell("备用手机号接收短信验证码", 4, needArrow: false)
                      : ghb(0);
                },
              )
            ],
          );
        },
      ),
    );
  }

  Widget cell(
    String t1,
    int type, {
    Function()? onPressed,
    String? t2,
    bool needArrow = true,
  }) {
    String img = "icon_zhgl";
    switch (type) {
      case 0:
        img = "icon_phone";
        break;
      case 1:
        img = "icon_userid";
        break;
      case 2:
        img = "icon_pwd";
        break;
      case 3:
        img = "icon_phone";
        break;
      case 4:
        img = "icon_otherphone";
        break;
    }

    return CustomButton(
        onPressed: onPressed,
        child: Center(
          child: Container(
            width: 345.w,
            height: 54.w,
            margin: EdgeInsets.only(top: 8.w),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.w),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 4.w),
                      color: const Color(0x19C8C8C8),
                      blurRadius: 8.w)
                ]),
            child: Center(
              child: sbhRow([
                centRow([
                  gwb(7),
                  Image.asset(
                    assetsName("mine/userinfo/$img"),
                    width: 16.w,
                    fit: BoxFit.fitWidth,
                  ),
                  gwb(12),
                  getSimpleText(t1, 15, AppColor.textBlack4)
                ]),
                centRow([
                  t2 != null
                      ? centRow(
                          [getSimpleText(t2, 15, AppColor.textBlack4), gwb(7)])
                      : gwb(0),
                  needArrow
                      ? Image.asset(
                          assetsName("mine/userinfo/icon_right_arrow_gray"),
                          width: 20.w,
                          fit: BoxFit.fitWidth,
                        )
                      : gwb(0),
                  type == 4
                      ? centRow([
                          GetX<MineAccountManageController>(
                            builder: (_) {
                              return CupertinoSwitch(
                                value: controller.openBackPhone,
                                onChanged: (value) {
                                  controller.useBackPhoneAction();
                                  // controller.openBackPhone = value;
                                },
                              );
                            },
                          )
                        ])
                      : gwb(0)
                ]),
              ], width: 345 - 18 * 2, height: 54),
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
}

class MineChangePwdList extends StatelessWidget {
  const MineChangePwdList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "密码设置", color: Colors.white),
      body: Column(
        children: [
          gwb(375),
          sbhRow([
            getSimpleText("登录密码设置", 12, AppColor.text3),
          ], width: 375 - 15 * 2, height: 51),
          cell(
            "修改登录密码",
            onPressed: () {
              push(const MineChangePassword(), context,
                  binding: MineChangePasswordBinding());
            },
          ),
          sbhRow([
            getSimpleText("支付密码设置", 12, AppColor.text3),
          ], width: 375 - 15 * 2, height: 51),
          cell(
            "修改支付密码",
            onPressed: () {
              push(
                  const MineVerifyIdentity(
                    type: MineVerifyIdentityType.setPayPassword,
                  ),
                  context,
                  binding: MineVerifyIdentityBinding());
            },
          ),
        ],
      ),
    );
  }

  Widget cell(String t1,
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
}
