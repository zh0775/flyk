// 红包领取记录（我的领取记录）

import 'package:cxhighversion2/ranking/red_packet_detail.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RedPacketRecordBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RedPacketRecordController>(RedPacketRecordController());
  }
}

class RedPacketRecordController extends GetxController {
  int currentPage = 1;
  int total = 0;

  List redPacketRecordList = [];

  // 获取奖励金领取记录
  getRedPacketRecordData() {
    Http().doPost(
      'https://mock.apifox.cn/m1/2153127-0-default/api/redpacket/record',
      {"pageNum": currentPage, "pageSize": 10},
      success: (json) {
        if (json['success']) {
          Map data = json['data'] ?? {};
          total = data['total'] ?? 0;
          if (redPacketRecordList.length <= total) {
            List newData = data['rows'] ?? [];
            redPacketRecordList = [...redPacketRecordList, ...newData];
          }
          update();
        }
      },
    );
  }

  // 是否取消奖励金红包订单接口
  confirmRedPacketID(id) {
    Http().doPost(
      'https://mock.apifox.cn/m1/2153127-0-default/api/redpacket/record/id',
      {"id": id},
      success: (json) {},
    );
  }

  // 模态框
  showModal(String title, Function() confirm) {
    showAlert(
      Global.navigatorKey.currentContext!,
      title,
      confirmOnPressed: () {
        Get.back();
        confirm();
      },
    );
  }

  // 初始化
  @override
  void onInit() {
    getRedPacketRecordData();
    super.onInit();
  }
}

class RedPacketRecordPage extends GetView<RedPacketRecordController> {
  const RedPacketRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, '我的领取记录'),
        body: GetBuilder<RedPacketRecordController>(
          init: RedPacketRecordController(),
          initState: (_) {},
          builder: (_) {
            return EasyRefresh.builder(
                onLoad: controller.redPacketRecordList.length >= controller.total
                    ? null
                    : () {
                        controller.currentPage++;
                        controller.getRedPacketRecordData();
                      },
                onRefresh: () {
                  controller.currentPage = 1;
                  controller.getRedPacketRecordData();
                },
                childBuilder: (context, physics) {
                  return SingleChildScrollView(
                    physics: physics,
                    child: Column(
                      children: List.generate(controller.redPacketRecordList.length, (index) {
                        Map data = controller.redPacketRecordList[index];
                        return redPacketRecordItem(data);
                      }),
                    ),
                  );
                });
          },
        ));
  }

  // 红包记录item
  Widget redPacketRecordItem(item) {
    return Container(
      width: 375.w,
      // height: 240.w,
      padding: EdgeInsets.all(15.w),
      margin: EdgeInsets.only(bottom: 15.w),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                width: 24.w,
                height: 24.w,
                assetsName('ranking/icon_wallet'),
                fit: BoxFit.fill,
              ),
              gwb(6.5.w),
              getSimpleText("奖励金订单金额 ${item['money']} 元", 14, const Color(0xFF333333))
            ],
          ),
          ghb(12),
          Container(
            width: 375.w - 15.w * 2,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(8.w)),
            child: Column(
              children: [
                sbhRow(height: 24.w, [getSimpleText('已领取金额', 12, const Color(0xFF999999)), getSimpleText("${item['claimAmount']}元", 12, const Color(0xFF999999))]),
                sbhRow(height: 24.w, [getSimpleText('订单编号', 12, const Color(0xFF999999)), getSimpleText("${item['orderNo']}", 12, const Color(0xFF999999))]),
                sbhRow(height: 24.w, [getSimpleText('兑换时间', 12, const Color(0xFF999999)), getSimpleText("${item['time']}", 12, const Color(0xFF999999))]),
                sbhRow(height: 24.w, [getSimpleText('领取次数', 12, const Color(0xFF999999)), getSimpleText("${item['hasDraw']}次", 12, const Color(0xFF999999))]),
                sbhRow(height: 24.w, [getSimpleText('剩余次数', 12, const Color(0xFF999999)), getSimpleText("${item['notDraw']}次", 12, const Color(0xFF999999))]),
              ],
            ),
          ),
          ghb(15),
          SizedBox(
            width: 375.w - 15.w * 2,
            height: 25.w,
            child: sbhRow(width: 375.w - 15.w * 2, [
              getSimpleText(item['orderStatus'] == 0 ? '已完成' : (item['orderStatus'] == 1 ? '进行中' : '已取消'), 12, item['orderStatus'] == 1 ? const Color(0xFFFE4F3B) : const Color(0xFF999999)),
              Row(
                children: [
                  CustomButton(
                    onPressed: () {
                      push(const RedPacketDetailPage(), null, binding: RedPacketDetailBinding());
                    },
                    child: Container(
                      width: 65.w,
                      height: 25.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.w), border: Border.all(width: 0.5.w, color: const Color(0xFF999999))),
                      child: getSimpleText('查看明细', 12, const Color(0xFF333333)),
                    ),
                  ),
                  item['orderStatus'] == 1
                      ? CustomButton(
                          onPressed: () {
                            controller.showModal('是否取消奖励金红包订单？', () {
                              controller.confirmRedPacketID(item['id']);
                            });
                          },
                          child: Container(
                            width: 65.w,
                            height: 25.w,
                            margin: EdgeInsets.only(left: 10.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.w), color: const Color(0xFFFE4F3B)),
                            child: getSimpleText('撤单', 12, Colors.white),
                          ),
                        )
                      : gwb(0)
                ],
              )
            ]),
          )
        ],
      ),
    );
  }
}
