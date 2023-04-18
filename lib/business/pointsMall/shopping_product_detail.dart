import 'package:cxhighversion2/business/mallEvaluate/shopping_all_evaluate.dart';
import 'package:cxhighversion2/business/mallOrder/mall_order_confirm_page.dart';
import 'package:cxhighversion2/business/pointsMall/points_mall_page.dart';
import 'package:cxhighversion2/business/pointsMall/shopping_cart_page.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class ShoppingProductDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ShoppingProductDetailController>(
        ShoppingProductDetailController(datas: Get.arguments));
  }
}

class ShoppingProductDetailController extends GetxController {
  final dynamic datas;
  ShoppingProductDetailController({this.datas});

  final numInputCtrl = TextEditingController();
  moveCountInputLastLine() {
    numInputCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: numInputCtrl.text.length));
  }

  final numInputNode = FocusNode();

  String subSelectBuildId = "ShoppingProductDetailController_subSelectBuildId";

  List subSelects = [];

  Map productData = {};
  Map productDetailData = {};
  List childProducts = [];

  final _imgPageIdx = 0.obs;
  int get imgPageIdx => _imgPageIdx.value;
  set imgPageIdx(v) => _imgPageIdx.value = v;

  final imagePageCtrl = PageController();

  final _childProductIdx = 0.obs;
  int get childProductIdx => _childProductIdx.value;
  set childProductIdx(v) {
    if (_childProductIdx.value != v) {
      _childProductIdx.value = v;
      imgPageIdx = 0;
      imagePageCtrl.jumpToPage(imgPageIdx);
    }
  }

  final _subProductIdx = 0.obs;
  int get subProductIdx => _subProductIdx.value;
  set subProductIdx(v) => _subProductIdx.value = v;

  final _payTypeIdx = 0.obs;
  int get payTypeIdx => _payTypeIdx.value;
  set payTypeIdx(v) => _payTypeIdx.value = v;

  final _isLoadCollect = false.obs;
  bool get isLoadCollect => _isLoadCollect.value;
  set isLoadCollect(v) => _isLoadCollect.value = v;

  final _productNum = 1.obs;
  int get productNum => _productNum.value;
  set productNum(v) => _productNum.value = v;

  List getShopPropertyList() {
    List productPropertyList = [];
    List shopPropertyList =
        childProducts[childProductIdx]["shopPropertyList"] ?? [];
    for (var i = 0; i < shopPropertyList.length; i++) {
      Map e = shopPropertyList[i];
      int sIdx = subSelects[childProductIdx][i];
      if (sIdx <= (e["value"] ?? []).length - 1) {
        productPropertyList.add({
          "key": e["key"],
          "value": e["value"][sIdx],
        });
      }
    }
    return productPropertyList;
  }

  addCarAction() {
    // List productPropertyList = [];
    // List shopPropertyList =
    //     childProducts[childProductIdx]["shopPropertyList"] ?? [];
    // for (var i = 0; i < shopPropertyList.length; i++) {
    //   Map e = shopPropertyList[i];
    //   int sIdx = subSelects[childProductIdx][i];
    //   if (sIdx <= (e["value"] ?? []).length - 1) {
    //     productPropertyList.add({
    //       "key": e["key"],
    //       "value": e["value"][sIdx],
    //     });
    //   }
    // }
    simpleRequest(
      url: Urls.userAddToCart,
      params: {
        "product_Property_List": getShopPropertyList(),
        "product_ID": childProducts[childProductIdx]["productListId"],
        "num": productNum,
      },
      success: (success, json) {
        if (success) {
          ShowToast.normal("已加入购物车");
          Get.find<ShoppingCartPageController>().loadList();
        }
      },
      after: () {},
    );
  }

  toCarAction() {
    Get.find<PointsMallPageController>().tabIdx = 2;
    Get.find<ShoppingCartPageController>().loadList();
    Get.until((route) => route is GetPageRoute
        ? route.binding is PointsMallPageBinding ||
                route.binding is MainPageBinding
            ? true
            : false
        : false);
  }

  loadAddCollect(Map data) {
    isLoadCollect = true;
    simpleRequest(
      url: Urls.userAddProductCollection(data["productId"], 1),
      params: {},
      success: (success, json) {
        if (success) {
          loadDetail();
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
          loadDetail();
        }
      },
      after: () {
        isLoadCollect = false;
      },
    );
  }

  loadDetail() {
    if (productData.isEmpty) {
      return;
    }
    simpleRequest(
      url: Urls.userProductShow(productData["productId"]),
      params: {},
      success: (success, json) {
        if (success) {
          productDetailData = json["data"] ?? {};
          childProducts = productDetailData["childProduct"] ?? [];
          if (subSelects.isEmpty) {
            for (var e in childProducts) {
              List select = [];
              List pList = e["shopPropertyList"] ?? [];
              for (var e2 in pList) {
                select.add(0);
              }
              subSelects.add(select);
            }
          }

          changeData();
        }
      },
      after: () {},
    );
  }

  changeData() {
    Map currentData = {};
    if (childProductIdx <= childProducts.length - 1) {
      currentData = childProducts[childProductIdx];
      productData["shopImg"] = currentData["shopImg"] ?? "";
      productData["shopImgList"] = currentData["shopImgList"] ?? [];
      productData["shopName"] = productDetailData["shopName"] ?? "";
      productData["isCollect"] = currentData["isCollect"] ?? 0;
      productData["oldPrice"] = currentData["oldPrice"] ?? 0;
      productData["nowPrice"] = currentData["nowPrice"] ?? 0;
      productData["cashPrice"] = currentData["cashPrice"] ?? 0;
      productData["nowPoint"] = currentData["nowPoint"] ?? 0;
    }
    update();
  }

  numInputNodeListener() {
    if (numInputNode.hasFocus) {
      moveCountInputLastLine();
    } else {
      if (int.tryParse(numInputCtrl.text) == null) {
        ShowToast.normal("请输入正确的数量");
        numInputCtrl.text = "$productNum";
      } else if (int.parse(numInputCtrl.text) >
          (childProducts[childProductIdx]["shopStock"] ?? 1)) {
        numInputCtrl.text =
            "${(childProducts[childProductIdx]["shopStock"] ?? 1)}";
        productNum = (childProducts[childProductIdx]["shopStock"] ?? 1);
        ShowToast.normal("输入的数量大于库存");
      } else {
        productNum = int.parse(numInputCtrl.text);
      }
    }
  }

  @override
  void onInit() {
    numInputNode.addListener(numInputNodeListener);

    numInputCtrl.text = "$productNum";
    productData = (((datas ?? {})["data"] ?? {}) as Map);
    loadDetail();
    super.onInit();
  }

  @override
  void onClose() {
    numInputNode.removeListener(numInputNodeListener);
    imagePageCtrl.dispose();
    super.onClose();
  }
}

class ShoppingProductDetail extends GetView<ShoppingProductDetailController> {
  const ShoppingProductDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "详情"),
      body: GetBuilder<ShoppingProductDetailController>(builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
                bottom: 60.w + paddingSizeBottom(context),
                child: EasyRefresh(
                  header: const CupertinoHeader(),
                  // header: const ClassicHeader(showMessage: false),
                  onRefresh: () => controller.loadDetail(),
                  child: SingleChildScrollView(
                    child: Column(children: [
                      pageImageView(),
                      ghb(10),
                      GetX<ShoppingProductDetailController>(builder: (_) {
                        Map data = controller.childProductIdx <=
                                controller.childProducts.length - 1
                            ? controller
                                .childProducts[controller.childProductIdx]
                            : {};
                        return Container(
                          width: 345.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.w)),
                          child: Column(
                            children: [
                              ghb(11),
                              getWidthText(
                                "${data["shopTitle"] ?? ""}",
                                18,
                                AppColor.text,
                                315,
                                2,
                                isBold: true,
                              ),
                              ghb(8),
                              sbRow([
                                getSimpleText("库存:${data["shopStock"] ?? ""}",
                                    12, AppColor.textGrey5),
                              ], width: 315),
                              sbhRow([
                                getSimpleText(
                                    "${priceFormat(data["nowPrice"] ?? 0, savePoint: 0)}积分",
                                    18,
                                    AppColor.themeOrange,
                                    isBold: true),
                                getSimpleText(
                                  "已兑:${data["shopBuyCount"] ?? 0}",
                                  12,
                                  AppColor.textGrey5,
                                ),
                              ], width: 315, height: 30.5),
                              Padding(
                                padding:
                                    EdgeInsets.only(top: 8.w, bottom: 16.5.w),
                                child: sbRow([
                                  centRow([
                                    Container(
                                      height: 20.w,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6.w),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: AppColor.themeOrange
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(2.w)),
                                      child: getSimpleText(
                                          "全积分", 10, AppColor.themeOrange),
                                    ),
                                    gwb(9.5),
                                    (data["cashPrice"] ?? 0) > 0
                                        ? Container(
                                            height: 20.w,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: AppColor.themeOrange
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(2.w)),
                                            child: getSimpleText("积分+现金", 10,
                                                AppColor.themeOrange),
                                          )
                                        : gwb(0),
                                  ])
                                ], width: 315),
                              ),
                            ],
                          ),
                        );
                      }),
                      ghb(15),
                      Container(
                        width: 345.w,
                        padding: EdgeInsets.symmetric(vertical: 2.w),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.w)),
                        child: Column(
                          children: List.generate(
                              2,
                              (index) => CustomButton(
                                    onPressed: () {
                                      if (index == 0) {
                                        showSelectModel();
                                      }
                                    },
                                    child: sbhRow([
                                      centRow([
                                        gwb(15),
                                        getWidthText(index == 0 ? "已选" : "运费",
                                            14, AppColor.text, 40, 1,
                                            textHeight: 1.3),
                                        index == 0
                                            ? GetBuilder<
                                                ShoppingProductDetailController>(
                                                id: controller.subSelectBuildId,
                                                builder: (_) {
                                                  return GetX<
                                                      ShoppingProductDetailController>(
                                                    builder: (_) {
                                                      String str2 = "";
                                                      if (controller
                                                          .childProducts
                                                          .isNotEmpty) {
                                                        List shopPropertyList =
                                                            controller.childProducts[
                                                                        controller
                                                                            .childProductIdx]
                                                                    [
                                                                    "shopPropertyList"] ??
                                                                [];

                                                        for (var i = 0;
                                                            i <
                                                                shopPropertyList
                                                                    .length;
                                                            i++) {
                                                          int idx = controller
                                                                  .subSelects[
                                                              controller
                                                                  .childProductIdx][i];
                                                          if (idx >
                                                              (shopPropertyList[i]
                                                                              [
                                                                              "value"] ??
                                                                          [])
                                                                      .length -
                                                                  1) {
                                                          } else {
                                                            str2 += " ";

                                                            str2 +=
                                                                (shopPropertyList[
                                                                            i][
                                                                        "value"] ??
                                                                    [])[idx];
                                                          }
                                                        }
                                                      }

                                                      String str = "默认";
                                                      if (controller
                                                              .childProducts
                                                              .isEmpty &&
                                                          controller
                                                                  .childProductIdx >=
                                                              0) {
                                                        str = "默认";
                                                      } else {
                                                        str = controller.childProducts[
                                                                    controller
                                                                        .childProductIdx]
                                                                ["shopTitle"] ??
                                                            "";
                                                      }
                                                      return getWidthText(
                                                          str + str2,
                                                          14,
                                                          AppColor.textGrey5,
                                                          261,
                                                          1,
                                                          textHeight: 1.3);
                                                    },
                                                  );
                                                },
                                              )
                                            : getWidthText("在线支付免运费", 14,
                                                AppColor.textGrey5, 261, 1,
                                                textHeight: 1.3),
                                      ]),
                                      index == 0
                                          ? Padding(
                                              padding:
                                                  EdgeInsets.only(right: 9.5.w),
                                              child: Image.asset(
                                                assetsName(
                                                    "business/mall/arrow_right"),
                                                width: 18.w,
                                                fit: BoxFit.fitWidth,
                                              ),
                                            )
                                          : gwb(0),
                                    ], width: 345, height: 50),
                                  )),
                        ),
                      ),
                      ghb(15),
                      Container(
                        width: 345.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.w)),
                        child: CustomButton(
                          onPressed: () {
                            push(const ShoppingAllEvaluatePage(), context,
                                binding: ShoppingAllEvaluateBinding(),
                                arguments: {
                                  "data": controller.productDetailData,
                                });
                          },
                          child: sbhRow([
                            getSimpleText("商品评价", 14, AppColor.text),
                            SizedBox(
                              height: 50.w,
                              child: Center(
                                child: centRow([
                                  getSimpleText(
                                      "查看全部(${controller.productDetailData["commentNum"] ?? 0})",
                                      14,
                                      AppColor.textGrey5),
                                  Image.asset(
                                    assetsName("business/mall/arrow_right"),
                                    width: 18.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ]),
                              ),
                            )
                          ], width: 315, height: 50),
                        ),
                      ),
                      ghb(15),
                      detailInfo(),
                      ghb(20),
                    ]),
                  ),
                )),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60.w + paddingSizeBottom(context),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: const Color(0x0D000000),
                        offset: Offset(0, 2.w),
                        blurRadius: 4.w),
                  ]),
                  child: sbRow([
                    centRow(List.generate(3, (index) {
                      return CustomButton(
                        onPressed: () {
                          if (index == 0) {
                            Get.find<PointsMallPageController>().tabIdx = 0;
                            Get.until((route) => route is GetPageRoute
                                ? route.binding is PointsMallPageBinding ||
                                        route.binding is MainPageBinding
                                    ? true
                                    : false
                                : false);
                          } else if (index == 1) {
                            if ((controller.productDetailData["isCollect"] ??
                                    0) ==
                                0) {
                              controller.loadAddCollect(
                                  controller.productDetailData.isEmpty
                                      ? controller.productData
                                      : controller.productDetailData);
                            } else {
                              controller.loadRemoveCollect(
                                  controller.productDetailData.isEmpty
                                      ? controller.productData
                                      : controller.productDetailData);
                            }
                          } else {
                            controller.toCarAction();
                          }
                        },
                        child: Container(
                          height: 60.w,
                          margin: EdgeInsets.only(left: index == 0 ? 0 : 17.w),
                          child: Center(
                            child: centClm([
                              SizedBox(
                                height: 24.w,
                                child: Center(
                                  child: Image.asset(
                                    assetsName(index == 0
                                        ? "home/fodderlib/btn_home"
                                        : "business/mall/btn_${index == 1 ? (controller.productDetailData["isCollect"] ?? 0) == 0 ? "collect" : "iscollect" : "addcar"}"),
                                    height: index == 1 ? 20.w : 24.w,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                              ghb(3),
                              getSimpleText(
                                  index == 0
                                      ? "首页"
                                      : index == 1
                                          ? (controller.productDetailData[
                                                          "isCollect"] ??
                                                      0) ==
                                                  0
                                              ? "收藏"
                                              : "已收藏"
                                          : "购物车",
                                  12,
                                  AppColor.text)
                            ]),
                          ),
                        ),
                      );
                    })),
                    centRow(List.generate(2, (index) {
                      return CustomButton(
                          onPressed: () {
                            if (index == 0) {
                              if (controller.childProducts.isEmpty) {
                                ShowToast.normal("数据获取中，请稍等");
                                return;
                              }
                              controller.addCarAction();
                            } else {
                              // showSelectModel();
                              if (controller.childProducts.isEmpty) {
                                ShowToast.normal("数据获取中，请稍等");
                                return;
                              }
                              showSelectModel();
                            }
                          },
                          child: Container(
                            width: 105.w,
                            height: 40.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(index == 0 ? 20.w : 0),
                                right: Radius.circular(index == 1 ? 20.w : 0),
                              ),
                              color: index == 0
                                  ? const Color(0xFFFEB501)
                                  : AppColor.themeOrange,
                            ),
                            child: getSimpleText(index == 0 ? "加入购物车" : "立即兑换",
                                15, Colors.white),
                          ));
                    }))
                  ], width: 375 - 15 * 2),
                )),
          ],
        );
      }),
    );
  }

  Widget detailInfo() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          SizedBox(
            height: 40.w,
            child: Center(
              child: getSimpleText("- 图文详情 -", 12, AppColor.assisText),
              // child: getSimpleText("- 下拉查看图文详情 -", 12, AppColor.assisText),
            ),
          ),
          ghb(20),
          SizedBox(
              width: 315.w,
              child: HtmlWidget(
                  controller.productDetailData["shopParameter"] ?? "")),
          ghb(20),
        ],
      ),
    );
  }

  showSelectModel() {
    if (controller.childProducts.isEmpty) {
      ShowToast.normal("数据获取中，请稍等");
      return;
    }

    Get.bottomSheet(
      GetX<ShoppingProductDetailController>(builder: (_) {
        Map data = controller.childProducts[controller.childProductIdx];
        return GestureDetector(
          onTap: () => takeBackKeyboard(Global.navigatorKey.currentContext!),
          child: Container(
            height:
                450.w + paddingSizeBottom(Global.navigatorKey.currentContext!),
            width: 375.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
            ),
            child: Column(
              children: [
                sbRow([
                  Padding(
                    padding: EdgeInsets.only(top: 18.5.w),
                    child: centRow([
                      gwb(15),
                      CustomNetworkImage(
                        src: AppDefault().imageUrl + (data["shopImg"] ?? ""),
                        width: 105.w,
                        height: 105.w,
                        fit: BoxFit.cover,
                      ),
                      gwb(15),
                      sbClm([
                        getWidthText(
                            controller.productDetailData["shopName"] ?? "",
                            15,
                            AppColor.text,
                            375 - 105 - 15 - 15 - 40,
                            2,
                            isBold: true),
                        getSimpleText(
                            "库存：${controller.childProducts[controller.childProductIdx]["shopStock"] ?? 0}",
                            12,
                            AppColor.textGrey5),
                        getSimpleText(
                            "${priceFormat(controller.childProducts[controller.childProductIdx]["nowPrice"] ?? 0, savePoint: 0)}积分",
                            18,
                            AppColor.themeOrange,
                            isBold: true),
                      ],
                          height: 105,
                          crossAxisAlignment: CrossAxisAlignment.start),
                    ]),
                  ),
                  CustomButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: SizedBox(
                      height: 40.w,
                      width: 40.w,
                      child: Center(
                        child: Image.asset(
                          assetsName("statistics/machine/btn_model_close"),
                          width: 12.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  )
                ], width: 375, crossAxisAlignment: CrossAxisAlignment.start),
                ghb(19.5),
                gline(345, 1),
                SizedBox(
                  height: 180.w,
                  width: 375.w,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child:
                          GetX<ShoppingProductDetailController>(builder: (_) {
                        List shopPropertyList = (controller
                                    .childProducts[controller.childProductIdx]
                                ["shopPropertyList"] ??
                            []);
                        return Column(
                          children: [
                            ghb(13.5),
                            sbhRow([
                              getSimpleText("类型", 14, AppColor.text),
                            ], height: 45, width: 345),
                            SizedBox(
                              width: 345.w,
                              child: Wrap(
                                spacing: 15.w,
                                runSpacing: 10.w,
                                children: List.generate(
                                    controller.childProducts.length, (index) {
                                  return CustomButton(
                                    onPressed: () {
                                      controller.childProductIdx = index;
                                    },
                                    child: selectBtn(
                                        controller.childProducts[index]
                                            ["shopTitle"],
                                        controller.childProductIdx == index),
                                  );
                                }),
                              ),
                            ),
                            ...List.generate(shopPropertyList.length,
                                (propertyIndex) {
                              Map pData = shopPropertyList[propertyIndex];
                              return centClm([
                                sbhRow([
                                  getSimpleText(
                                      pData["key"] ?? "", 14, AppColor.text),
                                ], height: 45, width: 345),
                                GetBuilder<ShoppingProductDetailController>(
                                    id: controller.subSelectBuildId,
                                    builder: (_) {
                                      return SizedBox(
                                        width: 345.w,
                                        child: Wrap(
                                          spacing: 15.w,
                                          runSpacing: 10.w,
                                          children: List.generate(
                                              (pData["value"] ?? []).length,
                                              (valueIndex) {
                                            String vData = (pData["value"] ??
                                                [])[valueIndex];
                                            return CustomButton(
                                              onPressed: () {
                                                controller.subSelects[controller
                                                            .childProductIdx]
                                                        [propertyIndex] =
                                                    valueIndex;
                                                controller.update([
                                                  controller.subSelectBuildId
                                                ]);
                                              },
                                              child: selectBtn(
                                                  vData,
                                                  // index == 0
                                                  //     ? "${priceFormat(controller.productData["nowPrice"] ?? 0, savePoint: 0)}积分"
                                                  //     : "${priceFormat(controller.productData["nowPoint"] ?? 0, savePoint: 0)}积分+${priceFormat(controller.productData["cashPrice"] ?? 2, savePoint: 0)}元",
                                                  controller.subSelects[controller
                                                              .childProductIdx]
                                                          [propertyIndex] ==
                                                      valueIndex),
                                            );
                                          }),
                                        ),
                                      );
                                    })
                              ]);
                            }),
                            ghb(12),
                            sbhRow([
                              getSimpleText("支付方式", 14, AppColor.text),
                            ], height: 45, width: 345),
                            SizedBox(
                              width: 345.w,
                              child: Wrap(
                                spacing: 15.w,
                                runSpacing: 10.w,
                                children: List.generate(
                                    (controller.childProducts[controller
                                                        .childProductIdx]
                                                    ["cashPrice"] ??
                                                0) >
                                            0
                                        ? 2
                                        : 1, (index) {
                                  return CustomButton(
                                    onPressed: () {
                                      controller.payTypeIdx = index;
                                    },
                                    child:
                                        GetX<ShoppingProductDetailController>(
                                            builder: (_) {
                                      return selectBtn(
                                          index == 0
                                              ? "${priceFormat(controller.childProducts[controller.childProductIdx]["nowPrice"] ?? 0, savePoint: 0)}积分"
                                              : "${priceFormat(controller.childProducts[controller.childProductIdx]["nowPoint"] ?? 0, savePoint: 0)}积分+${priceFormat(controller.childProducts[controller.childProductIdx]["cashPrice"] ?? 0, savePoint: 0)}元",
                                          // index == 0
                                          //     ? "${priceFormat(controller.productData["nowPrice"] ?? 0, savePoint: 0)}积分"
                                          //     : "${priceFormat(controller.productData["nowPoint"] ?? 0, savePoint: 0)}积分+${priceFormat(controller.productData["cashPrice"] ?? 2, savePoint: 0)}元",
                                          controller.payTypeIdx == index);
                                    }),
                                  );
                                }),
                              ),
                            ),
                            ghb(15),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                sbRow([
                  getSimpleText("数量", 14, AppColor.text),
                  Container(
                      width: 90.w,
                      height: 25.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.5.w),
                          color: AppColor.pageBackgroundColor,
                          border: Border.all(
                              width: 0.5.w, color: AppColor.lineColor)),
                      child: Row(
                        children: List.generate(
                            3,
                            (idx) => idx == 1
                                ? Container(
                                    width: 40.w - 1.w,
                                    height: 21.w,
                                    color: Colors.white,
                                    child: CustomInput(
                                      width: 40.w - 1.w,
                                      heigth: 21.w,
                                      textEditCtrl: controller.numInputCtrl,
                                      focusNode: controller.numInputNode,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          fontSize: 15.w, color: AppColor.text),
                                      placeholderStyle: TextStyle(
                                          fontSize: 15.w,
                                          color: AppColor.assisText),
                                    ),
                                  )
                                : CustomButton(
                                    onPressed: () {
                                      int num = controller.productNum;
                                      int count = controller.childProducts[
                                                  controller.childProductIdx]
                                              ["shopStock"] ??
                                          1;

                                      if (idx == 0) {
                                        if (num > 1) {
                                          controller.productNum -= 1;
                                        }
                                      } else {
                                        if (num < count) {
                                          controller.productNum += 1;
                                        }
                                      }
                                      controller.numInputCtrl.text =
                                          "${controller.productNum}";
                                      controller.moveCountInputLastLine();
                                    },
                                    child: SizedBox(
                                      width: 25.w - 0.1.w,
                                      height: 25.w,
                                      child: Center(
                                        child: Icon(
                                          idx == 0 ? Icons.remove : Icons.add,
                                          size: 18.w,
                                          color: idx == 0
                                              ? (controller.productNum <= 1
                                                  ? AppColor.assisText
                                                  : AppColor.textBlack)
                                              : (controller.productNum >=
                                                      (controller.childProducts[
                                                                  controller
                                                                      .childProductIdx]
                                                              ["shopStock"] ??
                                                          1)
                                                  ? AppColor.assisText
                                                  : AppColor.textBlack),
                                        ),
                                      ),
                                    ),
                                  )),
                      ))
                ], width: 345),
                ghb(20),
                getSubmitBtn("确定", () {
                  Get.back();

                  Map childProduct = Map.from(
                      controller.childProducts[controller.childProductIdx]);

                  childProduct["shopPropertyList"] =
                      controller.getShopPropertyList();
                  childProduct["num"] = controller.productNum;
                  List data = [childProduct];
                  Future.delayed(const Duration(milliseconds: 300), () {
                    push(const MallOrderConfirmPage(), null,
                        binding: MallOrderConfirmPageBinding(),
                        arguments: {
                          "data": data,
                          "payType": controller.payTypeIdx,
                          // "num": controller.productNum,
                          // "mainData": controller.productDetailData,
                          // "subSelectList": controller
                          //     .subSelects[controller.childProductIdx],
                        });
                  });
                }, fontSize: 15, color: AppColor.themeOrange, height: 45)
              ],
            ),
          ),
        );
      }),
      enableDrag: false,
      isDismissible: true,
    );
  }

  Widget pageImageView() {
    return GetX<ShoppingProductDetailController>(
      builder: (_) {
        Map data =
            controller.childProductIdx <= controller.childProducts.length - 1
                ? controller.childProducts[controller.childProductIdx]
                : {};

        List shopImgList = (data["shopImgList"] ?? "").split(",");
        shopImgList = shopImgList.where((e) => e.isNotEmpty).toList();
        if (shopImgList.isEmpty &&
            data["shopImg"] != null &&
            data["shopImg"].isNotEmpty) {
          shopImgList.add(data["shopImg"]);
        }
        return Container(
            width: 375.w,
            height: 240.w,
            color: Colors.white,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: controller.imagePageCtrl,
                    itemCount: shopImgList.length,
                    onPageChanged: (value) {
                      controller.imgPageIdx = value;
                    },
                    itemBuilder: (context, index) {
                      return CustomNetworkImage(
                        src: AppDefault().imageUrl + shopImgList[index],
                        width: 375.w,
                        height: 240.w,
                        fit: BoxFit.fill,
                      );
                    },
                  ),
                ),
                Positioned(
                    bottom: 10.w,
                    left: 15.w,
                    right: 15.w,
                    height: 2.w,
                    child: sbRow(
                        List.generate(
                            shopImgList.length,
                            (index) => Container(
                                  width:
                                      (345.w - (shopImgList.length - 1) * 8.w) /
                                          shopImgList.length,
                                  height: 2.w,
                                  color: controller.imgPageIdx >= index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.2),
                                )),
                        width: 345))
              ],
            ));
      },
    );
  }

  Widget selectBtn(String title, bool select) {
    return UnconstrainedBox(
      child: Container(
        height: 24.w,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            color:
                select ? AppColor.themeOrange.withOpacity(0.1) : Colors.white,
            border: Border.all(
                width: select ? 0 : 0.5.w,
                color: select ? Colors.transparent : AppColor.assisText)),
        child: getSimpleText(
            title, 12, select ? AppColor.themeOrange : AppColor.text),
      ),
    );
  }
}
