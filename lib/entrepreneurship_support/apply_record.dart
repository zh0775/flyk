// 创业支持申请记录

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SupportApplyRecordBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SupportApplyRecordController>(SupportApplyRecordController());
  }
}

class SupportApplyRecordController extends GetxController {
  bool topAnimation = false;

  String allApplayRecordId = "allApplayRecordId";
  String hasApplayRecordId = "hasApplayRecordId";
  String hasNotApplayRecordId = "hasNotApplayRecordId";

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final PageController pageCtrl = PageController();
  final _topCurrentIndex = 0.obs;
  int get topCurrentIndex => _topCurrentIndex.value;
  set topCurrentIndex(v) {
    if (!topAnimation) {
      _topCurrentIndex.value = v;
      getApplyRecordData(topCurrentIndex);
      toChangePage(topCurrentIndex);
    }
  }

  toChangePage(index) {
    topAnimation = true;
    pageCtrl.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.linear).then((value) {
      topAnimation = false;
    });
  }

  List applyRecordData = [
    {"pageNum": 1, "pageSize": 10, "total": 0, "data": []},
    {"pageNum": 1, "pageSize": 10, "total": 0, "data": []},
    {"pageNum": 1, "pageSize": 10, "total": 0, "data": []}
  ];

  applyRecordStatus(index) {
    String applyStatusStr = "";
    switch (index) {
      case 0:
        applyStatusStr = "申请通过";
        break;
      case 1:
        applyStatusStr = "申请中";
        break;
      case 2:
        applyStatusStr = "申请未通过";
        break;
      default:
    }

    return applyStatusStr;
  }

  getApplyRecordData(int topIndex, {bool isLoad = false}) {
    int currentPageNumm = isLoad ? ++applyRecordData[topIndex]['pageNum'] : 1;
    // isLoad ? applyRecordData[topIndex]['pageNum']++ : applyRecordData[topIndex]['pageNum'] = 1;
    if (applyRecordData[topIndex]['data'].isEmpty) {
      isLoading = true;
    }

    Http().doPost('https://mock.apifox.cn/m1/2153127-0-default/api/entrepreneurship/support/record', {"type": topCurrentIndex, "pageNum": currentPageNumm, "pageSize": 10}, success: (json) {
      Map data = json['data'] ?? {};
      applyRecordData[topIndex]['total'] = data['total'] ?? 0;
      if (applyRecordData[topIndex]['data'].length <= applyRecordData[topIndex]['total']) {
        List newData = data['rows'] ?? [];
        applyRecordData[topIndex]['data'] = isLoad ? [...applyRecordData[topIndex]['data'], ...newData] : newData;
      }

      update([topIndex == 0 ? allApplayRecordId : (topIndex == 1 ? hasApplayRecordId : hasNotApplayRecordId)]);

      // update([topIndex == 0 ? hasRedPacketDetailId : hasNotRedPacketDetailId]);
    }, after: () {
      isLoading = false;
    });
  }

  // 初始化数据
  @override
  void onInit() {
    getApplyRecordData(0);
    super.onInit();
  }
}

class SupportApplyRecordPage extends GetView<SupportApplyRecordController> {
  const SupportApplyRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, '申请记录'),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 51.w,
            child: topBar(),
          ),
          // Positioned(
          Positioned.fill(
            top: 55.w,
            child: PageView.builder(
              controller: controller.pageCtrl,
              itemCount: 3,
              onPageChanged: (value) {
                controller.topCurrentIndex = value;
              },
              itemBuilder: (context, index) {
                return recordPage(index);
              },
            ),
          )
        ],
      ),
    );
  }

  // 头部区域
  Widget topBar() {
    return Container(
      width: 375.w,
      height: 51.w,
      color: Colors.white,
      child: Row(
        children: ["全部", "已通过", "未通过"]
            .asMap()
            .entries
            .map((item) => CustomButton(
                  onPressed: () {
                    controller.topCurrentIndex = item.key;
                    controller.getApplyRecordData(item.key);
                  },
                  child: GetX<SupportApplyRecordController>(
                    builder: (_) {
                      return SizedBox(
                        width: (375 / 3 - 0.1).w,
                        height: 55.w,
                        child: centClm([
                          getSimpleText(item.value, 16, const Color(0xFF333333)),
                          ghb(controller.topCurrentIndex == item.key ? 5 : 0),
                          controller.topCurrentIndex != item.key
                              ? gwb(0)
                              : Container(
                                  width: 15.w,
                                  height: 2.w,
                                  decoration: BoxDecoration(color: const Color(0xFFFE4B3B), borderRadius: BorderRadius.circular(0.5.w)),
                                )
                        ]),
                      );
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget recordPage(int currentIndex) {
    return GetBuilder<SupportApplyRecordController>(
      id: currentIndex == 0 ? controller.allApplayRecordId : (currentIndex == 1 ? controller.hasApplayRecordId : controller.hasNotApplayRecordId),
      builder: (_) {
        if (controller.applyRecordData[currentIndex]['data'].isEmpty) {
          return SingleChildScrollView(
            child: Center(
              child: CustomEmptyView(isLoading: controller.isLoading, bottomSpace: 200.w),
            ),
          );
        } else {
          return EasyRefresh.builder(
              onLoad: (controller.applyRecordData[currentIndex]['data'] ?? []).length >= (controller.applyRecordData[currentIndex]['total'] ?? 0)
                  ? null
                  : () {
                      controller.getApplyRecordData(currentIndex, isLoad: true);
                    },
              onRefresh: () {
                controller.getApplyRecordData(currentIndex);
              },
              childBuilder: (context, physics) {
                return ListView.builder(
                    physics: physics,
                    itemCount: controller.applyRecordData[currentIndex]['data'].length ?? 0,
                    itemBuilder: (context, index) {
                      Map itemData = controller.applyRecordData[currentIndex]['data'][index] ?? {};
                      return recordItem(itemData);
                    });
              });
        }
      },
    );
  }

  Widget recordItem(data) {
    return Container(
      width: 375.w,
      height: 75.w,
      padding: EdgeInsets.all(15.w),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [getSimpleText("${data['name']}", 15, const Color(0xFF333333)), getSimpleText(controller.applyRecordStatus(data['applyStatus']), 12, Color(data['applyStatus'] == 2 ? 0xFFFE4D3B : 0xFF999999))],
          ),
          ghb(8),
          SizedBox(width: 375.w, child: getSimpleText("${data['time']}", 12, const Color(0xFF999999)))
        ],
      ),
    );
  }
}
