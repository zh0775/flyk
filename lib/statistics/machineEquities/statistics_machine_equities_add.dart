import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class StatisticsMachineEquitiesAddBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineEquitiesAddController>(
        StatisticsMachineEquitiesAddController(datas: Get.arguments));
  }
}

class StatisticsMachineEquitiesAddController extends GetxController {
  final dynamic datas;
  StatisticsMachineEquitiesAddController({this.datas});

  MachineOrderUtil util = MachineOrderUtil();

  Map myMachineData = {};

  List machines = [];

  final _submitEnable = true.obs;
  bool get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  final _selectMachines = Rx<List>([]);
  List get selectMachines => _selectMachines.value;
  set selectMachines(v) => _selectMachines.value = v;

  final _selectCount = 0.obs;
  int get selectCount => _selectCount.value;
  set selectCount(v) => _selectCount.value = v;

  late BottomPayPassword bottomPayPassword;

  submitAction() {
    if (selectMachines.isEmpty) {
      ShowToast.normal("请选择需要添加的设备");
      return;
    }
    if (selectMachines.length > (myMachineData["isUnused"] ?? 0)) {
      ShowToast.normal("添加的设备超过${myMachineData["isUnused"] ?? 0}台，请进行删减");
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

  loadBindMachine(String pwd) {
    submitEnable = false;

    String machinesStr = "";
    List.generate(selectMachines.length, (index) {
      machinesStr += "${index == 0 ? "" : ","}${selectMachines[index]["tId"]}";
    });

    simpleRequest(
      url: Urls.userTerminalAssociate,
      params: {
        "terminal_Ids": machinesStr,
        "u_3nd_Pad": pwd,
      },
      success: (success, json) {
        if (success) {
          ShowToast.normal("恭喜您，添加权益设备成功！");
          Get.find<StatisticsMachineEquitiesController>().loadData();
          Get.find<HomeController>().refreshHomeData();
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {
        submitEnable = true;
      },
    );
  }

  addMachines(List addMachines) {
    List adds = addMachines.map((e) {
      e["selected"] = true;
      return e;
    }).toList();
    machines = adds;
    selectMachines = adds;
    selectCount = selectMachines.length;
    Get.back();
  }

  unSelectAction(int index) {
    selectMachines = selectMachines.where((e) => e["selected"]).toList();
    selectCount = selectMachines.length;
  }

  @override
  void onInit() {
    myMachineData = datas["machineData"] ?? {};
    machines = ((myMachineData["machines"] ?? []) as List).map((e) {
      e["tNo"] = e["no"];
      e["status"] = 0;
      return e;
    }).toList();
    selectMachines = machines.map((e) {
      e["selected"] = true;

      return e;
    }).toList();
    selectCount = selectMachines.length;

    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        loadBindMachine(payPwd);
      },
    );
    super.onInit();
  }
}

class StatisticsMachineEquitiesAdd
    extends GetView<StatisticsMachineEquitiesAddController> {
  const StatisticsMachineEquitiesAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "添加权益设备"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            gwb(375),
            sbhRow([
              Text.rich(TextSpan(
                  text: "当前已有权益设备",
                  style: TextStyle(fontSize: 14.sp, color: AppColor.text2),
                  children: [
                    TextSpan(
                        text: " ${controller.myMachineData["isUsed"] ?? 0} ",
                        style:
                            TextStyle(fontSize: 14.sp, color: AppColor.theme)),
                    const TextSpan(
                      text: "台，您还可添加",
                    ),
                    TextSpan(
                        text: " ${controller.myMachineData["isUnused"] ?? 0} ",
                        style:
                            TextStyle(fontSize: 14.sp, color: AppColor.theme)),
                    const TextSpan(
                      text: "台",
                    ),
                  ]))
            ], width: 375 - 16.5 * 2, height: 56),
            GetX<StatisticsMachineEquitiesAddController>(
              builder: (_) {
                return controller.util.getOrSetMachineList(
                  3,
                  controller.selectMachines,
                  controller.selectMachines,
                  controller.myMachineData,
                  addMachines: (machines) {
                    controller.addMachines(machines);
                  },
                  unSelectAction: (index) {
                    controller.unSelectAction(index);
                  },
                );
              },
            ),
            ghb(31.5),
            GetX<StatisticsMachineEquitiesAddController>(
              builder: (_) {
                return getSubmitBtn("确认", () {
                  controller.submitAction();
                },
                    enable: controller.submitEnable,
                    width: 345,
                    height: 45,
                    color: AppColor.theme);
              },
            ),
            ghb(20),
          ],
        ),
      ),
    );
  }
}
