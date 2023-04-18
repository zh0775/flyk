import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineManage/statistics_machine_transfer_history.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatisticsMachineManageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineManageController>(
        StatisticsMachineManageController(datas: Get.arguments));
  }
}

class StatisticsMachineManageController extends GetxController {
  final dynamic datas;
  StatisticsMachineManageController({this.datas});

  TextEditingController searchInputCtrl = TextEditingController();
  RefreshController pullCtrl = RefreshController();

  CustomDropDownController filterCtrl = CustomDropDownController();
  CustomDropDownController filterCtrl2 = CustomDropDownController();

  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();

  int viewType = 0;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _count = 0.obs;
  int get count => _count.value;
  set count(v) => _count.value = v;

  final _filterXhIdx = 0.obs;
  int get filterXhIdx => _filterXhIdx.value;
  set filterXhIdx(v) => _filterXhIdx.value = v;

  int pageSize = 20;
  int pageNo = 1;

  List machineTypes = [];

  final _machineTypesIdx = 0.obs;
  int get machineTypesIdx => _machineTypesIdx.value;
  set machineTypesIdx(v) => _machineTypesIdx.value = v;

  final _realMachineTypesIdx = (-1).obs;
  int get realMachineTypesIdx => _realMachineTypesIdx.value;
  set realMachineTypesIdx(v) => _realMachineTypesIdx.value = v;

  List machineStatus = [
    {"id": 0, "name": "全部"},
    {"id": 1, "name": "在库(可划拨)"},
    {"id": 2, "name": "已绑定"},
    {"id": 3, "name": "已激活"},
    {"id": 4, "name": "未绑定"},
    {"id": 5, "name": "有效激活"},
    {"id": 6, "name": "达标"},
    {"id": 7, "name": "未达标"},
    {"id": 8, "name": "作废"},
  ];

  final _machineStatusIdx = 0.obs;
  int get machineStatusIdx => _machineStatusIdx.value;
  set machineStatusIdx(v) => _machineStatusIdx.value = v;

  final _realMachineStatusIdx = (-1).obs;
  int get realMachineStatusIdx => _realMachineStatusIdx.value;
  set realMachineStatusIdx(v) => _realMachineStatusIdx.value = v;

  List businessLevels = [
    {"id": 0, "name": "全部"},
    {"id": 1, "name": "个人"},
    {"id": 2, "name": "合伙人"},
    {"id": 3, "name": "盘主"},
    {"id": 4, "name": "运营中心"},
  ];

  final _businessLevelsIdx = 0.obs;
  int get businessLevelsIdx => _businessLevelsIdx.value;
  set businessLevelsIdx(v) => _businessLevelsIdx.value = v;

  int realBusinessLevelsIdx = 0;

  List currentTypes = [
    {"id": -1, "name": "全部"},
    {"id": 0, "name": "正常"},
    {"id": 1, "name": "作废"},
    {"id": 2, "name": "达标"},
    {"id": 3, "name": "未达标"},
  ];

  final _currentTypesIdx = 0.obs;
  int get currentTypesIdx => _currentTypesIdx.value;
  set currentTypesIdx(v) => _currentTypesIdx.value = v;

  int realCurrentTypesIdx = 0;

  final _filterHeight = 0.0.obs;
  double get filterHeight => _filterHeight.value;
  set filterHeight(v) => _filterHeight.value = v;

  final _filterHeight2 = 0.0.obs;
  double get filterHeight2 => _filterHeight2.value;
  set filterHeight2(v) => _filterHeight2.value = v;

  final _filterOverSize = false.obs;
  bool get filterOverSize => _filterOverSize.value;
  set filterOverSize(v) => _filterOverSize.value = v;
  double appBarMaxHeight = 0;
  getFilterHeight() {
    if (viewType == 0) {
      filterHeight = 0.0.w;

      if (machineTypes.isNotEmpty) {
        filterHeight += 56.0.w;
        int machineTypesCount = (machineTypes.length / 3).ceil();
        filterHeight += machineTypesCount * 30.0.w;
        filterHeight += (machineTypesCount - 1) * 10.0.w;
      }

      if (machineStatus.isNotEmpty) {
        filterHeight += 56.w;
        int machineStatusCount = (machineStatus.length / 3).ceil();
        filterHeight += machineStatusCount * 30.0.w;
        filterHeight += (machineStatusCount - 1) * 10.0.w;
      }

      if (businessLevels.isNotEmpty) {
        filterHeight += 56.w;
        int businessLevelsCount = (businessLevels.length / 3).ceil();
        filterHeight += businessLevelsCount * 30.0.w;
        filterHeight += (businessLevelsCount - 1) * 10.0.w;
      }

      // filterHeight += 56;
      // int currentTypesCount = (currentTypes.length / 3).ceil();
      // filterHeight += currentTypesCount * 30.0.w;
      // filterHeight += (currentTypesCount - 1) * 10.0.w;

      filterHeight += 19.0.w;
      filterHeight += 55.0.w;
      filterHeight = filterHeight * 1.0;
    } else if (viewType == 1) {
      filterHeight = machineTypes.length * 40.w * 1.0;
      filterHeight2 = machineStatus.length * 40.w * 1.0;
    }

    double maxHeight = ScreenUtil().screenHeight -
        appBarMaxHeight -
        105.w -
        paddingSizeBottom(Global.navigatorKey.currentContext!);
    filterOverSize = filterHeight > maxHeight;
    if (filterHeight > maxHeight) {
      filterHeight = maxHeight * 1.0;
    }
    if (viewType == 1) {
      if (filterHeight2 > maxHeight) {
        filterHeight2 = maxHeight * 1.0;
      }
    }
  }

  showSelfFilter(int idx) {
    if (filterCtrl.isShow) {
      filterCtrl.hide();
      loadDatas();
      return;
    }
    if (filterCtrl2.isShow) {
      filterCtrl2.hide();
      loadDatas();
      return;
    }
    idx == 0
        ? filterCtrl.show(stackKey, headKey)
        : filterCtrl2.show(stackKey, headKey);
  }

  filterSearchReset() {
    realBusinessLevelsIdx = 0;
    realCurrentTypesIdx = 0;
    realMachineStatusIdx = 0;
    realMachineTypesIdx = 0;
    businessLevelsIdx = 0;
    currentTypesIdx = 0;
    machineStatusIdx = 0;
    machineTypesIdx = 0;
  }

  filterSearchConfirm() {
    showFilter();
    realBusinessLevelsIdx = businessLevelsIdx;
    realCurrentTypesIdx = currentTypesIdx;
    realMachineStatusIdx = machineStatusIdx;
    realMachineTypesIdx = machineTypesIdx;
    loadDatas();
  }

  searchAction() {
    loadDatas();
  }

  onRefresh() {
    loadDatas();
  }

  onLoad() {
    loadDatas(isLoad: true);
  }

  Map publicHomeData = {};
  List dataList = [];
  List xhList = [];

  showFilter() {
    if (filterCtrl.isShow) {
      filterCtrl.hide();
    } else {
      filterCtrl.show(stackKey, headKey);
    }
  }

  loadDatas({bool isLoad = false, String? start, String? end, int? loadIdx}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "status":
          machineStatus[realMachineStatusIdx < 0 ? 0 : realMachineStatusIdx]
              ["id"],
      "pageNo": pageNo,
      "pageSize": pageSize,
      "teamType": viewType == 0 ? 1 : 0,
      "terminalModel": -1,
      "terminalBrandId": -1,
      "levelType": businessLevels[realBusinessLevelsIdx]["id"],
      "tId": machineTypes[realMachineTypesIdx < 0 ? 0 : realMachineTypesIdx]
          ["id"],
    };
    if (start != null && start.isNotEmpty) {
      params["terminal_Start"] = start;
    }
    if (end != null && end.isNotEmpty) {
      params["terminal_End"] = end;
    }

    if (searchInputCtrl.text.isNotEmpty) {
      params["terminalNo"] = searchInputCtrl.text;
    }

    simpleRequest(
      url: Urls.userPersonTerminalHighList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List dList = data["data"] ?? [];
          // List.generate(dList.length, (index) {
          //   Map e = dList[index];
          //   return {...e, "open": false};
          // });

          if (dataList.isEmpty && !isLoad && dList.isNotEmpty) {
            dList[0]["open"] = true;
          }

          dataList = isLoad ? [...dataList, ...dList] : dList;
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
  }

  dynamic otherCtrl;

  @override
  void onInit() {
    viewType = datas["type"] ?? 0;
    otherCtrl = datas["controller"];
    publicHomeData = AppDefault().publicHomeData;

    machineTypes = [
      {
        "id": -1,
        "name": "全部",
      }
    ];

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
      // machineTypes = (publicHomeData["terminalConfig"] as List)
      //     .map((e) => {...e, "selected": false})
      //     .toList();
    }
    // getFilterHeight();
    loadDatas();

    super.onInit();
  }

  @override
  void onClose() {
    searchInputCtrl.dispose();
    filterCtrl.dispose();
    filterCtrl2.dispose();
    super.onClose();
  }
}

class StatisticsMachineManage
    extends GetView<StatisticsMachineManageController> {
  const StatisticsMachineManage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(
            context, controller.viewType == 0 ? "设备管理" : "我的机具"),
        body: Builder(builder: (context) {
          controller.appBarMaxHeight =
              (Scaffold.of(context).appBarMaxHeight ?? 0);
          controller.getFilterHeight();
          return Stack(key: controller.stackKey, children: [
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 55.w,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      gwb(375),
                      ghb(5.5),
                      Container(
                        width: 345.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                            color: AppColor.pageBackgroundColor,
                            borderRadius: BorderRadius.circular(20.w)),
                        child: Row(
                          children: [
                            gwb(20),
                            CustomInput(
                              textEditCtrl: controller.searchInputCtrl,
                              width: (345 - 20 - 62 - 1 - 0.1).w,
                              heigth: 40.w,
                              placeholder: "请输入想要搜索的设备编号",
                              placeholderStyle: TextStyle(
                                  fontSize: 12.sp, color: AppColor.assisText),
                              style: TextStyle(
                                  fontSize: 12.sp, color: AppColor.text),
                            ),
                            CustomButton(
                              onPressed: () {
                                takeBackKeyboard(context);
                                controller.searchAction();
                              },
                              child: SizedBox(
                                width: 62.w,
                                height: 40.w,
                                child: Center(
                                  child: Image.asset(
                                    assetsName("machine/icon_search"),
                                    width: 18.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )),
            Positioned(
                top: 55.w,
                left: 0,
                right: 0,
                height: 50.w,
                key: controller.viewType == 0 ? controller.headKey : null,
                child: Container(
                  width: 375.w,
                  height: 50.w,
                  color: Colors.white,
                  child: Center(
                      child: sbhRow([
                    GetX<StatisticsMachineManageController>(
                      builder: (_) {
                        return getSimpleText(
                            "${controller.viewType == 0 ? "团队" : "我的"}设备总数：${controller.count}台",
                            15,
                            AppColor.text);
                      },
                    ),
                    controller.viewType == 0
                        ? CustomButton(
                            onPressed: () {
                              controller.showFilter();
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: centRow([
                                Image.asset(
                                  assetsName("common/btn_filter"),
                                  width: 22.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                gwb(3),
                                getSimpleText("筛选", 14, AppColor.text2),
                              ]),
                            ),
                          )
                        : gwb(0)
                  ], width: 375 - 15 * 2, height: 50)),
                )),
            controller.viewType == 0
                ? gemp()
                : Positioned(
                    top: 106.w,
                    left: 0,
                    right: 0,
                    height: 50.w,
                    key: controller.viewType == 0 ? null : controller.headKey,
                    child: Container(
                      color: Colors.white,
                      child: centRow([
                        CustomButton(
                          onPressed: () {
                            controller.showSelfFilter(0);
                          },
                          child: SizedBox(
                            width: 375.w / 2 - 0.1.w - 20.w,
                            height: 50.w,
                            child: centRow([
                              GetX<StatisticsMachineManageController>(
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
                              GetX<StatisticsMachineManageController>(
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
                            height: 50.w,
                            child: centRow([
                              GetX<StatisticsMachineManageController>(
                                builder: (_) {
                                  return getSimpleText(
                                      controller.realMachineStatusIdx == -1
                                          ? "按状态"
                                          : controller.machineStatus[controller
                                              .realMachineStatusIdx]["name"],
                                      15,
                                      controller.realMachineStatusIdx != -1
                                          ? AppColor.text2
                                          : AppColor.text3,
                                      isBold: true);
                                },
                              ),
                              gwb(5),
                              GetX<StatisticsMachineManageController>(
                                builder: (_) {
                                  return Image.asset(
                                    assetsName(
                                        "statistics/machine/icon_filter_down_${controller.realMachineStatusIdx != -1 ? "selected" : "normal"}_arrow"),
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
            Positioned.fill(
                top: 55.w + 50.w + (controller.viewType == 0 ? 0 : 51.w),
                child: GetBuilder<StatisticsMachineManageController>(
                  builder: (_) {
                    return SmartRefresher(
                      controller: controller.pullCtrl,
                      onLoading: controller.onLoad,
                      onRefresh: controller.onRefresh,
                      enablePullUp:
                          controller.count > controller.dataList.length,
                      child: controller.dataList.isEmpty
                          ? GetX<StatisticsMachineManageController>(
                              builder: (_) {
                                return CustomEmptyView(
                                  isLoading: controller.isLoading,
                                );
                              },
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: 20.w),
                              itemCount: controller.dataList.length,
                              itemBuilder: (context, index) {
                                return machineCell(
                                    index, controller.dataList[index]);
                              },
                            ),
                    );
                  },
                )),
            GetX<StatisticsMachineManageController>(builder: (_) {
              return CustomDropDownView(
                dropDownCtrl: controller.filterCtrl,
                height: controller.filterHeight,
                dropWidget: Container(
                  height: controller.filterHeight,
                  width: 375.w,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                        height: controller.filterHeight,
                        child: controller.viewType == 0
                            ? teamFilterView()
                            : selfFilterView(0)),
                  ),
                ),
              );
            }),
            GetX<StatisticsMachineManageController>(builder: (_) {
              return CustomDropDownView(
                dropDownCtrl: controller.filterCtrl2,
                height: controller.filterHeight2,
                dropWidget: Container(
                  height: controller.filterHeight2,
                  width: 375.w,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    physics: controller.filterOverSize
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                        height: controller.filterHeight2,
                        child: selfFilterView(1)),
                  ),
                ),
              );
            }),
          ]);
        }),
      ),
    );
  }

  Widget selfFilterView(int idx) {
    List filterDatas = [];
    if (idx == 0) {
      filterDatas = controller.machineTypes;
    } else if (idx == 1) {
      filterDatas = controller.machineStatus;
    }

    return centClm(List.generate(filterDatas.length, (index) {
      return CustomButton(
        onPressed: () {
          if (idx == 0) {
            controller.machineTypesIdx = index;
            controller.realMachineTypesIdx = controller.machineTypesIdx;
          } else if (idx == 1) {
            controller.machineStatusIdx = index;
            controller.realMachineStatusIdx = controller.machineStatusIdx;
          }
          controller.showSelfFilter(idx);
        },
        child: GetX<StatisticsMachineManageController>(builder: (context) {
          int selectIdx = -1;
          if (idx == 0) {
            selectIdx = controller.realMachineTypesIdx;
          } else {
            selectIdx = controller.realMachineStatusIdx;
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

  Widget teamFilterView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 375.w,
          height: controller.filterHeight - 55.w,
          child: SingleChildScrollView(
              physics: controller.filterOverSize
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  gwb(375),
                  filterTitle("设备类型"),
                  GetX<StatisticsMachineManageController>(
                    builder: (_) {
                      return filters(
                        controller.machineTypes,
                        controller.machineTypesIdx,
                        onPressed: (index) {
                          controller.machineTypesIdx = index;
                        },
                      );
                    },
                  ),
                  filterTitle("设备状态"),
                  GetX<StatisticsMachineManageController>(
                    builder: (_) {
                      return filters(
                        controller.machineStatus,
                        controller.machineStatusIdx,
                        onPressed: (index) {
                          controller.machineStatusIdx = index;
                        },
                      );
                    },
                  ),
                  filterTitle("所属商户等级"),
                  GetX<StatisticsMachineManageController>(
                    builder: (_) {
                      return filters(
                        controller.businessLevels,
                        controller.businessLevelsIdx,
                        onPressed: (index) {
                          controller.businessLevelsIdx = index;
                        },
                      );
                    },
                  ),
                  // filterTitle("当前状态"),
                  // GetX<StatisticsMachineManageController>(
                  //   builder: (_) {
                  //     return filters(
                  //       controller.currentTypes,
                  //       controller.currentTypesIdx,
                  //       onPressed: (index) {
                  //         controller.currentTypesIdx = index;
                  //       },
                  //     );
                  //   },
                  // ),
                  ghb(controller.filterOverSize ? 19 : 0),
                ],
              )),
        ),
        Row(
          children: List.generate(
              2,
              (index) => CustomButton(
                    onPressed: () {
                      if (index == 0) {
                        controller.filterSearchReset();
                      } else {
                        controller.filterSearchConfirm();
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
    );
  }

  Widget machineCell(int index, Map data) {
    if (data["open"] == null) {
      data["open"] = false;
    }
    bool open = data["open"] ?? false;
    bool normal = (data["isBinding"] ?? -1) == 0;

    return CustomButton(
      onPressed: () {
        if (controller.otherCtrl != null &&
            controller.otherCtrl.setMachine != null) {
          controller.otherCtrl.setMachine(data);
          Get.back();
        }
      },
      child: Align(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 345.w,
          margin: EdgeInsets.only(top: 15.w),
          height: controller.viewType == 0
              ? (open ? 255.w - (normal ? 23.w * 3 : 0) : 120.w)
              : 210.w - (normal ? 88.5.w : 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sbhRow([
                  centRow([
                    CustomNetworkImage(
                      src: AppDefault().imageUrl + (data["tImg"] ?? ""),
                      width: 45.w,
                      height: 45.w,
                      fit: BoxFit.fill,
                    ),
                    gwb(9),
                    centClm([
                      getSimpleText(data["tbName"] ?? "", 15, AppColor.text2,
                          isBold: true),
                      ghb(6),
                      getSimpleText(
                          "设备编号：${data["tNo"] ?? ""}", 12, AppColor.text3),
                    ], crossAxisAlignment: CrossAxisAlignment.start)
                  ]),
                  controller.viewType == 0
                      ? centClm([
                          centRow([
                            Container(
                              width: 7.5.w,
                              height: 7.5.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3AD3D2),
                                borderRadius: BorderRadius.circular(7.5.w / 2),
                              ),
                            ),
                            gwb(5),
                            getSimpleText(
                                data["tStatus"] ?? "", 12, AppColor.text2),
                          ]),
                          CustomButton(
                            onPressed: () {
                              data["open"] = !data["open"];
                              controller.update();
                            },
                            child: SizedBox(
                              width: 50.w,
                              height: 40.w,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  assetsName(
                                      "statistics/machine/icon_listpull"),
                                  width: 18.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          )
                        ], crossAxisAlignment: CrossAxisAlignment.end)
                      : centRow([
                          Container(
                            width: 7.5.w,
                            height: 7.5.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3AD3D2),
                              borderRadius: BorderRadius.circular(7.5.w / 2),
                            ),
                          ),
                          gwb(5),
                          getSimpleText(
                              data["tStatus"] ?? "", 12, AppColor.text2),
                        ]),
                ],
                    width: 345 - 15 * 2,
                    height: 75,
                    crossAxisAlignment: CrossAxisAlignment.start),
                controller.viewType == 0
                    ? ghb(0)
                    : normal
                        ? ghb(0)
                        : gline(315, 0.5),
                controller.viewType == 0
                    ? AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 315.w,
                        height: open ? 135.w - (normal ? 23.w * 3 : 0) : 0,
                        decoration: BoxDecoration(
                            color: AppColor.pageBackgroundColor,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 135.w - (normal ? 23.w * 3 : 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(normal ? 2 : 5, (index) {
                                String title = "";
                                String t2 = "";
                                switch (index) {
                                  case 0:
                                    title = "当前所属人";
                                    t2 = data["uName"] ?? "";
                                    break;
                                  case 1:
                                    title = "所属人身份";
                                    t2 = data["uLevelName"] ?? "";
                                    break;
                                  case 2:
                                    title = "绑定时间";
                                    t2 = data["bindingTime"] ?? "";
                                    break;
                                  case 3:
                                    title = "激活时间";
                                    t2 = data["activaTime"] ?? "";
                                    break;
                                  case 4:
                                    {
                                      String valid = "";
                                      final dateFormat =
                                          DateFormat("yyyy/MM/dd HH:mm:ss");
                                      if (data["bindingTime"] != null &&
                                          data["bindingTime"].isNotEmpty &&
                                          data["activaDay"] != null &&
                                          data["activaDay"] is int) {
                                        DateTime vDate = dateFormat
                                            .parse(data["bindingTime"])
                                            .add(Duration(
                                                days: data["activaDay"]));
                                        valid = dateFormat.format(vDate);
                                      }
                                      title = "有效激活时间";
                                      t2 = valid;
                                    }

                                    break;
                                }
                                return sbhRow([
                                  getSimpleText(title, 12, AppColor.text3),
                                  centRow([
                                    index == 1
                                        ? Image.asset(
                                            assetsName(
                                                "mine/vip/level${data["uL_Level"]}"),
                                            width: 31.5.w,
                                            fit: BoxFit.fitWidth,
                                          )
                                        : gwb(0),
                                    getSimpleText(
                                        t2,
                                        index == 1 ? 10 : 12,
                                        index == 1
                                            ? const Color(0xFFBB5D10)
                                            : AppColor.text2),
                                  ])
                                ], width: 315 - 15 * 2, height: 23);
                              }),
                            ),
                          ),
                        ),
                      )
                    : normal
                        ? ghb(0)
                        : SizedBox(
                            height: 88.5.w,
                            child: centClm([
                              ...List.generate(3, (index) {
                                String title = "";
                                String t2 = "";
                                switch (index) {
                                  case 0:
                                    title = "绑定时间";
                                    t2 = data["bindingTime"] ?? "";
                                    break;
                                  case 1:
                                    title = "激活时间";
                                    t2 = data["activaTime"] ?? "";
                                    break;
                                  case 2:
                                    {
                                      String valid = "";
                                      final dateFormat =
                                          DateFormat("yyyy/MM/dd HH:mm:ss");
                                      if (data["bindingTime"] != null &&
                                          data["bindingTime"].isNotEmpty &&
                                          data["activaDay"] != null &&
                                          data["activaDay"] is int) {
                                        DateTime vDate = dateFormat
                                            .parse(data["bindingTime"])
                                            .add(Duration(
                                                days: data["activaDay"]));
                                        valid = dateFormat.format(vDate);
                                      }
                                      title = "有效激活时间";
                                      t2 = valid;
                                    }
                                    break;
                                }
                                return sbhRow([
                                  getSimpleText(title, 12, AppColor.text3),
                                  centRow([
                                    getSimpleText(t2, 12, AppColor.text2),
                                  ])
                                ], width: 315, height: 25);
                              })
                            ]),
                          ),
                centClm([
                  gline(315, 0.5),
                  CustomButton(
                    onPressed: () {
                      if (controller.viewType == 0) {
                        push(const StatisticsMachineTransferHistory(), null,
                            binding: StatisticsMachineTransferHistoryBinding(),
                            arguments: {
                              "machineData": data,
                            });
                      } else if (controller.viewType == 1) {
                        showMachineInfo(data);
                      }
                    },
                    child: SizedBox(
                      height: 44.w,
                      width: 345.w,
                      child: centRow([
                        Image.asset(
                          assetsName("statistics/machine/icon_arrow_right"),
                          width: 18.w,
                          fit: BoxFit.fitWidth,
                        ),
                        gwb(3),
                        getSimpleText(
                            controller.viewType == 0 ? "查看划拨记录" : "查看设备信息",
                            12,
                            AppColor.text2),
                      ]),
                    ),
                  )
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget filters(List list, int index, {Function(int index)? onPressed}) {
    return Wrap(
      runSpacing: 10.w,
      spacing: 15.w,
      children: List.generate(
          list.length,
          (idx) => CustomButton(
                onPressed: () {
                  if (onPressed != null) {
                    onPressed(idx);
                  }
                },
                child: Container(
                  width: 105.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.w),
                      color: idx == index
                          ? AppColor.theme
                          : AppColor.theme.withOpacity(0.1)),
                  child: Center(
                    child: getSimpleText(list[idx]["name"], 12,
                        idx == index ? Colors.white : AppColor.text2),
                  ),
                ),
              )),
    );
  }

  Widget filterTitle(String text) {
    return sbhRow([
      getSimpleText(text, 15, AppColor.text, isBold: true),
    ], width: 375 - 15 * 2, height: 56);
  }

  showMachineInfo(Map data) {
    bool normal = (data["isBinding"] ?? -1) == 0;
    Get.bottomSheet(
      Container(
        width: 375.w,
        height: 330.w -
            (normal ? 95.w : 0) +
            paddingSizeBottom(Global.navigatorKey.currentContext!),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
        child: Column(
          children: [
            gwb(375),
            sbhRow([
              gwb(42),
              getSimpleText("设备信息", 18, AppColor.text, isBold: true),
              CustomButton(
                onPressed: () {
                  Get.back();
                },
                child: SizedBox(
                  width: 42.w,
                  height: 48.w,
                  child: Center(
                    child: Image.asset(
                      assetsName("statistics/machine/btn_model_close"),
                      width: 18.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              )
            ], width: 375, height: 48),
            ghb(5),
            gline(375, 1),
            SizedBox(
              height: 112.5.w,
              child: centClm([
                ghb(5),
                sbRow([
                  centClm([
                    getSimpleText(data["tbName"] ?? "", 15, AppColor.text2,
                        isBold: true),
                    ghb(11),
                    CustomButton(
                      onPressed: () {
                        copyClipboard(data["tNo"] ?? "");
                      },
                      child: getSimpleText(
                          "设备编号：${data["tNo"] ?? ""}", 12, AppColor.text3),
                    ),
                    ghb(9),
                    getSimpleText(
                        "设备状态：${data["tStatus"] ?? ""}", 12, AppColor.text3)
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  CustomNetworkImage(
                    src: AppDefault().imageUrl + (data["tImg"] ?? ""),
                    width: 45.w,
                    height: 45.w,
                    fit: BoxFit.fill,
                  )
                ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    width: 345 - 15 * 2),
              ]),
            ),
            normal ? ghb(0) : gline(315, 0.5),
            normal
                ? ghb(0)
                : SizedBox(
                    height: 95.w,
                    child: centClm(
                      List.generate(3, (index) {
                        String title = "";
                        String t2 = "";
                        switch (index) {
                          case 0:
                            title = "绑定时间";
                            t2 = data["bindingTime"] ?? "";
                            break;
                          case 1:
                            title = "激活时间";
                            t2 = data["activaTime"] ?? "";
                            break;
                          case 2:
                            {
                              String valid = "";
                              final dateFormat =
                                  DateFormat("yyyy/MM/dd HH:mm:ss");
                              if (data["bindingTime"] != null &&
                                  data["bindingTime"].isNotEmpty &&
                                  data["activaDay"] != null &&
                                  data["activaDay"] is int) {
                                DateTime vDate = dateFormat
                                    .parse(data["bindingTime"])
                                    .add(Duration(days: data["activaDay"]));
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
                    ),
                  ),
            ghb(8),
            getSubmitBtn("确定", () {
              Get.back();
            }, color: AppColor.theme, width: 345, height: 45),
          ],
        ),
      ),
    );
  }
}
