import 'package:flutter/material.dart';
import 'package:cxhighversion2/home/myMachine/machine_unbind_history_detail.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class MyMachineUnbindHistoryController extends GetxController {
  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;
  List historyData = [
    {
      "datetime": "2020年09月12日 20:28:91",
      "count": 20,
      "from": "刘德华",
      "phone": "186****7329"
    },
    {
      "datetime": "2020年09月12日 20:28:91",
      "count": 20,
      "from": "刘德华",
      "phone": "186****7329"
    },
    {
      "datetime": "2020年09月12日 20:28:91",
      "count": 20,
      "from": "刘德华",
      "phone": "186****7329"
    },
    {
      "datetime": "2020年09月12日 20:28:91",
      "count": 20,
      "from": "刘德华",
      "phone": "186****7329"
    },
    {
      "datetime": "2020年09月12日 20:28:91",
      "count": 20,
      "from": "刘德华",
      "phone": "186****7329"
    },
  ];
}

class MyMachineUnbindHistory extends StatelessWidget {
  const MyMachineUnbindHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, "解绑记录"),
      body: GetBuilder<MyMachineUnbindHistoryController>(
        init: MyMachineUnbindHistoryController(),
        initState: (_) {},
        builder: (_) {
          return ListView.builder(
            itemCount: _.historyData != null ? _.historyData.length : 0,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  push(
                      MachineUnbindHistoryDetail(
                        detailData: _.historyData[index],
                      ),
                      context);
                },
                child: Align(
                  child: Container(
                    width: 345.w,
                    margin: const EdgeInsets.only(top: 15),
                    padding: EdgeInsets.fromLTRB(20.w, 19, 20.w, 20),
                    decoration: getDefaultWhiteDec(),
                    child: Column(
                      children: [
                        sbRow([
                          centRow([
                            getSimpleText("解绑时间：", 16, AppColor.textGrey,
                                isBold: true),
                            getSimpleText(_.historyData[index]["datetime"], 16,
                                AppColor.textBlack,
                                isBold: true),
                          ])
                        ], width: 345 - 20 * 2),
                        ghb(10),
                        sbRow([
                          centRow([
                            getSimpleText("解绑前所属人：", 16, AppColor.textGrey,
                                isBold: true),
                            getSimpleText(
                                "${_.historyData[index]["from"]}(${_.historyData[index]["phone"]})",
                                16,
                                AppColor.textBlack,
                                isBold: true),
                          ]),
                        ], width: 345 - 20 * 2),
                        ghb(10),
                        sbRow([
                          centRow([
                            getSimpleText("解绑台数：", 16, AppColor.textGrey,
                                isBold: true),
                            getSimpleText("${_.historyData[index]["count"]}台",
                                16, AppColor.textBlack,
                                isBold: true),
                          ]),
                          centRow([
                            getSimpleText(
                              "查看详情",
                              16,
                              const Color(0xFFA20606),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 20.w,
                              color: const Color(0xFFA20606),
                            ),
                          ])
                        ], width: 345 - 20 * 2)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
