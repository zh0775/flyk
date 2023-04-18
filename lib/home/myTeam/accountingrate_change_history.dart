import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AccountingRateChangeHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountingRateChangeHistoryController>(
        () => AccountingRateChangeHistoryController());
  }
}

class AccountingRateChangeHistoryController extends GetxController {
  List changeData = [
    {
      "changedate": "2021年09月12日-18:12:27",
      "workdate": "2021年09月12日-18:12:27",
      "changestate": "修改成功",
      "info": [
        {
          "name": "借记卡",
          "change1": "0.515%",
        },
        {
          "name": "扫码1000以上",
          "change1": "0.515%",
          "change2": "3",
        },
        {
          "name": "手机pay",
          "change1": "0.515%",
        },
        {
          "name": "贷记卡",
          "change1": "0.515%",
        },
      ]
    },
    {
      "changedate": "2021年09月12日-18:12:27",
      "workdate": "2021年09月12日-18:12:27",
      "changestate": "修改成功",
      "info": [
        {
          "name": "借记卡",
          "change1": "0.515%",
        },
        {
          "name": "扫码1000以上",
          "change1": "0.515%",
          "change2": "3",
        },
        {
          "name": "手机pay",
          "change1": "0.515%",
        },
        {
          "name": "贷记卡",
          "change1": "0.515%",
        },
      ]
    },
    {
      "changedate": "2021年09月12日-18:12:27",
      "workdate": "2021年09月12日-18:12:27",
      "changestate": "修改成功",
      "info": [
        {
          "name": "借记卡",
          "change1": "0.515%",
        },
        {
          "name": "扫码1000以上",
          "change1": "0.515%",
          "change2": "3",
        },
        {
          "name": "手机pay",
          "change1": "0.515%",
        },
        {
          "name": "贷记卡",
          "change1": "0.515%",
        },
      ]
    },
  ];
}

class AccountingRateChangeHistory
    extends GetView<AccountingRateChangeHistoryController> {
  const AccountingRateChangeHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "修改记录"),
        body: GetBuilder<AccountingRateChangeHistoryController>(
          init: controller,
          initState: (_) {},
          builder: (_) {
            return ListView.builder(
              itemCount: controller.changeData != null
                  ? controller.changeData.length
                  : 0,
              itemBuilder: (context, index) {
                return AccountingRateChangeHistoryCell(
                  index: index,
                  cellData: controller.changeData[index],
                );
              },
            );
          },
        ));
  }

  Widget historyCell(
      int index, Map date, AccountingRateChangeHistoryController ctrl) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: 345.w,
    );
  }
}

class AccountingRateChangeHistoryCell extends StatefulWidget {
  final int? index;
  final Map? cellData;
  const AccountingRateChangeHistoryCell({Key? key, this.index, this.cellData})
      : super(key: key);

  @override
  State<AccountingRateChangeHistoryCell> createState() =>
      _AccountingRateChangeHistoryCellState();
}

class _AccountingRateChangeHistoryCellState
    extends State<AccountingRateChangeHistoryCell> {
  bool isOpen = false;
  double cellHeight = 108;
  double animationHeight = 169;
  final _duration = const Duration(milliseconds: 300);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _duration,

      margin: EdgeInsets.only(top: 15.w),
      width: 345.w,
      // height: cellHeight + (_animation != null ? _animation!.value : 0),
      height: cellHeight + (isOpen ? animationHeight : 0),
      child: Stack(
        children: [
          AnimatedPositioned(
              top: isOpen ? cellHeight : 0,
              left: 0,
              height: animationHeight,
              right: 0,
              duration: _duration,
              child: Container(
                width: 345.w,
                height: animationHeight,
                decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
                child: Column(
                  children: [
                    // ghb(20),
                    ...widget.cellData!["info"].map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: sbCell(
                            getSimpleText(e["name"], 14, AppColor.textGrey2),
                            centRow([
                              e["change1"] != null
                                  ? getSimpleText(
                                      e["change1"], 14, Color(0xFFDD1616),
                                      isBold: true)
                                  : const SizedBox(),
                              e["change2"] != null
                                  ? Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      width: 1.w,
                                      height: 12,
                                      color: AppColor.textGrey2,
                                    )
                                  : const SizedBox(),
                              e["change2"] != null
                                  ? getSimpleText(
                                      e["change2"], 14, Color(0xFFDD1616),
                                      isBold: true)
                                  : const SizedBox(),
                            ])),
                      );
                    }).toList()
                  ],
                ),
              )),
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   height: animationHeight,
          //   child: Container(
          //     width: 345.w,
          //     height: animationHeight,
          //     decoration: const BoxDecoration(
          //         color: Color(0xFFF2F2F2),
          //         borderRadius: BorderRadius.only(
          //             bottomLeft: Radius.circular(5),
          //             bottomRight: Radius.circular(5))),
          //     child: Column(
          //       children: [
          //         // ghb(20),
          //         ...widget.cellData!["info"].map((e) {
          //           return Padding(
          //             padding: const EdgeInsets.only(top: 18),
          //             child: sbCell(
          //                 getSimpleText(e["name"], 14, AppColor.textGrey2),
          //                 centRow([
          //                   e["change1"] != null
          //                       ? getSimpleText(
          //                           e["change1"], 14, Color(0xFFDD1616),
          //                           isBold: true)
          //                       : const SizedBox(),
          //                   e["change2"] != null
          //                       ? Container(
          //                           margin:
          //                               EdgeInsets.symmetric(horizontal: 10.w),
          //                           width: 1.w,
          //                           height: 12,
          //                           color: AppColor.textGrey2,
          //                         )
          //                       : const SizedBox(),
          //                   e["change2"] != null
          //                       ? getSimpleText(
          //                           e["change2"], 14, Color(0xFFDD1616),
          //                           isBold: true)
          //                       : const SizedBox(),
          //                 ])),
          //           );
          //         }).toList()
          //       ],
          //     ),
          //   ),
          // ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: cellHeight,
              child: GestureDetector(
                onTap: () {
                  // _showDropDownItemWidget();
                  setState(() {
                    isOpen = !isOpen;
                  });
                },
                child: Container(
                  width: 345.w,
                  height: cellHeight,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5))),
                  child: Column(
                    children: [
                      ghb(17),
                      gwb(345),
                      sbRow([
                        getSimpleText("修改时间：${widget.cellData!["changedate"]}",
                            15, AppColor.textBlack,
                            isBold: true),
                      ], width: 345 - 17 * 2),
                      ghb(5),
                      sbRow([
                        getSimpleText("生效时间：${widget.cellData!["workdate"]}",
                            15, AppColor.textBlack,
                            isBold: true),
                      ], width: 345 - 17 * 2),
                      ghb(5),
                      sbCell(
                        getSimpleText("修改状态：${widget.cellData!["changestate"]}",
                            15, AppColor.textBlack,
                            isBold: true),
                        AnimatedRotation(
                          duration: _duration,
                          turns: isOpen ? 0.5 : 0,
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 25.w,
                            color: AppColor.textGrey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget sbCell(Widget w1, Widget w2) {
    return sbRow([w1, w2], width: 309);
  }
}
