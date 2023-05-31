import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatisticsFacilitatorDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsFacilitatorDetailController>(
        StatisticsFacilitatorDetailController());
  }
}

class StatisticsFacilitatorDetailController extends GetxController {
  int moneyHistogramIdx = 0;
  int alliesHistogramIdx = 0;

  int moneyHistogramButtonIdx = -1;
  int alliesHistogramButtonIdx = -1;

  final _btnIdx = 0.obs;
  int get btnIdx => _btnIdx.value;
  set btnIdx(v) => _btnIdx.value = v;

  List moneyScales = [0, 5, 10, 15, 20];
  List alliesScales = [0, 5, 10, 15, 20];

  bool isFirst = true;
  Map firstPeopleData = {};
  Map peopleData = {};
  bool isDirectly = true;
  dataInit(bool directly, Map data) {
    if (!isFirst) return;
    isFirst = false;
    isDirectly = directly;
    firstPeopleData = data;
    loadPeopleInfo();
  }

  loadPeopleInfo() {
    simpleRequest(
      url: Urls.userTeamPeopleShow,
      params: {
        "type": isDirectly ? 0 : 1,
        "userId": firstPeopleData["user_ID"] ?? 0,
      },
      success: (success, json) {
        if (success) {
          peopleData = json["data"] ?? {};
          update();
        }
      },
      after: () {},
    );
  }

  @override
  void onInit() {
    // dataForCurrentDate = tData["month"];
    super.onInit();
  }
}

class StatisticsFacilitatorDetail
    extends GetView<StatisticsFacilitatorDetailController> {
  final bool isDirectly;
  final Map teamData;
  const StatisticsFacilitatorDetail(
      {Key? key, this.teamData = const {}, this.isDirectly = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(isDirectly, teamData);

    return Scaffold(
        appBar: getDefaultAppBar(context, "服务商详情",
            systemOverlayStyle: SystemUiOverlayStyle.light,
            white: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(assetsName(
                          "statistics_page/business/service_bg_top")),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter)),
            )),
        // backgroundColor: Colors.white,
        body: Builder(builder: (buildContext) {
          return Stack(children: [
            Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                    assetsName("statistics_page/business/service_bg_top"),
                    width: 375.w,
                    height: 195.w -
                        (Scaffold.of(buildContext).appBarMaxHeight ?? 0),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.bottomCenter)),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60.w + paddingSizeBottom(context),
                child: Container(
                    alignment: Alignment.topCenter,
                    child: getSubmitBtn("联系TA", () {
                      String phone = controller.peopleData["u_Mobile"] ?? "";
                      if (phone.isEmpty) {
                        ShowToast.normal("该服务商未配置电话号码");
                        return;
                      }
                      callPhone(controller.peopleData["u_Mobile"] ?? "");
                    },
                        height: 45,
                        linearGradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColor.gradient1,
                              AppColor.gradient2
                            ])))),
            Positioned.fill(
                bottom: 60.w + paddingSizeBottom(context),
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: GetBuilder<StatisticsFacilitatorDetailController>(
                        builder: (_) {
                      return Column(children: [
                        Container(
                            width: 356.w,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(assetsName(
                                        "statistics_page/business/service_bg_card")))),
                            child: Column(children: [
                              sbhRow([
                                centRow([
                                  SizedBox(
                                      width: 45.w,
                                      height: isDirectly ? 55.w : 45.w,
                                      child: Stack(children: [
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(45.w / 2),
                                            child: CustomNetworkImage(
                                                src: AppDefault().imageUrl +
                                                    (teamData["u_Avatar"] ??
                                                        ""),
                                                width: 45.w,
                                                height: 45.w,
                                                fit: BoxFit.cover,
                                                errorWidget: Image.asset(
                                                    assetsName(
                                                        "common/default_head"),
                                                    width: 45.w,
                                                    height: 45.w,
                                                    fit: BoxFit.fill))),
                                        !isDirectly
                                            ? gemp()
                                            : Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                    width: 43.w,
                                                    height: 18.w,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFFF8D40),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.w)),
                                                    child: getSimpleText("直属",
                                                        12, Colors.white)),
                                              )
                                      ])),
                                  gwb(10),
                                  centClm([
                                    getSimpleText(
                                        controller.peopleData["u_Name"] ?? "",
                                        18,
                                        AppColor.textBlack,
                                        isBold: true),
                                    getSimpleText(
                                        hidePhoneNum(
                                            controller.peopleData["u_Mobile"] ??
                                                ""),
                                        14,
                                        AppColor.textBlack)
                                  ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start)
                                ])
                              ], height: 100, width: 345 - 17.5 * 2),
                              gline(315, 0.5),
                              sbhRow(
                                  List.generate(
                                      2,
                                      (index) => SizedBox(
                                          width: 315.w / 2,
                                          child: centClm([
                                            getSimpleText(
                                                priceFormat(teamData[index == 0
                                                        ? "teamThisMAmount"
                                                        : "teamThisMAmount"] ??
                                                    "0"),
                                                18,
                                                AppColor.textBlack,
                                                isBold: true),
                                            ghb(3),
                                            getSimpleText(
                                                index == 0
                                                    ? "当月交易额(元)"
                                                    : "上月交易额(元)",
                                                12,
                                                AppColor.textGrey),
                                            ghb(15)
                                          ]))),
                                  width: 315,
                                  height: 81.5),
                            ])),
                        ghb(16),
                        SizedBox(
                            width: 345.w,
                            height: 50.w,
                            child: centRow(List.generate(
                                2,
                                (index) => CustomButton(
                                    onPressed: () {
                                      controller.btnIdx = index;
                                    },
                                    child: SizedBox(
                                        width: 345.w / 2,
                                        child: GetX<
                                                StatisticsFacilitatorDetailController>(
                                            builder: (_) {
                                          return sbClm([
                                            ghb(2),
                                            getSimpleText(
                                                index == 0 ? "基本信息" : "团队数据",
                                                16,
                                                controller.btnIdx == index
                                                    ? AppColor.textBlack
                                                    : AppColor.textGrey,
                                                isBold:
                                                    controller.btnIdx == index),
                                            Container(
                                              width: 15.w,
                                              height: 2.w,
                                              decoration: BoxDecoration(
                                                  color:
                                                      controller.btnIdx == index
                                                          ? AppColor.theme
                                                          : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.5.w)),
                                            )
                                          ], height: 50);
                                        })))))),
                        gline(375, 0.5),

                        // sbRow([
                        //   getSimpleText("盟友其他数据（本月）", 17, AppColor.textBlack,
                        //       isBold: true),
                        // ], width: 345),
                        // ghb(24.5),
                        GetX<StatisticsFacilitatorDetailController>(
                            builder: (controller) {
                          return controller.btnIdx == 0
                              ? centClm([
                                  ghb(20),
                                  otherDataCell("伙伴姓名：",
                                      controller.peopleData["u_Name"] ?? ""),
                                  otherDataCell(
                                    "手机号码：",
                                    controller.peopleData["u_Mobile"] ?? "",
                                  ),
                                  otherDataCell(
                                    "实名认证：",
                                    (controller.peopleData["u_Name"] ?? "")
                                            .isEmpty
                                        ? "未认证"
                                        : "已认证",
                                  ),
                                  // otherDataCell("邀请码：", "",
                                  //     rightWidget: CustomButton(
                                  //         onPressed: () {
                                  //           copyClipboard(controller
                                  //                   .peopleData["u_Number"] ??
                                  //               "");
                                  //         },
                                  //         child: centRow([
                                  //           ghb(40),
                                  //           getSimpleText(
                                  //               controller.peopleData[
                                  //                       "u_Number"] ??
                                  //                   "",
                                  //               14,
                                  //               AppColor.textBlack),
                                  //           gwb(9),
                                  //           getSimpleText(
                                  //               "复制", 12, AppColor.theme)
                                  //         ]))),
                                  // otherDataCell(
                                  //   "分润级别",
                                  //   controller.peopleData["ulevelName"] ?? "",
                                  //   // rightWidget: Image.asset(
                                  //   //     assetsName("mine/vip/vip1"),
                                  //   //     width: 52.w,
                                  //   //     height: 21.w,
                                  //   //     fit: BoxFit.fill)
                                  // ),
                                  otherDataCell(
                                    "注册时间：",
                                    controller.peopleData["uPassDate"] ?? "",
                                  ),
                                  isDirectly
                                      ? ghb(0)
                                      : otherDataCell(
                                          "所属团队：",
                                          controller.peopleData["t_Name"] ??
                                              ""),
                                  // otherDataCell(
                                  //     "团长姓名：",
                                  //     controller.peopleData["t_Name"] ??
                                  //         ""),
                                ])
                              : centClm([
                                  ghb(20),
                                  otherDataCell("团队服务商数量(人)",
                                      "${controller.peopleData["团队服务商数量(人)"] ?? 0}",
                                      spaceBetween: true),
                                  otherDataCell("团队商户数量(人)",
                                      "${controller.peopleData["团队商户数量(人)"] ?? 0}",
                                      spaceBetween: true),
                                  otherDataCell("团队总终端数量(个)",
                                      "${controller.peopleData["团队总终端数量(个)"] ?? 0}",
                                      spaceBetween: true),
                                  otherDataCell("团队已激活终端数量(个)",
                                      " ${controller.peopleData["团队已激活终端数量(个)"] ?? 0}",
                                      spaceBetween: true),
                                  otherDataCell("团队未激活终端数量(个)",
                                      "${controller.peopleData["团队未激活终端数量(个)"] ?? 0}",
                                      spaceBetween: true),
                                ]);
                        }),
                        ghb(50),
                      ]);
                    })))
          ]);
        }));
  }

  Widget histogramView(int type) {
    List scales = [];
    if (type == 0) {
      scales = controller.moneyScales;
    } else if (type == 1) {
      scales = controller.alliesScales;
    }
    return Container(
      width: 345.w,
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      decoration: getDefaultWhiteDec(),
      child: Column(
        children: [
          sbRow([
            getSimpleText(type == 0 ? "团队全部交易额(万元)" : "团队新增盟友(人)", 15,
                AppColor.textBlack),
            centRow([
              histogramChangeButton(type, 0),
              histogramChangeButton(type, 1),
            ]),
          ], width: 345 - 18 * 2),
          ghb(40),
          sbRow([
            sbClm(scales.map((e) => moneyScaleView("$e")).toList(),
                crossAxisAlignment: CrossAxisAlignment.start,
                height: 42.0 * controller.moneyScales.length),
            ...getHistogramButtonList(type),
          ], width: 310, crossAxisAlignment: CrossAxisAlignment.end)
        ],
      ),
    );
  }

  List<Widget> getHistogramButtonList(int type) {
    List<Widget> mButtons = [];
    List tmpData = [];
    if (type == 0) {
      tmpData = controller.peopleData["moneyHistory"];
    } else if (type == 1) {
      tmpData = controller.peopleData["peopleHistory"];
    }
    for (var i = 0; i < tmpData.length; i++) {
      mButtons.add(histogramButton(type, i));
    }
    return mButtons;
  }

  // 柱状图 柱状按钮
  Widget histogramButton(int type, int idx) {
    Map data = {};
    bool? isSelected;
    if (type == 0) {
      data = controller.peopleData["moneyHistory"][idx];
      isSelected = (idx == controller.moneyHistogramButtonIdx);
    } else if (type == 1) {
      data = controller.peopleData["peopleHistory"][idx];
      isSelected = (idx == controller.alliesHistogramButtonIdx);
    }
    return Tooltip(
      message: "${data["num"]}${type == 0 ? "万" : "人"}",
      textStyle: TextStyle(color: AppColor.textBlack, fontSize: 12.sp),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(-1, 1),
              blurRadius: 45.0,
              spreadRadius: 0.0,
            )
          ]),
      triggerMode: TooltipTriggerMode.tap,
      verticalOffset: -(8.4 * data["num"] + 20),
      child: CustomButton(
        onPressed: null,
        // onPressed: () {
        //   if (type == 0) {
        //     if (idx != moneyHistogramButtonIdx) {
        //       setState(() {
        //         moneyHistogramButtonIdx = idx;
        //       });
        //     }
        //   } else if (type == 1) {
        //     if (idx != alliesHistogramButtonIdx) {
        //       setState(() {
        //         alliesHistogramButtonIdx = idx;
        //       });
        //     }
        //   }
        // },
        child: Column(
          children: [
            Container(
              width: 20.w,
              height: 8.4 * data["num"],
              decoration: const BoxDecoration(
                  color: Color(0xFFFB4746),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4))),
            ),
            ghb(12),
            getSimpleText(
                data["date"],
                10,
                isSelected!
                    ? const Color(0xFFFB4746)
                    : const Color(0xFFB3B3B3)),
          ],
        ),
      ),
    );
  }

  Widget moneyScaleView(String t) {
    return SizedBox(
      height: 42,
      child: Align(
        alignment: Alignment.topLeft,
        child: getSimpleText(t, 15, const Color(0xFFB3B3B3)),
      ),
    );
  }

  //柱状图 7日/半年切换按钮
  Widget histogramChangeButton(int type, int idx) {
    bool isSelected = false;
    if (type == 0) {
      isSelected = (controller.moneyHistogramIdx == idx);
    } else if (type == 1) {
      isSelected = (controller.alliesHistogramIdx == idx);
    }

    return CustomButton(
        onPressed: () {
          if (type == 0 && idx != controller.moneyHistogramIdx) {
            // setState(() {
            controller.moneyHistogramIdx = idx;
            // });
          } else if (type == 1 && idx != controller.alliesHistogramIdx) {
            // setState(() {
            controller.alliesHistogramIdx = idx;
            // });
          }
        },
        child: Container(
            width: 40.w,
            height: 20,
            decoration: BoxDecoration(
                borderRadius: idx == 0
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4))
                    : const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4)),
                color: !isSelected
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFFFB4746)),
            child: Center(
                child: getSimpleText(idx == 0 ? "7日" : "半年", 12,
                    isSelected ? Colors.white : AppColor.textBlack))));
  }

  Widget otherDataCell(String t1, String t2,
      {double leftWidth = 71.5,
      bool spaceBetween = false,
      Widget? rightWidget}) {
    return sbhRow([
      spaceBetween
          ? getSimpleText(t1, 14, AppColor.textGrey)
          : centRow([
              getWidthText(t1, 14, AppColor.textGrey, leftWidth, 1,
                  textHeight: 1.3),
              rightWidget ??
                  getSimpleText(
                    t2,
                    14,
                    AppColor.textBlack,
                  ),
            ]),

      spaceBetween ? getSimpleText(t2, 14, AppColor.textBlack) : gwb(0),
      // getSimpleText(t1, 15, const Color(0xFF808080)),
      // getSimpleText(t2, 15, AppColor.textBlack, isBold: true),
    ], width: 375 - 35 * 2, height: 40);
  }

  Widget dataWidget(String? data, String time, String sub) {
    return Container(
      margin: EdgeInsets.only(left: 12.w),
      width: 140.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(
              text: time,
              style: TextStyle(fontSize: 12.sp, color: AppColor.textBlack),
              children: [
                TextSpan(
                    text: sub,
                    style:
                        TextStyle(fontSize: 12.sp, color: AppColor.textGrey)),
              ])),
          ghb(13.5),
          getSimpleText(data ?? "", 20, AppColor.textBlack)
        ],
      ),
    );
  }
}
