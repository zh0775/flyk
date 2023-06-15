import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/income/income_page_list.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class IncomePageController extends GetxController {
  final _showValue = true.obs;
  bool get showValue => _showValue.value;
  set showValue(v) => _showValue.value = v;
  List ppList = [];
  @override
  void onInit() {
    selectDate = dateFormat.format(DateTime.now());
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    dataFormat();
    loadReward();
    super.onInit();
  }

  final _selectDate = "".obs;
  String get selectDate => _selectDate.value;
  set selectDate(v) {
    if (_selectDate.value != v) {
      _selectDate.value = v;
      loadReward();
    }
  }

  DateFormat dateFormat = DateFormat("yyyy年MM月");

  Map bounsData = {};
  List boundList = [];
  double tolBouns = 0.0;

  loadReward() {
    DateTime monthDate = dateFormat.parse(selectDate);
    simpleRequest(
        url: Urls.userBounsNameByCount,
        params: {
          "startingTime": DateFormat("yyyy-MM-dd").format(monthDate),
          "end_Time": DateFormat("yyyy-MM-dd")
              .format(DateTime(monthDate.year, monthDate.month + 1, 0))
        },
        success: (success, json) {
          if (success) {
            boundList = json["data"] ?? [];
            tolBouns = 0.0;
            for (var e in boundList) {
              tolBouns += e["amt"] ?? 0.0;
            }

            update();
          }
        },
        after: () {});
  }

  dataFormat() {
    Map homeData = AppDefault().homeData;
    bounsData = (homeData["homeBouns"] ?? {})["bounsData"] ?? {};
    // Map publicHomeData = AppDefault().publicHomeData;
    // boundList = publicHomeData["bounsNameList"] ?? [];
    // tolBouns = 0.0;
    // for (var e in boundList) {
    //   tolBouns += e["tolBounsN"] ?? 0.0;
    // }
  }

  homeDataNotify(arg) {
    dataFormat();
    update();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onClose();
  }
}

class IncomePage extends GetView<IncomePageController> {
  const IncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "收入",
            centerTitle: false,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            needBack: false,
            white: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(assetsName("income/bg_top")),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter)),
            )),
        body: Builder(builder: (context) {
          return Stack(children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                assetsName("income/bg_top"),
                width: 375.w,
                height: 195.w - (Scaffold.of(context).appBarMaxHeight ?? 0),
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Positioned.fill(
                child: EasyRefresh.builder(
              header: const MaterialHeader(),
              onRefresh: () => controller.loadReward(),
              childBuilder: (context, physics) {
                return SingleChildScrollView(
                    physics: physics,
                    child: GetBuilder<IncomePageController>(
                        init: IncomePageController(),
                        builder: (_) {
                          return Column(children: [
                            // 收益视图
                            topValueView(),
                            // 奖励金列表
                            rewardView()
                          ]);
                        }));
              },
            ))
          ]);
        }));
  }

  // 奖励金列表
  Widget rewardView() {
    return Container(
      width: 375.w,
      color: Colors.white,
      margin: EdgeInsets.only(top: 15.w),
      child: Column(
        children: [
          ghb(25),
          sbRow([
            CustomButton(
              onPressed: () {
                showDatePick();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                height: 24.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.w),
                    border:
                        Border.all(width: 0.5.w, color: AppColor.lineColor)),
                alignment: Alignment.center,
                child: centRow([
                  GetX<IncomePageController>(builder: (_) {
                    return getSimpleText(
                        controller.selectDate, 12, AppColor.textBlack);
                  }),
                  gwb(12),
                  Image.asset(
                    assetsName("income/btn_down_arrow"),
                    width: 6.w,
                    fit: BoxFit.fitWidth,
                  )
                ]),
              ),
            ),
          ], width: 345),
          ghb(17),
          ...List.generate(controller.boundList.length, (index) {
            Map data = controller.boundList[index];
            double scale = (data["amt"] ?? 0.0) /
                (controller.tolBouns <= 0 ? 1.0 : controller.tolBouns);
            scale = scale > 1.0 ? 1.0 : scale;
            return CustomButton(
              onPressed: () {
                push(const IncomePageList(), null,
                    binding: IncomePageListBinding(),
                    arguments: {"data": data});
              },
              child: Column(
                children: [
                  ghb(15),
                  sbRow([
                    centRow([
                      Image.asset(
                          assetsName("income/icon_reward${index % 3 + 1}"),
                          width: 45.w,
                          height: 45.w,
                          fit: BoxFit.fill),
                      gwb(10),
                      centClm([
                        sbRow([
                          getRichText(
                              data["tilte"] ?? "",
                              "  ${priceFormat((scale * 100).round(), savePoint: 0)}%",
                              14,
                              AppColor.textBlack,
                              12,
                              AppColor.textGrey5,
                              isBold2: true,
                              isBold: true,
                              h1: 1.0,
                              h2: 1.0),
                          getSimpleText(priceFormat(data["amt"] ?? 0.0), 14,
                              AppColor.textBlack,
                              isBold: true)
                        ], width: 260),
                        ghb(7),
                        Container(
                            width: 260.w,
                            height: 6.w,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.w),
                                color: AppColor.pageBackgroundColor),
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 6.w,
                                width: 260.w * scale,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3.w),
                                    color: AppColor.theme)))
                      ])
                    ]),
                    Image.asset(assetsName("income/cell_arrow"),
                        width: 4.5.w, fit: BoxFit.fitWidth)
                  ], width: 375 - 20 * 2),
                  ghb(14.5),
                  index >= controller.boundList.length - 1
                      ? ghb(0)
                      : sbRow([gwb(0), gline(285, 0.5)], width: 375 - 15 * 2)
                ],
              ),
            );
          }),
          ghb(9)
        ],
      ),
    );
  }

  // 收益视图
  Widget topValueView() {
    return GetBuilder<IncomePageController>(builder: (_) {
      return Container(
        width: 345.w,
        decoration: getDefaultWhiteDec(radius: 8),
        child: GetX<IncomePageController>(builder: (context) {
          return Column(
            children: [
              ghb(18),
              sbRow([
                centClm([
                  centRow([
                    getSimpleText(
                        "累计收入(元)", 12, AppColor.textBlack.withOpacity(0.7)),
                    CustomButton(
                      onPressed: () {
                        controller.showValue = !controller.showValue;
                      },
                      child: SizedBox(
                        width: 50.w,
                        height: 30.w,
                        child: Center(
                          child: Image.asset(
                            assetsName(
                                "income/btn_showvalue_${controller.showValue ? "open" : "close"}"),
                            width: 18.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    )
                  ]),
                  getSimpleText(
                      !controller.showValue
                          ? "****"
                          : priceFormat(
                              controller.bounsData["totalBouns"] ?? 0),
                      28,
                      AppColor.textBlack,
                      isBold: true),
                ], crossAxisAlignment: CrossAxisAlignment.start)
              ], width: 345 - 23 * 2),
              ghb(25),
              sbRow(
                  List.generate(
                      2,
                      (index) => SizedBox(
                            width: (345 - 22 * 2).w / 2,
                            child: centClm([
                              getSimpleText(index == 0 ? "今日收入(元)" : "本月总收入(元)",
                                  12, AppColor.textBlack.withOpacity(0.7)),
                              ghb(5),
                              getSimpleText(
                                  !controller.showValue
                                      ? "****"
                                      : priceFormat(controller.bounsData[
                                              index == 0
                                                  ? "thisDBouns"
                                                  : "thisMBouns"] ??
                                          "0"),
                                  18,
                                  AppColor.textBlack),
                            ], crossAxisAlignment: CrossAxisAlignment.start),
                          )),
                  width: 345 - 22 * 2),
              ghb(20)
            ],
          );
        }),
      );
    });
  }

  showDatePick() async {
    DateTime now = DateTime.now();
    DateTime? selectDate = await showMonthPicker(
        context: Global.navigatorKey.currentContext!,
        // initialEntryMode: DatePickerEntryMode.calendar,
        initialDate: controller.dateFormat.parse(controller.selectDate),
        firstDate: DateTime(now.year - 5, now.month),
        lastDate: DateTime.now(),
        cancelWidget: getSimpleText("取消", 15, AppColor.theme),
        confirmWidget: getSimpleText("确认", 15, AppColor.theme));
    if (selectDate != null) {
      controller.selectDate = controller.dateFormat.format(selectDate);
    }
  }
}
