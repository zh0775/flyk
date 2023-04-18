import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ApplyCreditCardListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ApplyCreditCardListController>(ApplyCreditCardListController());
  }
}

class ApplyCreditCardListController extends GetxController {
  List cardList = [{}, {}];
  RefreshController pullCtrl = RefreshController();

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  int pageNo = 1;
  int pageSize = 10;
  int count = 0;
  onLoad() {
    loadCardList(isLoad: true);
  }

  onRefresh() {
    loadCardList();
  }

  loadCardList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    simpleRequest(
      url: "",
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          count = data["count"];
          isLoad
              ? cardList = [...cardList, ...data["data"]]
              : cardList = data["data"];
          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  @override
  void onInit() {
    loadCardList();
    super.onInit();
  }

  @override
  void dispose() {
    pullCtrl.dispose();
    super.dispose();
  }
}

class ApplyCreditCardList extends GetView<ApplyCreditCardListController> {
  const ApplyCreditCardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "信用卡申请"),
      body: GetBuilder<ApplyCreditCardListController>(
        init: controller,
        builder: (_) {
          return SmartRefresher(
              physics: const BouncingScrollPhysics(),
              controller: controller.pullCtrl,
              onLoading: controller.onLoad,
              onRefresh: controller.onRefresh,
              enablePullUp: controller.count > controller.cardList.length,
              child: controller.cardList.isEmpty
                  ? GetX<ApplyCreditCardListController>(
                      builder: (_) {
                        return CustomEmptyView(
                          isLoading: controller.isLoading,
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: controller.cardList.isNotEmpty
                          ? controller.cardList.length
                          : 0,
                      itemBuilder: (context, index) {
                        return cardCell(index, controller.cardList[index]);
                      },
                    ));
        },
      ),
    );
  }

  Widget cardCell(int index, Map data) {
    return Container(
      width: 375.w,
      color: Colors.white,
      margin: EdgeInsets.only(top: 15.5.w),
      child: Column(
        children: [
          ghb(25.w),
          // Container(
          //   width: 10,
          //   height: 10,
          //   color: Colors.red,
          // ),
          sbRow([
            Container(
              width: 138.w,
              height: 87.w,
              decoration: BoxDecoration(
                  color: const Color(0xFF343434),
                  borderRadius: BorderRadius.circular(5.w)),
            ),
            centClm([
              centRow([
                getSimpleText("上海银行无界卡", 15, AppColor.textBlack, isBold: true),
                ghb(8),
                gline(1, 14, color: const Color(0xFFE6E6E6)),
                ghb(8),
                getSimpleText("高额度", 15, AppColor.textBlack, isBold: true),
              ]),
              getWidthText("上海银行无界卡 | 高额度", 13, AppColor.textGrey, 193.5, 1),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ], width: 375 - 15 * 2, crossAxisAlignment: CrossAxisAlignment.end)
        ],
      ),
    );
  }
}
