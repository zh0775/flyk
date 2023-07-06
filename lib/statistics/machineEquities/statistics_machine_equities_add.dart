import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_userlist.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities_history.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatisticsMachineEquitiesAddBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineEquitiesAddController>(StatisticsMachineEquitiesAddController(datas: Get.arguments));
  }
}

class StatisticsMachineEquitiesAddController extends GetxController {
  final dynamic datas;
  StatisticsMachineEquitiesAddController({this.datas});

  MachineOrderUtil util = MachineOrderUtil();

  Map myMachineData = {};

  List machines = [];

  final _selectUserData = Rx<Map>({});
  set selectUserData(value) => _selectUserData.value = value;
  Map get selectUserData => _selectUserData.value;

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

  showAddSuccModel() {
    showGeneralDialog(
      barrierLabel: "",
      barrierDismissible: true,
      context: Global.navigatorKey.currentContext!,
      pageBuilder: (context, animation, secondaryAnimation) {
        return UnconstrainedBox(
          child: Material(
              color: Colors.transparent,
              child: SizedBox(
                  width: 300.w,
                  height: 180.w + 37.5.w,
                  child: Stack(children: [
                    Positioned(
                        top: 37.5.w,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: getDefaultWhiteDec(radius: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              centClm([
                                ghb(37.5),
                                getSimpleText("添加成功", 18, AppColor.text2, isBold: true),
                                ghb(15),
                                getWidthText("设备已添加到该商户名下，您可在“添加设备-操作记录”中查看", 12, AppColor.textGrey5, 222, 2)
                              ]),
                              centClm([
                                gline(300, 1),
                                CustomButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: SizedBox(
                                    width: 300.w,
                                    height: 54.w,
                                    child: Center(
                                      child: getSimpleText("知道了", 16, AppColor.theme),
                                    ),
                                  ),
                                )
                              ])
                            ],
                          ),
                        )),
                    Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 75.w,
                        child: Center(
                            child: Container(
                                width: 75.w,
                                height: 75.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(37.5.w)),
                                child: Image.asset(assetsName("machine/icon_result_success"), width: 57.w, height: 57.w, fit: BoxFit.fill))))
                  ]))),
        );
      },
    );
  }

  selectUser(Map user) {
    selectUserData = user;
  }

  submitAction() {
    if (selectMachines.isEmpty) {
      ShowToast.normal("请选择需要添加的设备");
      return;
    }
    if (selectUserData.isEmpty) {
      ShowToast.normal("请指定添加对象");
      return;
    }

    if (AppDefault().homeData["u_3rd_password"] == null || AppDefault().homeData["u_3rd_password"].isEmpty) {
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

    List content = [];
    List.generate(selectMachines.length, (index) {
      Map e = selectMachines[index];
      content.add({
        // "productId":0,
        "tId": e["tId"],
        "tNO": e["tNo"],
      });
      // machinesStr += "${index == 0 ? "" : ","}${selectMachines[index]["tId"]}";
    });

    // return;

    simpleRequest(
        url: Urls.userTerminalAssociate2,
        params: {"content": content, "u_3nd_Pad": pwd, "user_ID": selectUserData["uId"]},
        success: (success, json) {
          if (success) {
            // ShowToast.normal("恭喜您，添加权益设备成功！");
            // Get.find<StatisticsMachineEquitiesController>().loadData();
            // Get.find<HomeController>().refreshHomeData();
            // Future.delayed(const Duration(seconds: 1), () {
            //   Get.back();
            // });
            showAddSuccModel();
            selectMachines.clear();
          }
        },
        after: () {
          submitEnable = true;
        });
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
    // myMachineData = (datas ?? {})["machineData"] ?? {};
    // machines = ((myMachineData["machines"] ?? []) as List).map((e) {
    //   e["tNo"] = e["no"];
    //   e["status"] = 0;
    //   return e;
    // }).toList();
    // selectMachines = machines.map((e) {
    //   e["selected"] = true;

    //   return e;
    // }).toList();
    // selectCount = selectMachines.length;

    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        loadBindMachine(payPwd);
      },
    );
    super.onInit();
  }
}

class StatisticsMachineEquitiesAdd extends GetView<StatisticsMachineEquitiesAddController> {
  const StatisticsMachineEquitiesAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "添加设备", action: [
        CustomButton(
          onPressed: () {
            push(const StatisticsMachineEquitiesHistory(), context, binding: StatisticsMachineEquitiesHistoryBinding());
          },
          child: SizedBox(
            height: kToolbarHeight,
            width: 75.w,
            child: Center(
              child: getSimpleText("操作记录", 15, AppColor.text2),
            ),
          ),
        )
      ]),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            gwb(375),
            ghb(7),
            sbhRow([getSimpleText("选择指定添加对象", 12, AppColor.textGrey)], width: 375 - 15.5 * 2, height: 38.5),
            GetX<StatisticsMachineEquitiesAddController>(
              init: controller,
              builder: (_) {
                return transferSection(
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22.5.w),
                      child: controller.selectUserData["uAvatar"] != null && controller.selectUserData["uAvatar"].isNotEmpty
                          ? CustomNetworkImage(
                              src: "${AppDefault().imageUrl}${controller.selectUserData["uAvatar"]}",
                              width: 45.w,
                              height: 45.w,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(assetsName("common/default_head"), width: 45.w, height: 45.w, fit: BoxFit.fill),
                    ),
                    controller.selectUserData.isNotEmpty ? controller.selectUserData["uName"] ?? (controller.selectUserData["uMobile"] ?? "") : "请选择",
                    controller.selectUserData.isNotEmpty
                        ? "${controller.selectUserData["uNumber"] ?? ""}|${controller.selectUserData["uMobile"] ?? ""}"
                        : "未选择",
                    AppColor.textGrey, () {
                  // push(
                  //     MachineTransferUserList(
                  //       userData: controller.userList,
                  //     ),
                  //     context,
                  //     bindings: MachineTransferUserListBinding());

                  Get.to(
                      MachineTransferUserList(
                        fromCtrl: controller,
                      ),
                      binding: MachineTransferUserListBinding(),
                      arguments: {
                        "levelType": 1,
                        "teamYlocation": 1,
                      });
                });
              },
            ),
            ghb(7),
            sbhRow([getSimpleText("选择要添加的设备", 12, AppColor.textGrey)], width: 375 - 15.5 * 2, height: 38.5),
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
                return getSubmitBtn("确认添加", () {
                  controller.submitAction();
                }, enable: controller.submitEnable, width: 345, height: 45, color: AppColor.theme);
              },
            ),
            ghb(20),
          ],
        ),
      ),
    );
  }

  Widget transferSection(Widget img, String t1, String t2, Color t2Color, Function() toNextPage) {
    return CustomButton(
      onPressed: toNextPage,
      child: Container(
          width: 345.w,
          height: 75.w,
          decoration: getDefaultWhiteDec(radius: 4),
          child: Center(
            child: sbRow([
              centRow([
                gwb(15),
                img,
                gwb(18.5),
                centClm([
                  getWidthText(t1, 15, AppColor.textBlack, 159.5, 1, isBold: true, textAlign: TextAlign.left),
                  ghb(6),
                  getWidthText(t2, 12, t2Color, 159.5, 1, textAlign: TextAlign.left),
                ], crossAxisAlignment: CrossAxisAlignment.start)
              ]),
              centRow([
                Image.asset(
                  assetsName("message_notify/arrow_right_gray"),
                  width: 15.w,
                  fit: BoxFit.fitWidth,
                ),
                gwb(20),
              ])
            ], width: 345),
          )),
    );
  }
}
