import 'package:cxhighversion2/business/finance/finance_space_card_apply.dart';
import 'package:cxhighversion2/business/finance/finance_space_card_list.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FinanceSpaceHomeController extends GetxController {
  final dynamic datas;
  FinanceSpaceHomeController({this.datas});

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;
  List loansList = [
    // {
    //   "id": 0,
    //   "name": "中信信秒贷",
    //   "topAmout": "1000000000",
    //   "rate": 4.35,
    //   "count": 1256,
    // },
    // {
    //   "id": 0,
    //   "name": "快乐房抵贷",
    //   "topAmout": "1000000000",
    //   "rate": 4.35,
    //   "count": 1256,
    // },
    // {
    //   "id": 0,
    //   "name": "百拓校园贷",
    //   "topAmout": "1000000000",
    //   "rate": 4.35,
    //   "count": 1256,
    // },
  ];

  List cardList = [
    // {
    //   "id": 0,
    //   "name": "招商银行全球支付信用卡",
    //   "subTitle": "初审+首刷+M4补贴",
    //   "reward": 58.0,
    //   "img": "business/tmp_card",
    // },
    // {
    //   "id": 0,
    //   "name": "建行龙卡尊享白金信用卡",
    //   "subTitle": "初审+首刷+M4补贴",
    //   "reward": 68.0,
    //   "img": "business/tmp_card",
    // },
    // {
    //   "id": 0,
    //   "name": "农业银行金穗信用卡",
    //   "subTitle": "初审+首刷+M4补贴",
    //   "reward": 78.0,
    //   "img": "business/tmp_card",
    // },
    // {
    //   "id": 0,
    //   "name": "建行龙卡尊享白金信用卡",
    //   "subTitle": "初审+首刷+M4补贴",
    //   "reward": 88.0,
    //   "img": "business/tmp_card",
    // }
  ];

  loadCardList() {
    if (cardList.isEmpty && loansList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
        url: Urls.userCreditCardBankList,
        params: {
          "pageNo": 1,
          "pageSize": 4,
          "d_Type": 1,
        },
        success: (success, json) {
          if (success) {
            Map data = json["data"] ?? {};
            cardList = data["data"] ?? [];
            update();
          }
        },
        after: () {
          isLoading = false;
        },
        useCache: true);
  }

  loadLoansList() {
    if (cardList.isEmpty && loansList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
        url: Urls.userCreditCardLoansList,
        params: {
          "pageNo": 1,
          "pageSize": 4,
          "d_Type": 1,
        },
        success: (success, json) {
          if (success) {
            Map data = json["data"] ?? {};
            loansList = data["data"] ?? [];
            update();
          }
        },
        after: () {
          isLoading = false;
        },
        useCache: true);
  }

  @override
  void onInit() {
    loadCardList();
    loadLoansList();
    super.onInit();
  }
}

class FinanceSpaceHome extends GetView<FinanceSpaceHomeController> {
  const FinanceSpaceHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "金融区"),
      body: GetBuilder<FinanceSpaceHomeController>(
        init: FinanceSpaceHomeController(),
        builder: (controller) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: controller.cardList.isEmpty && controller.cardList.isEmpty
                ? GetX<FinanceSpaceHomeController>(
                    builder: (controller) {
                      return Center(
                        child: CustomEmptyView(
                          isLoading: controller.isLoading,
                        ),
                      );
                    },
                  )
                : Column(
                    children: [
                      gwb(375),
                      ghb(15),
                      cardList(),
                      loansList(),
                      ghb(50)
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget cardList() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          sbhRow([
            nSimpleText("热门信用卡", 16, isBold: true),
            CustomButton(
              onPressed: () {
                push(const FinanceSpaceCardList(), null,
                    binding: FinanceSpaceCardListBinding());
              },
              child: centRow([
                nSimpleText("查看更多", 12, color: AppColor.text3, textHeight: 1.2),
                Image.asset(
                  assetsName("mine/icon_right_arrow"),
                  width: 12.w,
                  fit: BoxFit.fitWidth,
                )
              ]),
            )
          ], width: 345 - 15.5 * 2, height: 45.5),
          ...List.generate(
              controller.cardList.length > 3 ? 3 : controller.cardList.length,
              (index) {
            Map data = controller.cardList[index];
            return SizedBox(
              width: (345 - 15 * 2).w,
              child: Column(
                children: [
                  ghb(index == 0 ? 8 : 17),
                  sbRow([
                    centRow([
                      CustomNetworkImage(
                        src: AppDefault().imageUrl + (data["images"] ?? ""),
                        width: 40.w,
                        fit: BoxFit.fitWidth,
                      ),
                      gwb(12),
                      centClm([
                        nSimpleText(data["title"] ?? "", 15, isBold: true),
                        ghb(5),
                        getSimpleText(
                            data["projectName"] ?? "", 12, AppColor.text2),
                      ], crossAxisAlignment: CrossAxisAlignment.start)
                    ]),
                    CustomButton(
                      onPressed: () {
                        push(const FinanceSpaceCardApply(), null,
                            binding: FinanceSpaceCardApplyBinding(),
                            arguments: {
                              "data": data,
                            });
                      },
                      child: Container(
                        width: 60.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.w),
                            border: Border.all(
                                width: 0.5.w, color: AppColor.theme)),
                        child: Center(
                          child: getSimpleText("申请", 12, AppColor.theme),
                        ),
                      ),
                    )
                  ], width: 345 - 15 * 2),
                  ghb(10),
                  sbRow([
                    Container(
                      height: 18.w,
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      decoration: BoxDecoration(
                          color: AppColor.theme.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2.w)),
                      child: Center(
                        child: getSimpleText(
                            "奖励￥${priceFormat(data["price"] ?? 0, savePoint: 0)}",
                            10,
                            AppColor.theme),
                      ),
                    )
                  ], width: 345 - (15 + 40 + 12) * 2),
                  ghb(16),
                  index !=
                          (controller.cardList.length > 3
                                  ? 3
                                  : controller.cardList.length) -
                              1
                      ? gline(315, 1)
                      : ghb(0)
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget loansList() {
    return controller.loansList.isEmpty
        ? ghb(0)
        : Container(
            margin: EdgeInsets.only(top: 15.w),
            width: 345.w,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
            child: Column(
              children: [
                sbhRow([
                  nSimpleText("热门贷款", 16, isBold: true),
                  CustomButton(
                    onPressed: () {
                      push(const FinanceSpaceCardList(), null,
                          binding: FinanceSpaceCardListBinding(),
                          arguments: {"type": 1});
                    },
                    child: centRow([
                      nSimpleText("查看更多", 12,
                          color: AppColor.text3, textHeight: 1.2),
                      Image.asset(
                        assetsName("mine/icon_right_arrow"),
                        width: 12.w,
                        fit: BoxFit.fitWidth,
                      )
                    ]),
                  )
                ], width: 345 - 15.5 * 2, height: 45.5),
                ...List.generate(
                    controller.loansList.length > 3
                        ? 3
                        : controller.loansList.length, (index) {
                  Map data = controller.loansList[index];
                  return SizedBox(
                    width: (345 - 15 * 2).w,
                    child: Column(
                      children: [
                        ghb(index == 0 ? 8 : 17),
                        sbhRow([
                          centRow([
                            centClm([
                              getWidthText(data["title"] ?? "", 15,
                                  AppColor.text, 120, 1,
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
                              getSimpleText(
                                  "${data["price1"] ?? 0}%", 14, AppColor.red),
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
                                      "type": 1,
                                    });
                              },
                              child: Container(
                                width: 60.w,
                                height: 30.w,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.w),
                                    border: Border.all(
                                        width: 0.5.w, color: AppColor.theme)),
                                child: Center(
                                  child:
                                      getSimpleText("申请", 12, AppColor.theme),
                                ),
                              ),
                            ),
                            ghb(12),
                            getRichText("${data["buyNum"] ?? 0}", "人申请", 10,
                                AppColor.red, 10, AppColor.text3)
                          ]),
                        ], width: 345 - 15 * 2, height: 100),
                        index !=
                                (controller.loansList.length > 3
                                        ? 3
                                        : controller.loansList.length) -
                                    1
                            ? gline(315, 1)
                            : ghb(0)
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
  }
}
