import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class MachineUnbindHistoryDetailController extends GetxController {
  final isOpen = true.obs;
  List datas = [
    {
      "id": 0,
      "sn": "0000 1102C 831993 79123",
      "ulock": false,
      "selected": false
    },
    {
      "id": 1,
      "sn": "0000 1102C 831993 79124",
      "ulock": false,
      "selected": false
    },
    {
      "id": 2,
      "sn": "0000 1102C 831993 79125",
      "ulock": false,
      "selected": false
    },
    {
      "id": 3,
      "sn": "0000 1102C 831993 79126",
      "ulock": false,
      "selected": false
    },
    {
      "id": 4,
      "sn": "0000 1102C 831993 79127",
      "ulock": false,
      "selected": false
    },
    {
      "id": 5,
      "sn": "0000 1102C 831993 79128",
      "ulock": false,
      "selected": false
    },
    {
      "id": 6,
      "sn": "0000 1102C 831993 79129",
      "ulock": false,
      "selected": false
    },
    {
      "id": 7,
      "sn": "0000 1102C 831993 79130",
      "ulock": false,
      "selected": false
    },
    {
      "id": 8,
      "sn": "0000 1102C 831993 79131",
      "ulock": false,
      "selected": false
    },
    {
      "id": 9,
      "sn": "0000 1102C 831993 79132",
      "ulock": false,
      "selected": false
    },
    {
      "id": 10,
      "sn": "0000 1102C 831993 79133",
      "ulock": false,
      "selected": false
    },
    {
      "id": 11,
      "sn": "0000 1102C 831993 79134",
      "ulock": false,
      "selected": false
    },
    {
      "id": 12,
      "sn": "0000 1102C 831993 79135",
      "ulock": false,
      "selected": false
    },
    {
      "id": 13,
      "sn": "0000 1102C 831993 79136",
      "ulock": false,
      "selected": false
    },
    {
      "id": 14,
      "sn": "0000 1102C 831993 79137",
      "ulock": false,
      "selected": false
    },
    {
      "id": 15,
      "sn": "0000 1102C 831993 79138",
      "ulock": false,
      "selected": false
    },
  ];
}

class MachineUnbindHistoryDetail extends StatelessWidget {
  final Map? detailData;
  const MachineUnbindHistoryDetail({Key? key, this.detailData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "解绑详情"),
      body: Stack(children: [
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 145.5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(width: 0.5, color: AppColor.lineColor))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  sbRow([
                    centRow([
                      getSimpleText("解绑前所属人：", 16, AppColor.textGrey,
                          isBold: true),
                      getSimpleText(
                          "${detailData!["from"]}(${detailData!["phone"]})",
                          16,
                          AppColor.textBlack,
                          isBold: true),
                    ]),
                  ], width: 375 - 15 * 2),
                  ghb(15),
                  sbRow([
                    centRow([
                      getSimpleText("解绑时间：", 16, AppColor.textGrey,
                          isBold: true),
                      getSimpleText(
                          detailData!["datetime"], 16, AppColor.textBlack,
                          isBold: true),
                    ])
                  ], width: 375 - 15 * 2),
                  ghb(15),
                  sbRow([
                    centRow([
                      getSimpleText("解绑台数：", 16, AppColor.textGrey,
                          isBold: true),
                      getSimpleText(
                          "${detailData!["count"]}台", 16, AppColor.textBlack,
                          isBold: true),
                    ]),
                  ], width: 375 - 15 * 2)
                ],
              ),
            )),
        Positioned(
          top: 145.5,
          left: 0,
          right: 0,
          height: 44,
          child: Container(
              color: const Color(0xFFFFF2F3),
              child: GetX<MachineUnbindHistoryDetailController>(
                  init: MachineUnbindHistoryDetailController(),
                  builder: (_) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _.isOpen(!_.isOpen.value);
                      },
                      child: Center(
                        child: sbRow([
                          centRow([
                            getSimpleText("全部：", 14, AppColor.textBlack),
                            // getSimpleText("${_.datas.length}", 14,
                            //     const Color(0xFFEB5757)),
                            // getSimpleText("台", 14, AppColor.textBlack),
                            Text.rich(TextSpan(
                                text: "${_.datas.length}",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFFEB5757)),
                                children: [
                                  TextSpan(
                                      text: "台",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColor.textBlack))
                                ]))
                          ]),
                          AnimatedRotation(
                              duration: const Duration(milliseconds: 300),
                              turns: _.isOpen.value ? 1 : 0.5,
                              child: Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 25.w,
                                color: AppColor.textGrey,
                              ))
                        ], width: 375 - 15.5 * 2),
                      ),
                    );
                  })),
        ),
        GetX<MachineUnbindHistoryDetailController>(
          init: MachineUnbindHistoryDetailController(),
          initState: (_) {},
          builder: (_) {
            return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: 145.5 + 44,
                left: 0,
                right: 0,
                bottom:
                    _.isOpen.value ? 0 : ScreenUtil().screenHeight - 145.5 + 44,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  itemCount: _.datas != null ? _.datas.length : 0,
                  itemBuilder: (context, index) {
                    return Expanded(
                      child: SizedBox(
                        height: 72.w,
                        width: 375.w,
                        child: Column(
                          children: [
                            sbRow([
                              getSimpleText(
                                  "机具编号（SN号）", 14, const Color(0xFF808080)),
                            ], width: 375 - 15.5 * 2),
                            ghb(10),
                            sbRow([
                              centRow([
                                getSimpleText(
                                    (_.datas[index]["sn"] as String).substring(
                                        0, _.datas[index]["sn"].length - 5),
                                    14,
                                    const Color(0xFF808080)),
                                getSimpleText(
                                    (_.datas[index]["sn"] as String).substring(
                                        _.datas[index]["sn"].length - 5,
                                        _.datas[index]["sn"].length),
                                    14,
                                    const Color(0xFFEB5757)),
                              ])
                            ], width: 375 - 15.5 * 2),
                          ],
                        ),
                      ),
                    );
                  },
                ));
          },
        ),
      ]),
    );
  }
}
