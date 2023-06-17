// 奖励金 已领取记录

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/ranking/red_packet_record.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RedPacketReceiveHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RedPacketReceiveHistoryController>(
        RedPacketReceiveHistoryController());
  }
}

class RedPacketReceiveHistoryController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  List receiveHistoryList = [];
  // 今日领取金额
  double todayReceiveMoney = 0.0;
  // 总领取金额
  double receiveTotalMoney = 0.0;
  double bodyHeight = 0.0;

  int currentPage = 1;
  int total = 0;

  getReceiveHistoryApi() {
    if (receiveHistoryList.isEmpty) {
      isLoading = true;
    }

    simpleRequest(
        url: Urls.userHongbaoQueueAllList,
        params: {},
        otherData: {"pageSize": 10, "pageNo": currentPage},
        success: (success, json) {
          if (success) {
            Map jsonData = json['data'] ?? {};
            total = jsonData['count'] ?? 0;
            todayReceiveMoney = double.parse(jsonData['totalAmount'] ?? '0.0');
            receiveTotalMoney = double.parse(jsonData['thisDAmount'] ?? '0.0');
            if (receiveHistoryList.length <= total) {
              List newData = jsonData['data'] ?? [];
              receiveHistoryList = currentPage == 1
                  ? newData
                  : [...receiveHistoryList, ...newData];
              update();
            }
          }
        },
        after: () {});
  }

  @override
  void onInit() {
    getReceiveHistoryApi();
    super.onInit();
  }
}

class RedPacketReceiveHistory
    extends GetView<RedPacketReceiveHistoryController> {
  const RedPacketReceiveHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    controller.bodyHeight = screenHeight - appBarHeight - statusBarHeight;

    return Scaffold(
      appBar: getDefaultAppBar(context, "已领取记录", action: [
        CustomButton(
          onPressed: () {
            push(const RedPacketRecordPage(), context,
                binding: RedPacketRecordBinding());
          },
          child: SizedBox(
            height: kToolbarHeight,
            width: 80.w,
            child: Center(
              child: getSimpleText("我的红包", 14, AppColor.textBlack),
            ),
          ),
        )
      ]),
      body: GetBuilder<RedPacketReceiveHistoryController>(
        builder: (_) {
          if (controller.receiveHistoryList.isEmpty) {
            return SingleChildScrollView(
              child: Center(
                child: CustomEmptyView(
                    isLoading: controller.isLoading, bottomSpace: 200.w),
              ),
            );
          } else {
            return Column(
              children: [toDayReceiveHeader(), receiveHistoryBody()],
            );
          }
        },
      ),
    );
  }

  // 今日获取总金额头部信息
  Widget toDayReceiveHeader() {
    return GetBuilder<RedPacketReceiveHistoryController>(
      builder: (_) {
        return Container(
          width: 375.w,
          height: 49.w,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 15.w, right: 15.w),
          // 今日已领取总额为 3.0 元，累计已领取 264.50 元
          child: Text.rich(TextSpan(
              text: "今日已领取总额为 ",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
              children: [
                TextSpan(
                    text: "${controller.todayReceiveMoney}",
                    style: const TextStyle(
                        color: Color(0xFFFE4C3B), fontWeight: FontWeight.bold)),
                const TextSpan(text: " 元，累计已领取 "),
                TextSpan(
                    text: "${controller.receiveTotalMoney}",
                    style: const TextStyle(
                        color: Color(0xFFFE4C3B), fontWeight: FontWeight.bold)),
                const TextSpan(text: " 元"),
              ])),
        );
      },
    );
  }

  // 获取红包领取记录列表
  Widget receiveHistoryBody() {
    return GetBuilder<RedPacketReceiveHistoryController>(
      builder: (_) {
        return Container(
            width: 375.w,
            height: controller.bodyHeight - 50.w,
            color: Colors.white,
            child: EasyRefresh.builder(
                onLoad: controller.receiveHistoryList.length >= controller.total
                    ? null
                    : () {
                        controller.currentPage++;
                        controller.getReceiveHistoryApi();
                      },
                onRefresh: () {
                  controller.currentPage = 1;
                  controller.getReceiveHistoryApi();
                },
                childBuilder: (context, physics) {
                  return ListView.builder(
                      physics: physics,
                      itemCount: controller.receiveHistoryList.length,
                      itemBuilder: (context, index) {
                        Map receiveItem =
                            controller.receiveHistoryList[index] ?? {};
                        return receiveHistoryItem(receiveItem);
                      });
                }));
      },
    );
  }

  // 获取红包item
  Widget receiveHistoryItem(Map item) {
    return Container(
      width: 375.w,
      height: 90.w,
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          SizedBox(
            width: 375.w - 15.w * 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  width: 45.w,
                  height: 45.w,
                  assetsName('ranking/red_envelope'),
                  fit: BoxFit.cover,
                ),
                gwb(10),
                SizedBox(
                  width: 375.w - 15.w * 2 - 45.w - 10.w,
                  height: 90.w - 15.w * 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getSimpleText("红包领取", 16.w, Color(0xFF333333)),
                          ghb(11),
                          getSimpleText("+${item['receiveAmount']}", 18.w,
                              Color(0xFF333333)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getSimpleText("订单号：${item['order_NO']}", 12.w,
                              Color(0xFF999999)),
                          ghb(10),
                          getSimpleText("已领取", 12.w, Color(0xFF999999)),
                        ],
                      ),
                      getSimpleText(
                          "${item['receiveTime']}", 12, Color(0xFF999999))
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
