import 'dart:async';

import 'package:cxhighversion2/component/authcode_button.dart';
import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_pin_textfield.dart';
import 'package:cxhighversion2/component/custom_pwd_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum MineVerifyIdentityType { changeLoginPassword, setPayPassword }

class MineVerifyIdentityBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineVerifyIdentityController>(MineVerifyIdentityController());
  }
}

class MineVerifyIdentityController extends GetxController {
  late BottomPayPassword bottomPayPassword;
  Map pwdSource = {
    "pwd": "",
    "pwd2": "",
    "sms": "",
  };

  final _showConfirmPayPwd = false.obs;
  bool get showConfirmPayPwd => _showConfirmPayPwd.value;
  set showConfirmPayPwd(v) => _showConfirmPayPwd.value = v;

  final _payPwdError = "".obs;
  String get payPwdError => _payPwdError.value;
  set payPwdError(v) => _payPwdError.value = v;

  bool isFirst = true;
  MineVerifyIdentityType? myType;
  String myTitle = "";
  late BuildContext context;

  TextEditingController pwdCtrl = TextEditingController();
  TextEditingController pwdConfirmCtrl = TextEditingController();

  TextEditingController changePwdCtrl = TextEditingController();
  TextEditingController changePwdConfirmCtrl = TextEditingController();
  TextEditingController payPwdCtrl = TextEditingController();

  CustomPwdInputController pwdInputCtrl = CustomPwdInputController();
  CustomPwdInputController pwdInputCtrl2 = CustomPwdInputController();
  CustomPwdInputController smsInputCtrl = CustomPwdInputController();

  // late final StreamController<ErrorAnimationType> errorController;
  final _showPwd = false.obs;
  bool get showPwd => _showPwd.value;
  set showPwd(v) => _showPwd.value = v;

  final _showConfirmPwd = false.obs;
  bool get showConfirmPwd => _showConfirmPwd.value;
  set showConfirmPwd(v) => _showConfirmPwd.value = v;

  final _authButtonState = Rx<AuthCodeButtonState>(AuthCodeButtonState.first);
  set authButtonState(value) => _authButtonState.value = value;
  get authButtonState => _authButtonState.value;

  final _nextBtnEnable = true.obs;
  set nextBtnEnable(value) => _nextBtnEnable.value = value;
  get nextBtnEnable => _nextBtnEnable.value;

  final _userPhone = "".obs;
  String get userPhone => _userPhone.value;
  set userPhone(v) => _userPhone.value = v;

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

  checkAuthCodeRequest(
      String authCode, Function(bool success, dynamic json)? success) {
    Http().doPost(
      Urls.checkAuthCode(authCode),
      {},
      success: (json) {
        if (success != null) {
          success(true, json);
        }
      },
      fail: (reason, code, json) {
        if (success != null) {
          success(false, json);
        }
      },
    );
  }

  bool setPwdSuccess = false;
  setPwdAction({Function()? successCallback}) {
    if (pwdCtrl.text.isEmpty) {
      ShowToast.normal("请输入6位支付密码");
      return;
    }

    if (pwdConfirmCtrl.text.isEmpty) {
      ShowToast.normal("请输入确认的6位支付密码");
      return;
    }

    if (pwdConfirmCtrl.text != pwdCtrl.text) {
      ShowToast.normal("两次密码不一致，请重新输入");
      return;
    }

    nextBtnEnable = false;

    Map<String, dynamic> params = {};
    String url = "";

    if (myType == MineVerifyIdentityType.setPayPassword) {
      params = {
        "smsCode": authCodeInputCtrl.text,
        "new3ndPad": pwdCtrl.text,
        "phoneKey": AppDefault().deviceId
      };
      url = Urls.userSetPayPwd;
    } else {
      params = {
        "code": authCodeInputCtrl.text,
        "new1st_Pad": pwdCtrl.text,
        "phoneKey": AppDefault().deviceId
      };
      url = Urls.userChangePwd;
    }

    simpleRequest(
      url: url,
      params: params,
      success: (success, json) {
        if (success) {
          if (myType == MineVerifyIdentityType.setPayPassword) {
            setPwdSuccess = true;
          }
          Get.find<HomeController>().homeOnRefresh();
          if (successCallback != null) {
            successCallback();
          }
        }
      },
      after: () {
        nextBtnEnable = true;
      },
    );
  }

  nextAction({Function()? successCallback}) {
    if (authCodeInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入验证码");
      return;
    }
    setPwdAction(successCallback: successCallback);
  }

  changePwdAction() {
    if (payPwdCtrl.text.isEmpty) {
      ShowToast.normal("请输入支付密码");
      return;
    }
    if (payPwdCtrl.text.length != 6) {
      ShowToast.normal("请输入6位支付密码");
      return;
    }
    if (int.tryParse(payPwdCtrl.text) == null) {
      ShowToast.normal("支付密码为6位纯数字");
      return;
    }

    if (changePwdCtrl.text.isEmpty) {
      ShowToast.normal("请输入新密码");
      return;
    }

    if (changePwdCtrl.text.length < 8 || changePwdCtrl.text.length > 20) {
      ShowToast.normal("密码长度要求8到20位");
      return;
    }
    if (changePwdConfirmCtrl.text.isEmpty) {
      ShowToast.normal("请输入确认密码");
      return;
    }
    if (changePwdConfirmCtrl.text != changePwdCtrl.text) {
      ShowToast.normal("两次密码不一致，请重新输入");
      return;
    }

    changePwd(payPwdCtrl.text);
  }

  changePwd(String payPwd) {
    nextBtnEnable = false;

    simpleRequest(
      url: Urls.user1stPadEdit,
      params: {
        "old3nd_Pad": payPwd,
        "new1st_Pad": changePwdCtrl.text,
        // "new1st_Pad": pwdSource["pwd"],
        "phoneKey": AppDefault().deviceId,
      },
      success: (success, json) {
        if (success) {
          if (json["messages"] != null && json["messages"].isNotEmpty) {
            ShowToast.normal(json["messages"]);
          }
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {
        nextBtnEnable = true;
      },
    );
  }

  changePayPwdAction() {
    String pwd = pwdCtrl.text;
    String pwd2 = pwdConfirmCtrl.text;
    // String pwd2 = pwdSource["pwd2"] ?? "";
    String sms = pwdSource["sms"] ?? "";
    if (pwd.isEmpty) {
      ShowToast.normal("请输入新支付密码");
      return;
    }
    if (pwd2.isEmpty) {
      ShowToast.normal("请输入确认支付密码");
      return;
    }

    if (pwd != pwd2) {
      ShowToast.normal("两次支付密码不一致，请重新输入");
      return;
    }

    push(
        ChangePayStep2(
          payPwd: pwd,
          phone: userPhone,
          setPayPwdResult: (success) {
            setPwdSuccess = success;
          },
        ),
        context);

    return;

    // String pwd = pwdSource["pwd"] ?? "";
    // String pwd2 = pwdSource["pwd2"] ?? "";
    // String sms = pwdSource["sms"] ?? "";
    // if (pwd.isEmpty) {
    //   pwdInputCtrl.errorValue = "请输入新支付密码";
    //   return;
    // } else {
    //   pwdInputCtrl.errorValue = "";
    // }
    // if (pwd2.isEmpty) {
    //   pwdInputCtrl2.errorValue = "请输入确认支付密码";
    //   return;
    // } else {
    //   pwdInputCtrl2.errorValue = "";
    // }
    // if (pwd != pwd2) {
    //   pwdInputCtrl2.errorValue = "两次支付密码不一致，请重新输入";
    //   return;
    // } else {
    //   pwdInputCtrl2.errorValue = "";
    // }

    if (sms.isEmpty) {
      smsInputCtrl.errorValue = "请输入验证码";
      return;
    } else {
      smsInputCtrl.errorValue = "";
    }

    nextBtnEnable = false;

    simpleRequest(
      url: Urls.userSetPayPwd,
      params: {
        "smsCode": sms,
        "new3ndPad": pwd,
        "phoneKey": AppDefault().deviceId
      },
      success: (success, json) {
        if (success) {
          if (json["messages"] != null && json["messages"].isNotEmpty) {
            ShowToast.normal(json["messages"]);
          }
          if (myType == MineVerifyIdentityType.setPayPassword) {
            setPwdSuccess = true;
          }
          Get.find<HomeController>().homeOnRefresh();
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {
        nextBtnEnable = true;
      },
    );
  }

  loadCode() {
    // if (phoneInputCtrl.text.isEmpty) {
    //   ShowToast.normal("请输入手机号");
    //   return;
    // }
    // if (!isMobilePhoneNumber(phoneInputCtrl.text)) {
    //   ShowToast.normal("请输入正确的手机号");
    //   return;
    // }
    String sendCodeUrl = "";
    Map<String, dynamic> params = {};
    if (userPhone.isEmpty) {
      params["sendType"] =
          (myType == MineVerifyIdentityType.changeLoginPassword ? 4 : 5);
      params["sendNumber"] = phoneInputCtrl.text;
      sendCodeUrl = Urls.sendCode;
    } else {
      params["type"] =
          (myType == MineVerifyIdentityType.changeLoginPassword ? 4 : 5);
      sendCodeUrl = Urls.sendCodeAfterLogin;
    }

    sendAuthCode(sendCodeUrl, params, (bool success) {
      if (success) {}
    });
  }

  GlobalKey inputkey1 = GlobalKey();
  GlobalKey inputkey2 = GlobalKey();
  late TextEditingController phoneInputCtrl;
  late TextEditingController authCodeInputCtrl;

  final _pwdNext = false.obs;
  bool get pwdNext => _pwdNext.value;

  String firstPwd = "";
  set pwdNext(v) {
    firstPwd = pwdCtrl.text;
    pwdCtrl.clear();
    _pwdNext.value = v;
    if (myType == MineVerifyIdentityType.setPayPassword) {}
  }

  dataInit(MineVerifyIdentityType? type, BuildContext ctx) {
    if (!isFirst) return;
    isFirst = false;
    context = ctx;
    if (AppDefault().loginStatus) {
      Map homeData = AppDefault().homeData;
      if (homeData.isNotEmpty) {
        int isMobile = homeData["isMobile"] ?? 0;
        if (isMobile == 0) {
          userPhone = homeData["u_Mobile"] ?? "";
        } else {
          userPhone = homeData["u_Mobile2"] ?? "";
        }
      }
      if (type != null) {
        myType = type;
        switch (myType) {
          case MineVerifyIdentityType.changeLoginPassword:
            myTitle = "修改登陆密码";
            break;
          case MineVerifyIdentityType.setPayPassword:
            myTitle = "修改支付密码";
            // errorController = StreamController<ErrorAnimationType>();
            pwdCtrl.addListener(payPwdListener);
            pwdConfirmCtrl.addListener(confirmPwdListener);
            break;
          default:
            myTitle = "";
        }
      }
    } else {
      popToLogin();
    }
  }

  payPwdListener() {
    if (pwdCtrl.text.length >= 6) {
      showConfirmPayPwd = true;
      payPwdError = "请再输入一次";
    }
  }

  confirmPwdListener() {
    if (pwdConfirmCtrl.text.length >= 6) {
      payPwdError = pwdConfirmCtrl.text != pwdCtrl.text ? "两次输入不一致" : "";
    }
  }

  @override
  void onInit() {
    // bottomPayPassword = BottomPayPassword.init(
    //   confirmClick: (payPwd) {
    //     changePwd(payPwd);
    //   },
    // );
    super.onInit();
  }

  @override
  void onClose() {
    smsInputCtrl.dispose();
    // errorController.close();

    changePwdCtrl.dispose();
    changePwdConfirmCtrl.dispose();
    payPwdCtrl.dispose();

    pwdCtrl.removeListener(payPwdListener);
    pwdConfirmCtrl.removeListener(confirmPwdListener);
    // pwdConfirmCtrl.dispose();
    pwdInputCtrl.dispose();
    pwdInputCtrl2.dispose();
    // bottomPayPassword.dispos();
    // pwdInputCtrl.dispose();
    // pwdInputCtrl2.dispose();
    // smsInputCtrl.dispose();
    // pwdCtrl.dispose();
    // pwdConfirmCtrl.dispose();
    // phoneInputCtrl.dispose();
    // authCodeInputCtrl.dispose();
    super.onClose();
  }
}

class MineVerifyIdentity extends GetView<MineVerifyIdentityController> {
  final MineVerifyIdentityType type;
  final bool popToRoot;
  final Function()? setSuccess;
  final Function()? noSetBack;
  const MineVerifyIdentity(
      {Key? key,
      this.type = MineVerifyIdentityType.setPayPassword,
      this.setSuccess,
      this.noSetBack,
      this.popToRoot = true})
      : super(key: key);

  checkPwdBeforeBack() {
    if (noSetBack != null &&
        type == MineVerifyIdentityType.setPayPassword &&
        controller.setPwdSuccess == false) {
      noSetBack!();
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.dataInit(type, context);
    return WillPopScope(
      onWillPop: () async {
        checkPwdBeforeBack();
        return true;
      },
      child: GestureDetector(
        onTap: () => takeBackKeyboard(context),
        child: Scaffold(
          backgroundColor: AppColor.pageBackgroundColor,
          appBar: getDefaultAppBar(
            context,
            controller.myTitle,
            color: Colors.white,
            backPressed: () {
              checkPwdBeforeBack();
              Get.back();
            },
          ),
          body: getInputBodyNoBtn(context,
              contentColor: Colors.transparent,
              marginTop: 10,
              buttonHeight: 80.w + paddingSizeBottom(context),
              children: [
                type == MineVerifyIdentityType.setPayPassword
                    //设置支付密码
                    ? centClm([
                        ghb(45),
                        // getWidthText("请先验证手机号 +86 ${controller.userPhone}", 15,
                        //     AppColor.textBlack, 335, 2),
                        getSimpleText("设置密码", 18, AppColor.text, isBold: true),
                        ghb(13),
                        getSimpleText("请设置支付密码，以便用于管理", 15, AppColor.text),

                        // ghb(15),
                        // CustomPwdInput(
                        //   controller: controller.smsInputCtrl,
                        //   type: CustomPwdInputType.sendCode,
                        //   textInputType: TextInputType.number,
                        //   placeholder: "请输入验证码",
                        //   source: controller.pwdSource,
                        //   arg: "sms",
                        //   rightWidget: centRow([
                        //     Container(
                        //       width: 1,
                        //       height: 17,
                        //       color: const Color(0xFFEEEFF0),
                        //     ),
                        //     GetX<MineVerifyIdentityController>(
                        //       init: controller,
                        //       builder: (controller) {
                        //         return AuthCodeButton(
                        //           buttonState: controller.authButtonState,
                        //           countDownFinish: () {
                        //             controller.authButtonState =
                        //                 AuthCodeButtonState.again;
                        //           },
                        //           sendCodeAction: () {
                        //             controller.loadCode();
                        //           },
                        //         );
                        //       },
                        //     ),
                        //   ]),
                        // ),
                        // ghb(15),
                        // getWidthText("输入新的支付密码，密码为6位数，仅有数字组合", 15,
                        //     AppColor.textBlack, 335, 2),

                        ghb(75),
                        GetX<MineVerifyIdentityController>(
                          builder: (_) {
                            return !controller.showConfirmPayPwd
                                ? CustomPinTextfield(
                                    key: controller.inputkey1,
                                    controller: controller.pwdCtrl,
                                    insideColor: Colors.white,
                                    singleHeight: 45.w,
                                    singleWidth: 45.w,
                                    width: 375 - 28 * 2,
                                    onChanged: (v) {
                                      // debugPrint(v);
                                      // if (v.length >= 6) {}
                                    },
                                  )
                                : CustomPinTextfield(
                                    key: controller.inputkey2,
                                    insideColor: Colors.white,
                                    controller: controller.pwdConfirmCtrl,
                                    singleHeight: 45.w,
                                    singleWidth: 45.w,
                                    width: 375 - 25 * 2,
                                    onChanged: (v) {
                                      // debugPrint(v);
                                      // if (v.length >= 6) {}
                                    },
                                  );
                          },
                        ),
                        ghb(25),
                        GetX<MineVerifyIdentityController>(
                          builder: (_) {
                            return getSimpleText(
                                controller.payPwdError, 16, AppColor.textRed);
                          },
                        ),

                        // sbRow([
                        //   getSimpleText(
                        //     "再次输入新密码",
                        //     14,
                        //     AppColor.textGrey,
                        //   ),
                        // ], width: 375 - 25 * 2),
                        // ghb(15),
                        // CustomPinTextfield(
                        //   key: controller.inputkey2,
                        //   controller: controller.pwdConfirmCtrl,
                        //   width: 375 - 25 * 2,
                        //   onChanged: (v) {
                        //     // debugPrint(v);
                        //     // if (v.length >= 6) {}
                        //   },
                        // ),
                        // ghb(40),
                        ghb(39),
                        GetX<MineVerifyIdentityController>(
                          builder: (_) {
                            return getLoginBtn("提交", () {
                              controller.changePayPwdAction();
                            },
                                enable: controller.nextBtnEnable,
                                haveShadow: false);
                          },
                        )
                      ])
                    :
                    //修改登录密码
                    centClm([
                        // ghb(15),
                        // CustomPwdInput(
                        //   controller: controller.pwdInputCtrl,
                        //   type: CustomPwdInputType.password,
                        //   placeholder: "请输入新密码",
                        //   source: controller.pwdSource,
                        //   arg: "pwd",
                        // ),
                        // ghb(8),
                        // CustomPwdInput(
                        //   controller: controller.pwdInputCtrl2,
                        //   type: CustomPwdInputType.password,
                        //   placeholder: "请确认新密码",
                        //   source: controller.pwdSource,
                        //   arg: "pwd2",
                        // ),

                        sbhRow([
                          getSimpleText(
                              "必须是8-16个字符之间，包含字母和数字组合的新密码", 12, AppColor.text3)
                        ], width: 375 - 15.5 * 2, height: 50),
                        pwdInput(0),
                        ghb(15),
                        pwdInput(1),
                        pwdInput(2),
                        ghb(31.5),
                        GetX<MineVerifyIdentityController>(
                          builder: (controller) {
                            return getLoginBtn("确认", () {
                              controller.changePwdAction();
                            },
                                haveShadow: false,
                                enable: controller.nextBtnEnable);
                          },
                        )
                      ]),
              ]),
        ),
      ),
    );
  }

  Widget pwdInput(int type) {
    String title = "";
    String placeholder = "";
    TextEditingController textCtrl;
    int? maxLength;
    TextInputType inputType = TextInputType.text;
    switch (type) {
      case 0:
        title = "支付密码";
        placeholder = "请输入支付密码验证";
        textCtrl = controller.payPwdCtrl;
        maxLength = 6;
        inputType = const TextInputType.numberWithOptions(
            signed: false, decimal: false);
        break;
      case 1:
        title = "新密码";
        placeholder = "请输入新密码";
        textCtrl = controller.changePwdCtrl;
        maxLength = 20;
        break;
      case 2:
        title = "确认密码";
        placeholder = "请再次输入新密码";
        textCtrl = controller.changePwdConfirmCtrl;
        maxLength = 20;
        break;
      default:
        textCtrl = TextEditingController();
    }
    return Container(
      width: 375.w,
      height: 55.w,
      decoration: const BoxDecoration(color: Colors.white),
      child: Center(
          child: sbRow([
        getSimpleText(title, 15, AppColor.text3),
        CustomInput(
          width: 270.w - 15.5.w,
          heigth: 55.w,
          placeholder: placeholder,
          textEditCtrl: textCtrl,
          maxLength: maxLength,
          keyboardType: inputType,
          style: TextStyle(fontSize: 15.sp, color: AppColor.text),
          placeholderStyle:
              TextStyle(fontSize: 15.sp, color: AppColor.assisText),
        )
      ], width: 375 - 15.5 * 2)),
    );
  }

  showSuccess(BuildContext context) {
    showGeneralDialog(
      barrierDismissible: false,
      context: context,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Center(
          child: SizedBox(
            height: 306.5.w,
            width: 220.w,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  CustomButton(
                    onPressed: () {
                      Get.until((route) {
                        if (route is GetPageRoute) {
                          if (route.binding is MainPageBinding) {
                            return true;
                          } else {
                            return false;
                          }
                        } else {
                          return false;
                        }
                      });
                    },
                    child: Image.asset(
                      assetsName(
                        "common/btn_model_close",
                      ),
                      width: 37.w,
                      height: 56.5.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    width: 220.w,
                    height: 250.w,
                    decoration: getDefaultWhiteDec(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          assetsName(
                            "common/bg_auth_success",
                          ),
                          height: 98.w,
                          fit: BoxFit.fitHeight,
                        ),
                        ghb(23),
                        getSimpleText("设置新密码成功", 16, AppColor.textBlack,
                            isBold: true),
                        ghb(20),
                        CustomButton(
                          onPressed: () {
                            if (popToRoot) {
                              Get.until((route) {
                                if (route is GetPageRoute) {
                                  if (route.binding is MainPageBinding) {
                                    return true;
                                  } else {
                                    return false;
                                  }
                                } else {
                                  return false;
                                }
                              });
                            } else {
                              int i = 0;
                              Get.until((route) {
                                if (route is GetPageRoute) {
                                  if (i == 1) {
                                    return true;
                                  }
                                  i++;
                                  return false;
                                } else {
                                  return false;
                                }
                              });
                            }
                          },
                          child: Container(
                            width: 150.w,
                            height: 35.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17.5.w),
                                gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF4282EB),
                                      Color(0xFF5BA3F7),
                                    ])),
                            child: Center(
                              child: getSimpleText("返回", 16, Colors.white,
                                  isBold: true),
                            ),
                          ),
                        ),
                        ghb(20)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChangePayStep2 extends StatefulWidget {
  final String payPwd;
  final String phone;
  final Function(bool success)? setPayPwdResult;
  const ChangePayStep2(
      {super.key, this.payPwd = "", this.phone = "", this.setPayPwdResult});

  @override
  State<ChangePayStep2> createState() => _ChangePayStep2State();
}

class _ChangePayStep2State extends State<ChangePayStep2> {
  // CustomPwdInputController smsInputCtrl = CustomPwdInputController();
  TextEditingController smsInputCtrl = TextEditingController();
  Map pwdSource = {"sms": ""};

  bool btnEnable = true;

  AuthCodeButtonState authButtonState = AuthCodeButtonState.first;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        takeBackKeyboard(context);
      },
      child: Scaffold(
        appBar: getDefaultAppBar(context, "验证身份", color: Colors.white),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              gwb(375),
              sbhRow([getSimpleText("验证身份", 12, AppColor.text3)],
                  width: 375 - 15.5 * 2, height: 50),
              Container(
                  color: Colors.white,
                  width: 375.w,
                  child: Column(
                    children: [
                      Center(
                        child: sbhRow([
                          getSimpleText("手机号", 15, AppColor.assisText),
                          getWidthText(hidePhoneNum(widget.phone), 15,
                              AppColor.assisText, 268 - 15, 1),
                        ], width: 375 - 15.5 * 2, height: 55),
                      ),
                      gline(375 - 15.5 * 2, 1),
                    ],
                  )),
              Container(
                  color: Colors.white,
                  width: 375.w,
                  child: Center(
                    child: sbhRow([
                      getSimpleText("验证码", 15, AppColor.assisText),
                      centRow([
                        CustomInput(
                          width: (268 - 15 - 108).w,
                          heigth: 55.w,
                          textEditCtrl: smsInputCtrl,
                          placeholder: "请输入验证码",
                          style:
                              TextStyle(fontSize: 15.w, color: AppColor.text),
                          placeholderStyle:
                              TextStyle(fontSize: 15.w, color: AppColor.text3),
                        ),
                        AuthCodeButton(
                          buttonState: authButtonState,
                          countDownFinish: () {
                            setState(() {
                              authButtonState = AuthCodeButtonState.again;
                            });
                          },
                          customStyle: 1,
                          sendCodeAction: () {
                            loadCode();
                          },
                        )
                      ])
                    ], width: 375 - 15.5 * 2, height: 55),
                  )),
              ghb(31.5),
              getLoginBtn("确认", () {
                changePwdAction();
              }, haveShadow: false, enable: btnEnable)
            ],
          ),
        ),
      ),
    );
  }

  changePwdAction() {
    setState(() {
      btnEnable = false;
    });
    simpleRequest(
      url: Urls.userSetPayPwd,
      params: {
        "smsCode": smsInputCtrl.text,
        "new3ndPad": widget.payPwd,
        "phoneKey": AppDefault().deviceId
      },
      success: (success, json) {
        if (widget.setPayPwdResult != null) {
          widget.setPayPwdResult!(success);
        }
        if (success) {
          Get.find<HomeController>().homeOnRefresh();
          ShowToast.normal(json["messages"] ?? "");
          Future.delayed(const Duration(seconds: 1), () {
            Get.until((route) {
              if (route is GetPageRoute) {
                if (route.binding is MineVerifyIdentityBinding) {
                  return false;
                } else {
                  return true;
                }
              } else {
                return false;
              }
            });
          });
        }
      },
      after: () {
        setState(() {
          btnEnable = true;
        });
      },
    );
  }

  loadCode() {
    setState(() {
      authButtonState = AuthCodeButtonState.sendAndWait;
    });
    simpleRequest(
      url: Urls.sendCodeAfterLogin,
      params: {
        "type": 4,
      },
      success: (success, json) {
        if (success) {
          ShowToast.normal(json["messages"]);
          authButtonState = AuthCodeButtonState.countDown;
        } else {
          authButtonState = AuthCodeButtonState.again;
        }
        setState(() {});
      },
      after: () {},
    );
  }
}
