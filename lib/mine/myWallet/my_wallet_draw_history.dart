import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_draw_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class MyWalletDrawHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyWalletDrawHistoryController>(
        MyWalletDrawHistoryController(datas: Get.arguments));
  }
}

class MyWalletDrawHistoryController extends GetxController {
  final dynamic datas;
  MyWalletDrawHistoryController({this.datas});

  String historyDataListBuildId = "MyWalletDrawHistory_historyDataListBuildId_";

  PageController pageCtrl = PageController();
  FixedExtentScrollController? yearPickCtrl;
  FixedExtentScrollController? monthPickCtrl;

  final _scrollYearIndex = 0.obs;
  int get scrollYearIndex => _scrollYearIndex.value;
  set scrollYearIndex(v) => _scrollYearIndex.value = v;
  final _scrollMonthIndex = 0.obs;
  int get scrollMonthIndex => _scrollMonthIndex.value;
  set scrollMonthIndex(v) => _scrollMonthIndex.value = v;

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

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (pageIsAnimate) {
      return;
    }
    if (_topIndex.value != v) {
      _topIndex.value = v;
      changePage();
      loadHistory();
    }
  }

  bool pageIsAnimate = false;

  changePage() {
    if (pageIsAnimate) {
      return;
    }
    pageIsAnimate = true;
    pageCtrl
        .animateToPage(topIndex,
            duration: const Duration(milliseconds: 300), curve: Curves.linear)
        .then((value) {
      pageIsAnimate = false;
    });
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _historyDataList = Rx<List<List>>(<List>[]);
  List<List> get historyDataList => _historyDataList.value;
  set historyDataList(v) => _historyDataList.value = v;

  final _startDate = "".obs;
  String get startDate => _startDate.value;
  set startDate(v) => _startDate.value = v;

  final _endDate = "".obs;
  String get endDate => _endDate.value;
  set endDate(v) => _endDate.value = v;

  String currentDate = "";

  final _currentDateIndex = RxInt(-1);
  int get currentDateIndex => _currentDateIndex.value;
  set currentDateIndex(int v) {
    _currentDateIndex.value = v;
    if (currentDateIndex == 0) {
      currentDate = startDate;
    } else if (currentDateIndex == 1) {
      currentDate = endDate;
    }
  }

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  List<int> pageSizes = [20, 20, 20];
  List<int> pageNos = [1, 1, 1];
  List<int> counts = [0, 0, 0];

  final _showFilter = false.obs;
  bool get showFilter => _showFilter.value;
  set showFilter(v) => _showFilter.value = v;

  List accountList = [];

  loadHistory({bool isLoad = false, int? loadIdx}) {
    // if (dateFormat.parse(endDate).isBefore(dateFormat.parse(startDate))) {
    //   ShowToast.normal("结束时间不能早于开始时间，请重新选择");
    //   return;
    // }
    int myLoadIdx = loadIdx ?? topIndex;
    isLoad ? pageNos[myLoadIdx]++ : pageNos[myLoadIdx] = 1;

    if (historyDataList[myLoadIdx].isEmpty) {
      isLoading = true;
    }

    Map<String, dynamic> params = {
      "pageSize": pageSizes[myLoadIdx],
      "pageNo": pageNos[myLoadIdx]
    };
    if (aNo != 0) {
      params["a_No"] = aNo;
    } else {
      if (myLoadIdx != 0) {
        params["a_No"] = accountList[myLoadIdx]["a_No"];
      }
      DateTime date =
          DateTime(currentYear, currentMon + 1 > 12 ? 1 : currentMon + 1, 0);
      params["startingTime"] = "$currentYear-$currentMon-1";
      params["end_Time"] = "$currentYear-$currentMon-${date.day}";
    }

    simpleRequest(
      url: Urls.userDrawList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myLoadIdx] = data["count"] ?? 0;
          List dataList = data["data"] ?? [];
          isLoad
              ? historyDataList[myLoadIdx] = [
                  ...dataList,
                  ...historyDataList[myLoadIdx]
                ]
              : historyDataList[myLoadIdx] = dataList;
          update(["$historyDataListBuildId$myLoadIdx"]);

          if (firstLoad && dataList.isNotEmpty) {
            String addTime = dataList[0]["addTime"] ?? "";
            DateTime date = DateFormat("yyyy/MM/dd HH:mm:ss").parse(addTime);
            currentYear = date.year;
            currentMon = date.month;
            upDateDateTimeStr();
          }
          firstLoad = false;
        }
      },
      after: () {
        isFirstLoading = false;
        isLoading = false;
      },
    );
  }

  resetTime() {
    DateTime dt = DateTime.now();
    startDate = dateFormat.format(dt.subtract(const Duration(days: 90)));
    currentDate = startDate;
    endDate = dateFormat.format(DateTime.now());
  }

  List yearList = [];
  List monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  cancelPick() {}
  confirmPick() {
    currentYear = yearList[scrollYearIndex];
    currentMon = monthList[scrollMonthIndex];
    upDateDateTimeStr();
    loadHistory();
    // loadList(
    //     year: yearList[scrollYearIndex], month: monthList[scrollMonthIndex]);
  }

  final _dateTimeStr = "".obs;
  String get dateTimeStr => _dateTimeStr.value;
  set dateTimeStr(v) => _dateTimeStr.value = v;

  int currentYear = 0;
  int currentMon = 0;

  bool firstLoad = true;

  upDateDateTimeStr() {
    dateTimeStr =
        "$currentYear年${currentMon < 10 ? "0$currentMon" : currentMon}月";
  }

  int aNo = 0;

  @override
  void onInit() {
    aNo = (datas ?? {})["a_No"] ?? 0;
    if (aNo == 0) {
      for (var i = 0; i < 50; i++) {
        yearList.add(DateTime.now().year - i);
      }
      DateTime now = DateTime.now();
      currentYear = now.year;
      currentMon = now.month;
      upDateDateTimeStr();
      List a = AppDefault().homeData["u_Account"];
      accountList = [
        {
          "name": "全部",
        }
      ];
      for (var e in a) {
        if (e["a_No"] <= 3) {
          accountList.add(e);
        }
      }
      historyDataList = <List>[];
      pageNos = [];
      pageSizes = [];
      counts = [];
      for (var e in accountList) {
        historyDataList.add([]);
        pageNos.add(1);
        pageSizes.add(20);
        counts.add(0);
      }

      resetTime();
    } else {
      historyDataList.add([]);
      pageNos.add(1);
      pageSizes.add(20);
      counts.add(0);
    }

    loadHistory();
    super.onInit();
  }

  @override
  void onClose() {
    pageCtrl.dispose();
    super.onClose();
  }
}

class MyWalletDrawHistory extends GetView<MyWalletDrawHistoryController> {
  const MyWalletDrawHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(
          context, "提现记录",
          //  action: [
          //   CustomButton(
          //     onPressed: () {
          //       controller.showFilter = !controller.showFilter;
          //     },
          //     child: SizedBox(
          //       height: kToolbarHeight,
          //       width: 50.w,
          //       child: Align(
          //         alignment: Alignment.center,
          //         child: Image.asset(
          //           assetsName("mine/mywallet/btn_wallet_drawhistory_filter"),
          //           height: 17.w,
          //           fit: BoxFit.fitHeight,
          //         ),
          //       ),
          //     ),
          //   )
          // ]
        ),
        body: Stack(children: [
          controller.aNo != 0
              ? gemp()
              : Positioned(
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
                              children: List.generate(
                                  controller.accountList.length, (index) {
                                return CustomButton(
                                  onPressed: () {
                                    controller.topIndex = index;
                                  },
                                  child: GetX<MyWalletDrawHistoryController>(
                                      builder: (_) {
                                    return SizedBox(
                                      width: 375.w / 3 - 0.1.w,
                                      child: Center(
                                        child: getSimpleText(
                                          controller.accountList[index]["name"],
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
                        GetX<MyWalletDrawHistoryController>(
                          builder: (_) {
                            return AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                top: 47.w,
                                width: 15.w,
                                left:
                                    controller.topIndex * (375.w / 3 - 0.1.w) +
                                        ((375.w / 3 - 0.1.w) - 15.w) / 2,
                                height: 2.w,
                                child: Container(
                                  color: AppColor.theme,
                                ));
                          },
                        )
                      ],
                    ),
                  )),
          controller.aNo != 0
              ? gemp()
              : Positioned(
                  top: 55.w,
                  left: 0,
                  right: 0,
                  height: 46.w,
                  child: CustomButton(
                    onPressed: () {
                      controller.showPick(
                          controller.currentYear, controller.currentMon);
                      showBottomDatePick(
                          controller.currentYear, controller.currentMon);
                    },
                    child: sbhRow([
                      centRow([
                        GetX<MyWalletDrawHistoryController>(
                          builder: (_) {
                            return getSimpleText(
                                controller.dateTimeStr, 15, AppColor.text,
                                isBold: true);
                          },
                        ),
                        gwb(3),
                        Image.asset(
                          assetsName("mine/wallet/icon_down_arrow_black"),
                          width: 10.w,
                          fit: BoxFit.fitWidth,
                        )
                      ])
                    ], width: 375 - 15 * 2, height: 46),
                  )),
          Positioned.fill(
            top: controller.aNo != 0 ? 0 : 55.w + 46.w,
            child: controller.aNo != 0
                ? list(0)
                : PageView.builder(
                    controller: controller.pageCtrl,
                    itemCount: controller.historyDataList.length,
                    itemBuilder: (context, index) {
                      return list(index);
                    },
                    onPageChanged: (value) {
                      controller.topIndex = value;
                    },
                  ),
          ),
          GetX<MyWalletDrawHistoryController>(
            initState: (_) {},
            builder: (_) {
              return controller.showFilter
                  ? Positioned.fill(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          controller.showFilter = false;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 10000),
                          width: 375.w,
                          height: 100.w,
                          color: controller.showFilter
                              ? Colors.black26
                              : Colors.transparent,
                        ),
                      ))
                  : gemp();
            },
          ),
          GetX<MyWalletDrawHistoryController>(
              initState: (_) {},
              builder: (_) {
                double contentHeight = 100.w;
                double buttonHeight = 50.w;
                return AnimatedPositioned(
                    top: controller.showFilter
                        ? 0
                        : -(contentHeight + buttonHeight),
                    left: 0,
                    right: 0,
                    // height: controller.showFilter
                    //     ? (contentHeight + buttonHeight)
                    //     : 0,
                    height: contentHeight + buttonHeight,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 375.w,
                      height: contentHeight + buttonHeight,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 375.w,
                              height: contentHeight,
                              child: Center(
                                child: centRow([
                                  timeFilter(0),
                                  gwb(30),
                                  timeFilter(1),
                                ]),
                              ),
                            ),
                            sbRow([
                              CustomButton(
                                onPressed: () {
                                  controller.resetTime();
                                },
                                child: Container(
                                  width: 375.w / 2 - 0.1.w,
                                  height: buttonHeight,
                                  color: const Color(0xFFE6EEFF),
                                  child: Center(
                                    child: getSimpleText(
                                        "重置",
                                        16,
                                        AppDefault().getThemeColor() ??
                                            AppColor.theme),
                                  ),
                                ),
                              ),
                              CustomButton(
                                onPressed: () {
                                  controller.showFilter = false;
                                  controller.loadHistory();
                                },
                                child: Container(
                                  width: 375.w / 2 - 0.1.w,
                                  height: 50.w,
                                  color: AppDefault().getThemeColor() ??
                                      AppColor.theme,
                                  child: Center(
                                    child:
                                        getSimpleText("确认", 16, Colors.white),
                                  ),
                                ),
                              ),
                            ], width: 375),
                          ],
                        ),
                      ),
                    ));
              })
        ]));
  }

  Widget list(int index) {
    return GetBuilder<MyWalletDrawHistoryController>(
      id: "${controller.historyDataListBuildId}$index",
      init: controller,
      initState: (_) {},
      builder: (_) {
        return EasyRefresh.builder(
          onLoad: controller.historyDataList[index].length >=
                  controller.counts[index]
              ? null
              : () => controller.loadHistory(isLoad: true, loadIdx: index),
          onRefresh: () => controller.loadHistory(loadIdx: index),
          childBuilder: (context, physics) {
            return controller.historyDataList[index].isEmpty
                ? GetX<MyWalletDrawHistoryController>(
                    builder: (_) {
                      return controller.isFirstLoading
                          ? SizedBox(
                              width: 375.w,
                              height: ScreenUtil().screenHeight -
                                  20.w -
                                  kToolbarHeight -
                                  (controller.aNo != 0 ? 0 : 111.w),
                              child: SkeletonListView(
                                padding: EdgeInsets.all(15.w),
                              ),
                            )
                          : CustomListEmptyView(
                              physics: physics,
                              isLoading: controller.isLoading,
                            );
                    },
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: 20.w),
                    physics: physics,
                    itemCount: controller.historyDataList[index].length,
                    itemBuilder: (context, listIdx) {
                      return GestureDetector(
                        onTap: () => push(const MyWalletDrawDetail(), context,
                            binding: MyWalletDrawDetailBinding(),
                            arguments: {
                              "drawData": controller.historyDataList[index]
                                  [listIdx]
                            }),
                        child: historyCell(
                            index, controller.historyDataList[index][listIdx]),
                      );
                    },
                  );
          },
        );
      },
    );
  }

  Widget timeFilter(int index) {
    return CustomButton(
      onPressed: () {
        controller.currentDateIndex = index;
        showDatePick(isStart: index == 0);
      },
      child: GetX<MyWalletDrawHistoryController>(
        initState: (_) {},
        builder: (_) {
          String date = index == 0 ? controller.startDate : controller.endDate;
          return Container(
            width: 144.w,
            height: 32.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.w),
                color: const Color(0xFFF8F8F8),
                border: Border.all(width: 1.w, color: Colors.white)),
            child: Row(
              children: [
                gwb(4),
                Image.asset(
                  assetsName("mine/mywallet/icon_timefilter"),
                  width: 14.w,
                  fit: BoxFit.fitWidth,
                ),
                gwb(9),
                getSimpleText(
                    date.isEmpty ? "起始时间" : date,
                    14,
                    date.isEmpty
                        ? const Color(0xFF8A9199)
                        : AppColor.textBlack4)
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget historyCell(int index, Map data, BuildContext context) {
  //   return Container(
  //     height: 80.5.w,
  //     width: 375.w,
  //     color: Colors.white,
  //     child: Column(
  //       children: [
  //         sbhRow([
  //           centClm([
  //             getSimpleText("提现", 16, AppColor.textBlack),
  //             ghb(10),
  //             getSimpleText(data["addTime"], 13, AppColor.textGrey),
  //           ], crossAxisAlignment: CrossAxisAlignment.start),
  //           centClm([
  //             getSimpleText("-￥${priceFormat(data["money"])}", 16,
  //                 const Color(0xFFFB4746),
  //                 fw: FontWeight.w600),
  //             ghb(10),
  //             getSimpleText(data["managedStr"], 13, AppColor.textGrey),
  //           ], crossAxisAlignment: CrossAxisAlignment.end),
  //         ], width: 375 - 25 * 2, height: 80),
  //         gline(345, 0.5)
  //       ],
  //     ),
  //   );
  // }

  Widget historyCell(int index, Map data) {
    String img = data["account"] != null
        ? AppDefault().getAccountImg(data["account"])
        : "";
    String accountName = data["onlineName"] ?? data["bankName"] ?? "";
    String imgUrl = AppDefault().imageUrl + img;
    return CustomButton(
      onPressed: () {
        push(const MyWalletDrawDetail(), null,
            binding: MyWalletDrawDetailBinding(),
            arguments: {"drawData": data});
      },
      child: Container(
        width: 375.w,
        height: 75.w,
        alignment: Alignment.center,
        color: Colors.white,
        child: sbhRow([
          centRow([
            img.isNotEmpty
                ? CustomNetworkImage(
                    src: imgUrl,
                    width: 32.w,
                    height: 32.w,
                    fit: BoxFit.fill,
                  )
                : SizedBox(
                    width: 32.w,
                  ),
            gwb(7),
            centClm([
              getWidthText("${data["accountName"] ?? ""}提现-到$accountName", 15,
                  AppColor.text2, 214.5, 1),
              ghb(10),
              getWidthText(data["addTime"] ?? "", 12, AppColor.text3, 214.5, 1)
            ], crossAxisAlignment: CrossAxisAlignment.start)
          ]),
          centClm([
            getWidthText(priceFormat(data["amount"] ?? 0), 18, AppColor.text,
                345 - 32 - 7 - 214.5 - 0.1, 1,
                isBold: true, alignment: Alignment.centerRight),
            ghb(5),
            getWidthText(data["managedStr"] ?? "", 12, AppColor.text3,
                345 - 32 - 7 - 214.5 - 0.1, 1,
                alignment: Alignment.centerRight),
          ], crossAxisAlignment: CrossAxisAlignment.end)
        ], width: 375 - 15 * 2, height: 75),
      ),
    );
  }

  showDatePick({required bool isStart}) {
    Get.bottomSheet(Container(
      color: Colors.white,
      width: 375.w,
      height: 265.w,
      child: CupertinoDatePicker(
        maximumYear: DateTime.now().year,
        minimumYear: DateTime.now().year - 10,
        minimumDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
        maximumDate: DateTime.now().add(const Duration(days: 1)),
        initialDateTime: controller.dateFormat.parse(controller.currentDate),
        mode: CupertinoDatePickerMode.date,
        dateOrder: DatePickerDateOrder.ymd,
        onDateTimeChanged: (value) {
          if (isStart) {
            controller.startDate = controller.dateFormat.format(value);
          } else {
            controller.endDate = controller.dateFormat.format(value);
          }
        },
      ),
    )).then((value) {
      controller.currentDateIndex = -1;
      // controller.loadHistory();
    });
  }

  showBottomDatePick(int year, int month) {
    Get.bottomSheet(
      Container(
        width: 375.w,
        height: 248.w,
        color: Colors.white,
        child: Column(
          children: [
            sbhRow([
              CustomButton(
                onPressed: () {
                  controller.cancelPick();
                  Get.back();
                },
                child: getSimpleText("取消", 16, AppColor.textGrey),
              ),
              CustomButton(
                onPressed: () {
                  controller.confirmPick();
                  Get.back();
                },
                child: getSimpleText("确定", 16, AppColor.textBlack),
              ),
            ], width: 375 - 16 * 2, height: 48),
            gline(375, 0.5),
            SizedBox(
                width: 375.w,
                height: (248 - 48 - 0.5).w,
                child: Center(
                  child: centRow([
                    pick(true),
                    pick(false),
                  ]),
                ))

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
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
    );
  }

  Widget pick(bool isYear) {
    return SizedBox(
      height: (248 - 48 - 0.5).w,
      width: 123.w,
      child: Center(
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
                child: GetX<MyWalletDrawHistoryController>(
                  autoRemove: false,
                  init: controller,
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
      ),
    );
  }
}
