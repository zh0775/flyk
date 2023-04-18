import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class MyTeamDataController extends GetxController {
  final _teamData = {
    "names": [
      {"id": 0, "name": "总业绩"},
      {"id": 1, "name": "张冠"},
      {"id": 2, "name": "李戴"},
      {"id": 3, "name": "赵四"},
      {"id": 4, "name": "刘能"},
      {"id": 5, "name": "张冠"},
      {"id": 6, "name": "赵四"},
      {"id": 6, "name": "刘能"},
      {"id": 8, "name": "赵四"},
      {"id": 0, "name": "刘能"},
      {"id": 0, "name": "李戴"},
      {"id": 0, "name": "李戴"},
      {"id": 0, "name": "张冠"},
      {"id": 0, "name": "李戴"},
      {"id": 0, "name": "赵四"},
      {"id": 0, "name": "刘能"},
      {"id": 0, "name": "张冠"},
      {"id": 0, "name": "赵四"},
      {"id": 0, "name": "刘能"},
      {"id": 0, "name": "赵四"},
      {"id": 0, "name": "刘能"},
      {"id": 0, "name": "李戴"},
      {"id": 0, "name": "李戴"},
    ],
    "month_datas": {
      0: [
        {
          "date": "2022-08",
          "jy": 389821.78,
          "bs": 78,
          "djk": 0,
          "jjk": 0,
          "wx": 0,
          "zfb": 0,
          "qt": 0
        },
        {
          "date": "2022-07",
          "jy": 389821.78,
          "bs": 78,
          "djk": 0,
          "jjk": 0,
          "wx": 0,
          "zfb": 0,
          "qt": 0
        },
        {
          "date": "2022-06",
          "jy": 389821.78,
          "bs": 78,
          "djk": 0,
          "jjk": 0,
          "wx": 0,
          "zfb": 0,
          "qt": 0
        },
        {
          "date": "2022-05",
          "jy": 389821.78,
          "bs": 78,
          "djk": 0,
          "jjk": 0,
          "wx": 0,
          "zfb": 0,
          "qt": 0
        },
        {
          "date": "2022-04",
          "jy": 389821.78,
          "bs": 78,
          "djk": 0,
          "jjk": 0,
          "wx": 0,
          "zfb": 0,
          "qt": 0
        },
      ]
    },
    "day_datas": {
      0: [
        {
          "date": "2022-08-01",
          "jy": 389821.78,
          "bs": 78,
          "djk": 0,
          "jjk": 0,
          "wx": 0,
          "zfb": 0,
          "qt": 0
        },
        {
          "date": "2022-07-31",
          "jy": 389821.78,
          "bs": 78,
          "djk": 0,
          "jjk": 0,
          "wx": 0,
          "zfb": 0,
          "qt": 0
        },
        {
          "date": "2022-07-30",
          "jy": 389821.78,
          "bs": 78,
          "djk": 0,
          "jjk": 0,
          "wx": 0,
          "zfb": 0,
          "qt": 0
        },
      ]
    },
  }.obs;

  set teamData(value) => _teamData.value = value;
  get teamData => _teamData.value;

  final _dateBtnIdx = 0.obs;
  set dateBtnIdx(value) => _dateBtnIdx.value = value;
  get dateBtnIdx => _dateBtnIdx.value;

  final _peopleBtnIdx = 0.obs;
  set peopleBtnIdx(value) => _peopleBtnIdx.value = value;
  get peopleBtnIdx => _peopleBtnIdx.value;

  updateDateBtnIdx(value) => _dateBtnIdx.value = value;
  updateTeamData(value) => _teamData.value = value;
  updatePeopleBtnIdx(value) => _peopleBtnIdx.value = value;
}

class MyTeamData extends StatelessWidget {
  MyTeamData({Key? key}) : super(key: key);

  final MyTeamDataController ctrl = MyTeamDataController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, "盟友数据"),
      body: Stack(children: [
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 50,
            child: Container(
              width: 375.w,
              color: Colors.white,
              child: Align(
                child: sbhRow([
                  GetX<MyTeamDataController>(
                    init: ctrl,
                    builder: (controller) {
                      return centRow([
                        topDateBtn(0, "按月"),
                        topDateBtn(1, "按日"),
                      ]);
                    },
                  ),
                  CustomButton(
                    onPressed: () {},
                    child: centRow([
                      getSimpleText("自定义", 15, AppColor.textBlack),
                      gwb(3),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20.w,
                      )
                    ]),
                  )
                ], width: 375 - 15 * 2, height: 50),
              ),
            )),
        Positioned(
            top: 50,
            left: 0,
            width: 85,
            bottom: 0,
            child: SizedBox(
              width: 85.w,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: ctrl.teamData["names"] != null
                    ? ctrl.teamData["names"].length
                    : 0,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        ctrl.updatePeopleBtnIdx(index);
                      },
                      child: GetX<MyTeamDataController>(
                        init: ctrl,
                        builder: (controller) {
                          return Container(
                            width: 85.w,
                            height: 50,
                            decoration: BoxDecoration(
                                color: index == ctrl.peopleBtnIdx
                                    ? Colors.white
                                    : const Color(0xFFE6E6E6),
                                border: Border(
                                    left: ctrl.peopleBtnIdx == index
                                        ? BorderSide(
                                            width: 3.w,
                                            color: const Color(0xFF5290F2))
                                        : BorderSide.none)),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: getContentText(
                                  ctrl.teamData["names"][index]["name"],
                                  15,
                                  AppColor.textBlack,
                                  85 - 15.5,
                                  50,
                                  1),
                            ),
                          );
                        },
                      ));
                },
              ),
            )),
        Positioned(
            top: 50,
            left: 90,
            right: 0,
            bottom: 0,
            child: GetX<MyTeamDataController>(
              init: ctrl,
              builder: (controller) {
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: ctrl.dateBtnIdx == 0
                      ? ctrl.teamData["month_datas"][0].length
                      : ctrl.teamData["day_datas"][0].length,
                  itemBuilder: (context, index) {
                    return dataCell(ctrl.dateBtnIdx == 0
                        ? ctrl.teamData["month_datas"][0][index]
                        : ctrl.teamData["day_datas"][0][index]);
                  },
                );
              },
            )),
      ]),
    );
  }

  Widget topDateBtn(int idx, String t1) {
    return CustomButton(
      onPressed: () {
        ctrl.updateDateBtnIdx(idx);
      },
      child: Container(
        width: 60.w,
        height: 30,
        decoration: BoxDecoration(
            color: idx == ctrl.dateBtnIdx
                ? const Color(0xFF5290F2)
                : const Color(0xFFF2F2F2),
            borderRadius: idx == 0
                ? const BorderRadius.horizontal(left: Radius.circular(4))
                : const BorderRadius.horizontal(right: Radius.circular(4))),
        child: Center(
          child: getSimpleText(t1, 14,
              idx == ctrl.dateBtnIdx ? Colors.white : AppColor.textBlack),
        ),
      ),
    );
  }

  // {
  //         "date": "2022-05",
  //         "jy": 389821.78,
  //         "bs": 78,
  //         "djk": 0,
  //         "jjk": 0,
  //         "wx": 0,
  //         "zfb": 0,
  //         "qt": 0
  //       },
  Widget dataCell(Map data) {
    double spaceHeight = 15;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ghb(15),
          sbRow([getSimpleText(data["date"], 15, AppColor.textBlack)],
              width: 375 - 90 - 16 * 2),
          ghb(15),
          gline(375 - 90, 0.5),
          ghb(spaceHeight),
          cellDataLine("交易额", "${priceFormat(data["jy"])}元"),
          ghb(spaceHeight),
          cellDataLine("交易笔数", "${data["bs"]}笔"),
          ghb(spaceHeight),
          cellDataLine("贷记卡交易额", "${priceFormat(data["djk"])}元"),
          ghb(spaceHeight),
          cellDataLine("借记卡交易额", "${priceFormat(data["jjk"])}元"),
          ghb(spaceHeight),
          cellDataLine("微信交易额", "${priceFormat(data["wx"])}元"),
          ghb(spaceHeight),
          cellDataLine("支付宝交易额", "${priceFormat(data["zfb"])}元"),
          ghb(spaceHeight),
          cellDataLine("其他类交易额", "${priceFormat(data["qt"])}元"),
          ghb(spaceHeight),
          gline(375 - 90, 0.5),
        ],
      ),
    );
  }

  Widget cellDataLine(String t1, String t2) {
    return sbRow([
      getSimpleText(t1, 13, AppColor.textGrey2),
      getSimpleText(t2, 13, AppColor.textBlack),
    ], width: 375 - 90 - 16 * 2);
  }
}
