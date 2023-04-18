import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_check.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_success.dart';
import 'package:cxhighversion2/mine/myWallet/receipt_setting.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IdentityAuthenticationAlipayBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IdentityAuthenticationAlipayController>(
        IdentityAuthenticationAlipayController());
  }
}

class IdentityAuthenticationAlipayController extends GetxController {
  bool isFirst = true;
  BuildContext? context;
  final accountInputCtrl = TextEditingController();

  String payPassword = "";

  BottomPayPassword? bottomPayPassword;
  bool isAdd = false;

  dataInit(BuildContext? ctx, bool add) {
    if (!isFirst) return;
    isFirst = false;
    context = ctx;
    isAdd = add;
    bottomPayPassword = BottomPayPassword.init(
      // context: context,
      confirmClick: (payPwd) {
        takeBackKeyboard(Global.navigatorKey.currentContext!);
        payPassword = payPwd;
        submitAction();
      },
    );
  }

  setAlipayAction() {
    if (accountInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入您的支付宝账户");
      return;
    }
    if (homeData["u_3rd_password"] == null ||
        homeData["u_3rd_password"].isEmpty) {
      showPayPwdWarn(
        haveClose: true,
        popToRoot: false,
        untilToRoot: false,
        setSuccess: () {},
      );
      return;
    }
    bottomPayPassword?.show();
  }

  userAliPayEditRequest(Map<String, dynamic> params,
      Function(bool success, dynamic json) success) {
    Http().doPost(
      Urls.userAliPayEdit,
      params,
      success: (json) async {
        if (json["success"]) {
          if (success != null) {
            success(true, json);
          }
        } else {
          if (success != null) {
            success(false, json);
          }
        }
      },
      fail: (reason, code, json) {
        if (success != null) {
          success(false, json);
        }
      },
    );
  }

  submitAction() {
    if (accountInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入支付宝账号");
      return;
    }
    if (accountInputCtrl.text.length < 4 || accountInputCtrl.text.length > 28) {
      ShowToast.normal("支付宝账号为4到28位");
      return;
    }
    if (payPassword.isEmpty) {
      ShowToast.normal("请输入支付密码");
      return;
    }
    if (payPassword.length < 6) {
      ShowToast.normal("请输入6位支付密码");
      return;
    }

    simpleRequest(
      url: Urls.userAliPayEdit,
      params: {
        "name": authData["u_Name"] ?? "",
        "account": accountInputCtrl.text,
        "u_3nd_Pad": payPassword
      },
      success: (success, json) {
        if (success) {
          // ShowToast.normal("支付宝绑定成功");
          Get.find<HomeController>().refreshHomeData();
          Future.delayed(const Duration(seconds: 1), () {
            // Get.to(
            //     IdentityAuthenticationSuccess(
            //       alipayNoAuth: false,
            //       title: "${isAdd ? "提交" : "修改"}成功",
            //       subTitle: "您的支付宝信息已${isAdd ? "提交" : "修改"}成功，平台已审批通过",
            //     ),
            //     binding: IdentityAuthenticationSuccessBinding());
            Get.offUntil(
                GetPageRoute(
                    page: () => const IdentityAuthenticationCheck(
                          isAlipay: true,
                        ),
                    binding: IdentityAuthenticationCheckBinding()),
                (route) => route is GetPageRoute
                    ? route.binding is ReceiptSettingBinding
                        ? true
                        : false
                    : false);
          });
        }
      },
      after: () {},
    );
  }

  Map homeData = {};
  Map authData = {};
  bool authAlipay = false;
  @override
  void onInit() {
    homeData = AppDefault().homeData;
    authData = homeData["authentication"] ?? {};
    authAlipay = authData["isAliPay"] ?? false;
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    super.onInit();
  }

  getHomeDataNotify(arg) {
    homeData = AppDefault().homeData;
    authData = homeData["authentication"] ?? {};
    authAlipay = authData["isAliPay"] ?? false;
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    bottomPayPassword!.dispos();
    accountInputCtrl.dispose();
    super.onClose();
  }
}

class IdentityAuthenticationAlipay
    extends GetView<IdentityAuthenticationAlipayController> {
  final bool isAdd;
  const IdentityAuthenticationAlipay({Key? key, this.isAdd = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(context, isAdd);
    return GestureDetector(
        onTap: () => takeBackKeyboard(context),
        child: Scaffold(
          appBar: getDefaultAppBar(
            context,
            isAdd ? "支付宝认证" : "修改支付宝",
          ),
          body: getInputBodyNoBtn(
            context,
            buttonHeight: 0,
            build: (boxHeight, context) {
              return SizedBox(
                width: 375.w,
                height: boxHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      sbhRow([
                        getSimpleText("请确认绑定的支付宝账号与实名信息一致", 12, AppColor.text3)
                      ], width: 375 - 15 * 2, height: 34),
                      Container(
                        width: 375.w,
                        color: Colors.white,
                        child: Column(
                          children: List.generate(
                              3,
                              (index) => index == 1
                                  ? gline(345, 1)
                                  : SizedBox(
                                      height: 54.5.w,
                                      child: Center(
                                        child: Row(
                                          children: [
                                            gwb(15),
                                            getWidthText(
                                                index == 0 ? "姓名" : "身份证号",
                                                15,
                                                AppColor.text3,
                                                90,
                                                1),
                                            getWidthText(
                                                index == 0
                                                    ? controller.authData[
                                                            "u_Name"] ??
                                                        ""
                                                    : controller.authData[
                                                            "u_IdCard"] ??
                                                        "",
                                                15,
                                                AppColor.text2,
                                                345 - 90 - 1,
                                                1),
                                          ],
                                        ),
                                      ),
                                    )),
                        ),
                      ),
                      ghb(10),
                      Container(
                        width: 375.w,
                        height: 55.w,
                        color: Colors.white,
                        child: Center(
                            child: Row(
                          children: [
                            gwb(15),
                            getWidthText("支付宝账号", 15, AppColor.text3, 90, 1),
                            CustomInput(
                              width: 345.w - 90.w,
                              heigth: 55.w,
                              placeholder: "请输入支付宝账号",
                              textEditCtrl: controller.accountInputCtrl,
                              style: TextStyle(
                                color: AppColor.text,
                                fontSize: 15.w,
                              ),
                              placeholderStyle: TextStyle(
                                color: AppColor.assisText,
                                fontSize: 15.w,
                              ),
                            ),
                          ],
                        )),
                      ),
                      ghb(31),
                      getSubmitBtn("提交", () {
                        controller.setAlipayAction();
                      }, height: 45, color: AppColor.theme),
                    ],
                  ),
                ),
              );
            },
          ),

          //     Builder(builder: (ctx) {
          //   return SingleChildScrollView(
          //     child: Column(
          //       children: [

          //       ],
          //     ),
          //   );
          // })),
        ));
  }
}
