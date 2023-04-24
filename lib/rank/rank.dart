import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RankBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RankController>(RankController());
  }
}

class RankController extends GetxController {
  PageController pageController = PageController(viewportFraction: 0.36);

  final _isLoading = true.obs;
  set isLoading(v) => _isLoading.value = v;
  bool get isLoading => _isLoading.value;

  final _buttonIdx = 1.obs;
  set buttonIdx(v) {
    if (_buttonIdx.value != v) {
      _buttonIdx.value = v;
      update();
    }
  }

  bool pageAnimation = false;
  pageAnimationTo(int index) {
    pageAnimation = true;
    pageController
        .animateToPage(index,
            duration: const Duration(milliseconds: 200), curve: Curves.linear)
        .then((value) {
      pageAnimation = false;
    });
  }

  int get buttonIdx => _buttonIdx.value;
  List pageDataList = [];
  Map rankData = {};

  loadRankData() {
    simpleRequest(
      url: Urls.userTOPScoreList,
      params: {},
      success: (success, json) {
        if (success) {
          rankData = json["data"] ?? {};
          pageDataList = [];
          if (rankData["tradeData"] != null) {
            pageDataList.add({
              "field": "tradeData",
              "name": "本月交易排行",
              "datas": ((rankData["tradeData"] ?? []) as List).map((e) {
                e["num"] = priceFormat(e["num"], savePoint: 2);
                return e;
              }).toList()
            });
          }
          if (rankData["activData"] != null) {
            pageDataList.add({
              "field": "activData",
              "name": "激活排行",
              "datas": ((rankData["activData"] ?? []) as List).map((e) {
                e["num"] = priceFormat(e["num"], savePoint: 0);
                return e;
              }).toList()
            });
          }
          if (rankData["bounsData"] != null) {
            pageDataList.add({
              "field": "bounsData",
              "name": "累计收益排行",
              "datas": ((rankData["bounsData"] ?? []) as List).map((e) {
                e["num"] = priceFormat(e["num"], savePoint: 2);
                return e;
              }).toList()
            });
          }
          if (rankData["tradeTeamData"] != null) {
            pageDataList.add({
              "field": "tradeTeamData",
              "name": "团队累计交易",
              "datas": rankData["tradeTeamData"] ?? []
            });
          }

          if (pageDataList.isNotEmpty) {
            // pageController.jumpToPage(500);
          }
          update();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  List<DropdownMenuItem<int>> dropItems() {
    return List.generate(pageDataList.length, (index) {
      Map data = pageDataList[index];
      String img = "rank/icon_thismonth";
      switch (data["field"] ?? "") {
        case "tradeData": //本月交易排行
          img = "rank/btn_changetype_grjy";
          break;
        case "activData": //激活排行
          img = "rank/btn_changetype_jh";
          break;
        case "bounsData": //累计收益排行
          img = "rank/btn_changetype_sy";
          break;
        case "tradeTeamData": //团队累计交易
          img = "rank/btn_changetype_tdjy";
          break;
      }
      return DropdownMenuItem<int>(
          value: index,
          child: centClm([
            SizedBox(
              height: (18 + 4 * 2).w,
              child: Align(
                alignment: Alignment.centerLeft,
                child: centRow([
                  gwb(8),
                  Image.asset(
                    assetsName(img),
                    width: 18.w,
                    fit: BoxFit.fitWidth,
                  ),
                  gwb(7),
                  getSimpleText(pageDataList[index]["name"], 14,
                      buttonIdx == index ? AppColor.theme : AppColor.textBlack)
                ]),
              ),
            ),
          ]));
    });
  }

  final _dayMonthIdx = 0.obs;
  int get dayMonthIdx => _dayMonthIdx.value;
  set dayMonthIdx(v) {
    if (_dayMonthIdx.value != v) {
      _dayMonthIdx.value = v;
      dateScrollerCtrl.jumpTo(
          getScrollX(dayMonthIdx == 0, dayMonthIdx == 0 ? dayIdx : monthIdx));
    }
  }

  final _headerWhite = false.obs;
  bool get headerWhite => _headerWhite.value;
  set headerWhite(v) => _headerWhite.value = v;
  final scrollerCtrl = ScrollController();
  scrollerListener() {
    headerWhite = scrollerCtrl.offset < 400 ? true : false;
  }

  final _monthIdx = 0.obs;
  int get monthIdx => _monthIdx.value;
  set monthIdx(v) => _monthIdx.value = v;

  final _dayIdx = 0.obs;
  int get dayIdx => _dayIdx.value;
  set dayIdx(v) => _dayIdx.value = v;

  List monthList = [];
  List dayList = [];

  late ScrollController dateScrollerCtrl;

  double dateSingleWidth = 50;
  dataFormat() {
    DateTime now = DateTime.now();
    dayList = [];
    int dayCount = DateTime(now.year, now.month + 1, 0).day;
    for (var i = 0; i < dayCount; i++) {
      dayList.add(i + 1);
    }
    int monthCount = now.month;
    monthList = [];
    for (var i = 0; i < monthCount; i++) {
      monthList.add(i + 1);
    }
    dayIdx = now.day - 1;
    monthIdx = now.month - 1;
    dateScrollerCtrl = ScrollController(
        initialScrollOffset:
            getScrollX(dayMonthIdx == 0, dayMonthIdx == 0 ? dayIdx : monthIdx));
  }

  double getScrollX(bool isD, int idx) {
    double scrollX = 0.0;
    if (isD) {
      scrollX = idx * dateSingleWidth.w;
    } else {
      scrollX = idx * dateSingleWidth.w;
    }
    return scrollX;
  }

  @override
  void onInit() {
    scrollerCtrl.addListener(scrollerListener);
    dataFormat();
    loadRankData();
    super.onInit();
  }

  @override
  void onClose() {
    dateScrollerCtrl.dispose();
    scrollerCtrl.removeListener(scrollerListener);
    scrollerCtrl.dispose();
    pageController.dispose();
    super.onClose();
  }
}

class Rank extends GetView<RankController> {
  const Rank({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          clipBehavior: Clip.none,
          controller: controller.scrollerCtrl,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              GetX<RankController>(builder: (_) {
                return SliverAppBar(
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  pinned: true,
                  stretch: true,
                  expandedHeight: 253.w - paddingSizeTop(context),
                  snap: false,
                  elevation: 0,
                  centerTitle: true,
                  title: GetBuilder<RankController>(
                    builder: (_) {
                      return getSimpleText(
                          controller.buttonIdx >
                                  controller.pageDataList.length - 1
                              ? ""
                              : controller.pageDataList[controller.buttonIdx]
                                  ["name"],
                          16,
                          Colors.white);
                    },
                  ),
                  backgroundColor:
                      controller.headerWhite ? AppColor.theme : Colors.white,
                  leading: defaultBackButton(context, white: true),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topCenter,
                              image: AssetImage(assetsName("rank/bg_rank")))),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: paddingSizeTop(context) + kToolbarHeight),
                            child: centRow(List.generate(
                                2,
                                (index) => CustomButton(
                                      onPressed: () {
                                        controller.dayMonthIdx = index;
                                      },
                                      child: Container(
                                        width: 51.w,
                                        height: 30.w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: controller.dayMonthIdx ==
                                                    index
                                                ? AppColor.theme
                                                : Colors.white,
                                            border:
                                                controller
                                                            .dayMonthIdx ==
                                                        index
                                                    ? null
                                                    : Border
                                                        .all(
                                                            width: 1.w,
                                                            color: AppColor
                                                                .theme),
                                            borderRadius: BorderRadius
                                                .horizontal(
                                                    left: Radius.circular(
                                                        index == 0 ? 2.w : 0),
                                                    right: Radius.circular(
                                                        index == 1 ? 2.w : 0))),
                                        child: getSimpleText(
                                            index == 0 ? "日榜" : "月榜",
                                            16,
                                            controller.dayMonthIdx == index
                                                ? Colors.white
                                                : AppColor.theme),
                                      ),
                                    ))),
                          )
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    GetBuilder<RankController>(builder: (_) {
                      return DropdownButtonHideUnderline(
                          child: GetX<RankController>(
                        builder: (_) {
                          return DropdownButton2(
                              offset: Offset(-70.w, -5.w),
                              customButton: SizedBox(
                                  width: 71.w,
                                  child: Align(
                                      // alignment: Alignment.centerRight,
                                      child: Row(
                                    children: [
                                      Image.asset(
                                        assetsName("rank/btn_changetype"),
                                        width: 18.w,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      gwb(10),
                                      getSimpleText("切换", 14, Colors.white)
                                    ],
                                  ))),
                              items: controller.dropItems(),
                              value: controller.buttonIdx,
                              // buttonWidth: 70.w,
                              buttonHeight: kToolbarHeight,
                              itemHeight: 30.w,
                              onChanged: (value) {
                                controller.buttonIdx = value;
                              },
                              itemPadding: EdgeInsets.zero,
                              dropdownWidth: 125.w,
                              dropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.w),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0x26333333),
                                        offset: Offset(0, 5.w),
                                        blurRadius: 15.w)
                                  ]));
                        },
                      ));
                    })
                  ],
                );
              })
            ];
          },
          body: GetBuilder<RankController>(builder: (_) {
            return GetX<RankController>(builder: (_) {
              Map pageData =
                  controller.buttonIdx > controller.pageDataList.length - 1
                      ? {}
                      : controller.pageDataList[controller.buttonIdx];
              List listDatas =
                  controller.buttonIdx > controller.pageDataList.length - 1
                      ? []
                      : pageData["datas"] ?? [];
              String headTitle = "绑定机具";
              String type = pageData["field"] ?? "";
              switch (type) {
                case "bounsData":
                  headTitle = "累计收益";

                  break;
                case "tradeData":
                  headTitle = "本月交易";

                  break;
                case "tradeTeamData":
                  headTitle = "累计交易";

                  break;
                case "activData":
                  headTitle = "激活台数";

                  break;
              }
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.w))),
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.only(
                      bottom: 20.w + paddingSizeBottom(context)),
                  itemCount: listDatas.isEmpty ? 2 : 1 + listDatas.length,
                  // physics: physics,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return SizedBox(
                        // color: Colors.amber,
                        width: 375.w,
                        height: 115.w,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 375.w,
                              height: 16.w,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                      child: Image.asset(
                                    assetsName("rank/bg_rank"),
                                    width: 375.w,
                                    height: 16.w,
                                    fit: BoxFit.fitWidth,
                                    alignment: const Alignment(0, 0.4),
                                  )),
                                  Positioned.fill(
                                      child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16.w))),
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 375.w,
                              height: 43.5.w,
                              child: GetX<RankController>(
                                builder: (_) {
                                  List dateList = controller.dayMonthIdx == 0
                                      ? controller.dayList
                                      : controller.monthList;
                                  int dateIdx = controller.dayMonthIdx == 0
                                      ? controller.dayIdx
                                      : controller.monthIdx;
                                  return ListView.builder(
                                    controller: controller.dateScrollerCtrl,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: dateList.length,
                                    itemBuilder: (context, index) {
                                      int date = dateList[index];
                                      return CustomButton(
                                        onPressed: () {
                                          if (controller.dayMonthIdx == 0) {
                                            controller.dayIdx = index;
                                          } else {
                                            controller.monthIdx = index;
                                          }
                                        },
                                        child: SizedBox(
                                          width: 50.w,
                                          height: 43.5.w,
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: centClm([
                                              getSimpleText(
                                                  "$date",
                                                  16,
                                                  controller.dayMonthIdx == 0
                                                      ? dateIdx == index
                                                          ? AppColor.textBlack
                                                          : AppColor.textGrey5
                                                      : dateIdx == index
                                                          ? AppColor.textBlack
                                                          : AppColor.textGrey5,
                                                  isBold:
                                                      controller.dayMonthIdx ==
                                                              0
                                                          ? dateIdx == index
                                                          : dateIdx == index),
                                              ghb(13),
                                              Container(
                                                width: 15.w,
                                                height: 3.w,
                                                decoration: BoxDecoration(
                                                    color: controller
                                                                .dayMonthIdx ==
                                                            0
                                                        ? dateIdx == index
                                                            ? AppColor.theme
                                                            : Colors.transparent
                                                        : dateIdx == index
                                                            ? AppColor.theme
                                                            : Colors
                                                                .transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.5.w)),
                                              )
                                            ]),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            gline(375, 0.5),
                            Container(
                              margin: EdgeInsets.only(top: 14.5.w),
                              width: 345.w,
                              height: 40.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(4.w)),
                              child: Row(children: [
                                gwb(15),
                                getWidthText(
                                    "排名", 12, AppColor.textGrey5, 45, 1),
                                getWidthText(
                                    "用户", 12, AppColor.textGrey5, 150, 1),
                                getWidthText(headTitle, 12, AppColor.textGrey5,
                                    345 - 45 - 150 - 15 - 12, 1,
                                    alignment: Alignment.centerRight),
                                gwb(12)
                              ]),
                            )
                          ],
                        ),
                      );
                    } else if (index == 1 && listDatas.isEmpty) {
                      return CustomListEmptyView(
                          isLoading: controller.isLoading);
                    } else {
                      return cell(index - 1, listDatas[index - 1], pageData);
                    }
                  },
                ),
              );
            });
          })

          // SingleChildScrollView(
          //   child: Column(
          //     children: [
          //       GetBuilder<RankController>(
          //         builder: (controller) {
          //           List list = [];
          //           Map pageData = {};
          //           if (controller.pageDataList.isNotEmpty &&
          //               controller.pageDataList.length > controller.buttonIdx &&
          //               controller.pageDataList[controller.buttonIdx]
          //                       ["datas"] !=
          //                   null &&
          //               controller.pageDataList[controller.buttonIdx]["datas"]
          //                   .isNotEmpty) {
          //             pageData = controller.pageDataList[controller.buttonIdx];
          //             list = pageData["datas"];
          //           }
          //           return controller.pageDataList.isEmpty || list.isEmpty
          //               ? GetX<RankController>(
          //                   builder: (_) {
          //                     return CustomEmptyView(
          //                       isLoading: controller.isLoading,
          //                     );
          //                   },
          //                 )
          //               : Column(
          //                   children: [
          //                     listCell(0, {}, pageData, true),
          //                     ...List.generate(
          //                         list.length,
          //                         (index) => listCell(
          //                             index, list[index], pageData, false)),
          //                   ],
          //                 );
          //         },
          //       ),
          //       ghb(30),
          //     ],
          //   ),
          // )
          ),
    );
  }

  Widget cell(int index, Map data, Map pageData) {
    String rankName = pageData["name"] ?? "";
    bool isCash = rankName.contains("交易") || rankName.contains("收益");
    String num = isCash ? priceFormat(data["num"] ?? "") : "${data["num"]}";
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 7.w : 0),
      // padding: EdgeInsets.only(top: index == 0 ? 26.w : 19.w, bottom: 19.w),
      child: SizedBox(
          width: 375.w,
          height: 60.w,
          child: Row(
            children: [
              SizedBox(
                width: 70.w,
                child: Align(
                    alignment: const Alignment(0.25, 0),
                    child: index > 2
                        ? Container(
                            width: 18.w,
                            height: 18.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: const Color(0xFFF9C529),
                                borderRadius: BorderRadius.circular(9.w)),
                            child:
                                getSimpleText("${index + 1}", 14, Colors.white))
                        : Image.asset(assetsName("rank/icon_text${index + 1}"),
                            width: 22.w, fit: BoxFit.fitWidth)),
              ),
              SizedBox(
                width: 190.w,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.w),
                      child: CustomNetworkImage(
                        src: AppDefault().imageUrl + (data["u_Avatar"] ?? ""),
                        width: 30.w,
                        height: 30.w,
                        fit: BoxFit.cover,
                        errorWidget: Image.asset(
                          assetsName("common/default_head"),
                          width: 30.w,
                          height: 30.w,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    gwb(6),
                    getWidthText(
                        "${data["u_Name"] ?? ""}(${data["u_Mobile"] != null && data["u_Mobile"].isNotEmpty ? "(${data["u_Mobile"] ?? ""})" : ""}",
                        14,
                        AppColor.textBlack,
                        190 - 30 - 6,
                        2,
                        isBold: true)
                  ],
                ),
              ),
              getWidthText(num, 14, AppColor.theme, 345 - 190 - 70, 2,
                  isBold: true, alignment: Alignment.centerRight)
            ],
          )),
    );
  }

  Widget listCell(int index, Map data, Map pageData, bool isHead) {
    String unit = "";
    String headTitle = "绑定机具";
    String type = pageData["field"] ?? "";
    switch (type) {
      case "bounsData":
        headTitle = "累计收益";
        unit = "元";
        break;
      case "tradeData":
        headTitle = "本月交易";
        unit = "元";
        break;
      case "tradeTeamData":
        headTitle = "累计交易";
        unit = "元";
        break;
      case "activData":
        headTitle = "绑定机具";
        unit = "台";
        break;
    }

    Widget mcWidget;
    Color color = const Color(0xFF525C66);
    if (!isHead && index < 3) {
      switch (index) {
        case 0:
          color = const Color(0xFF2E07F0);
          break;
        case 1:
          color = const Color(0xFF027EFA);
          break;
        case 2:
          color = const Color(0xFFFFB300);
          break;
      }

      mcWidget = Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                assetsName("rank/icon_text${index + 1}"),
                height: 26.w,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
        ],
      );

      // Row(
      //   children: [
      //     Image.asset(
      //       assetsName("rank/icon_text${index + 1}"),
      //       height: 22.w,
      //       fit: BoxFit.fitHeight,
      //     ),
      //     Image.asset(
      //       assetsName("rank/icon_jz${index + 1}"),
      //       height: 18.w,
      //       fit: BoxFit.fitHeight,
      //     ),
      //   ],
      // );
    } else {
      mcWidget = getSimpleText(
          isHead ? "名次" : "${index + 1}", 16, const Color(0xFF525C66));
    }

    return Container(
        margin: EdgeInsets.only(top: isHead ? 0 : 6.w),
        width: 345.w,
        height: isHead ? 32.w : 42.w,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFE9EDF5),
                  blurRadius: 25.5.w,
                  offset: Offset(0, 8.5.w))
            ]),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              gwb(16),
              SizedBox(
                width: 55.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: mcWidget,
                ),
              ),
              SizedBox(
                width: 100.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: getSimpleText(
                      isHead ? "用户名" : "${data["u_Name"] ?? ""}", 16, color),
                ),
              ),
              SizedBox(
                width: 158.w,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: getSimpleText(
                      isHead ? headTitle : "${data["num"] ?? 0}$unit",
                      16,
                      color),
                ),
              ),
            ],
          ),
        ));
  }
}
