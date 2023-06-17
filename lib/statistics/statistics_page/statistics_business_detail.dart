import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/statistics_page/statistics_business_changeinfo.dart';
import 'package:cxhighversion2/statistics/statistics_page/statistics_business_dealdata.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatisticsBusinessDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsBusinessDetailController>(
        StatisticsBusinessDetailController(datas: Get.arguments));
  }
}

class StatisticsBusinessDetailController extends GetxController {
  final dynamic datas;
  StatisticsBusinessDetailController({this.datas});

  loadData() {
    simpleRequest(
        url: Urls.userMerchantEditShow(businessData["merchantId"]),
        params: {},
        success: (success, json) {
          if (success) {
            Map data = json["data"] ?? {};
            businessData["merchantName"] = data["merchants_Name"] ?? "";
            businessData["merchantPhone"] = data["merchants_Phone"] ?? "";
            update();
          }
        },
        after: () {});
  }

  Map businessData = {};

  List businessMachines = [{}, {}];

  @override
  void onReady() {
    loadData();
    super.onReady();
  }

  @override
  void onInit() {
    businessData = (datas ?? {})["data"] ?? {};
    super.onInit();
  }
}

class StatisticsBusinessDetail
    extends GetView<StatisticsBusinessDetailController> {
  /// 统计-商户详情
  ///
  /// 参数
  ///
  /// data 必传 商户列表数据
  const StatisticsBusinessDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "商户详情", action: [
          CustomButton(
            onPressed: () {
              push(const StatisticsBusinessChangeInfo(), context,
                  binding: StatisticsBusinessChangeInfoBinding(),
                  arguments: {"data": controller.businessData});
            },
            child: SizedBox(
              width: 80.w,
              height: kToolbarHeight,
              child: Center(
                child: centRow([
                  Image.asset(
                    assetsName(
                        "statistics_page/business/btn_businessinfo_edit"),
                    width: 18.w,
                    height: 18.w,
                    fit: BoxFit.fill,
                  ),
                  gwb(7),
                  getSimpleText("修改", 15, AppColor.textBlack),
                ]),
              ),
            ),
          )
        ]),
        body: Stack(
          children: [
            // Positioned(
            //     bottom: 0,
            //     left: 0,
            //     right: 0,
            //     height: 65.w + paddingSizeBottom(context),
            //     child: Align(
            //       alignment: Alignment.topCenter,
            //       child: CustomButton(
            //         onPressed: () {},
            //         child: Container(
            //           width: 345.w,
            //           height: 45.w,
            //           alignment: Alignment.center,
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(45.w / 2),
            //               gradient: const LinearGradient(
            //                   colors: [
            //                     Color(0xFFFD573B),
            //                     Color(0xFFFF3A3A),
            //                   ],
            //                   begin: Alignment.topCenter,
            //                   end: Alignment.bottomCenter)),
            //           child: getSimpleText("升级为服务商", 15, Colors.white),
            //         ),
            //       ),
            //     )),
            Positioned.fill(
              child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: GetBuilder<StatisticsBusinessDetailController>(
                      builder: (_) {
                    return Column(children: [
                      Container(
                          width: 375.w,
                          color: Colors.white,
                          child: Column(children: [
                            Container(
                                margin: EdgeInsets.only(top: 13.w),
                                width: 345.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.w),
                                  border: Border.all(
                                      width: 0.5.w, color: AppColor.lineColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x1A040000),
                                      offset: Offset(0, 2.w),
                                      blurRadius: 4.w,
                                    )
                                  ],
                                ),
                                child: Column(children: [
                                  ghb(21),
                                  sbRow([
                                    centRow([
                                      Container(
                                          width: 55.w,
                                          height: 55.w,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      55.w / 2),
                                              color: AppColor.theme
                                                  .withOpacity(0.1)),
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                              assetsName(
                                                  "statistics_page/business/icon_business_default_head"),
                                              width: 30.w,
                                              fit: BoxFit.fitWidth)),
                                      gwb(10),
                                      centClm([
                                        getSimpleText(
                                            controller.businessData[
                                                    "merchantName"] ??
                                                "",
                                            18,
                                            AppColor.textBlack,
                                            isBold: true),
                                        ghb(10),
                                        getSimpleText(
                                            hidePhoneNum(
                                                controller.businessData[
                                                        "merchantPhone"] ??
                                                    ""),
                                            14,
                                            AppColor.textGrey5)
                                      ],
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start)
                                    ]),
                                    centRow(List.generate(
                                        2,
                                        (index) => CustomButton(
                                              onPressed: () {
                                                String phone =
                                                    controller.businessData[
                                                            "merchantPhone"] ??
                                                        "";
                                                if (phone.isEmpty) {
                                                  ShowToast.normal(
                                                      "该商户没有配置电话号码");
                                                  return;
                                                }
                                                if (index == 0) {
                                                  callSMS(phone, "");
                                                } else {
                                                  showAlert(
                                                    Global.navigatorKey
                                                        .currentContext!,
                                                    "您即将拨打电话 $phone",
                                                    confirmOnPressed: () {
                                                      Get.back();
                                                      callPhone(phone);
                                                    },
                                                  );
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: index == 1
                                                        ? 12.5.w
                                                        : 0),
                                                child: centClm([
                                                  Image.asset(
                                                      assetsName(
                                                          "statistics_page/btn_${index == 0 ? "sms" : "call_phone"}"),
                                                      width: 45.w,
                                                      fit: BoxFit.fitWidth),
                                                  ghb(1),
                                                  getSimpleText(
                                                      index == 0
                                                          ? "发短信"
                                                          : "打电话",
                                                      10,
                                                      AppColor.textBlack)
                                                ]),
                                              ),
                                            )))
                                  ], width: 315),
                                  ghb(15),
                                  ...List.generate(4, (index) {
                                    return sbhRow([
                                      centRow([
                                        getWidthText(
                                            index == 0
                                                ? "备注姓名"
                                                : index == 1
                                                    ? "手机号"
                                                    : index == 2
                                                        ? "商户状态"
                                                        : "注册时间",
                                            14,
                                            AppColor.textBlack.withOpacity(0.5),
                                            75,
                                            1,
                                            textHeight: 1.3),
                                        getSimpleText(
                                            index == 0
                                                ? controller.businessData[
                                                        "merchantName"] ??
                                                    ""
                                                : index == 1
                                                    ? hidePhoneNum(controller
                                                                .businessData[
                                                            "merchantPhone"] ??
                                                        "")
                                                    : index == 2
                                                        ? "${(controller.businessData["isActivity"] ?? 0) > 0 ? "已达标" : "未达标"}${(controller.businessData["isActivation"] ?? 0) > 0 || (controller.businessData["isAssessment"] ?? 0) > 0 ? "已激活" : "未激活"}"
                                                        : controller.businessData[
                                                                "merchantInTime"] ??
                                                            "",
                                            14,
                                            AppColor.textBlack)
                                      ])
                                    ], width: 315, height: 25);
                                  }),
                                  ghb(15)
                                ])),
                            sbhRow([
                              centRow([
                                getSimpleText(
                                    "累计交易总额(元)", 12, AppColor.textBlack),
                                gwb(15),
                                getSimpleText(
                                    priceFormat(controller
                                            .businessData["totalTxnAmt"] ??
                                        0),
                                    24,
                                    const Color(0xFFFE4B3B),
                                    isBold: true)
                              ])
                            ], width: 375 - 20 * 2, height: 70),
                            ghb(5),
                            sbRow(
                                List.generate(
                                    2,
                                    (index) => centRow([
                                          Container(
                                              width: 40.w,
                                              height: 40.w,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.w),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: const Color(
                                                            0x1A040000),
                                                        offset: Offset(0, 2.w),
                                                        blurRadius: 4.w)
                                                  ]),
                                              child: Image.asset(
                                                  assetsName(
                                                      "statistics_page/business/icon_${index == 0 ? "this" : "last"}m"),
                                                  width: 24.w,
                                                  fit: BoxFit.fitWidth)),
                                          gwb(9),
                                          centClm([
                                            getSimpleText(
                                                priceFormat(controller
                                                            .businessData[
                                                        index == 0
                                                            ? "thisMTxnAmt"
                                                            : "lastMTxnAmt"] ??
                                                    0),
                                                18,
                                                AppColor.textBlack,
                                                isBold: true),
                                            ghb(3),
                                            getSimpleText(
                                                index == 0
                                                    ? "本月交易额(元)"
                                                    : "上月交易额(元)",
                                                12,
                                                AppColor.textGrey5)
                                          ],
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start)
                                        ])),
                                width: 375 - 20 * 2),
                            ghb(15),
                            CustomButton(
                              onPressed: () {
                                push(const StatisticsBusinessDealData(), null,
                                    binding:
                                        StatisticsBusinessDealDataBinding(),
                                    arguments: {
                                      "data": controller.businessData
                                    });
                              },
                              child: SizedBox(
                                width: 375.w,
                                height: 45.w,
                                child: centRow([
                                  getSimpleText(
                                      "查看交易明细", 12, AppColor.textGrey5),
                                  gwb(2),
                                  Image.asset(
                                      assetsName(
                                          "statistics_page/business/arror_right_gray"),
                                      width: 12.w,
                                      fit: BoxFit.fitWidth)
                                ]),
                              ),
                            )
                          ])),
                      businessMachineView()
                    ]);
                  })),
            ),
          ],
        ));
  }

  Widget businessMachineView() {
    return Column(children: [
      ghb(4),
      sbRow([
        centRow([
          ghb(49),
          Container(
            width: 3.w,
            height: 15.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.5.w),
                color: AppColor.theme),
          ),
          gwb(9),
          getSimpleText("终端设备", 15, AppColor.textBlack, isBold: true)
        ]),
      ], width: 345),
      machineCell(0, controller.businessData),
      ghb(20)
    ]);
  }

  Widget machineCell(int index, Map data) {
    String cellBuildId = "machineCell__cellBuildId";
    return GetBuilder<StatisticsBusinessDetailController>(
        id: cellBuildId,
        builder: (_) {
          bool open = false;
          if (data["open"] == null) {
            data["open"] = (index == 0);
          }
          open = data["open"];

          String statusStr = (data["isActivity"] ?? -1) <= 0 ? "未达标" : "已达标";
          return AnimatedContainer(
              margin: EdgeInsets.only(top: index == 0 ? 0 : 15.w),
              width: 345.w,
              duration: const Duration(milliseconds: 200),
              decoration: getDefaultWhiteDec(radius: 4.w),
              curve: Curves.easeInOut,
              child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(children: [
                    CustomButton(
                        onPressed: () {
                          data["open"] = !data["open"];
                          controller.update([cellBuildId]);
                        },
                        child: sbhRow([
                          centRow([
                            Image.asset(
                                assetsName("product_store/default_machine"),
                                width: 45.w,
                                fit: BoxFit.fitWidth),
                            gwb(10),
                            centClm([
                              getSimpleText(data["terminalName"] ?? "", 15,
                                  AppColor.textBlack,
                                  isBold: true),
                              ghb(5),
                              getSimpleText("设备编号：${data["tNo"] ?? ""}", 12,
                                  AppColor.textGrey5)
                            ], crossAxisAlignment: CrossAxisAlignment.start)
                          ]),
                          AnimatedRotation(
                            turns: open ? 0.5 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: Image.asset(
                                assetsName("statistics_page/icon_cell_open"),
                                width: 18.w,
                                fit: BoxFit.fitWidth),
                          )
                        ],
                            width: 315,
                            height: 75,
                            crossAxisAlignment: CrossAxisAlignment.end)),
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 315.w,
                        height: open ? 135.w : 0,
                        margin: EdgeInsets.only(bottom: open ? 15.w : 0),
                        alignment: Alignment.center,
                        // padding: EdgeInsets.symmetric(vertical: 8.w),
                        decoration: BoxDecoration(
                            color: AppColor.pageBackgroundColor,
                            borderRadius: BorderRadius.circular(8.w)),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                              children: List.generate(
                                  5,
                                  (index) => sbhRow([
                                        getSimpleText(
                                            index == 0
                                                ? "所属商户"
                                                : index == 1
                                                    ? "设备状态"
                                                    : index == 2
                                                        ? "绑定时间"
                                                        : index == 3
                                                            ? "激活时间"
                                                            : "返现时间",
                                            12,
                                            AppColor.textGrey5),
                                        getSimpleText(
                                            index == 0
                                                ? data["merchantName"] ?? ""
                                                : index == 1
                                                    ? statusStr
                                                    : index == 2
                                                        ? data["bindTime"] ?? ""
                                                        : index == 3
                                                            ? data["activationTime"] ??
                                                                ""
                                                            : data["activityTime"] ??
                                                                "",
                                            12,
                                            AppColor.textBlack)
                                      ], width: 285, height: 23))),
                        ))
                  ])));
        });
  }
}
