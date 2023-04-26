import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/earn/earn_particulars.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class MyWalletConvertHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyWalletConvertHistoryController>(
        MyWalletConvertHistoryController(datas: Get.arguments));
  }
}

class MyWalletConvertHistoryController extends GetxController {
  final dynamic datas;
  MyWalletConvertHistoryController({this.datas});

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  int pageNo = 1;
  int pageSize = 20;
  int count = 0;
  List dataList = [];

  loadList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }

    Map<String, dynamic> params = {
      "a_No": 4,
      "pageSize": pageSize,
      "pageNo": pageNo,
      "d_Type": 1
    };

    simpleRequest(
      url: Urls.userFinanceIntegralList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"];
          List tmpList = data["data"] ?? [];
          dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
          update();
        }
      },
      after: () {
        isLoading = false;
        isFirstLoading = false;
      },
    );
  }

  @override
  void onReady() {
    loadList();
    super.onReady();
  }

  bool isRedPack = true;
  @override
  void onInit() {
    isRedPack = (datas ?? {})["isRedPack"] ?? true;

    super.onInit();
  }
}

class MyWalletConvertHistory extends GetView<MyWalletConvertHistoryController> {
  const MyWalletConvertHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "兑换记录"),
      body: GetBuilder<MyWalletConvertHistoryController>(
        builder: (_) {
          return EasyRefresh.builder(
            onLoad: controller.dataList.length >= controller.count
                ? null
                : () => controller.loadList(),
            onRefresh: () => controller.loadList(isLoad: true),
            childBuilder: (context, physics) {
              return controller.dataList.isEmpty
                  ? GetX<MyWalletConvertHistoryController>(builder: (_) {
                      return controller.isFirstLoading
                          ? SkeletonListView(padding: EdgeInsets.all(15.w))
                          : CustomListEmptyView(
                              isLoading: controller.isLoading);
                    })
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 20.w),
                      itemCount: controller.dataList.length,
                      itemBuilder: (context, index) {
                        return cell(index, controller.dataList[index]);
                      },
                    );
            },
          );
        },
      ),
    );
  }

  Widget cell(int index, Map data) {
    return CustomButton(
      onPressed: () {
        push(
            EarnParticulars(
              earnData: data,
              title: "积分明细",
            ),
            null,
            binding: EarnParticularsBinding());
      },
      child: Container(
        width: 375.w,
        height: 75.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(width: 0.5.w, color: AppColor.lineColor))),
        child: sbhRow([
          centClm([
            sbRow([
              getSimpleText(data["codeName"] ?? "", 15, AppColor.text2,
                  isBold: true),
              getSimpleText(
                  "${(data["bType"] ?? -1) == 0 ? "-" : "+"}${priceFormat(data["amount"] ?? 0, savePoint: 0)}",
                  18,
                  AppColor.text,
                  isBold: true)
            ], width: 345),
            ghb(8),
            getSimpleText(data["addTime"] ?? "", 12, AppColor.text3),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ], width: 345, height: 75),
      ),
    );
  }
}
