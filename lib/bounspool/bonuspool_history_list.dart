import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BonuspoolHistoryListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<BonuspoolHistoryListController>(BonuspoolHistoryListController());
  }
}

class BonuspoolHistoryListController extends GetxController {
  final dynamic datas;
  BonuspoolHistoryListController({this.datas});

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

  PageController pageCtrl = PageController();

  List<int> pageSizes = [
    20,
    20,
    20,
  ];
  List<int> pageNos = [
    1,
    1,
    1,
  ];
  List<int> counts = [
    0,
    0,
    0,
  ];
  List<RefreshController> pullCtrls = [
    RefreshController(),
    RefreshController(),
    RefreshController(),
  ];
  List<List> dataLists = [
    [],
    [],
    [],
  ];

  String loadListBuildId = "BonuspoolHistoryList_loadListBuildId_";

  loadData({bool isLoad = false, int? loadIdx, String? searchText}) {
    int myLoadIdx = loadIdx ?? topIndex;
    if (dataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.userPrizeQueueList,
      params: {
        "pageSize": pageSizes[myLoadIdx],
        "pageNo": pageNos[myLoadIdx],
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myLoadIdx] = data["count"] ?? 0;
          List tmpDatas = data["data"] ?? [];
          // tmpDatas = [{}, {}];
          dataLists[myLoadIdx] =
              isLoad ? [...dataLists[myLoadIdx], ...tmpDatas] : tmpDatas;

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
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    pageCtrl.dispose();
    for (var element in pullCtrls) {
      element.dispose();
    }
    super.onClose();
  }
}

class BonuspoolHistoryList extends GetView<BonuspoolHistoryListController> {
  const BonuspoolHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "领奖记录"),
      body: Stack(
        children: [
          // Positioned(
          //     top: 0,
          //     left: 0,
          //     right: 0,
          //     height: 55.w,
          //     child: Container(
          //       color: Colors.white,
          //       child: Stack(
          //         children: [
          //           Positioned(
          //               top: 20.w,
          //               left: 0,
          //               right: 0,
          //               height: 20.w,
          //               child: Row(
          //                 children: List.generate(3, (index) {
          //                   String title = "";
          //                   switch (index) {
          //                     case 0:
          //                       title = "全部";
          //                       break;
          //                     case 1:
          //                       title = "已到账";
          //                       break;
          //                     case 2:
          //                       title = "已失效";
          //                       break;
          //                   }
          //                   return CustomButton(
          //                     onPressed: () {
          //                       controller.topIndex = index;
          //                     },
          //                     child: GetX<BonuspoolHistoryListController>(
          //                         builder: (_) {
          //                       return SizedBox(
          //                         width: 375.w / 3 - 0.1.w,
          //                         child: Center(
          //                           child: getSimpleText(
          //                             title,
          //                             15,
          //                             controller.topIndex == index
          //                                 ? AppColor.theme
          //                                 : AppColor.text2,
          //                             isBold: controller.topIndex == index,
          //                           ),
          //                         ),
          //                       );
          //                     }),
          //                   );
          //                 }),
          //               )),
          //           GetX<BonuspoolHistoryListController>(
          //             builder: (_) {
          //               return AnimatedPositioned(
          //                   duration: const Duration(milliseconds: 300),
          //                   curve: Curves.easeInOut,
          //                   top: 47.w,
          //                   width: 15.w,
          //                   left: controller.topIndex * (375.w / 3 - 0.1.w) +
          //                       ((375.w / 3 - 0.1.w) - 15.w) / 2,
          //                   height: 2.w,
          //                   child: Container(
          //                     color: AppColor.theme,
          //                   ));
          //             },
          //           )
          //         ],
          //       ),
          //     )),
          Positioned.fill(
              // top: 55.w,
              child: PageView.builder(
            controller: controller.pageCtrl,
            // itemCount: controller.dataLists.length,
            itemCount: 1,
            onPageChanged: (value) {
              controller.topIndex = value;
            },
            itemBuilder: (context, index) {
              return list(index);
            },
          ))
        ],
      ),
    );
  }

  Widget list(int listIdx) {
    return GetBuilder<BonuspoolHistoryListController>(
      id: "${controller.loadListBuildId}$listIdx",
      builder: (_) {
        return SmartRefresher(
          controller: controller.pullCtrls[listIdx],
          onLoading: () => controller.loadData(isLoad: true, loadIdx: listIdx),
          onRefresh: () => controller.loadData(loadIdx: listIdx),
          enablePullUp:
              controller.counts[listIdx] > controller.dataLists[listIdx].length,
          child: controller.dataLists[listIdx].isEmpty
              ? GetX<BonuspoolHistoryListController>(
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
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: index == 0 ? 6.w : 0),
      color: Colors.white,
      width: 375.w,
      height: 75.w,
      child: sbhRow([
        centRow([
          Image.asset(
            assetsName("bonuspool/icon_history_coin"),
            width: 32.w,
            fit: BoxFit.fitWidth,
          ),
          gwb(9.5),
          centClm([
            getSimpleText("奖金池奖励领取", 15, AppColor.text2),
            ghb(9),
            getSimpleText(data["addTime"] ?? "", 12, AppColor.text3),
          ], crossAxisAlignment: CrossAxisAlignment.start)
        ]),
        centClm([
          getSimpleText(priceFormat(data["vcoM_Num"] ?? 0), 18, AppColor.text,
              isBold: true),
          ghb(6),
          getSimpleText("已到账", 12, AppColor.text3),
        ], crossAxisAlignment: CrossAxisAlignment.end)
      ], width: 345, height: 75),
    );
  }
}
