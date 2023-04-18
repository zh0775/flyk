import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FinanceSpaceOrderListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<FinanceSpaceOrderListController>(
        FinanceSpaceOrderListController(datas: Get.arguments));
  }
}

class FinanceSpaceOrderListController extends GetxController {
  final dynamic datas;
  FinanceSpaceOrderListController({this.datas});

  final _topIdx = 0.obs;
  int get topIdx => _topIdx.value;
  set topIdx(v) {
    if (_topIdx.value != v) {
      _topIdx.value = v;
      loadData();
    }
  }

  int type = 0;
  int index = 0;
  final searchInputCtrl = TextEditingController();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  bool isPageAnimate = false;

  changePage(int? toIdx) {
    if (isPageAnimate) {
      return;
    }
    isPageAnimate = true;
    int idx = toIdx ?? typeIdx;
    pageCtrl
        .animateToPage(idx,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut)
        .then((value) {
      isPageAnimate = false;
    });
  }

  late PageController pageCtrl;

  List typeList = [];
  final _typeIdx = 0.obs;
  int get typeIdx => _typeIdx.value;
  set typeIdx(v) {
    if (isPageAnimate) {
      return;
    }
    if (_typeIdx.value != v) {
      _typeIdx.value = v;
      if (pageCtrl.positions.isEmpty) {
        return;
      }
      loadData(loadIdx: typeIdx);
      changePage(typeIdx);
    }
  }

  searchAction() {
    loadData(searchText: searchInputCtrl.text);
  }

  List pageNos = [];
  List pageSizes = [];
  List counts = [];
  List pullCtrls = [];
  List dataLists = [];

  String loadListBuildId = "InformationDetail_loadListBuildId_";

  loadData({bool isLoad = false, int? loadIdx, String? searchText}) {
    int myLoadIdx = loadIdx ?? typeIdx;
    isLoad ? pageNos[myLoadIdx]++ : pageNos[myLoadIdx] = 1;
    if (dataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "pageNo": pageNos[myLoadIdx],
      "pageSize": pageSizes[myLoadIdx],
      "handelStatus": typeList[myLoadIdx]["id"] ?? 0,
      "origin": topIdx + 1,
      "merType": type + 1,
    };

    if (searchText != null && searchText.isNotEmpty) {
      params["u_Number"] = searchText;
    }
    simpleRequest(
      url: type == 0
          ? Urls.userCreditCardOrderList
          : Urls.userCreditCardLoansOrderList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myLoadIdx] = data["count"] ?? 0;
          List mDatas = data["data"] ?? [];
          dataLists[myLoadIdx] =
              isLoad ? [...dataLists[myLoadIdx], ...mDatas] : mDatas;
          // isLoad
          //     ? pullCtrls[myLoadIdx].loadComplete()
          //     : pullCtrls[myLoadIdx].refreshCompleted();
          update(["$loadListBuildId$myLoadIdx"]);
        } else {
          // isLoad
          //     ? pullCtrls[myLoadIdx].loadFailed()
          //     : pullCtrls[myLoadIdx].refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  @override
  void onInit() {
    type = (datas ?? {})["type"] ?? 0;
    index = (datas ?? {})["index"] ?? 0;
    if (type == 0) {
      typeList = [
        {"id": 0, "name": "待确认"},
        {"id": 1, "name": "待再查"},
        {"id": 2, "name": "待激活"},
        {"id": 3, "name": "已完成"},
        {"id": 4, "name": "未通过"},
      ];
    } else {
      typeList = [
        {"id": 0, "name": "待确认"},
        {"id": 3, "name": "已完成"},
        {"id": 4, "name": "未通过"},
      ];
    }
    for (var item in typeList) {
      counts.add(0);
      pageNos.add(1);
      pageSizes.add(10);
      dataLists.add([]);
    }
    pageCtrl = PageController(initialPage: index);
    typeIdx = index;
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    // searchInputCtrl.dispose();
    super.onClose();
  }
}

class FinanceSpaceOrderList extends GetView<FinanceSpaceOrderListController> {
  const FinanceSpaceOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: controller.type == 1
          ? getDefaultAppBar(context, "我的订单")
          : getDefaultAppBar(
              context,
              "",
              flexibleSpace: Align(
                alignment: Alignment.bottomCenter,
                child: centRow(List.generate(
                    2,
                    (index) => GetX<FinanceSpaceOrderListController>(
                          builder: (_) {
                            return CustomButton(
                              onPressed: () {
                                controller.topIdx = index;
                              },
                              child: SizedBox(
                                height: kToolbarHeight,
                                child: Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    child: getSimpleText(
                                        index == 0 ? "我的订单" : "推广订单",
                                        18,
                                        controller.topIdx == index
                                            ? AppColor.text
                                            : AppColor.text3,
                                        isBold: true),
                                  ),
                                ),
                              ),
                            );
                          },
                        ))),
              ),
            ),
      body: Stack(
        children: [
          GetX<FinanceSpaceOrderListController>(
            builder: (_) {
              return controller.topIdx == 0
                  ? gemp()
                  : Positioned(
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
                                    placeholder: "请输入想要搜索的名称或手机号",
                                    placeholderStyle: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColor.assisText),
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
                      ));
            },
          ),
          GetX<FinanceSpaceOrderListController>(
            builder: (_) {
              return Positioned(
                  top: controller.topIdx == 0 ? 0 : 55.w,
                  left: 0,
                  right: 0,
                  height: 55.w,
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 46.w,
                            child: Row(
                              children: List.generate(
                                  controller.typeList.length, (index) {
                                return CustomButton(
                                  onPressed: () {
                                    controller.typeIdx = index;
                                  },
                                  child: Column(
                                    children: [
                                      ghb(20),
                                      GetX<FinanceSpaceOrderListController>(
                                          builder: (_) {
                                        return SizedBox(
                                          width: 375.w /
                                                  controller.typeList.length -
                                              0.1.w,
                                          child: Center(
                                            child: getSimpleText(
                                              controller.typeList[index]
                                                  ["name"],
                                              15,
                                              controller.typeIdx == index
                                                  ? AppColor.theme
                                                  : AppColor.text2,
                                              isBold:
                                                  controller.typeIdx == index,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            )),
                        GetX<FinanceSpaceOrderListController>(
                          builder: (_) {
                            return AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                top: 46.w,
                                width: 15.w,
                                left: controller.typeIdx *
                                        (375.w / controller.typeList.length -
                                            0.1.w) +
                                    ((375.w / controller.typeList.length -
                                                0.1.w) -
                                            15.w) /
                                        2,
                                height: 9.w,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(0.5.w),
                                      color: AppColor.theme,
                                    ),
                                    height: 2.w,
                                  ),
                                ));
                          },
                        )
                      ],
                    ),
                  ));
            },
          ),
          GetX<FinanceSpaceOrderListController>(
            builder: (controller) {
              return Positioned.fill(
                  top: controller.topIdx == 0 ? 55 : 105.w,
                  child: PageView.builder(
                    controller: controller.pageCtrl,
                    itemCount: controller.dataLists.length,
                    onPageChanged: (value) {
                      controller.typeIdx = value;
                    },
                    itemBuilder: (context, index) {
                      return list(index);
                    },
                  ));
            },
          )
        ],
      ),
    );
  }

  Widget list(int listIdx) {
    return GetBuilder<FinanceSpaceOrderListController>(
      id: "${controller.loadListBuildId}$listIdx",
      builder: (_) {
        return EasyRefresh.builder(
          // controller: controller.pullCtrls[listIdx],
          onLoad:
              controller.dataLists[listIdx].length >= controller.counts[listIdx]
                  ? null
                  : () => controller.loadData(isLoad: true),
          onRefresh: () => controller.loadData(),
          childBuilder: (context, physics) {
            return ListView.builder(
              physics: physics,
              itemCount: controller.dataLists[listIdx].isEmpty
                  ? 2
                  : controller.dataLists[listIdx].length + 1,
              padding: EdgeInsets.only(bottom: 20.w),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: sbhRow([
                      getWidthText(
                          "进入${controller.type == 0 ? "申卡" : "贷款"}页面浏览和${controller.type == 0 ? "申卡" : "贷款"}记录，不能全部视为${controller.type == 0 ? "申卡" : "贷款"}订单，根据${controller.type == 0 ? "银行" : "机构"}结算周期，${controller.type == 0 ? "银行" : "机构"}数据导入后，${controller.type == 0 ? "申卡" : "贷款"}通过，即已完成",
                          12,
                          AppColor.red,
                          345,
                          2),
                    ], width: 375 - 15 * 2, height: 52),
                  );
                } else {
                  if (controller.dataLists[listIdx].isEmpty) {
                    return GetX<FinanceSpaceOrderListController>(
                      builder: (_) {
                        return SingleChildScrollView(
                          physics: physics,
                          child: Center(
                            child: CustomEmptyView(
                                isLoading: controller.isLoading,
                                bottomSpace: 200.w),
                          ),
                        );
                      },
                    );
                  } else {
                    return cell(index - 1,
                        controller.dataLists[listIdx][index - 1], listIdx);
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  Widget cell(int index, Map data, int listIdx) {
    return Center(
      child: Container(
          margin: EdgeInsets.only(top: index != 0 ? 15.w : 0),
          width: 345.w,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
          child: Column(
            children: [
              gwb(345),
              sbhRow([
                centRow([
                  gwb(15),
                  getSimpleText(data["u_Name"] ?? "", 15, AppColor.text2,
                      isBold: true),
                  gwb(5),
                  getSimpleText(
                    hidePhoneNum(data["u_Mobile"] ?? ""),
                    12,
                    AppColor.text2,
                  ),
                ]),
                Container(
                  width: 50.w,
                  height: 18.w,
                  alignment: const Alignment(0, 0),
                  decoration: BoxDecoration(
                    color: ((controller.type == 0 && listIdx < 4) ||
                                (controller.type == 1 && listIdx < 2)
                            ? AppColor.theme
                            : AppColor.red)
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(9.w)),
                  ),
                  child: getSimpleText(
                      controller.typeList[listIdx]["name"],
                      10,
                      ((controller.type == 0 && listIdx < 4) ||
                              (controller.type == 1 && listIdx < 2)
                          ? AppColor.theme
                          : AppColor.red)),
                )
              ], width: 345, height: 50),
              gline(315, 0.5),
              SizedBox(
                height: 89.5.w,
                child: centClm(
                    List.generate(
                        3,
                        (index) => sbhRow([
                              getWidthText(
                                  index == 0
                                      ? "${controller.type == 0 ? "申卡" : "贷款"}类型"
                                      : index == 1
                                          ? "${controller.type == 0 ? "申卡" : "贷款"}条件"
                                          : "申请时间",
                                  12,
                                  AppColor.text3,
                                  58.5,
                                  1,
                                  textHeight: 1.25),
                              getWidthText(
                                  index == 0
                                      ? data["title"] ?? ""
                                      : index == 1
                                          ? data["subTitle"] ?? ""
                                          : data["addTime"] ?? "",
                                  12,
                                  AppColor.text2,
                                  315 - 58.5,
                                  1,
                                  textHeight: 1.25)
                            ], width: 315, height: 22)),
                    crossAxisAlignment: CrossAxisAlignment.start),
              )
            ],
          )),
    );
  }

  Widget loansCell(int index, Map data, int listIdx) {
    return Container();
  }
}
