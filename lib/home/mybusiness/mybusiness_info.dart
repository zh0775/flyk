import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/mybusiness/mybusiness_transaction_list.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyBusinessInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyBusinessInfoController>(MyBusinessInfoController());
  }
}

class MyBusinessInfoController extends GetxController {
  List moneyScales = [0, 5, 10, 15, 20];
  final _moneyHistogramIdx = 0.obs;
  int get moneyHistogramIdx => _moneyHistogramIdx.value;
  set moneyHistogramIdx(v) {
    _moneyHistogramIdx.value = v;
    loadHistogram();
  }

  int moneyHistogramButtonIdx = 0;
  List moneyHistory = [];

  List rateList = [];

  String overTime = "";

  List businessEnum = [];
  List businessTyps = [];

  loadBusinessEnum() {
    simpleRequest(
      url: Urls.userMerchantEnum,
      params: {},
      success: (success, json) {
        if (success) {
          businessEnum = json["data"]["children"];

          update();
          // if (businessData.isNotEmpty) {
          // businessEnumFormat();
          // }
        }
      },
      after: () {},
    );
  }

  businessEnumFormat() {
    if (businessEnum.isNotEmpty && businessData.isNotEmpty) {
      // for (var item in businessData) {
      //   if ("${item["enumValue"]}" == "0") {
      //     item["desc"] = "我的所有直属商户";
      //   }
      //   for (var item2 in businessEnum) {
      //     if ("${item["enumValue"]}" == "${item2["enumValue"]}") {
      //       item["desc"] = item2["enumDesc"];
      //       item["logo"] = item2["logo"];
      //     }
      //   }
      // }
    }
  }

  int maxHistogramCount = 0;
  Map histogramScales = {};
  loadHistogram() {
    Map<String, dynamic> params = {
      "date_Type": moneyHistogramIdx + 1,
    };
    if (fromMachine) {
      params["id"] = merchantId;
    } else {
      params["id"] = int.parse("${businessData["tId"] ?? -1}");
    }
    simpleRequest(
      url: Urls.userMerchantDetails2,
      params: params,
      success: (success, json) {
        if (success) {
          List d = json["data"]["histogramData"];

          if (d.isNotEmpty) {
            List date = d[0]["date"];
            List data = d[0]["data"];
            moneyHistory = [];
            for (var i = 0; i < date.length; i++) {
              moneyHistory
                  .add({"date": date[i], "num": double.parse("${data[i]}")});
            }
          }
        }
        double num = 0;
        for (var e in moneyHistory) {
          if (e["num"] > num) {
            num = e["num"];
          }
        }
        maxHistogramCount = getMaxCount(num);
        histogramScales = getChartScale(num);
        moneyScales = [];
        List t = [];
        for (var i = 0; i < histogramScales.values.length; i++) {
          t.add(histogramScales[i]);
        }
        for (var i = t.length - 1; i >= 0; i--) {
          moneyScales.add(t[i]);
        }

        update();
      },
      after: () {},
    );
  }

  loadDetail() {
    Map<String, dynamic> params = {
      "date_Type": moneyHistogramIdx + 1,
    };

    late dynamic id;
    if (fromMachine) {
      id = merchantId;
    } else {
      id = int.parse("${businessData["tId"] ?? -1}");
    }

    simpleRequest(
      url: Urls.userMerchantShow(id),
      params: {},
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          businessData = data;
          if (businessData["merchantTypes"] != null &&
              businessData["merchantTypes"].isNotEmpty) {
            businessTyps = (businessData["merchantTypes"] as String).split(",");
          }
          if (businessData["isActivation"] != null &&
              businessData["isActivation"] <= 0 &&
              businessData["bindTime"] != null &&
              businessData["bindTime"].isNotEmpty) {
            DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
            DateTime bindDate = dateFormat.parse(businessData["bindTime"]);
            Duration overDuration = Duration(
                milliseconds: DateTime.now().millisecondsSinceEpoch -
                    bindDate.millisecondsSinceEpoch);
            int overDay =
                (businessData["activationDay"] ?? 0) - overDuration.inDays;
            overTime = overDay > 0 ? "$overDay" : "";
          } else {
            overTime = "";
          }
          update();
        }
      },
      after: () {},
    );
  }

  bool isFirst = true;
  Map businessData = {};
  bool fromMachine = false;
  int merchantId = 0;
  dataInit(Map bData, bool form, int id) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    businessData = bData;
    fromMachine = form;
    merchantId = id;
    loadBusinessEnum();
    loadDetail();
    loadHistogram();
  }

  @override
  void onInit() {
    super.onInit();
  }
}

class MyBusinessInfo extends GetView<MyBusinessInfoController> {
  final Map businessData;
  final Map businessType;
  final bool fromMachine;
  final int merchantId;
  const MyBusinessInfo({
    Key? key,
    this.businessData = const {},
    this.businessType = const {},
    this.fromMachine = false,
    this.merchantId = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(businessData, fromMachine, merchantId);
    return Scaffold(
      appBar: getDefaultAppBar(context, "商户信息", action: [
        // GestureDetector(
        //   onTap: () {
        //     if (businessData["rateData"] != null) {
        //       showRateInfo(context);
        //     } else {
        //       ShowToast.normal("暂无费率数据");
        //     }
        //   },
        //   child: SizedBox(
        //       width: 50.w,
        //       height: kToolbarHeight,
        //       child:
        //           Center(child: getSimpleText("费率", 14, AppColor.textBlack))),
        // ),
      ]),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: GetBuilder<MyBusinessInfoController>(
          init: controller,
          initState: (_) {},
          builder: (_) {
            return Column(
              children: [
                gwb(375),
                ghb(10),
                Container(
                    width: 345.w,
                    height: 85.5.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.w),
                            topRight: Radius.circular(5.w)),
                        gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Color(0xFF292732),
                              Color(0xFF484E5E),
                            ])),
                    child: Stack(
                      children: [
                        // Positioned(
                        //     right: 18.w,
                        //     top: (85.5 / 2 - 35 / 2).w,
                        //     child: CustomButton(
                        //       onPressed: () {
                        //         if (businessData["merchantPhone"] == null ||
                        //             businessData["merchantPhone"].isEmpty) {
                        //           ShowToast.normal("没有该商户的电话号码");
                        //           return;
                        //         }
                        //         callPhone(businessData["merchantPhone"]);
                        //       },
                        //       child: assetsSizeImage(
                        //           "home/mybusiness/icon_business_phone",
                        //           35,
                        //           35),
                        //     )),
                        Positioned(
                          width: 173.w,
                          left: 18.w,
                          top: 18.w,
                          bottom: 10.w,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              assetsSizeImage(
                                  "home/mybusiness/icon_business_name", 20, 21),
                              gwb(10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getSimpleText(
                                      controller.businessData["merchantName"] ??
                                          "",
                                      17,
                                      Colors.white,
                                      isBold: true),
                                  ghb(8),
                                  typesView()
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
                topInfo(),
                ghb(10),
                secondView(context),
                ghb(10),
                histogramView(),
                ghb(57)
              ],
            );
          },
        ),
      ),
    );
  }

  Widget typesView() {
    List<Widget> widgets = [];
    if (controller.businessEnum != null &&
        controller.businessEnum.isNotEmpty &&
        controller.businessTyps != null &&
        controller.businessTyps.isNotEmpty) {
      for (var type in controller.businessTyps) {
        for (var enumItem in controller.businessEnum) {
          if ((enumItem["enumValue"] ?? -1) == int.parse(type ?? "-2")) {
            bool isWarn = false;
            int enumValue = int.parse("${enumItem["enumValue"] ?? -1}");
            if (enumValue == 4 || enumValue == 5 || enumValue == 6) {
              isWarn = true;
            }

            widgets.add(Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              message: enumItem["enumDesc"] ?? "",
              child: Container(
                padding: EdgeInsets.fromLTRB(10.w, 4.w, 10.w, 4.w),
                decoration: BoxDecoration(
                    color: isWarn
                        ? const Color(0xFFFFEFEF)
                        : const Color(0xFFD6E7FF),
                    borderRadius: BorderRadius.circular(4.w)),
                child: getSimpleText(enumItem["enumName"] ?? "", 11,
                    isWarn ? const Color(0xFFF03E3E) : const Color(0xFF4889FF)),
              ),
            ));
          }
        }
      }
    }

    return Row(
      children: widgets,
    );
  }

  Widget topInfo() {
    return Container(
      width: 345.w,
      padding: EdgeInsets.fromLTRB(15.w, 15.w, 0, 15.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5.w),
              bottomRight: Radius.circular(5.w))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getSimpleText("商户编号：${controller.businessData["merchantId"] ?? ""}",
              14, AppColor.textBlack),
          ghb(7),
          Row(
            children: [
              getSimpleText(
                  "激活状态：${controller.businessData["isActivation"] == null ? "" : controller.businessData["isActivation"] > 0 ? "已激活" : "未激活"}",
                  14,
                  AppColor.textBlack),
              controller.overTime.isNotEmpty
                  ? Text.rich(TextSpan(
                      text: "(",
                      style:
                          TextStyle(fontSize: 14.sp, color: AppColor.textBlack),
                      children: [
                          TextSpan(
                              text: "剩余激活时间不足${controller.overTime}天",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFFE45050))),
                          TextSpan(
                              text: ")",
                              style: TextStyle(
                                  fontSize: 14.sp, color: AppColor.textBlack)),
                        ]))
                  : const SizedBox(),
            ],
          ),
          ghb(7),
          getSimpleText(
              "达标状态：${controller.businessData["isActivity"] == null ? "" : controller.businessData["isActivity"] <= 0 ? "未达标" : "已达标"}${businessData["activityTime"] != null ? "(${businessData["activityTime"]})" : ""}",
              14,
              AppColor.textBlack),
          ghb(7),
          getSimpleText(
              "伪激活考核：${controller.businessData["isAssessment"] == null ? "" : controller.businessData["isAssessment"] > 0 ? "已考核" : "未考核"}",
              14,
              AppColor.textBlack),
        ],
      ),
    );
  }

  Widget secondView(BuildContext context) {
    List tradeAmountData = controller.businessData["tradeAmountData"] ?? [];
    double djk = 0.0;
    double jjk = 0.0;
    double zfb = 0.0;
    double other = 0.0;
    for (var e in tradeAmountData) {
      if (e["type"] == 1) {
        djk = e["amount"] ?? 0.0;
      } else if (e["type"] == 2) {
        jjk = e["amount"] ?? 0.0;
      } else if (e["type"] == 4) {
        zfb = e["amount"] ?? 0.0;
      } else {
        other += e["amount"] ?? 0.0;
      }
    }
    return Container(
      width: 345.w,
      decoration: getDefaultWhiteDec(),
      child: Column(
        children: [
          ghb(22.5),
          getSimpleText("累计商户全部交易额(元)", 12, AppColor.textBlack),
          ghb(10),
          getSimpleText(
              priceFormat(controller.businessData["thisMTxnAmt"] ?? 0),
              30,
              AppColor.textBlack,
              fw: FontWeight.w500),
          ghb(22),
          gline(345, 0.5),
          sbRow([
            secondViewCell(
              "贷记卡交易额(元)",
              priceFormat(djk),
            ),
            gline(0.5, 68),
            secondViewCell(
              "借记卡交易额(元)",
              priceFormat(jjk),
            ),
          ], width: 345 - 25.5 * 2),
          gline(315, 0.5),
          sbRow([
            secondViewCell(
              "支付宝交易额(元)",
              priceFormat(zfb),
            ),
            gline(0.5, 68),
            secondViewCell(
              "其他交易额(元)",
              priceFormat(other),
            ),
          ], width: 345 - 25.5 * 2),
          gline(315, 0.5),
          CustomButton(
              onPressed: () {
                if (controller.businessData == null ||
                    controller.businessData.isEmpty) {
                  ShowToast.normal("请稍等数据正在请求中");
                  return;
                }
                push(
                    MybusinessTransactionList(
                      businessData: controller.businessData,
                    ),
                    context,
                    binding: MybusinessTransactionListBinding());
              },
              child: SizedBox(
                width: 345.w,
                height: 52.w,
                child: Center(
                  child: centRow([
                    getSimpleText("查看实时交易信息", 14, AppColor.textGrey),
                    gwb(5),
                    Icon(
                      Icons.arrow_right_outlined,
                      size: 28.w,
                      color: const Color(0xFFB3B3B3),
                    ),
                  ]),
                ),
              ))
        ],
      ),
    );
  }

  Widget secondViewCell(String t1, String t2) {
    return SizedBox(
      width: ((345 - 25.5 * 2) / 2 - 30).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ghb(19),
          getSimpleText(t1, 12, AppColor.textBlack),
          ghb(5),
          getSimpleText(t2, 18, AppColor.textBlack, fw: FontWeight.w500),
          ghb(5),
          getSimpleText("累计金额", 10, AppColor.textGrey),
          ghb(19)
        ],
      ),
    );
  }

  Widget histogramView() {
    return Container(
      width: 345.w,
      padding: EdgeInsets.only(top: 25.w, bottom: 10.w),
      decoration: getDefaultWhiteDec(),
      child: GetBuilder<MyBusinessInfoController>(
        init: controller,
        initState: (_) {},
        builder: (_) {
          return Column(
            children: [
              sbRow([
                getSimpleText("商户全部交易额(万元)", 15, AppColor.textBlack),
                centRow([
                  histogramChangeButton(0),
                  histogramChangeButton(1),
                ]),
              ], width: 345 - 18 * 2),
              ghb(40),
              sbRow([
                sbClm(
                    controller.moneyScales
                        .map((e) => moneyScaleView(e))
                        .toList(),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    height: 42.0 * controller.moneyScales.length),
                ...getHistogramButtonList(),
              ], width: 310, crossAxisAlignment: CrossAxisAlignment.end)
            ],
          );
        },
      ),
    );
  }

  List<Widget> getHistogramButtonList() {
    List<Widget> mButtons = [];

    for (var i = 0; i < controller.moneyHistory.length; i++) {
      mButtons.add(histogramButton(i));
    }
    return mButtons;
  }
  // TweenAnimationBuilder<double>(
  //             tween: Tween(begin: 0.0, end: 8.4 * data["num"]),
  //             curve: Curves.fastOutSlowIn,
  //             duration: const Duration(milliseconds: 400),
  //             builder: (context, value, child) {
  //               return Container(
  //                 width: 20.w,
  //                 height: value,
  //                 decoration: const BoxDecoration(
  //                     color: Color(0xFFFB4746),
  //                     borderRadius: BorderRadius.only(
  //                         topLeft: Radius.circular(4),
  //                         topRight: Radius.circular(4))),
  //               );
  //             },
  //           ),

  // 柱状图 柱状按钮
  Widget histogramButton(int idx) {
    double maxHeight = 180;
    double heightScale = maxHeight / controller.maxHistogramCount;
    Map data = controller.moneyHistory[idx];
    return Tooltip(
      message: "${data["num"]}万",
      textStyle: TextStyle(color: AppColor.textBlack, fontSize: 12.sp),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(-1, 1),
              blurRadius: 45.0,
              spreadRadius: 0.0,
            )
          ]),
      triggerMode: TooltipTriggerMode.tap,
      verticalOffset: -(8.4 * data["num"] + 20).w,
      child: TweenAnimationBuilder<double>(
          tween: Tween(
              begin: 0.0,
              end: (heightScale * data["num"]).w == 0
                  ? 3.w
                  : (heightScale * data["num"]).w),
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 400),
          builder: (context, valueAnimationHeight, child) {
            return CustomButton(
              onPressed: null,
              child: Column(
                children: [
                  Container(
                    width: 20.w,
                    height: valueAnimationHeight,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFB4746),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4.w),
                            topRight: Radius.circular(4.w))),
                  ),
                  ghb(12),
                  // getSimpleText(
                  //     data["date"],
                  //     10,
                  //     idx == controller.moneyHistogramButtonIdx
                  //         ? const Color(0xFFFB4746)
                  //         : const Color(0xFFB3B3B3)),
                  getSimpleText(data["date"], 10, const Color(0xFFB3B3B3)),
                ],
              ),
            );
          }),
    );
  }

  Widget moneyScaleView(dynamic t) {
    return SizedBox(
      height: 42.w,
      child: Align(
        alignment: Alignment.topLeft,
        child: getSimpleText("$t", 15, const Color(0xFFB3B3B3)),
      ),
    );
  }

  //柱状图 7日/半年切换按钮
  Widget histogramChangeButton(int idx) {
    return CustomButton(
      onPressed: () {
        controller.moneyHistogramIdx = idx;
      },
      child: GetX<MyBusinessInfoController>(
        init: controller,
        initState: (_) {},
        builder: (_) {
          return Container(
            width: 40.w,
            height: 20.w,
            decoration: BoxDecoration(
                borderRadius: idx == 0
                    ? BorderRadius.only(
                        topLeft: Radius.circular(4.w),
                        bottomLeft: Radius.circular(4.w))
                    : BorderRadius.only(
                        topRight: Radius.circular(4.w),
                        bottomRight: Radius.circular(4.w)),
                color: controller.moneyHistogramIdx == idx
                    ? const Color(0xFFFB4746)
                    : const Color(0xFFF5F5F5)),
            child: Center(
                child: getSimpleText(
                    idx == 0 ? "7日" : "半年",
                    12,
                    controller.moneyHistogramIdx == idx
                        ? Colors.white
                        : AppColor.textBlack)),
          );
        },
      ),
    );
  }

  void showRateInfo(BuildContext context) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 200),
        barrierColor: Colors.black.withOpacity(.5),
        pageBuilder: (BuildContext dialogCtx, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return Align(
            child: SizedBox(
              width: 289.w,
              height: (300 + 54).w,
              // color: Colors.white,
              child: Stack(
                children: [
                  Positioned(
                      right: 16.5.w,
                      top: 0,
                      width: 37.w,
                      height: 37.w,
                      child: CustomButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                        },
                        child: Icon(
                          Icons.highlight_off,
                          size: 37.w,
                          color: Colors.white,
                        ),
                      )),
                  Positioned(
                      right: 33.75.w,
                      top: 34.w,
                      child: Container(
                        width: 1.5.w,
                        height: 20.w,
                        color: Colors.white,
                      )),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 30.w,
                    height: 98.w,
                    child: assetsSizeImage(
                        "home/mybusiness/bg_fl_dialog", 315.5, 98),
                  ),
                  Positioned(
                      top: 114.w,
                      left: 10.w,
                      right: 14.w,
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5))),
                        child: Column(
                          children: [
                            ghb(10),
                            ...(controller.businessData["rateData"] as List)
                                .map((e) => rateText(e))
                                .toList()
                          ],
                        ),
                      ))
                ],
              ),
            ),
          );
        });
  }

  Widget rateText(Map data) {
    return Material(
      child: Padding(
        padding: EdgeInsets.only(top: 18.w),
        child: sbRow([
          Text.rich(TextSpan(
              text: "${data["tRateName"]}：",
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: AppDefault.fontBold,
                  color: AppColor.textBlack),
              children: [
                TextSpan(
                    text: "${data["tUserRate"]}",
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: AppDefault.fontBold,
                        color: const Color(0xFFA20606))),
              ])),
          data["top"] != null
              ? Text.rich(TextSpan(
                  text: "封顶：",
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: AppDefault.fontBold,
                      color: AppColor.textBlack),
                  children: [
                      TextSpan(
                          text: "${data["top"]}",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: AppDefault.fontBold,
                              color: const Color(0xFFA20606))),
                    ]))
              : const SizedBox(),
        ], width: 210),
      ),
    );
  }
}
