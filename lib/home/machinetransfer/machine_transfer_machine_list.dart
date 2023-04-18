import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineTransferMachineListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferMachineListController>(
        MachineTransferMachineListController());
  }
}

class MachineTransferMachineListController extends GetxController {
  final _isLoading = true.obs;
  set isLoading(value) => _isLoading.value = value;
  bool get isLoading => _isLoading.value;

  final _topIdx = 0.obs;
  set topIdx(value) => _topIdx.value = value;
  get topIdx => _topIdx.value;

  final _terminalBrandId = 0.obs;
  set terminalBrandId(value) => _terminalBrandId.value = value;
  get terminalBrandId => _terminalBrandId.value;

  final _status = RxInt(0);
  set status(value) => _status.value = value;
  get status => _status.value;

  final RxInt _policy = RxInt(-1);
  set policy(value) => _policy.value = value;
  get policy => _policy.value;

  // final _terminalNo = "".obs;
  // set terminalNo(value) => _terminalNo.value = value;
  // get terminalNo => _terminalNo.value;

  final _pageSize = 20.obs;
  set pageSize(value) => _pageSize.value = value;
  get pageSize => _pageSize.value;

  final _pageNo = 1.obs;
  set pageNo(value) => _pageNo.value = value;
  get pageNo => _pageNo.value;

  final _machineList = Rx<List>([]);
  set machineList(value) => _machineList.value = value;
  List get machineList => _machineList.value;

  final _searchMachineList = Rx<List>([]);
  set searchMachineList(value) => _searchMachineList.value = value;
  List get searchMachineList => _searchMachineList.value;

  final _quickSearchCount = 1.obs;
  set quickSearchCount(value) {
    if (value < 1) return;
    quickCountTextCtrl.text = "$value";
    _quickSearchCount.value = value;
  }

  get quickSearchCount => _quickSearchCount.value;

  final normalSearchTextCtrl = TextEditingController();
  final startSearchTextCtrl = TextEditingController();
  final endSearchTextCtrl = TextEditingController();
  final quickSearchTextCtrl = TextEditingController();
  final quickCountTextCtrl = TextEditingController();

  List policyList = [
    {"id": -1, "name": "政策筛选"},
    {"id": 0, "name": "政策1"},
    {"id": 1, "name": "政策2"},
    {"id": 2, "name": "政策3"},
  ];

  List statusList = [
    {"id": 0, "name": "全部"},
    {"id": 1, "name": "未绑定"},
    {"id": 2, "name": "已绑定"},
    // {"id": 3, "name": "划拨中"},
  ];

  final _policyIndex = 0.obs;
  set policyIndex(value) => _policyIndex.value = value;
  get policyIndex => _policyIndex.value;

  final _statusIndex = 0.obs;
  set statusIndex(value) => _statusIndex.value = value;
  get statusIndex => _statusIndex.value;

  final _currentCount = 0.obs;
  set currentCount(value) => _currentCount.value = value;
  get currentCount => _currentCount.value;

  final pullCtrl = RefreshController();

  final _isAllSelected = false.obs;
  set isAllSelected(value) => _isAllSelected.value = value;
  get isAllSelected => _isAllSelected.value;

  final _searchButtonIdx = 0.obs;
  int get searchButtonIdx => _searchButtonIdx.value;
  set searchButtonIdx(v) => _searchButtonIdx.value = v;

  onRefresh() async {
    getMachineList();
  }

  onLoad() async {
    getMachineList(isLoad: true);
  }

  bool isFirst = true;

  Map brandData = {};

  loadMachineListRequest(Map? data) {
    brandData = data ?? {};
    if (data != null && data["enumValue"] != null) {
      terminalBrandId = data["enumValue"];
      if (isFirst) {
        isFirst = false;
        getMachineList();
      }
    }
  }

  int selectedCount = 0;

  void checkAllSelected() {
    bool t = true;
    int count = 0;
    for (var e in machineList) {
      if (!e["selected"] &&
          (e["checkStatus"] == null || (e["checkStatus"] ?? "") != "nocheck")) {
        t = false;
      } else {
        count++;
      }
    }
    isAllSelected = t;
    selectedCount = count;
  }

  selectedAndUnSelectedAll(bool selected) {
    for (var e in machineList) {
      e["selected"] = selected;
      if ((e["checkStatus"] ?? "") == "nocheck") {
        e["selected"] = false;
      }
    }
    selectedCount = selected ? machineList.length : 0;
    isAllSelected = selected;
    update();
  }

  updateSelectButtons() {
    checkAllSelected();
    update();
  }

  getMachineList({
    bool isLoad = false,
    int? dataSize,
  }) {
    if (isLoad) {
      pageNo++;
    } else {
      pageNo = 1;
    }

    pageSize = dataSize ?? 20;

    Map<String, dynamic> params = {
      "terminalBrandId": terminalBrandId,
      // "terminalBrandId": -1,
      "teamType": 0,
      "status": status,
      "terminalModel": -1,
      // "policy": policy,
      "pageSize": pageSize,
      "pageNo": pageNo
    };
    if (topIdx == 0) {
      if (normalSearchTextCtrl.text.isNotEmpty && searchButtonIdx == 0) {
        params["terminalNo"] = normalSearchTextCtrl.text;
      }
      if (startSearchTextCtrl.text.isNotEmpty && searchButtonIdx == 1) {
        params["terminal_Start"] = startSearchTextCtrl.text;
      }
      if (endSearchTextCtrl.text.isNotEmpty && searchButtonIdx == 1) {
        params["terminal_End"] = endSearchTextCtrl.text;
      }
    } else {
      params["terminalNo"] = quickSearchTextCtrl.text;
    }

    simpleRequest(
      url: Urls.userPersonTerminalHighList,
      params: params,
      success: (success, json) {
        if (success) {
          final data = json["data"];
          if (topIdx == 1) {
            searchMachineList = data["data"];
          } else {
            if (data["data"] != null && data["data"].isNotEmpty) {
              machineList = (isLoad
                  ? machineList = [
                      ...machineList,
                      ...(data["data"] as List).map((e) {
                        e["selected"] = false;
                        return e;
                      }).toList()
                    ]
                  : (data["data"] as List).map((e) {
                      e["selected"] = false;
                      return e;
                    }).toList());
            }
            isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          }
          updateSelectButtons();
          currentCount = data["count"] ?? 0;
        } else {
          if (isLoad) {
            pullCtrl.loadFailed();
          } else {
            pullCtrl.refreshFailed();
          }
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  @override
  void onInit() {
    quickCountTextCtrl.text = "$quickSearchCount";
    super.onInit();
  }

  @override
  void onClose() {
    normalSearchTextCtrl.dispose();
    startSearchTextCtrl.dispose();
    endSearchTextCtrl.dispose();
    quickSearchTextCtrl.dispose();
    quickCountTextCtrl.dispose();
    pullCtrl.dispose();
    super.onClose();
  }
}

class MachineTransferMachineList
    extends GetView<MachineTransferMachineListController> {
  final Map? brandData;
  const MachineTransferMachineList({Key? key, this.brandData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.loadMachineListRequest(brandData);
    return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: defaultBackButton(context),
            title: Container(
              width: 170.w,
              height: 34.w,
              decoration: BoxDecoration(
                  color: AppColor.pageBackgroundColor,
                  borderRadius: BorderRadius.circular(6.w)),
              child: Center(
                child: GetX<MachineTransferMachineListController>(
                  init: controller,
                  builder: (controller) {
                    return centRow([topButton(0), topButton(1)]);
                  },
                ),
              ),
            ),
            actions: [
              CustomButton(
                onPressed: () {
                  showSearchModel(context);
                },
                child: SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: Center(
                    child: Image.asset(
                      assetsName("home/machinetransfer/btn_search"),
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: getInputSubmitBody(
            context,
            "确定",
            onPressed: () {
              if (controller.topIdx == 0) {
                List machines = [];
                for (var item in controller.machineList) {
                  if (item["selected"]) {
                    machines.add(item);
                  }
                }
                if (machines.isEmpty) {
                  showAlert(
                    context,
                    "没有选择机具，确定返回吗？",
                    confirmOnPressed: () {
                      Get.until((route) {
                        if (route is GetPageRoute) {
                          if (route.binding is MachineTransferBinding) {
                            return true;
                          } else {
                            return false;
                          }
                        } else {
                          return false;
                        }
                      });
                    },
                  );
                } else {
                  Get.until((route) {
                    if ((route as GetPageRoute).binding
                        is MachineTransferBinding) {
                      Get.find<MachineTransferController>().selectMachineData =
                          machines;
                      return true;
                    }
                    return false;
                  });
                }
              } else {
                if (controller.searchMachineList.isEmpty) {
                  showAlert(
                    context,
                    "没有搜索到机具，确定返回吗？",
                    confirmOnPressed: () {
                      Get.until((route) {
                        if (route is GetPageRoute) {
                          if (route.binding is MachineTransferBinding) {
                            return true;
                          } else {
                            return false;
                          }
                        } else {
                          return false;
                        }
                      });
                    },
                  );
                } else {
                  Get.until((route) {
                    if ((route as GetPageRoute).binding
                        is MachineTransferBinding) {
                      Get.find<MachineTransferController>().selectMachineData =
                          controller.searchMachineList;
                      return true;
                    }
                    return false;
                  });
                }
              }
            },
            build: (boxHeight, context) {
              return SingleChildScrollView(
                child: GetX<MachineTransferMachineListController>(
                  init: controller,
                  builder: (_) {
                    return controller.topIdx == 0
                        ? Column(
                            children: [
                              SizedBox(
                                width: 375.w,
                                height: boxHeight,
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        height: 50.w,
                                        child: Container(
                                          color: Colors.white,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: sbhRow([
                                              ...controller.statusList
                                                  .asMap()
                                                  .entries
                                                  .map((e) => GetX<
                                                          MachineTransferMachineListController>(
                                                        init: controller,
                                                        builder: (controller) {
                                                          return CustomButton(
                                                            onPressed: () {
                                                              controller
                                                                      .statusIndex =
                                                                  e.key;
                                                              controller
                                                                  .status = controller
                                                                      .statusList[
                                                                  e.key]["id"];
                                                              controller
                                                                  .getMachineList();
                                                            },
                                                            child: SizedBox(
                                                              width: 68.75.w,
                                                              height: 50.w,
                                                              child: Center(
                                                                child: getSimpleText(
                                                                    e.value[
                                                                        "name"],
                                                                    15,
                                                                    controller.statusIndex ==
                                                                            e
                                                                                .key
                                                                        ? AppDefault().getThemeColor() ??
                                                                            AppColor
                                                                                .buttonTextBlue
                                                                        : const Color(
                                                                            0xFFB3B3B3)),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ))
                                                  .toList()
                                              // ], width: 375, height: 50),
                                            ],
                                                width: 68.75 *
                                                        controller
                                                            .statusList.length +
                                                    0.1,
                                                height: 50),
                                          ),
                                        )),
                                    Positioned(
                                        top: 50.w,
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                height: 54.w,
                                                child: Align(
                                                  child: sbhRow([
                                                    Text.rich(TextSpan(
                                                        text:
                                                            "${controller.brandData["enumName"]}-${controller.statusList[controller.statusIndex]["name"]}库存：",
                                                        style: TextStyle(
                                                            fontSize: 15.sp,
                                                            color: AppColor
                                                                .textBlack),
                                                        children: [
                                                          TextSpan(
                                                              text:
                                                                  "${controller.currentCount}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.sp,
                                                                  color: const Color(
                                                                      0xFFEB5757))),
                                                          TextSpan(
                                                              text: "台",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.sp,
                                                                  color: AppColor
                                                                      .textBlack)),
                                                        ]))
                                                  ], width: 375 - 14.5 * 2),
                                                )),
                                            Positioned(
                                                top: 54.w,
                                                left: 0,
                                                right: 0,
                                                bottom: 0,
                                                child: controller
                                                            .currentCount ==
                                                        0
                                                    ? GetX<
                                                        MachineTransferMachineListController>(
                                                        builder: (controller) {
                                                          return CustomEmptyView(
                                                            isLoading:
                                                                controller
                                                                    .isLoading,
                                                          );
                                                        },
                                                      )
                                                    : GetX<
                                                        MachineTransferMachineListController>(
                                                        init: controller,
                                                        initState: (_) {},
                                                        builder: (_) {
                                                          return SmartRefresher(
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            controller:
                                                                controller
                                                                    .pullCtrl,
                                                            enablePullDown:
                                                                true,
                                                            enablePullUp: controller
                                                                    .machineList
                                                                    .length <
                                                                controller
                                                                    .currentCount,
                                                            onRefresh:
                                                                controller
                                                                    .onRefresh,
                                                            onLoading:
                                                                controller
                                                                    .onLoad,
                                                            child: ListView
                                                                .builder(
                                                              itemCount: controller
                                                                      .machineList
                                                                      .isNotEmpty
                                                                  ? controller
                                                                          .machineList
                                                                          .length +
                                                                      1
                                                                  : 1,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return index ==
                                                                        0
                                                                    ? Container(
                                                                        height:
                                                                            45.w,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            border: Border(bottom: BorderSide(width: 0.5.w, color: const Color(0xFFEBEBEB)))),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              gwb(15),
                                                                              SizedBox(
                                                                                width: 252.w + (controller.statusIndex == 3 ? (375 - 15 - 252 - 66).w : 0),
                                                                                child: Align(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: getSimpleText("机具编号（SN号）", 14, const Color(0xFF808080)),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 66.w,
                                                                                child: Align(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: getSimpleText("状态", 14, const Color(0xFF808080)),
                                                                                ),
                                                                              ),
                                                                              GetX<MachineTransferMachineListController>(
                                                                                init: controller,
                                                                                builder: (_) {
                                                                                  return controller.statusIndex == 3
                                                                                      ? const SizedBox()
                                                                                      : CustomButton(
                                                                                          onPressed: () {
                                                                                            controller.selectedAndUnSelectedAll(!controller.isAllSelected);
                                                                                          },
                                                                                          child: SizedBox(
                                                                                            width: (375 - 15 - 252 - 66).w,
                                                                                            child: Align(
                                                                                              alignment: Alignment.centerLeft,
                                                                                              child: getSimpleText(controller.isAllSelected ? "反选" : "全选", 14, AppDefault().getThemeColor() ?? AppColor.buttonTextBlue),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                },
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        width:
                                                                            375.w,
                                                                        height:
                                                                            60.w,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            border: Border(bottom: BorderSide(width: 0.5.w, color: const Color(0xFFEBEBEB)))),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              gwb(15),
                                                                              CustomButton(
                                                                                onPressed: () {
                                                                                  showSnNoModel(context, controller.machineList[index - 1]["tNo"] ?? "");
                                                                                },
                                                                                child: SizedBox(
                                                                                  width: 252.w + (controller.statusIndex == 3 ? (375 - 15 - 252 - 66).w : 0),
                                                                                  child: Align(
                                                                                    alignment: Alignment.centerLeft,
                                                                                    child: getSimpleText(controller.machineList[index - 1]["tNo"] != null ? snNoFormat(controller.machineList[index - 1]["tNo"]) : "", 14, const Color(0xFF808080)),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 66.w,
                                                                                child: Align(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: getSimpleText(controller.machineList[index - 1]["tStatus"], 14, const Color(0xFF808080)),
                                                                                ),
                                                                              ),
                                                                              GetBuilder<MachineTransferMachineListController>(
                                                                                init: controller,
                                                                                builder: (_) {
                                                                                  return controller.statusIndex == 3
                                                                                      ? const SizedBox()
                                                                                      : CustomButton(
                                                                                          onPressed: () {
                                                                                            Map cData = controller.machineList[index - 1];
                                                                                            // if (cData["checkStatus"] == null || cData["checkStatus"] == "nocheck") {
                                                                                            //   ShowToast.normal("无法选择已激活的机具");
                                                                                            //   return;
                                                                                            // }
                                                                                            cData["selected"] = !cData["selected"];
                                                                                            controller.updateSelectButtons();
                                                                                          },
                                                                                          child: SizedBox(
                                                                                            width: (375 - 15 - 252 - 66).w,
                                                                                            child: (controller.machineList[index - 1]["checkStatus"] ?? "") == "nocheck"
                                                                                                ? gemp()
                                                                                                : Align(
                                                                                                    alignment: Alignment.centerLeft,
                                                                                                    child: assetsSizeImage(controller.machineList[index - 1]["selected"] ? "common/btn_checkbox_selected" : "common/btn_checkbox_normal", 22, 22),
                                                                                                  ),
                                                                                          ),
                                                                                        );
                                                                                },
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ))
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              SizedBox(
                                width: 375.w,
                                height: boxHeight,
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Column(
                                          children: [
                                            ghb(32.5),
                                            getSearchInput(
                                              "请输入机具SN号查询",
                                              controller.quickSearchTextCtrl,
                                              scanSnClick: () {
                                                toScanBarCode(((barCode) {
                                                  controller.quickSearchTextCtrl
                                                      .text = barCode;
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500),
                                                      (() => showQuickBottom(
                                                          context)));
                                                }));
                                              },
                                              isText: true,
                                              onPressed: () {
                                                // controller.getMachineList(
                                                //     dataSize: controller
                                                //         .quickSearchCount);
                                                showQuickBottom(context);
                                              },
                                              onSubmitted: (str) {
                                                // FocusScope.of(context)
                                                //     .requestFocus(FocusNode());
                                              },
                                            ),
                                            ghb(42),
                                            sbRow([
                                              getSimpleText("批量连号划拨台数", 17,
                                                  AppColor.textBlack,
                                                  isBold: true),
                                            ], width: 375 - 15 * 2),
                                            ghb(25),
                                            sbRow([
                                              CustomButton(
                                                onPressed: () {
                                                  controller.quickSearchCount++;
                                                },
                                                child: Container(
                                                  width: 80.w,
                                                  height: 55.w,
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFEDEDED),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.w)),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.add_rounded,
                                                      size: 30.w,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 160.w,
                                                height: 55.w,
                                                decoration:
                                                    getDefaultWhiteDec(),
                                                child: CustomInput(
                                                  width: 150.w,
                                                  heigth: 55.w,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  placeholder: "请输入数量",
                                                  textEditCtrl: controller
                                                      .quickCountTextCtrl,
                                                  style: TextStyle(
                                                      fontSize: 25.sp,
                                                      color: AppColor.textBlack,
                                                      fontWeight:
                                                          AppDefault.fontBold),
                                                  placeholderStyle: TextStyle(
                                                      fontSize: 25.sp,
                                                      color: AppColor.textGrey,
                                                      fontWeight:
                                                          AppDefault.fontBold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              CustomButton(
                                                onPressed: () {
                                                  controller.quickSearchCount--;
                                                },
                                                child: Container(
                                                  width: 80.w,
                                                  height: 55.w,
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFEDEDED),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.w)),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.remove_rounded,
                                                      size: 30.w,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ], width: 375 - 15 * 2),
                                            ghb(25),
                                            SizedBox(
                                              width: 345.w,
                                              child: getSimpleText(
                                                  "*输入机具号后，填写数量，系统将默认按顺序排列选定,输入完 数字之后点击确认即可",
                                                  12,
                                                  AppColor.textGrey),
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          );
                  },
                ),
              );
            },
          ),

          // Builder(builder: (ctx) {
          //   return GetX<MachineTransferMachineListController>(
          //     init: controller,
          //     builder: (_) {
          //       return controller.topIdx == 0
          //           ? SingleChildScrollView(
          //               child: Column(
          //                 children: [
          //                   SizedBox(
          //                     width: 375.w,
          //                     height: ScreenUtil().screenHeight -
          //                         Scaffold.of(ctx).appBarMaxHeight! -
          //                         80.w +
          //                         paddingSizeBottom(context),
          //                     child: Stack(
          //                       children: [
          //                         Positioned(
          //                             top: 0,
          //                             left: 0,
          //                             right: 0,
          //                             height: 50.w,
          //                             child: Container(
          //                               color: Colors.white,
          //                               child: sbhRow([
          //                                 CustomButton(
          //                                   onPressed: () {
          //                                     showPolicySelectView(context);
          //                                   },
          //                                   child: Container(
          //                                     padding:
          //                                         EdgeInsets.only(left: 5.w),
          //                                     width: 100.w,
          //                                     height: 50.w,
          //                                     child: Center(
          //                                       child: centRow([
          //                                         GetX<
          //                                             MachineTransferMachineListController>(
          //                                           init: controller,
          //                                           builder: (_) {
          //                                             return getSimpleText(
          //                                                 controller.policyList[
          //                                                         controller
          //                                                             .policyIndex]
          //                                                     ["name"],
          //                                                 15,
          //                                                 AppColor.textBlack,
          //                                                 isBold: true);
          //                                           },
          //                                         ),
          //                                         // gwb(5),
          //                                         Icon(
          //                                           Icons.keyboard_arrow_down,
          //                                           size: 17.w,
          //                                           color: AppColor.textBlack,
          //                                         ),
          //                                       ]),
          //                                     ),
          //                                   ),
          //                                 ),
          //                                 ...controller.statusList
          //                                     .asMap()
          //                                     .entries
          //                                     .map((e) => GetX<
          //                                             MachineTransferMachineListController>(
          //                                           init: controller,
          //                                           builder: (controller) {
          //                                             return CustomButton(
          //                                               onPressed: () {
          //                                                 controller
          //                                                         .statusIndex =
          //                                                     e.key;
          //                                                 controller.status =
          //                                                     controller
          //                                                             .statusList[
          //                                                         e.key]["id"];
          //                                                 // controller
          //                                                 //     .getMachineList();
          //                                               },
          //                                               child: SizedBox(
          //                                                 width: ((375 - 100) /
          //                                                         controller
          //                                                             .statusList
          //                                                             .length)
          //                                                     .w,
          //                                                 height: 50.w,
          //                                                 child: Center(
          //                                                   child: getSimpleText(
          //                                                       e.value["name"],
          //                                                       15,
          //                                                       controller.statusIndex ==
          //                                                               e.key
          //                                                           ? AppColor
          //                                                               .buttonTextBlue
          //                                                           : const Color(
          //                                                               0xFFB3B3B3)),
          //                                                 ),
          //                                               ),
          //                                             );
          //                                           },
          //                                         ))
          //                                     .toList()
          //                               ], width: 375, height: 50),
          //                             )),
          //                         Positioned(
          //                             top: 50.w,
          //                             left: 0,
          //                             right: 0,
          //                             bottom: 0,
          //                             child: Stack(
          //                               children: [
          //                                 Positioned(
          //                                     top: 0,
          //                                     left: 0,
          //                                     right: 0,
          //                                     height: 54.w,
          //                                     child: Align(
          //                                       child: sbhRow([
          //                                         Text.rich(TextSpan(
          //                                             text:
          //                                                 "${controller.brandData["enumName"]}-${controller.statusList[controller.statusIndex]["name"]}库存：",
          //                                             style: TextStyle(
          //                                                 fontSize: 15.sp,
          //                                                 color: AppColor
          //                                                     .textBlack),
          //                                             children: [
          //                                               TextSpan(
          //                                                   text:
          //                                                       "${controller.currentCount}",
          //                                                   style: TextStyle(
          //                                                       fontSize: 15.sp,
          //                                                       color: const Color(
          //                                                           0xFFEB5757))),
          //                                               TextSpan(
          //                                                   text: "台",
          //                                                   style: TextStyle(
          //                                                       fontSize: 15.sp,
          //                                                       color: AppColor
          //                                                           .textBlack)),
          //                                             ]))
          //                                       ], width: 375 - 14.5 * 2),
          //                                     )),
          //                                 Positioned(
          //                                     top: 54.w,
          //                                     left: 0,
          //                                     right: 0,
          //                                     bottom: 0,
          //                                     child: controller.currentCount ==
          //                                             0
          //                                         ? GetX<
          //                                             MachineTransferMachineListController>(
          //                                             builder: (controller) {
          //                                               return CustomEmptyView(
          //                                                 isLoading: controller
          //                                                     .isLoading,
          //                                               );
          //                                             },
          //                                           )
          //                                         : GetX<
          //                                             MachineTransferMachineListController>(
          //                                             init: controller,
          //                                             initState: (_) {},
          //                                             builder: (_) {
          //                                               return SmartRefresher(
          //                                                 controller: controller
          //                                                     .pullCtrl,
          //                                                 enablePullDown: true,
          //                                                 enablePullUp: controller
          //                                                         .machineList
          //                                                         .length <
          //                                                     controller
          //                                                         .currentCount,
          //                                                 onRefresh: controller
          //                                                     .onRefresh,
          //                                                 onLoading:
          //                                                     controller.onLoad,
          //                                                 child:
          //                                                     ListView.builder(
          //                                                   itemCount: controller
          //                                                           .machineList
          //                                                           .isNotEmpty
          //                                                       ? controller
          //                                                               .machineList
          //                                                               .length +
          //                                                           1
          //                                                       : 1,
          //                                                   itemBuilder:
          //                                                       (context,
          //                                                           index) {
          //                                                     return index == 0
          //                                                         ? Container(
          //                                                             height:
          //                                                                 45.w,
          //                                                             decoration: BoxDecoration(
          //                                                                 color: Colors
          //                                                                     .white,
          //                                                                 border:
          //                                                                     Border(bottom: BorderSide(width: 0.5.w, color: const Color(0xFFEBEBEB)))),
          //                                                             child:
          //                                                                 Center(
          //                                                               child:
          //                                                                   Row(
          //                                                                 children: [
          //                                                                   gwb(15),
          //                                                                   SizedBox(
          //                                                                     width: 252.w + (controller.statusIndex == 3 ? (375 - 15 - 252 - 66).w : 0),
          //                                                                     child: Align(
          //                                                                       alignment: Alignment.centerLeft,
          //                                                                       child: getSimpleText("机具编号（SN号）", 14, const Color(0xFF808080)),
          //                                                                     ),
          //                                                                   ),
          //                                                                   SizedBox(
          //                                                                     width: 66.w,
          //                                                                     child: Align(
          //                                                                       alignment: Alignment.centerLeft,
          //                                                                       child: getSimpleText("状态", 14, const Color(0xFF808080)),
          //                                                                     ),
          //                                                                   ),
          //                                                                   GetX<MachineTransferMachineListController>(
          //                                                                     init: controller,
          //                                                                     builder: (_) {
          //                                                                       return controller.statusIndex == 3
          //                                                                           ? const SizedBox()
          //                                                                           : CustomButton(
          //                                                                               onPressed: () {
          //                                                                                 controller.selectedAndUnSelectedAll(!controller.isAllSelected);
          //                                                                               },
          //                                                                               child: SizedBox(
          //                                                                                 width: (375 - 15 - 252 - 66).w,
          //                                                                                 child: Align(
          //                                                                                   alignment: Alignment.centerLeft,
          //                                                                                   child: getSimpleText(controller.isAllSelected ? "反选" : "全选", 14, AppColor.buttonTextBlue),
          //                                                                                 ),
          //                                                                               ),
          //                                                                             );
          //                                                                     },
          //                                                                   )
          //                                                                 ],
          //                                                               ),
          //                                                             ),
          //                                                           )
          //                                                         : Container(
          //                                                             width:
          //                                                                 375.w,
          //                                                             height:
          //                                                                 60.w,
          //                                                             decoration: BoxDecoration(
          //                                                                 color: Colors
          //                                                                     .white,
          //                                                                 border:
          //                                                                     Border(bottom: BorderSide(width: 0.5.w, color: const Color(0xFFEBEBEB)))),
          //                                                             child:
          //                                                                 Center(
          //                                                               child:
          //                                                                   Row(
          //                                                                 children: [
          //                                                                   gwb(15),
          //                                                                   CustomButton(
          //                                                                     onPressed: () {
          //                                                                       showSnNoModel(context, controller.machineList[index - 1]["tNo"] ?? "");
          //                                                                     },
          //                                                                     child: SizedBox(
          //                                                                       width: 252.w + (controller.statusIndex == 3 ? (375 - 15 - 252 - 66).w : 0),
          //                                                                       child: Align(
          //                                                                         alignment: Alignment.centerLeft,
          //                                                                         child: getSimpleText(controller.machineList[index - 1]["tNo"] != null ? snNoFormat(controller.machineList[index - 1]["tNo"]) : "", 14, const Color(0xFF808080)),
          //                                                                       ),
          //                                                                     ),
          //                                                                   ),
          //                                                                   SizedBox(
          //                                                                     width: 66.w,
          //                                                                     child: Align(
          //                                                                       alignment: Alignment.centerLeft,
          //                                                                       child: getSimpleText(controller.machineList[index - 1]["tStatus"], 14, const Color(0xFF808080)),
          //                                                                     ),
          //                                                                   ),
          //                                                                   GetBuilder<MachineTransferMachineListController>(
          //                                                                     init: controller,
          //                                                                     builder: (_) {
          //                                                                       return controller.statusIndex == 3
          //                                                                           ? const SizedBox()
          //                                                                           : CustomButton(
          //                                                                               onPressed: () {
          //                                                                                 controller.machineList[index - 1]["selected"] = !controller.machineList[index - 1]["selected"];

          //                                                                                 controller.updateSelectButtons();
          //                                                                               },
          //                                                                               child: SizedBox(
          //                                                                                 width: (375 - 15 - 252 - 66).w,
          //                                                                                 child: Align(
          //                                                                                   alignment: Alignment.centerLeft,
          //                                                                                   child: assetsSizeImage(controller.machineList[index - 1]["selected"] ? "common/btn_checkbox_selected" : "common/btn_checkbox_normal", 22, 22),
          //                                                                                 ),
          //                                                                               ),
          //                                                                             );
          //                                                                     },
          //                                                                   )
          //                                                                 ],
          //                                                               ),
          //                                                             ),
          //                                                           );
          //                                                   },
          //                                                 ),
          //                                               );
          //                                             },
          //                                           ))
          //                               ],
          //                             )),
          //                       ],
          //                     ),
          //                   ),
          //                   Container(
          //                     width: 375.w,
          //                     height: 80.w,
          //                     color: Colors.white,
          //                     child: Center(
          //                       child: getSubmitBtn("确定", () {
          //                         List machines = [];
          //                         for (var item in controller.machineList) {
          //                           if (item["selected"]) {
          //                             machines.add(item);
          //                           }
          //                         }
          //                         if (machines.isEmpty) {
          //                           showAlert(
          //                             context,
          //                             "没有选择机具，确定返回吗？",
          //                             confirmOnPressed: () {
          //                               Get.until((route) {
          //                                 if (route is GetPageRoute) {
          //                                   if (route.binding
          //                                       is MachineTransferBinding) {
          //                                     return true;
          //                                   } else {
          //                                     return false;
          //                                   }
          //                                 } else {
          //                                   return false;
          //                                 }
          //                               });
          //                             },
          //                           );
          //                         } else {
          //                           Get.until((route) {
          //                             if ((route as GetPageRoute).binding
          //                                 is MachineTransferBinding) {
          //                               Get.find<MachineTransferController>()
          //                                   .selectMachineData = machines;
          //                               return true;
          //                             }
          //                             return false;
          //                           });
          //                         }
          //                       }),
          //                     ),
          //                   ),
          //                   Container(
          //                     width: 375.w,
          //                     height: paddingSizeBottom(context),
          //                     color: Colors.white,
          //                   ),
          //                 ],
          //               ),
          //             )
          //           : SingleChildScrollView(
          //               child: Column(
          //                 children: [
          //                   SizedBox(
          //                     width: 375.w,
          //                     height: ScreenUtil().screenHeight -
          //                         Scaffold.of(ctx).appBarMaxHeight! -
          //                         80.w +
          //                         paddingSizeBottom(context),
          //                     child: Stack(
          //                       children: [
          //                         Positioned(
          //                             top: 0,
          //                             left: 0,
          //                             right: 0,
          //                             bottom: 0,
          //                             child: Column(
          //                               children: [
          //                                 ghb(32.5),
          //                                 getSearchInput(
          //                                   "请输入机具SN号查询",
          //                                   controller.quickSearchTextCtrl,
          //                                   isText: true,
          //                                   onPressed: () {
          //                                     // controller.getMachineList(
          //                                     //     dataSize: controller
          //                                     //         .quickSearchCount);
          //                                     showQuickBottom(context);
          //                                   },
          //                                   onSubmitted: (str) {
          //                                     // FocusScope.of(context)
          //                                     //     .requestFocus(FocusNode());
          //                                   },
          //                                 ),
          //                                 ghb(42),
          //                                 sbRow([
          //                                   getSimpleText("批量连号划拨台数", 17,
          //                                       AppColor.textBlack,
          //                                       isBold: true),
          //                                 ], width: 375 - 15 * 2),
          //                                 ghb(25),
          //                                 sbRow([
          //                                   CustomButton(
          //                                     onPressed: () {
          //                                       controller.quickSearchCount++;
          //                                     },
          //                                     child: Container(
          //                                       width: 80.w,
          //                                       height: 55.w,
          //                                       decoration: BoxDecoration(
          //                                           color:
          //                                               const Color(0xFFEDEDED),
          //                                           borderRadius:
          //                                               BorderRadius.circular(
          //                                                   5.w)),
          //                                       child: Center(
          //                                         child: Icon(
          //                                           Icons.add_rounded,
          //                                           size: 30.w,
          //                                         ),
          //                                       ),
          //                                     ),
          //                                   ),
          //                                   Container(
          //                                     width: 160.w,
          //                                     height: 55.w,
          //                                     decoration: getDefaultWhiteDec(),
          //                                     child: CustomInput(
          //                                       width: 150.w,
          //                                       heigth: 55.w,
          //                                       keyboardType:
          //                                           TextInputType.number,
          //                                       placeholder: "请输入数量",
          //                                       textEditCtrl: controller
          //                                           .quickCountTextCtrl,
          //                                       style: TextStyle(
          //                                           fontSize: 25.sp,
          //                                           color: AppColor.textBlack,
          //                                           fontWeight:
          //                                               AppDefault.fontBold),
          //                                       placeholderStyle: TextStyle(
          //                                           fontSize: 25.sp,
          //                                           color: AppColor.textGrey,
          //                                           fontWeight:
          //                                               AppDefault.fontBold),
          //                                       textAlign: TextAlign.center,
          //                                     ),
          //                                   ),
          //                                   CustomButton(
          //                                     onPressed: () {
          //                                       controller.quickSearchCount--;
          //                                     },
          //                                     child: Container(
          //                                       width: 80.w,
          //                                       height: 55.w,
          //                                       decoration: BoxDecoration(
          //                                           color:
          //                                               const Color(0xFFEDEDED),
          //                                           borderRadius:
          //                                               BorderRadius.circular(
          //                                                   5.w)),
          //                                       child: Center(
          //                                         child: Icon(
          //                                           Icons.remove_rounded,
          //                                           size: 30.w,
          //                                         ),
          //                                       ),
          //                                     ),
          //                                   ),
          //                                 ], width: 375 - 15 * 2),
          //                                 ghb(25),
          //                                 SizedBox(
          //                                   width: 345.w,
          //                                   child: getSimpleText(
          //                                       "*输入机具号后，填写数量，系统将默认按顺序排列选定,输入完 数字之后点击确认即可",
          //                                       12,
          //                                       AppColor.textGrey),
          //                                 )
          //                               ],
          //                             )),
          //                       ],
          //                     ),
          //                   ),
          //                   Container(
          //                     width: 375.w,
          //                     height: 80.w,
          //                     color: Colors.white,
          //                     child: Center(
          //                       child: getSubmitBtn("确定", () {
          //                         if (controller.searchMachineList.isEmpty) {
          //                           showAlert(
          //                             context,
          //                             "没有搜索到机具，确定返回吗？",
          //                             confirmOnPressed: () {
          //                               Get.until((route) {
          //                                 if (route is GetPageRoute) {
          //                                   if (route.binding
          //                                       is MachineTransferBinding) {
          //                                     return true;
          //                                   } else {
          //                                     return false;
          //                                   }
          //                                 } else {
          //                                   return false;
          //                                 }
          //                               });
          //                             },
          //                           );
          //                         } else {
          //                           Get.until((route) {
          //                             if ((route as GetPageRoute).binding
          //                                 is MachineTransferBinding) {
          //                               Get.find<MachineTransferController>()
          //                                       .selectMachineData =
          //                                   controller.searchMachineList;
          //                               return true;
          //                             }
          //                             return false;
          //                           });
          //                         }
          //                       }),
          //                     ),
          //                   ),
          //                   Container(
          //                     width: 375.w,
          //                     height: paddingSizeBottom(context),
          //                     color: Colors.white,
          //                   ),
          //                 ],
          //               ),
          //             );
          //     },
          //   );
          // })),
        ));
  }

  Widget topButton(int idx) {
    return CustomButton(
      onPressed: () {
        controller.topIdx = idx;
      },
      child: Align(
        child: Container(
          width: 83.w,
          height: 30.w,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    idx == controller.topIdx
                        ? AppDefault().getThemeColor() ??
                            const Color(0xFF4282EB)
                        : Colors.transparent,
                    idx == controller.topIdx
                        ? AppDefault().getThemeColor(index: 2) ??
                            const Color(0xFF5BA3F7)
                        : Colors.transparent,
                  ]),
              borderRadius: BorderRadius.circular(6.w)),
          child: Center(
              child: getSimpleText(idx == 0 ? "机具划拨" : "快速划拨", 14,
                  idx == controller.topIdx ? Colors.white : AppColor.textGrey)),
        ),
      ),
    );
  }

  showPolicySelectView(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      context: context,
      builder: (context) {
        return Container(
          height: (68 + controller.policyList.length * 60).w,
          width: 375.w,
          color: AppColor.pageBackgroundColor,
          child: Column(
            children: [
              ...controller.policyList
                  .asMap()
                  .entries
                  .map((e) => CustomButton(
                        onPressed: () {
                          controller.policyIndex = e.key;
                          controller.policy =
                              controller.policyList[e.key]["id"];
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 375.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.5.w,
                                      color: AppColor.lineColor))),
                          child: Center(
                            child: getSimpleText(
                                e.value["name"], 16, AppColor.textBlack),
                          ),
                        ),
                      ))
                  .toList(),
              ghb(7),
              CustomButton(
                onPressed: () => Navigator.pop(context),
                child: Container(
                    width: 375.w,
                    height: 61.w,
                    color: Colors.white,
                    child: Center(
                        child: getSimpleText("取消", 16, AppColor.textBlack))),
              )
            ],
          ),
        );
      },
    );
  }

  showSearchModel(BuildContext context) {
    Get.bottomSheet(
      GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: SizedBox(
            width: 375.w,
            height: 374.w,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  sbRow([
                    ghb(0),
                    CustomButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Image.asset(
                        assetsName(
                          "common/btn_model_close",
                        ),
                        width: 37.w,
                        height: 56.5.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ], width: 375 - 24 * 2),
                  Container(
                    width: 375.w,
                    height: 317.w,
                    decoration: BoxDecoration(
                        color: AppColor.lineColor,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10.w))),
                    child: Column(
                      children: [
                        sbRow([
                          CustomButton(
                            onPressed: () {
                              controller.searchButtonIdx = 0;
                            },
                            child: SizedBox(
                              width: (375 - 1).w / 2,
                              height: 50.w,
                              child: Center(child:
                                  GetX<MachineTransferMachineListController>(
                                builder: (_) {
                                  return getSimpleText(
                                    "普通搜索",
                                    16,
                                    controller.searchButtonIdx == 0
                                        ? AppDefault().getThemeColor() ??
                                            AppColor.buttonTextBlue
                                        : const Color(0xFF808080),
                                  );
                                },
                              )),
                            ),
                          ),
                          gline(1, 15, color: const Color(0xFFE0E0E0)),
                          CustomButton(
                            onPressed: () {
                              controller.searchButtonIdx = 1;
                            },
                            child: SizedBox(
                              width: (375 - 1).w / 2,
                              height: 50.w,
                              child: Center(child:
                                  GetX<MachineTransferMachineListController>(
                                builder: (_) {
                                  return getSimpleText(
                                    "连号搜索",
                                    16,
                                    controller.searchButtonIdx == 1
                                        ? AppDefault().getThemeColor() ??
                                            AppColor.buttonTextBlue
                                        : const Color(0xFF808080),
                                  );
                                },
                              )),
                            ),
                          )
                        ], width: 375),
                        gline(345, 0.5, color: const Color(0xFFE0E0E0)),
                        ghb(16),
                        GetX<MachineTransferMachineListController>(
                          builder: (_) {
                            return controller.searchButtonIdx == 0
                                ? centClm([
                                    ghb(5.5),
                                    sbRow([
                                      getSimpleText(
                                          "普通搜索", 25, AppColor.textBlack,
                                          isBold: true),
                                    ], width: 375 - 25 * 2),
                                    ghb(10),
                                    sbRow([
                                      getSimpleText("输入SN号或者扫描SN号", 14,
                                          AppColor.textGrey),
                                    ], width: 375 - 25 * 2),
                                    ghb(10),
                                    getSearchInput(
                                      "请输入机具SN号查询",
                                      controller.normalSearchTextCtrl,
                                      scanSnClick: () {
                                        toScanBarCode(((barCode) => controller
                                            .normalSearchTextCtrl
                                            .text = barCode));
                                      },
                                    ),
                                  ])
                                : centClm([
                                    getSearchInput("请输入起始机具号",
                                        controller.startSearchTextCtrl,
                                        scanSnClick: () {
                                      toScanBarCode(((barCode) => controller
                                          .startSearchTextCtrl.text = barCode));
                                    }, maxLength: 5),
                                    ghb(12),
                                    getSearchInput("请输入终点机具号",
                                        controller.endSearchTextCtrl,
                                        scanSnClick: () {
                                      toScanBarCode(((barCode) => controller
                                          .endSearchTextCtrl.text = barCode));
                                    }, maxLength: 5),
                                  ]);
                          },
                        ),
                        ghb(20.5),
                        getSubmitBtn("快速搜索", () {
                          // if (controller.searchButtonIdx == 0) {
                          //   if (controller
                          //       .normalSearchTextCtrl.text.isNotEmpty) {
                          //     controller.terminalNo =
                          //         controller.normalSearchTextCtrl.text;
                          //   }
                          // } else {
                          //   if (controller
                          //       .startSearchTextCtrl.text.isNotEmpty) {
                          //     controller.terminal_Start =
                          //         controller.startSearchTextCtrl.text;
                          //   }
                          //   if (controller
                          //       .endSearchTextCtrl.text.isNotEmpty) {
                          //     controller.terminal_End =
                          //         controller.endSearchTextCtrl.text;
                          //   }
                          // }

                          controller.getMachineList();
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).then((value) {
      controller.normalSearchTextCtrl.clear();
      controller.startSearchTextCtrl.clear();
      controller.endSearchTextCtrl.clear();
    });
  }

  Widget getSearchInput(
    String placeholder,
    TextEditingController ctrl, {
    int? maxLength,
    Function(String str)? onSubmitted,
    Function()? scanSnClick,
    Function()? onPressed,
    bool isText = false,
  }) {
    return CustomButton(
      onPressed: onPressed != null
          ? () {
              onPressed();
            }
          : null,
      child: Container(
        width: 345.w,
        height: 70.w,
        decoration: getDefaultWhiteDec(),
        child: Center(
          child: sbhRow([
            isText
                ? SizedBox(
                    width: 266.w,
                    height: 70.w,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: getSimpleText(
                          "请输入机具SN号查询", 15, const Color(0xFFCCCCCC)),
                    ),
                  )
                : CustomInput(
                    width: 266.w,
                    heigth: 70.w,
                    onSubmitted: onSubmitted,
                    placeholder: placeholder,
                    textEditCtrl: ctrl,
                    maxLength: maxLength,
                    keyboardType: TextInputType.text,
                    placeholderStyle:
                        TextStyle(fontSize: 15.sp, color: AppColor.textGrey),
                    style:
                        TextStyle(fontSize: 15.sp, color: AppColor.textBlack),
                  ),
            CustomButton(
              onPressed: scanSnClick,
              child: SizedBox(
                width: (345 - 18.5 * 2 - 266).w,
                height: 70.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    assetsName("home/machinemanage/tiaoxingma"),
                    width: 24.w,
                    height: 24.w,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ], height: 70, width: 345 - 18.5 * 2),
        ),
      ),
    );
  }

  showSnNoModel(BuildContext context, String sn) {
    showGeneralDialog(
      context: context,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Align(
            child: SizedBox(
              width: 345.w,
              height: 172.5.w,
              child: Column(
                children: [
                  CustomButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Image.asset(
                      assetsName(
                        "common/btn_model_close",
                      ),
                      width: 37.w,
                      height: 56.5.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    width: 345.w,
                    height: 116.w,
                    decoration: BoxDecoration(
                        color: AppColor.lineColor,
                        borderRadius: BorderRadius.circular(5.w)),
                    child: Column(
                      children: [
                        ghb(25),
                        getSimpleText("点击机具编号即可复制", 15, AppColor.textBlack,
                            isBold: true),
                        ghb(13.5),
                        CustomButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: sn));
                            ShowToast.normal("已复制");
                          },
                          child: Container(
                            width: 270.w,
                            height: 35.w,
                            decoration: getDefaultWhiteDec(),
                            child: Center(
                                child: getSimpleText(sn, 20, AppColor.textBlack,
                                    isBold: true)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  showQuickBottom(BuildContext context) {
    Get.bottomSheet(
      SizedBox(
        width: 375.w,
        height: 553.w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              sbRow([
                gwb(0),
                CustomButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Image.asset(
                    assetsName(
                      "common/btn_model_close",
                    ),
                    width: 37.w,
                    height: 56.5.w,
                    fit: BoxFit.fill,
                  ),
                ),
              ], width: 375 - 24 * 2),
              Container(
                width: 375.w,
                height: 100.w,
                decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10.w))),
                child: Center(
                  child: Container(
                    width: 345.w,
                    height: 50.w,
                    decoration: getDefaultWhiteDec(),
                    child: Center(
                      child: sbRow([
                        CustomInput(
                          textEditCtrl: controller.quickSearchTextCtrl,
                          placeholder: "请输入机具SN号查询",
                          width: 251.w,
                          heigth: 50.w,
                          onSubmitted: (str) {
                            // controller.terminalNo =
                            //     controller.quickSearchTextCtrl.text;
                            // controller.getMachineList(
                            //     dataSize: controller.quickSearchCount);
                            // takeBackKeyboard(context);
                          },
                        ),
                        CustomButton(
                          onPressed: () {
                            // controller.terminalNo =
                            //     controller.quickSearchTextCtrl.text;
                            controller.getMachineList(
                                dataSize: controller.quickSearchCount);
                            takeBackKeyboard(context);
                          },
                          child: Container(
                            width: 64.w,
                            height: 30,
                            decoration: BoxDecoration(
                                color: AppColor.textBlack,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: getSimpleText("搜索", 15, Colors.white),
                            ),
                          ),
                        )
                      ], width: 345 - 15 * 2),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                width: 375.w,
                height: (553 - 36 - 20 - 100).w,
                child: GetX<MachineTransferMachineListController>(
                  init: controller,
                  initState: (_) {},
                  builder: (_) {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.searchMachineList.isNotEmpty
                          ? controller.searchMachineList.length
                          : 0,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 375.w,
                          height: 55.w,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.5.w,
                                      color: AppColor.lineColor))),
                          child: Align(
                              alignment: const Alignment(-0.89, 0),
                              child: getSimpleText(
                                  controller.searchMachineList[index]["tNo"] ??
                                      "",
                                  15,
                                  AppColor.textBlack)),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: false,
    );
  }
}
