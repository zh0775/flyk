import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_html_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/product/product_store/product_store_confirm.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert' as convert;

class ProductStoreDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductStoreDetailController>(
        ProductStoreDetailController(datas: Get.arguments));
  }
}

class ProductStoreDetailController extends GetxController {
  final dynamic datas;
  ProductStoreDetailController({this.datas});

  cursorToEnd() {
    numInputCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: numInputCtrl.text.length));
  }

  final _isLoading = true.obs;
  set isLoading(v) => _isLoading.value = v;
  bool get isLoading => _isLoading.value;

  // 当前幻灯图下标
  final _pageIdx = 0.obs;
  set pageIdx(v) => _pageIdx.value = v;
  int get pageIdx => _pageIdx.value;
  int minCount = 1;
  final numInputCtrl = TextEditingController();
  final numNode = FocusNode();

  // 商品购买数量
  final _num = 1.obs;
  int get num => _num.value;
  set num(v) {
    if (_num.value != v) {
      _num.value = v;
      numInputCtrl.text = "$num";
      cursorToEnd();
    }
  }

  // 页面数据
  Map orderData = {};
  // 1:礼包 2:采购 3:兑换
  int levelType = 1;
  // 商品幻灯图
  final _bannerImgList = Rx<List>([]);
  List get bannerImgList => _bannerImgList.value;
  set bannerImgList(v) => _bannerImgList.value = v;

  loadDetail() {
    simpleRequest(
        url: Urls.userLevelGiftShow(orderData["levelGiftId"] ?? -1),
        params: {},
        success: (bool success, dynamic json) {
          if (success) {
            orderData = json["data"];
            dataFormat();
          }
        },
        after: () {
          isLoading = false;
        });
  }

  dataFormat() {
    // List tmp = [];
    bannerImgList = orderData["levelGiftImgList"] != null &&
            orderData["levelGiftImgList"].isNotEmpty
        ? (orderData["levelGiftImgList"] as String).split(",")
        : [];
    if (bannerImgList.isEmpty &&
        orderData["levelGiftImg"] != null &&
        orderData["levelGiftImg"].isNotEmpty) {
      bannerImgList = [orderData["levelGiftImg"] ?? ""];
    }
    // tmp = orderData["levelGiftPaymentMethod"] != null &&
    //         orderData["levelGiftPaymentMethod"].isNotEmpty
    //     ? convert.jsonDecode(orderData["levelGiftPaymentMethod"])
    //     : [];
    update();
  }

  @override
  void onReady() {
    loadDetail();
    super.onReady();
  }

  numNodeListener() {
    if (!numNode.hasFocus) {
      if (numInputCtrl.text.isEmpty) {
        ShowToast.normal("最少购买$minCount件哦");
        numInputCtrl.text = "$minCount";
        cursorToEnd();
        return;
      }
      if (int.tryParse(numInputCtrl.text) == null) {
        ShowToast.normal("请输入正确的数量");
        numInputCtrl.text = "$minCount";
        cursorToEnd();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        cursorToEnd();
      });
    }
  }

  numInputListener() {
    int? tNum = int.tryParse(numInputCtrl.text);
    if (tNum != null) {
      _num.value = tNum;
    }
  }

  @override
  void onInit() {
    numInputCtrl.text = "$minCount";
    numNode.addListener(numNodeListener);
    numInputCtrl.addListener(numInputListener);
    // 列表传过来的商品数据
    orderData = (datas ?? {})["data"] ?? {};
    // 1:礼包 2:采购 3:兑换
    levelType = (datas ?? {})["levelType"] ?? 1;
    super.onInit();
  }

  @override
  void onClose() {
    numNode.removeListener(numNodeListener);
    numInputCtrl.removeListener(numInputListener);
    numNode.dispose();
    numInputCtrl.dispose();
    super.onClose();
  }
}

class ProductStoreDetail extends GetView<ProductStoreDetailController> {
  const ProductStoreDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "产品详情"),
        body: Stack(
          children: [
            Positioned.fill(
              bottom: 60.w + paddingSizeBottom(context),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 商品幻灯图
                    pageImgView(),
                    // 商品信息
                    productInfoView(),
                    // 商品详细信息
                    productDetailInfoView(),
                    ghb(20)
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60.w + paddingSizeBottom(context),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(color: const Color(0x1A000000), blurRadius: 3.w)
                  ]),
                  child: Column(
                    children: [
                      ghb(10),
                      CustomButton(
                        onPressed: () {
                          showBuyModel();
                        },
                        child: Container(
                          width: 345.w,
                          height: 40.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.w),
                              gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFD573B),
                                    Color(0xFFFF3A3A)
                                  ])),
                          child: getSimpleText(
                              "立即${controller.levelType == 1 ? "升级" : controller.levelType == 2 ? "采购" : "兑换"}",
                              16,
                              Colors.white),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  // 商品幻灯图
  Widget pageImgView() {
    return SizedBox(
      width: 375.w,
      height: 375.w,
      child: GetX<ProductStoreDetailController>(builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
                child: PageView.builder(
              itemCount: controller.bannerImgList.length,
              itemBuilder: (context, index) {
                return CustomNetworkImage(
                  src: AppDefault().imageUrl + controller.bannerImgList[index],
                  width: 375.w,
                  height: 375.w,
                  fit: BoxFit.fill,
                );
              },
              onPageChanged: (value) {
                controller.pageIdx = value;
              },
            )),
            Positioned(
                height: 5.w,
                left: 0,
                right: 0,
                bottom: 19.w,
                child: centRow(List.generate(
                    controller.bannerImgList.length,
                    (index) => Container(
                          margin: EdgeInsets.only(left: index == 0 ? 0 : 5.w),
                          width: controller.pageIdx == index ? 15.w : 5.w,
                          height: 5.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.5.w),
                              color: controller.pageIdx == index
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.1)),
                        ))))
          ],
        );
      }),
    );
  }

  // 商品信息
  Widget productInfoView() {
    return Container(
      width: 345.w,
      color: Colors.white,
      margin: EdgeInsets.only(top: 15.w),
      child: GetBuilder<ProductStoreDetailController>(builder: (_) {
        bool isReal = controller.levelType != 3;
        bool isBean = false;
        String beanName = "";
        if (controller.levelType == 3) {
          List payTypes = convert
              .jsonDecode(controller.orderData["levelGiftPaymentMethod"]);
          if (payTypes.isNotEmpty &&
              payTypes.length == 1 &&
              (payTypes[0]["value"] ?? 0) == 5) {
            isBean = true;
          }
          beanName = "";
          List wallets = AppDefault().homeData["u_Account"] ?? [];
          for (var e in wallets) {
            if ((e["a_No"] ?? 0) == 5) {
              beanName = e["name"] ?? "";
              break;
            }
          }
        }

        return Column(
          children: [
            ghb(12),
            getWidthText(controller.orderData["levelName"] ?? "", 18,
                AppColor.textBlack, 315, 2),
            ghb(20),
            sbRow([
              getRichText(
                  isReal ? "￥" : "",
                  "${priceFormat(controller.orderData["nowPrice"] ?? 0)}${isReal ? "" : isBean ? beanName : "积分"}",
                  14,
                  const Color(0xFFFE4B3B),
                  24,
                  const Color(0xFFFE4B3B),
                  isBold2: true),
              getSimpleText("已售 ${controller.orderData["giftBuyCount"] ?? 0}",
                  12, AppColor.textGrey5)
            ], width: 315),
            ghb(10)
          ],
        );
      }),
    );
  }

  // 商品详细信息
  Widget productDetailInfoView() {
    return Container(
      width: 345.w,
      color: Colors.white,
      margin: EdgeInsets.only(top: 15.w),
      child: GetBuilder<ProductStoreDetailController>(builder: (_) {
        return Column(
          children: [
            SizedBox(
              height: 40.w,
              child: Center(
                child: getSimpleText("- 图文详情 -", 12, AppColor.textGrey2),
              ),
            ),
            CustomHtmlView(
              width: 315,
              src: controller.orderData["levelGiftParameter"] ?? "",
            ),
            ghb(10)
          ],
        );
      }),
    );
  }

  showBuyModel() {
    bool isReal = controller.levelType != 3;
    bool isBean = false;
    String beanName = "";
    if (controller.levelType == 3) {
      List payTypes =
          convert.jsonDecode(controller.orderData["levelGiftPaymentMethod"]);
      if (payTypes.isNotEmpty &&
          payTypes.length == 1 &&
          (payTypes[0]["value"] ?? 0) == 5) {
        isBean = true;
      }
      beanName = "";
      List wallets = AppDefault().homeData["u_Account"] ?? [];
      for (var e in wallets) {
        if ((e["a_No"] ?? 0) == 5) {
          beanName = e["name"] ?? "";
          break;
        }
      }
    }
    // ⏤+
    Get.bottomSheet(
            CustomButton(
              onPressed: () {
                takeBackKeyboard(Global.navigatorKey.currentContext!);
              },
              child: UnconstrainedBox(
                child: Container(
                  width: 375.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16.w))),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 375.w,
                        height: 143.w,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: CustomButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: SizedBox(
                                  width: 46.w,
                                  height: 46.w,
                                  child: Center(
                                    child: Image.asset(
                                        assetsName(
                                            "product_store/btn_bottom_model_close"),
                                        width: 12.w,
                                        height: 12.w,
                                        fit: BoxFit.fill),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                                child: Column(
                              children: [
                                ghb(18.5),
                                sbRow([
                                  centRow([
                                    CustomNetworkImage(
                                        src: AppDefault().imageUrl +
                                            (controller.orderData[
                                                    "levelGiftImg"] ??
                                                ""),
                                        width: 105.w,
                                        height: 105.w,
                                        fit: BoxFit.fill),
                                    gwb(15),
                                    sbClm([
                                      getWidthText(
                                          controller.orderData["levelName"] ??
                                              "",
                                          16,
                                          AppColor.textBlack,
                                          345 - 105 - 15 - 32,
                                          2,
                                          isBold: true),
                                      getRichText(
                                          isReal ? "￥" : "",
                                          "${priceFormat(controller.orderData["nowPrice"] ?? 0)}${isReal ? "" : isBean ? beanName : "积分"}",
                                          14,
                                          const Color(0xFFFE4B3B),
                                          24,
                                          const Color(0xFFFE4B3B),
                                          isBold2: true),
                                    ],
                                        height: 105,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start)
                                  ])
                                ], width: 345)
                              ],
                            ))
                          ],
                        ),
                      ),
                      ghb(19.5),
                      gline(345, 0.5),
                      ghb(15.5),
                      sbRow([
                        getSimpleText("数量", 14, AppColor.textBlack),
                        Container(
                          width: 91.w,
                          height: 25.w,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F7),
                              border: Border.all(
                                  width: 0.5.w, color: AppColor.lineColor),
                              borderRadius: BorderRadius.circular(25.w / 2)),
                          child: centRow(List.generate(
                              3,
                              (index) => index == 1
                                  ? Container(
                                      width: 40.w,
                                      height: 21.w,
                                      color: Colors.white,
                                      child: CustomInput(
                                        width: 40.w,
                                        heigth: 21.w,
                                        placeholder: "数量",
                                        placeholderStyle: TextStyle(
                                            fontSize: 15.sp,
                                            color: AppColor.textGrey5),
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color: AppColor.textBlack),
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        textAlign: TextAlign.center,
                                        focusNode: controller.numNode,
                                        keyboardType: TextInputType.number,
                                        textEditCtrl: controller.numInputCtrl,
                                      ))
                                  : CustomButton(
                                      onPressed: () {
                                        if (index == 0) {
                                          if (controller.num <= 1) {
                                            ShowToast.normal("最少购买一件");
                                            return;
                                          }
                                          controller.num -= 1;
                                        } else {
                                          controller.num += 1;
                                        }
                                      },
                                      child: GetX<ProductStoreDetailController>(
                                          builder: (_) {
                                        int myNum = controller.num;
                                        return SizedBox(
                                          width: 25.w - 0.1.w,
                                          height: 21.w,
                                          child: Center(
                                            child: getSimpleText(
                                                index == 0 ? "⏤" : "+",
                                                index == 0 ? 9 : 12,
                                                index == 0 && myNum <= 1
                                                    ? AppColor.textGrey5
                                                    : AppColor.textBlack),
                                          ),
                                        );
                                      }),
                                    ))),
                        )
                      ], width: 315),
                      ghb(24.5),
                      CustomButton(
                        onPressed: () {
                          takeBackKeyboard(Global.navigatorKey.currentContext!);
                          Get.back();
                          Future.delayed(const Duration(milliseconds: 250), () {
                            push(const ProductStoreConfirm(), null,
                                binding: ProductStoreConfirmBinding(),
                                arguments: {
                                  "data": controller.orderData,
                                  "levelType": controller.levelType,
                                  "num": controller.num,
                                });
                          });
                        },
                        child: Container(
                          width: 345.w,
                          height: 45.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.w),
                              gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFD573B),
                                    Color(0xFFFF3A3A)
                                  ])),
                          child: getSimpleText("确定", 16, Colors.white),
                        ),
                      ),
                      ghb(10),
                      SizedBox(
                          height: paddingSizeBottom(
                              Global.navigatorKey.currentContext!))
                    ],
                  ),
                ),
              ),
            ),
            isDismissible: true,
            isScrollControlled: true)
        .then((value) => takeBackKeyboard(Global.navigatorKey.currentContext!));
  }
}
