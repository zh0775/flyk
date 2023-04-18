import 'package:cxhighversion2/business/finance/finance_space_card_apply.dart';
import 'package:cxhighversion2/business/finance/finance_space_card_pop.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FinanceSpaceCardListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<FinanceSpaceCardListController>(
        FinanceSpaceCardListController(datas: Get.arguments));
  }
}

class FinanceSpaceCardListController extends GetxController {
  final dynamic datas;
  FinanceSpaceCardListController({this.datas});

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  int pageSize = 20;
  int pageNo = 1;
  int count = 0;
  List dataList = [];
  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: type == 0
          ? Urls.userCreditCardBankList
          : Urls.userCreditCardLoansList,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];
          dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
          update();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  // 0: 信用卡 1: 贷款
  int type = 0;

  @override
  void onInit() {
    type = (datas ?? {})["type"] ?? 0;
    loadData();
    super.onInit();
  }
}

class FinanceSpaceCardList extends GetView<FinanceSpaceCardListController> {
  const FinanceSpaceCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          getDefaultAppBar(context, controller.type == 0 ? "热门信用卡" : "热门贷款"),
      body: GetBuilder<FinanceSpaceCardListController>(
        builder: (_) {
          return EasyRefresh(
              onLoad: controller.count <= controller.dataList.length
                  ? null
                  : () => controller.loadData(isLoad: true),
              onRefresh: () => controller.loadData(),
              noMoreLoad: controller.count >= controller.dataList.length,
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 20.w),
                itemCount: controller.dataList.isEmpty
                    ? 2
                    : controller.dataList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Center(
                      child: sbhRow([
                        getSimpleText(
                            "*本页面相关信息仅供参考，不构成任务投资建议", 12, AppColor.text3),
                      ], width: 375 - 15 * 2, height: 36),
                    );
                  } else {
                    if (controller.dataList.isEmpty) {
                      return GetX<FinanceSpaceCardListController>(
                        builder: (_) {
                          return CustomEmptyView(
                            isLoading: controller.isLoading,
                          );
                        },
                      );
                    } else {
                      return controller.type == 0
                          ? cell(index - 1, controller.dataList[index - 1])
                          : loansCell(
                              index - 1, controller.dataList[index - 1]);
                    }
                  }
                },
              ));
        },
      ),
    );
  }

  Widget loansCell(int index, Map data) {
    return Center(
        child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(index == 0 ? 8.w : 0),
              bottom: Radius.circular(
                  index >= controller.dataList.length - 1 ? 8.w : 0))),
      width: 345.w,
      child: SizedBox(
        width: (345 - 15 * 2).w,
        child: Column(
          children: [
            ghb(index == 0 ? 8 : 17),
            sbhRow([
              centRow([
                centClm([
                  getWidthText(data["title"] ?? "", 15, AppColor.text, 120, 1,
                      isBold: true),
                  ghb(8),
                  getWidthText(
                    priceFormat(data["price"] ?? 0, savePoint: 0),
                    14,
                    AppColor.red,
                    120,
                    1,
                  ),
                  ghb(5),
                  getSimpleText("最高可贷(元)", 10, AppColor.text3),
                ], crossAxisAlignment: CrossAxisAlignment.start),
                centClm([
                  ghb(29),
                  getSimpleText("${data["price1"] ?? 0}%", 14, AppColor.red),
                  ghb(5),
                  getSimpleText("最高可贷(元)", 10, AppColor.text3),
                ], crossAxisAlignment: CrossAxisAlignment.start)
              ]),
              centClm([
                CustomButton(
                  onPressed: () {
                    push(const FinanceSpaceCardApply(), null,
                        binding: FinanceSpaceCardApplyBinding(),
                        arguments: {
                          "data": data,
                          "type": controller.type,
                        });
                  },
                  child: Container(
                    width: 60.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.w),
                        border:
                            Border.all(width: 0.5.w, color: AppColor.theme)),
                    child: Center(
                      child: getSimpleText("申请", 12, AppColor.theme),
                    ),
                  ),
                ),
                ghb(12),
                getRichText("${data["buyNum"] ?? 0}", "人申请", 10, AppColor.red,
                    10, AppColor.text3)
              ]),
            ], width: 345 - 15 * 2, height: 100),
          ],
        ),
      ),
    ));
  }

  Widget cell(int index, Map data) {
    return Center(
      child: Container(
        width: 345.w,
        height: 159.w,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(index == 0 ? 8.w : 0),
                bottom: Radius.circular(
                    index >= controller.dataList.length - 1 ? 8.w : 0))),
        child: Column(
          children: [
            index != 0 ? gline(315, 1) : ghb(0),
            sbhRow([
              centRow([
                CustomNetworkImage(
                  src: AppDefault().imageUrl + (data["images"] ?? ""),
                  width: 126.w,
                  height: 78.5.w,
                  fit: BoxFit.fill,
                ),
                gwb(11),
                centClm([
                  getWidthText(data["title"] ?? "", 15, AppColor.text,
                      315 - 11 - 126 - 1, 2,
                      isBold: true),
                  ghb(5),
                  getWidthText(
                    data["projectName"] ?? "",
                    12,
                    AppColor.text2,
                    315 - 11 - 126 - 1,
                    2,
                  ),
                  ghb(10),
                  Container(
                    height: 18.w,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                        color: AppColor.theme.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2.w)),
                    child: getSimpleText(
                        "奖励￥${data["price"]}", 10, AppColor.theme),
                  )
                ], crossAxisAlignment: CrossAxisAlignment.start)
              ])
            ], width: 345 - 15 * 2, height: 110),
            sbRow([
              gwb(0),
              centRow(List.generate(3, (index) {
                return index == 1
                    ? gwb(10)
                    : CustomButton(
                        onPressed: () {
                          if (index == 0) {
                            push(const FinanceSpaceCardPop(), null,
                                binding: FinanceSpaceCardPopBinding(),
                                arguments: {
                                  "data": data,
                                });
                          } else {
                            push(const FinanceSpaceCardApply(), null,
                                binding: FinanceSpaceCardApplyBinding(),
                                arguments: {
                                  "data": data,
                                });
                          }
                        },
                        child: Container(
                          width: 80.w,
                          height: 30.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.w),
                              color: index == 0 ? AppColor.theme : Colors.white,
                              border: Border.all(
                                  color: index == 0
                                      ? Colors.transparent
                                      : AppColor.theme,
                                  width: index == 0 ? 0 : 1.w)),
                          child: getSimpleText(index == 0 ? "我要推广" : "申请办卡", 12,
                              index == 0 ? Colors.white : AppColor.theme),
                        ),
                      );
              }))
            ], width: 315),
          ],
        ),
      ),
    );
  }
}
