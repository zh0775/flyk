import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineManage/statistics_machine_maintain.dart';
import 'package:cxhighversion2/statistics/machineManage/statistics_machine_manage.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatisticsMachineMaintainDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineMaintainDetailController>(
        StatisticsMachineMaintainDetailController(datas: Get.arguments));
  }
}

class StatisticsMachineMaintainDetailController extends GetxController {
  final dynamic datas;
  StatisticsMachineMaintainDetailController({this.datas});

  Map orderData = {};
  final _machineData = Rx<Map>({});
  Map get machineData => _machineData.value;
  set machineData(v) => _machineData.value = v;
  int status = 0;
  bool toMe = false;

  final _syncOldMachineOpen = false.obs;
  bool get syncOldMachineOpen => _syncOldMachineOpen.value;
  set syncOldMachineOpen(v) => _syncOldMachineOpen.value = v;

  loadData() {}

  backoutAction() {
    simpleRequest(
      url: Urls.featuresOverRefuse(orderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          ShowToast.normal("撤销成功");
          Get.find<StatisticsMachineMaintainController>().loadData();
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {},
    );
  }

  agreeAction() {
    simpleRequest(
      url: Urls.userMaintainePass,
      params: {
        "id": orderData["id"],
        "replace_Type": syncOldMachineOpen ? 1 : 0,
        "newTerminalNo": machineData["tNo"],
      },
      success: (success, json) {
        if (success) {
          ShowToast.normal("已同意该工单");
          Get.find<StatisticsMachineMaintainController>().loadData();
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {},
    );
  }

  rejectAction() {
    simpleRequest(
      url: Urls.featuresWithdraw(orderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          ShowToast.normal("已拒绝该工单");
          Get.find<StatisticsMachineMaintainController>().loadData();
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {},
    );
  }

  setMachine(Map data) {
    machineData = data;
  }

  List imgs = [];

  @override
  void onInit() {
    orderData = datas["data"] ?? {};
    status = orderData["status"] ?? -1;
    toMe = (orderData["orderType"] ?? 1) == 0;
    if (orderData["certificate"] != null &&
        orderData["certificate"].isNotEmpty &&
        orderData["certificate"] is String) {
      imgs = (orderData["certificate"] as String).split(",");
    }
    // machineData = orderData["machine"] ?? {};
    loadData();
    super.onInit();
  }
}

class StatisticsMachineMaintainDetail
    extends GetView<StatisticsMachineMaintainDetailController> {
  const StatisticsMachineMaintainDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "详情"),
      body: Stack(
        children: [
          Positioned.fill(
              bottom:
                  (controller.toMe ? 117.w : 62.w) + paddingSizeBottom(context),
              child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      !controller.toMe ? toMeTopView() : ghb(0),
                      machineInfoView(),
                      controller.toMe ? selectMachineView() : ghb(0)
                    ],
                  ))),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height:
                  (controller.toMe ? 117.w : 62.w) + paddingSizeBottom(context),
              child: Container(
                  padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
                  child: Column(
                    children: [
                      controller.toMe
                          ? getSubmitBtn("同意并确认更换", () {
                              if (controller.machineData.isEmpty) {
                                ShowToast.normal("请选择更换的新设备");
                                return;
                              }
                              showAlert(
                                Global.navigatorKey.currentContext!,
                                "确认要同意该维修单吗？",
                                confirmOnPressed: () {
                                  Get.back();
                                  controller.agreeAction();
                                },
                              );
                            },
                              width: 345,
                              height: 45,
                              color: AppColor.theme,
                              fontSize: 15,
                              textColor: Colors.white)
                          : ghb(0),
                      ghb(controller.toMe ? 10 : 0),
                      getSubmitBtn(controller.toMe ? "拒绝" : "撤销申请", () {
                        if (controller.toMe) {
                          showAlert(
                            Global.navigatorKey.currentContext!,
                            "确认要拒绝该维修单吗？",
                            confirmOnPressed: () {
                              Get.back();
                              controller.rejectAction();
                            },
                          );
                        } else {
                          showAlert(
                            Global.navigatorKey.currentContext!,
                            "确认要撤销该维修单吗？",
                            confirmOnPressed: () {
                              Get.back();
                              controller.backoutAction();
                            },
                          );
                        }
                      },
                          width: 345,
                          height: 45,
                          color: Colors.white,
                          fontSize: 15,
                          textColor: AppColor.red)
                    ],
                  )))
        ],
      ),
    );
  }

  Widget selectMachineView() {
    return SizedBox(
      width: 345.w,
      child: Column(
        children: [
          ghb(6.5),
          sbhRow([
            getSimpleText("选择新设备", 12, AppColor.text3),
          ], width: 345, height: 41.5),
          Container(
            width: 345.w,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
            child: Column(
              children: [
                CustomButton(
                  onPressed: () {
                    push(const StatisticsMachineManage(), null,
                        binding: StatisticsMachineManageBinding(),
                        arguments: {"type": 1, "controller": controller});
                  },
                  child: sbhRow([
                    getSimpleText("选择设备", 14, AppColor.text3),
                    Image.asset(
                      assetsName("statistics/icon_arrow_right_gray"),
                      width: 15.w,
                      fit: BoxFit.fitWidth,
                    )
                  ], width: 345 - 20.5 * 2, height: 59.5),
                ),
                gline(315, 0.5),
                sbRow([
                  GetX<StatisticsMachineMaintainDetailController>(
                    builder: (_) {
                      return controller.machineData.isEmpty
                          ? CustomButton(
                              onPressed: () {
                                push(const StatisticsMachineManage(), null,
                                    binding: StatisticsMachineManageBinding(),
                                    arguments: {
                                      "type": 1,
                                      "controller": controller
                                    });
                              },
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.w),
                              child: centRow([
                                CustomNetworkImage(
                                  src: AppDefault().imageUrl +
                                      (controller.machineData["tImg"] ?? ""),
                                  width: 45.w,
                                  height: 45.w,
                                  fit: BoxFit.fill,
                                ),
                                gwb(15),
                                centClm([
                                  getSimpleText(
                                      controller.machineData["tbName"] ?? "",
                                      15,
                                      AppColor.text,
                                      isBold: true),
                                  ghb(6),
                                  getSimpleText(
                                      "设备编号：${controller.machineData["tNo"] ?? ""}",
                                      12,
                                      AppColor.text3),
                                ], crossAxisAlignment: CrossAxisAlignment.start)
                              ]),
                            );
                    },
                  )
                ], width: 315),
              ],
            ),
          ),
          ghb(15),
          Container(
            width: 345.w,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
            child: Center(
              child: sbhRow([
                getSimpleText("同步旧设备所有数据", 14, AppColor.text3),
                CustomButton(
                  onPressed: () => controller.syncOldMachineOpen =
                      !controller.syncOldMachineOpen,
                  child: GetX<StatisticsMachineMaintainDetailController>(
                    builder: (_) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 35.w,
                        height: 19.w,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage(assetsName(
                                    "statistics/machine/switch_${controller.syncOldMachineOpen ? "open" : "close"}")))),
                      );
                    },
                  ),
                )
              ], width: 315, height: 45),
            ),
          ),
        ],
      ),
    );
  }

  Widget machineInfoView() {
    return SizedBox(
      width: 345.w,
      child: Column(
        children: [
          sbhRow([
            getSimpleText("故障设备信息", 12, AppColor.text3),
          ], width: 345, height: 41.5),
          Container(
            width: 345.w,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
            child: Column(
              children: [
                ghb(12),
                infoCell(
                    "发起人",
                    controller.orderData["u_Name"] != null &&
                            controller.orderData["u_Name"].isNotEmpty
                        ? controller.orderData["u_Name"]
                        : controller.orderData["u_Mobile"] ?? ""),
                infoCell("维修设备号", controller.orderData["oldTerminalNo"] ?? ""),
                // infoCell("故障类型", "设备无法正常使用"),
                ghb(4),
                sbRow([
                  getWidthText("故障描述", 14, AppColor.text3, 84.5, 1,
                      textHeight: 1.3),
                  getWidthText("${controller.orderData["cause"] ?? ""}", 14,
                      AppColor.text2, 315 - 84.5, 10,
                      textHeight: 1.3),
                ], width: 315, crossAxisAlignment: CrossAxisAlignment.start),
                sbhRow([getSimpleText("故障凭证", 14, AppColor.text3)],
                    width: 315, height: 24),
                ghb(5),
                SizedBox(
                  width: 315.w,
                  child: Wrap(
                    spacing: 12.w,
                    runSpacing: 12.w,
                    children: List.generate(controller.imgs.length, (index) {
                      return CustomButton(
                        onPressed: () {
                          toCheckImg(
                              image: AppDefault().imageUrl +
                                  controller.imgs[index]);
                        },
                        child: CustomNetworkImage(
                          src: AppDefault().imageUrl + controller.imgs[index],
                          width: (315.w - 12.w * (3 - 1)) / 3 - 0.1.w,
                          height: (315.w - 12.w * (3 - 1)) / 3 - 0.1.w,
                        ),
                      );
                    }),
                  ),
                ),
                ghb(12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget toMeTopView() {
    return Container(
      width: 375.w,
      height: 300.w,
      color: Colors.white,
      child: Column(
        children: [
          ghb(36),
          Image.asset(
            assetsName("statistics/machine/bg_wait_sh"),
            width: 142.5.w,
            fit: BoxFit.fitWidth,
          ),
          ghb(35),
          getSimpleText("审核中", 18, AppColor.text, isBold: true),
          ghb(12),
          getSimpleText("您提交的申请正在审核中，请耐心等待。", 12, AppColor.text3)
        ],
      ),
    );
  }

  Widget infoCell(String t1, String t2,
      {double width = 84.5, double width2 = 230, double height = 24}) {
    return sbhRow([
      centRow([
        getWidthText(t1, 14, AppColor.text3, width, 1, textHeight: 1.2),
        getWidthText(t2, 14, AppColor.text2, width2, 1, textHeight: 1.3),
      ])
    ], width: 315, height: height);
  }
}
