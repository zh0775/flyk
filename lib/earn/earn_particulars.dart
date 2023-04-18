import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EarnParticularsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<EarnParticularsController>(EarnParticularsController());
  }
}

class EarnParticularsController extends GetxController {
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  Map earnData = {};
  loadData() {
    simpleRequest(
      url: Urls.userFinanceSourceShow(firstData["id"], source),
      params: {},
      success: (success, json) {
        if (success) {
          earnData = json["data"] != null && json["data"].isNotEmpty
              ? json["data"][0]
              : {};
          update();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  String img = "";

  double cellSpace = 16;
  bool isFirst = true;
  String source = "";
  Map firstData = {};
  dataInit(Map data) {
    if (!isFirst) return;
    isFirst = false;
    firstData = data;
    source = firstData["source"] ?? "";
    img = data["account"] != null
        ? AppDefault().getAccountImg(data["account"])
        : "";

    loadData();
  }
}

class EarnParticulars extends GetView<EarnParticularsController> {
  final Map earnData;
  final String title;
  const EarnParticulars(
      {Key? key, this.earnData = const {}, this.title = "明细详情"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(earnData);
    return Scaffold(
      appBar: getDefaultAppBar(context, title),
      body: GetBuilder<EarnParticularsController>(
        initState: (_) {},
        builder: (_) {
          return controller.earnData.isEmpty
              ? GetX<EarnParticularsController>(
                  builder: (_) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: CustomEmptyView(
                        isLoading: controller.isLoading,
                      ),
                    );
                  },
                )
              : Stack(
                  children: [
                    Positioned.fill(
                        child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.w)),
                        margin: EdgeInsets.only(top: 20.w),
                        width: 345.w,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(
                                height: controller.img.isEmpty ? 107.w : 165.w,
                                child: Column(
                                  children: [
                                    ghb(21),
                                    controller.img.isEmpty
                                        ? ghb(0)
                                        : CustomNetworkImage(
                                            src: AppDefault().imageUrl +
                                                controller.img,
                                            width: 58.w,
                                            height: 58.w,
                                            fit: BoxFit.fill,
                                          ),
                                    ghb(12),
                                    getSimpleText(
                                        "${controller.earnData["title_CN"] ?? ""}${controller.earnData["f_Description"] ?? ""}",
                                        12,
                                        AppColor.text2),
                                    ghb(12),
                                    getSimpleText(
                                        "${(controller.earnData["bType"] ?? 0) == 0 ? "-" : "+"}${priceFormat(controller.earnData["amount"] ?? 0)}",
                                        24,
                                        AppColor.text,
                                        isBold: true),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 375.w,
                                height: 15.w,
                                child: Stack(children: [
                                  Positioned(
                                      top: 0,
                                      left: -7.5.w,
                                      width: 15.w,
                                      height: 15.w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: AppColor.pageBackgroundColor,
                                            borderRadius: BorderRadius.circular(
                                                15.w / 2)),
                                      )),
                                  Align(
                                    alignment: Alignment.center,
                                    child: getCustomDashLine(
                                      315,
                                      0.5,
                                      v: false,
                                      dashSingleGap: 3,
                                      strokeWidth: 0.5,
                                      color: AppColor.lineColor,
                                    ),
                                  ),
                                  Positioned(
                                      top: 0,
                                      right: -15.w / 2,
                                      width: 15.w,
                                      height: 15.w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: AppColor.pageBackgroundColor,
                                            borderRadius: BorderRadius.circular(
                                                15.w / 2)),
                                      ))
                                ]),
                              ),
                              ghb(20 - 7.5),
                              ...contentInfo(),
                              ghb(20)
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                );
        },
      ),
    );
  }

  Widget cellInfo(String t1, String t2) {
    return sbhRow([
      Row(
        children: [
          getWidthText(t1, 12, AppColor.text3, 75, 1,
              textAlign: TextAlign.right),
          getWidthText(t2, 12, AppColor.text2, 315 - 75, 100),
        ],
      ),
    ], width: 345 - 15 * 2, height: 30);
  }

  List<Widget> contentInfo() {
    List<Widget> widgets = [];
    String sources = controller.source;
    if (sources.isNotEmpty) {
      List sourcesList = sources.split(',');
      for (var e in sourcesList) {
        int r = int.parse(e);

        switch (r) {
          case 1000:
            widgets.add(cellInfo("影响人", controller.earnData["t_Number"] ?? ""));
            break;
          case 1002:
            widgets.add(cellInfo("机具号", controller.earnData["devNo"] ?? ""));
            widgets.add(
                cellInfo("机型", controller.earnData["terninal_Name"] ?? ""));
            widgets.add(
                cellInfo("级别模式", controller.earnData["userLevelTitle"] ?? ""));
            widgets
                .add(cellInfo("商户号", controller.earnData["merchantNo"] ?? ""));
            break;
          case 1003:
            widgets.add(
                cellInfo("交易订单号", controller.earnData["tradeOrderNo"] ?? ""));
            widgets.add(cellInfo("交易总额",
                priceFormat(controller.earnData["tradeOrderAmount"] ?? 0)));
            widgets.add(
                cellInfo("交易比例", "${controller.earnData["commission"] ?? ""}"));
            widgets
                .add(cellInfo("交易方式", controller.earnData["tradeType"] ?? ""));
            widgets
                .add(cellInfo("分润级别", controller.earnData["levelName"] ?? ""));
            break;
          case 1004:
            widgets.add(cellInfo("订单号", controller.earnData["order_NO"] ?? ""));
            widgets.add(cellInfo("订单总额",
                priceFormat(controller.earnData["shopOrderTotalPrice"] ?? "")));
            break;
          case 1005:
            widgets.add(cellInfo("订单号", controller.earnData["order_NO"] ?? ""));
            widgets
                .add(cellInfo("订单名称", controller.earnData["shopName"] ?? ""));
            widgets.add(
                cellInfo("订单金额", controller.earnData["total_Price"] ?? ""));
            break;
          case 1006:
            widgets
                .add(cellInfo("提现单号", controller.earnData["period_No"] ?? ""));
            widgets.add(
                cellInfo("提现金额", "${controller.earnData["draw_Money"] ?? ""}"));
            widgets.add(cellInfo(
                "提现方式", controller.earnData["draw_ReleaseName"] ?? ""));
            if (controller.earnData["draw_Remarks"] != null &&
                controller.earnData["draw_Remarks"].isNotEmpty) {
              widgets.add(
                  cellInfo("提现备注", controller.earnData["draw_Remarks"] ?? ""));
            }
            break;
          case 1007:
            widgets
                .add(cellInfo("奖项名", controller.earnData["lotteryName"] ?? ""));
            widgets
                .add(cellInfo("奖品信息", controller.earnData["prizeTitle"] ?? ""));
            widgets.add(
                cellInfo("奖品类型", controller.earnData["prizeTypeStr"] ?? ""));
            break;
          case 1008:
            widgets.add(cellInfo("投资类型", controller.earnData["title"] ?? ""));
            widgets
                .add(cellInfo("投资订单号", controller.earnData["order_NO"] ?? ""));
            widgets.add(
                cellInfo("投资总额", controller.earnData["investAmount"] ?? ""));
            break;
          case 1009:
            widgets.add(cellInfo("签到类型", controller.earnData["flagStr"] ?? ""));
            widgets
                .add(cellInfo("签到时间", controller.earnData["signInTime"] ?? ""));
            break;
          case 1010:
            widgets
                .add(cellInfo("积分类型", controller.earnData["className"] ?? ""));
            widgets
                .add(cellInfo("名称", controller.earnData["integralName"] ?? ""));
            break;
          default:
        }
      }
    }

    widgets.add(cellInfo("财务备注", controller.earnData["f_Description"] ?? ""));
    widgets.add(cellInfo(
        "状态",
        controller.earnData["f_Flag"] != null
            ? (controller.earnData["f_Flag"] == 1 ? "已核算" : "")
            : "未发放"));

    return widgets;
  }
}
