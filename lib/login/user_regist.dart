import 'package:cxhighversion2/component/authcode_button.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_login_input.dart';
import 'package:cxhighversion2/login/user_agreement_view.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:platform_device_id/platform_device_id.dart';

class UserRegistBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<UserRegistController>(UserRegistController());
  }
}

class UserRegistController extends GetxController {
  final _showPassWord = false.obs;
  set showPassWord(value) => _showPassWord.value = value;
  get showPassWord => _showPassWord.value;

  final _policySelected = false.obs;
  set policySelected(value) => _policySelected.value = value;
  get policySelected => _policySelected.value;
  CustomLoginInputController realNameInputCtrl = CustomLoginInputController();
  CustomLoginInputController tjInputCtrl = CustomLoginInputController();
  CustomLoginInputController pwdInputCtrl = CustomLoginInputController();
  CustomLoginInputController phoneInputCtrl = CustomLoginInputController();
  CustomLoginInputController sendCodeInputCtrl = CustomLoginInputController();
  @override
  void onClose() {
    realNameInputCtrl.dispose();
    tjInputCtrl.dispose();
    pwdInputCtrl.dispose();
    phoneInputCtrl.dispose();
    sendCodeInputCtrl.dispose();
    super.onClose();
  }

  final sendButtonType = Rx<AuthCodeButtonState>(AuthCodeButtonState.first);
  // get sendButtonType => _sendButtonType.value;
  // set sendButtonType(value) => sendButtonType = value;

  bool step1Success = false;

  final _submitEnable = true.obs;
  bool get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  sendCodeAction() {
    String phone = formData["u_Mobile"] ?? "";
    String sponsorNumber = formData["sponsor_Number"] ?? "";

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
    if (sponsorNumber.isEmpty) {
      // ShowToast.normal("请输入邀请码");
      tjInputCtrl.errorValue = "请输入邀请码";
      return;
    } else {
      tjInputCtrl.errorValue = "";
    }
    sendAuthCode({"sendType": 3, "sendNumber": phone, "spNumber": sponsorNumber}, (success) => null);
  }

  sendAuthCode(Map<String, dynamic> params, Function(bool success)? success) {
    sendButtonType(AuthCodeButtonState.sendAndWait);
    Http().doPost(
      Urls.sendCode,
      params,
      success: (json) {
        if (json["messages"] != null && json["messages"].isNotEmpty) {
          ShowToast.normal(json["messages"]);
        }
        sendButtonType(AuthCodeButtonState.countDown);
        if (success != null) {
          success(true);
        }
      },
      fail: (reason, code, json) {
        sendButtonType(AuthCodeButtonState.again);
        if (success != null) {
          success(false);
        }
      },
    );
  }

  // registStep1(Map<String, dynamic> params, Function(bool success)? success) {
  //   Http().doPost(
  //     Urls.registStep1,
  //     params,
  //     success: (json) {
  //       if (success != null) {
  //         success(true);
  //       }
  //     },
  //     fail: (reason, code, json) {
  //       if (success != null) {
  //         success(false);
  //       }
  //     },
  //   );
  // }

  // registStep2(Map<String, dynamic> params, Function(bool success)? success) {
  //   Http().doPost(
  //     Urls.registStep2,
  //     params,
  //     success: (json) {
  //       if (success != null) {
  //         success(true);
  //       }
  //     },
  //     fail: (reason, code, json) {
  //       if (success != null) {
  //         success(false);
  //       }
  //     },
  //   );
  // }

  // registStep3(Map<String, dynamic> params, Function(bool success)? success) {
  //   Http().doPost(
  //     Urls.registStep2,
  //     params,
  //     success: (json) {
  //       if (success != null) {
  //         success(true);
  //       }
  //     },
  //     fail: (reason, code, json) {
  //       if (success != null) {
  //         success(false);
  //       }
  //     },
  //   );
  // }

  // registLastStep(Map<String, dynamic> params, Function(bool success)? success) {
  //   Http().doPost(
  //     Urls.registLastStep,
  //     params,
  //     success: (json) {
  //       if (success != null) {
  //         success(true);
  //       }
  //     },
  //     fail: (reason, code, json) {
  //       if (success != null) {
  //         success(false);
  //       }
  //     },
  //   );
  // }

  // "uMobile": ctrl.phoneCtrl.text,
  // "smsCode": ctrl.authCodeCtrl.text,
  //  "uType": 1,
  //  "spNumber": ctrl.tjCtrl.text,
  //   "loginPassword": ctrl.pwdCtrl.text,
  //  "phoneKey": _.deviceId,

  Map formData = {
    "loginPassword": "",
    "u_Mobile": "",
    "sponsor_Number": "",
    "sms_Code": "",
    "realname": "",
  };

  registAction() async {
    String phone = formData["u_Mobile"] ?? "";
    String sponsorNumber = formData["sponsor_Number"] ?? "";
    String pwd = formData["loginPassword"] ?? "";
    String sendCode = formData["sms_Code"] ?? "";
    String realname = formData["realname"] ?? "";

    if (realname.isEmpty) {
      realNameInputCtrl.errorValue = "请输入真实姓名";
      return;
    } else {
      phoneInputCtrl.errorValue = "";
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
    if (sponsorNumber.isEmpty) {
      // ShowToast.normal("请输入推荐码");
      tjInputCtrl.errorValue = "请输入推荐码";
      return;
    } else {
      tjInputCtrl.errorValue = "";
    }
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
    if (sendCode.isEmpty) {
      // ShowToast.normal("请输入验证码");
      sendCodeInputCtrl.errorValue = "请输入验证码";
      return;
    } else {
      sendCodeInputCtrl.errorValue = "";
    }
    if (!policySelected) {
      ShowToast.normal("请勾选和同意用户协议和隐私政策");
      return;
    }
    String? dId = await PlatformDeviceId.getDeviceId;

    // registRequest({
    //   "uMobile": phone,
    //   "smsCode": sendCode,
    //   "uType": 1,
    //   "uNickName": realname,
    //   "spNumber": sponsorNumber,
    //   "loginPassword": pwd,
    //   "phoneKey": dId ?? "",
    // }, (success) {
    //   submitEnable = true;
    //   if (success) {
    //     ShowToast.normal("注册成功");
    //     Future.delayed(const Duration(seconds: 1), () {
    //       Get.back();
    //     });
    //   }
    // });
    submitEnable = false;
    simpleRequest(
      url: Urls.registLastStep,
      params: {
        "uMobile": phone,
        "smsCode": sendCode,
        "uType": 1,
        // "uNickName": realname,
        "spNumber": sponsorNumber,
        "loginPassword": pwd,
        "phoneKey": dId ?? "",
      },
      success: (success, json) {
        if (success) {
          ShowToast.normal("注册成功");
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {
        submitEnable = true;
      },
    );
  }

  // registRequest(Map<String, dynamic> params, Function(bool success)? ses) {
  //   submitEnable = false;
  //   registStep1({
  //     "u_Mobile": params["uMobile"],
  //     "sponsor_Number": params["spNumber"],
  //     "phoneKey": params["phoneKey"]
  //   }, ((success) {
  //     if (success) {
  //       registStep2({
  //         "u_Mobile": params["uMobile"],
  //         "sponsor_Number": params["spNumber"],
  //         "phoneKey": params["phoneKey"],
  //         "sms_Code": params["smsCode"]
  //       }, ((success) {
  //         if (success) {
  //           registLastStep(params, ses);
  //         } else {
  //           submitEnable = true;
  //         }
  //       }));
  //     } else {
  //       submitEnable = true;
  //     }
  //   }));
  // }

  final _userAgreement = Rx<Map>({});
  Map get userAgreement => _userAgreement.value;
  set userAgreement(v) => _userAgreement.value = v;

  final _privacyAgreement = Rx<Map>({});
  Map get privacyAgreement => _privacyAgreement.value;
  set privacyAgreement(v) => _privacyAgreement.value = v;

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
        }
      },
      after: () {},
    );
  }

  bool isFirst = true;
  dataInit(Map uData, Map pData) {
    if (!isFirst) return;
    isFirst = false;
    userAgreement = uData;
    privacyAgreement = pData;
    if (userAgreement.isEmpty) {
      loadAgreement(1);
    }
    if (privacyAgreement.isEmpty) {
      loadAgreement(5);
    }
  }

  // String? deviceId = "";

  // void getDeviceID() {
  //   PlatformDeviceId.getDeviceId.then((value) {
  //     deviceId = value;
  //   });
  // }

  @override
  void onInit() {
    // getDeviceID();
    policySelected = !AppDefault.uploadPT;
    super.onInit();
  }
}

class UserRegist extends GetView<UserRegistController> {
  final Map userAgreement;
  final Map privacyAgreement;
  const UserRegist({Key? key, this.userAgreement = const {}, this.privacyAgreement = const {}}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(userAgreement, privacyAgreement);
    return GestureDetector(
        onTap: () => takeBackKeyboard(context),
        child: Scaffold(
            backgroundColor: Colors.white,
            body: getInputBodyNoBtn(context, buttonHeight: 0, contentColor: Colors.transparent, build: (
              boxHeight,
              context,
            ) {
              return SingleChildScrollView(
                child: SizedBox(
                  height: boxHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                            ,
                            CustomButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: SizedBox(
                                width: 80.w,
                                height: kToolbarHeight,
                                child: Center(
                                  child: getSimpleText(
                                    "切换登录",
                                    14,
                                    AppDefault().getThemeColor() ?? AppColor.text2,
                                  ),
                                ),
                              ),
                            ),
                          ], width: 369),
                          ghb(22.5),
                          sbRow([
                            getSimpleText(
                              "新用户注册",
                              24,
                              AppColor.text,
                            ),
                          ], width: 375 - 20.5 * 2),
                          ghb(25.5),
                          CustomLoginInput(
                            controller: controller.realNameInputCtrl,
                            type: CustomLoginInputType.recommend,
                            placeholder: "请输入真实姓名",
                            textInputType: TextInputType.text,
                            source: controller.formData,
                            arg: "realname",
                            customStyle: 1,
                          ),
                          ghb(20),
                          CustomLoginInput(
                            controller: controller.phoneInputCtrl,
                            placeholder: "请输入手机号",
                            textInputType: TextInputType.phone,
                            source: controller.formData,
                            maxLength: 11,
                            arg: "u_Mobile",
                            customStyle: 1,
                          ),
                          ghb(20),
                          CustomLoginInput(
                              controller: controller.sendCodeInputCtrl,
                              type: CustomLoginInputType.sendCode,
                              placeholder: "请输入短信验证码",
                              textInputType: TextInputType.number,
                              source: controller.formData,
                              arg: "sms_Code",
                              customStyle: 1,
                              rightWidget: centRow([
                                Container(
                                  width: 1,
                                  height: 17,
                                  color: const Color(0xFFEEEFF0),
                                ),
                                GetX<UserRegistController>(
                                  init: controller,
                                  builder: (_) {
                                    return AuthCodeButton(
                                      buttonState: controller.sendButtonType.value,
                                      customStyle: 1,
                                      countDownFinish: () {
                                        controller.sendButtonType.value = AuthCodeButtonState.again;
                                      },
                                      sendCodeAction: () {
                                        controller.sendCodeAction();
                                      },
                                    );
                                  },
                                ),
                              ])),
                          ghb(20),
                          CustomLoginInput(
                            controller: controller.tjInputCtrl,
                            type: CustomLoginInputType.recommend,
                            placeholder: "请输入邀请码（必填）",
                            textInputType: TextInputType.text,
                            source: controller.formData,
                            arg: "sponsor_Number",
                            customStyle: 1,
                          ),
                          ghb(20),
                          CustomLoginInput(
                            controller: controller.pwdInputCtrl,
                            type: CustomLoginInputType.password,
                            placeholder: "请设置8-16位字母和数字组合的密码",
                            textInputType: TextInputType.text,
                            source: controller.formData,
                            arg: "loginPassword",
                            customStyle: 1,
                          ),
                          ghb(77.5),
                          GetX<UserRegistController>(
                            init: controller,
                            builder: (_) {
                              return getLoginBtn("确定", () {
                                controller.registAction();
                              }, enable: controller.submitEnable);
                            },
                          )
                        ],
                      ),
                      GetX<UserRegistController>(
                        init: controller,
                        builder: (ctrl) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: paddingSizeBottom(context) + 25.w),
                            child: sbRow([
                              CustomButton(
                                onPressed: () {
                                  ctrl.policySelected = !ctrl.policySelected;
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      // assetsName(
                                      //     "login/btn_checkbox_policy_${controller.policySelected ? "selected" : "normal"}"),
                                      assetsName("business/mall/checkbox_orange_${controller.policySelected ? "selected" : "normal"}"),
                                      width: 14.w,
                                      height: 14.w,
                                      fit: BoxFit.fill,
                                    ),
                                    gwb(7.5),
                                    getSimpleText("请阅读并同意", 13, AppColor.textGrey, textHeight: 1.1),
                                    CustomButton(
                                      onPressed: () {
                                        if (controller.userAgreement.isEmpty) {
                                          ShowToast.normal("请稍等，正在接收数据");
                                          return;
                                        }
                                        pushAg(false, controller.userAgreement["name"] ?? "", controller.userAgreement["content"] ?? "");
                                      },
                                      child: getSimpleText("《用户协议》", 13, AppDefault().getThemeColor() ?? AppColor.theme, textHeight: 1.1),
                                    ),
                                    getSimpleText("和", 13, AppColor.textGrey, textHeight: 1.1),
                                    CustomButton(
                                      onPressed: () {
                                        pushAg(false, controller.privacyAgreement["name"] ?? "", controller.privacyAgreement["content"] ?? "");
                                      },
                                      child: getSimpleText("《隐私政策》", 13, AppDefault().getThemeColor() ?? AppColor.theme, textHeight: 1.1),
                                    ),
                                  ],
                                ),
                              )
                            ], width: 375 - 17 * 2),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            })));
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
