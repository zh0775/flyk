import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatisticsMachineReplenishmentBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineReplenishmentController>(
        StatisticsMachineReplenishmentController());
  }
}

class StatisticsMachineReplenishmentController extends GetxController {
  final dynamic datas;
  StatisticsMachineReplenishmentController({this.datas});

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

  List statusList = [
    {"id": -1, "name": "全部"},
    {"id": 0, "name": "开始"},
  ];
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
      "tStatus": statusList[myLoadIdx]["id"],
    };

    if (searchInputCtrl.text.isNotEmpty) {
      params["uInfo"] = searchInputCtrl.text;
    }

    simpleRequest(
      url: Urls.userTerminalFreightList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myLoadIdx] = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];
          dataLists[myLoadIdx] =
              isLoad ? [...dataLists[myLoadIdx], ...tmpList] : tmpList;
          // update();
          update(["$loadListBuildId$myLoadIdx"]);
          isLoad
              ? pullCtrls[myLoadIdx].loadComplete()
              : pullCtrls[myLoadIdx].refreshCompleted();
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
    //       "sponsor": "黄远雄",
    //       "upgradeTime": "2023-02-13",
    //       "yingbu": 150,
    //       "yibu": 13,
    //       "buhuoStartTime": "2022-12-09 00:00:00",
    //       "buhuoEndTime": "2022-12-10 00:00:00",
    //       "zhouqiStartTime": "2022-12-09 00:00:00",
    //       "zhouqiEndTime": "2022-12-22 00:00:00",
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

  backoutAction() {
    loadData();
  }

  agreeAction() {
    loadData();
  }

  rejectAction() {
    loadData();
  }

  @override
  void onInit() {
    loadData();
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

class StatisticsMachineReplenishment
    extends GetView<StatisticsMachineReplenishmentController> {
  const StatisticsMachineReplenishment({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
          appBar: getDefaultAppBar(context, "续货管理"),
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
                                placeholder: "请输入想要搜索的用户名",
                                placeholderStyle: TextStyle(
                                    fontSize: 12.sp, color: AppColor.assisText),
                                style: TextStyle(
                                    fontSize: 12.sp, color: AppColor.text),
                                onSubmitted: (p0) {
                                  takeBackKeyboard(context);
                                  controller.searchAction();
                                },
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
                                  controller.statusList.length, (index) {
                                return CustomButton(
                                  onPressed: () {
                                    controller.topIndex = index;
                                  },
                                  child: GetX<
                                          StatisticsMachineReplenishmentController>(
                                      builder: (_) {
                                    return SizedBox(
                                      width:
                                          375.w / controller.statusList.length -
                                              0.1.w,
                                      child: Center(
                                        child: getSimpleText(
                                          controller.statusList[index]["name"],
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
                        GetX<StatisticsMachineReplenishmentController>(
                          builder: (_) {
                            return AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                top: 47.w,
                                width: 15.w,
                                left: controller.topIndex *
                                        (375.w / controller.statusList.length -
                                            0.1.w) +
                                    ((375.w / controller.statusList.length -
                                                0.1.w) -
                                            15.w) /
                                        2,
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
                    itemCount: controller.statusList.length,
                    onPageChanged: (value) {
                      controller.topIndex = value;
                    },
                    itemBuilder: (context, index) {
                      return list(index);
                    },
                  ))
            ],
          )),
    );
  }

  Widget list(int listIdx) {
    return GetBuilder<StatisticsMachineReplenishmentController>(
      id: "${controller.loadListBuildId}$listIdx",
      builder: (_) {
        return SmartRefresher(
          controller: controller.pullCtrls[listIdx],
          onLoading: () => controller.onLoad(listIdx),
          onRefresh: () => controller.onRefresh(listIdx),
          enablePullUp:
              controller.counts[listIdx] > controller.dataLists[listIdx].length,
          child: controller.dataLists[listIdx].isEmpty
              ? GetX<StatisticsMachineReplenishmentController>(
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
                    return cell(index, controller.dataLists[listIdx][index]);
                  },
                ),
        );
      },
    );
  }

  Widget cell(int index, Map data) {
    int cellStatus = data["state"] ?? -1;

    Color textColor = AppColor.theme;
    String statusStr = "";
    switch (cellStatus) {
      case 0:
        textColor = AppColor.theme;
        statusStr = "未开始";
        break;
      case 1:
        textColor = AppColor.text2;
        statusStr = "已开始";
        break;
      case 2:
        textColor = AppColor.red;
        statusStr = "未完成";
        break;
      case 3:
        textColor = AppColor.text2;
        statusStr = "已完成";
        break;
    }

    return Align(
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        width: 345.w,
        height: 180.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: Column(
          children: [
            sbhRow([
              getSimpleText(
                "订单编号：${data["order_No"] ?? ""}",
                10,
                AppColor.text3,
              ),
              getSimpleText(statusStr, 12, textColor)
            ], width: 345 - 15 * 2, height: 40),
            gline(315, 0.5),
            SizedBox(
              height: 78.5.w,
              width: 315.w,
              child: centClm([
                infoCell("发起人", data["u_Name"] ?? ""),
                infoCell("升级时间", data["uplvTime"] ?? ""),
                infoCell("已补/应补",
                    "${data["plan_Num"] ?? 0}/${data["actual_Num"] ?? 0}"),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),
            Container(
              width: 315.w,
              height: 50.w,
              decoration: BoxDecoration(
                  color: AppColor.pageBackgroundColor,
                  borderRadius: BorderRadius.circular(4.w)),
              child: centClm(
                  List.generate(3, (index) {
                    return index == 1
                        ? ghb(5)
                        : Row(
                            children: [
                              gwb(15),
                              getWidthText(index == 0 ? "补货时间" : "周期时间", 10,
                                  AppColor.text3, 55.5, 1,
                                  textHeight: 1.3),
                              getWidthText(
                                  "${data[index == 0 ? "replenishStaTime" : "periodStaTime"] ?? 0}~${data[index == 0 ? "replenishEndTime" : "periodEndTime"] ?? 0}",
                                  10,
                                  AppColor.text2,
                                  315 - 15 * 2 - 55.5 - 1,
                                  1,
                                  textHeight: 1.3)
                            ],
                          );
                  }),
                  crossAxisAlignment: CrossAxisAlignment.start),
            )
          ],
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
