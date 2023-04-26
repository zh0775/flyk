import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/debitCard/debit_card_add.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class DebitCardInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<DebitCardInfoController>(DebitCardInfoController());
  }
}

class DebitCardInfoController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  List cardColors = [
    {"l": "0xFFFE7E79", "r": "0xFFFA605A"},
    {"l": "0xFF6395FB", "r": "0xFF3C79F7"},
    {"l": "0xFF51DBBF", "r": "0xFF3DCBA7"}
  ];

  List cardList = [];
  // RefreshController pullCtrl = RefreshController();
  // EasyRefreshController pullCtrl = EasyRefreshController(
  // );
  int pageNo = 1;
  int pageSize = 20;
  int count = 0;

  deleteCard(dynamic id) {
    simpleRequest(
      url: Urls.bankDel(id),
      params: {},
      success: (success, json) {
        if (success) {
          ShowToast.normal("解除绑定成功");
          loadData();
        }
      },
      after: () {},
    );
  }

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    isLoading = cardList.isEmpty;
    simpleRequest(
        url: Urls.bankList,
        params: {
          "pageNo": pageNo,
          "pageSize": pageSize,
        },
        success: (success, json) {
          if (success) {
            Map data = json["data"] ?? {};
            count = data["count"] ?? 0;
            List bList = data["data"] ?? [];
            cardList = isLoad ? [...cardList, ...bList] : bList;
            update();
            // isLoad ? pullCtrl.finishLoad() : pullCtrl.finishRefresh();
            // isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          }
        },
        after: () {
          isLoading = false;
        },
        useCache: true);
  }

  @override
  void onInit() {
    Map homeData = AppDefault().homeData;
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    // pullCtrl.dispose();
    super.onClose();
  }
}

// 6222023602034647198
class DebitCardInfo extends GetView<DebitCardInfoController> {
  const DebitCardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        "卡包",
      ),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 52.5.w,
              child: Center(
                  child: sbhRow([
                getSimpleText("银行卡", 18, AppColor.text, isBold: true),
                CustomButton(
                  onPressed: () {
                    push(
                        const DebitCardAdd(
                          isAdd: true,
                        ),
                        context,
                        binding: DebitCardAddBinding());
                  },
                  child: SizedBox(
                    height: 52.5.w,
                    child: Center(
                      child: centRow(
                        [
                          Image.asset(
                            assetsName("mine/wallet/icon_gray_add"),
                            width: 18.w,
                            fit: BoxFit.fitWidth,
                          ),
                          gwb(3),
                          getSimpleText("添加", 14, AppColor.text3),
                        ],
                      ),
                    ),
                  ),
                )
              ], width: 375 - 16 * 2))),
          Positioned.fill(
              top: 52.5.w,
              child: GetBuilder<DebitCardInfoController>(
                builder: (_) {
                  return EasyRefresh(
                    // controller: controller.pullCtrl,
                    onLoad: () => controller.loadData(isLoad: true),
                    onRefresh: () => controller.loadData(),
                    noMoreLoad: controller.count <= controller.cardList.length,
                    child: ListView.builder(
                      itemCount: controller.cardList.length,
                      itemBuilder: (context, index) {
                        return cardCell(index, controller.cardList[index]);
                      },
                    ),
                  );
                },
              )),
          GetBuilder<DebitCardInfoController>(builder: (_) {
            return controller.cardList.isNotEmpty
                ? gemp()
                : Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      color: AppColor.pageBackgroundColor,
                      child: centClm([
                        getSimpleText("您当前没有添加结算卡", 14, AppColor.text3),
                        ghb(15),
                        CustomButton(
                          onPressed: () {
                            push(
                                const DebitCardAdd(
                                  isAdd: true,
                                ),
                                context,
                                binding: DebitCardAddBinding());
                          },
                          child: Container(
                            width: 345.w,
                            height: 45.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColor.theme,
                                borderRadius: BorderRadius.circular(45.w / 2)),
                            child: centRow([
                              Image.asset(
                                assetsName("mine/wallet/icon_white_add"),
                                width: 28.w,
                                fit: BoxFit.fitWidth,
                              ),
                              gwb(5),
                              getSimpleText("添加", 15, Colors.white)
                            ]),
                          ),
                        )
                      ]),
                    ),
                  );
          }),
        ],
      ),
    );
  }

  Widget cardCell(int index, Map data) {
    dynamic colorData =
        controller.cardColors[index % controller.cardColors.length];
    Color lColor = AppColor.theme.withOpacity(0.5);
    Color rColor = AppColor.theme;
    if (colorData is Map && colorData.isNotEmpty) {
      lColor = Color(int.parse(colorData["l"]));
      rColor = Color(int.parse(colorData["r"]));
    } else if (colorData is String &&
        colorData.isNotEmpty &&
        int.tryParse(colorData) != null) {
      int colorInt = int.parse(colorData);
      lColor = Color(colorInt).withOpacity(0.7);
      rColor = Color(colorInt);
    }
    return Slidable(
      key: ValueKey(index),
      endActionPane: ActionPane(
          extentRatio: 0.12,
          motion: const ScrollMotion(),
          children: [
            CustomSlidableAction(
              flex: 1,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              onPressed: (context) {
                controller.deleteCard(data["id"] ?? -1);
              },
              child: Container(
                // margin: EdgeInsets.only(right: 10.w),
                width: 45.w,
                height: 135.w,
                color: const Color(0xFFFB5252),
                child: Center(
                    child: getWidthText("解除绑定", 15, Colors.white, 12, 4)),
              ),
            )
          ]),
      child: Align(
        child: Container(
          margin: EdgeInsets.only(top: index == 0 ? 0 : 15.w),
          width: 345.w,
          height: 135.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              gradient: LinearGradient(
                colors: [lColor, rColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              centClm([
                ghb(16),
                gwb(345),
                sbhRow([
                  getSimpleText(data["bankName"] ?? "", 18, Colors.white,
                      isBold: true),
                  Image.asset(
                    assetsName("mine/wallet/icon_card_ic"),
                    width: 31.w,
                    fit: BoxFit.fitWidth,
                  )
                ], width: 345 - 16.5 * 2)
              ]),
              centClm([
                sbRow([
                  getSimpleText(
                      data["bankAccountNumber"] != null &&
                              data["bankAccountNumber"].length > 4
                          ? "****  ****  ****  ${(data["bankAccountNumber"] as String).substring(data["bankAccountNumber"].length - 4, data["bankAccountNumber"].length)}"
                          : "",
                      24,
                      Colors.white,
                      isBold: true,
                      letterSpacing: 1.5.w)
                ], width: 345 - 25 * 2),
                ghb(25)
              ])
            ],
          ),
        ),
      ),
    );
  }
}
