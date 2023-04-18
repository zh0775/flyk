import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyTeamPeopleInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyTeamPeopleInfoController>(MyTeamPeopleInfoController());
  }
}

class MyTeamPeopleInfoController extends GetxController {
  int moneyHistogramIdx = 0;
  int alliesHistogramIdx = 0;

  int moneyHistogramButtonIdx = -1;
  int alliesHistogramButtonIdx = -1;

  List moneyScales = [0, 5, 10, 15, 20];
  List alliesScales = [0, 5, 10, 15, 20];

  // Map tData = {
  //   "name": "刘涛",
  //   "registTime": "2021-03-28",
  //   "phone": "15912346788",
  //   "yqCode": "Ag38271276",
  //   "fromTeam": "刘德华",
  //   "fromTeamPhone": "13756788552",
  //   "fromTeamYqCode": "Ag00006900",
  //   "teamPeopleCount": 110,
  //   "todayTeamPeopleCountChange": -2,
  //   "month": {
  //     "money": 610,
  //     "avg": 321.68,
  //     "machineCount": 610,
  //     "activeCount": 321,
  //   },
  //   "day": {"money": 61, "avg": 32.68, "machineCount": 61, "activeCount": 32},
  //   "year": {
  //     "money": 6100,
  //     "avg": 3210.68,
  //     "machineCount": 6100,
  //     "activeCount": 3210
  //   },
  //   "moneyHistory": [
  //     {
  //       "date": "03/11",
  //       "num": 1.2,
  //     },
  //     {
  //       "date": "03/12",
  //       "num": 4,
  //     },
  //     {
  //       "date": "03/13",
  //       "num": 9,
  //     },
  //     {
  //       "date": "03/14",
  //       "num": 12,
  //     },
  //     {
  //       "date": "03/15",
  //       "num": 3.2,
  //     },
  //     {
  //       "date": "03/16",
  //       "num": 9.2,
  //     },
  //     {
  //       "date": "03/17",
  //       "num": 2.9,
  //     },
  //   ],
  //   "peopleHistory": [
  //     {
  //       "date": "03/11",
  //       "num": 1,
  //     },
  //     {
  //       "date": "03/12",
  //       "num": 4,
  //     },
  //     {
  //       "date": "03/13",
  //       "num": 9,
  //     },
  //     {
  //       "date": "03/14",
  //       "num": 12,
  //     },
  //     {
  //       "date": "03/15",
  //       "num": 3,
  //     },
  //     {
  //       "date": "03/16",
  //       "num": 9,
  //     },
  //     {
  //       "date": "03/17",
  //       "num": 3,
  //     },
  //   ],
  // };
  // Map? dataForCurrentDate;
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

class MyTeamPeopleInfo extends GetView<MyTeamPeopleInfoController> {
  final bool isDirectly;
  final Map teamData;
  const MyTeamPeopleInfo(
      {Key? key, this.teamData = const {}, this.isDirectly = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(isDirectly, teamData);
    return Scaffold(
      body: NestedScrollView(
        // physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: getSimpleText("盟友资料", 18, Colors.white, isBold: true),
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft, //右上
                        end: Alignment.centerRight,
                        colors: [
                      Color(0xFF4282EB),
                      Color(0xFF5BA3F7),
                    ])),
              ),
            )
          ];
        },
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: GetBuilder<MyTeamPeopleInfoController>(
              init: controller,
              builder: (_) {
                return Column(
                  children: [
                    SizedBox(
                      width: 375.w,
                      height: isDirectly ? 257.5.w : 166.5.w,
                      // height: 257.5.w,
                      child: Stack(
                        children: [
                          Positioned(
                            child: Container(
                              width: 375.w,
                              height: 100.w,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.centerLeft, //右上
                                      end: Alignment.centerRight,
                                      colors: [
                                    Color(0xFF4282EB),
                                    Color(0xFF5BA3F7),
                                  ])),
                            ),
                          ),
                          Positioned(
                              left: 15.w,
                              top: 44.5.w,
                              child: Container(
                                width: 345.w,
                                // height: isDirectly ? 142.w : 234.w,
                                height: 213.w,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.w)),
                                child: Column(
                                  children: [
                                    ghb(35),
                                    // row1
                                    sbRow(
                                      [
                                        SizedBox(
                                          width: 136.w,
                                          child: Column(
                                            // crossAxisAlignment:
                                            //     CrossAxisAlignment.start,
                                            children: [
                                              getSimpleText(
                                                  "${controller.peopleData["u_Name"] ?? (controller.peopleData["u_Mobile"] != null ? hidePhoneNum(controller.peopleData["u_Mobile"]) : "")}",
                                                  controller.peopleData[
                                                                  "u_Name"] !=
                                                              null &&
                                                          controller
                                                              .peopleData[
                                                                  "u_Name"]
                                                              .isNotEmpty
                                                      ? 34
                                                      : 22,
                                                  AppColor.textBlack,
                                                  isBold: true),
                                              // ghb(2),
                                              // getSimpleText(
                                              //     "注册时间：${controller.peopleData["registTime"] ?? ""}",
                                              //     12,
                                              //     AppColor.textGrey),
                                            ],
                                          ),
                                        ),
                                        gline(1, 44),
                                        SizedBox(
                                          width: 136.w,
                                          child: Column(
                                            // crossAxisAlignment:
                                            //     CrossAxisAlignment.end,
                                            children: [
                                              CustomButton(
                                                onPressed: () {
                                                  if (isDirectly) {
                                                    callPhone(
                                                        controller.peopleData[
                                                                "u_Mobile"] ??
                                                            "");
                                                  }
                                                },
                                                child: centRow(
                                                  [
                                                    getSimpleText(
                                                        hidePhoneNum(controller
                                                                .peopleData[
                                                            "u_Mobile"]),
                                                        14,
                                                        AppColor.textBlack),
                                                    gwb(10),
                                                    !isDirectly
                                                        ? gwb(19)
                                                        : Container(
                                                            width: 19.w,
                                                            height: 19.w,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(5
                                                                            .w),
                                                                color: const Color(
                                                                    0xFF74DB7B)),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.phone,
                                                                size: 14.w,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              ghb(15),
                                              Text.rich(TextSpan(
                                                  text: "邀请码：",
                                                  style: TextStyle(
                                                      color: AppColor.textBlack,
                                                      fontSize: 14.sp),
                                                  children: [
                                                    TextSpan(
                                                        text: controller
                                                                    .peopleData[
                                                                "u_Number"] ??
                                                            "",
                                                        style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: AppColor
                                                                .textBlack))
                                                  ])),
                                            ],
                                          ),
                                        ),
                                      ],
                                      width: 345 - 24 * 2,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                    ),
                                    ghb(isDirectly ? 40 : 0),
                                    // row2
                                    !isDirectly
                                        ? ghb(0)
                                        : sbRow(
                                            [
                                              SizedBox(
                                                width: 136.w,
                                                child: Column(
                                                  children: [
                                                    getSimpleText(
                                                        "${controller.peopleData["t_Name"] ?? ""}",
                                                        34,
                                                        AppColor.textBlack,
                                                        isBold: true),
                                                    ghb(2),
                                                    getSimpleText("所属团队", 12,
                                                        AppColor.textGrey),
                                                  ],
                                                ),
                                              ),
                                              gline(1, 44),
                                              SizedBox(
                                                width: 136.w,
                                                child: Column(
                                                  children: [
                                                    CustomButton(
                                                      onPressed: () {
                                                        if (isDirectly) {
                                                          callPhone(controller
                                                                      .peopleData[
                                                                  "t_Mobile"] ??
                                                              "");
                                                        }
                                                      },
                                                      child: centRow(
                                                        [
                                                          getSimpleText(
                                                              hidePhoneNum(controller
                                                                      .peopleData[
                                                                  "t_Mobile"]),
                                                              14,
                                                              AppColor
                                                                  .textBlack),
                                                          gwb(10),
                                                          !isDirectly
                                                              ? gwb(19)
                                                              : Container(
                                                                  width: 19.w,
                                                                  height: 19.w,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(5
                                                                              .w),
                                                                      color: const Color(
                                                                          0xFF74DB7B)),
                                                                  child: Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .phone,
                                                                      size:
                                                                          14.w,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                    ghb(15),
                                                    Text.rich(TextSpan(
                                                        text: "邀请码：",
                                                        style: TextStyle(
                                                            color: AppColor
                                                                .textBlack,
                                                            fontSize: 14.sp),
                                                        children: [
                                                          TextSpan(
                                                              text: controller
                                                                          .peopleData[
                                                                      "t_Number"] ??
                                                                  "",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  color: AppColor
                                                                      .textBlack))
                                                        ])),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            width: 345 - 24 * 2,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                          ),
                                  ],
                                ),
                              )),
                          Positioned(
                            top: 20.w,
                            left: ((375 - 60) / 2).w,
                            width: 60.w,
                            height: 60.w,
                            child: ClipRRect(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.w),
                                child: controller.peopleData["u_Avatar"] == null
                                    ? Image.asset(
                                        assetsName(
                                            "home/machinetransfer/icon_machine_transfer_defaultpeople"),
                                        width: 60.w,
                                        height: 60.w,
                                        fit: BoxFit.fill,
                                      )
                                    : CustomNetworkImage(
                                        src: AppDefault().imageUrl +
                                            controller.peopleData["u_Avatar"],
                                        width: 60.w,
                                        height: 60.w,
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ghb(10),
                    // sbRow([
                    //   chooesButton(0),
                    //   chooesButton(1),
                    // ], width: 345),
                    ghb(10),
                    Container(
                      width: 345.w,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        children: [
                          centRow([
                            dataWidget(
                                priceFormat(
                                    controller.peopleData["tolTradNum"] ?? 0),
                                "累计",
                                "交易金额(元)"),
                            gline(1, 45),
                            dataWidget(
                                priceFormat(
                                    controller.peopleData["aveNum"] ?? 0),
                                "台均",
                                "交易金额(元)"),
                          ]),
                          ghb(15),
                          centRow([
                            dataWidget(
                                "${controller.peopleData["tolTermiC"] ?? 0}",
                                "装机",
                                "总数(台)"),
                            gline(1, 45),
                            dataWidget(
                                "${controller.peopleData["actTermiC"] ?? 0}",
                                "激活",
                                "台数(台)"),
                          ]),
                        ],
                      ),
                    ),
                    ghb(20),
                    !isDirectly
                        ? Container(
                            width: 345.w,
                            // height: 92,
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: getDefaultWhiteDec(),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Column(
                              children: [
                                sbRow([
                                  getSimpleText("团队盟友", 15, AppColor.textBlack),
                                  // Icon(
                                  //   Icons.play_circle_outline,
                                  //   size: 20.w,
                                  //   color: const Color(0xFFDCDCDC),
                                  // ),
                                ], width: 345 - 18 * 2),
                                ghb(10),
                                sbRow([
                                  Text.rich(TextSpan(
                                      text:
                                          "${controller.peopleData["teamCount"] ?? 0}",
                                      style: TextStyle(
                                          fontSize: 25.sp,
                                          color: AppColor.textBlack,
                                          fontWeight: AppDefault.fontBold),
                                      children: [
                                        TextSpan(
                                            text: "人",
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: AppColor.textBlack))
                                      ])),
                                  // getSimpleText(
                                  //     "今日新增${controller.peopleData["todayTeamPeopleCountChange"]}人",
                                  //     13,
                                  //     const Color(0xFF808080))
                                ], width: 345 - 18 * 2),
                              ],
                            ),
                          )
                        : const SizedBox(),
                    // histogramView(0),
                    // ghb(20),
                    // histogramView(1),
                    // ghb(10),
                    sbRow([
                      getSimpleText("盟友其他数据（本月）", 17, AppColor.textBlack,
                          isBold: true),
                    ], width: 345),
                    ghb(24.5),
                    otherDataCell("月均交易额",
                        "${priceFormat(controller.peopleData["monTxnNum"] ?? 0)}元"),
                    otherDataCell(
                        "月均交易笔数", "${controller.peopleData["monTxnC"] ?? 0}笔"),
                    otherDataCell("考核达标台数",
                        "${controller.peopleData["monActivityTermiC"] ?? 0}台"),
                    otherDataCell("激活率",
                        " ${integralFormat(controller.peopleData["activRate"] ?? 0)}%"),
                    otherDataCell("考核达标率",
                        "${integralFormat(controller.peopleData["activityRate"] ?? 0)}%"),
                    ghb(50),
                  ],
                );
              }),
        ),
      ),
    );
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
                    topLeft: Radius.circular(4), bottomLeft: Radius.circular(4))
                : const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4)),
            color: !isSelected
                ? const Color(0xFFF5F5F5)
                : const Color(0xFFFB4746)),
        child: Center(
            child: getSimpleText(idx == 0 ? "7日" : "半年", 12,
                isSelected ? Colors.white : AppColor.textBlack)),
      ),
    );
  }

  Widget otherDataCell(String t1, String t2) {
    return sbhRow([
      getSimpleText(t1, 15, const Color(0xFF808080)),
      getSimpleText(t2, 15, AppColor.textBlack, isBold: true),
    ], width: 345, height: 33.5);
  }

  Widget chooesButton(int idx) {
    return CustomButton(
      onPressed: () {},
      child: Container(
        padding: EdgeInsets.only(left: 13.w, right: 6.w),
        height: 30,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: centRow([
            getSimpleText(idx == 0 ? "时间" : "产品分类", 14, AppColor.textBlack),
            gwb(3),
            Icon(
              Icons.expand_more,
              color: AppColor.textBlack,
              size: 15.w,
            ),
          ]),
        ),
      ),
    );
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
