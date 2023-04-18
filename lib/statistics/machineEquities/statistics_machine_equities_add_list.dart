import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatisticsMachineEquitiesAddListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineEquitiesAddListController>(
        StatisticsMachineEquitiesAddListController(datas: Get.arguments));
  }
}

class StatisticsMachineEquitiesAddListController extends GetxController {
  final dynamic datas;
  StatisticsMachineEquitiesAddListController({this.datas});

  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  CustomDropDownController filterCtrl = CustomDropDownController();
  CustomDropDownController filterCtrl2 = CustomDropDownController();

  TextEditingController startInputCtrl = TextEditingController();
  TextEditingController endInputCtrl = TextEditingController();

  RefreshController pullCtrl = RefreshController();

  List machineTypes = [];

  final _machineTypesIdx = 0.obs;
  int get machineTypesIdx => _machineTypesIdx.value;
  set machineTypesIdx(v) => _machineTypesIdx.value = v;
  final _realMachineTypesIdx = (-1).obs;
  int get realMachineTypesIdx => _realMachineTypesIdx.value;
  set realMachineTypesIdx(v) => _realMachineTypesIdx.value = v;

  List currentTypes = [
    // {"id": 0, "name": "全部"},
    // {"id": 1, "name": "在库(可划拨)"},
    {"id": 2, "name": "已绑定"},
    {"id": 3, "name": "已激活"},
    {"id": 4, "name": "未绑定"},
    {"id": 5, "name": "有效激活"},
    {"id": 6, "name": "达标"},
    // {"id": 7, "name": "未达标"},
    // {"id": 8, "name": "作废"},
  ];

  final _currentTypesIdx = 0.obs;
  int get currentTypesIdx => _currentTypesIdx.value;
  set currentTypesIdx(v) => _currentTypesIdx.value = v;

  final _realCurrentTypesIdx = (-1).obs;
  int get realCurrentTypesIdx => _realCurrentTypesIdx.value;
  set realCurrentTypesIdx(v) => _realCurrentTypesIdx.value = v;

  List machines = [];
  Map orderData = {};
  int aftersaleType = 0;

  final _btnEnable = true.obs;
  bool get btnEnable => _btnEnable.value;
  set btnEnable(v) => _btnEnable.value = v;

  final _count = 0.obs;
  int get count => _count.value;
  set count(v) => _count.value = v;

  final _selectCount = 0.obs;
  int get selectCount => _selectCount.value;
  set selectCount(v) => _selectCount.value = v;

  final _allselect = false.obs;
  bool get allselect => _allselect.value;
  set allselect(v) => _allselect.value = v;

  final _isFrap = false.obs;
  bool get isFrap => _isFrap.value;
  set isFrap(v) => _isFrap.value = v;

  bool haveFrap = false;

  Function(List addMachines)? addMachines;
  Function(Map mData)? setMachine;

  allSelectAction() {
    checkSelect(allSelect: !allselect);
    update();
  }

  List selectMachines = [];

  checkSelect({bool? allSelect, int? setIndex}) {
    if (machines.isEmpty) {
      allselect = false;
      return;
    }
    bool isAllSelect = true;
    int tmpSelectCount = 0;
    int i = 0;
    selectMachines = [];
    for (var e in machines) {
      if (setIndex != null && singleSelect) {
        e["selected"] = i == setIndex;
      } else {
        if (allSelect != null) {
          e["selected"] = allSelect;
          isAllSelect = allSelect;
        } else {
          if (!(e["selected"] ?? false)) {
            isAllSelect = false;
            // break;
          }
        }
      }
      if ((e["selected"] ?? false)) {
        tmpSelectCount++;
        selectMachines.add(e);
      }
      i++;
    }
    selectCount = tmpSelectCount;
    allselect = isAllSelect;
  }

  confirmAction() {
    if (selectCount > maxCount) {
      ShowToast.normal("选择数量超出，最多可选择$maxCount件");
      return;
    }
    if (selectMachines.isEmpty) {
      ShowToast.normal("请至少选择一件设备");
      return;
    }
    if (toChange) {
      if (setMachine != null) {
        setMachine!(selectMachines[0]);
      }
    } else {
      if (addMachines != null) {
        addMachines!(selectMachines);
      }
    }
  }

  showSelfFilter(int idx) {
    if (filterCtrl.isShow) {
      filterCtrl.hide();
      loadMachines();
      return;
    }
    if (filterCtrl2.isShow) {
      filterCtrl2.hide();
      loadMachines();
      return;
    }
    idx == 0
        ? filterCtrl.show(stackKey, headKey)
        : filterCtrl2.show(stackKey, headKey);
  }

  int maxCount = 100000;

  String filterBuildId = "MachineShipSelect_filterBuildId";
  String filterBuildId2 = "MachineShipSelect_filterBuildId2";

  double filterHeight = 0;
  double filterHeight2 = 0;

  filterHeightFormat() {
    filterHeight = machineTypes.length * 40.0;
    update([filterBuildId]);
    filterHeight2 = currentTypes.length * 40.0;
    update([filterBuildId2]);
  }

  modelSearchReset() {
    startInputCtrl.clear();
    endInputCtrl.clear();
  }

  modelSearchConfirm() {
    takeBackKeyboard(Global.navigatorKey.currentContext!);
    Get.back();
    loadMachines(start: startInputCtrl.text, end: endInputCtrl.text);
  }

  int pageSize = 20;
  int pageNo = 1;

  bool toChange = false;
  bool singleSelect = false;

  loadMachines({bool isLoad = false, String? start, String? end}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (machines.isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
      "tId": machineTypes[machineTypesIdx]["id"],
      "currentTypes": currentTypes[currentTypesIdx]["id"]
    };

    if (start != null && start.isNotEmpty) {
      params["terminal_Start"] = start;
    }
    if (end != null && end.isNotEmpty) {
      params["terminal_End"] = end;
    }

    simpleRequest(
      url: Urls.userTerminalReplaceList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List mDatas = data["data"] ?? [];
          for (var e in mDatas) {
            int tId = e["tId"] ?? -1;
            bool selected = false;
            for (var s in selectMachines) {
              if (s["tId"] == tId) {
                selected = true;
                break;
              }
            }
            e["selected"] = selected;
          }
          machines = isLoad ? [...machines, ...mDatas] : mDatas;

          checkSelect();
          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          update();
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );

    // Future.delayed(const Duration(seconds: 1), () {
    //   count = 100;
    //   List tmpDatas = [];
    //   for (var i = 0; i < pageSize; i++) {
    //     tmpDatas.add({
    //       "id": machines.length + i,
    //       "name": i % 2 == 0 ? "盛电宝K300" : "渝钱宝电签",
    //       "img": "D0031/2023/1/202301311856422204X.png",
    //       "no": "T550006698$i",
    //       "tNo": "T550006698$i",
    //       "useDay": 20 + i,
    //       "bName": "欢乐人",
    //       "bPhone": "13598901253",
    //       "bXh": i % 2 == 0 ? "盛电宝K300123" : "渝钱宝电签123",
    //       "aTime": "2020-01-23 13:26:09",
    //       "selected": false
    //     });
    //   }
    //   machines = isLoad ? [...machines, ...tmpDatas] : tmpDatas;
    //   update();
    //   isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
    //   isLoading = false;
    // });
  }

  @override
  void onInit() {
    if (datas != null && datas is Map && datas.isNotEmpty) {
      selectMachines = datas["machines"] ?? [];
      aftersaleType = datas["type"] ?? 0;
      orderData = datas["orderData"] ?? {};
      addMachines = datas["addMachines"];
      toChange = datas["toChange"] ?? false;
      count = machines.length;
      singleSelect = datas["singleSelect"] ?? false;
      setMachine = datas["setMachine"];

      if (machines.length > 5) {
        isFrap = true;
        haveFrap = true;
      }
      checkSelect();
    }

    machineTypes = [
      {
        "id": -1,
        "name": "全部",
      }
    ];
    Map publicHomeData = AppDefault().publicHomeData;
    if (publicHomeData.isNotEmpty &&
        publicHomeData["terminalConfig"].isNotEmpty &&
        publicHomeData["terminalConfig"] is List) {
      List.generate((publicHomeData["terminalConfig"] as List).length, (index) {
        Map e = (publicHomeData["terminalConfig"] as List)[index];
        machineTypes.add({
          "id": e["id"] ?? -1,
          "name": e["terninal_Name"] ?? "",
        });
      });
    }

    if (toChange) {
      loadMachines();
    } else {
      filterHeightFormat();
    }

    loadMachines();

    super.onInit();
  }

  @override
  void onClose() {
    filterCtrl.dispose();
    filterCtrl2.dispose();
    startInputCtrl.dispose();
    endInputCtrl.dispose();
    pullCtrl.dispose();
    super.onClose();
  }
}

class StatisticsMachineEquitiesAddList
    extends GetView<StatisticsMachineEquitiesAddListController> {
  const StatisticsMachineEquitiesAddList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, controller.toChange ? "选择置换设备" : "选择设备",
          action: controller.toChange
              ? null
              : [
                  CustomButton(
                    onPressed: () {
                      showSearch();
                    },
                    child: SizedBox(
                      height: kToolbarHeight,
                      width: 50.w,
                      child: Center(
                        child: Image.asset(
                          assetsName("machine/btn_search"),
                          width: 18.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  )
                ]),
      body: Stack(
        key: controller.stackKey,
        children: [
          controller.toChange
              ? gemp()
              : Positioned(
                  top: 1.w,
                  left: 0,
                  right: 0,
                  height: 55.w,
                  key: controller.headKey,
                  child: Container(
                    color: Colors.white,
                    child: centRow([
                      CustomButton(
                        onPressed: () {
                          controller.showSelfFilter(0);
                        },
                        child: SizedBox(
                          width: 375.w / 2 - 0.1.w - 20.w,
                          height: 55.w,
                          child: centRow([
                            GetX<StatisticsMachineEquitiesAddListController>(
                              builder: (_) {
                                return getSimpleText(
                                    controller.realMachineTypesIdx == -1
                                        ? "按设备类型"
                                        : controller.machineTypes[controller
                                            .realMachineTypesIdx]["name"],
                                    15,
                                    controller.realMachineTypesIdx != -1
                                        ? AppColor.text2
                                        : AppColor.text3,
                                    isBold: true);
                              },
                            ),
                            gwb(5),
                            GetX<StatisticsMachineEquitiesAddListController>(
                              builder: (_) {
                                return Image.asset(
                                  assetsName(
                                      "statistics/machine/icon_filter_down_${controller.realMachineTypesIdx != -1 ? "selected" : "normal"}_arrow"),
                                  width: 6.w,
                                  fit: BoxFit.fitWidth,
                                );
                              },
                            )
                          ]),
                        ),
                      ),
                      CustomButton(
                        onPressed: () {
                          controller.showSelfFilter(1);
                        },
                        child: SizedBox(
                          width: 375.w / 2 - 0.1.w - 20.w,
                          height: 55.w,
                          child: centRow([
                            GetX<StatisticsMachineEquitiesAddListController>(
                              builder: (_) {
                                return getSimpleText(
                                    controller.realCurrentTypesIdx == -1
                                        ? "按设备状态"
                                        : controller.currentTypes[controller
                                            .realCurrentTypesIdx]["name"],
                                    15,
                                    controller.realCurrentTypesIdx != -1
                                        ? AppColor.text2
                                        : AppColor.text3,
                                    isBold: true);
                              },
                            ),
                            gwb(5),
                            GetX<StatisticsMachineEquitiesAddListController>(
                              builder: (_) {
                                return Image.asset(
                                  assetsName(
                                      "statistics/machine/icon_filter_down_${controller.realCurrentTypesIdx != -1 ? "selected" : "normal"}_arrow"),
                                  width: 6.w,
                                  fit: BoxFit.fitWidth,
                                );
                              },
                            )
                          ]),
                        ),
                      )
                    ]),
                  )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 55.w + paddingSizeBottom(context),
              child: Container(
                padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: const Color(0x0D000000), blurRadius: 5.w)
                ]),
                child: Center(
                  child: controller.toChange
                      ? getSubmitBtn("确认", () {
                          controller.confirmAction();
                        }, height: 45, color: AppColor.theme)
                      : sbhRow([
                          CustomButton(
                            onPressed: () {
                              controller.allSelectAction();
                            },
                            child: SizedBox(
                                height: 55.w,
                                child: GetX<
                                    StatisticsMachineEquitiesAddListController>(
                                  builder: (_) {
                                    return centRow([
                                      Image.asset(
                                        assetsName(
                                            "machine/checkbox_${controller.allselect ? "selected" : "normal"}"),
                                        width: 16.w,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      gwb(15),
                                      getSimpleText(
                                          controller.allselect ? "反选" : "全选",
                                          14,
                                          AppColor.text),
                                    ]);
                                  },
                                )),
                          ),
                          centRow([
                            // Image.asset(
                            //   assetsName("machine/icon_machine_count"),
                            //   width: 18.w,
                            //   fit: BoxFit.fitWidth,
                            // ),
                            // gwb(4),
                            // GetX<StatisticsMachineEquitiesAddListController>(
                            //   builder: (_) {
                            //     return getSimpleText(
                            //         "已选${controller.selectCount}/${controller.maxCount}",
                            //         12,
                            //         AppColor.text);
                            //   },
                            // ),
                            // gwb(10),
                            CustomButton(onPressed: () {
                              controller.confirmAction();
                            }, child: GetX<
                                StatisticsMachineEquitiesAddListController>(
                              builder: (_) {
                                bool enable = controller.selectCount <=
                                    controller.maxCount;
                                return Container(
                                  width: 90.w,
                                  height: 30.w,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.w),
                                      color: enable
                                          ? AppColor.theme
                                          : const Color(0xFFDBDBDB)),
                                  child: Center(
                                      child: getSimpleText(
                                          "确认", 14, Colors.white)),
                                );
                              },
                            ))
                          ]),
                        ], width: 375 - 15 * 2, height: 55),
                ),
              )),
          Positioned.fill(
              top: controller.toChange ? 0 : 55.w,
              bottom: 55.w + paddingSizeBottom(context),
              child: GetBuilder<StatisticsMachineEquitiesAddListController>(
                builder: (_) {
                  return SmartRefresher(
                    physics: const BouncingScrollPhysics(),
                    controller: controller.pullCtrl,
                    onLoading: () => controller.loadMachines(isLoad: true),
                    onRefresh: () => controller.loadMachines(),
                    // enablePullDown: controller.toChange,
                    enablePullUp: controller.count > controller.machines.length,
                    child: controller.machines.isEmpty
                        ? GetX<StatisticsMachineEquitiesAddListController>(
                            builder: (_) {
                              return CustomEmptyView(
                                isLoading: controller.isLoading,
                              );
                            },
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 20.w),
                            itemCount: controller.machines.length,
                            itemBuilder: (context, index) {
                              return machineCell(
                                  index, controller.machines[index]);
                            },
                          ),
                  );
                },
              )),
          GetBuilder<StatisticsMachineEquitiesAddListController>(
              id: controller.filterBuildId,
              builder: (_) {
                return CustomDropDownView(
                    height: controller.filterHeight.w,
                    dropDownCtrl: controller.filterCtrl,
                    dropWidget: Container(
                      width: 375.w,
                      height: controller.filterHeight.w,
                      color: Colors.white,
                      child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: selfFilterView(0)),
                    ));
              }),
          GetBuilder<StatisticsMachineEquitiesAddListController>(
              id: controller.filterBuildId2,
              builder: (_) {
                return CustomDropDownView(
                    height: controller.filterHeight2.w,
                    dropDownCtrl: controller.filterCtrl2,
                    dropWidget: Container(
                      width: 375.w,
                      height: controller.filterHeight2.w,
                      color: Colors.white,
                      child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: selfFilterView(1)),
                    ));
              }),
        ],
      ),
    );
  }

  Widget machineCell(int index, Map data) {
    if (data["selected"] == null) {
      data["selected"] = false;
    }
    return CustomButton(
      onPressed: () {
        // if (controller.toChange) {
        //   data["selected"] = !data["selected"];
        //   controller.checkSelect(setIndex: data["selected"] ? index : null);
        // } else {
        //   data["selected"] = !data["selected"];
        //   controller.checkSelect();
        // }
        data["selected"] = !data["selected"];
        controller.checkSelect();

        controller.update();
      },
      child: Container(
        width: 345.w,
        height: 75.w,
        margin: EdgeInsets.only(top: 15.w),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(3.w)),
        child: Center(
          child: sbhRow([
            centRow([
              Image.asset(
                assetsName(
                    "machine/checkbox_${(data["selected"] ?? false) ? "selected" : "normal"}"),
                width: 16.w,
                fit: BoxFit.fitWidth,
              ),
              gwb(10),
              CustomNetworkImage(
                src: AppDefault().imageUrl + (data["tImg"] ?? ""),
                width: 45.w,
                height: 45.w,
                fit: BoxFit.fill,
              ),
              gwb(10),
              centClm([
                getSimpleText(data["tbName"] ?? "", 15, AppColor.text,
                    isBold: true),
                ghb(5),
                getSimpleText("设备编号：${data["tNo"] ?? ""}", 12, AppColor.text),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ]),
            centRow([
              Container(
                width: 7.5.w,
                height: 7.5.w,
                decoration: BoxDecoration(
                    color: const Color(0xFF3AD3D2),
                    borderRadius: BorderRadius.circular(7.5.w / 2)),
              ),
              gwb(5),
              getSimpleText("${data["tStatus"] ?? ""}", 12, AppColor.text2)
            ])
          ], width: 345 - 13 * 2, height: 75),
        ),
      ),
    );
  }

  showSearch() {
    Get.bottomSheet(Container(
      width: 375.w,
      height: 230.w,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          centClm([
            gwb(375),
            sbhRow([getSimpleText("搜索区间", 15, AppColor.text, isBold: true)],
                height: 55, width: 375 - 15 * 2),
            ...List.generate(2, (int index) {
              return Container(
                width: 345.w,
                height: 40.w,
                margin: EdgeInsets.only(top: index == 1 ? 15.w : 0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: 0.5.w,
                      color: AppColor.lineColor,
                    )),
                child: Row(
                  children: [
                    gwb(15),
                    CustomInput(
                      textEditCtrl: index == 0
                          ? controller.startInputCtrl
                          : controller.endInputCtrl,
                      width: (345 - 15 - 50 - 0.1 - 1).w,
                      heigth: 40.w,
                      placeholder: "请输入${index == 0 ? "开始" : "结束"}设备编号",
                      style: TextStyle(fontSize: 12.sp, color: AppColor.text),
                      placeholderStyle:
                          TextStyle(fontSize: 12.sp, color: AppColor.assisText),
                    ),
                    kIsWeb
                        ? gwb(0)
                        : CustomButton(
                            onPressed: () {
                              toScanBarCode(((barCode) {
                                if (index == 0) {
                                  controller.startInputCtrl.text = barCode;
                                } else {
                                  controller.endInputCtrl.text = barCode;
                                }
                              }));
                            },
                            child: SizedBox(
                              width: 50.w,
                              height: 40.w,
                              child: Center(
                                child: Image.asset(
                                  assetsName("machine/btn_scan_code"),
                                  width: 18.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              );
            }),
          ]),
          Row(
            children: List.generate(
                2,
                (index) => CustomButton(
                      onPressed: () {
                        if (index == 0) {
                          controller.modelSearchReset();
                        } else {
                          controller.modelSearchConfirm();
                        }
                      },
                      child: Container(
                        width: 375.w / 2 - 0.1.w,
                        height: 55.w,
                        color: index == 0
                            ? AppColor.theme.withOpacity(0.1)
                            : AppColor.theme,
                        child: Center(
                          child: getSimpleText(index == 0 ? "重置" : "确定", 15,
                              index == 0 ? AppColor.theme : Colors.white),
                        ),
                      ),
                    )),
          )
        ],
      ),
    ));
  }

  Widget selfFilterView(int idx) {
    List filterDatas = [];
    if (idx == 0) {
      filterDatas = controller.machineTypes;
    } else if (idx == 1) {
      filterDatas = controller.currentTypes;
    }
    return centClm(List.generate(filterDatas.length, (index) {
      return CustomButton(
        onPressed: () {
          if (idx == 0) {
            controller.machineTypesIdx = index;
            controller.realMachineTypesIdx = controller.machineTypesIdx;
          } else if (idx == 1) {
            controller.currentTypesIdx = index;
            controller.realCurrentTypesIdx = controller.currentTypesIdx;
          }
          controller.showSelfFilter(idx);
        },
        child: GetX<StatisticsMachineEquitiesAddListController>(builder: (_) {
          int selectIdx = -1;
          if (idx == 0) {
            selectIdx = controller.realMachineTypesIdx;
          } else {
            selectIdx = controller.realCurrentTypesIdx;
          }
          return sbhRow([
            getSimpleText(filterDatas[index]["name"], 14, AppColor.text2),
            selectIdx == index
                ? Image.asset(
                    assetsName("machine/icon_type_selected"),
                    width: 15.w,
                    fit: BoxFit.fitWidth,
                  )
                : gwb(0)
          ], width: 375 - 15.5 * 2, height: 40);
        }),
      );
    }));
  }
}
