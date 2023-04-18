import 'dart:async';
import 'package:cxhighversion2/business/mallOrder/mall_order_page.dart';
import 'package:cxhighversion2/business/pointsMall/points_mall_page.dart';
import 'package:cxhighversion2/business/pointsMall/shopping_product_list.dart';
import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_alipay.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MallOrderPayBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MallOrderPayController>(
        MallOrderPayController(datas: Get.arguments));
  }
}

class MallOrderPayController extends GetxController {
  final dynamic datas;
  MallOrderPayController({this.datas});

  Timer? myTimer;

  final _payIndex = 0.obs;
  int get payIndex => _payIndex.value;
  set payIndex(v) => _payIndex.value = v;

  // bool isRepurchase = true;
  // Map integralData = {};
  DateTime now = DateTime.now().add(const Duration(minutes: 30));

  String hours = "00";
  String minutes = "30";
  String seconds = "00";

  String timeBuildId = "IntegralProjectPay_timeBuildId";

  late BottomPayPassword bottomPayPassword;

  loadPay(String pwd) {
    Map<String, dynamic> params = {
      "version_Origin": AppDefault().versionOriginForPay(),
      "u_3nd_Pad": pwd,
      "product_Type": isCar ? 1 : 2,
      "delivery_Method": 1,
      "pay_Method": payTypeIdx + 1,
      "contactID": address["id"],
      "user_Remarks": remarks,
    };
    List orderProduct = [];
    if (isCar) {
      for (var i = 0; i < integralDatas.length; i++) {
        Map e = integralDatas[i];
        orderProduct.add({
          "carId": e["carId"],
          "productId": e["productId"],
          "productListId": e["productListId"],
          "num": e["num"],
          "shopType": 2,
          "productPropertyList": e["shopPropertyList"],
        });
      }
    } else {
      if (integralDatas.isEmpty) {
        return;
      }
      Map data = integralDatas[0];
      orderProduct.add({
        "productId": data["productId"],
        "productListId": data["productListId"],
        "num": data["num"],
        "shopType": 2,
        "productPropertyList": data["shopPropertyList"],
      });
    }

    params["orderProduct"] = orderProduct;
    // return;
    simpleRequest(
      url: Urls.userGenerateBigOrders,
      params: params,
      success: (success, json) async {
        Map data = json["data"] ?? {};
        if (payTypeIdx == 0) {
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
                            page: () => const MallOrderPage(),
                            binding: MallOrderPageBinding(),
                            settings: const RouteSettings(
                              name: "MallOrderPage",
                            )),
                        (route) => route is GetPageRoute
                            ? route.binding is MainPageBinding ||
                                    route.binding is PointsMallPageBinding
                                ? true
                                : false
                            : false);
                  } else {
                    Get.offUntil(
                        GetPageRoute(
                            page: () => const ShoppingProductList(),
                            binding: ShoppingProductListBinding(),
                            settings: const RouteSettings(
                              name: "ShoppingProductList",
                            )),
                        (route) => route is GetPageRoute
                            ? route.binding is MainPageBinding ||
                                    route.binding is PointsMallPageBinding
                                ? true
                                : false
                            : false);
                  }
                },
              ),
              Global.navigatorKey.currentContext!);
        } else {
          Map aliData = await CustomAlipay().payAction(
            data["aliData"],
            payBack: () {
              Get.find<HomeController>().refreshHomeData();
              Get.offUntil(
                  GetPageRoute(
                      page: () => const MallOrderPage(),
                      binding: MallOrderPageBinding(),
                      settings: const RouteSettings(
                        name: "MallOrderPage",
                      )),
                  (route) => route is GetPageRoute
                      ? route.binding is MainPageBinding ||
                              route.binding is PointsMallPageBinding
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
                              page: () => const MallOrderPage(),
                              binding: MallOrderPageBinding(),
                              settings: const RouteSettings(
                                name: "MallOrderPage",
                              )),
                          (route) => route is GetPageRoute
                              ? route.binding is MainPageBinding ||
                                      route.binding is PointsMallPageBinding
                                  ? true
                                  : false
                              : false);
                    } else {
                      Get.offUntil(
                          GetPageRoute(
                              page: () => const ShoppingProductList(),
                              binding: ShoppingProductListBinding(),
                              settings: const RouteSettings(
                                name: "ShoppingProductList",
                              )),
                          (route) => route is GetPageRoute
                              ? route.binding is MainPageBinding ||
                                      route.binding is PointsMallPageBinding
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
  }

  // Map productMainData = {};
  int payTypeIdx = 0;
  // int productNum = 1;
  bool isCar = false;
  Map address = {};

  List integralDatas = [];
  // List subSelectList = [];
  // List payTypeAndNumDatas = [];
  String remarks = "";

  String payPrice = "";

  @override
  void onInit() {
    if (datas != null) {
      // isRepurchase = datas["isRepurchase"] ?? true;
      // integralData = datas["data"] ?? {};
      integralDatas = datas["data"] ?? [];
      // payTypeAndNumDatas = datas["payNumDatas"] ?? [];
      payTypeIdx = datas["payType"] ?? 0;
      // productNum = datas["productNum"] ?? 1;
      // productMainData = datas["mainData"] ?? {};
      isCar = datas["isCar"] ?? false;
      address = datas["address"] ?? {};
      remarks = datas["remarks"] ?? {};

      double allPrice = 0;
      double allPoint = 0;
      double allCash = 0;
      // int allNum = 0;

      for (var e in integralDatas) {
        int num = e["num"] ?? 1;
        // allNum += num;
        allPoint += (e["nowPoint"] ?? 0) * num;
        allCash += (e["cashPrice"] ?? 0) * num;
        allPrice += (e["nowPrice"] ?? 0) * num;
      }
      if (payTypeIdx == 0) {
        payPrice = "${priceFormat(allPrice, savePoint: 0)}积分";
      } else {
        payPrice =
            "${priceFormat(allPoint, savePoint: 0)}积分+${priceFormat(allCash, savePoint: 2)}元";
      }
      // subSelectList = datas["subSelectList"] ?? [];
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

class MallOrderPay extends GetView<MallOrderPayController> {
  const MallOrderPay({super.key});

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
                      getSimpleText(controller.payPrice, 30, AppColor.text,
                          isBold: true),
                      ghb(5),
                      GetBuilder<MallOrderPayController>(
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
                              assetsName(controller.payTypeIdx == 1
                                  ? "home/integralRepurchase/icon_${index == 0 ? "alipay" : "wx"}"
                                  : "mine/jf/icon_jf"),
                              width: controller.payTypeIdx == 0 ? 24.w : 21.w,
                              fit: BoxFit.fitWidth,
                            ),
                            gwb(6),
                            getSimpleText(
                                "${controller.payTypeIdx == 1 ? index == 0 ? "支付宝" : "微信" : "积分钱包"}支付",
                                14,
                                AppColor.text2),
                          ]),
                          GetX<MallOrderPayController>(
                            builder: (_) {
                              return Image.asset(
                                assetsName(
                                    "business/mall/checkbox_orange_${controller.payIndex == index ? "selected" : "normal"}"),
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
                }, height: 45, color: AppColor.themeOrange)
              ],
            )),
      ),
    );
  }
}
