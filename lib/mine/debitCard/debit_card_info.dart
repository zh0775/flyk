import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/debitCard/debit_card_add.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool isBindCard = false;
  Map authData = {};
  dataFormat() {
    Map homeData = AppDefault().homeData;
    authData = homeData["authentication"] ?? {};
    isBindCard = authData["isBank"] ?? false;
  }

  homeDataNotify(arg) {
    dataFormat();
    update();
  }

  @override
  void onInit() {
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    dataFormat();
    super.onInit();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onClose();
  }
}

// 6222023602034647198
class DebitCardInfo extends GetView<DebitCardInfoController> {
  const DebitCardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "我的结算卡"),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 52.5.w,
              child: Center(
                  child: sbhRow([
                getSimpleText("结算卡", 18, AppColor.text, isBold: true),
                CustomButton(
                  onPressed: () {
                    push(
                        const DebitCardAdd(
                          isAdd: false,
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
                            assetsName("mine/authentication/icon_change_card"),
                            width: 18.w,
                            fit: BoxFit.fitWidth,
                          ),
                          gwb(3),
                          getSimpleText("更改", 14, AppColor.textBlack),
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
                  return Column(
                    children: [
                      cardCell(0, controller.authData),
                    ],
                  );
                },
              )),
          GetBuilder<DebitCardInfoController>(builder: (_) {
            return controller.isBindCard
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
    return Align(
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
                getSimpleText(data["bank_AccountName"] ?? "", 18, Colors.white,
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
                    data["bank_AccountNumber"] != null &&
                            data["bank_AccountNumber"].length > 4
                        ? "****  ****  ****  ${(data["bank_AccountNumber"] as String).substring(data["bank_AccountNumber"].length - 4, data["bank_AccountNumber"].length)}"
                        : data["bank_AccountNumber"] ?? "",
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
    );
  }
}
