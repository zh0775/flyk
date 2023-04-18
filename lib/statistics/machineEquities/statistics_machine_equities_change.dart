import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities_add_list.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities_history.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatisticsMachineEquitiesChangeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineEquitiesChangeController>(
        StatisticsMachineEquitiesChangeController(datas: Get.arguments));
  }
}

class StatisticsMachineEquitiesChangeController extends GetxController {
  final dynamic datas;
  StatisticsMachineEquitiesChangeController({this.datas});

  late BottomPayPassword bottomPayPassword;

  final _submitEnable = true.obs;
  bool get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  String explainSrc = '''一、积分获取与计算
1.购买复购积分只能用于联聚商城区以及联聚拓客合作

2.平台消费或兑换；如有疑问请联系：400 809 1988。

3.为了更好的增加商户粘性度，安装新设备时，如果商户48小时内未绑定联聚拓客平台，则此设备为未达标设备。设备激活后正常交易有效达标1万元，此设备不参与奖励积分（培育奖、直招盘主装机奖励）。

4、注册pos机的资料要和注册联聚拓客平台用户的资料要一致，否则不能获取对应的交易积分

二、积分获取与计算
1.购买复购积分只能用于联聚商城区以及联聚拓客合作
为了更好的增加商户粘性度，安装新设备时，如果商户48小时内未绑定联聚拓客平台，则此设备为未达标设备。设备激活后正常交易有效达标1万元，此设备不参与奖励积分（培育奖、直招盘主装机奖励）。

4、注册pos机的资料要和注册联聚拓客平台用户的资料要一致，否则不能获取对应的交易积分''';

  Map changeMachine = {};

  submitAction() {
    if (changeMachine.isEmpty) {
      ShowToast.normal("请选择需要更换的设备");
      return;
    }
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
    bottomPayPassword.show();
  }

  setMachine(Map sMachine) {
    changeMachine = sMachine;
    update();
    Get.back();
  }

  Map machine = {};
  Map brandData = {};

  loadChange(String payPwd) {
    submitEnable = false;

    simpleRequest(
      url: Urls.userTerminalAssociateSwitch,
      params: {
        "oldId": machine["id"],
        "terminal_newId": changeMachine["tId"],
        "u_3nd_Pad": payPwd,
      },
      success: (success, json) {
        if (success) {
          Get.find<StatisticsMachineEquitiesController>().loadData();
          push(
              AppSuccessResult(
                title: "申请结果",
                contentTitle: "提交成功",
                buttonTitles: const ["查看记录", "返回列表"],
                backPressed: () {
                  Get.until((route) {
                    if (route is GetPageRoute) {
                      if (route.binding is StatisticsMachineEquitiesBinding) {
                        return true;
                      } else {
                        return false;
                      }
                    } else {
                      return false;
                    }
                  });
                },
                onPressed: (index) {
                  if (index == 0) {
                    Get.offUntil(
                        GetPageRoute(
                          page: () => const StatisticsMachineEquitiesHistory(),
                          binding: StatisticsMachineEquitiesHistoryBinding(),
                          settings: const RouteSettings(
                              name: "StatisticsMachineEquitiesHistory"),
                        ), (route) {
                      if (route is GetPageRoute) {
                        if (route.binding is StatisticsMachineEquitiesBinding) {
                          return true;
                        } else {
                          return false;
                        }
                      } else {
                        return false;
                      }
                    });
                  } else {
                    Get.until((route) {
                      if (route is GetPageRoute) {
                        if (route.binding is StatisticsMachineEquitiesBinding) {
                          return true;
                        } else {
                          return false;
                        }
                      } else {
                        return false;
                      }
                    });
                  }
                },
              ),
              Global.navigatorKey.currentContext);
        }
      },
      after: () {
        submitEnable = true;
      },
    );
  }

  @override
  void onInit() {
    machine = datas["machine"] ?? {};
    brandData = datas["brand"] ?? {};

    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        loadChange(payPwd);
      },
    );
    super.onInit();
  }
}

class StatisticsMachineEquitiesChange
    extends GetView<StatisticsMachineEquitiesChangeController> {
  const StatisticsMachineEquitiesChange({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "更换权益设备", action: [
        CustomButton(
          onPressed: () {
            Get.to(
                StatisticsMachineEquitiesExplain(
                  src: controller.explainSrc,
                ),
                transition: Transition.downToUp);
          },
          child: SizedBox(
            height: kToolbarHeight,
            width: 80.w,
            child: Center(
              child: getSimpleText("换机说明", 15, AppColor.text2),
            ),
          ),
        )
      ]),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            gwb(375),
            sbhRow([
              getSimpleText("当前设备", 14, AppColor.text3),
            ], height: 56, width: 375 - 15 * 2),
            machineCell(controller.machine),
            ghb(13.5),
            sbhRow([
              getSimpleText("选择想要置换的设备", 14, AppColor.text3),
              CustomButton(
                onPressed: () {
                  push(const StatisticsMachineEquitiesAddList(), null,
                      binding: StatisticsMachineEquitiesAddListBinding(),
                      arguments: {
                        "setMachine": controller.setMachine,
                        "machines": [controller.changeMachine],
                        "singleSelect": true,
                        "maxCount": 1,
                        "toChange": true,
                      });
                },
                child: SizedBox(
                  height: 56.w,
                  child: Center(
                    child: centRow([
                      getSimpleText("更换设备", 12, AppColor.text2),
                      Image.asset(
                        assetsName("statistics/icon_arrow_right_gray"),
                        width: 12.w,
                        fit: BoxFit.fitWidth,
                      ),
                    ]),
                  ),
                ),
              )
            ], height: 56, width: 375 - 15 * 2),
            GetBuilder<StatisticsMachineEquitiesChangeController>(
              builder: (_) {
                return machineCell(controller.changeMachine, fromSelect: true);
              },
            ),
            ghb(29),
            GetX<StatisticsMachineEquitiesChangeController>(
              builder: (_) {
                return getSubmitBtn("提交", () {
                  controller.submitAction();
                },
                    enable: controller.submitEnable,
                    width: 345,
                    height: 45,
                    color: AppColor.theme);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget machineCell(Map machineData, {bool fromSelect = false}) {
    return Container(
      width: 345.w,
      height: machineData.isEmpty ? 70.w : 120.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: machineData.isEmpty
          ? CustomButton(
              onPressed: () {
                push(const StatisticsMachineEquitiesAddList(), null,
                    binding: StatisticsMachineEquitiesAddListBinding(),
                    arguments: {
                      "machines": [controller.changeMachine],
                      "setMachine": controller.setMachine,
                      "singleSelect": true,
                      "maxCount": 1,
                      "toChange": true,
                    });
              },
              child: SizedBox(
                width: 345.w,
                height: 70.w,
                child: Center(
                  child: getSimpleText("点击选择想要置换的设备", 16, AppColor.text3),
                ),
              ),
            )
          : Center(
              child: sbhRow([
                centRow([
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.w),
                    child: CustomNetworkImage(
                      src: AppDefault().imageUrl +
                          (machineData[fromSelect ? "tImg" : "bgImg"] ?? ""),
                      width: 90.w,
                      height: 90.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                  gwb(12),
                  centClm([
                    getSimpleText(
                        machineData[fromSelect ? "tbName" : "brandName"] ?? "",
                        15,
                        AppColor.text,
                        isBold: true),
                    ghb(8),
                    ...List.generate(3, (index) {
                      return centRow([
                        ghb(20),
                        getWidthText(
                            index == 0
                                ? "设备型号"
                                : index == 1
                                    ? "设备编号"
                                    : "激活时间",
                            12,
                            AppColor.text3,
                            68.5,
                            1,
                            textHeight: 1.2),
                        getWidthText(
                            index == 0
                                ? machineData[
                                        fromSelect ? "tmName" : "modelName"] ??
                                    ""
                                : index == 1
                                    ? machineData[
                                            fromSelect ? "tNo" : "termNo"] ??
                                        ""
                                    : machineData[fromSelect
                                            ? "activaTime"
                                            : "activTime"] ??
                                        "",
                            12,
                            AppColor.text2,
                            345 - 15 * 2 - 90 - 12 - 68.5 - 1,
                            1,
                            textHeight: 1.2),
                      ]);
                    })
                  ], crossAxisAlignment: CrossAxisAlignment.start)
                ])
              ], height: 120, width: 345 - 15 * 2),
            ),
    );
  }
}

class StatisticsMachineEquitiesExplain extends StatelessWidget {
  final String src;
  const StatisticsMachineEquitiesExplain({super.key, this.src = ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "换机说明",
          leading: CustomButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: centRow([
              defaultBackButtonView(),
              getSimpleText("关闭", 14, AppColor.text2, textHeight: 1.5)
            ]),
          ),
          leadingWidth: 80.w),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            gwb(375),
            ghb(20),
            getWidthText(src, 14, AppColor.text2, 345, 1000),
            ghb(20),
          ],
        ),
      ),
    );
  }
}
