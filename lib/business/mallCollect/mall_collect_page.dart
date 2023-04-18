/**
 * 积分商城收藏
 */

import 'package:cxhighversion2/business/pointsMall/shopping_product_detail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';

import 'package:easy_refresh/easy_refresh.dart';

import 'package:get/get.dart';

class MallCollectPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MallCollectPageController>(() => MallCollectPageController());
  }
}

class MallCollectPageController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isLoadCollect = false.obs;
  bool get isLoadCollect => _isLoadCollect.value;
  set isLoadCollect(v) => _isLoadCollect.value = v;

  List collectList = [];

  int pageSize = 10;
  int pageNo = 1;
  int count = 0;

  loadList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (collectList.isEmpty) {
      isLoading = true;
    }

    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
      "isBoutique": 1,
      "shop_Type": 2,
    };
    simpleRequest(
      url: Urls.userProductList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];
          collectList = isLoad ? [...collectList, ...tmpList] : tmpList;
          update();
        }
      },
      after: () {},
    );
  }

  loadAddCollect(Map data) {
    isLoadCollect = true;
    simpleRequest(
      url: Urls.userAddProductCollection(data["productId"], 1),
      params: {},
      success: (success, json) {
        if (success) {
          loadList();
        }
      },
      after: () {
        isLoadCollect = false;
      },
    );
  }

  loadRemoveCollect(Map data) {
    isLoadCollect = true;
    simpleRequest(
      url: Urls.userDeleteCollection(data["productId"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadList();
        }
      },
      after: () {
        isLoadCollect = false;
      },
    );
  }

  @override
  void onInit() {
    loadList();
    super.onInit();
  }
}

class MallCollectPage extends GetView<MallCollectPageController> {
  const MallCollectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        "我的收藏",
        action: [],
      ),
      body: GetBuilder<MallCollectPageController>(
        initState: (_) {},
        builder: (_) {
          return EasyRefresh(
            header: kIsWeb ? const MaterialHeader() : const CupertinoHeader(),
            footer: const CupertinoFooter(),

            onLoad: controller.collectList.length >= controller.count
                ? null
                : () => controller.loadList(isLoad: true),
            onRefresh: () => controller.loadList(),
            child: controller.collectList.isEmpty
                ? SingleChildScrollView(
                    child: Center(
                      child: GetX<MallCollectPageController>(
                        builder: (_) {
                          return CustomEmptyView(
                              type: CustomEmptyType.carNoData,
                              isLoading: controller.isLoading,
                              bottomSpace: 200.w);
                        },
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.collectList.length,
                    itemBuilder: (context, index) {
                      return collectItem(controller.collectList[index]);
                    },
                  ),
            // child: SingleChildScrollView(
            //   physics: const BouncingScrollPhysics(),
            //   child: Column(
            //     children: [collectList()],
            //   ),
            // ),
          );
        },
      ),
    );
  }

  // 收藏列表
  // Widget collectList() {
  //   return Column(
  //     children: List.generate(controller.collectList.length, (index) {
  //       Map data = controller.collectList[index];
  //       return collectItem(data);
  //     }),
  //   );
  // }

  // 收藏item
  Widget collectItem(item) {
    return CustomButton(
      onPressed: () {
        push(const ShoppingProductDetail(), null,
            binding: ShoppingProductDetailBinding(),
            arguments: {
              "data": item,
            });
      },
      child: Center(
        child: Container(
          width: 345.w,
          color: Colors.white,
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 15.w),
          child: Row(
            children: [
              centRow([
                CustomNetworkImage(
                  src: AppDefault().imageUrl + (item["shopImg"] ?? ""),
                  width: 120.w,
                  height: 120.w,
                  fit: BoxFit.fill,
                ),
                gwb(10),
                sbClm([
                  centClm([
                    getWidthText(
                      item['shopName'],
                      15,
                      AppColor.textBlack,
                      345 - 120 - 10 * 2,
                      2,
                    ),
                    ghb(5),
                    getSimpleText(
                        "${item['nowPrice'] ?? "0"}积分", 18, AppColor.theme3,
                        isBold: true),
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  sbRow([
                    getSimpleText("已兑${item['shopBuyCount'] ?? "已兑0"}个", 12,
                        AppColor.textGrey5,
                        textAlign: TextAlign.left),
                    centRow([
                      GetBuilder<MallCollectPageController>(
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
                            child: Image.asset(
                              assetsName((item["isCollect"] ?? 0) == 0
                                  ? 'business/mall/btn_collect'
                                  : 'business/mall/btn_iscollect'),
                              width: 32.w,
                              height: 28.w,
                            ),
                          );
                        },
                      )
                    ])
                  ], width: 345 - 120 - 10 * 2)
                ], crossAxisAlignment: CrossAxisAlignment.start, height: 105),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
