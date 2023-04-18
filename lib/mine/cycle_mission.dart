import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/machine/machine_pay_page.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineManage/statistics_machine_replenishment.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CycleMissionBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<CycleMissionController>(
        CycleMissionController(datas: Get.arguments));
  }
}

class CycleMissionController extends GetxController {
  final dynamic datas;
  CycleMissionController({this.datas});

  final _haveNotify = true.obs;
  bool get haveNotify => _haveNotify.value;
  set haveNotify(v) => _haveNotify.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  Map freightData = {};
  List levelUpList = [];
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
  DateFormat dateFormat2 = DateFormat("yyyy-MM-dd");
  DateFormat dateFormat3 = DateFormat("yyyy年MM月dd日");

  double scale = 0.0;

  loadData() {
    simpleRequest(
      url: Urls.userTerminalFreightShow,
      params: {},
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          freightData = data["freight"] ?? {};
          levelUpList = data["userLevelLogs"] ?? [];
          String startTime = freightData["replenishStaTime"] ?? "";
          String endTime = freightData["replenishEndTime"] ?? "";
          if (startTime.isNotEmpty && endTime.isNotEmpty) {
            DateTime startDate = dateFormat.parse(startTime);
            DateTime endDate = dateFormat.parse(endTime);
            // DateTime startDate = dateFormat.parse("2023/03/01 12:23:43");
            // DateTime endDate = dateFormat.parse("2023/03/17 12:23:43");
            DateTime now = DateTime.now();
            if (endDate.isAfter(startDate) && now.isBefore(endDate)) {
              int diff1 = endDate.difference(startDate).inMilliseconds;
              int diff2 = endDate.difference(now).inMilliseconds;
              scale = diff2 / diff1;
            } else {
              scale = 1.0;
            }
          }
          update();
        }
      },
      after: () {
        isFirstLoading = false;
      },
    );
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }
}

class CycleMission extends GetView<CycleMissionController> {
  const CycleMission({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "周期续约奖励"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: GetBuilder<CycleMissionController>(builder: (_) {
          return Column(children: [
            GetX<CycleMissionController>(
              builder: (_) {
                return !controller.haveNotify
                    ? ghb(0)
                    : Container(
                        width: 375.w,
                        height: 28.w,
                        alignment: Alignment.center,
                        decoration:
                            const BoxDecoration(color: Color(0xFFFBFAE6)),
                        child: sbhRow([
                          Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: Image.asset(
                              assetsName("mine/icon_notify_orange"),
                              width: 16.w,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5.w),
                            child: getWidthText(
                                "续货有效期：${controller.freightData["replenishStaTime"] ?? ""}至${controller.freightData["replenishEndTime"] ?? ""}",
                                10,
                                const Color(0xFFFF881E),
                                375 - 36 - 40 - 5,
                                1,
                                textHeight: 1.25),
                          ),
                          CustomButton(
                            onPressed: () {
                              controller.haveNotify = false;
                            },
                            child: SizedBox(
                              height: 28.w,
                              width: 40.w,
                              child: Center(
                                child: Image.asset(
                                  assetsName("mine/icon_close_orange"),
                                  width: 12.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          )
                        ], width: 375),
                      );
              },
            ),
            Container(
              width: 375.w,
              height: 255.w,
              color: AppColor.theme,
              child: Stack(children: [
                Positioned.fill(
                    child: Column(
                  children: [
                    ghb(54),
                    centRow(List.generate(3, (index) {
                      return index == 1
                          ? gwb(40)
                          : centClm([
                              getSimpleText(
                                  index == 0 ? "本周期应续(台)" : "本周期实续(台)",
                                  14,
                                  Colors.white),
                              ghb(10),
                              getSimpleText(
                                  "${index == 0 ? controller.freightData["plan_Num"] ?? 0 : controller.freightData["actual_Num"] ?? 0}",
                                  30,
                                  Colors.white,
                                  isBold: true),
                            ], crossAxisAlignment: CrossAxisAlignment.start);
                    })),
                    ghb(35),
                    centRow(List.generate(3, (index) {
                      return index == 1
                          ? Container(
                              width: 345.w - 12.w * 2,
                              height: 3.w,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3)),
                              child: Stack(
                                children: [
                                  Positioned(
                                      top: 0,
                                      bottom: 0,
                                      left: 0,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        height: 3.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.horizontal(
                                                    right: Radius.circular(
                                                        1.5.w))),
                                        width: (345.w - 12.w * 2) *
                                            controller.scale,
                                      ))
                                ],
                              ),
                            )
                          : Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6.w)),
                            );
                    })),
                    ghb(8),
                    sbRow([
                      getSimpleText(
                          controller.freightData["replenishStaTime"] != null
                              ? controller.dateFormat2.format(
                                  controller.dateFormat.parse(controller
                                          .freightData["replenishStaTime"] ??
                                      ""))
                              : "",
                          10,
                          Colors.white.withOpacity(0.5)),
                      getSimpleText(
                          controller.freightData["replenishEndTime"] != null
                              ? controller.dateFormat2.format(
                                  controller.dateFormat.parse(controller
                                          .freightData["replenishEndTime"] ??
                                      ""))
                              : "",
                          10,
                          Colors.white.withOpacity(0.5)),
                    ], width: 345),
                  ],
                )),
                Positioned(
                    left: 15.w,
                    right: 15.w,
                    bottom: 0,
                    height: 60.w,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(8.w))),
                      child: sbRow([
                        Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: getSimpleText(
                              (AppDefault().homeData["isFinsh"] ?? false)
                                  ? "本周期已完成续货任务,可获得续约奖励"
                                  : "本周期续货还差：${(controller.freightData["plan_Num"] ?? 0)}台",
                              15,
                              AppColor.text,
                              isBold: true),
                        ),
                        !(AppDefault().homeData["isFinsh"] ?? false)
                            ? CustomButton(
                                onPressed: () {
                                  push(const MachinePayPage(), context,
                                      binding: MachinePayPageBinding(),
                                      arguments: {"isXh": true});
                                },
                                child: Container(
                                  width: 75.w,
                                  height: 30.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.w),
                                      border: Border.all(
                                          width: 0.5, color: AppColor.theme)),
                                  child:
                                      getSimpleText("去完成", 14, AppColor.theme),
                                ),
                              )
                            : gwb(0),
                      ], width: 315),
                    )),
              ]),
            ),
            Container(
              width: 345.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadiusDirectional.vertical(
                    bottom: Radius.circular(8.w),
                  )),
              child: Column(
                children: [
                  cellTitle("周期续约奖励"),
                  ghb(15),
                  getWidthText("    ${controller.freightData["desc"] ?? ""}",
                      14, AppColor.text2, 315, 1000),
                  getWidthText(
                      "注：此奖励周期续约成功与否都不影响相应的分润结算。", 14, AppColor.red, 315, 1000),
                  ghb(20),
                  cellTitle("等级成长"),
                  ghb(15),
                  ...List.generate(
                    controller.levelUpList.length,
                    (index) {
                      Map e = controller.levelUpList[index];
                      return getWidthText(
                          "${controller.dateFormat3.format(controller.dateFormat.parse(e["addTime"] ?? ""))}成为${e["ulL_UpLevelName"] ?? ""}",
                          14,
                          AppColor.text2,
                          315,
                          2);
                    },
                  ),
                  ghb(22),
                ],
              ),
            ),
            ghb(31),
            getSubmitBtn(
              "查看补货记录",
              () {
                push(const StatisticsMachineReplenishment(), context,
                    binding: StatisticsMachineReplenishmentBinding());
              },
              height: 45,
              color: AppColor.theme,
              fontSize: 15,
            ),
            ghb(20),
            SizedBox(
              height: paddingSizeBottom(context),
            )
          ]);
        }),
      ),
    );
  }

  Widget cellTitle(String title) {
    return sbRow([
      centRow([
        Container(
          width: 3.w,
          height: 15.w,
          decoration: BoxDecoration(
              color: AppColor.theme,
              borderRadius: BorderRadius.circular(1.5.w)),
        ),
        gwb(10),
        getSimpleText(title, 15, AppColor.text, isBold: true),
      ])
    ], width: 345 - 15 * 2);
  }
}
