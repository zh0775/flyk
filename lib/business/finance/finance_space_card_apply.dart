import 'package:cxhighversion2/business/finance/finance_space.dart';
import 'package:cxhighversion2/business/finance/finance_space_card_list.dart';
import 'package:cxhighversion2/business/finance/finance_space_order_list.dart';
import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FinanceSpaceCardApplyBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<FinanceSpaceCardApplyController>(
        FinanceSpaceCardApplyController(datas: Get.arguments));
  }
}

class FinanceSpaceCardApplyController extends GetxController {
  final dynamic datas;
  FinanceSpaceCardApplyController({this.datas});

  final nameInputCtrl = TextEditingController();
  final noInputCtrl = TextEditingController();
  final phoneInputCtrl = TextEditingController();

  final _btnEnable = true.obs;
  bool get btnEnable => _btnEnable.value;
  set btnEnable(v) => _btnEnable.value = v;

  loadInfoContent() {
    simpleRequest(
      url: Urls.ruleDescriptionByID(type == 0 ? 5 : 6),
      params: {},
      success: (success, json) {
        if (success) {
          List infos = json["data"] ?? [];
          if (infos.isNotEmpty) {
            applyInfoContent = infos[0]["content"] ?? "";
          }
        }
      },
      after: () {},
      useCache: true,
    );
  }

  String applyInfoContent = "";

  confirmAction() {
    if (nameInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写个人姓名");
      return;
    }
    if (noInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写身份证号");
      return;
    }
    if (phoneInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写手机号");
      return;
    }
    btnEnable = false;
    simpleRequest(
      url: type == 0 ? Urls.userCreditCardAdd : Urls.userCreditCardLoansAdd,
      params: {
        "merName": nameInputCtrl.text,
        "merIdentityNo": noInputCtrl.text,
        "merMobile": phoneInputCtrl.text,
        "bankCardId": cardData["id"],
      },
      success: (success, json) {
        push(
            AppSuccessResult(
              title: "申请结果",
              success: success,
              contentTitle: success ? "提交成功" : json["messages"] ?? "提交失败",
              buttonTitles: const ["查看记录", "返回列表"],
              backPressed: () {
                Get.until((route) => route is GetPageRoute
                    ? route.binding is FinanceSpaceBinding ||
                            route.binding is MainPageBinding
                        ? true
                        : false
                    : false);
              },
              onPressed: (index) {
                Get.offUntil(
                    GetPageRoute(
                        page: () => index == 0
                            ? const FinanceSpaceOrderList()
                            : const FinanceSpaceCardList(),
                        binding: index == 0
                            ? FinanceSpaceOrderListBinding()
                            : FinanceSpaceCardListBinding(),
                        settings: RouteSettings(
                            arguments: {"type": type},
                            name: index == 0
                                ? "FinanceSpaceOrderList"
                                : "FinanceSpaceCardList")),
                    (route) => route is GetPageRoute
                        ? route.binding is FinanceSpaceBinding ||
                                route.binding is MainPageBinding
                            ? true
                            : false
                        : false);
              },
            ),
            Global.navigatorKey.currentContext!);
      },
      after: () {
        btnEnable = true;
      },
    );
  }

  @override
  void onClose() {
    nameInputCtrl.dispose();
    noInputCtrl.dispose();
    phoneInputCtrl.dispose();
    super.onClose();
  }

  int type = 0;
  Map cardData = {};

  @override
  void onInit() {
    if (datas != null) {
      type = datas["type"] ?? 0;
      cardData = datas["data"] ?? {};
    }
    loadInfoContent();
    super.onInit();
  }
}

class FinanceSpaceCardApply extends GetView<FinanceSpaceCardApplyController> {
  const FinanceSpaceCardApply({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "在线申请", action: [
          CustomButton(
            onPressed: () {
              pushInfoContent(
                title: "特别说明",
                content: controller.applyInfoContent,
              );
            },
            child: SizedBox(
              width: 75.w,
              height: kToolbarHeight,
              child: Center(
                child: getSimpleText("特别说明", 14, AppColor.text2),
              ),
            ),
          )
        ]),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                width: 375.w,
                height: 300.w + 6.w,
                child: Stack(
                  children: [
                    Positioned.fill(
                        bottom: 6.w,
                        child: Image.asset(
                          assetsName("business/finance/bg_shenqing"),
                          width: 375.w,
                          height: 300.w,
                          fit: BoxFit.fill,
                        )),
                    Positioned.fill(
                        top: 271.w,
                        left: 15.w,
                        right: 15.w,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(8.w))),
                          child: sbRow([
                            centRow([
                              Container(
                                width: 3.w,
                                height: 15.w,
                                decoration: BoxDecoration(
                                    color: AppColor.theme,
                                    borderRadius:
                                        BorderRadius.circular(1.25.w)),
                              ),
                              gwb(8),
                              getSimpleText("请完善您的个人信息", 15, AppColor.text,
                                  isBold: true),
                            ]),
                          ], width: 315),
                        ))
                  ],
                ),
              ),
              Container(
                width: 345.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(8.w))),
                child: Column(
                  children: [
                    ghb(15),
                    inputView(0),
                    inputView(1),
                    inputView(2),
                    ghb(5),
                  ],
                ),
              ),
              ghb(30),
              GetX<FinanceSpaceCardApplyController>(
                builder: (_) {
                  return getSubmitBtn("立即申请", () {
                    takeBackKeyboard(context);
                    controller.confirmAction();
                  },
                      fontSize: 15,
                      color: AppColor.theme,
                      height: 45,
                      enable: controller.btnEnable);
                },
              ),
              ghb(10),
              getWidthText("*请确认以上信息与申请信息完全一致，填写错误将会导致申请无 法通过，或者无法查询办理进度。", 12,
                  AppColor.text3, 345, 2)
            ],
          ),
        ),
      ),
    );
  }

  Widget inputView(int type) {
    return sbhRow([
      getWidthText(
          type == 0
              ? "姓名"
              : type == 1
                  ? "身份证号"
                  : "手机号",
          14,
          AppColor.text2,
          60,
          1,
          textHeight: 1.3),
      CustomInput(
        width: (315 - 60 - 1).w,
        heigth: 50.w,
        textEditCtrl: type == 0
            ? controller.nameInputCtrl
            : type == 1
                ? controller.noInputCtrl
                : controller.phoneInputCtrl,
        placeholder: type == 0
            ? "请输入姓名"
            : type == 1
                ? "请输入身份证号"
                : "请输入手机号",
        maxLength: type == 2 ? 11 : null,
        keyboardType: type == 2 ? TextInputType.phone : TextInputType.text,
        style: TextStyle(fontSize: 14.w, color: AppColor.text2),
        placeholderStyle: TextStyle(fontSize: 14.w, color: AppColor.assisText),
      )
    ], width: 345 - 15 * 2, height: 50);
  }
}
