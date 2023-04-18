import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatisticsMachinePopularizeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachinePopularizeController>(
        StatisticsMachinePopularizeController(datas: Get.arguments));
  }
}

class StatisticsMachinePopularizeController extends GetxController {
  final dynamic datas;

  StatisticsMachinePopularizeController({this.datas});

  RefreshController pullCtrl = RefreshController();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _allSelected = false.obs;
  bool get allSelected => _allSelected.value;
  set allSelected(v) => _allSelected.value = v;

  int pageSize = 20;
  int pageNo = 1;
  int count = 0;
  List dataList = [];
  List selectList = [];

  allSelectAction() {
    checkSelect(allSelect: !allSelected);
    update();
  }

  checkSelect({bool? allSelect}) {
    if (dataList.isEmpty) {
      return;
    }
    bool isAllSelect = true;
    List selectIds = [];

    selectList = [];

    for (var e in dataList) {
      if (allSelect != null) {
        e["selected"] = allSelect;
        isAllSelect = allSelect;
      } else {
        if (!(e["selected"] ?? false)) {
          isAllSelect = false;
        }
      }
      if (e["selected"]) {
        selectIds.add(e["levelGiftId"]);
        selectList.add(e);
      }
    }
    AppDefault().popularizeMachineSelectIds = selectIds;
    allSelected = isAllSelect;
  }

  onRefresh() {
    loadData();
  }

  onLoad() {
    loadData(isLoad: true);
  }

  clickCellSelect(Map data) {
    data["selected"] = !data["selected"];
    checkSelect();
    update();
  }

  popularizeAction() {
    if (selectList.isEmpty) {
      ShowToast.normal("请至少选择一台设备");
      return;
    }

    List ids = [];
    for (var e in selectList) {
      if (e["levelGiftId"] != null) {
        ids.add(e["levelGiftId"]);
      }
    }

    simpleRequest(
      url: Urls.levelGiftPromotionSet,
      params: {"levelGiftIds": ids},
      success: (success, json) {
        if (success) {
          ShowToast.normal("恭喜您，推广成功！");
        }
      },
      after: () {},
    );
  }

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;

    if (dataList.isEmpty) {
      isLoading = true;
    }
    List selectIds = AppDefault().popularizeMachineSelectIds;

    simpleRequest(
        url: Urls.levelGiftPromotionList,
        params: {},
        success: (success, json) {
          if (success) {
            List datas = json["data"] ?? [];
            dataList = isLoad ? [...dataList, ...datas] : datas;
            for (var e in datas) {
              e["selected"] = selectIds.contains(e["levelGiftId"]);
            }
            checkSelect();
            update();
            isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          }
        },
        after: () {
          isLoading = false;
        },
        useCache: true);

    // Future.delayed(const Duration(milliseconds: 200), () {
    //   count = 100;
    //   List datas = [];
    //   for (var i = 0; i < pageSize; i++) {
    //     datas.add({
    //       "id": dataList.length + i,
    //       "name": "嘉联云电签",
    //       "xh": "Furongyun-pos",
    //       "price": 159.0,
    //       "img": "D0031/2023/1/202301311856422204X.png"
    //     });
    //   }
    //   for (var e in datas) {
    //     e["selected"] = selectIds.contains(e["id"]);
    //   }
    //   dataList = isLoad ? [...dataList, ...datas] : datas;
    //   checkSelect();
    //   update();
    //   isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
    //   isLoading = false;
    // });
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }
}

class StatisticsMachinePopularize
    extends GetView<StatisticsMachinePopularizeController> {
  const StatisticsMachinePopularize({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "设备推广"),
      body: Stack(children: [
        Positioned.fill(
            bottom: 55.w + paddingSizeBottom(context),
            child: GetBuilder<StatisticsMachinePopularizeController>(
              builder: (_) {
                return SmartRefresher(
                  controller: controller.pullCtrl,
                  onLoading: controller.onLoad,
                  onRefresh: controller.onRefresh,
                  enablePullUp: controller.count > controller.dataList.length,
                  child: controller.dataList.isEmpty
                      ? GetX<StatisticsMachinePopularizeController>(
                          builder: (_) {
                            return CustomEmptyView(
                              isLoading: controller.isLoading,
                            );
                          },
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 20.w),
                          itemCount: controller.dataList.length,
                          itemBuilder: (context, index) {
                            return machineCell(
                                index, controller.dataList[index]);
                          },
                        ),
                );
              },
            )),
        Positioned(
            height: 55.w + paddingSizeBottom(context),
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(color: const Color(0x0D000000), blurRadius: 5.w)
              ]),
              child: Center(
                child: sbhRow([
                  CustomButton(onPressed: () {
                    controller.allSelectAction();
                  }, child: GetX<StatisticsMachinePopularizeController>(
                    builder: (_) {
                      return SizedBox(
                          height: 55.w,
                          child: centRow([
                            Image.asset(
                              assetsName(
                                  "machine/checkbox_${controller.allSelected ? "selected" : "normal"}"),
                              width: 16.w,
                              fit: BoxFit.fitWidth,
                            ),
                            gwb(15),
                            getSimpleText(controller.allSelected ? "反选" : "全选",
                                14, AppColor.text),
                          ]));
                    },
                  )),
                  getSubmitBtn(
                    "确认推广",
                    () {
                      controller.popularizeAction();
                    },
                    width: 90,
                    height: 30,
                    fontSize: 14,
                    color: AppColor.theme,
                  ),
                ], width: 375 - 15 * 2, height: 55),
              ),
            ))
      ]),
    );
  }

  Widget machineCell(int index, Map data) {
    if (data["selected"] == null) {
      data["selected"] = false;
    }
    return CustomButton(
      onPressed: () {
        controller.clickCellSelect(data);
      },
      child: Align(
        child: Container(
          width: 345.w,
          height: 120.w,
          margin: EdgeInsets.only(top: 15.w),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.w), color: Colors.white),
          child: Center(
            child: sbhRow([
              centRow([
                Image.asset(
                  assetsName(
                      "machine/checkbox_${data["selected"] ? "selected" : "normal"}"),
                  width: 16.w,
                  fit: BoxFit.fitWidth,
                ),
                gwb(10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.w),
                  child: Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4.w),
                        border: Border.all(
                            width: 0.5.w, color: AppColor.lineColor)),
                    child: Center(
                      child: CustomNetworkImage(
                        src: AppDefault().imageUrl +
                            (data["levelGiftImg"] ?? ""),
                        width: 90.w,
                        height: 90.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                gwb(10),
                sbClm([
                  centClm([
                    getSimpleText(data["levelName"] ?? "", 15, AppColor.text,
                        isBold: true),
                    ghb(10),
                    getSimpleText("型号：${data["levelDescribe"] ?? ""}", 12,
                        AppColor.text3),
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  getSimpleText("￥${priceFormat(data["nowPrice"] ?? "")}", 15,
                      AppColor.red,
                      isBold: true),
                ], height: 90, crossAxisAlignment: CrossAxisAlignment.start)
              ])
            ], width: 345 - 9 * 2, height: 120),
          ),
        ),
      ),
    );
  }
}
