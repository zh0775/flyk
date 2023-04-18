import 'dart:convert' as convert;

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_html_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/product/product_confirm_order.dart';
import 'package:cxhighversion2/product/product_vip_order.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProductPurchaseDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductPurchaseDetailController>(ProductPurchaseDetailController());
  }
}

class ProductPurchaseDetailController extends GetxController {
  bool isFirst = true;

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _pageIndex = 0.obs;
  get pageIndex => _pageIndex.value;
  set pageIndex(v) => _pageIndex.value = v;

  final _selectedIdx = 0.obs;
  get selectedIdx => _selectedIdx.value;
  set selectedIdx(v) => _selectedIdx.value = v;

  Map productData = {};
  final _bannerImgList = Rx<List>([]);
  List get bannerImgList => _bannerImgList.value;
  set bannerImgList(v) => _bannerImgList.value = v;

  final _payList = Rx<List>([]);
  List get payList => _payList.value;
  set payList(v) => _payList.value = v;
  late bool isBag;

  int normalCount = 0;
  int vCount = 0;

  dataInit(Map pData, bool bag) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    isBag = bag;
    productData = pData;
    dataFormat();
    loadDetail();
  }

  loadDetail() {
    simpleRequest(
        url: Urls.userLevelGiftShow(productData["levelGiftId"] ?? -1),
        params: {},
        success: (bool success, dynamic json) {
          if (success) {
            productData = json["data"];
            dataFormat();
          }
        },
        after: () {
          isLoading = false;
        });
  }

  dataFormat() {
    List tmp = [];
    {
      bannerImgList = productData["levelGiftImgList"] != null &&
              productData["levelGiftImgList"].isNotEmpty
          ? (productData["levelGiftImgList"] as String).split(",")
          : [];

      tmp = productData["levelGiftPaymentMethod"] != null &&
              productData["levelGiftPaymentMethod"].isNotEmpty
          ? convert.jsonDecode(productData["levelGiftPaymentMethod"])
          : [];
    }

    normalCount = 0;
    vCount = 0;
    payList = [];
    // if (isBag) {
    //   for (var item in tmp) {
    //     if (item["u_Type"] == 1) {
    //       if (normalCount == 0) {
    //         normalCount++;
    //         payList.add(item);
    //       }
    //     } else if (item["u_Type"] == 2) {
    //       vCount++;
    //       payList.add(item);
    //     }
    //   }
    // } else {
    //   payList = productData["bindLevelList"] ?? [];
    // }
    payList = productData["bindLevelList"] ?? [];
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }
}

class ProductPurchaseDetail extends GetView<ProductPurchaseDetailController> {
  final Map productData;
  final bool isBag;
  const ProductPurchaseDetail(
      {Key? key, required this.productData, this.isBag = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(productData, isBag);
    return Scaffold(
      appBar: getDefaultAppBar(context, "产品详情"),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                      width: 375.w,
                      height: 340.w,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: GetX<ProductPurchaseDetailController>(
                              init: controller,
                              initState: (_) {},
                              builder: (_) {
                                return PageView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: controller.bannerImgList.length,
                                  onPageChanged: (value) {
                                    controller.pageIndex = value;
                                  },
                                  itemBuilder: (context, index) {
                                    return CustomNetworkImage(
                                      src: AppDefault().imageUrl +
                                          controller.bannerImgList[index],
                                      width: 375.w,
                                      height: 340.w,
                                      fit: BoxFit.contain,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Positioned(
                              width: 327.w,
                              left: 23.5.w,
                              bottom: 35.w,
                              height: 2.w,
                              child:
                                  GetBuilder<ProductPurchaseDetailController>(
                                init: controller,
                                initState: (_) {},
                                builder: (_) {
                                  return Visibility(
                                    visible: controller.bannerImgList != null &&
                                        controller.bannerImgList.length > 1,
                                    child: Container(
                                      width: 327.w,
                                      height: 2.w,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(1.w)),
                                    ),
                                  );
                                },
                              )),
                          Positioned(
                              width: 327.w,
                              left: 23.5.w,
                              bottom: 35.w,
                              height: 2.w,
                              child: GetX<ProductPurchaseDetailController>(
                                init: controller,
                                builder: (_) {
                                  return Visibility(
                                    visible: controller.bannerImgList != null &&
                                        controller.bannerImgList.length > 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.fastOutSlowIn,
                                        width: (327.w /
                                                controller
                                                    .bannerImgList.length) *
                                            (controller.pageIndex + 1),
                                        height: 2.w,
                                        decoration: BoxDecoration(
                                            color: AppColor.textBlack,
                                            borderRadius:
                                                BorderRadius.circular(1.w)),
                                      ),
                                    ),
                                  );
                                },
                              )),
                        ],
                      )),
                  Container(
                      width: 372.w,
                      height: 123.w,
                      color: Colors.white,
                      child: GetBuilder<ProductPurchaseDetailController>(
                        init: controller,
                        builder: (_) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              getSimpleText(
                                  controller.productData["levelName"] ?? "",
                                  20,
                                  AppColor.textBlack,
                                  isBold: true),
                              // ghb(10),
                              // getSimpleText(productData["award"] ?? "", 15,
                              //     AppColor.textGrey),
                              ghb(10),
                              getSimpleText(productData["levelDescribe"] ?? "",
                                  15, AppColor.textGrey),
                              ghb(10),
                            ],
                          );
                        },
                      )),
                  ghb(10),
                  Container(
                    width: 375.w,
                    color: Colors.white,
                    child: Column(
                      children: [
                        ghb(20),
                        sectionTitle("商品信息"),
                        ghb(20),
                        GetBuilder<ProductPurchaseDetailController>(
                          init: controller,
                          builder: (_) {
                            return productInfo();
                          },
                        ),
                        ghb(20),
                      ],
                    ),
                  ),
                  ghb(20 * 2 + 90),
                  SizedBox(
                    height: paddingSizeBottom(context),
                  )
                ],
              ),
            ),
          ),
          Positioned(
              left: 15.w,
              bottom: 20.w + paddingSizeBottom(context),
              width: 345.w,
              height: 90.w,
              child: payButton(
                () {
                  if (controller.isLoading) {
                    ShowToast.normal("正在为您获取礼包信息，请稍等");
                    return;
                  }

                  push(
                      ProductConfirmOrder(
                        isBag: isBag,
                        productData: controller.productData,
                      ),
                      context,
                      binding: ProductConfirmOrderBinding());
                  // if (controller.payList.isEmpty) {
                  //   ShowToast.normal(isBag ? "暂无礼包" : "暂无购买方式");
                  //   return;
                  // }
                  // showPayChoose(context);
                },
              ))
        ],
      ),
    );
  }

  Widget payButton(Function() onPressed) {
    return CustomButton(
        onPressed: onPressed,
        child: Container(
          width: 345.w,
          height: 90.w,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5.w),
          ),
        ).blurred(
            colorOpacity: 0.3,
            blur: 2.5,
            blurColor: const Color(0xFFD1D1D1),
            overlay: Padding(
              padding: EdgeInsets.symmetric(horizontal: 34.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetBuilder<ProductPurchaseDetailController>(
                    init: controller,
                    builder: (_) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getSimpleText(
                              productData["levelName"], 16, AppColor.textBlack),
                          ghb(8),
                          getSimpleText(
                              priceFormat(
                                  "${controller.productData["nowPrice"] ?? 0}"),
                              14,
                              AppColor.textBlack),
                        ],
                      );
                    },
                  ),
                  Container(
                    width: 70.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                        color: AppColor.textBlack,
                        borderRadius: BorderRadius.circular(5.w)),
                    child: Center(
                      child: getSimpleText("去领取", 12, Colors.white),
                    ),
                  )
                ],
              ),
            )));

    // BackdropFilter(
    //   filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
    //   child: Container(
    //     width: 345.sp,
    //     height: 90,
    //     decoration: BoxDecoration(
    //       color: Colors.black.withOpacity(0.3),
    //       borderRadius: BorderRadius.circular(5),
    //     ),
    //   ),
    // );
  }

  Widget sectionTitle(String title) => Column(
        children: [
          getSimpleText(title, 15, AppColor.textBlack, isBold: true),
          ghb(8),
          Container(
            color: AppColor.pageBackgroundColor,
            width: 30.w,
            height: 4.w,
          ),
        ],
      );

  Widget productInfo() {
    return CustomHtmlView(
      src: controller.productData["levelGiftParameter"] ?? "",
    );
    //  SizedBox(
    //   height: 9 * 50.w,
    //   child: ListView.builder(
    //     physics: const NeverScrollableScrollPhysics(),
    //     // itemCount: 9,
    //     itemBuilder: (context, index) {
    //       return Container(
    //         padding: EdgeInsets.only(left: 20.w, right: 20.w),
    //         width: 375.w,
    //         height: 50.w,
    //         color: index % 2 == 0 ? AppColor.pageBackgroundColor : Colors.white,
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             // getSimpleText("支付机构", 15, AppColor.textBlack),
    //             // getSimpleText("拉卡拉", 15, AppColor.textGrey),
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );
  }

  void showPayChoose(BuildContext context) {
    double warpHeight = 0;
    int heightCount = 1;
    if ((controller.payList.length / 2) % 1 > 0) {
      heightCount = ((controller.payList.length / 2).floor() + 1);
    } else {
      heightCount = (controller.payList.length / 2).floor();
    }

    warpHeight = (160.0 * heightCount + 7 * (heightCount - 1)).w;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modelBottomCtx) {
        return StatefulBuilder(
          builder: (context, setModalBottomState) {
            return SizedBox(
              width: 375.w,
              height: 271.5.w + warpHeight,
              child: Stack(
                children: [
                  Positioned(
                    right: 24.w,
                    top: 0,
                    width: 37.w,
                    height: 56.5.w,
                    child: CustomButton(
                      onPressed: () {
                        Navigator.pop(modelBottomCtx);
                      },
                      child: Image.asset(
                        assetsName(
                          "common/btn_model_close",
                        ),
                        width: 37.w,
                        height: 56.5.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 57.w,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: const Color(0xFFEBEBEB),
                        child: Column(
                          children: [
                            ghb(19.5),
                            getSimpleText("选择${isBag ? "礼包" : "采购方式"}", 20,
                                AppColor.textBlack,
                                isBold: true),
                            ghb(19.5),
                            SizedBox(
                              width: (160 * 2 + 7).w,
                              child: Wrap(
                                runSpacing: 7.w,
                                spacing: 7.w,
                                children: controller.payList
                                    .asMap()
                                    .entries
                                    .map((e) => chooesButton(
                                        e.key,
                                        setModalBottomState,
                                        controller.payList[e.key]))
                                    .toList(),
                              ),
                            ),
                            ghb(24),
                          ],
                        ),
                      )),
                  Positioned(
                      left: 15.w,
                      bottom: 29.w,
                      child: CustomButton(
                        onPressed: () {
                          Navigator.pop(modelBottomCtx, () {});
                          // if (controller.selectedIdx == 0) {
                          //   push(
                          //       ProductConfirmOrder(
                          //         productData: productData,
                          //         payType: controller
                          //             .payList[controller.selectedIdx],
                          //       ),
                          //       context,
                          //       binding: ProductConfirmOrderBinding());
                          // } else {
                          if (isBag) {
                            push(
                                ProductVipOrder(
                                  title: productData["levelTitle"] ?? "",
                                  productData: controller.productData.isNotEmpty
                                      ? controller.productData
                                      : productData,
                                  payType: controller
                                      .payList[controller.selectedIdx],
                                ),
                                context,
                                binding: ProductVipOrderBinding());
                          } else {
                            push(
                                ProductConfirmOrder(
                                  isBag: isBag,
                                  productData: controller.productData,
                                  payType: controller
                                      .payList[controller.selectedIdx],
                                ),
                                context,
                                binding: ProductConfirmOrderBinding());
                          }
                          // }
                        },
                        child: Container(
                          width: 345.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: const Color(0xFF4282EB)),
                          child: Center(
                            child: getSimpleText("确定", 15, Colors.white,
                                isBold: true),
                          ),
                        ),
                      ))
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget chooesButton(int idx, StateSetter setModalBottomState, Map payData) {
    late String payName;
    bool isReal = false;
    String name = "";
    dynamic pList = convert.jsonDecode(payData["levelGiftPaymentMethod"]);
    if (isBag) {
      if (pList != null && pList is List && pList.isNotEmpty) {
        payName = payData["levelName"];
        name = payData["levelDescribe"];
      }
    } else {
      if (pList != null && pList is List && pList.isNotEmpty) {
        for (var item in pList) {
          if (item["u_Type"] == 1) {
            payName = "常规支付";
            isReal = true;
          } else {
            name = item["name"];
            payName = "${item["name"]}兑换";
            isReal = false;
          }
          break;
        }
      }
    }
    return CustomButton(
      onPressed: () {
        if (controller.selectedIdx != idx) {
          setModalBottomState(() {
            controller.selectedIdx = idx;
          });
        }
      },
      child: GetX<ProductPurchaseDetailController>(
        init: controller,
        initState: (_) {},
        builder: (_) {
          return Container(
            width: 159.5.w,
            height: 160.w,
            decoration: BoxDecoration(
              color: controller.selectedIdx == idx
                  ? Colors.white
                  : AppColor.pageBackgroundColor,
              borderRadius: BorderRadius.circular(4.w),
              border: controller.selectedIdx == idx
                  ? Border.all(width: 1.5.w, color: const Color(0xFF629AF9))
                  : Border.all(width: 0, color: Colors.transparent),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ghb(20),
                  getSimpleText(payName, 16, AppColor.textBlack),
                  ghb(5),
                  getSimpleText(
                      isBag ? name : ""
                      // "攒${payData["name"]}，大用处"
                      ,
                      12,
                      AppColor.textBlack),
                  ghb(20),
                  getSimpleText(
                    isBag
                        ? "平台购价"
                        : (isReal
                            ? "平台购价"
                            :
                            // "所需${payData["name"]}",
                            "所需$name"),
                    16,
                    idx == controller.selectedIdx
                        ? AppColor.textBlack
                        : AppColor.textGrey,
                  ),
                  ghb(5),
                  Text.rich(
                    TextSpan(
                        text: isBag
                            ? "¥${priceFormat(payData["nowPrice"] ?? 0)}"
                            : (isReal
                                ? "￥${priceFormat(payData["nowPrice"] ?? 0)}元/"
                                : "${integralFormat(payData["nowPrice"])}/"),
                        // "200/",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: AppDefault.fontBold,
                            color: idx == controller.selectedIdx
                                ? AppColor.textBlack
                                : AppColor.textGrey),
                        children: [
                          TextSpan(
                              text: isBag ? "元" : "台起",
                              // "起",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: idx == controller.selectedIdx
                                      ? AppColor.textBlack
                                      : AppColor.textGrey))
                        ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
