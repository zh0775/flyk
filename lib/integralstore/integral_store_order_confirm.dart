// 确认订单

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/integralstore/integral_store_order_pay.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IntegralStoreOrderConfirmBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IntegralStoreOrderConfirmController>(
        IntegralStoreOrderConfirmController(datas: Get.arguments));
  }
}

class IntegralStoreOrderConfirmController extends GetxController {
  final dynamic datas;
  IntegralStoreOrderConfirmController({this.datas});

  final numInputCtrl = TextEditingController();
  final remarkInputCtrl = TextEditingController();
  moveCountInputLastLine() {
    numInputCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: numInputCtrl.text.length));
  }

  final numInputNode = FocusNode();

  final _payTypeIdx = 0.obs;
  int get payTypeIdx => _payTypeIdx.value;
  set payTypeIdx(v) => _payTypeIdx.value = v;

  int inputIndex = -1;

  List productDatas = [];

  final _address = Rx<Map>({});
  Map get address => _address.value;
  set address(v) => _address.value = v;
  List payTypeList = [];

  loadAddress() {
    simpleRequest(
        url: Urls.userContactList,
        params: {},
        success: (success, json) {
          if (success) {
            List aList = json["data"] ?? [];
            if (aList.isNotEmpty) {
              if (aList.length == 1) {
                address = aList[0];
              } else {
                for (var item in aList) {
                  if (item["isDefault"] == 1) {
                    address = item;
                    break;
                  }
                }
              }
              update();
            }
            // if (deliveryType == 0) {
            //   address = addressLocation;
            // }
            // loadPreviewOrder();
          }
        },
        after: () {},
        useCache: true);
  }

  setAddress(Map aData) {
    address = aData;
  }

  // numInputNodeListener() {
  //   if (numInputNode.hasFocus) {
  //     moveCountInputLastLine();
  //   } else {
  //     if (int.tryParse(numInputCtrl.text) == null) {
  //       ShowToast.normal("请输入正确的数量");
  //       numInputCtrl.text = "$productNum";
  //     } else if (int.parse(numInputCtrl.text) >
  //         (productData["shopStock"] ?? 1)) {
  //       numInputCtrl.text = "${(productData["shopStock"] ?? 1)}";
  //       productNum = (productData["shopStock"] ?? 1);
  //       ShowToast.normal("输入的数量大于库存");
  //     } else {
  //       productNum = int.parse(numInputCtrl.text);
  //     }
  //   }
  // }

  bool keyborderIsShow = false;
  showKeyborder(int index) {
    if (keyborderIsShow) {
      inputIndex = -1;
      update();
      numInputNode.nextFocus();
      return;
    }
    inputIndex = index;

    numInputCtrl.text = "${productDatas[index]["num"]}";

    update();
    numInputNode.requestFocus();
  }

  numInputNodeListener() {
    keyborderIsShow = numInputNode.hasFocus;
    if (!numInputNode.hasFocus) {
      if (int.tryParse(numInputCtrl.text) == null) {
        ShowToast.normal("请输入正确的数量");
        inputIndex = -1;
        update();
        return;
      }
      int count = productDatas[inputIndex]["shopStock"] ?? 500;
      if (int.parse(numInputCtrl.text) > count) {
        ShowToast.normal("输入数量超出该商品库存");
        productDatas[inputIndex]["num"] = count;
        inputIndex = -1;
        // changeCar(dataList[inputIndex]);
        update();
        return;
      }

      productDatas[inputIndex]["num"] = int.parse(numInputCtrl.text);
      // changeCar(dataList[inputIndex]);
      inputIndex = -1;
      update();
    } else {
      moveCountInputLastLine();
    }
  }

  List subSelectList = [];
  bool isCar = false;
  @override
  void onInit() {
    loadAddress();
    if (datas != null) {
      isCar = datas["isCar"] ?? false;
      productDatas = datas["data"] ?? {};
      if (!isCar) {
        payTypeIdx = datas["payType"] ?? 0;
      }
      // if (isCar) {
      //   payTypeIdx = 0;
      // } else {
      //   payTypeIdx = datas["payType"] ?? 0;
      // }
      // productNum = datas["num"] ?? 1;
      // productMainData = datas["mainData"] ?? {};
      // subSelectList = datas["subSelectList"] ?? [];
    }
    numInputNode.addListener(numInputNodeListener);
    // numInputCtrl.text = "$productNum";
    super.onInit();
  }

  @override
  void onClose() {
    numInputNode.removeListener(numInputNodeListener);
    super.onClose();
  }
}

class IntegralStoreOrderConfirm
    extends GetView<IntegralStoreOrderConfirmController> {
  const IntegralStoreOrderConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, '确认订单'),
        body: Stack(
          children: [
            Positioned(
                top: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      addressDefaultBox(),
                      shopInfoBox(),
                      !AppDefault().checkDay
                          ? ghb(0)
                          : GetBuilder<IntegralStoreOrderConfirmController>(
                              builder: (controller) {
                                return orderPayMethods();
                              },
                            ),
                      GetBuilder<IntegralStoreOrderConfirmController>(
                        builder: (controller) {
                          return orderTotalBox();
                        },
                      ),
                      getSubmitBtn("确认兑换", () {
                        if (controller.address.isEmpty) {
                          ShowToast.normal("请选择收货地址");
                          return;
                        }
                        push(const IntegralStoreOrderPay(), context,
                            binding: IntegralStoreOrderPayBinding(),
                            arguments: {
                              "data": controller.productDatas,
                              // "mainData": controller.productMainData,
                              "payType": controller.payTypeIdx,
                              // "productNum": controller.productNum,
                              "address": controller.address,
                              "remarks": controller.remarkInputCtrl.text,
                              "isCar": controller.isCar
                              // "subSelectList": controller.subSelectList,
                            });
                      }, color: AppColor.theme, height: 45, fontSize: 15),
                      ghb(30),
                      // orderConfirmButton()
                    ],
                  ),
                )),
            // Positioned(
            //   bottom: 18.w,
            //   child: orderConfirmButton(),
            // )
          ],
        ),
        // body: SingleChildScrollView(
        //   child: Column(
        //     children: [
        //       addressDefaultBox(),
        //       shopInfoBox(),
        //       orderPayMethods(),
        //       orderTotalBox(),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  // 默认地址
  Widget addressDefaultBox() {
    return Container(
      width: 375.w - 15.w * 2,
      margin: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 0),
      padding: EdgeInsets.only(left: 18.5.w, top: 24.w, right: 18.5.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0.w),
            topRight: Radius.circular(8.0.w),
          )),
      child: CustomButton(
        onPressed: () {
          push(
              MineAddressManager(
                getCtrl: controller,
                addressType: AddressType.address,
              ),
              null,
              binding: MineAddressManagerBinding());
        },
        child: GetX<IntegralStoreOrderConfirmController>(builder: (_) {
          return Column(
            children: [
              controller.address.isEmpty
                  ? Center(
                      child: sbRow([
                        getSimpleText("请选择收货地址", 14, AppColor.textGrey2),
                        Image.asset(
                          assetsName("integral_store/arrow_right"),
                          width: 18.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ], width: 315),
                    )
                  : SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  (controller.address["isDefault"] ?? 0) == 1
                                      ? Container(
                                          padding: EdgeInsets.only(
                                              left: 5.w, right: 5.w),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6231),
                                            borderRadius:
                                                BorderRadius.circular(2.w),
                                          ),
                                          child: getSimpleText(
                                              "默认", 12, Colors.white),
                                        )
                                      : gwb(0),
                                  gwb((controller.address["isDefault"] ?? 0) ==
                                          1
                                      ? 10.5
                                      : 0),
                                  getSimpleText(
                                      controller.address["recipient"] ?? "",
                                      15,
                                      const Color(0xFF000000)),
                                  gwb(14.5),
                                  getSimpleText(
                                      controller.address["recipientMobile"] ??
                                          "",
                                      15,
                                      const Color(0xFF000000)),
                                ],
                              ),
                              ghb(15.w),
                              SizedBox(
                                width: 242.w,
                                child: Text(
                                  "${controller.address["provinceName"]}${controller.address["cityName"]}${controller.address["areaName"]}${controller.address["address"]}",
                                  style: TextStyle(
                                      color: const Color(0xFF999999),
                                      fontSize: 12.w,
                                      height: 1.5),
                                ),
                              ),
                            ],
                          ),
                          Image.asset(
                            assetsName("integral_store/arrow_right"),
                            width: 18.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ],
                      ),
                    ),
              ghb(18),
              Image.asset(
                assetsName("common/line2"),
                width: 345.w,
                height: 3.w,
                fit: BoxFit.fill,
              )
            ],
          );
        }),
      ),
    );
  }

  Widget shopInfoBox() {
    return Center(
      child: Container(
        width: 345.w,
        // padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        ),
        margin: EdgeInsets.only(top: 15.w, bottom: 15.5.w),
        child: Column(
          children: [
            GetBuilder<IntegralStoreOrderConfirmController>(builder: (_) {
              return centClm(
                  List.generate(controller.productDatas.length, (index) {
                Map myProduct = controller.productDatas[index];
                return centClm([
                  ghb(controller.productDatas.length > 1 && index != 0
                      ? 0
                      : 15),
                  shopItem(myProduct),
                  ghb(controller.productDatas.length > 1 ? 0 : 25),
                  SizedBox(
                      height: 52.w,
                      child: Center(
                        child: sbRow([
                          getSimpleText('数量', 14, AppColor.textBlack,
                              textHeight: 1.5),
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
                                        ? CustomButton(
                                            onPressed: () {
                                              controller.showKeyborder(index);
                                            },
                                            child: Container(
                                                width: 40.w - 1.w,
                                                height: 21.w,
                                                color: Colors.white,
                                                child: controller.inputIndex ==
                                                        index
                                                    ? CustomInput(
                                                        width: 40.w - 1.w,
                                                        heigth: 21.w,
                                                        textEditCtrl: controller
                                                            .numInputCtrl,
                                                        focusNode: controller
                                                            .numInputNode,
                                                        textAlign:
                                                            TextAlign.center,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        style: TextStyle(
                                                            fontSize: 15.w,
                                                            color: AppColor
                                                                .textBlack),
                                                        placeholderStyle:
                                                            TextStyle(
                                                                fontSize: 15.w,
                                                                color: AppColor
                                                                    .textGrey2),
                                                      )
                                                    : Center(
                                                        child: getSimpleText(
                                                            "${myProduct["num"] ?? 1}",
                                                            15,
                                                            AppColor.textBlack),
                                                      )),
                                          )
                                        : CustomButton(
                                            onPressed: () {
                                              int num = myProduct["num"] ?? 1;
                                              int count =
                                                  (myProduct["shopStock"] ??
                                                      100);

                                              if (idx == 0) {
                                                if (num > 1) {
                                                  myProduct["num"] -= 1;
                                                }
                                              } else {
                                                if (num < count) {
                                                  myProduct["num"] += 1;
                                                }
                                              }
                                              controller.numInputCtrl.text =
                                                  "${myProduct["num"]}";
                                              controller
                                                  .moveCountInputLastLine();
                                              controller.update();
                                            },
                                            child: SizedBox(
                                              width: 25.w - 0.1.w,
                                              height: 25.w,
                                              child: Center(
                                                child: Icon(
                                                  idx == 0
                                                      ? Icons.remove
                                                      : Icons.add,
                                                  size: 18.w,
                                                  color: idx == 0
                                                      ? (myProduct["num"] <= 1
                                                          ? AppColor.textGrey2
                                                          : AppColor.textBlack)
                                                      : (myProduct["num"] >=
                                                              ((myProduct[
                                                                      "shopStock"] ??
                                                                  100))
                                                          ? AppColor.textGrey2
                                                          : AppColor.textBlack),
                                                ),
                                              ),
                                            ),
                                          )),
                              ))
                        ], width: 315),
                      )),
                ]);
              }));
            }),
            gline(345 - 15 * 2, 1),
            SizedBox(
              height: 52.w,
              width: 315.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSimpleText('配送方式', 14, AppColor.textBlack,
                      textHeight: 1.5),
                  getSimpleText('普通快递', 14, AppColor.textBlack,
                      textHeight: 1.5),
                ],
              ),
            ),
            gline(345 - 15 * 2, 1),
            ghb(20),
            SizedBox(
              height: 40.w,
              width: 315.w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSimpleText('选填', 14, AppColor.textBlack, textHeight: 1.5),
                  CustomInput(
                    placeholder: '留言50字以内）',
                    width: 345 - 15 * 2 - 30,
                    heigth: 40,
                    textEditCtrl: controller.remarkInputCtrl,
                    maxLines: 2,
                    maxLength: 50,
                    placeholderStyle: TextStyle(
                        fontSize: 14.sp,
                        color: AppColor.textGrey2,
                        height: 1.3),
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColor.textBlack,
                        height: 1.3),
                  )
                ],
              ),
            ),
            ghb(25),
          ],
        ),
      ),
    );
  }

  // 商品信息
  Widget shopItem(Map myProduct) {
    String selectStr = "";
    List shopPropertys = myProduct["shopPropertyList"] ?? [];

    for (var i = 0; i < shopPropertys.length; i++) {
      String p = shopPropertys[i]["value"] ?? "";
      selectStr += "${i == 0 ? "" : " "}$p";
    }
    selectStr = selectStr.isEmpty ? "默认" : selectStr;

    return SizedBox(
      width: 315.w,
      height: 105.w,
      // padding: EdgeInsets.fromLTRB(10.w, 7.5.w, 10.w, 7.5.w),
      child: sbRow([
        CustomNetworkImage(
          src: AppDefault().imageUrl + (myProduct["shopImg"] ?? ""),
          width: 105.w,
          height: 105.w,
          fit: BoxFit.fitHeight,
        ),
        gwb(15),
        SizedBox(
          width: 345.w - 105.w - 15.w * 2 - 15.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getWidthText(
                  myProduct[controller.isCar ? "shopName" : "shopTitle"] ?? "",
                  15,
                  AppColor.textBlack,
                  345 - 105 - 15 * 2 - 15,
                  2),
              getSimpleText("已选：$selectStr", 12, const Color(0xFF999999)),
              GetX<IntegralStoreOrderConfirmController>(
                builder: (_) {
                  return getSimpleText(
                      controller.payTypeIdx == 0
                          ? "${priceFormat(myProduct["nowPrice"] ?? 0, savePoint: 0)}积分"
                          : "${priceFormat(myProduct["nowPoint"] ?? 0, savePoint: 0)}积分+${priceFormat(myProduct["cashPrice"] ?? 0, savePoint: 2)}现金",
                      15,
                      const Color(0xFF333333));
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // 支付方式
  Widget orderPayMethods() {
    double allPrice = 0;
    double allPoint = 0;
    double allCash = 0;

    for (var e in controller.productDatas) {
      int num = e["num"] ?? 1;
      allPoint += (e["nowPoint"] ?? 0) * num;
      allCash += (e["cashPrice"] ?? 0) * num;
      allPrice += (e["nowPrice"] ?? 0) * num;
    }

    return Container(
        width: 345.w,
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        ),
        margin: EdgeInsets.only(bottom: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getSimpleText("支付方式", 15, const Color(0xFF333333)),
            ghb(16),
            SizedBox(
              width: 345.w,
              child: Wrap(
                spacing: 15.w,
                runSpacing: 10.w,
                children: List.generate(allCash > 0 ? 2 : 1, (index) {
                  return CustomButton(
                    onPressed: () {
                      controller.payTypeIdx = index;
                    },
                    child:
                        GetX<IntegralStoreOrderConfirmController>(builder: (_) {
                      return selectBtn(
                          index == 0
                              ? "${priceFormat(allPrice, savePoint: 0)}积分"
                              : "${priceFormat(allPoint, savePoint: 0)}积分+${priceFormat(allCash, savePoint: 2)}元",
                          // index == 0
                          //     ? "${priceFormat(controller.productData["nowPrice"] ?? 0, savePoint: 0)}积分"
                          //     : "${priceFormat(controller.productData["nowPoint"] ?? 0, savePoint: 0)}积分+${priceFormat(controller.productData["cashPrice"] ?? 2, savePoint: 0)}元",
                          controller.payTypeIdx == index);
                    }),
                  );
                }),
              ),
            ),
          ],
        ));
  }

  // 商品合计Box

  Widget orderTotalBox() {
    double allPrice = 0;
    double allPoint = 0;
    double allCash = 0;
    int allNum = 0;

    for (var e in controller.productDatas) {
      int num = e["num"] ?? 1;
      allNum += num;
      allPoint += (e["nowPoint"] ?? 0) * num;
      allCash += (e["cashPrice"] ?? 0) * num;
      allPrice += (e["nowPrice"] ?? 0) * num;
    }
    return Container(
      width: 345.w,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      margin: EdgeInsets.only(bottom: 16.w),
      child: GetX<IntegralStoreOrderConfirmController>(builder: (_) {
        return Column(
          children: [
            controller.productDatas.length > 1
                ? ghb(0)
                : SizedBox(
                    height: 30.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        getSimpleText('商品单价', 14, const Color(0xFF999999)),
                        gwb(14.5),
                        getSimpleText(
                            controller.payTypeIdx == 0
                                ? "${priceFormat(allPrice, savePoint: 0)}积分"
                                : "${priceFormat(allPoint, savePoint: 0)}积分+${priceFormat(allPrice, savePoint: 2)}元",
                            14,
                            AppColor.textBlack),
                      ],
                    ),
                  ),
            //  6380积分 1 6380积分
            SizedBox(
              height: 30.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSimpleText('商品数量', 14, AppColor.textGrey),
                  gwb(14.5),
                  getSimpleText("$allNum", 14, AppColor.textGrey),
                ],
              ),
            ),
            SizedBox(
              height: 30.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSimpleText('合计', 14, AppColor.textGrey),
                  gwb(14.5),
                  getSimpleText(
                      controller.payTypeIdx == 0
                          ? "${priceFormat(allPrice, savePoint: 0)}积分"
                          : "${priceFormat(allPoint, savePoint: 0)}积分+${priceFormat(allCash, savePoint: 2)}元",
                      15,
                      AppColor.theme),
                ],
              ),
            ),
          ],
        );
      }),
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
            color: select ? AppColor.theme.withOpacity(0.1) : Colors.white,
            border: Border.all(
                width: select ? 0 : 0.5.w,
                color: select ? Colors.transparent : AppColor.textGrey2)),
        child: getSimpleText(
            title, 12, select ? AppColor.theme : AppColor.textBlack),
      ),
    );
  }
}
