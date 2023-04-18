import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/mine/mine_setting_list.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:platform_device_id/platform_device_id.dart';

class MineSetPayPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineSetPayPasswordController>(MineSetPayPasswordController());
  }
}

class MineSetPayPasswordController extends GetxController {
  BuildContext? context;
  bool isFirst = true;

  int authCode = 0;

  final pwdCounts = [0, 0, 0, 0, 0, 0];
  final confirmPwdCounts = [0, 0, 0, 0, 0, 0];
  final pwdCtrlList = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  final confirmPwdCtrlList = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  final pwdFocusNodeList = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];
  final confirmPwdFocusNodeList = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];

  final _submitBtnEnable = true.obs;
  set submitBtnEnable(value) => _submitBtnEnable.value = value;
  get submitBtnEnable => _submitBtnEnable.value;

  saveAction() async {
    String pwdStr = "";
    String confirmPwdStr = "";
    for (var i = 0; i < pwdCtrlList.length; i++) {
      TextEditingController e1 = pwdCtrlList[i];
      TextEditingController e2 = confirmPwdCtrlList[i];
      if (e1.text.isNotEmpty) {
        pwdStr += e1.text;
      } else {
        ShowToast.normal("请输入6位支付密码");
        return;
      }

      if (e2.text.isNotEmpty) {
        confirmPwdStr += e2.text;
      } else {
        ShowToast.normal("请输入确认的6位支付密码");
        return;
      }
    }

    if (pwdStr != confirmPwdStr) {
      ShowToast.normal("两次密码不一致，请重新输入");
      return;
    }

    submitBtnEnable = false;
    String? deviceId = await PlatformDeviceId.getDeviceId;

    userSetPayPwdRequest(
        {"smsCode": authCode, "new3ndPad": pwdStr, "phoneKey": deviceId ?? ""},
        (success, json) {
      submitBtnEnable = true;
      if (success) {
        ShowToast.normal("设置成功");
        Future.delayed(const Duration(seconds: 1), () {
          Get.until((route) {
            if (route is GetPageRoute) {
              if (route.binding is MineSettingListBinding) {
                return true;
              } else {
                return false;
              }
            } else {
              return false;
            }
          });
        });
      } else {
        if (json != null &&
            json["messages"] != null &&
            json["messages"].isNotEmpty) {
          ShowToast.normal(json["messages"]);
        }
      }
    });
  }

  userSetPayPwdRequest(Map<String, dynamic> params,
      Function(bool success, dynamic json) success) {
    Http().doPost(
      Urls.userSetPayPwd,
      params,
      success: (json) {
        if (success != null) {
          success(true, json);
        } else {
          success(false, json);
        }
      },
      fail: (reason, code, json) {
        if (success != null) {
          success(false, json);
        }
      },
    );
  }

  pwdListener(TextEditingController ctrl, int index) {
    if (ctrl.text.isNotEmpty && pwdCounts[index] == 0) {
      if (index < pwdFocusNodeList.length - 1) {
        FocusScope.of(context!).requestFocus(pwdFocusNodeList[index + 1]);
      }
    } else if (ctrl.text.isEmpty && pwdCounts[index] != 0) {
      if (index > 0) {
        FocusScope.of(context!).requestFocus(pwdFocusNodeList[index - 1]);
      }
    }
    pwdCounts[index] = ctrl.text.length;
  }

  confirmPwdListener(TextEditingController ctrl, int index) {
    if (ctrl.text.isNotEmpty && confirmPwdCounts[index] == 0) {
      if (index < confirmPwdFocusNodeList.length - 1) {
        FocusScope.of(context!)
            .requestFocus(confirmPwdFocusNodeList[index + 1]);
      }
    } else if (ctrl.text.isEmpty && confirmPwdCounts[index] != 0) {
      if (index > 0) {
        FocusScope.of(context!)
            .requestFocus(confirmPwdFocusNodeList[index - 1]);
      }
    }
    confirmPwdCounts[index] = ctrl.text.length;
  }

  dataInit(BuildContext ctx, int code) {
    if (isFirst) {
      context = ctx;
      authCode = code;
      isFirst = false;
    }
  }

  @override
  void onInit() {
    for (var i = 0; i < pwdCtrlList.length; i++) {
      TextEditingController e = pwdCtrlList[i];
      TextEditingController e2 = confirmPwdCtrlList[i];
      e.addListener(() {
        pwdListener(e, i);
      });
      e2.addListener(() {
        confirmPwdListener(e2, i);
      });
    }
    super.onInit();
  }

  @override
  void dispose() {
    for (var i = 0; i < pwdCtrlList.length; i++) {
      TextEditingController e = pwdCtrlList[i];
      TextEditingController e2 = confirmPwdCtrlList[i];
      FocusNode n1 = pwdFocusNodeList[i];
      FocusNode n2 = confirmPwdFocusNodeList[i];
      e.removeListener(() {});
      e.dispose();
      e2.removeListener(() {});
      e2.dispose();
      n1.dispose();
      n2.dispose();
    }
    super.dispose();
  }
}

class MineSetPayPassword extends GetView<MineSetPayPasswordController> {
  final int? authCode;
  const MineSetPayPassword({Key? key, this.authCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(context, authCode ?? 0);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "设置支付密码"),
        body: getInputBodyNoBtn(context,
            contentColor: Colors.white,
            marginTop: 10,
            submitBtn: GetX<MineSetPayPasswordController>(
              init: controller,
              builder: (_) {
                return getBottomBlueSubmitBtn(context, "保存", onPressed: () {
                  controller.saveAction();
                }, enalble: controller.submitBtnEnable);
              },
            ),
            children: [
              ghb(60),
              sbRow([
                getSimpleText("设置支付密码", 26, AppColor.textBlack, isBold: true),
              ], width: 375 - 25 * 2),
              ghb(25),
              sbRow([
                getSimpleText(
                  "在下方填写平台支付密码，密码为6位数字",
                  14,
                  AppColor.textGrey,
                ),
              ], width: 375 - 25 * 2),
              ghb(15),
              sbRow([
                ...controller.pwdCtrlList
                    .asMap()
                    .entries
                    .map((e) => inputs(controller.pwdCtrlList[e.key],
                        controller.pwdFocusNodeList[e.key]))
                    .toList(),
              ], width: 375 - 25 * 2),
              ghb(35),
              sbRow([
                getSimpleText(
                  "再次输入新密码",
                  14,
                  AppColor.textGrey,
                ),
              ], width: 375 - 25 * 2),
              ghb(15),
              sbRow([
                ...controller.confirmPwdCtrlList
                    .asMap()
                    .entries
                    .map((e) => inputs(controller.confirmPwdCtrlList[e.key],
                        controller.confirmPwdFocusNodeList[e.key]))
                    .toList(),
              ], width: 375 - 25 * 2)
            ]),
      ),
    );
  }

  Widget inputs(
    TextEditingController ctrl,
    FocusNode node,
  ) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(6.w)),
      child: Center(
        child: CustomInput(
          width: 40.w,
          heigth: 40.w,
          focusNode: node,
          keyboardType: TextInputType.number,
          placeholder: " ",
          textEditCtrl: ctrl,
          style: TextStyle(fontSize: 20.sp, color: AppColor.textBlack),
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          maxLength: 1,
          padding: EdgeInsets.only(top: 1.w, left: 2.5.w),
        ),
      ),
    );
  }
}
