import 'dart:async';

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/integralstore/integral_store_detail.dart';
import 'package:cxhighversion2/integralstore/integral_store_order_confirm.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class IntegralStoreBuycarBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IntegralStoreBuycarController>(IntegralStoreBuycarController());
  }
}

class IntegralStoreBuycarController extends GetxController {
  TextEditingController cellInput = TextEditingController();
  moveCountInputLastLine() {
    cellInput.selection =
        TextSelection.fromPosition(TextPosition(offset: cellInput.text.length));
  }

  final Map<String, Timer> _funcDebounce = {};
  // 防抖
  void debounce({
    int timeout = 500,
    Function? target,
  }) {
    String key = hashCode.toString();
    Timer? timer = _funcDebounce[key];
    timer?.cancel();
    timer = Timer(Duration(milliseconds: timeout), () {
      Timer? t = _funcDebounce.remove(key);
      t?.cancel();
      target?.call();
    });
    _funcDebounce[key] = timer;
  }

  FocusNode node = FocusNode();
  int inputIndex = -1;

  final _carNum = 0.obs;
  int get carNum => _carNum.value;
  set carNum(v) => _carNum.value = v;

  final _isEdit = false.obs;
  bool get isEdit => _isEdit.value;
  set isEdit(v) => _isEdit.value = v;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _allSelected = false.obs;
  bool get allSelected => _allSelected.value;
  set allSelected(v) => _allSelected.value = v;

  int pageSize = 20;
  int pageNo = 1;
  int count = 0;
  List dataList = [];
  List selectList = [];
  double allPrice = 0.0;

  settleAction() {
    List settleCarList = [];
    for (var e in dataList) {
      if (e["selected"]) {
        settleCarList.add(e);
      }
    }
    if (settleCarList.isEmpty) {
      ShowToast.normal("请添加一件宝贝");
      return;
    }
    push(const IntegralStoreOrderConfirm(), null,
        binding: IntegralStoreOrderConfirmBinding(),
        arguments: {
          "data": settleCarList,
          "isCar": true,
        });
  }

  changeCar(Map data) {
    simpleRequest(
      url: Urls.userModifyCart,
      params: {
        "product_ID": data["carId"],
        "product_Property_List": data["shopPropertyList"] ?? [],
        "num": data["num"],
      },
      success: (success, json) {
        if (success) {
          loadList();
        }
      },
      after: () {},
    );
  }

  deleleCar() {
    List settleCarList = [];
    for (var e in dataList) {
      if (e["selected"]) {
        settleCarList.add(e);
      }
    }
    if (settleCarList.isEmpty) {
      ShowToast.normal("没有宝贝可以删除哦");
      return;
    }
    for (var e in settleCarList) {
      simpleRequest(
        url: Urls.userRemoveFromCart(e["carId"]),
        params: {},
        success: (success, json) {
          if (success) {
            loadList();
            isEdit = false;
          }
        },
        after: () {},
      );
    }
  }

  checkSelect({bool? allSelect}) {
    if (dataList.isEmpty) {
      allSelected = false;
      return;
    }
    bool isAllSelect = true;
    List selectIds = [];

    selectList = [];
    allPrice = 0;
    for (var e in dataList) {
      if (allSelect != null) {
        e["selected"] = allSelect;
        isAllSelect = allSelect;
      } else {
        if (!(e["selected"] ?? false)) {
          isAllSelect = false;
        }
      }
      if (e["selected"]) {
        selectList.add(e);
        allPrice = (e["price"] ?? 0) * (e["num"] ?? 1) * 1.0;
      }

      selectIds.add({
        "id": e["id"],
        "selected": e["selected"] ?? false,
      });
    }

    AppDefault().integralStoreCarSelectIds = selectIds;
    allSelected = isAllSelect;
    update();
  }

  clickCellSelect(Map data) {
    data["selected"] = !data["selected"];
    checkSelect();
    update();
  }

  bool keyborderIsShow = false;
  isShowOrHideKeyborder(bool show) {
    if (Get.currentRoute != "/MachinePayPage") {
      return;
    }
    if (keyborderIsShow != show) {
      keyborderIsShow = show;
      if (!keyborderIsShow) {
        if (int.tryParse(cellInput.text) == null) {
          ShowToast.normal("请输入正确的数量");
          inputIndex = -1;
          update();
          return;
        }
        int count = dataList[inputIndex]["shopStock"] ?? 500;
        if (int.parse(cellInput.text) > count) {
          ShowToast.normal("输入数量超出该商品库存");
          dataList[inputIndex]["num"] = count;
          inputIndex = -1;
          // changeCar(dataList[inputIndex]);
          update();
          return;
        }

        dataList[inputIndex]["num"] = int.parse(cellInput.text);
        // changeCar(dataList[inputIndex]);
        inputIndex = -1;
        update();
      }
    }
  }

  showKeyborder(int index) {
    if (keyborderIsShow) {
      inputIndex = -1;
      update();
      node.nextFocus();
      return;
    }
    inputIndex = index;
    cellInput.text = "${dataList[index]["num"]}";

    update();
    node.requestFocus();
  }

  loadList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }
    List selectIds = AppDefault().integralStoreCarSelectIds;

    simpleRequest(
      url: Urls.userViewCart,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          Map carData = data["carList"] ?? {};
          count = carData["count"] ?? 0;
          List tmpList = carData["data"] ?? [];
          tmpList = tmpList.map((e) {
            bool selected = false;
            for (var e2 in selectIds) {
              if (e["id"] == e2["id"]) {
                selected = e2["selected"] ?? false;

                break;
              }
            }
            return {...e, "selected": selected};
          }).toList();

          dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
          checkSelect();
          update();
        } else {}
      },
      after: () {
        isLoading = false;
      },
    );

    // Future.delayed(const Duration(seconds: 1), () {
    //   count = 30;
    //   List tmpList = List.generate(
    //       pageSize,
    //       (index) => {
    //             "id": isLoad ? dataList.length + index : index,
    //             "name": "商品${dataList.length + index}",
    //             "img": [
    //               "https://img20.360buyimg.com/focus/s140x140_jfs/t13759/194/897734755/2493/1305d4c4/5a1692ebN8ae73077.jpg",
    //               "https://img14.360buyimg.com/focus/s140x140_jfs/t1/91206/20/13565/9379/5e5f262bE45790537/0373287c48fa2317.jpg",
    //               "https://img10.360buyimg.com/focus/s140x140_jfs/t1/95022/3/13977/20829/5e5f2636E20222316/bbc6e2cf5b10669e.jpg",
    //               "https://img10.360buyimg.com/focus/s140x140_jfs/t1/102819/1/13751/13266/5e5f2642Ea72e3802/828ddc1e738c1e07.jpg",
    //             ][index % 4],
    //             "subTitle": "60g 1组",
    //             "maxNum": 15,
    //             "price": [1592, 6380, 698, 1592][index % 4],
    //           });

    //   tmpList = tmpList.map((e) {
    //     bool selected = false;
    //     int num = 1;
    //     for (var e2 in selectIds) {
    //       if (e["id"] == e2["id"]) {
    //         selected = e2["selected"] ?? false;
    //         num = e2["num"] ?? 1;
    //         break;
    //       }
    //     }
    //       return {...e, "selected": selected, "num": num};
    //     }).toList();
    //     checkSelect();
    //     dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
    //     isLoading = false;
    //     update();
    //   });
  }

  noListener() {
    keyborderIsShow = node.hasFocus;
    if (!node.hasFocus) {
      if (int.tryParse(cellInput.text) == null) {
        ShowToast.normal("请输入正确的数量");
        inputIndex = -1;
        update();
        return;
      }
      int count = dataList[inputIndex]["shopStock"] ?? 500;
      if (int.parse(cellInput.text) > count) {
        ShowToast.normal("输入数量超出该商品库存");
        dataList[inputIndex]["num"] = count;
        inputIndex = -1;
        // changeCar(dataList[inputIndex]);
        update();
        return;
      }

      dataList[inputIndex]["num"] = int.parse(cellInput.text);
      // changeCar(dataList[inputIndex]);
      inputIndex = -1;
      update();
    } else {
      moveCountInputLastLine();
    }
  }

  @override
  void onInit() {
    loadList();
    node.addListener(noListener);
    super.onInit();
  }

  @override
  void onClose() {
    node.removeListener(noListener);
    super.onClose();
  }
}

class IntegralStoreBuycar extends StatelessWidget {
  const IntegralStoreBuycar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: AppBar(
          leading: defaultBackButton(context),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          title: GetX<IntegralStoreBuycarController>(
            init: IntegralStoreBuycarController(),
            builder: (controller) {
              return getSimpleText(
                  "购物车 ${controller.carNum < 1 ? "" : "(${controller.carNum})"}",
                  18,
                  AppColor.textBlack,
                  isBold: true);
            },
          ),
          actions: [
            GetX<IntegralStoreBuycarController>(
              init: IntegralStoreBuycarController(),
              initState: (_) {},
              builder: (controller) {
                return CustomButton(
                  onPressed: () {
                    controller.isEdit = !controller.isEdit;
                  },
                  child: SizedBox(
                    height: kTextTabBarHeight,
                    width: 60.w,
                    child: Center(
                      child: getSimpleText(controller.isEdit ? "完成" : "编辑", 14,
                          AppColor.textBlack),
                    ),
                  ),
                );
              },
            )
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
                bottom: 55.w + paddingSizeBottom(context),
                child: GetBuilder<IntegralStoreBuycarController>(
                  init: IntegralStoreBuycarController(),
                  builder: (controller) {
                    return EasyRefresh(
                      onLoad: controller.dataList.length >= controller.count
                          ? null
                          : () => controller.loadList(isLoad: true),
                      onRefresh: () => controller.loadList(),
                      child: controller.dataList.isEmpty
                          ? SingleChildScrollView(
                              child: Center(
                                child: GetX<IntegralStoreBuycarController>(
                                  builder: (_) {
                                    return CustomEmptyView(
                                        // type: CustomEmptyType.carNoData,
                                        isLoading: controller.isLoading,
                                        bottomSpace: 200.w);
                                  },
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: 20.w),
                              itemCount: controller.dataList.length,
                              itemBuilder: (context, index) {
                                return carCell(controller.dataList[index],
                                    index, controller);
                              },
                            ),
                    );
                  },
                )),
            Positioned(
                height: 55.w + paddingSizeBottom(context),
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(color: const Color(0x0D000000), blurRadius: 5.w)
                  ]),
                  child: GetX<IntegralStoreBuycarController>(
                    init: IntegralStoreBuycarController(),
                    builder: (controller) {
                      return Center(
                        child: sbhRow([
                          CustomButton(
                              onPressed: () {
                                controller.checkSelect(
                                    allSelect: !controller.allSelected);
                              },
                              child: SizedBox(
                                  height: 55.w,
                                  child: centRow([
                                    Image.asset(
                                      assetsName(
                                          "integral_store/checkbox_orange_${controller.allSelected ? "selected" : "normal"}"),
                                      width: 16.w,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    gwb(15),
                                    getSimpleText(
                                        controller.allSelected ? "反选" : "全选",
                                        14,
                                        AppColor.textBlack),
                                  ]))),
                          getSubmitBtn(
                            controller.isEdit ? "删除" : "结算",
                            () {
                              if (controller.isEdit) {
                                controller.deleleCar();
                              } else {
                                controller.settleAction();
                              }
                              // controller.popularizeAction();
                            },
                            width: 90,
                            height: 30,
                            fontSize: 14,
                            color: AppColor.theme,
                          ),
                        ], width: 375 - 15 * 2, height: 55),
                      );
                    },
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget carCell(
      Map data, int index, IntegralStoreBuycarController controller) {
    String subType = "";
    List shopPropertyList = data["shopPropertyList"] ?? [];
    if (shopPropertyList.isNotEmpty) {
      int i = 0;
      for (var e in shopPropertyList) {
        subType += "${i == 0 ? "" : " "}${e["value"] ?? ""}";

        i++;
      }
    }
    return Align(
      child: CustomButton(
        onPressed: () {
          controller.clickCellSelect(data);
        },
        child: Container(
          width: 345.w,
          height: 120.w,
          margin: EdgeInsets.only(top: 15.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(3.w)),
          child: Center(
            child: sbhRow([
              centRow([
                SizedBox(
                  height: 90.w,
                  width: 35.w,
                  child: Center(
                    child: Image.asset(
                      assetsName(
                          "integral_store/checkbox_orange_${data["selected"] ? "selected" : "normal"}"),
                      width: 16.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                CustomButton(
                  onPressed: () {
                    push(const IntegralstoreDetail(), null,
                        binding: IntegralstoreDetailBinding(),
                        arguments: {
                          "data": data,
                        });
                  },
                  child: CustomNetworkImage(
                    src: AppDefault().imageUrl + (data["shopImg"] ?? ""),
                    width: 90.w,
                    height: 90.w,
                    fit: BoxFit.fill,
                  ),
                ),
              ]),
              Padding(
                padding: EdgeInsets.only(right: 11.5.w),
                child: sbClm([
                  centClm([
                    getWidthText("${data["shopName"] ?? ""}", 15,
                        AppColor.textBlack, 200, 2,
                        isBold: true),
                    ghb(3),
                    getWidthText("型号：${subType.isEmpty ? "默认" : subType} ", 12,
                        AppColor.textGrey, 180, 1),
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  sbRow([
                    getSimpleText(
                        "${priceFormat(data["nowPrice"] ?? 0, savePoint: 0)}积分",
                        15,
                        const Color(0xFFF93635),
                        isBold: true),
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
                                        child: controller.inputIndex == index
                                            ? CustomInput(
                                                width: 40.w - 1.w,
                                                heigth: 21.w,
                                                textEditCtrl:
                                                    controller.cellInput,
                                                focusNode: controller.node,
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                    fontSize: 15.w,
                                                    color: AppColor.textBlack),
                                                placeholderStyle: TextStyle(
                                                    fontSize: 15.w,
                                                    color: AppColor.textGrey2),
                                              )
                                            : Center(
                                                child: getSimpleText(
                                                    "${data["num"] ?? 1}",
                                                    15,
                                                    AppColor.textBlack),
                                              ),
                                      ),
                                    )
                                  : CustomButton(
                                      onPressed: () {
                                        int num = data["num"] ?? 1;
                                        int count = data["shopStock"] ?? 100;

                                        if (idx == 0) {
                                          if (num > 1) {
                                            data["num"] =
                                                (data["num"] ?? 1) - 1;
                                            controller.update();
                                          }
                                        } else {
                                          if (num < count) {
                                            data["num"] =
                                                (data["num"] ?? 1) + 1;
                                            controller.update();
                                          }
                                        }

                                        if (controller.inputIndex == index) {
                                          controller.cellInput.text =
                                              "${data["num"]}";
                                        }
                                        if (controller.keyborderIsShow) {
                                          controller.moveCountInputLastLine();
                                        }
                                        controller.debounce(
                                            target: () {
                                              controller.changeCar(data);
                                            },
                                            timeout: 1000);
                                      },
                                      child: SizedBox(
                                        width: 25.w - 0.1.w,
                                        height: 25.w,
                                        child: Center(
                                          child: Icon(
                                            idx == 0 ? Icons.remove : Icons.add,
                                            size: 18.w,
                                            color: idx == 0
                                                ? ((data["num"] ?? 1) <= 1
                                                    ? AppColor.textGrey2
                                                    : AppColor.textBlack)
                                                : ((data["num"] ?? 1) >=
                                                        (data["shopStock"] ??
                                                            500)
                                                    ? AppColor.textGrey2
                                                    : AppColor.textBlack),
                                          ),
                                        ),
                                      ),
                                    )),
                        ))
                  ], width: 200),
                ], height: 90, crossAxisAlignment: CrossAxisAlignment.start),
              ),
            ], height: 120 - 15 * 2, width: 345),
          ),
        ),
      ),
    );
  }

  // Widget carCell(int index, Map data, ShoppingCartPageController controller) {
  //   if (data["selected"] == null) {
  //     data["selected"] = false;
  //   }
  //   return CustomButton(
  //     onPressed: () {
  //       controller.clickCellSelect(data);
  //     },
  //     child: Align(
  //       child: Container(
  //         width: 345.w,
  //         height: 120.w,
  //         margin: EdgeInsets.only(top: 15.w),
  //         decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(3.w), color: Colors.white),
  //         child: Center(
  //           child: sbhRow([
  //             centRow([
  //               Image.asset(
  //                 assetsName(
  //                     "business/mall/checkbox_orange_${data["selected"] ? "selected" : "normal"}"),
  //                 width: 16.w,
  //                 fit: BoxFit.fitWidth,
  //               ),
  //               gwb(10),
  //               ClipRRect(
  //                 borderRadius: BorderRadius.circular(4.w),
  //                 child: Container(
  //                   width: 90.w,
  //                   height: 90.w,
  //                   decoration: BoxDecoration(
  //                       color: Colors.transparent,
  //                       borderRadius: BorderRadius.circular(4.w),
  //                       border: Border.all(
  //                           width: 0.5.w, color: AppColor.lineColor)),
  //                   child: Center(
  //                     child: CustomNetworkImage(
  //                       src: (data["img"] ?? ""),
  //                       width: 90.w,
  //                       height: 90.w,
  //                       fit: BoxFit.fill,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               gwb(10),
  //               sbClm([
  //                 centClm([
  //                   getSimpleText(data["name"] ?? "", 15, AppColor.text,
  //                       isBold: true),
  //                   ghb(10),
  //                   // getSimpleText("型号：${data["levelDescribe"] ?? ""}", 12,
  //                   //     AppColor.text3),
  //                 ], crossAxisAlignment: CrossAxisAlignment.start),
  //                 getSimpleText(
  //                     "${priceFormat(data["price"] ?? "", savePoint: 0)}积分",
  //                     15,
  //                     AppColor.red,
  //                     isBold: true),
  //               ], height: 90, crossAxisAlignment: CrossAxisAlignment.start)
  //             ])
  //           ], width: 345 - 9 * 2, height: 120),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
