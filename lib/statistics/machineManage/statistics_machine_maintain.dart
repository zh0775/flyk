import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineManage/statistics_machine_maintain_add.dart';
import 'package:cxhighversion2/statistics/machineManage/statistics_machine_maintain_detail.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatisticsMachineMaintainBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineMaintainController>(
        StatisticsMachineMaintainController(datas: Get.arguments));
  }
}

class StatisticsMachineMaintainController extends GetxController {
  final dynamic datas;
  StatisticsMachineMaintainController({this.datas});

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (isPageAnimate) {
      return;
    }
    if (_topIndex.value != v) {
      _topIndex.value = v;
      loadData(loadIdx: topIndex);
      changePage(topIndex);
    }
  }

  List listStatus = [
    {"id": -1, "name": "全部"},
    {"id": 0, "name": "待审核"},
    {"id": 1, "name": "已同意"},
    {"id": 2, "name": "已驳回"},
    {"id": 3, "name": "已作废"},
  ];

  bool isPageAnimate = false;

  changePage(int? toIdx) {
    if (isPageAnimate) {
      return;
    }
    isPageAnimate = true;
    int idx = toIdx ?? topIndex;
    pageCtrl
        .animateToPage(idx,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut)
        .then((value) {
      isPageAnimate = false;
    });
  }

  PageController pageCtrl = PageController();
  TextEditingController searchInputCtrl = TextEditingController();

  List<int> pageSizes = [
    20,
    20,
    20,
    20,
    20,
  ];
  List<int> pageNos = [1, 1, 1, 1, 1];
  List<int> counts = [0, 0, 0, 0, 0];
  List<RefreshController> pullCtrls = [
    RefreshController(),
    RefreshController(),
    RefreshController(),
    RefreshController(),
    RefreshController(),
  ];
  List<List> dataLists = [
    [],
    [],
    [],
    [],
    [],
  ];

  onRefresh(int refreshIdx) {
    loadData(loadIdx: refreshIdx);
  }

  onLoad(int loadIdx) {
    loadData(isLoad: true, loadIdx: loadIdx);
  }

  searchAction() {
    loadData(searchText: searchInputCtrl.text);
  }

  String typeStr(int type) {
    switch (type) {
      case 0:
        return "设备更换";
      case 1:
        return "设备维修";
    }
    return "";
  }

  String loadListBuildId = "StatisticsMachineMaintain_loadListBuildId_";

  loadData({bool isLoad = false, int? loadIdx, String? searchText}) {
    int myLoadIdx = loadIdx ?? topIndex;
    isLoad ? pageNos[myLoadIdx]++ : pageNos[myLoadIdx] = 1;
    if (dataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "pageNo": pageNos[myLoadIdx],
      "pageSize": pageSizes[myLoadIdx],
      "d_Type": listStatus[myLoadIdx]["id"],
    };
    if (searchInputCtrl.text.isNotEmpty) {
      params["username"] = searchInputCtrl.text;
    }
    simpleRequest(
      url: Urls.userFeaturesApplyList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myLoadIdx] = data["count"] ?? 0;
          List mDatas = data["data"] ?? [];
          dataLists[myLoadIdx] =
              isLoad ? [...dataLists[myLoadIdx], ...mDatas] : mDatas;
          isLoad
              ? pullCtrls[myLoadIdx].loadComplete()
              : pullCtrls[myLoadIdx].refreshCompleted();
          update(["$loadListBuildId$myLoadIdx"]);
        } else {
          isLoad
              ? pullCtrls[myLoadIdx].loadFailed()
              : pullCtrls[myLoadIdx].refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );

    // Future.delayed(const Duration(milliseconds: 200), () {
    //   counts[myLoadIdx] = 100;
    //   List datas = [];
    //   for (var i = 0; i < pageSizes[myLoadIdx]; i++) {
    //     datas.add({
    //       "id": dataLists[myLoadIdx].length + i,
    //       "type": i % 2,
    //       "addTime": "2023-02-13 20:21:20",
    //       "no": "2102523020156150",
    //       "reason": "设备无响应，无法开机",
    //       "status": i % 4,
    //       "toMe": i % 3,
    //       "userImg": "D0031/2023/2/20230201214710P4FVH.jpg",
    //       "userName": "李文敏",
    //       "ono": "2523020156150123",
    //       "nno": "2523020156150125",
    //       "machine": {
    //         "id": 123,
    //         "img": "D0031/2023/1/202301311856422204X.png",
    //         "name": "嘉联电签K300",
    //         "tNo": "T550006698",
    //         "status": 0,
    //         "addTime": "2020-01-23 13:26:09",
    //       }
    //     });
    //   }

    //   dataLists[myLoadIdx] =
    //       isLoad ? [...dataLists[myLoadIdx], ...datas] : datas;
    //   update(["$loadListBuildId$myLoadIdx"]);
    //   isLoad
    //       ? pullCtrls[myLoadIdx].loadComplete()
    //       : pullCtrls[myLoadIdx].refreshCompleted();
    //   isLoading = false;
    // });
  }

  backoutAction(Map data) {
    simpleRequest(
      url: Urls.featuresOverRefuse(data["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadData();
        }
      },
      after: () {},
    );
  }

  agreeAction(Map data) {
    loadData();
  }

  rejectAction(Map data) {
    simpleRequest(
      url: Urls.featuresWithdraw(data["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadData();
        }
      },
      after: () {},
    );
  }

  @override
  void onInit() {
    loadData();
    Map data = AppDefault().homeData;
    super.onInit();
  }

  @override
  void onClose() {
    for (var e in pullCtrls) {
      e.dispose();
    }
    searchInputCtrl.dispose();
    pageCtrl.dispose();
    super.onClose();
  }
}

class StatisticsMachineMaintain
    extends GetView<StatisticsMachineMaintainController> {
  const StatisticsMachineMaintain({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "维修工单", action: [
          CustomButton(
            onPressed: () {
              push(const StatisticsMachineMaintainAdd(), context,
                  binding: StatisticsMachineMaintainAddBinding());
            },
            child: SizedBox(
              height: kToolbarHeight,
              width: 80.w,
              child: Center(
                child: centRow([
                  Image.asset(
                    assetsName("statistics/machine/btn_navi_add"),
                    width: 24.w,
                    fit: BoxFit.fitWidth,
                  ),
                  gwb(1.5),
                  getSimpleText("新建", 14, AppColor.text2)
                ]),
              ),
            ),
          )
        ]),
        body: Stack(
          children: [
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
                top: 56.w,
                left: 0,
                right: 0,
                height: 55.w,
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Positioned(
                          top: 20.w,
                          left: 0,
                          right: 0,
                          height: 20.w,
                          child: Row(
                            children: List.generate(
                                controller.listStatus.length, (index) {
                              return CustomButton(
                                onPressed: () {
                                  controller.topIndex = index;
                                },
                                child:
                                    GetX<StatisticsMachineMaintainController>(
                                        builder: (_) {
                                  return SizedBox(
                                    width: 375.w / 5 - 0.1.w,
                                    child: Center(
                                      child: getSimpleText(
                                        controller.listStatus[index]["name"],
                                        15,
                                        controller.topIndex == index
                                            ? AppColor.theme
                                            : AppColor.text2,
                                        isBold: controller.topIndex == index,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          )),
                      GetX<StatisticsMachineMaintainController>(
                        builder: (_) {
                          return AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              top: 47.w,
                              width: 15.w,
                              left: controller.topIndex * (375.w / 5 - 0.1.w) +
                                  ((375.w / 5 - 0.1.w) - 15.w) / 2,
                              height: 2.w,
                              child: Container(
                                color: AppColor.theme,
                              ));
                        },
                      )
                    ],
                  ),
                )),
            Positioned.fill(
                top: 111.w,
                child: PageView.builder(
                  controller: controller.pageCtrl,
                  itemCount: controller.dataLists.length,
                  onPageChanged: (value) {
                    controller.topIndex = value;
                  },
                  itemBuilder: (context, index) {
                    return list(index);
                  },
                ))
          ],
        ),
      ),
    );
  }

  Widget list(int listIdx) {
    return GetBuilder<StatisticsMachineMaintainController>(
      id: "${controller.loadListBuildId}$listIdx",
      builder: (_) {
        return SmartRefresher(
          controller: controller.pullCtrls[listIdx],
          onLoading: () => controller.onLoad(listIdx),
          onRefresh: () => controller.onRefresh(listIdx),
          enablePullUp:
              controller.counts[listIdx] > controller.dataLists[listIdx].length,
          child: controller.dataLists[listIdx].isEmpty
              ? GetX<StatisticsMachineMaintainController>(
                  builder: (_) {
                    return CustomEmptyView(
                      isLoading: controller.isLoading,
                    );
                  },
                )
              : ListView.builder(
                  itemCount: controller.dataLists[listIdx].length,
                  padding: EdgeInsets.only(bottom: 20.w),
                  itemBuilder: (context, index) {
                    return maintainCell(
                        index, controller.dataLists[listIdx][index]);
                  },
                ),
        );
      },
    );
  }

  Widget maintainCell(int index, Map data) {
    int maintainStatus = data["featuresApply_Flag"] ?? -1;
    bool toMe = (data["orderType"] ?? 1) == 0;

    Color textColor = AppColor.theme;
    String statusStr = "";
    switch (maintainStatus) {
      case 0:
        textColor = AppColor.theme;
        statusStr = "待审核";
        break;
      case 1:
        textColor = AppColor.text2;
        statusStr = "已同意";
        break;
      case 2:
        textColor = AppColor.red;
        statusStr = "已驳回";
        break;
      case 3:
        textColor = AppColor.red;
        statusStr = "已作废";
        break;
    }

    return Align(
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        width: 345.w,
        // height: maintainStatus == 0 ? 180.w : 165.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: Column(
          children: [
            sbhRow([
              toMe
                  ? centRow([
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.w),
                        child: CustomNetworkImage(
                          src: AppDefault().imageUrl + (data["u_Avatar"] ?? ""),
                          width: 20.w,
                          height: 20.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      gwb(5),
                      getSimpleText(
                          data["u_Name"] != null && data["u_Name"].isNotEmpty
                              ? data["u_Name"]
                              : data["u_Mobile"] ?? "",
                          12,
                          AppColor.text,
                          isBold: true),
                      gwb(4.5),
                      getSimpleText("发起的", 12, AppColor.text3),
                    ])
                  : getSimpleText(
                      "订单编号：${data["orderNo"] ?? ""}", 12, AppColor.text2,
                      isBold: true),
              getSimpleText(statusStr, 12, textColor)
            ], width: 345 - 15 * 2, height: 40),
            gline(315, 0.5),
            SizedBox(
                // height: maintainStatus == 0 ? 99.5.w : 124.5.w,
                child: sbRow([
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ghb(6),
                  infoCell("工单类型", "维修工单"),
                  infoCell("创建时间", data["addTime"] ?? ""),
                  infoCell("维修设备号", data["oldTerminalNo"] ?? ""),
                  maintainStatus == 1
                      ? infoCell("新设备编号", data["newTerminalNo"] ?? "")
                      : ghb(0),
                  ghb(2.5),
                  sbRow([
                    getWidthText("故障原因", 12, AppColor.text3, 66.5, 1,
                        textHeight: 1.3),
                    getWidthText("${data["cause"] ?? ""}", 12, AppColor.text2,
                        315 - 66.5 - (maintainStatus > 0 ? 68.5 : 0), 10,
                        textHeight: 1.3),
                  ],
                      width: 315 - (maintainStatus > 0 ? 68.5 : 0),
                      crossAxisAlignment: CrossAxisAlignment.start),
                  ghb(10),
                ],
              ),
              maintainStatus != 0
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 15.w),
                      child: Image.asset(
                        assetsName(
                            "statistics/machine/icon_${maintainStatus == 1 ? "ty" : maintainStatus == 2 ? "bh" : "zf"}"),
                        width: 68.5.w,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                  : gwb(0),
            ], width: 315, crossAxisAlignment: CrossAxisAlignment.end)),
            maintainStatus == 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: toMe
                        ? [
                            cellBtn(0, data),
                            gwb(10),
                            cellBtn(1, data),
                            gwb(10),
                            cellBtn(2, data),
                            gwb(15),
                          ]
                        : [
                            cellBtn(0, data),
                            gwb(10),
                            cellBtn(3, data),
                            gwb(15),
                          ],
                  )
                : ghb(0),
            ghb(10),
          ],
        ),
      ),
    );
  }

  Widget cellBtn(int type, Map data, {Function()? onPressed}) {
    int maintainStatus = data["featuresApply_Flag"] ?? -1;
    bool toMe = (data["orderType"] ?? 1) == 0;
    String title = "";
    switch (type) {
      case 0:
        title = "查看详情";
        break;
      case 1:
        title = "拒绝";
        break;
      case 2:
        title = "同意";
        break;
      case 3:
        title = "撤销申请";
        break;
    }

    return CustomButton(
      onPressed: () {
        if (type == 0) {
          push(const StatisticsMachineMaintainDetail(), null,
              binding: StatisticsMachineMaintainDetailBinding(),
              arguments: {
                "data": data,
              });
        } else if (type == 1) {
          showAlert(
            Global.navigatorKey.currentContext!,
            "确认要拒绝该维修单吗？",
            confirmOnPressed: () {
              Get.back();
              controller.rejectAction(data);
            },
          );
        } else if (type == 2) {
          push(const StatisticsMachineMaintainDetail(), null,
              binding: StatisticsMachineMaintainDetailBinding(),
              arguments: {
                "data": data,
              });
          // showAlert(
          //   Global.navigatorKey.currentContext!,
          //   "确认要同意该维修单吗？",
          //   confirmOnPressed: () {
          //     Get.back();
          //     controller.agreeAction(data);
          //   },
          // );
        } else if (type == 3) {
          showAlert(
            Global.navigatorKey.currentContext!,
            "确认要撤销该维修单吗？",
            confirmOnPressed: () {
              Get.back();
              controller.backoutAction(data);
            },
          );
        }
      },
      child: Container(
        width: 65.w,
        height: 25.w,
        decoration: BoxDecoration(
            color: type == 2 ? AppColor.theme : Colors.white,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
                width: type == 2 ? 0 : 0.5.w,
                color: type == 2 ? Colors.transparent : AppColor.textGrey5)),
        child: Center(
          child: getSimpleText(
              title, 12, type == 2 ? Colors.white : AppColor.text2),
        ),
      ),
    );
  }

  Widget infoCell(String t1, String t2,
      {double width = 62, double width2 = 180, double height = 20}) {
    return SizedBox(
      height: height.w,
      child: Center(
          child: Row(
        children: [
          getWidthText(t1, 12, AppColor.text3, width, 1, textHeight: 1.3),
          gwb(4.5),
          getWidthText(t2, 12, AppColor.text2, width2, 1, textHeight: 1.3),
        ],
      )),
    );
  }
}
