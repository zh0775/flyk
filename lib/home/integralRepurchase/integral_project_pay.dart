import 'dart:async';

import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_alipay.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/home/integralRepurchase/integral_repurchase.dart';
import 'package:cxhighversion2/home/integralRepurchase/integral_repurchase_order.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/mine/integral/integral_cash_order_list.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IntegralProjectPayBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IntegralProjectPayController>(
        IntegralProjectPayController(datas: Get.arguments));
  }
}

class IntegralProjectPayController extends GetxController {
  final dynamic datas;
  IntegralProjectPayController({this.datas});

  Timer? myTimer;

  final _payIndex = 0.obs;
  int get payIndex => _payIndex.value;
  set payIndex(v) => _payIndex.value = v;

  bool isRepurchase = true;
  Map integralData = {};
  DateTime now = DateTime.now().add(const Duration(minutes: 30));

  String hours = "00";
  String minutes = "30";
  String seconds = "00";

  String timeBuildId = "IntegralProjectPay_timeBuildId";

  late BottomPayPassword bottomPayPassword;

  loadPay(String pwd) {
    if (isRepurchase) {
      simpleRequest(
        url: Urls.userIntegralRepurchase,
        params: {
          "pay_Method": payIndex + 1,
          "creditCashing_ID": integralData["id"],
          "u_3nd_Pad": pwd,
        },
        success: (success, json) async {
          if (success) {
            Map data = json["data"] ?? {};
            if (data["aliData"] == null || data["aliData"].isEmpty) {
              ShowToast.normal("支付失败，请稍后再试");
              return;
            }
            Map aliData = await CustomAlipay().payAction(
              data["aliData"],
              payBack: () {
                Get.find<HomeController>().refreshHomeData();
                Get.offUntil(
                    GetPageRoute(
                        page: () => const IntegralRepurchaseOrder(),
                        binding: IntegralRepurchaseOrderBinding(),
                        settings: const RouteSettings(
                          name: "IntegralRepurchaseOrder",
                        )),
                    (route) => route is GetPageRoute
                        ? route.binding is MainPageBinding
                            ? true
                            : false
                        : false);
              },
            );

            if (!kIsWeb) {
              if (aliData["resultStatus"] == "9000") {
                Get.find<HomeController>().refreshHomeData();
              }
              push(
                  AppSuccessResult(
                    success: aliData["resultStatus"] == "9000",
                    title: "支付结果",
                    contentTitle:
                        aliData["resultStatus"] == "9000" ? "支付成功" : "支付失败",
                    buttonTitles: const ["查看订单", "继续购买"],
                    backPressed: () {
                      popToUntil();
                    },
                    onPressed: (index) {
                      if (index == 0) {
                        Get.offUntil(
                            GetPageRoute(
                                page: () => const IntegralRepurchaseOrder(),
                                binding: IntegralRepurchaseOrderBinding(),
                                settings: const RouteSettings(
                                  name: "IntegralRepurchaseOrder",
                                )),
                            (route) => route is GetPageRoute
                                ? route.binding is MainPageBinding
                                    ? true
                                    : false
                                : false);
                      } else {
                        Get.offUntil(
                            GetPageRoute(
                                page: () => const IntegralRepurchase(),
                                binding: IntegralRepurchaseBinding(),
                                settings: const RouteSettings(
                                    name: "IntegralRepurchase",
                                    arguments: {
                                      "isRepurchase": true,
                                    })),
                            (route) => route is GetPageRoute
                                ? route.binding is MainPageBinding
                                    ? true
                                    : false
                                : false);
                      }
                    },
                  ),
                  Global.navigatorKey.currentContext!);
            }
          }
        },
        after: () {},
      );
    } else {
      simpleRequest(
        url: Urls.userTransfer,
        params: {
          "creditCashing_ID": integralData["id"],
          "u_3nd_Pad": pwd,
        },
        success: (success, json) {
          if (success) {
            Get.find<HomeController>().refreshHomeData();
          }
          push(
              AppSuccessResult(
                success: success,
                title: "支付结果",
                contentTitle: success ? "支付成功" : "支付失败",
                buttonTitles: const ["查看订单", "继续购买"],
                content: success ? "" : json["messages"] ?? "",
                backPressed: () {
                  popToUntil();
                },
                onPressed: (index) {
                  if (index == 0) {
                    Get.offUntil(
                        GetPageRoute(
                            page: () => const IntegralCashOrderList(),
                            binding: IntegralCashOrderListBinding(),
                            settings: const RouteSettings(
                              name: "IntegralCashOrderList",
                            )),
                        (route) => route is GetPageRoute
                            ? route.binding is MainPageBinding
                                ? true
                                : false
                            : false);
                  } else {
                    Get.offUntil(
                        GetPageRoute(
                            page: () => const IntegralRepurchase(),
                            binding: IntegralRepurchaseBinding(),
                            settings: const RouteSettings(
                                name: "IntegralRepurchase",
                                arguments: {
                                  "isRepurchase": false,
                                })),
                        (route) => route is GetPageRoute
                            ? route.binding is MainPageBinding
                                ? true
                                : false
                            : false);
                  }
                },
              ),
              Global.navigatorKey.currentContext!);
        },
        after: () {},
      );
    }
  }

  @override
  void onInit() {
    if (datas != null) {
      isRepurchase = datas["isRepurchase"] ?? true;
      integralData = datas["data"] ?? {};
    }

    myTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now2 = DateTime.now();
      Duration d = now.difference(now2);
      int m = (d.inSeconds / 60).floor();
      int s = d.inSeconds - m * 60;
      minutes = "${m < 10 ? "0$m" : m}";
      seconds = "${s < 10 ? "0$s" : s}";
      update([timeBuildId]);
    });
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        loadPay(payPwd);
      },
    );
    super.onInit();
  }

  @override
  void onClose() {
    if (myTimer != null) {
      myTimer!.cancel();
      myTimer = null;
    }

    super.onClose();
  }
}

class IntegralProjectPay extends GetView<IntegralProjectPayController> {
  const IntegralProjectPay({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: getDefaultAppBar(context, "支付订单"),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  width: 375.w,
                  height: 141.w,
                  child: Center(
                    child: centClm([
                      getSimpleText("实付金额", 12, AppColor.text3),
                      ghb(5),
                      getSimpleText(
                          controller.isRepurchase
                              ? "￥${priceFormat((controller.integralData["price2"] ?? 0) * (controller.integralData["num"] ?? 1))}"
                              : "${priceFormat((controller.integralData["price"] ?? 0) * (controller.integralData["num"] ?? 1), savePoint: 0)}积分",
                          30,
                          AppColor.text,
                          isBold: true),
                      ghb(5),
                      GetBuilder<IntegralProjectPayController>(
                        id: controller.timeBuildId,
                        builder: (_) {
                          return getSimpleText(
                              "剩余支付时间 ${controller.hours} : ${controller.minutes} : ${controller.seconds}",
                              12,
                              AppColor.text3);
                        },
                      ),
                    ]),
                  ),
                ),
                Container(
                  width: 345.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Column(
                    children: List.generate(1, (index) {
                      return CustomButton(
                        onPressed: () {
                          controller.payIndex = index;
                        },
                        child: sbhRow([
                          centRow([
                            Image.asset(
                              assetsName(controller.isRepurchase
                                  ? "home/integralRepurchase/icon_${index == 0 ? "alipay" : "wx"}"
                                  : "mine/jf/icon_jf"),
                              width: controller.isRepurchase ? 24.w : 21.w,
                              fit: BoxFit.fitWidth,
                            ),
                            gwb(6),
                            getSimpleText(
                                "${controller.isRepurchase ? index == 0 ? "支付宝" : "微信" : "积分钱包"}支付",
                                14,
                                AppColor.text2),
                          ]),
                          GetX<IntegralProjectPayController>(
                            builder: (_) {
                              return Image.asset(
                                assetsName(
                                    "machine/checkbox_${controller.payIndex == index ? "selected" : "normal"}"),
                                width: 21.w,
                                fit: BoxFit.fitWidth,
                              );
                            },
                          ),
                        ], width: 345 - 15 * 2, height: 50),
                      );
                    }),
                  ),
                ),
                ghb(30),
                getSubmitBtn("确认支付", () {
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
                  controller.bottomPayPassword.show();
                }, height: 45, color: AppColor.theme)
              ],
            )),
      ),
    );
  }
}
