// 兑换榜单

import 'package:cxhighversion2/business/pointsMall/shopping_product_detail.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_button.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:get/get.dart';

class RedemptionListPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RedemptionListPageController>(RedemptionListPageController());
  }
}

class RedemptionListPageController extends GetxController {
  List collectList = [];

  loadData({String? searchStr}) {
    Map<String, dynamic> params = {
      "pageSize": 10,
      "pageNo": 1,
      "isBoutique": 0,
      "shop_Type": 2,
      "shop_Buy_Count": 0,
    };
    if (searchStr != null && searchStr.isNotEmpty) {
      params["shop_Name"] = searchStr;
    }
    simpleRequest(
      url: Urls.userProductList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          collectList = data["data"] ?? [];
          update();
        }
      },
      after: () {},
    );
  }

  loadAddCollect(Map data) {
    simpleRequest(
      url: Urls.userAddProductCollection(data["productId"], 1),
      params: {},
      success: (success, json) {
        if (success) {
          loadData();
        }
      },
      after: () {},
    );
  }

  loadRemoveCollect(Map data) {
    simpleRequest(
      url: Urls.userDeleteCollection(data["productId"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadData();
        }
      },
      after: () {},
    );
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }
}

class RedemptionListPage extends GetView<RedemptionListPageController> {
  const RedemptionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFD4649),
      appBar: getDefaultAppBar(context, '兑换榜单'),
      body: GetBuilder<RedemptionListPageController>(
        initState: (_) {},
        builder: (_) {
          return Stack(
            children: [
              Positioned(top: 0, child: redemptionTopBg()),
              Positioned(
                top: 171.w,
                left: 0.w,
                bottom: 0,
                child: redemptionList(),
              )
            ],
          );
        },
      ),
    );
  }

  Widget redemptionTopBg() {
    return Container(
      child: Image.asset(
        assetsName('business/redemption/bg'),
        width: 365.w,
        height: 260.w,
        fit: BoxFit.fitHeight,
      ),
    );
  }

  Widget redemptionList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: 375.w - 15.w * 2,
        margin: EdgeInsets.fromLTRB(15.w, 0, 15.w, 15.w),
        child: Column(
          children: List.generate((controller.collectList).length, (index) {
            Map data = controller.collectList[index];
            return redemptionItem(data);
          }),
        ),
      ),
    );
  }

  Widget redemptionItem(item) {
    return CustomButton(
      onPressed: () {
        push(const ShoppingProductDetail(), null,
            binding: ShoppingProductDetailBinding(), arguments: {"data": item});
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(3.w)),
        margin: EdgeInsets.only(bottom: 15.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3.w),
              child: CustomNetworkImage(
                src: AppDefault().imageUrl + (item["shopImg"] ?? ""),
                width: 120.w,
                height: 120.w,
                fit: BoxFit.cover,
              ),
            ),
            gwb(8),
            SizedBox(
              width: 345.w - 120.w - 8.w,
              height: 120.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 5.w),
                    child: getWidthText(item['shopName'] ?? '', 15,
                        AppColor.textBlack, 209.w, 2,
                        isBold: true),
                  ),
                  getSimpleText(
                      "${item['nowPoint'] ?? "0"}积分", 18, AppColor.theme3,
                      isBold: true, textAlign: TextAlign.left),
                  sbhRow([
                    getSimpleText("已兑${item['shopBuyCount'] ?? "已兑0"}个", 12,
                        AppColor.textGrey5,
                        textAlign: TextAlign.left),
                    centRow([
                      GetBuilder<RedemptionListPageController>(
                        builder: (_) {
                          return CustomButton(
                            onPressed: () {
                              if ((item["isCollect"] ?? 0) == 0) {
                                controller.loadAddCollect(item);
                              } else {
                                controller.loadRemoveCollect(item);
                              }

                              controller.update();
                            },
                            child: SizedBox(
                              width: 32.w,
                              height: 28.w,
                              child: Center(
                                child: Image.asset(
                                  assetsName(item["isCollect"] == 0
                                      ? 'business/mall/btn_iscollect'
                                      : 'business/mall/btn_collect'),
                                  width: 16.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ])
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
