import 'package:cxhighversion2/component/authcode_button.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_login_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/login/forgetpwd.dart' deferred as forgetpwd;
import 'package:cxhighversion2/login/user_agreement_view.dart'
    deferred as user_agreement_view;
import 'package:cxhighversion2/login/user_error_status_view.dart';
import 'package:cxhighversion2/login/user_regist.dart' deferred as user_regist;
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/storage_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:cxhighversion2/util/user_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:platform_device_id/platform_device_id.dart';

class UserLoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<UserLoginController>(UserLoginController());
  }
}

class UserLoginController extends GetxController {
  // TextEditingController phoneCtrl = TextEditingController();
  // TextEditingController pwdCtrl = TextEditingController();
  // TextEditingController authCodeCtrl = TextEditingController();

  CustomLoginInputController phoneInputCtrl = CustomLoginInputController();
  CustomLoginInputController pwdInputCtrl = CustomLoginInputController();
  CustomLoginInputController sendCodeInputCtrl = CustomLoginInputController();

  final _confirmProtocol = true.obs;
  bool get confirmProtocol => _confirmProtocol.value;
  set confirmProtocol(v) => _confirmProtocol.value = v;

  final _showPassWord = false.obs;
  set showPassWord(value) => _showPassWord.value = value;
  get showPassWord => _showPassWord.value;

  final _buttonEnable = true.obs;
  bool get buttonEnable => _buttonEnable.value;
  set buttonEnable(v) => _buttonEnable.value = v;

  get needAuthCode => _needAuthCode.value;
  final _needAuthCode = false.obs;
  set needAuthCode(value) {
    if (needAuthCode != value) {
      _needAuthCode.value = value;
      needAuthCode ? policySpace -= 66.w : policySpace += 66.w;
    }
  }

  final _loginByAuthCode = false.obs;
  bool get loginByAuthCode => _loginByAuthCode.value;
  set loginByAuthCode(v) => _loginByAuthCode.value = v;

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

  String appInfobuildId = "userLogin_appInfobuildId";
  String phoneBuildId = "userLogin_phoneBuildId";
  Map publicHomeData = {};

  loadPublicHomeData() async {
    if (AppDefault().publicHomeData != null &&
        AppDefault().publicHomeData.isNotEmpty &&
        AppDefault().publicHomeData["webSiteInfo"] != null &&
        AppDefault().publicHomeData["webSiteInfo"].isNotEmpty) {
      publicHomeData = AppDefault().publicHomeData;
      update([appInfobuildId]);
      return;
    }
    Map userData = await getUserData();
    if (userData["publicHomeData"] != null &&
        userData["publicHomeData"].isNotEmpty &&
        userData["publicHomeData"]["webSiteInfo"] != null &&
        userData["publicHomeData"]["webSiteInfo"].isNotEmpty) {
      publicHomeData = userData["publicHomeData"];
      update([appInfobuildId]);
      return;
    }

    final ctrl = Get.find<HomeController>();
    ctrl.refreshPublicHomeData(coerce: true);
  }

  final sendButtonType = Rx<AuthCodeButtonState>(AuthCodeButtonState.first);

  sendCodeAction() {
    String phone = formData["loginID"] ?? "";
    if (phone.isEmpty) {
      ShowToast.normal("请输入手机号");
      return;
    }
    if (!isMobilePhoneNumber(phone)) {
      ShowToast.normal("请输入正确的手机号");
      return;
    }
    sendAuthCode({
      "sendType": 1,
      "sendNumber": phone,
    }, (success) {});
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

  Map formData = {
    "loginID": "",
    "password": "",
    "sms_Code": "",
  };

  loginRequest() async {
    if ((formData["loginID"] ?? "").isEmpty) {
      // ShowToast.normal("请输入手机号");
      phoneInputCtrl.errorValue = "请输入手机号";
      return;
    } else {
      phoneInputCtrl.errorValue = "";
    }
    if (!isMobilePhoneNumber(formData["loginID"] ?? "")) {
      // ShowToast.normal("请输入正确的手机号");
      phoneInputCtrl.errorValue = "请输入正确的手机号";
      return;
    } else {
      phoneInputCtrl.errorValue = "";
    }
    if (!loginByAuthCode) {
      if ((formData["password"] ?? "").isEmpty) {
        pwdInputCtrl.errorValue = "请输入密码";
        return;
      } else {
        pwdInputCtrl.errorValue = "";
      }
      if ((formData["password"] ?? "").length < 8 ||
          (formData["password"] ?? "").length > 20) {
        // ShowToast.normal("密码长度要求8到20位");
        pwdInputCtrl.errorValue = "密码长度要求8到20位";
        return;
      } else {
        pwdInputCtrl.errorValue = "";
      }
    }

    if (!confirmProtocol) {
      ShowToast.normal("请先阅读并勾选用户协议和隐私政策");
      takeBackKeyboard(Global.navigatorKey.currentContext!);
      return;
    }
    String? dId = await PlatformDeviceId.getDeviceId;

    var params = {
      "login_Type": loginByAuthCode ? 2 : 1,
      "loginID": formData["loginID"] ?? "",
      "u_Type": 1,
      "phoneKey": dId ?? "",
      "versionInternalNumber": "1.0",
      "version_Origin": AppDefault().versionOrigin,
      "password": formData["password"] ?? ""
    };

    // if (!loginByAuthCode) {
    //   params["password"] = formData["password"] ?? "";
    // }

    if (needAuthCode || loginByAuthCode) {
      if ((formData["sms_Code"] ?? "").isEmpty) {
        ShowToast.normal("请输入验证码");
        return;
      } else {
        params["sms_Code"] = formData["sms_Code"] ?? "";
      }
    }

    buttonEnable = false;
    simpleRequest(
      url: Urls.login,
      params: params,
      success: (success, json) {
        if (success) {
          UserDefault.saveStr(
              USER_LOGIN_PHONE_STORAGE, formData["loginID"] ?? "");
          AppDefault().deviceId = dId ?? "";
          Map data = json["data"] ?? {};
          setUserDataFormat(true, data["homeData"], data["publicHomeData"],
                  data["loginData"],
                  sendNotification: true)
              .then((value) {
            bus.emit(HOME_DATA_UPDATE_NOTIFY);
            // saveQRImage();

            AppDefault().firstAlertFromLogin = true;
            ShowToast.normal("登录成功");
            Future.delayed(const Duration(seconds: 1), () {
              popToUntil();
            });
          });
        } else {
          if (json != null &&
              json is Map &&
              (json["value"] ?? "") == "phoneKeyError") {
            // ShowToast.normal("超出错误次数，请使用验证码登录");
            loginByAuthCode = true;
          }
        }
      },
      after: () {
        buttonEnable = true;
      },
    );
  }

  // String? deviceId = "";
  // void getDeviceID() {
  //   PlatformDeviceId.getDeviceId.then((value) {
  //     deviceId = value;
  //   });
  // }

  bool isFirst = true;
  final _policySpace = 0.0.obs;
  double get policySpace => _policySpace.value;
  set policySpace(v) => _policySpace.value = v;

  dataInit(double space) {
    if (!isFirst) return;
    isFirst = false;
    policySpace = space;
  }

  bool isFirstStatus = true;

  final _isErrorStatus = false.obs;
  bool get isErrorStatus => _isErrorStatus.value;
  set isErrorStatus(v) => _isErrorStatus.value = v;

  stateInit(bool isError) {
    if (!isFirstStatus) return;
    isFirstStatus = false;
    isErrorStatus = isError;
  }

  @override
  void onInit() {
    loadPhoneCache();
    confirmProtocol = AppDefault.isDebug;
    bus.on(HOME_PUBLIC_DATA_UPDATE_NOTIFY, getPublicHomeData);
    // getDeviceID();
    loadPublicHomeData();
    loadAgreement(1);
    loadPrivacy();
    super.onInit();
  }

  loadPhoneCache() async {
    formData["loginID"] = await UserDefault.get(USER_LOGIN_PHONE_STORAGE) ?? "";
    update([phoneBuildId]);
  }

  getPublicHomeData(arg) {
    publicHomeData = AppDefault().publicHomeData;
    update([appInfobuildId]);
  }

  @override
  void onClose() {
    bus.off(HOME_PUBLIC_DATA_UPDATE_NOTIFY, getPublicHomeData);
    phoneInputCtrl.dispose();
    pwdInputCtrl.dispose();
    sendCodeInputCtrl.dispose();
    super.onClose();
  }
}

class UserLogin extends GetView<UserLoginController> {
  final bool allowBack;
  final int errorCode;
  final bool isErrorStatus;
  const UserLogin(
      {Key? key,
      this.allowBack = false,
      this.isErrorStatus = false,
      this.errorCode = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.stateInit(isErrorStatus);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: WillPopScope(
        onWillPop: () async {
          return allowBack;
        },
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
              backgroundColor: Colors.white,
              body: GetX<UserLoginController>(
                builder: (_) {
                  return getInputBodyNoBtn(
                    context,
                    buttonHeight: 0,
                    contentColor: Colors.transparent,
                    build: controller.isErrorStatus
                        ? (boxHeight, context) {
                            return UserErrorStatusView(
                              boxHeight: boxHeight,
                              errorCode: errorCode,
                              toLogin: () {
                                controller.isErrorStatus = false;
                              },
                            );
                          }
                        : (boxHeight, context) {
                            if (controller.isFirst) {
                              double policySpace = boxHeight -
                                  paddingSizeTop(context) -
                                  paddingSizeBottom(context) -
                                  kToolbarHeight -
                                  (22 +
                                          35 +
                                          25.5 +
                                          55 +
                                          20 +
                                          // 0.5 +
                                          55 +
                                          (controller.needAuthCode
                                              ? 55 + 20
                                              : 0) +
                                          10 +
                                          79 +
                                          45 +
                                          22.5 +
                                          // 50 +
                                          44.5)
                                      .w;
                              controller.dataInit(policySpace);
                            }
                            return SizedBox(
                              width: 375.w,
                              height: boxHeight,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: paddingSizeTop(context),
                                    ),
                                    sbRow([
                                      allowBack
                                          ? defaultBackButton(context)
                                          : const SizedBox(
                                              height: kToolbarHeight,
                                            ),
                                      CustomButton(
                                        onPressed: () async {
                                          await user_regist.loadLibrary();
                                          push(
                                              user_regist.UserRegist(
                                                userAgreement:
                                                    controller.userAgreement,
                                                privacyAgreement:
                                                    controller.privacyAgreement,
                                              ),
                                              null,
                                              binding: user_regist
                                                  .UserRegistBinding());
                                        },
                                        child: SizedBox(
                                          width: 60.w,
                                          height: kToolbarHeight,
                                          child: Center(
                                            child: getSimpleText(
                                              "注册",
                                              14,
                                              AppDefault().getThemeColor() ??
                                                  AppColor.text2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ], width: 375),
                                    ghb(22),
                                    sbhRow([
                                      getSimpleText("欢迎登录", 24, AppColor.text,
                                          isBold: true),
                                    ], width: 375 - 20.5 * 2, height: 35),

                                    ghb(25.5),

                                    GetBuilder<UserLoginController>(
                                      id: controller.phoneBuildId,
                                      builder: (_) {
                                        return CustomLoginInput(
                                          controller: controller.phoneInputCtrl,
                                          source: controller.formData,
                                          defalutValue:
                                              controller.formData["loginID"] ??
                                                  "",
                                          placeholder: "请输入手机号",
                                          maxLength: 11,
                                          type: CustomLoginInputType.userName,
                                          textInputType: TextInputType.phone,
                                          arg: "loginID",
                                          customStyle: 1,
                                        );
                                      },
                                    ),
                                    // CustomInput(
                                    //   width: (375 - 24 * 2).w,
                                    //   heigth: 50.w,
                                    //   textEditCtrl: controller.phoneCtrl,
                                    //   keyboardType: TextInputType.phone,
                                    //   maxLength: 11,
                                    //   placeholder: "请输入手机号",
                                    // ),
                                    // gline(375 - 20 * 2, 0.5),
                                    ghb(20),
                                    GetX<UserLoginController>(
                                      builder: (_) {
                                        return Visibility(
                                          visible: !controller.loginByAuthCode,
                                          child: CustomLoginInput(
                                            controller: controller.pwdInputCtrl,
                                            source: controller.formData,
                                            placeholder: "请输入密码",
                                            // maxLength: 11,
                                            type: CustomLoginInputType.password,
                                            textInputType: TextInputType.text,
                                            arg: "password",
                                            customStyle: 1,
                                          ),
                                        );
                                      },
                                    ),
                                    GetX<UserLoginController>(
                                      init: controller,
                                      builder: (_) {
                                        return Visibility(
                                          visible: controller.needAuthCode ||
                                              controller.loginByAuthCode,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: controller.needAuthCode
                                                    ? 20.w
                                                    : 0),
                                            child: CustomLoginInput(
                                              controller:
                                                  controller.sendCodeInputCtrl,
                                              source: controller.formData,
                                              placeholder: "请输入验证码",
                                              // maxLength: 11,
                                              type:
                                                  CustomLoginInputType.sendCode,
                                              textInputType:
                                                  TextInputType.number,
                                              arg: "sms_Code",
                                              customStyle: 1,
                                              rightWidget: centRow([
                                                GetX<UserLoginController>(
                                                  init: controller,
                                                  builder: (_) {
                                                    return AuthCodeButton(
                                                      customStyle: 1,
                                                      buttonState: controller
                                                          .sendButtonType.value,
                                                      countDownFinish: () {
                                                        controller
                                                                .sendButtonType
                                                                .value =
                                                            AuthCodeButtonState
                                                                .again;
                                                      },
                                                      sendCodeAction: () {
                                                        controller
                                                            .sendCodeAction();
                                                      },
                                                    );
                                                  },
                                                )
                                              ]),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    ghb(76),
                                    GetX<UserLoginController>(
                                      init: controller,
                                      builder: (_) {
                                        return getLoginBtn("登录", () {
                                          controller.loginRequest();
                                        }, enable: controller.buttonEnable);
                                      },
                                    ),
                                    ghb(10),
                                    sbhRow([
                                      CustomButton(
                                        onPressed: () {
                                          controller.loginByAuthCode =
                                              !controller.loginByAuthCode;
                                        },
                                        child: centRow([
                                          GetX<UserLoginController>(
                                            builder: (_) {
                                              return getSimpleText(
                                                  "${!controller.loginByAuthCode ? "验证码" : "密码"}登录",
                                                  14,
                                                  AppColor.text2,
                                                  textHeight: 1.1);
                                            },
                                          ),
                                          gwb(4),
                                          Image.asset(
                                            assetsName(
                                                "statistics/icon_arrow_right_gray"),
                                            width: 12.5.w,
                                            fit: BoxFit.fitWidth,
                                          )
                                        ]),
                                      ),
                                      CustomButton(
                                        onPressed: () async {
                                          await forgetpwd.loadLibrary();
                                          push(forgetpwd.ForgetPwd(), null,
                                              binding:
                                                  forgetpwd.ForgetPwdBinding());
                                        },
                                        child: getSimpleText(
                                          "忘记密码",
                                          14,
                                          AppDefault().getThemeColor() ??
                                              const Color(0xFFBCC2CB),
                                        ),
                                      ),
                                    ], width: 375 - 23 * 2, height: 44.5),

                                    GetX<UserLoginController>(
                                      init: controller,
                                      initState: (_) {},
                                      builder: (_) {
                                        return SizedBox(
                                            height: controller.policySpace < 0
                                                ? 0
                                                : controller.policySpace -
                                                    25.w);
                                      },
                                    ),
                                    policyView(context)
                                  ],
                                ),
                              ),
                            );
                          },
                  );
                },
              )),
        ),
      ),
    );
  }

  Widget policyView(BuildContext context) {
    return GetBuilder<UserLoginController>(
      id: controller.appInfobuildId,
      initState: (_) {},
      builder: (_) {
        Map appInfo = {};
        if (!HttpConfig.baseUrl.contains("woliankeji")) {
          Map info =
              (controller.publicHomeData["webSiteInfo"] ?? {})["app"] ?? {};
          appInfo = {"System_Home_Name": info["apP_Name"] ?? ""};
        } else if (HttpConfig.baseUrl.contains("woliankeji")) {
          appInfo = controller.publicHomeData["webSiteInfo"] ?? {};
        }

        return CustomButton(
          onPressed: () {
            controller.confirmProtocol = !controller.confirmProtocol;
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GetX<UserLoginController>(
                builder: (_) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        AppDefault().getThemeColor() ?? Colors.white,
                        BlendMode.modulate),
                    child: Image.asset(
                      // assetsName(
                      //     "login/btn_checkbox_policy_${controller.confirmProtocol ? "selected" : "normal"}"),
                      assetsName(
                          "business/mall/checkbox_orange_${controller.confirmProtocol ? "selected" : "normal"}"),
                      width: 14.w,
                      height: 14.w,
                      fit: BoxFit.fill,
                    ),
                  );
                },
              ),
              gwb(5),
              getSimpleText("登录即代表同意${appInfo["System_Home_Name"] ?? ""}的", 13,
                  AppColor.textGrey,
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
                child: getSimpleText("《用户协议》", 13,
                    AppDefault().getThemeColor() ?? AppColor.theme,
                    textHeight: 1.1),
              ),
              getSimpleText("和", 13, AppColor.textGrey, textHeight: 1.1),
              CustomButton(
                onPressed: () {
                  pushAg(false, "隐私协议",
                      controller.privacyAgreement["content"] ?? "");
                },
                child: getSimpleText("《隐私政策》", 13,
                    AppDefault().getThemeColor() ?? AppColor.theme,
                    textHeight: 1.1),
              ),
            ],
          ),
        );
      },
    );
  }

  void pushAg(bool isP, String t, String u) async {
    await user_agreement_view.loadLibrary();
    push(
        () => user_agreement_view.UserAgreementView(
              isPrivacy: isP,
              title: t,
              url: u,
            ),
        null,
        binding: user_agreement_view.UserAgreementViewBinding());
  }
}
