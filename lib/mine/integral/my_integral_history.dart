import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/earn/earn_particulars.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_deal_list.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class MyIntegralHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyIntegralHistoryController>(
        MyIntegralHistoryController(datas: Get.arguments));
  }
}

class MyIntegralHistoryController extends GetxController {
  final dynamic datas;
  MyIntegralHistoryController({this.datas});

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _topIdx = 0.obs;
  int get topIdx => _topIdx.value;
  set topIdx(v) {
    if (_topIdx.value != v) {
      _topIdx.value = v;
      changePage(index: topIdx);
      loadData(listIdx: topIdx);
    }
  }

  List statusList = [
    {"id": 1, "name": "获取记录"},
    {"id": 2, "name": "兑换记录"}
  ];

  bool topAnimation = false; // top动画
  late PageController pageCtrl;
  changePage({int? index}) {
    int myPage = index ?? topIdx;
    if (topAnimation) {
      return;
    }
    topAnimation = true;
    pageCtrl
        .animateToPage(myPage,
            duration: const Duration(milliseconds: 300), curve: Curves.linear)
        .then((value) {
      topAnimation = false;
    });
  }

  List dataLists = [[], []];
  List pageNos = [1, 1];
  List pageSizes = [20, 20];
  List counts = [0, 0];

  String listBuildId = "MyIntegralHistoryController_listBuildId_";

  loadData({bool isLoad = false, int? listIdx, int? year, int? month}) {
    int myListIdx = listIdx ?? topIdx;
    isLoad ? pageNos[myListIdx]++ : pageNos[myListIdx] = 1;

    Map<String, dynamic> params = {
      "a_No": isBean ? 5 : 4,
      "pageSize": pageSizes[myListIdx],
      "pageNo": pageNos[myListIdx],
      "d_Type": statusList[myListIdx]["id"]
    };

    if (year != null && month != null) {
      params["year"] = year;
      params["month"] = month;
    }

    simpleRequest(
      url: Urls.userFinanceIntegralList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myListIdx] = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];
          dataLists[myListIdx] =
              isLoad ? [...dataLists[myListIdx], ...tmpList] : tmpList;
          listDataFormat(data, isLoad,
              listIdx: myListIdx, year: year, month: month);
          update(["$listBuildId$myListIdx"]);
        }
      },
      after: () {
        isLoading = false;
        isFirstLoading = false;
      },
    );
  }

  //月份查询选择相关

  List yearList = [];
  List monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
  DateFormat dateFormat2 = DateFormat("MM-dd HH:mm");
  List<List<WalletDealSection>> walletDealSectionList = [[], []];
  listDataFormat(Map data, bool isLoad, {int? year, int? month, int? listIdx}) {
    int myListIdx = listIdx ?? topIdx;
    List financeInOutData = data["financeInOutData"] ?? [];
    List cellDatas = data["data"] ?? [];
    for (var i = 0; i < financeInOutData.length; i++) {
      var e = financeInOutData[i];
      List monthData = [];
      for (var cell in cellDatas) {
        if (cell["addTime"] != null && cell["addTime"].isNotEmpty) {
          DateTime dateTime = dateFormat.parse(cell["addTime"]);
          if (dateTime.year == (e["year"] ?? 0) &&
              dateTime.month == (e["month"] ?? 0)) {
            monthData.add(cell);
          }
        }
      }
      if (monthData.isEmpty) {
        continue;
      }
      if (walletDealSectionList[myListIdx].length <= i) {
        walletDealSectionList[myListIdx].add(WalletDealSection(
            dealList: monthData,
            year: e["year"] ?? 0,
            month: e["month"] ?? 0,
            inAmout: e["inAmount"] ?? 0.0,
            outAmout: e["outAmount"] ?? 0.0));
      } else {
        walletDealSectionList[myListIdx][i] = WalletDealSection(
            year: e["year"] ?? 0,
            month: e["month"] ?? 0,
            dealList: isLoad
                ? [
                    ...walletDealSectionList[myListIdx][i].dealList,
                    ...monthData
                  ]
                : monthData,
            inAmout: e["inAmount"] ?? 0.0,
            outAmout: e["outAmount"] ?? 0.0);
      }
    }
    // update();
    // if (year != null &&
    //     month != null &&
    //     walletDealSectionList[myListIdx].isNotEmpty) {
    //   double jumpOffset = 0;
    //   for (var i = 0; i < walletDealSectionList[myListIdx].length; i++) {
    //     WalletDealSection s = walletDealSectionList[myListIdx][i];
    //     if (s.month == month && s.year == year) {
    //       break;
    //     } else {
    //       jumpOffset += 45.w;
    //     }
    //     for (var e in s.dealList) {
    //       jumpOffset += (rowHeight + 10.w);
    //     }
    //   }
    //   scrollCtrl.jumpTo(jumpOffset);
    // }
  }

  final scrollCtrl = ScrollController();
  final listController = ExpandableListController();
  double rowHeight = 75.w;

  final _scrollYearIndex = 0.obs;
  int get scrollYearIndex => _scrollYearIndex.value;
  set scrollYearIndex(v) => _scrollYearIndex.value = v;
  final _scrollMonthIndex = 0.obs;
  int get scrollMonthIndex => _scrollMonthIndex.value;
  set scrollMonthIndex(v) => _scrollMonthIndex.value = v;
  FixedExtentScrollController? yearPickCtrl;
  FixedExtentScrollController? monthPickCtrl;
  showPick(int year, int month) {
    scrollYearIndex = yearList.indexOf(year);
    scrollMonthIndex = monthList.indexOf(month);

    if (yearPickCtrl != null) {
      yearPickCtrl!.dispose();
    }
    if (monthPickCtrl != null) {
      monthPickCtrl!.dispose();
    }

    yearPickCtrl = FixedExtentScrollController(initialItem: scrollYearIndex);
    monthPickCtrl = FixedExtentScrollController(initialItem: scrollMonthIndex);
    // yearPickCtrl.animateToItem(scrollYearIndex,
    //     duration: Duration(milliseconds: 300), curve: Curves.linear);
    // monthPickCtrl.animateToItem(scrollMonthIndex,
    //     duration: Duration(milliseconds: 300), curve: Curves.linear);
  }

  cancelPick() {
    Get.back();
  }

  confirmPick() {
    Get.back();
    loadData(
        year: yearList[scrollYearIndex], month: monthList[scrollMonthIndex]);
  }

  @override
  void onReady() {
    loadData();
    super.onReady();
  }

  bool isBean = false;
  Map walletData = {};

  @override
  void onInit() {
    isBean = (datas ?? {})["isBean"] ?? false;
    for (var e in (AppDefault().homeData["u_Account"] ?? [])) {
      if ((e["a_No"] ?? 0) == (isBean ? 5 : 4)) {
        walletData = e;
        break;
      }
    }
    _topIdx.value = (datas ?? {})["index"] ?? 0;
    pageCtrl = PageController(initialPage: topIdx);
    for (var i = 0; i < 50; i++) {
      yearList.add(DateTime.now().year - i);
    }
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class MyIntegralHistory extends GetView<MyIntegralHistoryController> {
  const MyIntegralHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
          context, "${controller.walletData["name"] ?? "积分"}明细"),
      body: Stack(children: [
        Positioned(
            top: 0,
            right: 0,
            left: 0,
            height: 50.w,
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  Positioned(
                      top: 15.w,
                      left: 0,
                      right: 0,
                      height: 20.w,
                      child: Row(
                        children: List.generate(controller.statusList.length,
                            (index) {
                          return CustomButton(
                            onPressed: () {
                              controller.topIdx = index;
                            },
                            child:
                                GetX<MyIntegralHistoryController>(builder: (_) {
                              return SizedBox(
                                width: 375.w / controller.statusList.length -
                                    0.1.w,
                                child: Center(
                                  child: getSimpleText(
                                    controller.statusList[index]["name"],
                                    16,
                                    AppColor.textBlack,
                                    isBold: controller.topIdx == index,
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      )),
                  GetX<MyIntegralHistoryController>(
                    builder: (_) {
                      return AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          top: 47.w,
                          width: 15.w,
                          left: controller.topIdx *
                                  (375.w / controller.statusList.length -
                                      0.1.w) +
                              ((375.w / controller.statusList.length - 0.1.w) -
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
            top: 50.w,
            child: PageView.builder(
              controller: controller.pageCtrl,
              itemCount: controller.dataLists.length,
              itemBuilder: (context, index) {
                return list(index);
              },
              onPageChanged: (value) {
                controller.topIdx = value;
              },
            )),
      ]),
    );
  }

  Widget list(int listIdx) {
    return GetBuilder<MyIntegralHistoryController>(
      id: "${controller.listBuildId}$listIdx",
      builder: (_) {
        return EasyRefresh.builder(
          onLoad:
              controller.dataLists[listIdx].length >= controller.counts[listIdx]
                  ? null
                  : () => controller.loadData(isLoad: true),
          onRefresh: () => controller.loadData(),
          childBuilder: (context, physics) {
            return controller.dataLists[listIdx].isEmpty
                    ? GetX<MyIntegralHistoryController>(
                        builder: (_) {
                          return controller.isFirstLoading
                              ? SkeletonListView(
                                  padding: EdgeInsets.all(15.w),
                                )
                              : CustomListEmptyView(
                                  physics: physics,
                                  isLoading: controller.isLoading,
                                );
                        },
                      )
                    : ExpandableListView(
                        controller: controller.scrollCtrl,
                        physics: physics,
                        builder: SliverExpandableChildDelegate(
                          controller: controller.listController,
                          sectionList:
                              controller.walletDealSectionList[listIdx],
                          // sectionBuilder: (context, containerInfo) {
                          //   return sectionView();
                          // },
                          headerBuilder: (context, sectionIndex, index) {
                            return sectionView(
                                sectionIndex,
                                controller.walletDealSectionList[listIdx]
                                    [sectionIndex],
                                listIdx);
                          },
                          itemBuilder:
                              (context, sectionIndex, itemIndex, index) {
                            return jfCell(
                                itemIndex,
                                controller
                                    .walletDealSectionList[listIdx]
                                        [sectionIndex]
                                    .dealList[itemIndex]);
                          },
                        ),
                      )

                // ListView.builder(
                //     physics: physics,
                //     itemCount: controller.dataLists[listIdx].length,
                //     padding: EdgeInsets.only(bottom: 20.w),
                //     itemBuilder: (context, index) {
                //       return jfCell(
                //           index, controller.dataLists[listIdx][index]);
                //     },
                //   )
                ;
          },
        );
      },
    );
  }

  Widget sectionView(int index, WalletDealSection section, int listIdx) {
    String subStr = listIdx == 0
        ? "总获得${controller.walletData["name"] ?? "积分"}：${priceFormat(section.inAmout, savePoint: 0)}个"
        : "总使用${controller.walletData["name"] ?? "积分"}：${priceFormat(section.outAmout, savePoint: 0)}个";
    return Container(
      color: AppColor.pageBackgroundColor,
      width: 375.w,
      height: 45.w,
      alignment: Alignment.center,
      child: sbRow([
        CustomButton(
          onPressed: () {
            controller.showPick(section.year, section.month);
            showBottomDatePick(section.year, section.month);
          },
          child: SizedBox(
            height: 55.w,
            child: Align(
              alignment: Alignment.centerRight,
              child: centRow([
                getSimpleText(
                    "${section.year}年${section.month}月", 15, AppColor.textBlack,
                    isBold: true),
                gwb(3),
                Image.asset(
                  assetsName("mine/jf/arrow_red_down"),
                  width: 10.w,
                  fit: BoxFit.fitWidth,
                )
              ]),
            ),
          ),
        ),
        getSimpleText(subStr, 12, AppColor.textGrey5)
      ], width: 375 - 14 * 2),
    );
  }

  showBottomDatePick(int year, int month) {
    Get.bottomSheet(
      Container(
        width: 375.w,
        height: 390.w + paddingSizeBottom(Global.navigatorKey.currentContext!),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
        child: Column(
          children: [
            sbhRow([
              gwb(42),
              getSimpleText("月份选择", 18, AppColor.textBlack, isBold: true),
              // CustomButton(
              //   onPressed: () {
              //     controller.cancelPick();
              //   },
              //   child: getSimpleText("取消", 16, AppColor.textGrey),
              // ),
              // CustomButton(
              //   onPressed: () {
              //     controller.confirmPick();
              //     Get.back();
              //   },
              //   child: getSimpleText("确定", 16, AppColor.textBlack),
              // ),
              CustomButton(
                onPressed: () {
                  controller.cancelPick();
                },
                child: SizedBox(
                  width: 42.w,
                  height: 55.w,
                  child: Center(
                    child: Image.asset(
                        assetsName("product_store/btn_bottom_model_close"),
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.fill),
                  ),
                ),
              )
            ], width: 375, height: 55),
            gline(375, 0.5),
            SizedBox(
                width: 375.w,
                height: 245.w,
                child: centRow([
                  pick(true),
                  pick(false),
                ])),
            SizedBox(
              height: 90.w,
              child: Center(
                child: getSubmitBtn("确定", () {
                  controller.confirmPick();
                }, height: 45, width: 345, color: AppColor.theme),
              ),
            )

            // CupertinoDatePicker(
            //   mode: CupertinoDatePickerMode.date,
            //   dateOrder: DatePickerDateOrder.ymd,
            //   initialDateTime: DateTime(year, month),
            //   onDateTimeChanged: (value) {},
            // ),
            // ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  Widget pick(bool isYear) {
    return SizedBox(
      height: 245.w,
      width: 123.w,
      child: CupertinoPicker.builder(
        // key: isYear ? controller.yearPickKey : controller.monthPickKey,
        childCount:
            isYear ? controller.yearList.length : controller.monthList.length,
        scrollController:
            isYear ? controller.yearPickCtrl : controller.monthPickCtrl,
        itemExtent: 40.w,
        onSelectedItemChanged: (value) {
          isYear
              ? controller.scrollYearIndex = value
              : controller.scrollMonthIndex = value;
        },
        itemBuilder: (context, index) {
          return SizedBox(
              width: 123.w,
              height: 40.w,
              child: GetX<MyIntegralHistoryController>(
                autoRemove: false,
                builder: (_) {
                  return Center(
                    child: getSimpleText(
                      isYear
                          ? "${controller.yearList[index]}年"
                          : "${controller.monthList[index]}月",
                      isYear
                          ? (controller.scrollYearIndex == index ? 16 : 15)
                          : (controller.scrollMonthIndex == index ? 16 : 15),
                      isYear
                          ? (controller.scrollYearIndex == index
                              ? AppColor.textBlack
                              : AppColor.textBlack)
                          : (controller.scrollMonthIndex == index
                              ? AppColor.textBlack
                              : AppColor.textBlack),
                    ),
                  );
                },
              ));
        },
      ),
    );
  }

  Widget jfCell(int index, Map data) {
    return CustomButton(
      onPressed: () {
        push(
            EarnParticulars(
              earnData: data,
              title: "积分明细",
            ),
            null,
            binding: EarnParticularsBinding());
      },
      child: Container(
        width: 375.w,
        height: 75.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(width: 0.5.w, color: AppColor.lineColor))),
        child: sbhRow([
          centClm([
            sbRow([
              getSimpleText(data["codeName"] ?? "", 15, AppColor.text2,
                  isBold: true),
              getSimpleText(
                  "${(data["bType"] ?? -1) == 0 ? "-" : "+"}${priceFormat(data["amount"] ?? 0, savePoint: 0)}",
                  18,
                  AppColor.text,
                  isBold: true)
            ], width: 345),
            ghb(8),
            getSimpleText(data["addTime"] ?? "", 12, AppColor.text3),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ], width: 345, height: 75),
      ),
    );
  }
}
