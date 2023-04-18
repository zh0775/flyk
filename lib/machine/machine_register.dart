import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineRegisterBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineRegisterController>(MachineRegisterController());
  }
}

class MachineRegisterController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  int pageSize = 20;
  int pageNo = 1;
  int count = 0;
  List dataList = [];

  RefreshController pullCtrl = RefreshController();

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }

    Future.delayed(const Duration(seconds: 1), () {
      isLoading = false;
      dataList = [
        {},
        {},
        {},
      ];
      count = 3;
      isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
      update();
    });
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    pullCtrl.dispose();
    super.onClose();
  }
}

class MachineRegister extends GetView<MachineRegisterController> {
  const MachineRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "设备注册"),
      body: GetBuilder<MachineRegisterController>(
        builder: (_) {
          return SmartRefresher(
            controller: controller.pullCtrl,
            onLoading: () => controller.loadData(isLoad: true),
            onRefresh: () => controller.loadData(),
            enablePullUp: controller.count > controller.dataList.length,
            child: controller.dataList.isEmpty
                ? GetX<MachineRegisterController>(
                    builder: (_) {
                      return CustomEmptyView(
                        isLoading: controller.isLoading,
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: controller.dataList.length,
                    padding: EdgeInsets.only(bottom: 20.w),
                    itemBuilder: (context, index) {
                      return cell(index, controller.dataList[index]);
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget cell(int index, Map data) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        width: 345.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
        height: 105.w,
        child: sbhRow([
          centRow([
            Container(
              width: 40.w,
              height: 40.w,
              color: AppColor.red,
            ),
            gwb(12),
            centClm([
              getSimpleText("融享付", 15, AppColor.text, isBold: true),
              ghb(5),
              getSimpleText("专业平台品质保障", 12, AppColor.text2),
              ghb(5),
              Container(
                width: 54.w,
                height: 18.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppColor.theme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2.w)),
                child: getSimpleText("新人专享", 10, AppColor.theme),
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ]),
          sbClm([
            CustomButton(
              onPressed: () {
                showAlert(
                  Global.navigatorKey.currentContext!,
                  "确定要注册此设备吗",
                  confirmOnPressed: () {
                    Get.back();
                  },
                );
              },
              child: Container(
                width: 60.w,
                height: 30.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.w),
                    border: Border.all(width: 0.5.w, color: AppColor.theme)),
                child: getSimpleText("注册", 12, AppColor.theme),
              ),
            )
          ], height: 105 - 22.5 * 2)
        ], width: 315, height: 105),
      ),
    );
  }
}
