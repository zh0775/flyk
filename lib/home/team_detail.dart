import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TeamDetail extends StatefulWidget {
  final bool? isDirectly;
  final Map? teamData;
  const TeamDetail({Key? key, this.teamData, this.isDirectly = true})
      : super(key: key);

  @override
  State<TeamDetail> createState() => _TeamDetailState();
}

class _TeamDetailState extends State<TeamDetail> {
  int moneyHistogramIdx = 0;
  int alliesHistogramIdx = 0;

  int moneyHistogramButtonIdx = -1;
  int alliesHistogramButtonIdx = -1;

  List moneyScales = [0, 5, 10, 15, 20];
  List alliesScales = [0, 5, 10, 15, 20];

  Map tData = {
    "name": "刘涛",
    "registTime": "2021-03-28",
    "phone": "15912346788",
    "yqCode": "Ag38271276",
    "fromTeam": "刘德华",
    "fromTeamPhone": "13756788552",
    "fromTeamYqCode": "Ag00006900",
    "teamPeopleCount": 110,
    "todayTeamPeopleCountChange": -2,
    "month": {
      "money": 610,
      "avg": 321.68,
      "machineCount": 610,
      "activeCount": 321,
    },
    "day": {"money": 61, "avg": 32.68, "machineCount": 61, "activeCount": 32},
    "year": {
      "money": 6100,
      "avg": 3210.68,
      "machineCount": 6100,
      "activeCount": 3210
    },
    "moneyHistory": [
      {
        "date": "03/11",
        "num": 1.2,
      },
      {
        "date": "03/12",
        "num": 4,
      },
      {
        "date": "03/13",
        "num": 9,
      },
      {
        "date": "03/14",
        "num": 12,
      },
      {
        "date": "03/15",
        "num": 3.2,
      },
      {
        "date": "03/16",
        "num": 9.2,
      },
      {
        "date": "03/17",
        "num": 2.9,
      },
    ],
    "peopleHistory": [
      {
        "date": "03/11",
        "num": 1,
      },
      {
        "date": "03/12",
        "num": 4,
      },
      {
        "date": "03/13",
        "num": 9,
      },
      {
        "date": "03/14",
        "num": 12,
      },
      {
        "date": "03/15",
        "num": 3,
      },
      {
        "date": "03/16",
        "num": 9,
      },
      {
        "date": "03/17",
        "num": 3,
      },
    ],
  };
  Map? dataForCurrentDate;

  @override
  void initState() {
    dataForCurrentDate = tData["month"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: getSimpleText("盟友资料", 18, Colors.white, isBold: true),
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
          // physics: ,
          child: Column(
            children: [
              SizedBox(
                width: 375.w,
                height: widget.isDirectly! ? 167.5 : 258.5,
                child: Stack(
                  children: [
                    Positioned(
                      child: Container(
                        width: 375.w,
                        height: 80,
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
                        top: 24.5,
                        child: Container(
                          width: 345.w,
                          height: widget.isDirectly! ? 142 : 234,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            children: [
                              ghb(35),
                              // row1
                              sbRow(
                                [
                                  Column(
                                    children: [
                                      getSimpleText("${tData["name"]}", 34,
                                          AppColor.textBlack,
                                          isBold: true),
                                      ghb(2),
                                      getSimpleText(
                                          "注册时间：${tData["registTime"]}",
                                          12,
                                          AppColor.textGrey),
                                    ],
                                  ),
                                  gline(1, 44),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomButton(
                                        onPressed: () {
                                          callPhone(tData["phone"]);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            getSimpleText(tData["phone"], 14,
                                                AppColor.textBlack),
                                            gwb(10),
                                            Container(
                                              width: 19.w,
                                              height: 19.w,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.w),
                                                  color:
                                                      const Color(0xFF74DB7B)),
                                              child: Center(
                                                child: Icon(
                                                  Icons.phone,
                                                  size: 14.w,
                                                  color: Colors.white,
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
                                                text: tData["yqCode"],
                                                style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: AppColor.textBlack))
                                          ])),
                                    ],
                                  ),
                                ],
                                width: 345 - 24 * 2,
                                crossAxisAlignment: CrossAxisAlignment.end,
                              ),
                              ghb(widget.isDirectly! ? 0 : 25),
                              // row2
                              widget.isDirectly!
                                  ? const SizedBox()
                                  : sbRow(
                                      [
                                        Column(
                                          children: [
                                            getSimpleText(
                                                "${tData["fromTeam"]}",
                                                34,
                                                AppColor.textBlack,
                                                isBold: true),
                                            ghb(2),
                                            getSimpleText(
                                                "所属团队", 12, AppColor.textGrey),
                                          ],
                                        ),
                                        gline(1, 44),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomButton(
                                              onPressed: () {
                                                callPhone(
                                                    tData["fromTeamPhone"]);
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  getSimpleText(
                                                      tData["fromTeamPhone"],
                                                      14,
                                                      AppColor.textBlack),
                                                  gwb(10),
                                                  Container(
                                                    width: 19.w,
                                                    height: 19.w,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.w),
                                                        color: const Color(
                                                            0xFF74DB7B)),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.phone,
                                                        size: 14.w,
                                                        color: Colors.white,
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
                                                      text: tData[
                                                          "fromTeamYqCode"],
                                                      style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: AppColor
                                                              .textBlack))
                                                ])),
                                          ],
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
                        top: 0,
                        left: ((375 - 60) / 2).w,
                        child: Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(30.w)),
                        )),
                  ],
                ),
              ),
              ghb(10),
              sbRow([
                chooesButton(0),
                chooesButton(1),
              ], width: 345),
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
                          "${dataForCurrentDate!["money"]}", "累计", "交易金额(元)"),
                      gline(1, 45),
                      dataWidget(
                          "${dataForCurrentDate!["avg"]}", "台均", "交易金额(元)"),
                    ]),
                    ghb(15),
                    centRow([
                      dataWidget("${dataForCurrentDate!["machineCount"]}", "装机",
                          "总数(台)"),
                      gline(1, 45),
                      dataWidget("${dataForCurrentDate!["activeCount"]}", "激活",
                          "台数(台)"),
                    ]),
                  ],
                ),
              ),
              ghb(20),
              widget.isDirectly!
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
                            Icon(
                              Icons.play_circle_outline,
                              size: 20.w,
                              color: const Color(0xFFDCDCDC),
                            ),
                          ], width: 345 - 18 * 2),
                          ghb(10),
                          sbRow([
                            Text.rich(TextSpan(
                                text: "${tData["teamPeopleCount"]}",
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
                            getSimpleText(
                                "今日新增${tData["todayTeamPeopleCountChange"]}人",
                                13,
                                const Color(0xFF808080))
                          ], width: 345 - 18 * 2),
                        ],
                      ),
                    )
                  : const SizedBox(),
              histogramView(0),
              ghb(20),
              histogramView(1),
              ghb(20),
              sbRow([
                getSimpleText("盟友其他数据（本月）", 17, AppColor.textBlack,
                    isBold: true),
              ], width: 345),
              ghb(24.5),
              otherDataCell("交易额", "321"),
              otherDataCell("交易额", "321"),
              otherDataCell("交易额", "321"),
              otherDataCell("交易额", "321"),
              otherDataCell("交易额", "321"),
            ],
          ),
        ),
      ),
    );
  }

  Widget histogramView(int type) {
    List scales = [];
    if (type == 0) {
      scales = moneyScales;
    } else if (type == 1) {
      scales = alliesScales;
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
                height: 42.0 * moneyScales.length),
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
      tmpData = tData["moneyHistory"];
    } else if (type == 1) {
      tmpData = tData["peopleHistory"];
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
      data = tData["moneyHistory"][idx];
      isSelected = (idx == moneyHistogramButtonIdx);
    } else if (type == 1) {
      data = tData["peopleHistory"][idx];
      isSelected = (idx == alliesHistogramButtonIdx);
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
      isSelected = (moneyHistogramIdx == idx);
    } else if (type == 1) {
      isSelected = (alliesHistogramIdx == idx);
    }

    return CustomButton(
      onPressed: () {
        if (type == 0 && idx != moneyHistogramIdx) {
          setState(() {
            moneyHistogramIdx = idx;
          });
        } else if (type == 1 && idx != alliesHistogramIdx) {
          setState(() {
            alliesHistogramIdx = idx;
          });
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
      margin: EdgeInsets.only(left: 12.sp),
      width: 140.sp,
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
