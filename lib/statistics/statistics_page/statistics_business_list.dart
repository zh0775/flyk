import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/statistics_page/statistics_business_detail.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class StatisticsBusinessListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsBusinessListController>(
        StatisticsBusinessListController());
  }
}

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

  /// 品牌筛选
  List filterTypeList1 = [];

  /// 商户类型筛选
  List filterTypeList2 = [];
  List businessEnum = [];
  loadBusiness() {
    simpleRequest(
        url: Urls.userMerchantStatusData,
        params: {},
        success: (success, json) {
          if (success) {
            List datas = json["data"];
            for (var item in filterTypeList2) {
              for (var item2 in datas) {
                if ("${item["enumValue"]}" == "${item2["status"]}") {
                  item["count"] = item2["num"];
                  break;
                }
              }
            }
            businessEnumFormat();
          }
        },
        after: () {});
  }

  loadBusinessCondition() {
    simpleRequest(
        url: Urls.userMerchantStatusSearch,
        params: {},
        success: (success, json) {
          if (success) {
            filterTypeList2 = json["data"];
            loadBusiness();
          }
        },
        after: () {});
  }

  loadBusinessEnum() {
    simpleRequest(
        url: Urls.userMerchantEnum,
        params: {},
        success: (success, json) {
          if (success) {
            businessEnum = (json["data"] ?? {})["children"] ?? [];
            if (filterTypeList2.isNotEmpty) {
              businessEnumFormat();
            }
          }
        },
        after: () {},
        useCache: true);
  }

  String businessEnumBuildId =
      "StatisticsBusinessListController_businessEnumBuildId";
  businessEnumFormat() {
    if (businessEnum.isNotEmpty && filterTypeList2.isNotEmpty) {
      for (var item in filterTypeList2) {
        if ("${item["enumValue"]}" == "0") {
          item["desc"] = "我的所有直属商户";
        }
        for (var item2 in businessEnum) {
          if ("${item["enumValue"]}" == "${item2["enumValue"]}") {
            item["desc"] = item2["enumDesc"];
            item["logo"] = item2["logo"];
          }
        }
      }
      filterTypeList2 = filterTypeList2
          .map(
            (e) => {
              "id": e["enumValue"] ?? -1,
              "name": e["enumName"] ?? "",
              "num": e["count"] ?? 0
            },
          )
          .toList();
      update([businessEnumBuildId]);
      isLoading = false;
    }
  }

  loadbusinessEnumData() {
    loadBusinessCondition();
    loadBusinessEnum();
  }

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
    Map<String, dynamic> params = {"pageSize": pageSize, "pageNo": pageNo};

    if (searchInputCtrl.text.isNotEmpty) {
      params["tmName"] = searchInputCtrl.text;
    }
    if (filterIdx1 >= 0 && filterTypeList1[filterIdx1]["id"] != -1) {
      params["tcId"] = "${filterTypeList1[filterIdx1]["id"]}";
    }

    if (filterIdx2 >= 0 &&
        filterIdx2 <= filterTypeList2.length - 1 &&
        filterTypeList2[filterIdx2]["id"] != -1) {
      params["tmStatus"] = "${filterTypeList2[filterIdx2]["id"]}";
    } else {
      params["tmStatus"] = 0;
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
      loadbusinessEnumData();
    });
    super.onReady();
  }

  searchInputListener() {
    needCleanInput = searchInputCtrl.text.isNotEmpty;
  }

  List brandList = [];
  @override
  void onInit() {
    searchInputCtrl.addListener(searchInputListener);
    Map publicHomeData = AppDefault().publicHomeData;
    List terminalBrands = publicHomeData["terminalConfig"] ?? [];
    if (terminalBrands.isNotEmpty) {
      filterTypeList1 = [
        {"name": "全部", "id": -1},
        ...terminalBrands
            .map((e) => {"id": e["id"] ?? -1, "name": e["terninal_Name"] ?? ""})
            .toList()
      ];
    }
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
  final bool isPage;
  const StatisticsBusinessList({super.key, this.isPage = false});

  @override
  Widget build(BuildContext context) {
    return isPage
        ? Scaffold(
            appBar: getDefaultAppBar(context, "商户列表"),
            body: contentView(context))
        : contentView(context);
  }

  Widget contentView(BuildContext context) {
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
              GetBuilder<StatisticsBusinessListController>(
                  init: StatisticsBusinessListController(),
                  id: controller.businessEnumBuildId,
                  builder: (controller) {
                    return dropView(1, controller);
                  })
            ],
          );
        });
  }

  Widget cell(
      int index, Map data, StatisticsBusinessListController controller) {
    bool open = data["open"] ?? false;
    int cellCount = 5;
    return CustomButton(
      onPressed: () {
        push(const StatisticsBusinessDetail(), null,
            binding: StatisticsBusinessDetailBinding(),
            arguments: {"data": data});
      },
      child: UnconstrainedBox(
          child: Container(
              margin: EdgeInsets.only(top: index == 0 ? 0 : 15.w),
              width: 345.w,
              decoration: getDefaultWhiteDec(radius: 4),
              child: Column(children: [
                sbhRow([
                  Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: getSimpleText(
                        data["merchantName"] ?? "", 16, AppColor.textBlack,
                        isBold: true),
                  ),
                  SizedBox(
                    height: 50.w,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 24.w,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        decoration: BoxDecoration(
                            color: AppColor.theme.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4.w),
                                bottomLeft: Radius.circular(8.w))),
                        child: getSimpleText("未达标", 10, AppColor.theme),
                      ),
                    ),
                  )
                ], width: 345, height: 50),
                sbhRow(
                    List.generate(
                        3,
                        (index) => index == 1
                            ? gline(1, 30)
                            : centClm([
                                getWidthText(
                                    index == 0
                                        ? priceFormat(data["thisMTxnAmt"] ?? 0)
                                        : data["terminalName"] ?? "",
                                    16,
                                    AppColor.textBlack,
                                    (345 - 15 * 2 - 1) / 2,
                                    1,
                                    isBold: true,
                                    textAlign: TextAlign.center,
                                    alignment: Alignment.center),
                                ghb(10),
                                getSimpleText(index == 0 ? "当月交易量(元)" : "设备品牌",
                                    12, AppColor.textBlack)
                              ])),
                    height: 80,
                    width: 345 - 15 * 2),
                sbRow(
                    List.generate(
                        3,
                        (index) => CustomButton(
                              onPressed: index == 0
                                  ? null
                                  : () {
                                      String phone =
                                          data["merchantPhone"] ?? "";
                                      if (phone.isEmpty) {
                                        ShowToast.normal("该商户没有配置电话号码");
                                        return;
                                      }
                                      if (index == 1) {
                                        callSMS(phone, "");
                                      } else {
                                        showAlert(
                                          Global.navigatorKey.currentContext!,
                                          "您即将拨打电话 $phone",
                                          confirmOnPressed: () {
                                            Get.back();
                                            callPhone(phone);
                                          },
                                        );
                                      }
                                    },
                              child: SizedBox(
                                height: 50.w,
                                child: centRow([
                                  Image.asset(
                                      assetsName(
                                          "statistics_page/btn_${index == 0 ? "to_detail" : index == 1 ? "sms" : "call_phone"}"),
                                      width: 21.w,
                                      fit: BoxFit.fitWidth),
                                  gwb(3),
                                  getSimpleText(
                                      index == 0
                                          ? "查看详情"
                                          : index == 1
                                              ? "发短信"
                                              : "打电话",
                                      12,
                                      AppColor.textBlack,
                                      isBold: true)
                                ]),
                              ),
                            )),
                    width: 345 - 30 * 2),
                ghb(5)
              ]))),
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

    return Builder(builder: (context) {
      double maxHeight = ScreenUtil().screenHeight -
          (Scaffold.of(context).appBarMaxHeight ?? 0) -
          (isPage
              ? 0
              : (kBottomNavigationBarHeight + paddingSizeBottom(context))) -
          106.w -
          50.w;

      return CustomDropDownView(
          dropDownCtrl:
              index == 0 ? controller.filterCtrl1 : controller.filterCtrl2,
          height: height > maxHeight ? maxHeight : height,
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
              }, height: height > maxHeight ? maxHeight : null);
            },
          ));
    });
  }

  Widget filterView(List filterList, int selectIdx,
      {Function(int clickIdx)? onPressed, double? height}) {
    return Container(
      color: Colors.white,
      height: height ?? filterList.length * 40.0.w,
      child: Scrollbar(
        child: SingleChildScrollView(
          physics: height != null
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
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
                            "${filterList[index]["name"]}${filterList[index]["num"] != null ? "(${filterList[index]["num"]})" : ""}",
                            14,
                            AppColor.text2),
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
                  fit: BoxFit.fitWidth)
            ])));
  }
}
