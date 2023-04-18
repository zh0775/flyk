import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math' as math;

class TerminalBackHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TerminalBackHistoryController>(TerminalBackHistoryController());
  }
}

class TerminalBackHistoryController extends GetxController {
  List historyList = [];
  int pageNo = 1;
  int pageSize = 10;
  int count = 0;
  final _isBeforeLoad = true.obs;
  set isBeforeLoad(v) => _isBeforeLoad.value = v;
  bool get isBeforeLoad => _isBeforeLoad.value;
  RefreshController pullCtrl = RefreshController();

  onLoad() async {
    loadHistoryList(isLoad: true);
  }

  onRefresh() async {
    loadHistoryList();
  }

  loadHistoryList({bool isLoad = false}) {
    if (isLoad) {
      pageNo++;
    } else {
      pageNo = 1;
    }

    simpleRequest(
      url: Urls.userTerminalLogsList,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
        "terminal_Type": 1,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          count = data["count"] ?? 0;

          if (isLoad) {
            historyList = [...historyList, ...data["data"]];
            pullCtrl.loadComplete();
          } else {
            historyList = data["data"];
            // historyList = [
            //   {
            //     "machines": [
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //       {},
            //     ]
            //   }
            // ];
            pullCtrl.refreshCompleted();
          }
          update();
        } else {
          if (isLoad) {
            pullCtrl.loadFailed();
          } else {
            pullCtrl.refreshFailed();
          }
        }
      },
      after: () {
        isBeforeLoad = false;
      },
    );
  }

  @override
  void onInit() {
    loadHistoryList();
    super.onInit();
  }

  @override
  void dispose() {
    pullCtrl.dispose();
    super.dispose();
  }
}

class TerminalBackHistory extends GetView<TerminalBackHistoryController> {
  const TerminalBackHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "回拨记录"),
        body: GetBuilder<TerminalBackHistoryController>(
          init: controller,
          builder: (controller) {
            return SmartRefresher(
              physics: const BouncingScrollPhysics(),
              controller: controller.pullCtrl,
              onLoading: controller.onLoad,
              onRefresh: controller.onRefresh,
              enablePullUp: controller.count > controller.historyList.length,
              child: controller.historyList.isEmpty
                  ? GetX<TerminalBackHistoryController>(
                      init: controller,
                      builder: (controller) {
                        return CustomEmptyView(
                          isLoading: controller.isBeforeLoad,
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: controller.historyList != null &&
                              controller.historyList.isNotEmpty
                          ? controller.historyList.length
                          : 0,
                      itemBuilder: (context, index) {
                        return historyCell(
                            index, controller.historyList[index], context);
                      },
                    ),
            );
          },
        ));
  }

  Widget historyCell(int index, Map data, BuildContext context) {
    return CustomButton(
        onPressed: () {
          showTerminalListModel(context, data["machines"] ?? []);
        },
        child: Container(
          margin: EdgeInsets.only(top: 15.w),
          width: 345.w,
          decoration: getDefaultWhiteDec(),
          child: Column(
            children: [
              ghb(17),
              sbRow([
                getSimpleText("回拨时间：", 15, AppColor.textBlack, isBold: true),
              ], width: 345 - 18 * 2),
              ghb(10),
              sbRow([
                getSimpleText("回拨对象：", 15, AppColor.textBlack, isBold: true),
              ], width: 345 - 18 * 2),
              ghb(10),
              sbRow([
                getRichText("回拨机具：", "查看", 15, AppColor.textBlack, 15,
                    AppColor.buttonTextBlue,
                    fw: AppDefault.fontBold, fw2: AppDefault.fontBold),
              ], width: 345 - 18 * 2),
              ghb(18.5)
            ],
          ),
        ));
  }

  showTerminalListModel(BuildContext context, List datas) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 316.w,
              height: 471.5.w,
              child: Column(
                children: [
                  Container(
                    width: 316.w,
                    height: 415.w,
                    decoration: getDefaultWhiteDec(),
                    child: Scrollbar(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8.w),
                        physics: const BouncingScrollPhysics(),
                        itemCount: datas != null && datas.isNotEmpty
                            ? datas.length
                            : 0,
                        itemBuilder: (context, index) {
                          return modelInfoCell(datas[index], index);
                        },
                      ),
                    ),
                  ),
                  CustomButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Transform.rotate(
                        angle: math.pi / 2 * 2,
                        child: Image.asset(
                          assetsName("common/btn_model_close"),
                          width: 37.w,
                          height: 56.5.w,
                          fit: BoxFit.fill,
                        ),
                      ))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget modelInfoCell(Map data, int index) {
    return Align(
      child: SizedBox(
        width: (316 - 18.5 * 2).w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ghb(9),
            getSimpleText("机具编号（SN号）", 14, const Color(0xFF808080)),
            ghb(12),
            getSimpleText("0000 1102C 831993 79123", 16, AppColor.textBlack,
                isBold: true),
            ghb(9)
          ],
        ),
      ),
    );
  }
}
