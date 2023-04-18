import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/integralRepurchase/integral_project_pay.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IntegralRepurchaseBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IntegralRepurchaseController>(
        IntegralRepurchaseController(datas: Get.arguments));
  }
}

class IntegralRepurchaseController extends GetxController {
  final dynamic datas;
  IntegralRepurchaseController({this.datas});

  // RefreshController pullCtrl = RefreshController();
  EasyRefreshController pullCtrl = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);
  TextEditingController countInputCtrl = TextEditingController();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  loadInfoContent(int type) {
    simpleRequest(
      url: Urls.ruleDescriptionByID(type),
      params: {},
      success: (success, json) {
        if (success) {
          List infos = json["data"] ?? [];
          if (infos.isNotEmpty) {
            if (type == 2) {
              infoContent = infos[0]["content"] ?? "";
            } else {
              infoContentDuixian = infos[0]["content"] ?? "";
            }
          }
        }
      },
      after: () {},
      useCache: true,
    );
  }

  String infoContent = "";
  String infoContentDuixian = "";

  int pageNo = 1;
  int pageSize = 20;
  int count = 0;

  String bottomModelBuildId = "IntegralRepurchase_bottomModelBuildId";

  List dataList = [];
  loadList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.userIntegralProjectList,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
        "classes_ID": isRepurchase ? 1 : 4,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];
          tmpList = List.generate(tmpList.length, (index) {
            Map e = tmpList[index];
            return {
              ...e,
              "num": 1,
            };
          });
          dataList = isLoad ? [...dataList, ...tmpList] : tmpList;

          update();
          isLoad ? pullCtrl.finishLoad() : pullCtrl.finishRefresh();
        } else {
          isLoad
              ? pullCtrl.finishLoad(IndicatorResult.fail)
              : pullCtrl.finishRefresh(IndicatorResult.fail);
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  bool isRepurchase = true;

  moveCountInputLastLine() {
    countInputCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: countInputCtrl.text.length));
  }

  showKeyborder(Map data) {
    if (keyborderIsShow) {
      // inputIndex = -1;
      update();
      // node.nextFocus();
      return;
    }
    // inputIndex = index;
    countInputCtrl.text = data["num"] ?? 1;
    update();
    // node.requestFocus();
  }

  bool keyborderIsShow = false;
  isShowOrHideKeyborder(bool show) {
    if (Get.currentRoute != "/IntegralRepurchase") {
      return;
    }

    if (show) {
      moveCountInputLastLine();
    }
    // if (keyborderIsShow != show) {
    //   keyborderIsShow = show;
    //   if (!keyborderIsShow) {
    //     if (int.tryParse(countInputCtrl.text) == null) {
    //       ShowToast.normal("请输入正确的数量");
    //       update();
    //       return;
    //     }
    //     // int count = dataList[inputIndex]["levelGiftProductCount"] ?? 1;
    //     if (int.parse(countInputCtrl.text) > count) {
    //       // ShowToast.normal("输入数量超出该商品库存");
    //       // dataList[inputIndex]["num"] = count;
    //       // inputIndex = -1;
    //       update();
    //       return;
    //     }

    //     // dataList[inputIndex]["num"] = int.parse(cellInput.text);
    //     // inputIndex = -1;
    //     update();
    //   }
    // }
  }

  @override
  void onInit() {
    if (datas != null) {
      isRepurchase = datas["isRepurchase"] ?? true;
    }
    loadInfoContent(isRepurchase ? 2 : 3);

    loadList();
    super.onInit();
  }

  @override
  void onClose() {
    pullCtrl.dispose();
    countInputCtrl.dispose();
    super.onClose();
  }
}

class IntegralRepurchase extends GetView<IntegralRepurchaseController> {
  const IntegralRepurchase({super.key});

  @override
  Widget build(BuildContext context) {
    bool isKeyboardShowing = MediaQuery.of(context).viewInsets.vertical > 0;
    controller.isShowOrHideKeyborder(isKeyboardShowing);
    return Scaffold(
      appBar: getDefaultAppBar(
          context, controller.isRepurchase ? "积分复购" : "积分兑现",
          action: [
            CustomButton(
              onPressed: () {
                pushInfoContent(
                    content: controller.isRepurchase
                        ? controller.infoContent
                        : controller.infoContentDuixian);
                // push(const ContactAddOrder(), context,
                //     binding: ContactAddOrderBinding());
              },
              child: SizedBox(
                height: kToolbarHeight,
                child: centRow([
                  getSimpleText(controller.isRepurchase ? "复购说明" : "兑现说明", 14,
                      AppColor.text2),
                  gwb(9),
                ]),
              ),
            ),
          ]),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 378.w,
              child: Image.asset(
                assetsName(
                    "home/integralRepurchase/bg_top${controller.isRepurchase ? "" : "2"}"),
                width: 375.w,
                height: 378.w,
                fit: BoxFit.fill,
              )),
          GetBuilder<IntegralRepurchaseController>(
            builder: (_) {
              return controller.dataList.isNotEmpty
                  ? gemp()
                  : Positioned.fill(
                      child: Container(
                      color: AppColor.pageBackgroundColor,
                    ));
            },
          ),
          Positioned.fill(child: GetBuilder<IntegralRepurchaseController>(
            builder: (_) {
              return Center(
                child: EasyRefresh(
                  header: controller.dataList.isEmpty && !kIsWeb
                      ? const CupertinoHeader()
                      : MaterialHeader(color: AppColor.theme),
                  controller: controller.pullCtrl,
                  onLoad: controller.count <= controller.dataList.length
                      ? null
                      : () => controller.loadList(isLoad: true),
                  onRefresh: () => controller.loadList(),
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 20.w),
                    itemCount: controller.dataList.isEmpty
                        ? 1
                        : controller.dataList.length + 1,
                    itemBuilder: (context, index) {
                      if (controller.dataList.isEmpty) {
                        if (index == 0) {
                          // return ghb(318);
                          return GetX<IntegralRepurchaseController>(
                            builder: (_) {
                              return CustomEmptyView(
                                isLoading: controller.isLoading,
                              );
                            },
                          );
                        } else {
                          return GetX<IntegralRepurchaseController>(
                            builder: (_) {
                              return CustomEmptyView(
                                isLoading: controller.isLoading,
                              );
                            },
                          );
                        }
                      } else {
                        if (index == 0) {
                          return ghb(318);
                        } else {
                          return cell(
                              index - 1, controller.dataList[index - 1]);
                        }
                      }
                    },
                  ),
                ),
              );
            },
          ))
        ],
      ),
    );
  }

  Widget cell(int cellIdx, Map data) {
    return Container(
      width: 375.w,
      height: 131.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: cellIdx == 0 ? Radius.circular(15.w) : Radius.zero,
              bottom: cellIdx == controller.dataList.length - 1
                  ? Radius.circular(15.w)
                  : Radius.zero)),
      child: Column(
        children: [
          sbhRow([
            CustomNetworkImage(
              src: AppDefault().imageUrl + (data["images"] ?? ""),
              width: 90.w,
              height: 90.w,
              fit: BoxFit.fill,
            ),
            // Image.asset(
            //   assetsName(
            //       "home/integralRepurchase/icon_jf${controller.isRepurchase ? "" : "2"}"),
            //   width: 90.w,
            //   height: 90.w,
            //   fit: BoxFit.fill,
            // ),
            sbClm([
              centClm([
                getSimpleText(data["title"] ?? "", 15, AppColor.text2),
                ghb(8),
                getSimpleText("${data["buyNum"] ?? 0}人购买", 12, AppColor.text3),
              ], crossAxisAlignment: CrossAxisAlignment.start),
              sbRow([
                Text.rich(TextSpan(
                    text: controller.isRepurchase
                        ? "¥${priceFormat(data["price2"] ?? 0)}"
                        : "${priceFormat(data["price"] ?? 0, savePoint: 0)}积分",
                    style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.3,
                        color: AppColor.red,
                        fontWeight: AppDefault.fontBold),
                    children: [
                      WidgetSpan(child: gwb(controller.isRepurchase ? 6 : 0)),
                      TextSpan(
                          text: controller.isRepurchase
                              ? "¥${data["price1"] ?? 0}"
                              : "",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.textGrey5,
                            decoration: TextDecoration.lineThrough,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationColor: AppColor.textGrey5,
                          ))
                    ])),
                CustomButton(
                  onPressed: () {
                    showBuyBottomModel(data);
                  },
                  child: Container(
                    width: 90.w,
                    height: 30.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColor.theme,
                      borderRadius: BorderRadius.circular(15.w),
                    ),
                    child: getSimpleText(controller.isRepurchase ? "购买" : "兑现",
                        14, Colors.white),
                  ),
                )
              ], width: 241),
            ], height: 95, crossAxisAlignment: CrossAxisAlignment.start),
          ], width: 345, height: 130.5),
          cellIdx < controller.dataList.length - 1 ? gline(345, 0.5) : ghb(0)
        ],
      ),
    );
  }

  showBuyBottomModel(Map data) {
    controller.countInputCtrl.text = "${data["num"] ?? 1}";
    Get.bottomSheet(GestureDetector(
      onTap: () => takeBackKeyboard(Global.navigatorKey.currentContext!),
      child: Container(
          width: 375.w,
          height:
              240.w + paddingSizeBottom(Global.navigatorKey.currentContext!),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.w))),
          child: Column(
            children: [
              gwb(375),
              SizedBox(
                width: 375.w,
                height: 113.w,
                child: centClm([
                  sbhRow([
                    centRow([
                      gwb(16),
                      Image.asset(
                        assetsName(
                            "home/integralRepurchase/icon_jf${controller.isRepurchase ? "" : "2"}"),
                        width: 60.w,
                        height: 60.w,
                        fit: BoxFit.fill,
                      ),
                      gwb(12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getSimpleText(data["title"] ?? "", 15, AppColor.text2,
                              isBold: true),
                          ghb(10),
                          getSimpleText(
                              "${data["buyNum"] ?? 0}人购买", 12, AppColor.text3),
                        ],
                      )
                    ]),
                    CustomButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: SizedBox(
                        width: 44.w,
                        height: 44.w,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            assetsName("common/btn_model_close2"),
                            width: 12.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                      height: 60,
                      width: 375,
                      crossAxisAlignment: CrossAxisAlignment.start),
                  sbRow([
                    GetBuilder<IntegralRepurchaseController>(
                      id: controller.bottomModelBuildId,
                      builder: (_) {
                        return getSimpleText(
                            controller.isRepurchase
                                ? "¥${priceFormat((data["price2"] ?? 0) * (data["num"] ?? 1))}"
                                : "${priceFormat((data["price"] ?? 0) * (data["num"] ?? 1), savePoint: 0)}积分",
                            18,
                            AppColor.red,
                            isBold: true);
                      },
                    )
                  ], width: 375 - 90.5 * 2)
                ]),
              ),
              gline(343, 1),
              sbhRow([
                getSimpleText("数量", 14, AppColor.text2),
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
                                    controller.showKeyborder(data);
                                  },
                                  child: Container(
                                    width: 40.w - 1.w,
                                    height: 21.w,
                                    color: Colors.white,
                                    child: CustomInput(
                                      width: 40.w - 1.w,
                                      heigth: 21.w,
                                      textEditCtrl: controller.countInputCtrl,
                                      // focusNode: controller.node,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      onChange: (str) {
                                        if (controller
                                            .countInputCtrl.text.isEmpty) {
                                          controller.countInputCtrl.text = "1";
                                        }
                                        int? num = int.tryParse(
                                            controller.countInputCtrl.text);
                                        if (num != null) {
                                          data["num"] = num < 1 ? 1 : num;
                                          controller.countInputCtrl.text =
                                              "${data["num"] ?? 1}";
                                        } else {
                                          ShowToast.normal("请输入正确的数量");
                                          controller.countInputCtrl.text =
                                              "${data["num"] ?? 1}";
                                        }
                                        controller.moveCountInputLastLine();
                                        controller.update(
                                            [controller.bottomModelBuildId]);
                                      },
                                      style: TextStyle(
                                          fontSize: 15.w,
                                          color: AppColor.text,
                                          height: 1.3),
                                      placeholderStyle: TextStyle(
                                          fontSize: 15.w,
                                          color: AppColor.assisText,
                                          height: 1.3),
                                    ),
                                  ),
                                )
                              : CustomButton(
                                  onPressed: () {
                                    int num = data["num"] ?? 1;
                                    if (idx == 0) {
                                      if (num > 1) {
                                        data["num"] = (data["num"] ?? 1) - 1;
                                      }
                                    } else {
                                      data["num"] = (data["num"] ?? 1) + 1;
                                    }
                                    controller.countInputCtrl.text =
                                        "${data["num"] ?? 1}";
                                    controller.moveCountInputLastLine();
                                    controller.update(
                                        [controller.bottomModelBuildId]);
                                  },
                                  child: SizedBox(
                                    width: 25.w - 0.1.w,
                                    height: 25.w,
                                    child: Center(
                                      child: GetBuilder<
                                          IntegralRepurchaseController>(
                                        id: controller.bottomModelBuildId,
                                        builder: (_) {
                                          return Icon(
                                            idx == 0 ? Icons.remove : Icons.add,
                                            size: 18.w,
                                            color: idx == 0
                                                ? ((data["num"] ?? 1) <= 1
                                                    ? AppColor.assisText
                                                    : AppColor.textBlack)
                                                : AppColor.textBlack,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )),
                    ))
              ], height: 56, width: 375 - 16 * 2),
              ghb(9),
              getSubmitBtn("立即购买", () {
                Get.back();
                push(const IntegralProjectPay(), null,
                    binding: IntegralProjectPayBinding(),
                    arguments: {
                      "data": data,
                      "isRepurchase": controller.isRepurchase
                    });
              }, color: AppColor.theme, height: 45, fontSize: 15),
            ],
          )),
    ));
  }
}
