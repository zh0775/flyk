import 'package:cxhighversion2/component/authcode_button.dart';
import 'package:cxhighversion2/component/custom_background.dart';
import 'package:cxhighversion2/component/custom_login_input.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platform_device_id/platform_device_id.dart';

class ForgetPwdBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ForgetPwdController>(ForgetPwdController());
  }
}

class ForgetPwdController extends GetxController {
  final _showPassWord = false.obs;
  set showPassWord(value) => _showPassWord.value = value;
  get showPassWord => _showPassWord.value;

  final _showConfirmPassWord = false.obs;
  set showConfirmPassWord(value) => _showConfirmPassWord.value = value;
  get showConfirmPassWord => _showConfirmPassWord.value;

  CustomLoginInputController pwdInputCtrl = CustomLoginInputController();
  CustomLoginInputController pwd2InputCtrl = CustomLoginInputController();
  CustomLoginInputController phoneInputCtrl = CustomLoginInputController();
  CustomLoginInputController sendCodeInputCtrl = CustomLoginInputController();

  final _sendButtonType = Rx<AuthCodeButtonState>(AuthCodeButtonState.first);
  set sendButtonType(v) => _sendButtonType.value = v;
  AuthCodeButtonState get sendButtonType => _sendButtonType.value;

  sendCodeAction() {
    String phone = formData["uMobile"] ?? "";

    if (phone.isEmpty) {
      // ShowToast.normal("请输入手机号");
      phoneInputCtrl.errorValue = "请输入手机号";
      return;
    } else {
      phoneInputCtrl.errorValue = "";
    }
    if (!isMobilePhoneNumber(phone)) {
      // ShowToast.normal("请输入正确的手机号");
      phoneInputCtrl.errorValue = "请输入正确的手机号";
      return;
    } else {
      phoneInputCtrl.errorValue = "";
    }

    sendAuthCode({"sendType": 4, "sendNumber": phone}, (success) {});
  }

  sendAuthCode(Map<String, dynamic> params, Function(bool success)? succ) {
    sendButtonType = AuthCodeButtonState.sendAndWait;
    // buttonEnable = false;
    simpleRequest(
      url: Urls.sendCode,
      params: params,
      success: (success, json) {
        if (success) {
          if (json["messages"] != null && json["messages"].isNotEmpty) {
            ShowToast.normal(json["messages"]);
          }
          sendButtonType = AuthCodeButtonState.countDown;
        } else {
          sendButtonType = AuthCodeButtonState.again;
        }
        if (succ != null) {
          succ(success);
        }
      },
      after: () {
        // buttonEnable = true;
      },
    );
  }

  Map formData = {
    "loginPassword": "",
    "loginPassword2": "",
    "uMobile": "",
    "smsCode": "",
  };

  forgetPwdAction() async {
    String pwd = formData["loginPassword"] ?? "";
    String pwd2 = formData["loginPassword2"] ?? "";
    String phone = formData["uMobile"] ?? "";
    String sendCode = formData["smsCode"] ?? "";

    if (pwd.isEmpty) {
      // ShowToast.normal("请输入密码");
      pwdInputCtrl.errorValue = "请输入密码";
      return;
    } else {
      pwdInputCtrl.errorValue = "";
    }
    if (pwd.length < 8 || pwd.length > 20) {
      // ShowToast.normal("密码长度要求8到20位");
      pwdInputCtrl.errorValue = "密码长度要求8到20位";
      return;
    } else {
      pwdInputCtrl.errorValue = "";
    }

    if (pwd2.isEmpty) {
      // ShowToast.normal("请输入确认密码");
      pwd2InputCtrl.errorValue = "请输入确认密码";
      return;
    } else {
      pwd2InputCtrl.errorValue = "";
    }
    if (pwd2 != pwd) {
      // ShowToast.normal("两次密码输入不一致");
      pwd2InputCtrl.errorValue = "两次密码输入不一致";
      return;
    } else {
      pwd2InputCtrl.errorValue = "";
    }
    if (phone.isEmpty) {
      // ShowToast.normal("请输入手机号");
      phoneInputCtrl.errorValue = "请输入手机号";
      return;
    } else {
      phoneInputCtrl.errorValue = "";
    }
    if (!isMobilePhoneNumber(phone)) {
      // ShowToast.normal("请输入正确的手机号");
      phoneInputCtrl.errorValue = "请输入正确的手机号";
      return;
    } else {
      phoneInputCtrl.errorValue = "";
    }
    if (sendCode.isEmpty) {
      // ShowToast.normal("请输入验证码");
      sendCodeInputCtrl.errorValue = "请输入验证码";
      return;
    } else {
      sendCodeInputCtrl.errorValue = "";
    }
    buttonEnable = false;

    String? dId = await PlatformDeviceId.getDeviceId;

    simpleRequest(
      url: Urls.findPwd,
      params: {
        "loginPassword": pwd,
        "uMobile": phone,
        "phoneKey": dId ?? "",
        "uType": 1,
        "smsCode": sendCode,
      },
      success: (success, json) {
        if (success) {
          ShowToast.normal(json["messages"]);
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {
        buttonEnable = true;
      },
    );
  }

  final _buttonEnable = true.obs;
  bool get buttonEnable => _buttonEnable.value;
  set buttonEnable(v) => _buttonEnable.value = v;

  // String? deviceId = "";

  // void getDeviceID() {
  //   PlatformDeviceId.getDeviceId.then((value) {
  //     deviceId = value;
  //   });
  // }

  @override
  void onInit() {
    // getDeviceID();
    super.onInit();
  }

  @override
  void onClose() {
    pwdInputCtrl.dispose();
    pwd2InputCtrl.dispose();
    phoneInputCtrl.dispose();
    sendCodeInputCtrl.dispose();
    super.onClose();
  }
}

class ForgetPwd extends GetView<ForgetPwdController> {
  const ForgetPwd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => takeBackKeyboard(context),
        child: Scaffold(
            backgroundColor: Colors.white,
            body: getInputBodyNoBtn(context,
                buttonHeight: 0, contentColor: Colors.transparent, build: (
              boxHeight,
              context,
            ) {
              return SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: paddingSizeTop(context),
                    ),
                    sbRow([
                      // allowBack
                      //     ?
                      defaultBackButton(context, close: true)
                      // : const SizedBox(
                      //     height: kToolbarHeight,
                      //   ),
                    ], width: 369),
                    ghb(22.5),
                    sbRow([
                      getSimpleText("修改密码", 24, AppColor.text, isBold: true),
                    ], width: 375 - 20 * 2),
                    ghb(25.5),
                    CustomLoginInput(
                      controller: controller.pwdInputCtrl,
                      type: CustomLoginInputType.password,
                      placeholder: "请设置8-16位字母和数字组合的密码",
                      textInputType: TextInputType.text,
                      source: controller.formData,
                      arg: "loginPassword",
                      customStyle: 1,
                    ),
                    ghb(20),
                    CustomLoginInput(
                      controller: controller.pwd2InputCtrl,
                      type: CustomLoginInputType.password,
                      placeholder: "请再次输入新密码",
                      textInputType: TextInputType.text,
                      source: controller.formData,
                      arg: "loginPassword2",
                      customStyle: 1,
                    ),
                    ghb(20),
                    CustomLoginInput(
                      controller: controller.phoneInputCtrl,
                      placeholder: "请输入手机号",
                      textInputType: TextInputType.phone,
                      source: controller.formData,
                      maxLength: 11,
                      arg: "uMobile",
                      customStyle: 1,
                    ),
                    ghb(20),
                    CustomLoginInput(
                      controller: controller.sendCodeInputCtrl,
                      source: controller.formData,
                      placeholder: "请输入短信验证码",
                      // maxLength: 11,
                      type: CustomLoginInputType.sendCode,
                      textInputType: TextInputType.number,
                      arg: "smsCode",
                      customStyle: 1,
                      rightWidget: centRow([
                        Container(
                          width: 1,
                          height: 17,
                          color: const Color(0xFFEEEFF0),
                        ),
                        GetX<ForgetPwdController>(
                          init: controller,
                          builder: (_) {
                            return AuthCodeButton(
                              buttonState: controller.sendButtonType,
                              customStyle: 1,
                              countDownFinish: () {
                                controller.sendButtonType =
                                    AuthCodeButtonState.again;
                              },
                              sendCodeAction: () {
                                controller.sendCodeAction();
                              },
                            );
                          },
                        )
                      ]),
                    ),
                    ghb(76),
                    GetX<ForgetPwdController>(
                      init: controller,
                      builder: (_) {
                        return getLoginBtn("确定", () {
                          controller.forgetPwdAction();
                        }, enable: controller.buttonEnable);
                      },
                    )
                  ],
                ),
              );
            })

            // SingleChildScrollView(
            //   child: Column(
            //     children: [
            //       SizedBox(
            //         height: screenHeight,
            //         width: screenWidth,
            //         child: Stack(
            //           children: [
            //             Positioned.fill(
            //                 child: Image.asset(
            //               "assets/images/login/bg_login.png",
            //               fit: BoxFit.fill,
            //             )),
            //             Positioned(
            //                 top: 0,
            //                 left: margin,
            //                 right: 0,
            //                 bottom: 0,
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     const SizedBox(
            //                       height: 60,
            //                     ),
            //                     CustomButton(
            //                       onPressed: () {
            //                         Navigator.pop(context);
            //                       },
            //                       child: const Icon(
            //                         Icons.navigate_before,
            //                         size: 24,
            //                         color: Colors.black,
            //                       ),
            //                     ),
            //                     const SizedBox(
            //                       height: 40,
            //                     ),
            //                     const Text(
            //                       " 忘记密码",
            //                       style: TextStyle(
            //                           color: Color(0xFF4A4A4A), fontSize: 20),
            //                     ),
            //                     const SizedBox(
            //                       height: 20,
            //                     ),
            //                     LoginInput(
            //                       placeholder: "请输入新密码(由英文或数字组成8位数)",
            //                       onEditingComplete: (str) {},
            //                       inputType: LoginInputType.password,
            //                     ),
            //                     const SizedBox(
            //                       height: 10,
            //                     ),
            //                     LoginInput(
            //                       placeholder: "请再次输入新密码",
            //                       onEditingComplete: (str) {},
            //                       inputType: LoginInputType.password,
            //                     ),
            //                     const SizedBox(
            //                       height: 10,
            //                     ),
            //                     LoginInput(
            //                       placeholder: "请输入手机号",
            //                       onEditingComplete: (str) {},
            //                       inputType: LoginInputType.phone,
            //                     ),
            //                     const SizedBox(
            //                       height: 10,
            //                     ),
            //                     LoginInput(
            //                       placeholder: "请输入验证码",
            //                       onEditingComplete: (str) {},
            //                       inputType: LoginInputType.authcode,
            //                     ),
            //                     const SizedBox(
            //                       height: 60,
            //                     ),
            //                     CustomImageButton(
            //                       width: screenWidth! - margin * 2,
            //                       height: 46,
            //                       img: "assets/images/login/btn_login.png",
            //                       title: const Text(
            //                         "确定",
            //                         style: TextStyle(
            //                             color: Colors.white, fontSize: 16),
            //                       ),
            //                       onPressed: () {},
            //                     )
            //                   ],
            //                 )),
            //             // Positioned(
            //             //   bottom: heightScale! * 10,
            //             //   left: (screenWidth! - 335) / 2,
            //             //   child:
            //             // )
            //           ],
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            ));
  }
}
