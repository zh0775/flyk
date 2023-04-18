import 'package:cxhighversion2/component/authcode_button.dart';
import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_pwd_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MineChangePhoneBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineChangePhoneController>(MineChangePhoneController());
  }
}

class MineChangePhoneController extends GetxController {
  CustomPwdInputController backPhoneInputCtrl = CustomPwdInputController();
  CustomPwdInputController smsInputCtrl = CustomPwdInputController();

  Map source = {"phone": "", "sms": ""};

  final _buttonEnable = true.obs;
  bool get buttonEnable => _buttonEnable.value;
  set buttonEnable(v) => _buttonEnable.value = v;

  final _authButtonState = Rx<AuthCodeButtonState>(AuthCodeButtonState.first);
  set authButtonState(value) => _authButtonState.value = value;
  get authButtonState => _authButtonState.value;

  loadCode() {
    String phone = source["phone"] ?? "";
    if (phone.isEmpty) {
      backPhoneInputCtrl.errorValue = "请输入备用手机号";
      return;
    } else {
      backPhoneInputCtrl.errorValue = "";
    }

    if (!isMobilePhoneNumber(phone)) {
      backPhoneInputCtrl.errorValue = "请输入正确的手机号";
      return;
    } else {
      backPhoneInputCtrl.errorValue = "";
    }
    sendAuthCode(
        Urls.sendCodeAfterLogin,
        {
          "type": 5,
          "u_Mobile2": phone,
        },
        (success) => null);
  }

  sendAuthCode(String url, Map<String, dynamic> params,
      Function(bool success)? success) {
    authButtonState = AuthCodeButtonState.sendAndWait;
    Http().doPost(
      url,
      params,
      success: (json) {
        ShowToast.normal(json["messages"]);
        authButtonState = AuthCodeButtonState.countDown;
        if (success != null) {
          success(true);
        }
      },
      fail: (reason, code, json) {
        authButtonState = AuthCodeButtonState.again;
        if (success != null) {
          success(false);
        }
      },
    );
  }

  changeBackPhoneAction() {
    String phone = source["phone"] ?? "";
    String sms = source["sms"] ?? "";
    if (phone.isEmpty) {
      backPhoneInputCtrl.errorValue = "请输入备用机号";
      return;
    } else {
      backPhoneInputCtrl.errorValue = "";
    }

    if (!isMobilePhoneNumber(phone)) {
      backPhoneInputCtrl.errorValue = "请输入正确的手机号";
      return;
    } else {
      backPhoneInputCtrl.errorValue = "";
    }

    if (sms.isEmpty) {
      smsInputCtrl.errorValue = "请输入验证码";
      return;
    } else {
      smsInputCtrl.errorValue = "";
    }
    if (AppDefault().homeData["u_3rd_password"] == null ||
        AppDefault().homeData["u_3rd_password"].isEmpty) {
      showPayPwdWarn(
        haveClose: true,
        popToRoot: false,
        untilToRoot: false,
        setSuccess: () {},
      );
      return;
    }
    bottomPayPassword.show();
  }

  late BottomPayPassword bottomPayPassword;

  @override
  void onInit() {
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        buttonEnable = false;
        simpleRequest(
          url: Urls.userBackupMobileEdit,
          params: {
            "strConut": source["phone"],
            "sms_Code": source["sms"],
            "u_3nd_Pad": payPwd,
          },
          success: (success, json) {
            if (success) {
              if (json["messages"] != null && json["messages"].isNotEmpty) {
                ShowToast.normal(json["messages"]);
              }
              Get.find<HomeController>().refreshHomeData();
              Future.delayed(const Duration(seconds: 1), () {
                Get.back();
              });
            }
          },
          after: () {
            buttonEnable = true;
          },
        );
      },
    );
    super.onInit();
  }

  @override
  void dispose() {
    backPhoneInputCtrl.dispose();
    smsInputCtrl.dispose();
    bottomPayPassword.dispos();
    super.dispose();
  }
}

class MineChangePhone extends GetView<MineChangePhoneController> {
  const MineChangePhone({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "备用手机号"),
        body: Column(
          children: [
            ghb(35),
            gwb(375),
            CustomPwdInput(
              controller: controller.backPhoneInputCtrl,
              textInputType: TextInputType.phone,
              type: CustomPwdInputType.userName,
              source: controller.source,
              maxLength: 11,
              arg: "phone",
              placeholder: "请输入备用机号",
            ),
            ghb(8),
            CustomPwdInput(
              controller: controller.smsInputCtrl,
              type: CustomPwdInputType.sendCode,
              textInputType: TextInputType.number,
              placeholder: "请输入验证码",
              source: controller.source,
              arg: "sms",
              rightWidget: centRow([
                Container(
                  width: 1,
                  height: 17,
                  color: const Color(0xFFEEEFF0),
                ),
                GetX<MineChangePhoneController>(
                  init: controller,
                  builder: (controller) {
                    return AuthCodeButton(
                      buttonState: controller.authButtonState,
                      countDownFinish: () {
                        controller.authButtonState = AuthCodeButtonState.again;
                      },
                      sendCodeAction: () {
                        controller.loadCode();
                      },
                    );
                  },
                ),
              ]),
            ),
            ghb(70),
            GetX<MineChangePhoneController>(
              builder: (_) {
                return getLoginBtn("确认", () {
                  controller.changeBackPhoneAction();
                }, enable: controller.buttonEnable);
              },
            )
          ],
        ),
      ),
    );
  }
}
