import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class StatisticsBusinessListController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _needCleanInput = false.obs;
  bool get needCleanInput => _needCleanInput.value;
  set needCleanInput(v) => _needCleanInput.value = v;
  CustomDropDownController filterCtrl1 = CustomDropDownController();
  CustomDropDownController filterCtrl2 = CustomDropDownController();
  final searchInputCtrl = TextEditingController();

  List filterTypeList1 = [
    {"id": 0, "name": "默认排序"},
    {"id": 1, "name": "当日激活"},
    {"id": 2, "name": "当月激活"},
    {"id": 3, "name": "当月交易"},
    {"id": 4, "name": "级别排序"}
  ];

  List filterTypeList2 = [
    {"id": 0, "name": "默认排序2"},
    {"id": 1, "name": "当日激活2"},
    {"id": 2, "name": "当月激活2"},
    {"id": 3, "name": "当月交易2"},
    {"id": 4, "name": "级别排序2"}
  ];
  final _filterTypeIdx = 0.obs;
  int get filterTypeIdx => _filterTypeIdx.value;
  set filterTypeIdx(v) {
    if (_filterTypeIdx.value != v) {
      _filterTypeIdx.value = v;
      loadData();
    }
  }

  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();

  final _filterIdx = (-1).obs;
  int get filterIdx => _filterIdx.value;
  set filterIdx(v) => _filterIdx.value = v;

  final _filterIdx1 = (-1).obs;
  int get filterIdx1 => _filterIdx1.value;
  set filterIdx1(v) => _filterIdx1.value = v;
  int realFilterIdx1 = -1;

  final _filterIdx2 = (-1).obs;
  int get filterIdx2 => _filterIdx2.value;
  set filterIdx2(v) => _filterIdx2.value = v;
  int realFilterIdx2 = -1;

  filterSelectAction(int index, int clickIdx) {
    if (index == 0) {
      filterIdx1 = clickIdx;
      realFilterIdx1 = filterIdx1;
    } else {
      filterIdx2 = clickIdx;
      realFilterIdx2 = filterIdx2;
    }
    showFilter(index);
    loadData();
  }

  showFilter(int idx) {
    if (filterCtrl1.isShow) {
      filterCtrl1.hide();
      return;
    }
    if (filterCtrl2.isShow) {
      filterCtrl2.hide();
      return;
    }
    idx == 0
        ? filterCtrl1.show(stackKey, headKey)
        : filterCtrl2.show(stackKey, headKey);
    filterIdx = idx;
    // filterHeight =
    //     (filterIdx == 0 ? machineTypes.length : currentTypes.length) * 40.0;
    // showFilter();
  }

  List dataList = [];
  int pageNo = 1;
  int pageSize = 20;
  int count = 0;
  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
      "tmStatus": 0
    };

    if (searchInputCtrl.text.isNotEmpty) {
      params["tmName"] = searchInputCtrl.text;
    }

    if (dataList.isEmpty) {
      isLoading = true;
    }

    simpleRequest(
        url: Urls.userMerchantDetail,
        params: params,
        success: (success, json) {
          if (success) {
            Map data = json["data"] ?? {};
            count = data["count"];
            List tmpList = data["data"] ?? [];
            dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
            update();
          }
        },
        after: () {
          isLoading = false;
          isFirstLoading = false;
        },
        useCache: !isLoad);
  }

  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 200), () {
      loadData();
    });
    super.onReady();
  }

  searchInputListener() {
    needCleanInput = searchInputCtrl.text.isNotEmpty;
  }

  @override
  void onInit() {
    searchInputCtrl.addListener(searchInputListener);
    super.onInit();
  }

  @override
  void onClose() {
    searchInputCtrl.removeListener(searchInputListener);
    searchInputCtrl.dispose();
    filterCtrl1.dispose();
    filterCtrl2.dispose();
    super.onClose();
  }
}

class StatisticsBusinessList extends StatelessWidget {
  const StatisticsBusinessList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatisticsBusinessListController>(
        init: StatisticsBusinessListController(),
        builder: (controller) {
          return Stack(
            key: controller.stackKey,
            children: [
              Positioned(
                  key: controller.headKey,
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 106.w,
                  child: GetX<StatisticsBusinessListController>(
                      init: StatisticsBusinessListController(),
                      builder: (controller) {
                        return Column(
                          children: [
                            ghb(15),
                            Container(
                              width: 345.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.w)),
                              child: Row(
                                children: [
                                  gwb(12),
                                  CustomInput(
                                    textEditCtrl: controller.searchInputCtrl,
                                    width: (345 -
                                            12 -
                                            36 -
                                            1 -
                                            0.1 -
                                            (controller.needCleanInput
                                                ? 40
                                                : 0))
                                        .w,
                                    heigth: 40.w,
                                    placeholder: "请输入想要搜索的名称或手机号",
                                    placeholderStyle: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColor.assisText),
                                    style: TextStyle(
                                        fontSize: 12.sp, color: AppColor.text),
                                    onSubmitted: (p0) {
                                      takeBackKeyboard(context);
                                      controller.loadData();
                                    },
                                  ),
                                  controller.needCleanInput
                                      ? CustomButton(
                                          onPressed: () {
                                            controller.searchInputCtrl.clear();
                                          },
                                          child: SizedBox(
                                            width: 40.w,
                                            height: 40.w,
                                            child: Center(
                                              child: Image.asset(
                                                assetsName(
                                                    "statistics/machine/icon_phone_delete"),
                                                width: 20.w,
                                                height: 20.w,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        )
                                      : gwb(0),
                                  gline(0.5, 40),
                                  CustomButton(
                                    onPressed: () {
                                      takeBackKeyboard(context);
                                      controller.loadData();
                                    },
                                    child: SizedBox(
                                      width: 36.w,
                                      height: 40.w,
                                      child: Center(
                                        child: Image.asset(
                                          assetsName(
                                              "statistics_page/btn_input_search_orange"),
                                          width: 18.w,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            filterFormatBtn(),
                          ],
                        );
                      })),
              Positioned.fill(
                  top: 106.w,
                  child: GetBuilder<StatisticsBusinessListController>(
                      init: StatisticsBusinessListController(),
                      builder: (controller) {
                        return EasyRefresh.builder(
                            onLoad:
                                controller.dataList.length >= controller.count
                                    ? null
                                    : () => controller.loadData(isLoad: true),
                            onRefresh: () => controller.loadData(),
                            childBuilder: (context, physics) {
                              return controller.dataList.isEmpty
                                  ? GetX<StatisticsBusinessListController>(
                                      builder: (controller) {
                                        return controller.isFirstLoading &&
                                                !kIsWeb
                                            ? SkeletonListView(
                                                padding: EdgeInsets.all(15.w),
                                              )
                                            : CustomListEmptyView(
                                                physics: physics,
                                                isLoading: controller.isLoading,
                                              );
                                      },
                                    )
                                  : ListView.builder(
                                      physics: physics,
                                      padding: EdgeInsets.only(bottom: 20.w),
                                      itemCount: controller.dataList.length,
                                      itemBuilder: (context, index) {
                                        return cell(
                                            index,
                                            controller.dataList[index],
                                            controller);
                                      },
                                    );
                            });
                      })),
              dropView(0, controller),
              dropView(1, controller),
            ],
          );
        });
  }

  Widget cell(
      int index, Map data, StatisticsBusinessListController controller) {
    bool open = data["open"] ?? false;
    int cellCount = 5;
    return UnconstrainedBox(
      child: AnimatedContainer(
        margin: EdgeInsets.only(top: 15.w),
        duration: const Duration(milliseconds: 300),
        width: 345.w,
        height: open ? 75.w + 25.w + cellCount * 23.w + 45.w + 45.w : 165.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 75.w,
                child: Center(
                  child: sbRow([
                    centRow([
                      gwb(15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(45.w / 2),
                        child: CustomNetworkImage(
                          src: AppDefault().imageUrl + (data["u_Avatar"] ?? ""),
                          width: 45.w,
                          height: 45.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      gwb(9.5),
                      centClm([
                        centRow([
                          getSimpleText(
                              data["u_Name"] != null &&
                                      data["u_Name"].isNotEmpty
                                  ? data["u_Name"]
                                  : data["u_Mobile"] ?? "",
                              15,
                              AppColor.text2,
                              isBold: true),
                          gwb(5),
                          Image.asset(
                            assetsName(
                                "mine/vip/level${data["uL_Level"] ?? 1}"),
                            width: 31.5.w,
                            fit: BoxFit.fitWidth,
                          ),
                          getSimpleText(data["uLevelName"] ?? "", 10,
                              const Color(0xFFBB5D10))
                        ]),
                        ghb(5),
                        getSimpleText(hidePhoneNum(data["u_Mobile"] ?? ""), 12,
                            AppColor.text2),
                      ], crossAxisAlignment: CrossAxisAlignment.start)
                    ]),
                    Container(
                      width: 50.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(9.w)),
                          color: (data["tStatu"] ?? -1) == 1
                              ? AppColor.theme.withOpacity(0.1)
                              : (data["tStatu"] ?? -1) == 0
                                  ? AppColor.red.withOpacity(0.1)
                                  : Colors.transparent),
                      child: Align(
                        child: getSimpleText(
                            (data["tStatu"] ?? -1) == 1
                                ? "有效"
                                : (data["tStatu"] ?? -1) == 0
                                    ? "无效"
                                    : "",
                            10,
                            (data["tStatu"] ?? -1) == 1
                                ? AppColor.theme
                                : (data["tStatu"] ?? -1) == 0
                                    ? AppColor.red
                                    : Colors.transparent),
                      ),
                    )
                  ], width: 345, crossAxisAlignment: CrossAxisAlignment.start),
                ),
              ),
              AnimatedContainer(
                height: open ? 25.w + cellCount * 23.w + 45.w : 45.w,
                width: 315.w,
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                    color: AppColor.pageBackgroundColor,
                    borderRadius: BorderRadius.circular(4.w)),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      sbhRow([
                        Padding(
                          padding: EdgeInsets.only(left: 15.5.w),
                          child: Text.rich(TextSpan(
                              text: "累积交易(元)：",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColor.text2,
                                  fontWeight: AppDefault.fontBold),
                              children: [
                                TextSpan(
                                    text: priceFormat(data["tolAmt"] ?? 0,
                                        savePoint: 2,
                                        tenThousand:
                                            (data["tolAmt"] ?? 0) >= 100000,
                                        tenThousandUnit: false),
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColor.red,
                                        fontWeight: AppDefault.fontBold)),
                                TextSpan(
                                  text:
                                      "${(data["tolAmt"] ?? 0) >= 100000 ? "万" : ""}元",
                                ),
                              ])),
                        ),
                        SizedBox(
                          width: 31.w,
                          height: 45.w,
                          child: Center(
                              child: AnimatedRotation(
                            turns: open ? 1.25 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: Image.asset(
                              assetsName("statistics/icon_arrow_right_gray"),
                              width: 12.w,
                              fit: BoxFit.fitWidth,
                            ),
                          )),
                        ),
                      ], width: 315, height: 45),
                      gline(300, 0.5, color: const Color(0xFFDFDFDF)),
                      SizedBox(
                        width: 315.w,
                        height: 25.w + cellCount * 23.w,
                        child: (data["isLoading"] ?? false)
                            ? Center(
                                child: kIsWeb
                                    ? CustomEmptyView(
                                        isLoading: (data["isLoading"] ?? false),
                                        topSpace: 20,
                                        bottomSpace: 20,
                                        centerSpace: 10)
                                    : SkeletonParagraph(
                                        style: SkeletonParagraphStyle(
                                            padding: EdgeInsets.only(
                                                top: 15.w,
                                                left: 15.w,
                                                right: 15.w),
                                            lines: cellCount,
                                            spacing: 13.w,
                                            lineStyle: SkeletonLineStyle(
                                              // randomLength: true,
                                              // width: 265.w,
                                              height: 10.w,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              // minLength: 150.w,
                                              // maxLength: 160.w,
                                            )),
                                      ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(cellCount, (index) {
                                  String t1 = "";
                                  String t2 = "";
                                  Map oData = data["openData"] ?? {};
                                  if (cellCount == 8) {
                                    switch (index) {
                                      case 0:
                                        t1 = "注册时间";
                                        t2 = "${oData["zcTime"] ?? ""}";
                                        break;
                                      case 1:
                                        t1 = "盘主数量(人)";
                                        t2 = "${oData["ul3Num"] ?? 0}";
                                        break;
                                      case 2:
                                        t1 = "伙伴数量(人)";
                                        t2 = "${oData["ul2Num"] ?? 0}";
                                        break;
                                      case 3:
                                        t1 = "累计贡献(元)";
                                        t2 = priceFormat(oData["toAmt"] ?? 0,
                                            tenThousand: true);
                                        break;
                                      case 4:
                                        t1 = "累计收益(元)";
                                        t2 = priceFormat(oData["myAmt"] ?? 0,
                                            tenThousand: true);
                                        break;
                                      case 5:
                                        t1 = "库存(台)";
                                        t2 = "${oData["noBingNum"] ?? 0}";
                                        break;
                                      case 6:
                                        t1 = "已激活(台)";
                                        t2 = "${oData["atcNum"] ?? 0}";
                                        break;
                                      case 7:
                                        t1 = "有效激活(台)";
                                        t2 = "${oData["haveAtcNum"] ?? 0}";
                                        break;
                                    }
                                  } else {
                                    switch (index) {
                                      case 0:
                                        t1 = "注册时间";
                                        t2 = "${oData["zcTime"] ?? ""}";
                                        break;
                                      // case 1:
                                      //   t1 = "盘主数量(人)";
                                      //   t2 = "${oData["ul3Num"] ?? 0}";
                                      //   break;
                                      case 1:
                                        t1 = "伙伴数量(人)";
                                        t2 = "${oData["ul2Num"] ?? 0}";
                                        break;
                                      case 2:
                                        t1 = "累计贡献(元)";
                                        t2 = priceFormat(oData["toAmt"] ?? 0,
                                            tenThousand: true);
                                        break;
                                      case 3:
                                        t1 = "累计收益(元)";
                                        t2 = priceFormat(oData["myAmt"] ?? 0,
                                            tenThousand: true);
                                        break;
                                      case 4:
                                        t1 = "库存(台)";
                                        t2 = "${oData["noBingNum"] ?? 0}";
                                        break;
                                      case 5:
                                        t1 = "已激活(台)";
                                        t2 = "${oData["atcNum"] ?? 0}";
                                        break;
                                      case 6:
                                        t1 = "有效激活(台)";
                                        t2 = "${oData["haveAtcNum"] ?? 0}";
                                        break;
                                    }
                                  }

                                  return sbhRow([
                                    getSimpleText(t1, 12, AppColor.text3),
                                    getSimpleText(t2, 12, AppColor.text2),
                                  ], width: 315 - 15 * 2, height: 23);
                                }),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              // ghb(15),
            ],
          ),
        ),
      ),
    );
  }

  Widget dropView(int index, StatisticsBusinessListController controller) {
    double height = 0;
    height = (index == 0
            ? controller.filterTypeList1.length
            : controller.filterTypeList2.length) *
        40.0.w;
    // if (controller.title == "商家管理") {
    //   if (index == 0) {
    //     height = controller.sfFilterDatas.length * 40.0.w;
    //   } else {
    //     height = controller.ztFilterDatas.length * 40.0.w;
    //   }
    // } else if (controller.title == "团队管理" || controller.title == "自营管理") {
    //   height = controller.ztFilterDatas.length * 40.0.w;
    // } else if (controller.title == "商户管理") {
    //   if (index == 0) {
    //     height = controller.ztFilterDatas.length * 40.0.w;
    //   } else {
    //     height = controller.jxFilterDatas.length * 40.0.w;
    //   }
    // }

    return CustomDropDownView(
        dropDownCtrl:
            index == 0 ? controller.filterCtrl1 : controller.filterCtrl2,
        height: height,
        dropdownMenuChange: (isShow) {
          if (!isShow) {
            controller.filterIdx = -1;
          }
        },
        dropWidget: GetX<StatisticsBusinessListController>(
          builder: (_) {
            return filterView(
              index == 0
                  ? controller.filterTypeList1
                  : controller.filterTypeList2,
              index == 0 ? controller.filterIdx1 : controller.filterIdx2,
              onPressed: (clickIdx) {
                controller.filterSelectAction(index, clickIdx);
              },
            );
          },
        ));
  }

  Widget filterView(List filterList, int selectIdx,
      {Function(int clickIdx)? onPressed}) {
    return Container(
      color: Colors.white,
      height: filterList.length * 40.0.w,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(
              filterList.length,
              (index) => CustomButton(
                    onPressed: () {
                      if (onPressed != null) {
                        onPressed(index);
                      }
                    },
                    child: sbhRow([
                      getSimpleText(
                          filterList[index]["name"], 14, AppColor.text2),
                      selectIdx == index
                          ? Image.asset(
                              assetsName(
                                  "statistics_page/icon_cell_filter_selected"),
                              width: 15.w,
                              fit: BoxFit.fitWidth,
                            )
                          : gwb(0)
                    ], width: 375 - 15 * 2, height: 40),
                  )),
        ),
      ),
    );
  }

  Widget filterFormatBtn() {
    return centRow([
      GetX<StatisticsBusinessListController>(
        init: StatisticsBusinessListController(),
        builder: (controller) {
          return filterBtn("全部品牌", 0, controller.filterIdx1, controller,
              controller.filterTypeList1);
        },
      ),
      gwb(100),
      GetX<StatisticsBusinessListController>(
        init: StatisticsBusinessListController(),
        builder: (controller) {
          return filterBtn("所有商户", 1, controller.filterIdx2, controller,
              controller.filterTypeList2);
        },
      ),
    ]);
  }

  Widget filterBtn(
    String title,
    int filterIdx,
    int index,
    StatisticsBusinessListController controller,
    List filterList, {
    double? width,
    int count = 2,
    bool sort = false,
  }) {
    return CustomButton(
      onPressed: () {
        controller.showFilter(filterIdx);
      },
      child: SizedBox(
        // width: width ?? (375 - 20 * 2).w / count - 0.1.w,
        height: 50.w,
        child: centRow([
          getSimpleText(
              index == -1 ? title : filterList[index]["name"],
              14,
              controller.filterIdx == filterIdx
                  ? AppColor.textBlack
                  : AppColor.textGrey5,
              isBold: controller.filterIdx == filterIdx),
          gwb(5),
          Image.asset(
            assetsName(
                "statistics_page/icon_filter_${index >= 0 || controller.filterIdx == filterIdx ? "selected" : "normal"}"),
            width: 6.w,
            fit: BoxFit.fitWidth,
          )
        ]),
      ),
    );
  }
}
