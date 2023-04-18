import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatisticsMachineTransferHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineTransferHistoryController>(
        StatisticsMachineTransferHistoryController(datas: Get.arguments));
  }
}

class StatisticsMachineTransferHistoryController extends GetxController {
  final dynamic datas;
  StatisticsMachineTransferHistoryController({this.datas});

  RefreshController pullCtrl = RefreshController();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  Map machineData = {};

  Map myData = {
    "name": "李志明",
    "orderType": "订货单",
    "no": "TK201545612313",
    "addTime": "2022-08-20 15:41:13",
  };
  List transferList = [];

  int pageSize = 10;
  int pageNo = 1;
  int count = 0;

  loadTransferList({bool isLoad = false}) {
    simpleRequest(
      url: Urls.terminalTransferOrder,
      params: {
        "tcId": machineData["tId"],
      },
      success: (success, json) {
        if (success) {
          transferList = [
            {},
            {},
            {},
            {},
          ];
          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
        } else {
          transferList = [
            {},
            {},
            {},
            {},
          ];
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {},
    );
  }

  @override
  void onInit() {
    machineData = datas["machineData"] ?? {};
    loadTransferList();
    super.onInit();
  }

  @override
  void onClose() {
    pullCtrl.dispose();
    super.onClose();
  }
}

class StatisticsMachineTransferHistory
    extends GetView<StatisticsMachineTransferHistoryController> {
  const StatisticsMachineTransferHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "设备详情"),
      body: GetBuilder<StatisticsMachineTransferHistoryController>(
        builder: (_) {
          return SmartRefresher(
            controller: controller.pullCtrl,
            onLoading: () => controller.loadTransferList(isLoad: true),
            onRefresh: () => controller.loadTransferList(),
            enablePullUp: controller.count > controller.transferList.length,
            child: ListView.builder(
              itemCount: controller.transferList.isEmpty
                  ? 2
                  : controller.transferList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return centClm([
                    gwb(375),
                    ghb(15),
                    machineInfoView(),
                  ]);
                } else {
                  return controller.transferList.isEmpty
                      ? GetX<StatisticsMachineTransferHistoryController>(
                          builder: (_) {
                            return CustomEmptyView(
                              isLoading: controller.isLoading,
                            );
                          },
                        )
                      : historyCell(index - 1, controller.myData);
                }
              },
            ),
          );

          // SingleChildScrollView(
          //     physics: const BouncingScrollPhysics(),
          //     child: Column(
          //       children: [ghb(15), transferHistoryView(), ghb(20)],
          //     ));
        },
      ),
    );
  }

  Widget machineInfoView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
      child: Column(
        children: [
          cellTitle("设备信息"),
          ghb(5),
          sbRow([
            centClm([
              getSimpleText(
                  controller.machineData["tbName"] ?? "", 15, AppColor.text2,
                  isBold: true),
              ghb(9),
              getSimpleText("设备编号：${controller.machineData["tNo"] ?? ""}", 12,
                  AppColor.text3),
              ghb(9),
              getSimpleText("设备状态：${controller.machineData["tStatus"] ?? ""}",
                  12, AppColor.text3)
            ], crossAxisAlignment: CrossAxisAlignment.start),
            CustomNetworkImage(
              src: AppDefault().imageUrl +
                  (controller.machineData["tImg"] ?? ""),
              width: 45.w,
              height: 45.w,
              fit: BoxFit.fill,
            )
          ], crossAxisAlignment: CrossAxisAlignment.start, width: 345 - 15 * 2),
          ghb(12),
          (controller.machineData["isBinding"] ?? 0) != 0
              ? centClm([
                  gline(315, 0.5),
                  ghb(7),
                  ...List.generate(3, (index) {
                    String title = "";
                    String t2 = "";
                    switch (index) {
                      case 0:
                        title = "绑定时间";
                        t2 = controller.machineData["bindingTime"] ?? "";
                        break;
                      case 1:
                        title = "激活时间";
                        t2 = controller.machineData["activaTime"] ?? "";
                        break;
                      case 2:
                        {
                          String valid = "";
                          final dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
                          if (controller.machineData["bindingTime"] != null &&
                              controller
                                  .machineData["bindingTime"].isNotEmpty &&
                              controller.machineData["activaDay"] != null &&
                              controller.machineData["activaDay"] is int) {
                            DateTime vDate = dateFormat
                                .parse(controller.machineData["bindingTime"])
                                .add(Duration(
                                    days: controller.machineData["activaDay"]));
                            valid = dateFormat.format(vDate);
                          }
                          title = "有效激活时间";
                          t2 = valid;
                        }
                        break;
                    }
                    return sbhRow([
                      getSimpleText(title, 12, AppColor.text3),
                      getSimpleText(t2, 12, AppColor.text2)
                    ], width: 345 - 15 * 2, height: 24);
                  }),
                  ghb(7),
                ])
              : ghb(0),
        ],
      ),
    );
  }

  Widget transferHistoryView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
      child: Column(
        children: [
          cellTitle("划拨记录"),
          ...List.generate(5, (index) => historyCell(index, controller.myData)),
          ghb(20)
        ],
      ),
    );
  }

  Widget historyCell(int index, Map data) {
    return Align(
      child: Container(
        width: 345.w,
        margin: EdgeInsets.only(top: index == 0 ? 15.w : 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
        child: Column(
          children: [
            index == 0 ? cellTitle("划拨记录") : ghb(0),
            sbhRow([
              centRow([
                centClm([
                  ghb(5.5),
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                        color: index == 0 ? AppColor.theme : AppColor.assisText,
                        borderRadius: BorderRadius.circular(3.5.w)),
                  ),
                  ghb(7),
                  Container(
                    width: 1.w,
                    height: 60.w,
                    color: AppColor.lineColor,
                  )
                ]),
                gwb(15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        getSimpleText(data["name"] ?? "", 15, AppColor.text2,
                            isBold: true),
                        gwb(10),
                        getSimpleText(data["orderType"] ?? "", 12,
                            const Color(0xFFF93635)),
                        gwb(index == 0 ? 10 : 0),
                        index == 0
                            ? Container(
                                height: 18.w,
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                decoration: BoxDecoration(
                                    color: AppColor.theme.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(9.w)),
                                child: Center(
                                    child: getSimpleText(
                                        "当前所属商户", 10, AppColor.theme)),
                              )
                            : gwb(0)
                      ],
                    ),
                    ghb(6),
                    Row(
                      children: [
                        getWidthText("订单号", 12, AppColor.text3, 54, 1),
                        getSimpleText(data["no"] ?? "", 12, AppColor.text2)
                      ],
                    ),
                    ghb(6),
                    Row(
                      children: [
                        getWidthText("创建时间", 12, AppColor.text3, 54, 1),
                        getSimpleText(data["addTime"] ?? "", 12, AppColor.text2)
                      ],
                    ),
                  ],
                ),
              ])
            ],
                crossAxisAlignment: CrossAxisAlignment.start,
                height: 79.5,
                width: 345 - 25 * 2),
            ghb(index == controller.transferList.length - 1 ? 20 : 0),
          ],
        ),
      ),
    );
  }

  Widget cellTitle(String title) {
    return sbhRow([
      centRow([
        Container(
          width: 3.w,
          height: 15.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.25.w),
              color: AppColor.theme),
        ),
        gwb(8),
        getSimpleText(title, 15, AppColor.text, isBold: true)
      ])
    ], width: 345 - 15 * 2, height: 45);
  }
}
