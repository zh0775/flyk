import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/contactCustomerService/contact_add_order.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ContactOrderListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ContactOrderListController>(
        ContactOrderListController(datas: Get.arguments));
  }
}

class ContactOrderListController extends GetxController {
  final dynamic datas;
  ContactOrderListController({this.datas});

  PageController pageCtrl = PageController();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (isPageAnimation) {
      return;
    }
    if (_topIndex.value != v) {
      _topIndex.value = v;
      changePage(idx: topIndex);
      loadList(loadIdx: topIndex);
    }
  }

  bool isPageAnimation = false;

  changePage({int? idx}) {
    isPageAnimation = true;
    int myIdx = idx ?? topIndex;
    pageCtrl
        .animateToPage(myIdx,
            duration: const Duration(milliseconds: 300), curve: Curves.linear)
        .then((value) {
      isPageAnimation = false;
    });
  }

  List topTabs = [
    {
      "id": -1,
      "name": "全部",
    },
    {
      "id": 0,
      "name": "处理中",
    },
    {
      "id": 1,
      "name": "已完成",
    },
  ];

  List<List> dataLists = [];
  List<int> counts = [];
  List<int> pageNos = [];
  List<int> pageSizes = [];
  List<RefreshController> pullCtrls = [];

  dataFormat() {
    dataLists = <List>[];
    counts = <int>[];
    pageNos = <int>[];
    pageSizes = <int>[];
    pullCtrls = <RefreshController>[];
    for (var e in topTabs) {
      dataLists.add(<List>[]);
      counts.add(0);
      pageNos.add(1);
      pageSizes.add(20);
      pullCtrls.add(RefreshController());
    }
  }

  String loadListBuildId = "ContactOrderListloadListBuildId_";

  loadList({bool isLoad = false, int? loadIdx}) {
    int myLoadIdx = loadIdx ?? topIndex;
    isLoad ? pageNos[myLoadIdx]++ : pageNos[myLoadIdx] = 1;
    if (dataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.userCustomerServiceList,
      params: {
        "pageNo": pageNos[myLoadIdx],
        "pageSize": pageSizes[myLoadIdx],
        "d_Type": topTabs[topIndex]["id"]
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myLoadIdx] = data["count"] ?? 0;
          List jList = data["data"] ?? [];

          dataLists[myLoadIdx] =
              isLoad ? [...dataLists[myLoadIdx], ...jList] : jList;

          isLoad
              ? pullCtrls[myLoadIdx].loadComplete
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
  }

  @override
  void onInit() {
    dataFormat();
    loadList();
    super.onInit();
  }

  @override
  void onClose() {
    for (var e in pullCtrls) {
      e.dispose();
    }
    pageCtrl.dispose();
    super.onClose();
  }
}

class ContactOrderList extends GetView<ContactOrderListController> {
  const ContactOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "我的工单", action: [
        CustomButton(
          onPressed: () {
            push(const ContactAddOrder(), context,
                binding: ContactAddOrderBinding());
          },
          child: SizedBox(
            height: kToolbarHeight,
            child: centRow([
              Image.asset(
                assetsName("statistics/machine/btn_navi_add"),
                width: 24.w,
                fit: BoxFit.fitWidth,
              ),
              gwb(2),
              getSimpleText("新建", 14, AppColor.text2),
              gwb(9),
            ]),
          ),
        ),
      ]),
      body: Stack(children: [
        Positioned(
            top: 0,
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
                        children:
                            List.generate(controller.topTabs.length, (index) {
                          return CustomButton(
                            onPressed: () {
                              controller.topIndex = index;
                            },
                            child:
                                GetX<ContactOrderListController>(builder: (_) {
                              return SizedBox(
                                width:
                                    375.w / controller.topTabs.length - 0.1.w,
                                child: Center(
                                  child: getSimpleText(
                                    controller.topTabs[index]["name"],
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
                  GetX<ContactOrderListController>(
                    builder: (_) {
                      return AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          top: 47.w,
                          width: 15.w,
                          left: controller.topIndex *
                                  (375.w / controller.topTabs.length - 0.1.w) +
                              ((375.w / controller.topTabs.length - 0.1.w) -
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
            top: 55.w,
            child: PageView.builder(
              controller: controller.pageCtrl,
              itemCount: controller.topTabs.length,
              itemBuilder: (context, index) {
                return list(index);
              },
              onPageChanged: (value) {
                controller.topIndex = value;
              },
            ))
      ]),
    );
  }

  Widget list(int listIdx) {
    return GetBuilder<ContactOrderListController>(
      id: "${controller.loadListBuildId}$listIdx",
      builder: (_) {
        return SmartRefresher(
          controller: controller.pullCtrls[listIdx],
          onLoading: () => controller.loadList(isLoad: true, loadIdx: listIdx),
          onRefresh: () => controller.loadList(loadIdx: listIdx),
          enablePullUp:
              controller.counts[listIdx] > controller.dataLists[listIdx].length,
          child: controller.dataLists[listIdx].isEmpty
              ? GetX<ContactOrderListController>(
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
    // bool toMe = data["toMe"] == 1;

    Color textColor = AppColor.theme;
    String statusStr = "";
    switch (maintainStatus) {
      case 0:
        textColor = AppColor.theme;
        statusStr = "处理中";
        break;
      case 1:
        textColor = AppColor.text2;
        statusStr = "已完成";
        break;
    }

    return Align(
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        width: 345.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: Column(
          children: [
            sbhRow([
              getSimpleText(
                "订单编号：${data["orderNo"] ?? ""}",
                12,
                AppColor.text3,
              ),
              getSimpleText(statusStr, 12, textColor)
            ], width: 345 - 15 * 2, height: 40),
            gline(315, 0.5),
            SizedBox(
                child: sbRow([
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ghb(10),
                  infoCell("工单标题", data["serviceTypes"] ?? ""),
                  ghb(2),
                  sbRow([
                    getWidthText("故障原因", 12, AppColor.text3, 66.5, 1,
                        textHeight: 1.3),
                    getWidthText("${data["cause"] ?? ""}", 12, AppColor.text2,
                        315 - 66.5 - (maintainStatus > 0 ? 68.5 : 0), 10,
                        textHeight: 1.3),
                  ], width: 315, crossAxisAlignment: CrossAxisAlignment.start),
                  ghb(2),
                  infoCell("创建时间", data["addTime"] ?? ""),
                  infoCell("处理人", data["handler"] ?? ""),
                  ghb(maintainStatus != 0 ? 10 : 0),
                  ghb(18),
                ],
              ),
            ], width: 315, crossAxisAlignment: CrossAxisAlignment.end)),
          ],
        ),
      ),
    );
  }

  Widget infoCell(String t1, String t2,
      {double width = 62, double width2 = 180, double height = 22}) {
    return SizedBox(
      height: height.w,
      child: Center(
          child: Row(
        children: [
          getWidthText(t1, 12, AppColor.text3, width, 1, textHeight: 1.2),
          gwb(4.5),
          getWidthText(t2, 12, AppColor.text2, width2, 1, textHeight: 1.3),
        ],
      )),
    );
  }
}
