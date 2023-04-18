import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/myTeam/accountingrate_change_history.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyTeamAccountingrateChangeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyTeamAccountingrateChangeController>(
        MyTeamAccountingrateChangeController());
  }
}

class MyTeamAccountingrateChangeController extends GetxController {
// final MyRepository repository;
// MyTeamAccountingrateChangeController(this.repository);

  // final _obj = ''.obs;
  // set obj(value) => this._obj.value = value;
  // get obj => this._obj.value;

  var flData = [
    {
      "id": 0,
      "name": "贷记卡",
      "rate": 0.6,
      "range": "0.43% - 0.98%",
      "sxf": 0,
      "sxfRange": "0 - 3"
    },
    {
      "id": 1,
      "name": "借记卡",
      "rate": 0.6,
      "range": "0.43% - 0.98%",
      "sxf": 0,
      "sxfRange": "0 - 3"
    },
    {
      "id": 2,
      "name": "扫码1000以上",
      "rate": 0.6,
      "range": "0.43% - 0.98%",
      "sxf": 0,
      "sxfRange": "0 - 3"
    },
    {
      "id": 3,
      "name": "手机pay",
      "rate": 0.6,
      "range": "0.43% - 0.98%",
      "sxf": 0,
      "sxfRange": "0 - 3"
    },
  ];

  loadRateData() {
    simpleRequest(
        url: Urls.getSelectToolMarginTemplateList,
        params: {},
        success: (success, json) {
          debugPrint(json["data"]);
        },
        after: () {});
  }

  @override
  void onInit() {
    loadRateData();
    super.onInit();
  }
}

class MyTeamAccountingrateChange
    extends GetView<MyTeamAccountingrateChangeController> {
  const MyTeamAccountingrateChange({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "结算费率修改", action: [
          CustomButton(
            onPressed: () {
              push(const AccountingRateChangeHistory(), context,
                  binding: AccountingRateChangeHistoryBinding());
            },
            child: Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Center(
                child: getSimpleText("修改记录", 14, AppColor.textBlack),
              ),
            ),
          ),
        ]),
        body: getInputSubmitBody(context, "确定修改", children: [
          GetBuilder<MyTeamAccountingrateChangeController>(
            init: controller,
            builder: (_) {
              return Column(
                children: [
                  ...(controller.flData
                      .asMap()
                      .entries
                      .map((e) => accountingrateCell(e.value))
                      .toList())
                ],
              );
            },
          )
        ])

        // Stack(
        //   children: [
        //     Positioned(
        //       top: 0,
        //       left: 0,
        //       right: 0,
        //       bottom: 100,
        //       child: GetBuilder<MyTeamAccountingrateChangeController>(
        //         init: MyTeamAccountingrateChangeController(),
        //         initState: (_) {},
        //         builder: (ctrl) {
        //           return ListView.builder(
        //             itemCount: ctrl.flData != null ? ctrl.flData.length : 0,
        //             itemBuilder: (context, index) {
        //               return accountingrateCell(ctrl.flData[index]);
        //             },
        //           );
        //         },
        //       ),
        //     ),
        //     Positioned(
        //         bottom: 0,
        //         left: 0,
        //         right: 0,
        //         height: 100,
        //         child: Container(
        //           width: 375.w,
        //           height: 100,
        //           color: Colors.white,
        //           child: Center(
        //             child: getSubmitBtn("确定修改", () {
        //               push(MyTeamAccountingrateChangeSuccess(), context);
        //             }),
        //           ),
        //         ))
        //   ],
        // )
        );
  }

  Widget accountingrateCell(
    Map data,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: 375.w,
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: Colors.white,
      child: Column(
        children: [
          sbRow([
            getSimpleText(data["name"], 15, AppColor.textBlack),
            getSimpleText("单笔提现手续费", 11, AppColor.textGrey2)
          ], width: 330.5),
          ghb(5),
          sbRow([
            Column(
              children: [
                Container(
                  width: 227.w,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color(0xFFEBF4FF),
                      borderRadius: BorderRadius.circular(6)),
                  child: CustomInput(
                    width: 227.w,
                    heigth: 40,
                    placeholder: "0.3",
                    textAlign: TextAlign.center,
                  ),
                ),
                ghb(5),
                getSimpleText("费率值 [ 0.43% - 0.98% ]", 11, AppColor.textGrey2)
              ],
            ),
            Column(
              children: [
                Container(
                  width: 110.w,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color(0xFFEBF4FF),
                      borderRadius: BorderRadius.circular(6)),
                  child: CustomInput(
                    width: 110.w,
                    heigth: 40,
                    placeholder: "0",
                    textAlign: TextAlign.center,
                  ),
                ),
                ghb(5),
                getSimpleText(" [ 0 - 3 ]", 11, AppColor.textGrey2)
              ],
            )
          ], width: 345)
        ],
      ),
    );
  }
}

class MyTeamAccountingrateChangeSuccess extends StatelessWidget {
  final bool? isSuccess;
  final String? img;
  final String? contentText;
  final String? submitBtnText;
  const MyTeamAccountingrateChangeSuccess(
      {Key? key,
      this.contentText,
      this.img,
      this.isSuccess = true,
      this.submitBtnText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, ""),
      body: Center(
          child: centClm([
        assetsSizeImage(img ?? "home/img_bs_03", 115.5, 98.5),
        ghb(64.5),
        getSimpleText(isSuccess! ? "提交成功" : "提交失败", 22, AppColor.textBlack,
            isBold: true),
        ghb(20),
        getSimpleText(contentText ?? "您修改的结算费率正在审核中", 14, AppColor.textGrey),
        ghb(159),
        getSubmitBtn(submitBtnText ?? "返回直属团队详情", () {
          // Navigator.pop(context);
          // Navigator.popAndPushNamed(context, MyTeamInfoCard());
          Navigator.popUntil(
              context, (route) => route.settings.name == "MyTeamInfoCard");
        })
      ])),
    );
  }
}
