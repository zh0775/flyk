import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/product/product_purchase_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductPurchaseListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductPurchaseListController>(ProductPurchaseListController());
  }
}

class ProductPurchaseListController extends GetxController {
  List purchaseDatas = [
    // {
    //   "img": "assets/images/product/img_lakala",
    //   "name": "VIP1盟友礼包",
    //   "mutity": false,
    //   "count": 25,
    //   "price": 7450.0
    // },
    // {
    //   "img": "assets/images/product/img_lakala",
    //   "name": "VIP1盟友礼包",
    //   "mutity": true,
    //   "count": 25,
    //   "price": 7450.0
    // },
    // {
    //   "img": "assets/images/product/img_lakala",
    //   "name": "VIP1盟友礼包",
    //   "mutity": true,
    //   "count": 25,
    //   "price": 7450.0
    // },
    // {
    //   "img": "assets/images/product/img_lakala",
    //   "name": "VIP1盟友礼包",
    //   "mutity": true,
    //   "count": 25,
    //   "price": 7450.0
    // },
    // {
    //   "img": "assets/images/product/img_lakala",
    //   "name": "VIP1盟友礼包",
    //   "mutity": true,
    //   "count": 25,
    //   "price": 7450.0
    // }
  ];

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  RefreshController pullCtrl = RefreshController();

  onLoad() async {
    loadList(isLoad: true);
  }

  onRefresh() async {
    loadList();
  }

  int pageSize = 10;
  int pageNo = 1;
  int count = 0;

  loadList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    simpleRequest(
      url: Urls.userLevelGiftList,
      params: {"pageSize": pageSize, "pageNo": pageNo, "levelType": 1},
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          count = data["count"];
          if (isLoad) {
            purchaseDatas = [...purchaseDatas, ...data["data"]];
            pullCtrl.loadComplete();
          } else {
            purchaseDatas = data["data"];
            pullCtrl.refreshCompleted();
          }
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
        update();
      },
      after: () {
        isLoading = false;
      },
    );
  }

  @override
  void onInit() {
    loadList();
    super.onInit();
  }
}

class ProductPurchaseList extends GetView<ProductPurchaseListController> {
  const ProductPurchaseList({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "礼包列表"),
        body: GetBuilder<ProductPurchaseListController>(
          init: controller,
          initState: (_) {},
          builder: (_) {
            return SmartRefresher(
              physics: const BouncingScrollPhysics(),
              controller: controller.pullCtrl,
              onLoading: controller.onLoad,
              onRefresh: controller.onRefresh,
              enablePullUp: controller.count > controller.purchaseDatas.length,
              child: controller.purchaseDatas.isEmpty
                  ? GetX<ProductPurchaseListController>(
                      init: controller,
                      builder: (_) {
                        return CustomEmptyView(
                          isLoading: controller.isLoading,
                        );
                      },
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 15.w),
                      itemCount: controller.purchaseDatas != null
                          ? controller.purchaseDatas.length
                          : 0,
                      itemBuilder: (context, index) {
                        return PurchaseCell(
                          index: index,
                          toDetail: (idx) {
                            toProductDetailAction(index, context);
                          },
                          cellData: controller.purchaseDatas[index],
                          // productData: widget.productData,
                        );
                      },
                    ),
            );
          },
        ));
  }

  void toProductDetailAction(int idx, BuildContext context) {
    push(
        ProductPurchaseDetail(
          productData: controller.purchaseDatas[idx],
          isBag: true,
        ),
        context,
        binding: ProductPurchaseDetailBinding());
  }
}

class PurchaseCell extends StatelessWidget {
  final Map cellData;
  final int? index;
  // final Map? productData;
  final Function(int idx)? toDetail;
  const PurchaseCell({
    Key? key,
    this.cellData = const {},
    this.index,
    this.toDetail,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (toDetail != null) {
          toDetail!(index ?? 0);
        }
      },
      child: Align(
        child: Container(
          margin: EdgeInsets.only(top: 15.w),
          width: 345.w,
          height: 130.w,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5.w)),
          child: Stack(
            children: [
              Positioned.fill(
                  left: 10.w,
                  right: 10.w,
                  child: Row(
                    children: [
                      CustomNetworkImage(
                        src: AppDefault().imageUrl + cellData["levelLogo"],
                        width: 100.w,
                        height: 100.w,
                        fit: BoxFit.fill,
                      ),
                      gwb(26),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(TextSpan(
                            text: cellData["levelTitle"],
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColor.textBlack),
                            // children: [
                            // widget.cellData!["mutity"]
                            //     ? TextSpan(
                            //         text: "（可多组合）",
                            //         style: TextStyle(
                            //             color: const Color(0xFFB3B3B3),
                            //             fontSize: 13.sp))
                            //     : const TextSpan()
                            // ]
                          )),
                          ghb(20),
                          // getSimpleText(
                          //     "¥${cellData!["price"]}${widget.cellData!["mutity"] ? "" : "/台"}",
                          //     18,
                          //     const Color(0xFFF13030))
                          getSimpleText(cellData["levelSubhead"] ?? "", 15,
                              AppColor.textGrey)
                        ],
                      )
                    ],
                  )),
              Positioned(
                  width: 96.w,
                  height: 30.w,
                  right: 0,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFDFEAFF),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5.w),
                            bottomLeft: Radius.circular(10.w))),
                    child: Center(
                      child: getSimpleText(
                          "设备：${cellData["levelTotalNum"] ?? 0}台",
                          12,
                          const Color(0xFF3782FF)),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
