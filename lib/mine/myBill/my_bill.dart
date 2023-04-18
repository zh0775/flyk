import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/mine/myBill/my_bill_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyBillBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyBillController>(MyBillController());
  }
}

class MyBillController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  List billListData = [];
  RefreshController pullCtrl = RefreshController();

  int pageNo = 1;
  int pageSize = 20;
  int count = 0;

  onLoad() async {
    loadBillList(isLoad: true);
  }

  onRefresh() async {
    loadBillList();
  }

  loadBillList({bool isLoad = false}) {
    if (isLoad) {
      pageNo++;
    } else {
      pageNo = 1;
    }
    if (billListData == null || billListData.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.userSubBillingList,
      params: {"pageSize": pageSize, "pageNo": pageNo},
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          count = data["count"];
          if (isLoad) {
            billListData = [...billListData, ...data["data"]];
            pullCtrl.loadComplete();
          } else {
            billListData = data["data"];
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
        isLoading = false;
      },
    );
  }

  @override
  void onInit() {
    loadBillList();
    super.onInit();
  }

  @override
  void dispose() {
    pullCtrl.dispose();
    super.dispose();
  }
}

class MyBill extends GetView<MyBillController> {
  const MyBill({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, "我的账单"),
      body: SmartRefresher(
        physics: const BouncingScrollPhysics(),
        controller: controller.pullCtrl,
        onLoading: controller.onLoad,
        onRefresh: controller.onRefresh,
        enablePullUp: controller.billListData.length < controller.count,
        child: GetBuilder<MyBillController>(
          init: controller,
          initState: (_) {},
          builder: (_) {
            return controller.billListData == null ||
                    controller.billListData.isEmpty
                ? GetX<MyBillController>(
                    builder: (_) {
                      return CustomEmptyView(
                        isLoading: controller.isLoading,
                      );
                    },
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.billListData != null &&
                            controller.billListData.isNotEmpty
                        ? controller.billListData.length
                        : 0,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () => Get.to(
                              MyBillDetail(
                                billData: controller.billListData[index],
                              ),
                              binding: MyBillDetailBinding()),
                          child:
                              billCell(index, controller.billListData[index]));
                    },
                  );
          },
        ),
      ),
    );
  }

  Widget billCell(int index, Map data) {
    return Align(
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        decoration: getDefaultWhiteDec(),
        width: 345.w,
        child: Column(
          children: [
            sbhRow([
              centClm([
                getSimpleText("结算款", 17, AppColor.textBlack),
                Container(
                  width: 15.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF6F05),
                      borderRadius: BorderRadius.circular(1.w)),
                )
              ], crossAxisAlignment: CrossAxisAlignment.start)
            ], width: 345 - 15 * 2, height: 51),
            gline(345, 0.5),
            sbhRow([
              SizedBox(
                width: 172.5.w - 15.w,
                child: centClm([
                  getSimpleText("结算日期：", 14, AppColor.textGrey2),
                  ghb(7),
                  getSimpleText(
                      "${data["year"]}-${data["month"] < 10 ? "0${data["month"]}" : "${data["month"]}"}",
                      19,
                      AppColor.textBlack,
                      isBold: true),
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ),
              gline(0.5, 50),
              SizedBox(
                width: 172.w - 18.w,
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w),
                  child: centClm([
                    getSimpleText("结算金额(元)：", 14, AppColor.textGrey2),
                    ghb(7),
                    getSimpleText(
                        priceFormat(data["tolAmount"]), 19, AppColor.textBlack,
                        isBold: true),
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                ),
              ),
            ], width: 345 - 15 * 2, height: 95.5)
          ],
        ),
      ),
    );
  }
}
