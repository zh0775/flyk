import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/earn/earn_particulars.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_draw.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class MyWalletDealListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyWalletDealListController>(MyWalletDealListController());
  }
}

class MyWalletDealListController extends GetxController {
  final _isLoading = true.obs;
  set isLoading(value) => _isLoading.value = value;
  bool get isLoading => _isLoading.value;

  final _isFirstLoading = true.obs;
  set isFirstLoading(value) => _isFirstLoading.value = value;
  bool get isFirstLoading => _isFirstLoading.value;

  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();

  final scrollCtrl = ScrollController();
  final listController = ExpandableListController();

  TextEditingController startMoneyInputCtrl = TextEditingController();
  TextEditingController endMoneyInputCtrl = TextEditingController();

  CustomDropDownController filterCtrl = CustomDropDownController();

  // 品牌选择
  final _brandIdx = 0.obs;
  int get brandIdx => _brandIdx.value;
  set brandIdx(v) => _brandIdx.value = v;

  List brandList = [];

  List dealTypes = [
    {
      "id": -1,
      "name": "全部",
    },
    {
      "id": 1,
      "name": "收入",
    },
    {
      "id": 0,
      "name": "支出",
    }
  ];

  final _dealTypeIdx = (-1).obs;
  int get dealTypeIdx => _dealTypeIdx.value;
  set dealTypeIdx(v) => _dealTypeIdx.value = v;

  final _startDate = "".obs;
  String get startDate => _startDate.value;
  set startDate(v) => _startDate.value = v;

  final _endDate = "".obs;
  String get endDate => _endDate.value;
  set endDate(v) => _endDate.value = v;

  int realDealTypeIdx = -1;
  String realStartMoney = "";
  String realEndMoney = "";
  String realStartDate = "";
  String realEndDate = "";

  resetFilter() {
    dealTypeIdx = -1;
    startDate = "";
    endDate = "";
    realDealTypeIdx = dealTypeIdx;
    realStartMoney = "";
    realEndMoney = "";
    realStartDate = startDate;
    realEndDate = endDate;
    startMoneyInputCtrl.clear();
    endMoneyInputCtrl.clear();
  }

  confirmFilter() {
    realDealTypeIdx = dealTypeIdx;
    realStartMoney = startMoneyInputCtrl.text;
    realEndMoney = endMoneyInputCtrl.text;
    realStartDate = startDate;
    realEndDate = endDate;
    showFilter();
    loadList();
  }

  showFilter() {
    if (filterCtrl.isShow) {
      filterCtrl.hide();
    } else {
      dealTypeIdx = realDealTypeIdx;
      startMoneyInputCtrl.text = realStartMoney;
      endMoneyInputCtrl.text = realEndMoney;
      startDate = realStartDate;
      endDate = realEndDate;
      filterCtrl.show(stackKey, headKey);
    }
  }

  List<WalletDealSection> walletDealSectionList = [];
  List walletDealList = [];
  onLoad() {
    loadList(isLoad: true);
  }

  onRefresh() {
    loadList();
  }

  // GlobalKey yearPickKey = GlobalKey();
  // GlobalKey monthPickKey = GlobalKey();

  int pageNo = 1;
  int pageSize = 20;
  int count = 0;

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
    loadList(
        year: yearList[scrollYearIndex], month: monthList[scrollMonthIndex]);
  }

  loadList({bool isLoad = false, int? year, int? month}) {
    isLoad ? pageNo++ : pageNo = 1;
    Map<String, dynamic> params = {
      "a_No": walletData["a_No"],
      "pageSize": pageSize,
      "pageNo": pageNo
    };

    if (year != null && month != null) {
      params["year"] = year;
      params["month"] = month;
    } else {
      if (realStartDate.isNotEmpty) {
        params["startingTime"] = realStartDate;
      }
      if (realEndDate.isNotEmpty) {
        params["end_Time"] = realEndDate;
      }
    }
    if (realStartMoney.isNotEmpty) {
      params["txnAmt_min"] = realStartMoney;
    }
    if (realEndMoney.isNotEmpty) {
      params["txnAmt_max"] = realEndMoney;
    }

    if (realDealTypeIdx != -1) {
      params["d_Type"] = dealTypes[realDealTypeIdx]["id"];
    }

    simpleRequest(
      url: Urls.userFinanceIntegralList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          listDataFormat(data, isLoad, year: year, month: month);
          List tmpList = data["data"] ?? [];
          isLoad
              ? walletDealList = [...walletDealList, ...tmpList]
              : walletDealList = tmpList;
        }
      },
      after: () {
        isLoading = false;
        isFirstLoading = false;
      },
    );
  }

  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
  DateFormat dateFormat2 = DateFormat("MM-dd HH:mm");

  listDataFormat(Map data, bool isLoad, {int? year, int? month}) {
    List financeInOutData = data["financeInOutData"] ?? [];
    List cellDatas = data["data"] ?? [];
    if (!isLoad) {
      walletDealSectionList = [];
    }
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
      if (walletDealSectionList.length <= i) {
        walletDealSectionList.add(WalletDealSection(
            dealList: monthData,
            year: e["year"] ?? 0,
            month: e["month"] ?? 0,
            inAmout: e["inAmount"] ?? 0.0,
            outAmout: e["outAmount"] ?? 0.0));
      } else {
        walletDealSectionList[i] = WalletDealSection(
            year: e["year"] ?? 0,
            month: e["month"] ?? 0,
            dealList: isLoad
                ? [...walletDealSectionList[i].dealList, ...monthData]
                : monthData,
            inAmout: e["inAmount"] ?? 0.0,
            outAmout: e["outAmount"] ?? 0.0);
      }
    }
    update();
    // if (year != null && month != null && walletDealSectionList.isNotEmpty) {
    //   double jumpOffset = 0;
    //   for (var i = 0; i < walletDealSectionList.length; i++) {
    //     WalletDealSection s = walletDealSectionList[i];
    //     if (s.month == month && s.year == year) {
    //       break;
    //     } else {
    //       jumpOffset += 32.w;
    //     }
    //     for (var e in s.dealList) {
    //       jumpOffset += (rowHeight + 10.w);
    //     }
    //   }
    //   scrollCtrl.jumpTo(jumpOffset);
    // }
  }

  double rowHeight = 75.w;

  int aNo = 0;
  bool isReal = true;

  bool isFirst = true;
  Map walletData = {};
  dataInit(Map wData) {
    if (!isFirst) return;
    isFirst = false;
    walletData = wData;
    aNo = walletData["a_No"] ?? 1;
    isReal = aNo <= 3;
    loadList();
  }

  List yearList = [];
  List monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  @override
  void onInit() {
    for (var i = 0; i < 50; i++) {
      yearList.add(DateTime.now().year - i);
    }
    Map publicHomeData = AppDefault().publicHomeData;
    brandList = [
      {"id": -1, "name": "不限"}
    ];
    if (publicHomeData["terminalBrand"] != null &&
        publicHomeData["terminalBrand"].isNotEmpty) {
      List terminalBrand = publicHomeData["terminalBrand"];
      for (var e in terminalBrand) {
        brandList.add({"id": e["enumValue"] ?? 0, "name": e["enumName"] ?? ""});
      }
    }
    super.onInit();
  }

  @override
  void onClose() {
    if (yearPickCtrl != null) {
      yearPickCtrl!.dispose();
    }
    if (monthPickCtrl != null) {
      monthPickCtrl!.dispose();
    }
    scrollCtrl.dispose();
    listController.dispose();
    filterCtrl.dispose();
    startMoneyInputCtrl.dispose();
    endMoneyInputCtrl.dispose();
    super.onClose();
  }
}

class MyWalletDealList extends GetView<MyWalletDealListController> {
  final Map walletData;
  final bool fromHome;
  final String title;
  const MyWalletDealList(
      {Key? key,
      this.walletData = const {},
      this.fromHome = false,
      this.title = "财务明细"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(walletData);
    return Scaffold(
        appBar: getDefaultAppBar(context, "钱包明细"),
        body: Stack(
          key: controller.stackKey,
          children: [
            // Positioned(
            //     top: 10.w,
            //     left: 15.w,
            //     right: 15.w,
            //     height: 137.w,
            //     child:
            //         // Image.asset(
            //         //   assetsName("earn/bg_wallet_deal_list_top"),
            //         //   width: 345.w,
            //         //   height: 137.w,
            //         //   fit: BoxFit.fill,
            //         // )
            //         Container(
            //       decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(12.w),
            //           color: Colors.white,
            //           boxShadow: [
            //             BoxShadow(
            //                 color: const Color(0xFFE9EDF5),
            //                 offset: Offset(0, 8.5.w),
            //                 blurRadius: 25.5.w,
            //                 spreadRadius: 15.5.w)
            //           ]),
            //     )),
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 0,
                key: controller.headKey,
                child: gemp()),
            // Positioned(
            //     top: 0,
            //     left: 0,
            //     right: 0,
            //     height: 160.w,
            //     child: Container(
            //       color: Colors.white,
            //       child: Column(
            //         children: [ghb(10.5), gwb(375), walletCell(walletData)],
            //       ),
            //     )),

            Positioned(
                // top: 160.w,
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: GetBuilder<MyWalletDealListController>(
                  builder: (_) {
                    return EasyRefresh.builder(
                      onLoad:
                          controller.walletDealList.length >= controller.count
                              ? null
                              : () => controller.walletDealList.length,
                      onRefresh: () => controller.loadList(),
                      childBuilder: (context, physics) {
                        return controller.walletDealList.isEmpty
                            ? GetX<MyWalletDealListController>(
                                builder: (_) {
                                  return CustomListEmptyView(
                                    physics: physics,
                                    isLoading: controller.isLoading,
                                  );
                                },
                              )
                            : ExpandableListView(
                                physics: physics,
                                padding: EdgeInsets.only(
                                    bottom: 20.w + paddingSizeBottom(context)),
                                controller: controller.scrollCtrl,
                                builder: SliverExpandableChildDelegate(
                                  controller: controller.listController,
                                  sectionList: controller.walletDealSectionList,
                                  // sectionBuilder: (context, containerInfo) {
                                  //   return sectionView();
                                  // },
                                  headerBuilder:
                                      (context, sectionIndex, index) {
                                    return sectionView(
                                        sectionIndex,
                                        controller.walletDealSectionList[
                                            sectionIndex]);
                                  },
                                  itemBuilder: (context, sectionIndex,
                                      itemIndex, index) {
                                    return rowView(controller
                                        .walletDealSectionList[sectionIndex]
                                        .dealList[itemIndex]);
                                  },
                                ),
                              );
                      },
                    );
                  },
                )),
            CustomDropDownView(
              dropDownCtrl: controller.filterCtrl,
              height: 345.w,
              dropWidget: filterView(),
              dropdownMenuChange: (isShow) {
                if (!isShow) {
                  takeBackKeyboard(context);
                }
              },
            )
          ],
        ));
  }

  Widget filterView() {
    return GestureDetector(
      onTap: () => takeBackKeyboard(Global.navigatorKey.currentContext!),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: 375.w,
              height: 345.w,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  centClm([
                    gline(375, 1),
                    sbhRow([
                      getSimpleText("交易类型", 15, AppColor.text, isBold: true),
                    ], width: 375 - 15 * 2, height: 55),
                    SizedBox(
                      width: 345.w,
                      child: Wrap(
                        spacing: 10.w,
                        children:
                            List.generate(controller.dealTypes.length, (index) {
                          return CustomButton(
                            onPressed: () {
                              controller.dealTypeIdx = index;
                            },
                            child: GetX<MyWalletDealListController>(
                              builder: (_) {
                                return Container(
                                  width: ((345 - 20) / 3 - 0.1).w,
                                  height: 30.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: controller.dealTypeIdx == index
                                          ? AppColor.theme
                                          : AppColor.theme.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.w)),
                                  child: getSimpleText(
                                      controller.dealTypes[index]["name"] ?? "",
                                      12,
                                      controller.dealTypeIdx == index
                                          ? Colors.white
                                          : AppColor.text2),
                                );
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    ghb(4.5),
                    sbhRow([
                      getSimpleText("起止时间", 15, AppColor.text, isBold: true),
                    ], width: 375 - 15 * 2, height: 55),
                    sbRow(
                        List.generate(3, (index) {
                          if (index == 1) {
                            return getSimpleText("至", 12, AppColor.text2);
                          } else {
                            return CustomButton(
                              onPressed: () {
                                takeBackKeyboard(
                                    Global.navigatorKey.currentContext!);
                                showDatePick(isStart: index == 0);
                              },
                              child: Container(
                                width: 150.w,
                                height: 30.w,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.5.w,
                                        color: AppColor.lineColor)),
                                child: Center(
                                  child: sbRow([
                                    gwb(18),
                                    GetX<MyWalletDealListController>(
                                      builder: (_) {
                                        String text = index == 0
                                            ? controller.startDate.isEmpty
                                                ? "开始时间"
                                                : controller.startDate
                                            : controller.endDate.isEmpty
                                                ? "结束时间"
                                                : controller.endDate;

                                        return getSimpleText(
                                            text,
                                            12,
                                            index == 0
                                                ? controller.startDate.isEmpty
                                                    ? AppColor.assisText
                                                    : AppColor.text
                                                : controller.endDate.isEmpty
                                                    ? AppColor.assisText
                                                    : AppColor.text);
                                      },
                                    ),
                                    Image.asset(
                                      assetsName("statistics/icon_date"),
                                      width: 18.w,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ], width: 150 - 8 * 2),
                                ),
                              ),
                            );
                          }
                        }),
                        width: 345),
                    ghb(4.5),
                    sbhRow([
                      getSimpleText("交易金额", 15, AppColor.text, isBold: true),
                    ], width: 375 - 15 * 2, height: 55),
                    sbRow(
                        List.generate(3, (index) {
                          if (index == 1) {
                            return getSimpleText("至", 12, AppColor.text2);
                          } else {
                            return Container(
                              width: 150.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5.w, color: AppColor.lineColor)),
                              child: Center(
                                  child: CustomInput(
                                width: 140.w,
                                heigth: 30.w,
                                textEditCtrl: index == 0
                                    ? controller.startMoneyInputCtrl
                                    : controller.endMoneyInputCtrl,
                                placeholder: index == 0 ? "最低金额" : "最高金额",
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textAlignVertical: TextAlignVertical.center,
                                placeholderStyle: TextStyle(
                                    fontSize: 12.w, color: AppColor.assisText),
                                style: TextStyle(
                                    fontSize: 12.w, color: AppColor.text2),
                              )),
                            );
                          }
                        }),
                        width: 345),
                  ]),
                  centRow(List.generate(
                      2,
                      (index) => CustomButton(
                            onPressed: () {
                              if (index == 0) {
                                controller.resetFilter();
                              } else {
                                controller.confirmFilter();
                              }
                            },
                            child: Container(
                              width: 375.w / 2 - 0.1.w,
                              height: 55.w,
                              color: index == 0
                                  ? AppColor.theme.withOpacity(0.1)
                                  : AppColor.theme,
                              child: Center(
                                child: getSimpleText(
                                    index == 0 ? "重置" : "确定",
                                    15,
                                    index == 0 ? AppColor.theme : Colors.white),
                              ),
                            ),
                          )))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDatePick({bool isStart = true}) async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    String dateStr = isStart ? controller.startDate : controller.endDate;
    DateTime initialDate;
    if (dateStr.isEmpty) {
      initialDate = DateTime.now();
    } else {
      initialDate = dateFormat.parse(dateStr);
    }
    DateTime? select = await showDatePicker(
        context: Global.navigatorKey.currentContext!,
        initialDate: initialDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
        lastDate: DateTime.now());
    if (select != null) {
      if (isStart) {
        controller.startDate = dateFormat.format(select);
      } else {
        var start = dateFormat.parse(controller.startDate);
        if (select.isBefore(start)) {
          ShowToast.normal("结束日期不能早于开始日期，请重新选择");
        } else {
          controller.endDate = dateFormat.format(select);
        }
      }
    }
  }

  String numFormat(dynamic num) {
    int no = walletData["a_No"] ?? -1;
    if (no == 4 || no == 5) {
      return integralFormat(num);
    } else {
      return priceFormat(num);
    }
  }

  Widget sectionView(int index, WalletDealSection section) {
    String inMoney =
        "收入:${!controller.isReal ? "" : "￥"}${priceFormat(section.inAmout)}";
    String outMoney =
        "支出:${!controller.isReal ? "" : "￥"}${priceFormat(section.outAmout)}";
    // double inWidth = calculateTextSize(inMoney, 14, FontWeight.normal,
    //         double.infinity, 1, Global.navigatorKey.currentContext!)
    //     .width;
    // double outWidth = calculateTextSize(outMoney, 14, FontWeight.normal,
    //         double.infinity, 1, Global.navigatorKey.currentContext!)
    //     .width;
    // outWidth += 12.w;
    return Container(
      color: AppColor.pageBackgroundColor,
      width: 375.w,
      height: 42.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomButton(
            onPressed: () {
              controller.showPick(section.year, section.month);
              showBottomDatePick(section.year, section.month);
            },
            child: SizedBox(
              height: 42.w,
              child: Align(
                alignment: Alignment.centerRight,
                child: centRow([
                  gwb(15),
                  getSimpleText("${section.year}年${section.month}月", 15,
                      AppColor.textBlack,
                      isBold: true),
                  gwb(3),
                  Image.asset(
                    assetsName("mine/wallet/icon_down_arrow_black"),
                    width: 10.w,
                    fit: BoxFit.fitWidth,
                  )
                ]),
              ),
            ),
          ),

          // getWidthText(
          //     "支出${!controller.isReal ? "" : "￥"}${priceFormat(section.outAmout)}",
          //     13,
          //     const Color(0xFF404040),
          //     inWidth,
          //     1),
          centRow([
            getSimpleText(outMoney, 12, AppColor.textGrey5),
            gwb(8),
            getSimpleText(inMoney, 12, AppColor.textGrey5),
            gwb(15)
          ]),

          // getWidthText(
          //     "收入${!controller.isReal ? "" : "￥"}${priceFormat(section.inAmout)}",
          //     13,
          //     const Color(0xFF404040),
          //     outWidth,
          //     1),
        ],
      ),
    );
  }

  Widget rowView(Map data) {
    // String img = data["account"] != null
    //     ? AppDefault().getAccountImg(data["account"])
    //     : "";
    // String imgUrl = AppDefault().imageUrl + img;

    return CustomButton(
      onPressed: () {
        push(EarnParticulars(earnData: data), null,
            binding: EarnParticularsBinding());
      },
      child: Container(
        // margin: EdgeInsets.only(top: 10.w),
        alignment: Alignment.center,
        width: 375.w,
        color: Colors.white,

        child: sbhRow([
          centClm([
            getSimpleText(data["codeName"] ?? "", 15, AppColor.textBlack),
            ghb(10),
            getWidthText(
                data["addTime"] ?? "", 12, AppColor.textGrey5, 200.5, 1)
          ], crossAxisAlignment: CrossAxisAlignment.start),
          centClm([
            getSimpleText(
                "${(data["bType"] ?? 0) == 0 ? "-" : "+"}${priceFormat(data["amount"], savePoint: (data["aNo"] ?? 0) <= 3 ? 2 : 0)}",
                18,
                (data["bType"] ?? 0) == 0
                    ? AppColor.textBlack
                    : const Color(0xFFF78A4A),
                isBold: true),
            ghb(7),
            getSimpleText(
                "余额 ${controller.isReal ? "￥" : ""}${priceFormat(data["balance"] ?? 0)}",
                12,
                AppColor.textGrey5)
          ], crossAxisAlignment: CrossAxisAlignment.end),
        ], width: 375 - 15 * 2, height: 75),
      ),
    );
  }

  // 品牌选择器
  showBrandSelectModel() {
    Get.bottomSheet(
        Container(
          width: 375.w,
          height:
              300.w + paddingSizeBottom(Global.navigatorKey.currentContext!),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
          child: Column(
            children: [
              sbhRow([
                CustomButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: SizedBox(
                      width: 65.w,
                      height: 58.w,
                      child: Center(
                          child: getSimpleText("取消", 14, AppColor.textGrey5))),
                ),
                CustomButton(
                  onPressed: () {
                    Get.back();
                    controller.loadList();
                  },
                  child: SizedBox(
                      width: 65.w,
                      height: 58.w,
                      child: Center(
                          child: getSimpleText("确定", 14, AppColor.theme))),
                )
              ], width: 375, height: 58),
              gline(375, 1),
              SizedBox(
                width: 375.w,
                height: 300.w - 59.w,
                child: CupertinoPicker.builder(
                  scrollController: FixedExtentScrollController(
                      initialItem: controller.brandIdx),
                  childCount: controller.brandList.length,
                  itemExtent: 45.w,
                  onSelectedItemChanged: (value) {
                    controller.brandIdx = value;
                  },
                  itemBuilder: (context, index) {
                    return Center(
                      child: GetX<MyWalletDealListController>(builder: (_) {
                        return getSimpleText(
                            controller.brandList[index]["name"],
                            16,
                            controller.brandIdx == index
                                ? AppColor.textBlack
                                : AppColor.textGrey5,
                            isBold: controller.brandIdx == index);
                      }),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true);
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
                },
                child: SizedBox(
                    width: 70.w,
                    height: 48.w,
                    child: Center(
                        child: getSimpleText("取消", 16, AppColor.textGrey))),
              ),
              CustomButton(
                onPressed: () {
                  controller.confirmPick();
                },
                child: SizedBox(
                    width: 70.w,
                    height: 48.w,
                    child: Center(
                        child: getSimpleText("确定", 16, AppColor.textBlack))),
              ),
            ], width: 375, height: 48),
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
      isDismissible: true,
      enableDrag: true,
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
                child: GetX<MyWalletDealListController>(
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

  Widget walletCell(Map data) {
    bool draw = data["haveDraw"] ?? false;

    Color lColor = data["lColor"] ?? const Color(0xFF6B96FD);
    Color rColor = data["rColor"] ?? const Color(0xFF366EFD);

    String unit = "";
    String inUnit = "";
    String outUnit = "";
    bool tenThousand = (data["amout"] ?? 0) > 100000.0;
    bool inTenThousand = (data["amout2"] ?? 0) > 100000.0;
    bool outTenThousand = (data["amout3"] ?? 0) > 100000.0;

    if ((data["a_No"] ?? 0) < 4) {
      unit = "(${(data["amout"] ?? 0) > 100000.0 ? "万" : ""}元)";
      inUnit = "(${(data["amout2"] ?? 0) > 100000.0 ? "万" : ""}元)";
      outUnit = "(${(data["amout3"] ?? 0) > 100000.0 ? "万" : ""}元)";
    } else {
      unit = (data["amout"] ?? 0) > 100000.0 ? "(万)" : "";
      inUnit = (data["amout2"] ?? 0) > 100000.0 ? "(万)" : "";
      outUnit = (data["amout3"] ?? 0) > 100000.0 ? "(万)" : "";
    }

    return Align(
      child: Container(
          // margin: EdgeInsets.only(top: 15.w),
          width: 345.w,
          height: 129.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lColor, rColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25.w),
                    child: sbRow([
                      centClm([
                        centRow([
                          getSimpleText(
                              "${data["name"] ?? ""}$unit", 14, Colors.white),
                          gwb(2),
                          Image.asset(
                            assetsName("mine/wallet/icon_right_arrow_white"),
                            width: 16.w,
                            fit: BoxFit.fitWidth,
                          )
                        ]),
                        ghb(10),
                        getSimpleText(
                            priceFormat(data["amout"] ?? 0,
                                tenThousand: tenThousand,
                                tenThousandUnit: false),
                            30,
                            Colors.white,
                            fw: FontWeight.w700,
                            textHeight: 1),
                      ], crossAxisAlignment: CrossAxisAlignment.start),
                      centClm([
                        centRow([
                          getSimpleText("总收入$inUnit：", 12, Colors.white),
                          getSimpleText(
                              priceFormat(data["amout2"] ?? 0,
                                  tenThousand: inTenThousand,
                                  tenThousandUnit: false),
                              14,
                              Colors.white)
                        ]),
                        ghb(5),
                        centRow([
                          getSimpleText("总支出$outUnit：", 12, Colors.white),
                          getSimpleText(
                              priceFormat(data["amout3"] ?? 0,
                                  tenThousand: outTenThousand,
                                  tenThousandUnit: false),
                              14,
                              Colors.white)
                        ])
                      ], crossAxisAlignment: CrossAxisAlignment.end)
                    ],
                        width: 345 - 21 * 2,
                        crossAxisAlignment: CrossAxisAlignment.start),
                  ),
                ],
              )),
              !draw
                  ? gemp()
                  : Positioned(
                      bottom: 16.w,
                      right: 0,
                      child: CustomButton(
                        onPressed: () {
                          checkIdentityAlert(toNext: () {
                            Get.offUntil(
                                GetPageRoute(
                                    page: () => MyWalletDraw(
                                          walletData: data,
                                        ),
                                    binding: MyWalletDrawBinding()),
                                (route) => route is GetPageRoute
                                    ? route.binding is MyWalletBinding
                                        ? true
                                        : false
                                    : false);
                          });
                        },
                        child: Container(
                          width: 75.w,
                          height: 24.w,
                          alignment: const Alignment(0.1, 0),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(12.w))),
                          child: getSimpleText("去提现", 12, rColor),
                        ),
                      )),
            ],
          )),
    );
  }
}

class WalletDealSection extends ExpandableListSection {
  final List dealList;
  final double inAmout;
  final double outAmout;
  final int year;
  final int month;
  WalletDealSection(
      {required this.dealList,
      this.inAmout = 0.0,
      this.outAmout = 0.0,
      required this.year,
      required this.month});
  bool isExpanded = true;

  @override
  List getItems() {
    return dealList;
  }

  @override
  bool isSectionExpanded() {
    return isExpanded;
  }

  @override
  void setSectionExpanded(bool expanded) {
    isExpanded = expanded;
  }
}
