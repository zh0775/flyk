import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/information/information_detail_cell.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class MyTeamPersonDataController extends GetxController {
  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;
  int personOrTeamIndex = 0;
  // int monthOrDayIndex = 0;

  final _monthOrDayIndex = 0.obs;

  void setMonthOrDayIndex(value) {
    if (value != _monthOrDayIndex.value) {
      _monthOrDayIndex.value = value;
      update();
    }
  }

  get monthOrDayIndex => _monthOrDayIndex.value;

  List activeInfos = [
    {"date": "2021/9", "count": 218},
    {"date": "2021/9", "count": 218},
    {"date": "2021/9", "count": 218},
    {"date": "2021/9", "count": 218},
    {"date": "2021/9", "count": 218},
    {"date": "2021/9", "count": 218},
  ];

  List jyInfos = [
    {
      "date": "2021/9",
      "alljy": 409218,
      "count": 9,
      "djk": 213,
      "jjk": 213,
      "other": 41234
    },
    {
      "date": "2021/9",
      "alljy": 409218,
      "count": 9,
      "djk": 213,
      "jjk": 213,
      "other": 41234
    },
    {
      "date": "2021/9",
      "alljy": 409218,
      "count": 9,
      "djk": 213,
      "jjk": 213,
      "other": 41234
    },
    {
      "date": "2021/9",
      "alljy": 409218,
      "count": 9,
      "djk": 213,
      "jjk": 213,
      "other": 41234
    },
    {
      "date": "2021/9",
      "alljy": 409218,
      "count": 9,
      "djk": 213,
      "jjk": 213,
      "other": 41234
    },
  ];

  @override
  void dispose() {
    super.dispose();
  }
}

class MyTeamPersonData extends StatelessWidget {
  const MyTeamPersonData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "个人数据"),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50.w,
              child: GetBuilder<MyTeamPersonDataController>(
                init: MyTeamPersonDataController(),
                initState: (_) {},
                builder: (ctrl) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        sbRow([
                          centRow([
                            ghb(50),
                            monthOrDayButton(0, ctrl),
                            monthOrDayButton(1, ctrl),
                          ]),
                          CustomButton(
                            onPressed: () {},
                            child: centRow([
                              getSimpleText("筛选", 15, AppColor.textBlack),
                              gwb(5),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 20.w,
                              ),
                            ]),
                          )
                        ], width: 345),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 50,
                child: GetBuilder<MyTeamPersonDataController>(
                  init: MyTeamPersonDataController(),
                  initState: (_) {},
                  builder: (ctrl) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: ctrl.jyInfos != null ? ctrl.jyInfos.length : 0,
                      itemBuilder: (listCtx, listIdx) {
                        return InformationDetailCell(
                          infomationType: 0,
                          infoData: ctrl.jyInfos[listIdx],
                        );
                      },
                    );
                  },
                ))
          ],
        ));
  }

  Widget monthOrDayButton(int idx, MyTeamPersonDataController ctrl) {
    return CustomButton(
      onPressed: () {
        if (idx != ctrl.monthOrDayIndex) {
          ctrl.setMonthOrDayIndex(idx);
        }
      },
      child: Container(
        width: 60.w,
        height: 30,
        decoration: BoxDecoration(
          color: idx == ctrl.monthOrDayIndex
              ? AppDefault().getThemeColor() ?? AppColor.theme
              : Colors.white,
          borderRadius: idx == 0
              ? const BorderRadius.horizontal(left: Radius.circular(4))
              : const BorderRadius.horizontal(right: Radius.circular(4)),
        ),
        child: Center(
          child: getSimpleText(
              "按${idx == 0 ? "月" : "日"}",
              14,
              idx == ctrl.monthOrDayIndex
                  ? Colors.white
                  : AppDefault().getThemeColor() ?? AppColor.theme),
        ),
      ),
    );
  }
}
