import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_pin_textfield.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomPayPassword {
  final Widget? centerWidget;
  final double? centerWidgetHeight;
  final Function()? closeClick;
  final BuildContext? context;
  final String? title;
  final String? subTitle;
  final String? btnTitle;
  final String? errorText;
  final bool showValue;
  final Function(String payPwd)? confirmClick;
  BottomPayPassword.init({
    this.centerWidget,
    this.closeClick,
    this.centerWidgetHeight,
    this.context,
    this.showValue = false,
    this.title = "请输入支付密码",
    this.subTitle = "为了您的交易安全，支付前请先输入平台支付密码",
    this.btnTitle = "确认",
    this.errorText = "请输入6位支付密码",
    this.confirmClick,
  }) {
    // for (var i = 0; i < pwdCtrlList.length; i++) {
    //   TextEditingController e = pwdCtrlList[i];
    //   e.addListener(() {
    //     pwdListener(e, i);
    //   });
    // }
    // pwdCtrl = TextEditingController();
    // key = GlobalKey();
    homeData = AppDefault().homeData;
  }
  // late GlobalKey key;
  // TextEditingController? pwdCtrl;
  final pwdCounts = [0, 0, 0, 0, 0, 0];
  List pwdCtrlList = [];
  List pwdFocusNodeList = [];
  String pwd = "";
  Map homeData = {};

  // pwdListener(TextEditingController ctrl, int index) {
  //   if (ctrl.text.isNotEmpty && pwdCounts[index] == 0) {
  //     if (index < pwdFocusNodeList.length - 1) {
  //       FocusScope.of(context ?? Global.navigatorKey.currentContext!)
  //           .requestFocus(pwdFocusNodeList[index + 1]);
  //     }
  //   } else if (ctrl.text.isEmpty && pwdCounts[index] != 0) {
  //     if (index > 0) {
  //       FocusScope.of(context ?? Global.navigatorKey.currentContext!)
  //           .requestFocus(pwdFocusNodeList[index - 1]);
  //     }
  //   }
  //   pwdCounts[index] = ctrl.text.length;
  //   int tCount = 0;
  //   for (TextEditingController item in pwdCtrlList) {
  //     if (item.text.isNotEmpty) {
  //       tCount++;
  //     }
  //   }
  //   if (tCount == 6) {}
  // }

  show() {
    pwd = "";
    // if (pwdCtrl != null) {
    //   pwdCtrl!.dispose();
    // }
    // pwdCtrl = TextEditingController();
    // dispos();
    // initCtrl();
    showGeneralDialog(
      context: Global.navigatorKey.currentContext!,
      barrierLabel: "",
      pageBuilder: (context, animation, secondaryAnimation) {
        return UnconstrainedBox(
            child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 330.w,
              height: 255.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.w)),
              child: Column(
                children: [
                  gwb(330),
                  sbhRow([
                    gwb(42),
                    getSimpleText("支付密码", 17, AppColor.text, isBold: true),
                    CustomButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: 42.w,
                        height: 65.w,
                        child: Center(
                          child: Image.asset(
                            assetsName("statistics/machine/btn_model_close"),
                            width: 18.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    )
                  ], width: 330, height: 65),
                  getSimpleText("请输入支付密码，已验证身份", 14, AppColor.text2),
                  ghb(25),
                  CustomPinTextfield(
                    obscureText: !showValue,
                    controller: TextEditingController(),
                    width: 300,
                    insideColor: Colors.white,
                    singleHeight: 50,
                    singleWidth: 50,
                    inactiveColor: AppColor.lineColor,
                    selectedColor: AppColor.text,
                    borderRadius: 0,
                    onChanged: (v) {
                      pwd = v;
                      // debugPrint(v);
                      // if (v.length >= 6) {}
                    },
                  ),
                  ghb(31),
                  getSubmitBtn("确认", () {
                    if (confirmClick != null) {
                      // confirmClick!(pwdCtrl!.text);
                      if (pwd.isEmpty) {
                        ShowToast.normal("请输入支付密码");
                        return;
                      } else if (pwd.length < 6) {
                        ShowToast.normal("请输入6位支付密码");
                        return;
                      } else {
                        confirmClick!(pwd);
                      }
                      Navigator.pop(context);
                    }
                  },
                      width: 300,
                      height: 40,
                      color: AppColor.theme,
                      fontSize: 15),
                ],
              ),
            ),
          ),
        ));
      },
    );
    // Get.bottomSheet(
    //   SizedBox(
    //     width: 375.w,
    //     height: (344.5 + (centerWidgetHeight ?? 35)).w,
    //     child: Stack(
    //       children: [
    //         Positioned(
    //             right: 24.w,
    //             top: 0,
    //             width: 37.w,
    //             height: 56.5.w,
    //             child: CustomButton(
    //               onPressed: () {
    //                 takeBackKeyboard(Global.navigatorKey.currentContext!);
    //                 if (closeClick != null) {
    //                   closeClick!();
    //                   Navigator.pop(Global.navigatorKey.currentContext!);
    //                 } else {
    //                   Navigator.pop(Global.navigatorKey.currentContext!);
    //                 }
    //               },
    //               child: Image.asset(
    //                 assetsName(
    //                   "common/btn_model_close",
    //                 ),
    //                 width: 37.w,
    //                 height: 56.5.w,
    //                 fit: BoxFit.fill,
    //               ),
    //             )),
    //         Positioned(
    //             top: 56.5.w,
    //             left: 0,
    //             right: 0,
    //             bottom: 0,
    //             child: GestureDetector(
    //               onTap: () =>
    //                   takeBackKeyboard(Global.navigatorKey.currentContext!),
    //               child: Container(
    //                 width: 375.w,
    //                 height: ((344.5 + (centerWidgetHeight ?? 35)) - 56.5).w,
    //                 decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius:
    //                         BorderRadius.vertical(top: Radius.circular(6.w))),
    //                 child: Column(
    //                   children: [
    //                     SizedBox(
    //                       height: 49.w,
    //                       child: Center(
    //                         child: getSimpleText(
    //                             title ?? "", 16, AppColor.textBlack,
    //                             isBold: true),
    //                       ),
    //                     ),
    //                     gline(375, 0.5),
    //                     centerWidget ?? ghb(35),
    //                     CustomPinTextfield(
    //                       obscureText: !showValue,
    //                       controller: TextEditingController(),
    //                       width: 375 - 25 * 2,
    //                       onChanged: (v) {
    //                         pwd = v;
    //                         // debugPrint(v);
    //                         // if (v.length >= 6) {}
    //                       },
    //                     ),
    //                     ghb(30),
    //                     getSimpleText(subTitle ?? "", 13, AppColor.textGrey),
    //                     ghb(45),
    // getSubmitBtn(btnTitle ?? "", () {
    //   // String text = "";
    //   // for (var item in pwdCtrlList) {
    //   //   text += (item.text.isEmpty ? "" : item.text);
    //   // }
    //   // if (text.length < 6 && errorText != null) {
    //   //   ShowToast.normal(errorText!);
    //   // }
    //   if (confirmClick != null) {
    //     // confirmClick!(pwdCtrl!.text);
    //     if (pwd == null || pwd.length == 0) {
    //       ShowToast.normal("请输入支付密码");
    //       return;
    //     } else if (pwd.length < 6) {
    //       ShowToast.normal("请输入6位支付密码");
    //       return;
    //     } else {
    //       confirmClick!(pwd);
    //     }
    //     Navigator.pop(Global.navigatorKey.currentContext!);
    //   }
    // }),
    //                   ],
    //                 ),
    //               ),
    //             ))
    //       ],
    //     ),
    //   ),
    //   isScrollControlled: true,
    //   enableDrag: false,
    //   isDismissible: false,
    // );
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
          showValue: false,
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

  dispos() {
    // for (var i = 0; i < pwdCtrlList.length; i++) {
    //   TextEditingController e = pwdCtrlList[i];
    //   FocusNode n1 = pwdFocusNodeList[i];
    //   if (e != null) {
    //     e.removeListener(() {});
    //     e.dispose();
    //   }
    //   if (n1 != null) {
    //     n1.dispose();
    //   }
    // }
    // if (pwdCtrl != null) {
    //   pwdCtrl!.dispose();
    // }
  }

  initCtrl() {
    // pwdCtrlList = [
    //   TextEditingController(),
    //   TextEditingController(),
    //   TextEditingController(),
    //   TextEditingController(),
    //   TextEditingController(),
    //   TextEditingController(),
    // ];
    // pwdFocusNodeList = [
    //   FocusNode(),
    //   FocusNode(),
    //   FocusNode(),
    //   FocusNode(),
    //   FocusNode(),
    //   FocusNode()
    // ];
    // for (var i = 0; i < pwdCtrlList.length; i++) {
    //   TextEditingController e = pwdCtrlList[i];
    //   e.addListener(() {
    //     pwdListener(e, i);
    //   });
    //   pwdCounts[i] = 0;
    // }
    // pwdCtrl == TextEditingController();
  }
}
