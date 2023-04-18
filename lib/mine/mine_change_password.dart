import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MineChangePasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineChangePasswordController>(
        MineChangePasswordController(datas: Get.arguments));
  }
}

class MineChangePasswordController extends GetxController {
  final dynamic datas;
  MineChangePasswordController({this.datas});
  late BottomPayPassword bottomPayPassword;

  final _nextBtnEnable = true.obs;
  bool get nextBtnEnable => _nextBtnEnable.value;
  set nextBtnEnable(v) => _nextBtnEnable.value = v;

  late BuildContext context;

  TextEditingController changePwdCtrl = TextEditingController();
  TextEditingController changePwdConfirmCtrl = TextEditingController();

  bool setPwdSuccess = false;
  setPwdAction({Function()? successCallback}) {
    Map<String, dynamic> params = {
      // "code": authCodeInputCtrl.text,
      // "new1st_Pad": pwdCtrl.text,
      "phoneKey": AppDefault().deviceId
    };
    String url = Urls.userChangePwd;

    simpleRequest(
      url: url,
      params: params,
      success: (success, json) {
        if (success) {
          Get.find<HomeController>().homeOnRefresh();
          if (successCallback != null) {
            successCallback();
          }
        }
      },
      after: () {},
    );
  }

  changePwd(String pwd) {
    nextBtnEnable = false;

    simpleRequest(
      url: Urls.user1stPadEdit,
      params: {
        "old3nd_Pad": pwd,
        "new1st_Pad": changePwdCtrl.text,
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

  changePwdAction() {
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

  @override
  void onInit() {
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        changePwd(payPwd);
      },
    );
    super.onInit();
  }

  @override
  void onClose() {
    changePwdCtrl.dispose();
    changePwdConfirmCtrl.dispose();
    super.onClose();
  }
}

class MineChangePassword extends GetView<MineChangePasswordController> {
  const MineChangePassword({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(
          context,
          "修改登录密码",
        ),
        body: getInputBodyNoBtn(context,
            contentColor: Colors.transparent,
            marginTop: 10,
            buttonHeight: 80.w + paddingSizeBottom(context),
            children: [
              //修改登录密码
              centClm([
                sbhRow([
                  getSimpleText(
                      "必须是8-16个字符之间，包含字母和数字组合的新密码", 12, AppColor.text3)
                ], width: 375 - 15.5 * 2, height: 50),
                // pwdInput(0),
                // ghb(15),
                pwdInput(0),
                pwdInput(1),
                ghb(31.5),
                GetX<MineChangePasswordController>(
                  builder: (controller) {
                    return getLoginBtn("确认", () {
                      controller.changePwdAction();
                    }, haveShadow: false, enable: controller.nextBtnEnable);
                  },
                )
              ]),
            ]),
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
        title = "新密码";
        placeholder = "请输入新密码";
        textCtrl = controller.changePwdCtrl;
        maxLength = 20;
        break;
      case 1:
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
}
