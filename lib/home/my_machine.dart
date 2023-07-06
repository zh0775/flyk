import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/myMachine/my_machine_info.dart';
import 'package:cxhighversion2/home/myMachine/my_machine_unbind.dart';
import 'package:cxhighversion2/home/myTeam/my_team_accountingrate_change.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyMachineBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MyMachineController>(MyMachineController());
  }
}

class MyMachineController extends GetxController {
  PageController pageController = PageController();
  // late CustomDropDownController _dropDownCtrl;

  final _isLoadding = false.obs;
  bool get isLoadding => _isLoadding.value;
  set isLoadding(v) => _isLoadding.value = v;

  final _teamIsLoadding = false.obs;
  bool get teamIsLoadding => _teamIsLoadding.value;
  set teamIsLoadding(v) => _teamIsLoadding.value = v;

  TextEditingController filterSearchInputCtrl = TextEditingController();

  RefreshController pullCtrl = RefreshController();
  RefreshController teamPullCtrl = RefreshController();
  int machineCount = 5345;
  double topHeight = 102;
  final _machineButtonIdx = 0.obs;
  int get machineButtonIdx => _machineButtonIdx.value;
  set machineButtonIdx(v) {
    _machineButtonIdx.value = v;
    pageController.jumpToPage(machineButtonIdx);
    update();
    loadData(index: machineButtonIdx);
    update([filterViewBuildId]);
  }

  final _filterShow = false.obs;
  bool get filterShow => _filterShow.value;

  set filterShow(v) {
    _filterShow.value = v;
  }

  resetFilter() {
    if (machineButtonIdx == 0) {
      filterTypeIdx = 0;
      filterStatusIdx = 0;
    } else {
      filterTeamTypeIdx = 0;
      filterTeamStatusIdx = 0;
    }
    filterSearchInputCtrl.clear();
    update([filterViewBuildId]);
  }

  loadScan() async {
    toScanBarCode(((barCode) => filterSearchInputCtrl.text = barCode));
  }

  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _headKey = GlobalKey();

  final _machineDataList = Rx<List>([[], []]);
  List get machineDataList => _machineDataList.value;
  set machineDataList(v) => _machineDataList.value = v;

  // 1激活，2绑定，3在库
  final _teamMachineStatus = 1.obs;
  int get teamMachineStatus => _teamMachineStatus.value;
  set teamMachineStatus(v) => _teamMachineStatus.value = v;

  String filterViewBuildId = "MyMachine_filterViewBuildId";

  int filterTypeIdx = 0;
  int filterStatusIdx = 0;

  int filterTeamTypeIdx = 0;
  int filterTeamStatusIdx = 0;

  Map publicHomeData = {};
  List xhList = [];

  List statusList = [
    {"id": 0, "name": "全部", "selected": true},
    {"id": 3, "name": "已激活", "selected": false},
    {"id": 2, "name": "已绑定", "selected": false},
    {"id": 1, "name": "在库", "selected": false}
  ];

  List mechines = [];

  int pageNo = 1;
  int pageSize = 20;
  int count = 0;

  int teamPageNo = 1;
  int teamPageSize = 20;
  int teamCount = 0;

  onLoad() async {
    loadData(isLoad: true, index: 0);
  }

  onTeamLoad() async {
    loadData(isLoad: true, index: 1);
  }

  onRefresh() async {
    loadData(index: 0);
  }

  onTeamRefresh() async {
    loadData(index: 1);
  }

  loadData({bool isLoad = false, int? index}) {
    int loadIndex = index ?? machineButtonIdx;
    if (isLoad) {
      loadIndex == 0 ? pageNo++ : teamPageNo++;
    } else {
      loadIndex == 0 ? pageNo = 1 : teamPageNo = 1;
    }

    if (machineDataList[loadIndex].isEmpty) {
      loadIndex == 0 ? isLoadding = true : teamIsLoadding = true;
    }

    Map<String, dynamic> params = {
      "teamType": loadIndex,
      "pageNo": loadIndex == 0 ? pageNo : teamPageNo,
      "pageSize": loadIndex == 0 ? pageSize : teamPageSize,
      "terminalBrandId": -1,
      "terminalModel": xhList.isEmpty ? -1 : (xhList[loadIndex == 0 ? filterTypeIdx : filterTeamTypeIdx]["enumValue"] ?? -1),
      "status": loadIndex == 0 ? statusList[filterStatusIdx]["id"] : statusList[filterTeamStatusIdx]["id"],
      "terminalNo": filterSearchInputCtrl.text.isNotEmpty ? filterSearchInputCtrl.text : "",
    };

    var pCtrl = loadIndex == 0 ? pullCtrl : teamPullCtrl;

    simpleRequest(
      url: Urls.userPersonTerminalHighList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          loadIndex == 0 ? count = data["count"] ?? 0 : teamCount = data["count"] ?? 0;

          List dataList = data["data"] ?? [];
          if (isLoad) {
            machineDataList[loadIndex] = [...machineDataList[loadIndex], ...dataList];
          } else {
            machineDataList[loadIndex] = dataList;
          }
          isLoad ? pCtrl.loadComplete() : pCtrl.refreshCompleted();
          update();
        } else {
          isLoad ? pCtrl.loadFailed() : pCtrl.refreshFailed();
        }
      },
      after: () {
        loadIndex == 0 ? isLoadding = false : teamIsLoadding = false;
      },
    );
  }

  @override
  void onInit() {
    // _dropDownCtrl = CustomDropDownController();
    publicHomeData = AppDefault().publicHomeData;
    if (publicHomeData.isNotEmpty &&
        publicHomeData["terminalMod"] != null &&
        publicHomeData["terminalMod"].isNotEmpty &&
        publicHomeData["terminalMod"] is List) {
      xhList = [
        {"enumValue": -1, "enumName": "全部"},
        ...publicHomeData["terminalMod"]
      ].map((e) => {...e, "selected": false}).toList();
      if (xhList.isNotEmpty) {
        xhList[0]["selected"] = true;
      }
    }
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    pullCtrl.dispose();
    teamPullCtrl.dispose();
    filterSearchInputCtrl.dispose();
    pageController.dispose();
    super.onClose();
  }
}

class MyMachine extends GetView<MyMachineController> {
  const MyMachine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => takeBackKeyboard(context),
        child: Scaffold(
            appBar: getDefaultAppBar(context, "我的机具"
                // action: [
                //   CustomButton(
                //     onPressed: () {
                //       showOperation(context);
                //     },
                //     child: SizedBox(
                //       width: 60.w,
                //       height: 50.w,
                //       child: Center(
                //         child: getSimpleText("操作", 14, AppColor.textBlack),
                //       ),
                //     ),
                //   )
                // ]
                ),
            body: Stack(key: controller._stackKey, children: [
              Positioned(
                  top: (controller.topHeight + 10).w,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: GetBuilder<MyMachineController>(
                      init: controller,
                      initState: (_) {},
                      builder: (_) {
                        return PageView(
                            physics: const NeverScrollableScrollPhysics(),
                            controller: controller.pageController,
                            children: [machineList(0, context), machineList(1, context)]);
                      })),
              GetX<MyMachineController>(
                  init: controller,
                  initState: (_) {},
                  builder: (_) {
                    return AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        key: controller._headKey,
                        top: 0,
                        right: 0,
                        height: controller.topHeight.w + (controller.filterShow ? 362.w : 0),
                        left: 0,
                        child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(children: [
                              Container(
                                  width: 375.w,
                                  color: Colors.white,
                                  height: controller.topHeight.w,
                                  child: Column(children: [
                                    gline(375, 0.5),
                                    Row(
                                      children: [machineChooesButton(0, context), machineChooesButton(1, context)],
                                    ),
                                    gline(375, 0.5),
                                    sbhRow([
                                      GetBuilder<MyMachineController>(
                                        init: controller,
                                        builder: (_) {
                                          return getSimpleText("总计机具：${controller.machineButtonIdx == 0 ? controller.count : controller.teamCount}",
                                              15, AppColor.textBlack);
                                        },
                                      ),
                                      CustomButton(
                                          onPressed: () {
                                            controller.filterShow = !controller.filterShow;
                                            // showOrHideFilter(context);
                                          },
                                          child: centRow(
                                              [getSimpleText("筛选", 15, AppColor.textBlack), gwb(5), Icon(Icons.keyboard_arrow_down, size: 20.w)]))
                                    ], width: 345, height: 50)
                                  ])),
                              Container(
                                  color: Colors.white,
                                  width: 375.w,
                                  height: 282.w,
                                  // height: 362.w,
                                  child: Stack(children: [
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        left: 0,
                                        bottom: 50.w,
                                        child: SingleChildScrollView(
                                            child: GetBuilder<MyMachineController>(
                                                id: controller.filterViewBuildId,
                                                init: controller,
                                                builder: (_) {
                                                  return centClm([
                                                    gline(375, 0.5),
                                                    ghb(4.5),
                                                    controller.xhList.isEmpty
                                                        ? ghb(0)
                                                        : sbhRow([
                                                            getSimpleText("机具类型", 14, AppColor.textBlack),
                                                          ], width: 375 - 23.5 * 2, height: 13 + 15.5 * 2),
                                                    SizedBox(
                                                        width: 345.w,
                                                        child: Wrap(spacing: 15.w, runSpacing: 15.w, children: [
                                                          ...controller.xhList
                                                              .asMap()
                                                              .entries
                                                              .map((e) => filterButton(e.value["enumName"], 0, e.key, e.value))
                                                              .toList()
                                                        ])),
                                                    ghb(4.5),
                                                    sbhRow([
                                                      getSimpleText("机具状态", 14, AppColor.textBlack),
                                                    ], width: 375 - 23.5 * 2, height: 13 + 15.5 * 2),
                                                    SizedBox(
                                                        width: 345.w,
                                                        child: Wrap(spacing: 15.w, runSpacing: 15.w, children: [
                                                          ...controller.statusList
                                                              .asMap()
                                                              .entries
                                                              .map((e) => filterButton(e.value["name"], 1, e.key, e.value))
                                                              .toList()
                                                        ])),
                                                    ghb(4.5),
                                                    sbhRow([
                                                      getSimpleText("机具搜索", 14, AppColor.textBlack),
                                                    ], width: 375 - 23.5 * 2, height: 13 + 15.5 * 2),
                                                    Container(
                                                        // padding: EdgeInsets.only(left: 8.w),
                                                        width: 330.w,
                                                        height: 50.w,
                                                        decoration:
                                                            BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(5)),
                                                        child: Center(
                                                            child: sbRow([
                                                          CustomInput(
                                                              width: 266.w,
                                                              heigth: 50.w,
                                                              textEditCtrl: controller.filterSearchInputCtrl,
                                                              placeholder: "请输入机具号搜索"),
                                                          AppDefault().appHideScan()
                                                              ? gwb(24)
                                                              : CustomButton(
                                                                  onPressed: () {
                                                                    controller.loadScan();
                                                                  },
                                                                  child: assetsSizeImage("home/machinemanage/tiaoxingma", 24, 24))
                                                        ], width: 330 - 15 * 2)))
                                                  ]);
                                                }))),
                                    Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        height: 50.w,
                                        child: Row(children: [filterBottomButton(0), filterBottomButton(1)]))
                                  ]))
                            ])));
                  })
            ])));
  }

  Widget machineList(int index, BuildContext context) {
    List machineDataList = controller.machineDataList[index];
    return SmartRefresher(
        key: ValueKey(index == 0 ? "mine" : "team"),
        physics: const BouncingScrollPhysics(),
        controller: index == 0 ? controller.pullCtrl : controller.teamPullCtrl,
        onLoading: index == 0 ? controller.onLoad : controller.onTeamLoad,
        onRefresh: index == 0 ? controller.onRefresh : controller.onTeamRefresh,
        enablePullUp: index == 0 ? controller.count > machineDataList.length : controller.teamCount > machineDataList.length,
        child: machineDataList.isEmpty
            ? GetX<MyMachineController>(builder: (_) {
                return CustomEmptyView(isLoading: index == 0 ? controller.isLoadding : controller.teamIsLoadding);
              })
            : ListView.builder(
                padding: EdgeInsets.only(bottom: paddingSizeBottom(context) + 20.w),
                itemCount: machineDataList != null ? (machineDataList.length) + 1 : 1,
                itemBuilder: (context, idx) {
                  return idx == 0
                      ? Container(
                          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(width: 1.w, color: AppColor.lineColor))),
                          child: Row(children: [
                            gwb(15),
                            getContentText("机具编号（SN号）", 14, const Color(0xFF808080), 252.5, 45, 1),
                            getContentText("状态", 14, const Color(0xFF808080), 345 - 252.5, 45, 1)
                          ]))
                      : machineCell(machineDataList[idx - 1], idx - 1, context, index == 1, (idx2) {
                          showMachineInfo(machineDataList[idx2], context);
                        });
                }));
  }

  Widget filterBottomButton(int idx) {
    return CustomButton(
        onPressed: () {
          if (idx == 1) {
            controller.loadData();
            controller.filterShow = false;
          } else {
            controller.resetFilter();
          }

          // hideFilter(context);
        },
        child: Container(
            width: 375.w / 2,
            height: 50.w,
            decoration: BoxDecoration(
                color: idx == 0 ? Colors.white : AppColor.theme, border: Border(top: BorderSide(width: 0.5.w, color: AppColor.lineColor))),
            child: Center(child: getSimpleText(idx == 0 ? "重置" : "确认", 15, idx == 0 ? AppColor.textBlack : Colors.white, isBold: true))));
  }

  Widget filterButton(String t1, int section, int idx, Map data) {
    bool selected = (controller.machineButtonIdx == 0
        ? (section == 0 ? controller.filterTypeIdx == idx : controller.filterStatusIdx == idx)
        : (section == 0 ? controller.filterTeamTypeIdx == idx : controller.filterTeamStatusIdx == idx));

    return CustomButton(
        onPressed: () {
          if (section == 0) {
            controller.machineButtonIdx == 0 ? controller.filterTypeIdx = idx : controller.filterTeamTypeIdx = idx;
            // print(controller.filterTypeIdx);
          } else {
            controller.machineButtonIdx == 0 ? controller.filterStatusIdx = idx : controller.filterTeamStatusIdx = idx;
          }

          // data["selected"] = !data["selected"];
          controller.update([controller.filterViewBuildId]);
          // setState(() {
          //   selected = !selected;
          // });
        },
        child: Container(
            padding: EdgeInsets.fromLTRB(18.w, 10.w, 18.w, 10.w),
            decoration: BoxDecoration(color: selected ? AppColor.theme : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(5.w)),
            child: getSimpleText(t1, 14, selected ? Colors.white : AppColor.textGrey2)));
  }

  Widget machineChooesButton(int idx, BuildContext context) {
    return CustomButton(
        onPressed: () {
          // hideFilter(context);
          if (idx != controller.machineButtonIdx) {
            // setState(() {
            //   machineButtonIdx = idx;
            // });
            controller.machineButtonIdx = idx;
          }
        },
        child: GetX<MyMachineController>(
            init: controller,
            initState: (_) {},
            builder: (_) {
              return SizedBox(
                  width: 375.w / 2,
                  height: 49.w,
                  child: Center(
                      child: getSimpleText(
                          "${idx == 0 ? "我的" : "团队"}机具", 15, idx == controller.machineButtonIdx ? AppColor.buttonTextBlue : AppColor.buttonTextBlack,
                          isBold: true)));
            }));
  }

  getStatus(Map data) {
    String statusStr = "";
    if (controller.machineButtonIdx == 0) {
      statusStr = data["tStatus"] ?? "";
    } else {
      statusStr = controller.filterTeamStatusIdx == 1
          ? "已激活"
          : controller.filterTeamStatusIdx == 2
              ? "已绑定"
              : "在库";
    }
    return statusStr;
  }

  Widget machineCell(Map data, int idx, BuildContext context, bool isDirectly, Function(int idx) cellTap) {
    return Container(
      width: 375.w,
      height: 81.5.w,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColor.lineColor, width: 0.5.w))),
      child: Center(
          child: SizedBox(
        width: 345.w,
        child: centClm([
          getSimpleText(data["tbName"] ?? "", 14, AppColor.textBlack, isBold: true),
          ghb(10),
          Row(
            children: [
              getWidthText(data["tNo"] != null ? snNoFormat(data["tNo"]) : "", 14, const Color(0xFF808080), 252.5, 1),
              getWidthText(getStatus(data), 14, AppColor.textBlack, 58.5, 1),
              CustomButton(
                onPressed: () {
                  // if (cellTap != null) {
                  //   cellTap(idx);
                  // }
                  push(
                      MyMachineInfo(
                        machineData: data,
                        isDirectly: isDirectly,
                      ),
                      context,
                      binding: MyMachineInfoBinding());
                },
                child: getSimpleText("查看", 13, AppColor.textGrey),
              ),
            ],
          )
        ], crossAxisAlignment: CrossAxisAlignment.start),
      )),
    );
  }

  void showMachineInfo(Map data, BuildContext context) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 200),
        barrierColor: Colors.black.withOpacity(.5),
        pageBuilder: (BuildContext dialogCtx, Animation<double> animation, Animation<double> secondaryAnimation) {
          return Align(
            child: SizedBox(
              width: 345.w,
              height: 537.5.w + 54.w,
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
                      bottom: 0,
                      top: 54.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Material(
                          color: Colors.white,
                          child: SizedBox(
                            width: 1.5.w,
                            height: 20.w,
                            child: Column(
                              children: [
                                ghb(20),
                                sbhRow([
                                  getSimpleText("机具信息", 25, AppColor.textBlack),
                                  // CustomNetworkImage(
                                  //   src: AppDefault().imageUrl +
                                  //       data["terninal_Pic"],
                                  //   width: 65.w,
                                  //   height: 65.w,
                                  //   fit: BoxFit.fill,
                                  // ),
                                ], width: 295, height: 65),
                                ghb(20),
                                dailogCell("品牌", data["tbName"], ""),
                                ghb(13.5),
                                dailogCell("产品名称", data["tmName"], ""),
                                ghb(13.5),
                                dailogCell("SN号", "${data["tNo"] ?? ""}", ""),
                                ghb(13.5),
                                // dailogCell("入库时间", data["transferTime"], ""),
                                // ghb(13.5),
                                // dailogCell(
                                //     "状态", getStatus(data), "即将激活过期：2天12小时"),
                                // ghb(13.5),
                                // dailogCell("绑定时间", data["binding_Time"], ""),
                                ghb(25),
                                CustomButton(
                                  onPressed: () {
                                    Navigator.pop(dialogCtx);
                                    // push(MachineManage(), context);
                                  },
                                  child: Container(
                                    width: 270.w,
                                    height: 45.w,
                                    decoration: BoxDecoration(
                                        color: AppDefault().getThemeColor() ?? AppColor.theme, borderRadius: BorderRadius.circular(22.5)),
                                    child: Center(
                                      child: getSimpleText("查看商户详情", 15, Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          );
        });
  }

  Widget dailogCell(String t1, String t2, String warnTip) {
    return Container(
      width: 315.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: warnTip != null && warnTip.length > 0
              ? Text.rich(
                  TextSpan(
                      text: "$t1:$t2",
                      style: TextStyle(fontSize: 14.sp, color: AppColor.buttonTextBlack),
                      children: [TextSpan(text: "  $warnTip", style: TextStyle(color: const Color(0xFFE3463D), fontSize: 12.sp))]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  "$t1:$t2",
                  style: TextStyle(fontSize: 14.sp, color: AppColor.buttonTextBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }

  // void showOrHideFilter(BuildContext context) {
  //   FocusScope.of(context).requestFocus(FocusNode());
  //   if (controller.filterShow) {
  //     controller.filterShow = false;
  //     controller._dropDownCtrl.hide();
  //   } else {
  //     controller.filterShow = true;
  //     controller._dropDownCtrl.show(controller._stackKey, controller._headKey);
  //   }
  // }

  // void hideFilter(BuildContext context) {
  //   FocusScope.of(context).requestFocus(FocusNode());
  //   if (controller.filterShow) {
  //     controller.filterShow = false;
  //     controller._dropDownCtrl.hide();
  //   }
  // }

  void showOperation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        bottom: true,
        child: Container(
          height: 200.w,
          color: AppColor.pageBackgroundColor,
          child: Column(
            children: [
              CustomButton(
                onPressed: () {
                  Get.to(const MyTeamAccountingrateChange(), binding: MyTeamAccountingrateChangeBinding());
                },
                child: Container(
                  width: 375.w,
                  height: 60.w,
                  color: Colors.white,
                  child: Center(
                    child: getSimpleText("结算费率修改", 16, AppColor.textBlack),
                  ),
                ),
              ),
              ghb(10),
              CustomButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  push(MyMachineUnbind(), context);
                },
                child: Container(
                  width: 375.w,
                  height: 60.w,
                  color: Colors.white,
                  child: Center(
                    child: getSimpleText("解绑机具", 16, AppColor.textBlack),
                  ),
                ),
              ),
              ghb(10),
              CustomButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 375.w,
                  height: 60.w,
                  color: Colors.white,
                  child: Center(
                    child: getSimpleText("取消", 16, AppColor.textBlack),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
