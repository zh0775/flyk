import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineShipSelectBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineShipSelectController>(MachineShipSelectController(datas: Get.arguments));
  }
}

class MachineShipSelectController extends GetxController {
  final dynamic datas;
  MachineShipSelectController({this.datas});

  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();

  final _topSelectIdx = 0.obs;
  int get topSelectIdx => _topSelectIdx.value;
  set topSelectIdx(v) => _topSelectIdx.value = v;

  CustomDropDownController filterCtrl = CustomDropDownController();
  TextEditingController startInputCtrl = TextEditingController();
  TextEditingController endInputCtrl = TextEditingController();

  List machines = [];
  Map orderData = {};
  int aftersaleType = 0;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _btnEnable = false.obs;
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

  allSelectAction() {
    checkSelect(allSelect: !allselect);
    update();
  }

  checkSelect({bool? allSelect}) {
    if (machines.isEmpty) {
      return;
    }
    bool isAllSelect = true;
    int tmpSelectCount = 0;
    for (var e in machines) {
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
    selectCount = 0;
    for (var e in commodityList) {
      tmpSelectCount += ((e["selectMachines"] ?? []) as List).length;
    }
    selectCount = tmpSelectCount;
    btnEnable = selectCount == maxCount;
    allselect = isAllSelect;
  }

  confirmAction() {
    if (addMachines != null) {
      addMachines!(commodityList);
    }
  }

  double filterHeight = 0;

  showFitler() {
    isFrap = !isFrap;
    // if (filterCtrl.isShow) {
    //   filterCtrl.hide();
    //   return;
    // }
    // filterCtrl.show(stackKey, headKey);
  }

  int maxCount = 0;

  String filterBuildId = "MachineShipSelect_filterBuildId";

  loadData() {
    update();
  }

  onlySelect(int index, {bool close = true}) {
    for (var i = 0; i < commodityList.length; i++) {
      Map data = commodityList[i];
      data["selected"] = (index == i);
    }
    update([filterBuildId]);
    loadMachines(loadIdx: index);
    if (close) {
      showFitler();
    }
  }

  modelSearchReset() {
    startInputCtrl.clear();
    endInputCtrl.clear();
  }

  modelSearchConfirm() {
    Get.back();
    if (startInputCtrl.text.isNotEmpty || endInputCtrl.text.isNotEmpty) {
      loadMachines(start: startInputCtrl.text, end: endInputCtrl.text);
    }
  }

  int dataCount = 0;
  int pageSize = 20;
  int pageNo = 1;

  loadMachines({bool isLoad = false, String? start, String? end, int? loadIdx}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (machines.isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "status": 1,
      "pageNo": pageNo,
      "pageSize": pageSize,
      "teamType": 0,
      "terminalModel": -1,
      "terminalBrandId": -1,
    };
    if (start != null && start.isNotEmpty) {
      params["terminal_Start"] = seqNumFormat(start);
    }
    if (end != null && end.isNotEmpty) {
      params["terminal_End"] = seqNumFormat(end);
    }
    Map selectType = {};
    if (loadIdx != null) {
      selectType = commodityList[loadIdx];
    } else {
      for (var e in commodityList) {
        if (e["selected"]) {
          selectType = e;
          break;
        }
      }
    }

    if (selectType.isNotEmpty) {
      params["terminalBrandId"] = selectType["terminalBrandId"];
      params["terminalModel"] = selectType["terminalModel"];
    } else {}

    simpleRequest(
      url: Urls.userPersonTerminalHighList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          dataCount = data["count"] ?? 0;
          List dList = data["data"] ?? [];
          dList = List.generate(dList.length, (index) {
            Map e = dList[index];
            bool selected = false;
            for (var commodity in commodityList) {
              for (var p in commodity["selectMachines"] ?? []) {
                if (p["tId"] == e["tId"]) {
                  selected = true;
                  break;
                }
              }
            }
            return {...e, "selected": selected};
          });

          machines = isLoad ? [...machines, ...dList] : dList;
          checkSelect();
          update();
          update([filterBuildId]);
          if (loadIdx != null) {
            topSelectIdx = loadIdx;
          }
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  List commodityList = [];

  checkSelectComplete(Map data, int idx) {
    List selectMachines = commodityList[topSelectIdx]["selectMachines"] ?? [];
    int num = commodityList[topSelectIdx]["num"] ?? 1;
    // if (!data["selected"] && selectMachines.length >= num) {
    //   return;
    // } else
    if (!data["selected"] && selectMachines.length + 1 == num) {
      data["selected"] = !data["selected"];
      selectMachines.add(data);
      int unSelectIdx = commodityList.length - 1;
      for (var i = 0; i < commodityList.length; i++) {
        Map p = commodityList[i];
        if ((p["num"] ?? 1) > (p["selectMachines"] ?? []).length) {
          unSelectIdx = i;
          break;
        }
      }
      loadMachines(loadIdx: unSelectIdx);
      for (var i = 0; i < commodityList.length; i++) {
        Map product = commodityList[i];
        product["selected"] = (unSelectIdx == i);
      }
    } else {
      if (data["selected"]) {
        for (var p in commodityList) {
          for (var e in (p["selectMachines"] ?? [])) {
            if (e["tId"] == data["tId"]) {
              (p["selectMachines"] ?? []).remove(e);
              break;
            }
          }
        }
      } else {
        selectMachines.add(data);
      }
      data["selected"] = !data["selected"];
    }

    // if (condition) {

    // }
  }

  listCellSelect(Map data, int idx) {
    checkSelectComplete(data, idx);
    checkSelect();
    update();
    update([filterBuildId]);
  }

  @override
  void onInit() {
    if (datas != null && datas is Map && datas.isNotEmpty) {
      // machines = datas["machines"] ?? [];
      aftersaleType = datas["type"] ?? 0;
      orderData = datas["orderData"] ?? {};
      addMachines = datas["addMachines"];
      // maxCount = datas["maxCount"] ?? 2;
      bool haveData = datas["machines"] != null && datas["machines"].isNotEmpty;
      commodityList = haveData ? datas["machines"] : orderData["commodity"] ?? [];
      maxCount = 0;
      topSelectIdx = 0;
      if (haveData) {
        for (var i = 0; i < datas["machines"].length; i++) {
          Map e = datas["machines"][i];
          if ((e["selectMachines"] ?? []).length < e["num"]) {
            topSelectIdx = i;
            break;
          }
        }
      }

      commodityList = List.generate(commodityList.length, (index) {
        Map e = commodityList[index];
        maxCount += (e["num"] ?? 1) as int;
        return {...e, "selected": index == topSelectIdx, "selectMachines": e["selectMachines"] ?? []};
      });

      filterHeight = 0.5 + 40 + commodityList.length * 25 + 10;

      checkSelect();
    }

    loadMachines(loadIdx: topSelectIdx);

    super.onInit();
  }

  @override
  void onClose() {
    filterCtrl.dispose();
    startInputCtrl.dispose();
    endInputCtrl.dispose();
    super.onClose();
  }
}

class MachineShipSelect extends GetView<MachineShipSelectController> {
  const MachineShipSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "选择设备", action: [
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
          Positioned(
              key: controller.headKey,
              left: 0,
              right: 0,
              top: 0,
              height: 45.w,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(width: 1.w, color: AppColor.lineColor)),
                  color: Colors.white,
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: const Color(0x0D000000), blurRadius: 5.w),
                  // ]
                ),
                child: Center(
                  child: sbhRow([
                    getSimpleText("订单详情", 16, AppColor.text, isBold: true),
                    CustomButton(
                      onPressed: () {
                        controller.showFitler();
                      },
                      child: GetX<MachineShipSelectController>(
                        builder: (_) {
                          return SizedBox(
                            width: 50.w,
                            height: 45.w,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: centRow([
                                getSimpleText(controller.isFrap ? "展开" : "收回", 12, AppColor.text3),
                                gwb(3),
                                AnimatedRotation(
                                  turns: controller.isFrap ? 0.5 : 1,
                                  duration: const Duration(milliseconds: 200),
                                  child: Image.asset(
                                    assetsName("machine/btn_list_pullback"),
                                    width: 12.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                )
                              ]),
                            ),
                          );
                        },
                      ),
                    )
                  ], width: 375 - 15 * 2, height: 45),
                ),
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 55.w + paddingSizeBottom(context),
              child: Container(
                padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 5.w)]),
                child: Center(
                  child: sbhRow([
                    CustomButton(
                      onPressed: () {
                        controller.allSelectAction();
                      },
                      child: SizedBox(
                          height: 55.w,
                          child: GetX<MachineShipSelectController>(
                            builder: (_) {
                              return centRow([
                                Image.asset(
                                  assetsName("machine/checkbox_${controller.allselect ? "selected" : "normal"}"),
                                  width: 16.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                gwb(15),
                                getSimpleText(controller.allselect ? "反选" : "全选", 14, AppColor.text),
                              ]);
                            },
                          )),
                    ),
                    centRow([
                      Image.asset(
                        assetsName("machine/icon_machine_count"),
                        width: 18.w,
                        fit: BoxFit.fitWidth,
                      ),
                      gwb(4),
                      GetX<MachineShipSelectController>(
                        builder: (_) {
                          return getSimpleText("已选${controller.selectCount}/${controller.maxCount}", 12, AppColor.text);
                        },
                      ),
                      gwb(10),
                      CustomButton(onPressed: () {
                        if (!controller.btnEnable) {
                          ShowToast.normal("请选择设备");
                          return;
                        }
                        controller.confirmAction();
                      }, child: GetX<MachineShipSelectController>(
                        builder: (_) {
                          return Container(
                            width: 90.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.w), color: controller.btnEnable ? AppColor.theme : const Color(0xFFDBDBDB)),
                            child: Center(child: getSimpleText("确认", 14, Colors.white)),
                          );
                        },
                      ))
                    ]),
                  ], width: 375 - 15 * 2, height: 55),
                ),
              )),
          GetX<MachineShipSelectController>(
            builder: (_) {
              return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: 0,
                  right: 0,
                  top: 45.w + (controller.isFrap ? 0 : controller.filterHeight.w),
                  bottom: 55.w + paddingSizeBottom(context),
                  child: GetBuilder<MachineShipSelectController>(
                    builder: (_) {
                      return EasyRefresh(
                          onRefresh: () => controller.loadMachines(),
                          onLoad: controller.machines.length >= controller.dataCount ? null : () => controller.loadMachines(isLoad: true),
                          child: controller.machines.isEmpty
                              ? GetX<MachineShipSelectController>(
                                  builder: (_) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          gwb(375),
                                          CustomEmptyView(
                                            isLoading: controller.isLoading,
                                          ),
                                          ghb(100)
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  itemCount: controller.machines.length,
                                  padding: EdgeInsets.only(bottom: 20.w),
                                  itemBuilder: (context, index) {
                                    return machineCell(index, controller.machines[index]);
                                  },
                                ));
                    },
                  )

                  // SingleChildScrollView(
                  //     physics: const BouncingScrollPhysics(),
                  //     child: GetBuilder<MachineShipSelectController>(
                  //       builder: (_) {
                  //         return Column(
                  //           children: [
                  //             ...List.generate(
                  //                 controller.machines.length,
                  //                 (index) => machineCell(
                  //                     index, controller.machines[index])),
                  //           ],
                  //         );
                  //       },
                  //     ))

                  );
            },
          ),
          GetBuilder<MachineShipSelectController>(
            id: controller.filterBuildId,
            builder: (_) {
              return GetX<MachineShipSelectController>(
                builder: (_) {
                  return AnimatedPositioned(
                    left: 0,
                    right: 0,
                    top: 45.w,
                    height: controller.isFrap ? 0 : controller.filterHeight.w,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 375.w,
                      height: controller.filterHeight.w,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            gline(345, 0.5),
                            sbhRow([
                              GetBuilder<MachineShipSelectController>(
                                builder: (_) {
                                  return getRichText("全部设备", "(共${controller.dataCount}台)", 14, AppColor.text, 14, AppColor.text3);
                                },
                              )
                            ], height: 40, width: 375 - 15.5 * 2),
                            ...List.generate(controller.commodityList.length, (int index) {
                              Map data = controller.commodityList[index];
                              return sbhRow([
                                CustomButton(
                                  onPressed: () {
                                    // data["selected"] = !data["selected"];
                                    // controller
                                    //     .update([controller.filterBuildId]);
                                    // controller.onlySelect(index, close: false);
                                  },
                                  child: SizedBox(
                                    height: 25.w,
                                    child: centRow([
                                      Image.asset(
                                        assetsName(
                                            "machine/btn_filter_${(((data["selectMachines"] ?? []) as List).length) == (data["num"] ?? 0) ? "selected" : "normal"}"),
                                        width: 16.w,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      gwb(6),
                                      getSimpleText(
                                          "${data["shopName"] ?? ""}(${(((data["selectMachines"] ?? []) as List).length)}/${data["num"] ?? 0})",
                                          14,
                                          AppColor.text),
                                    ]),
                                  ),
                                ),
                                CustomButton(
                                  onPressed: () {
                                    controller.onlySelect(index, close: false);
                                  },
                                  child: Container(
                                    height: 20.w,
                                    width: 50.w,
                                    alignment: Alignment.center,
                                    decoration:
                                        data["selected"] ? BoxDecoration(color: AppColor.theme, borderRadius: BorderRadius.circular(2.w)) : null,
                                    child: getSimpleText("只选TA", 12, data["selected"] ? Colors.white : AppColor.theme),
                                  ),
                                )
                              ], width: 375 - 15.5 * 2, height: 25);
                            })
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // GetBuilder<MachineShipSelectController>(
          //     id: controller.filterBuildId,
          //     builder: (_) {
          //       double height =
          //           0.5 + 40 + controller.commodityList.length * 25 + 10;
          //       return CustomDropDownView(
          //           height: height.w,
          //           dropDownCtrl: controller.filterCtrl,
          //           dropdownMenuChange: (isShow) {
          //             controller.isFrap = !isShow;
          //           },
          //           dropWidget: Container(
          //             width: 375.w,
          //             height: height.w,
          //             color: Colors.white,
          //             child: SingleChildScrollView(
          //               physics: const BouncingScrollPhysics(),
          //               child: Column(
          //                 children: [
          //                   gline(345, 0.5),
          //                   sbhRow([
          //                     GetBuilder<MachineShipSelectController>(
          //                       builder: (_) {
          //                         return getRichText(
          //                             "全部设备",
          //                             "(共${controller.dataCount}台)",
          //                             14,
          //                             AppColor.text,
          //                             14,
          //                             AppColor.text3);
          //                       },
          //                     )
          //                   ], height: 40, width: 375 - 15.5 * 2),
          //                   ...List.generate(controller.commodityList.length,
          //                       (int index) {
          //                     Map data = controller.commodityList[index];
          //                     return sbhRow([
          //                       CustomButton(
          //                         onPressed: () {
          //                           // data["selected"] = !data["selected"];
          //                           // controller
          //                           //     .update([controller.filterBuildId]);
          //                           controller.onlySelect(index, close: false);
          //                         },
          //                         child: SizedBox(
          //                           height: 25.w,
          //                           child: centRow([
          //                             Image.asset(
          //                               assetsName(
          //                                   "machine/btn_filter_${(data["selected"] ?? false) ? "selected" : "normal"}"),
          //                               width: 16.w,
          //                               fit: BoxFit.fitWidth,
          //                             ),
          //                             gwb(6),
          //                             getSimpleText(
          //                                 "${data["shopName"] ?? ""}(${index + 1}/${controller.commodityList.length})",
          //                                 14,
          //                                 AppColor.text),
          //                           ]),
          //                         ),
          //                       ),
          //                       CustomButton(
          //                         onPressed: () {
          //                           controller.onlySelect(index);
          //                         },
          //                         child: SizedBox(
          //                           height: 25.w,
          //                           width: 50.w,
          //                           child: Align(
          //                             alignment: Alignment.centerRight,
          //                             child: getSimpleText(
          //                                 "只选TA", 12, AppColor.theme),
          //                           ),
          //                         ),
          //                       )
          //                     ], width: 375 - 15.5 * 2, height: 25);
          //                   })
          //                 ],
          //               ),
          //             ),
          //           ));
          //     }),
        ],
      ),
    );
  }

  Widget machineCell(int index, Map data) {
    bool isActive = data["isBinding"] == 1;
    return CustomButton(
      onPressed: () {
        if (isActive) {
          return;
        }
        controller.listCellSelect(data, index);
      },
      child: Container(
        width: 345.w,
        height: 75.w,
        margin: EdgeInsets.only(top: 15.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3.w)),
        child: Center(
          child: sbhRow([
            centRow([
              isActive
                  ? Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: AppColor.pageBackgroundColor,
                          border: Border.all(width: 1.w, color: AppColor.text3)),
                    )
                  : Image.asset(
                      assetsName("machine/checkbox_${(data["selected"] ?? false) ? "selected" : "normal"}"),
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
                getSimpleText(data["tbName"] ?? "", 15, AppColor.text, isBold: true),
                ghb(5),
                getSimpleText("设备编号：${data["tNo"] ?? ""}", 12, AppColor.text),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ]),
            centRow([
              Container(
                width: 7.5.w,
                height: 7.5.w,
                decoration:
                    BoxDecoration(color: isActive ? AppColor.assisText : const Color(0xFF3AD3D2), borderRadius: BorderRadius.circular(7.5.w / 2)),
              ),
              gwb(5),
              getSimpleText(data["tStatus"] ?? "", 12, AppColor.text2)
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
            sbhRow([getSimpleText("搜索区间", 15, AppColor.text, isBold: true)], height: 55, width: 375 - 15 * 2),
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
                      textEditCtrl: index == 0 ? controller.startInputCtrl : controller.endInputCtrl,
                      width: (345 - 15 - 50 - 0.1 - 1).w,
                      heigth: 40.w,
                      placeholder: "请输入${index == 0 ? "开始" : "结束"}设备编号",
                      style: TextStyle(fontSize: 12.sp, color: AppColor.text),
                      placeholderStyle: TextStyle(fontSize: 12.sp, color: AppColor.assisText),
                    ),
                    AppDefault().appHideScan()
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
                        color: index == 0 ? AppColor.theme.withOpacity(0.1) : AppColor.theme,
                        child: Center(
                          child: getSimpleText(index == 0 ? "重置" : "确定", 15, index == 0 ? AppColor.theme : Colors.white),
                        ),
                      ),
                    )),
          )
        ],
      ),
    ));
  }
}
