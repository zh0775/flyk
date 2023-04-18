import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MineEverydaySigninBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineEverydaySigninController>(MineEverydaySigninController());
  }
}

class MineEverydaySigninController extends GetxController {
  final _jfNum = 0.0.obs;
  double get jfNum => _jfNum.value;
  set jfNum(v) => _jfNum.value = v;

  final _buttonEnable = true.obs;
  bool get buttonEnable => _buttonEnable.value;
  set buttonEnable(v) => _buttonEnable.value = v;

  Map infoData = {};

  String walletName = "";

  bool todaySingin = false;
  List dayDatas = [];

  loadData() {
    simpleRequest(
      url: Urls.userGetSignInInfo,
      params: {},
      success: (success, json) {
        if (success) {
          infoData = json["data"] ?? {};
          List infos = infoData["info"] ?? [];
          for (var e in infos) {
            if (e["day"] != null &&
                e["day"] is int &&
                dayDatas.length > e["day"]) {
              dayDatas[e["day"] - 1]["flag"] = e["flag"] ?? false;
            }
          }
          if (dayDatas.length > (day - 1)) {
            todaySingin = (dayDatas[day - 1]["flag"] ?? 0) == 1;
          }
          update();
        }
      },
      after: () {},
    );
  }

  singInAction() {
    buttonEnable = false;
    simpleRequest(
      url: Urls.userSignUp,
      params: {},
      success: (success, json) {
        if (success) {
          ShowToast.normal("签到成功");
          Get.find<HomeController>().refreshHomeData();
          loadData();
        }
      },
      after: () {
        buttonEnable = true;
      },
    );
  }

  List wekList = ["日", "一", "二", "三", "四", "五", "六"];
  int month = 0;
  int year = 0;
  int day = 0;
  int blank = 0;
  int dayCount = 0;

  Map homeData = {};

  homeDataNotify(arg) {
    dataFormat();
  }

  dataFormat() {
    homeData = AppDefault().homeData;
    if (homeData.isEmpty || homeData["u_Account"].isEmpty) {
      jfNum = 0;
    } else {
      List accounts = homeData["u_Account"] ?? [];
      bool haveWallet = false;
      for (var e in accounts) {
        if (e["a_No"] == 5) {
          haveWallet = true;
          jfNum = e["amout"];
          walletName = e["name"] ?? "";
        }
      }
      if (!haveWallet) {
        jfNum = 0;
      }
    }
  }

  @override
  void onInit() {
    dataFormat();
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    DateTime now = DateTime.now();
    month = now.month;
    year = now.year;
    day = now.day;
    dayCount = DateTime(year, month + 1, 0).day;
    dayDatas = List.generate(
        dayCount,
        (index) => {
              "day": index + 1,
              "flag": 0,
            });
    switch (DateTime(year, month, 1).weekday) {
      case DateTime.monday:
        blank = 1;
        break;
      case DateTime.tuesday:
        blank = 2;
        break;
      case DateTime.wednesday:
        blank = 3;
        break;
      case DateTime.thursday:
        blank = 4;
        break;
      case DateTime.friday:
        blank = 5;
        break;
      case DateTime.saturday:
        blank = 6;
        break;
      case DateTime.sunday:
        blank = 0;
        break;
    }
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onClose();
  }
}

class MineEverydaySignin extends GetView<MineEverydaySigninController> {
  const MineEverydaySignin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "每日签到", color: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            gwb(375),
            ghb(20),
            sbRow([
              centRow([
                getSimpleText(
                    "我的${controller.walletName}", 14, AppColor.textBlack),
                gwb(10),
                GetX<MineEverydaySigninController>(
                  builder: (_) {
                    return getSimpleText(integralFormat(controller.jfNum), 20,
                        AppColor.textBlack,
                        isBold: true);
                  },
                )
              ])
            ], width: 345),
            ghb(20),
            GetBuilder<MineEverydaySigninController>(
              builder: (_) {
                return Container(
                  width: 345.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.w),
                      ),
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFD6134), Color(0xFFFD4134)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)),
                  child: Row(
                    children: List.generate(
                        2,
                        (index) => SizedBox(
                              width: 345.w / 2 - 0.1.w,
                              child: Center(
                                child: centClm([
                                  ghb(10),
                                  getSimpleText(
                                      "${index == 0 ? integralFormat(controller.infoData["totalAmount"] ?? 0) : (controller.infoData["continuousNum"] ?? "")}",
                                      19,
                                      Colors.white,
                                      isBold: true),
                                  ghb(3),
                                  getSimpleText(
                                      index == 0
                                          ? "本月累计${controller.walletName}"
                                          : "本月连续签到",
                                      14,
                                      Colors.white,
                                      isBold: true),
                                  ghb(8),
                                ]),
                              ),
                            )),
                  ),
                );
              },
            ),
            ghb(10),
            Container(
              width: 345.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: Colors.white),
              child: Column(
                children: [
                  ghb(10),
                  SizedBox(
                    height: 34.w,
                    child: Center(
                      child: getSimpleText(
                          DateFormat("yyyy.MM").format(DateTime.now()),
                          19,
                          AppColor.textBlack,
                          isBold: true),
                    ),
                  ),
                  centRow(List.generate(
                    controller.wekList.length,
                    (index) => SizedBox(
                      width: (345 - 15 * 2).w / controller.wekList.length,
                      height: 40.w,
                      child: Center(
                        child: getSimpleText(
                            controller.wekList[index], 15, AppColor.textGrey5,
                            fw: FontWeight.w600),
                      ),
                    ),
                  )),
                  gline(345 - 20 * 2, 0.5),
                  ghb(10),
                  SizedBox(
                    width: (345 - 15 * 2).w,
                    child: GetBuilder<MineEverydaySigninController>(
                      builder: (_) {
                        // List infos = controller.infoData["info"] ?? [];
                        return Wrap(
                          // runSpacing: 5.w,
                          children: [
                            ...List.generate(controller.blank,
                                (index) => dayWidget(-1, {}, blank: true)),
                            ...List.generate(
                                controller.dayCount,
                                (index) => dayWidget(
                                    index, controller.dayDatas[index])),
                          ],
                        );
                      },
                    ),
                  ),
                  ghb(15),
                ],
              ),
            ),
            ghb(20),
            GetBuilder<MineEverydaySigninController>(
              builder: (_) {
                return GetX<MineEverydaySigninController>(
                  builder: (_) {
                    return getSubmitBtn(controller.todaySingin ? "今日已签到" : "签到",
                        () {
                      if (controller.todaySingin) {
                        ShowToast.normal("今日已签到");
                        return;
                      }
                      controller.singInAction();
                    },
                        linearGradient: const LinearGradient(
                            colors: [Color(0xFFFD6134), Color(0xFFFD4134)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight),
                        enable: controller.buttonEnable);
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget dayWidget(int index, Map data, {bool blank = false}) {
    bool today = (controller.day == index + 1);
    bool tadayBefore = data.isNotEmpty && data["flag"] != 0
        ? true
        : controller.day - 1 > index;
    return SizedBox(
      width: (345 - 15 * 2).w / controller.wekList.length,
      child: blank
          ? gemp()
          : Column(
              children: [
                Center(
                    child: Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                      color: blank
                          ? Colors.transparent
                          : (today
                              ? const Color(0xFFFD4134)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(15.w)),
                  child: Center(
                    child: getSimpleText("${index + 1}", 17,
                        today ? Colors.white : AppColor.textBlack),
                  ),
                )),
                SizedBox(
                  height: 15.w,
                  child: data.isEmpty || !tadayBefore
                      ? gemp()
                      : Center(
                          child: data["flag"] == 0
                              ? Icon(
                                  Icons.close_rounded,
                                  color: const Color(0xFFCCCCCC),
                                  size: 15.w,
                                )
                              : Icon(
                                  Icons.done_rounded,
                                  color: const Color(0xFF36FD3B),
                                  size: 15.w,
                                ),
                        ),
                ),
                ghb(5),
              ],
            ),
    );
  }
}
