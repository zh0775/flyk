import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/machine/machine_order_aftersale.dart';
import 'package:cxhighversion2/machine/machine_order_launch.dart';
import 'package:cxhighversion2/machine/machine_order_receive.dart';
import 'package:cxhighversion2/machine/machine_order_ship.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineOrderListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineOrderListController>(MachineOrderListController());
  }
}

class MachineOrderListController extends GetxController {
  MachineOrderUtil util = MachineOrderUtil();
  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (!topAnimation) {
      _topIndex.value = v;
      changePage(topIndex);
      loadData(index: topIndex);
    }
  }

  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();

  CustomDropDownController typeDropCtrl = CustomDropDownController();
  CustomDropDownController advancedDropCtrl = CustomDropDownController();
  TextEditingController searchInputCtrl = TextEditingController();

  final _typeFilterShow = false.obs;
  bool get typeFilterShow => _typeFilterShow.value;
  set typeFilterShow(v) => _typeFilterShow.value = v;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _typeFilterIndex = 0.obs;
  int get typeFilterIndex => _typeFilterIndex.value;
  set typeFilterIndex(v) => _typeFilterIndex.value = v;

  final _machineFilterIndex = 0.obs;
  int get machineFilterIndex => _machineFilterIndex.value;
  set machineFilterIndex(v) => _machineFilterIndex.value = v;

  final _orderFilterIndex = 0.obs;
  int get orderFilterIndex => _orderFilterIndex.value;
  set orderFilterIndex(v) => _orderFilterIndex.value = v;

  final _payFilterIndex = 0.obs;
  int get payFilterIndex => _payFilterIndex.value;
  set payFilterIndex(v) => _payFilterIndex.value = v;

  int realOrderIndex = 0;
  int realMachineIndex = 0;
  int realPayIndex = 0;

  showAFilter() {
    machineFilterIndex = realMachineIndex;
    orderFilterIndex = realOrderIndex;
    payFilterIndex = realPayIndex;
    advancedDropCtrl.show(stackKey, headKey);
  }

  hideAFilter() {
    advancedDropCtrl.hide();
  }

  confirmAFilter() {
    realMachineIndex = machineFilterIndex;
    realOrderIndex = orderFilterIndex;
    realPayIndex = payFilterIndex;
    advancedDropCtrl.hide();
    loadData();
  }

  resetAFilter() {
    machineFilterIndex = 0;
    orderFilterIndex = 0;
    payFilterIndex = 0;
    realMachineIndex = machineFilterIndex;
    realOrderIndex = orderFilterIndex;
    realPayIndex = payFilterIndex;
  }

  Map typeData = {
    "machine": [
      {"id": -1, "name": "全部"},
    ],
    "order": [
      {
        "id": -1,
        "name": "全部",
      },
      {
        "id": 1,
        "name": "采购单",
      },
      {
        "id": 2,
        "name": "换货单",
      },
      {
        "id": 3,
        "name": "退货单",
      },
    ],
    "pay": [
      {"id": 0, "name": "全部"},
      {"id": 3, "name": "线下付款"},
    ]
  };

  bool topAnimation = false;

  PageController pageController = PageController();

  String listBuildId = "MachineOrderList_listBuildId_";

  List<RefreshController> pullCtrls = [
    RefreshController(),
    RefreshController()
  ];

  changePage(int index) {
    topAnimation = true;
    pageController
        .animateToPage(index,
            duration: const Duration(milliseconds: 300), curve: Curves.linear)
        .then((value) {
      topAnimation = false;
    });
  }

  buttonsClick(MachineOrderBtnType type, int listIdx, int index) {
    Map data = dataLists[listIdx][index];
    int orderType2 = data["orderType2"] ?? -1;
    if (orderType2 == 2 || orderType2 == 3) {
      if (type == MachineOrderBtnType.afterSafeDetail) {
        push(const MachineOrderAftersale(), null,
            binding: MachineOrderAftersaleBinding(),
            arguments: {
              "orderData": {
                "id": data["aSaleID"] != null && data["aSaleID"] > 0
                    ? data["aSaleID"]
                    : data["id"]
              },
              "isMine": listIdx == 0
            });
      }
      return;
    }

    if (listIdx == 0) {
      push(const MachineOrderLaunch(), null,
          binding: MachineOrderLaunchBinding(),
          arguments: {"orderData": dataLists[listIdx][index]});
      if (type == MachineOrderBtnType.cancel) {
        util.loadCancelOrder(
          dataLists[listIdx][index]["id"],
          result: (succ) {
            if (succ) {
              loadData(index: listIdx);
            }
          },
        );
      } else if (type == MachineOrderBtnType.delete) {
        util.loadDeleteOrder(
          dataLists[listIdx][index]["id"],
          result: (succ) {
            if (succ) {
              loadData(index: listIdx);
            }
          },
        );
      } else if (type == MachineOrderBtnType.confirmTake) {
        util.loadConfirmTake(
          dataLists[listIdx][index]["id"],
          result: (succ) {
            if (succ) {
              loadData(index: listIdx);
            }
          },
        );
      } else if (type == MachineOrderBtnType.machineList) {
        push(const MachineOrderLaunch(), null,
            binding: MachineOrderLaunchBinding(),
            arguments: {"orderData": data});
      }
    } else {
      if (type == MachineOrderBtnType.confirmPay) {
        util.loadCheckPayOrder(
          dataLists[listIdx][index]["id"],
          result: (succ) {
            if (succ) {
              loadData(index: listIdx);
            }
          },
        );
      } else if (type == MachineOrderBtnType.invalid) {
        util.loadInvalidOrder(
          dataLists[listIdx][index]["id"],
          result: (succ) {
            if (succ) {
              loadData(index: listIdx);
            }
          },
        );
      } else if (type == MachineOrderBtnType.immediatedelivery) {
        push(const MachineOrderShip(), null,
            binding: MachineOrderShipBinding(),
            arguments: {
              "orderData": dataLists[listIdx][index],
            });
      } else if (type == MachineOrderBtnType.aftersaleImmediatedelivery) {
        ShowToast.normal("请到售后订单中发货");
        return;
      } else if (type == MachineOrderBtnType.machineList) {
        push(const MachineOrderReceive(), null,
            binding: MachineOrderReceiveBinding(),
            arguments: {"orderData": data});
      }
    }
  }

  List pageNos = [1, 1];
  List pageSizes = [20, 20];
  List counts = [0, 0];

  List<List> dataLists = [[], []];

  onRefresh() {
    loadData();
  }

  onLoad() {
    loadData(isLoad: true);
  }

  List statusList = [
    {"id": -1, "name": "全部"},
    {"id": 0, "name": "待支付"},
    {"id": 1, "name": "已支付"},
    {"id": 2, "name": "待收货"},
    {"id": 3, "name": "已完成"},
    {"id": 4, "name": "已作废"},
    {"id": 7, "name": "已取消"},
    {"id": 5, "name": "售后"},
  ];
  searchAction() {
    takeBackKeyboard(Global.navigatorKey.currentContext!);
    loadData();
  }

  loadData({bool isLoad = false, int? index}) {
    int loadIndex = index ?? topIndex;
    isLoad ? pageNos[loadIndex]++ : pageNos[loadIndex] = 1;
    if (dataLists[loadIndex].isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "order_Type": loadIndex + 1,
      "orderState": statusList[typeFilterIndex]["id"],
      "order_Type2": typeData["order"][orderFilterIndex]["id"],
      "paymentMethod": typeData["pay"][payFilterIndex]["id"],
      "pageNo": pageNos[loadIndex],
      "pageSize": pageSizes[loadIndex],
    };

    if (typeData["machine"].isNotEmpty &&
        typeData["machine"][machineFilterIndex]["id"] != -1) {
      params["tbId"] = "${typeData["machine"][machineFilterIndex]["id"]}";
    }

    if (searchInputCtrl.text.isNotEmpty) {
      params["orderNo"] = searchInputCtrl.text;
    }

    simpleRequest(
      url: Urls.userLevelGiftOrderList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[loadIndex] = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];
          dataLists[loadIndex] =
              isLoad ? [...dataLists[loadIndex], ...tmpList] : tmpList;

          isLoad
              ? pullCtrls[loadIndex].loadComplete()
              : pullCtrls[loadIndex].refreshCompleted();

          update(["$listBuildId$loadIndex"]);
        } else {
          isLoad
              ? pullCtrls[loadIndex].loadFailed()
              : pullCtrls[loadIndex].refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );

    // Future.delayed(const Duration(milliseconds: 300), () {
    //   List jsonData = List.generate(
    //       pageSize[loadIndex],
    //       (index) => {
    //             "id": index,
    //             "no": "201545130123056460",
    //             "img": "D0031/2023/1/202301311856422204X.png",
    //             "name": "融享付",
    //             "price": 128.0,
    //             "xh": "YDQ",
    //             "order_status": index % 13,
    //             ""
    //                 "product": List.generate(
    //                 index % 3,
    //                 (productIndex) => {
    //                       "id": productIndex,
    //                       "name": "融享付大机",
    //                       "xh": "YDQ",
    //                       "price": 128.0,
    //                       "img": "D0031/2023/1/202301311856422204X.png",
    //                       "num": 1,
    //                     }),
    //           });

    //   datas[loadIndex] = isLoad ? [...datas[loadIndex], ...jsonData] : jsonData;

    //   isLoad
    //       ? pullCtrls[loadIndex].loadComplete()
    //       : pullCtrls[loadIndex].refreshCompleted();
    //   isLoading = false;
    //   update(["$listBuildId$loadIndex"]);
    // });
  }

  @override
  void onInit() {
    List machineTypes = [
      {
        "id": -1,
        "name": "全部",
      }
    ];
    Map publicHomeData = AppDefault().publicHomeData;
    if (publicHomeData.isNotEmpty &&
        publicHomeData["terminalConfig"].isNotEmpty &&
        publicHomeData["terminalConfig"] is List) {
      // List.generate((publicHomeData["terminalBrand"] as List).length, (index) {
      //   Map e = (publicHomeData["terminalBrand"] as List)[index];
      //   machineTypes.add({
      //     "id": e["enumValue"] ?? -1,
      //     "name": e["enumName"] ?? "",
      //   });
      // });
      List.generate((publicHomeData["terminalConfig"] as List).length, (index) {
        Map e = (publicHomeData["terminalConfig"] as List)[index];
        machineTypes.add({
          "id": e["id"] ?? -1,
          "name": e["terninal_Name"] ?? "",
        });
      });
      typeData["machine"] = machineTypes;
    }

    loadData();
    super.onInit();
  }

  final _filterHeight = 0.0.obs;
  double get filterHeight => _filterHeight.value;
  set filterHeight(v) => _filterHeight.value = v;

  final _realFilterHeight = 0.0.obs;
  double get realFilterHeight => _realFilterHeight.value;
  set realFilterHeight(v) => _realFilterHeight.value = v;

  final _filterOverSize = false.obs;
  bool get filterOverSize => _filterOverSize.value;
  set filterOverSize(v) => _filterOverSize.value = v;
  double appBarMaxHeight = 0;
  getFilterHeight() {
    filterHeight = 0.0.w;
    List machineTypes = typeData["machine"] ?? [];

    if (machineTypes.isNotEmpty) {
      filterHeight += 56.0.w;
      int machineTypesCount = (machineTypes.length / 3).ceil();
      filterHeight += machineTypesCount * 30.0.w;
      filterHeight += (machineTypesCount - 1) * 10.0.w;
    }

    List machineStatus = typeData["order"] ?? [];
    if (machineStatus.isNotEmpty) {
      filterHeight += 56.w;
      int machineStatusCount = (machineStatus.length / 3).ceil();
      filterHeight += machineStatusCount * 30.0.w;
      filterHeight += (machineStatusCount - 1) * 10.0.w;
    }

    List payTypeList = typeData["pay"] ?? [];
    if (payTypeList.isNotEmpty) {
      filterHeight += 56.w;
      int payTypeListCount = (payTypeList.length / 3).ceil();
      filterHeight += payTypeListCount * 30.0.w;
      filterHeight += (payTypeListCount - 1) * 10.0.w;
    }

    // filterHeight += 56;
    // int currentTypesCount = (currentTypes.length / 3).ceil();
    // filterHeight += currentTypesCount * 30.0.w;
    // filterHeight += (currentTypesCount - 1) * 10.0.w;

    filterHeight += 19.0.w;
    filterHeight += 55.0.w;
    filterHeight = filterHeight * 1.0;
    double maxHeight = ScreenUtil().screenHeight - appBarMaxHeight - 105.w;
    filterOverSize = filterHeight > maxHeight;
    if (filterHeight > maxHeight) {
      realFilterHeight = filterHeight * 1.0;
      filterHeight = maxHeight * 1.0;
    } else {
      realFilterHeight = filterHeight * 1.0;
    }
  }

  @override
  void onClose() {
    for (var e in pullCtrls) {
      e.dispose();
    }
    advancedDropCtrl.dispose();
    typeDropCtrl.dispose();
    pageController.dispose();
    searchInputCtrl.dispose();
    super.onClose();
  }
}

class MachineOrderList extends GetView<MachineOrderListController> {
  const MachineOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "",
            flexibleSpace: Align(
              alignment: Alignment.bottomCenter,
              child: GetX<MachineOrderListController>(
                builder: (_) => centRow(List.generate(
                    2,
                    (index) => CustomButton(
                          onPressed: () {
                            controller.topIndex = index;
                          },
                          child: SizedBox(
                            height: kToolbarHeight,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: index != 0 ? 18.w : 0),
                                child: getSimpleText(
                                    index == 0 ? "我发起的" : "我收到的",
                                    18,
                                    controller.topIndex == index
                                        ? AppColor.text
                                        : AppColor.text3,
                                    isBold: true,
                                    textHeight: 1.5),
                              ),
                            ),
                          ),
                        ))),
              ),
            )),
        body: Builder(builder: (context) {
          controller.appBarMaxHeight =
              (Scaffold.of(context).appBarMaxHeight ?? 0);
          controller.getFilterHeight();
          return Stack(
            key: controller.stackKey,
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  width: 375.w,
                  height: 55.w,
                  child: Container(
                    color: Colors.white,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.only(top: 5.5.w),
                        width: 345.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                            color: AppColor.pageBackgroundColor,
                            borderRadius: BorderRadius.circular(20.w)),
                        child: Center(
                          child: sbRow([
                            CustomInput(
                              width: 260.w,
                              heigth: 40.w,
                              textEditCtrl: controller.searchInputCtrl,
                              placeholder: "请输入想要搜索的订单编号或设备编号",
                              style: TextStyle(
                                  fontSize: 12.sp, color: AppColor.text),
                              placeholderStyle: TextStyle(
                                  fontSize: 12.sp, color: AppColor.assisText),
                              onSubmitted: (p0) {
                                controller.searchAction();
                              },
                            ),
                            CustomButton(
                              onPressed: () {
                                controller.searchAction();
                              },
                              child: SizedBox(
                                height: 40.w,
                                width: 40.w,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Image.asset(
                                    assetsName("machine/icon_search"),
                                    width: 18.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            )
                          ], width: 345 - 20.5 * 2),
                        ),
                      ),
                    ),
                  )),
              Positioned(
                  top: 55.w,
                  left: 0,
                  right: 0,
                  height: 50.w,
                  key: controller.headKey,
                  child: Container(
                    color: Colors.white,
                    child: sbhRow([
                      CustomButton(onPressed: () {
                        if (controller.advancedDropCtrl.isShow) {
                          controller.advancedDropCtrl.hide();
                        }
                        if (controller.typeDropCtrl.isShow) {
                          controller.typeDropCtrl.hide();
                        } else {
                          controller.typeDropCtrl
                              .show(controller.stackKey, controller.headKey);
                        }
                        controller.typeFilterShow =
                            controller.typeDropCtrl.isShow;
                      }, child: GetX<MachineOrderListController>(
                        builder: (_) {
                          return centRow([
                            ghb(50),
                            gwb(15.5),
                            getSimpleText("订单状态：", 13, AppColor.text3,
                                textHeight: 1.3),
                            getSimpleText(
                                controller
                                        .statusList[controller.typeFilterIndex]
                                    ["name"],
                                13,
                                AppColor.text2,
                                textHeight: 1.3),
                            gwb(5),
                            GetX<MachineOrderListController>(
                              builder: (_) {
                                return AnimatedRotation(
                                  turns: controller.typeFilterShow ? 0.5 : 1,
                                  duration: const Duration(milliseconds: 300),
                                  child: Image.asset(
                                    assetsName("machine/icon_down"),
                                    width: 6.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                );
                              },
                            )
                          ]);
                        },
                      )),
                      CustomButton(
                        onPressed: () {
                          if (controller.typeDropCtrl.isShow) {
                            controller.typeDropCtrl.hide();
                          }
                          if (controller.advancedDropCtrl.isShow) {
                            controller.advancedDropCtrl.hide();
                          } else {
                            controller.showAFilter();
                          }
                          controller.typeFilterShow =
                              controller.typeDropCtrl.isShow;
                        },
                        child: centRow([
                          ghb(50),
                          Image.asset(
                            assetsName("common/btn_filter"),
                            width: 23.w,
                            fit: BoxFit.fitWidth,
                          ),
                          gwb(5),
                          getSimpleText("高级筛选", 13, AppColor.text2,
                              textHeight: 1.3),
                          gwb(15)
                        ]),
                      ),
                    ], width: 375, height: 50),
                  )),
              Positioned.fill(
                  top: 105.w,
                  child: PageView(
                    controller: controller.pageController,
                    onPageChanged: (value) {
                      controller.topIndex = value;
                    },
                    children: [
                      list(0),
                      list(1),
                    ],
                  )),
              CustomDropDownView(
                  height: controller.statusList.length * 40.w + 10.w + 1.w,
                  dropDownCtrl: controller.typeDropCtrl,
                  tapMaskHide: () {
                    controller.typeFilterShow = false;
                  },
                  dropWidget: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(
                                width: 0.5.w, color: AppColor.lineColor))),
                    width: 375.w,
                    height: controller.statusList.length * 40.w + 20.w,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ghb(5),
                          ...List.generate(controller.statusList.length,
                              (index) {
                            return CustomButton(
                              onPressed: () {
                                controller.typeFilterIndex = index;
                                controller.typeDropCtrl.hide();
                                controller.typeFilterShow = false;
                                controller.loadData();
                              },
                              child: sbhRow([
                                getSimpleText(
                                    controller.statusList[index]["name"],
                                    14,
                                    AppColor.text2)
                              ], width: 375 - 15.5 * 2, height: 40),
                            );
                          }),
                          ghb(5),
                        ],
                      ),
                    ),
                  )),
              GetX<MachineOrderListController>(
                builder: (_) {
                  return CustomDropDownView(
                      height: controller.filterHeight,
                      dropDownCtrl: controller.advancedDropCtrl,
                      dropWidget: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                top: BorderSide(
                                    width: 0.5.w, color: AppColor.lineColor))),
                        width: 375.w,
                        height: controller.filterHeight,
                        child: aFilterView(),
                      ));
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget list(int index) {
    return GetBuilder<MachineOrderListController>(
      id: "${controller.listBuildId}$index",
      builder: (_) {
        return SmartRefresher(
          controller: controller.pullCtrls[index],
          onLoading: controller.onLoad,
          onRefresh: controller.onRefresh,
          enablePullUp:
              controller.counts[index] > controller.dataLists[index].length,
          child: controller.dataLists[index].isEmpty
              ? GetX<MachineOrderListController>(
                  builder: (_) {
                    return CustomEmptyView(
                      isLoading: controller.isLoading,
                    );
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 20.w),
                  itemCount: controller.dataLists[index].length,
                  itemBuilder: (context, cellIndex) {
                    return cell(cellIndex,
                        controller.dataLists[index][cellIndex], index);
                  },
                ),
        );
      },
    );
  }

  Widget cell(int index, Map data, int listIdx) {
    Color bgColor = Colors.transparent;
    Color textColor = Colors.transparent;
    String text = "";
    int orderType2 = data["orderType2"] ?? -1;
    switch (orderType2) {
      case 1:
        bgColor = AppColor.theme.withOpacity(0.1);
        textColor = AppColor.theme;
        text = "采购单";
        break;
      case 2:
        bgColor = const Color(0xFFFFB72D).withOpacity(0.1);
        textColor = const Color(0xFFFFB72D);
        text = "换货单";
        break;
      case 3:
        bgColor = const Color(0xFFF93635).withOpacity(0.1);
        textColor = const Color(0xFFF93635);
        text = "退货单";
        break;
    }

    return CustomButton(
      onPressed: () {
        if (orderType2 == 2 || orderType2 == 3) {
          push(const MachineOrderAftersale(), null,
              binding: MachineOrderAftersaleBinding(),
              arguments: {
                "orderData": {
                  "id": data["aSaleID"] != null && data["aSaleID"] > 0
                      ? data["aSaleID"]
                      : data["id"]
                },
                "isMine": listIdx == 0
              });
        } else if (listIdx == 0) {
          push(const MachineOrderLaunch(), null,
              binding: MachineOrderLaunchBinding(),
              arguments: {"orderData": data});
        } else {
          push(const MachineOrderReceive(), null,
              binding: MachineOrderReceiveBinding(),
              arguments: {"orderData": data});
        }
      },
      child: Align(
        child: Container(
          margin: EdgeInsets.only(top: 15.w),
          width: 345.w,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
          child: Column(
            children: [
              sbRow([
                centRow([
                  gwb(15.5),
                  SizedBox(
                    height: 40.w,
                    child: Center(
                      child: getSimpleText(
                          "订单号：${data["orderNo"] ?? ""}", 10, AppColor.text3),
                    ),
                  ),
                ]),
                Container(
                  width: 50.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.w),
                        bottomLeft: Radius.circular(8.w),
                      )),
                  child: Align(child: getSimpleText(text, 10, textColor)),
                ),
              ], width: 345, crossAxisAlignment: CrossAxisAlignment.start),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.w),
                child: Container(
                  width: 315.w,
                  color: AppColor.pageBackgroundColor,
                  child: Column(
                    children: List.generate((data["commodity"] ?? []).length,
                        (index) {
                      Map product = data["commodity"][index];
                      return SizedBox(
                        width: 315.w,
                        child: centClm([
                          gwb(315),
                          ghb(8),
                          sbRow([
                            CustomNetworkImage(
                              src: AppDefault().imageUrl +
                                  (product["shopImg"] ?? ""),
                              width: 80.w,
                              height: 80.w,
                              fit: BoxFit.fill,
                            ),
                            centClm([
                              getWidthText(product["shopName"] ?? "", 15,
                                  AppColor.text, 315 - 10 * 2 - 80 - 10, 2,
                                  isBold: true),
                              sbRow([
                                getWidthText(
                                    "型号：${product["shopModel"] ?? ""}",
                                    12,
                                    AppColor.text3,
                                    315 - 10 * 2 - 80 - 10 - 30,
                                    2),
                                getSimpleText("X${data["num"] ?? 1}", 12,
                                    AppColor.textGrey5)
                              ], width: 315 - 10 * 2 - 80 - 10),
                              getWidthText(
                                  "￥${priceFormat(product["nowPrice"] ?? 0)}",
                                  15,
                                  const Color(0xFFF93635),
                                  315 - 10 * 2 - 80 - 10,
                                  2,
                                  isBold: true),
                            ])
                          ], width: 315 - 10 * 2),
                          ghb(8),
                        ]),
                      );
                    }),
                  ),
                ),
              ),
              sbhRow([
                getSimpleText(data["orderStateStr"] ?? "", 12, AppColor.text2),
                controller.util.getButtons(data["orderState"] ?? -1,
                    orderType: orderType2 == 2 || orderType2 == 3
                        ? MachineOrderType.aftersale
                        : listIdx == 0
                            ? MachineOrderType.sponsor
                            : MachineOrderType.receive,
                    detail: false, onPressed: (type) {
                  controller.buttonsClick(
                    type,
                    listIdx,
                    index,
                  );
                }, parenID: data["parenID"] ?? 0)
                // buttons(data["order_status"] ?? -1, index),
              ], width: 345 - 15 * 2, height: 50)
            ],
          ),
        ),
      ),
    );
  }

  Widget aFilterView() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: controller.filterHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 375.w,
              height: controller.filterHeight - 55.w,
              child: GetX<MachineOrderListController>(
                builder: (_) {
                  return SingleChildScrollView(
                    physics: controller.filterOverSize
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: GetX<MachineOrderListController>(
                      builder: (_) {
                        return SizedBox(
                          width: 375.w,
                          height: controller.realFilterHeight - 55.w,
                          child: Column(
                            children: [
                              ghb(12),
                              aFilterCell(0),
                              ghb(12),
                              aFilterCell(1),
                              ghb(12),
                              aFilterCell(2),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            sbhRow(
                List.generate(2, (index) {
                  return CustomButton(
                    onPressed: () {
                      if (index == 0) {
                        controller.resetAFilter();
                      } else {
                        controller.confirmAFilter();
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
                  );
                }),
                width: 375,
                height: 55)
          ],
        ),
      ),
    );
  }

  Widget aFilterCell(int idx) {
    List datas = [];

    switch (idx) {
      case 0:
        datas = controller.typeData["machine"];
        break;
      case 1:
        datas = controller.typeData["order"];
        break;
      case 2:
        datas = controller.typeData["pay"];
        break;
      default:
    }

    return Column(
      children: [
        sbRow([
          getSimpleText(
              idx == 0
                  ? "设备类型"
                  : idx == 1
                      ? "订单类型"
                      : "付款类型",
              15,
              AppColor.text,
              isBold: true),
        ], width: 375 - 15.5 * 2),
        ghb(12),
        SizedBox(
          width: 375.w - 15.w * 2,
          child: Wrap(
            spacing: 15.w,
            runSpacing: 10.w,
            children: List.generate(datas.length, (index) {
              Map machineData = datas[index];
              return CustomButton(
                onPressed: () {
                  if (idx == 0) {
                    controller.machineFilterIndex = index;
                  } else if (idx == 1) {
                    controller.orderFilterIndex = index;
                  } else if (idx == 2) {
                    controller.payFilterIndex = index;
                  }
                },
                child: GetX<MachineOrderListController>(builder: (_) {
                  return Container(
                    width: 105.w - 0.1.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                        color: (idx == 0
                                    ? controller.machineFilterIndex
                                    : idx == 1
                                        ? controller.orderFilterIndex
                                        : controller.payFilterIndex) ==
                                index
                            ? AppColor.theme
                            : AppColor.theme.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.w)),
                    child: Center(
                      child: getSimpleText(
                          machineData["name"] ?? "",
                          12,
                          (idx == 0
                                      ? controller.machineFilterIndex
                                      : idx == 1
                                          ? controller.orderFilterIndex
                                          : controller.payFilterIndex) ==
                                  index
                              ? Colors.white
                              : AppColor.text2,
                          textHeight: 1.3),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }
}
