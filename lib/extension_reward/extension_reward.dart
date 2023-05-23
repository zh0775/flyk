// 拓新奖励页面

import 'dart:async';

import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExtensionRewardBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ExtensionRewardController>(ExtensionRewardController());
  }
}

class ExtensionRewardController extends GetxController {
  List noticeList = [
    {"title": "新增服务商注册30天以内，线上采购5台并激活1台奖励100元"},
  ];

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  Timer? noticeTimer;
  final ScrollController _scrollController = ScrollController();

  int pageNum = 1;
  int pageSize = 10;
  int total = 0;

  List extensionRewardData = [
    // {"id": 1, "name": "瑞鑫科技", "levelIndex": 1, "reward": "101.00", "time": "2023-03-10", "purchaseCount": 3, "activateCount": 2},
    // {"id": 2, "name": "德信工艺", "levelIndex": 2, "reward": "102.00", "time": "2023-03-10", "purchaseCount": 1, "activateCount": 1},
    // {"id": 3, "name": "张成新", "levelIndex": 3, "reward": "103.00", "time": "2023-03-10", "purchaseCount": 2, "activateCount": 1},
  ];

  // priceFormat(price)

  // noticeBar
  startNoticeBar() {
    noticeTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_scrollController.positions.isNotEmpty) {
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        double pixels = _scrollController.offset + 30.0.w;
        if (pixels >= maxScrollExtent) {
          noticeList = [...noticeList, ...noticeList];
          update();
        } else {
          _scrollController.animateTo(pixels, duration: const Duration(milliseconds: 500), curve: Curves.linear);
        }
      }
    });
  }

  getExtensionRewardData() {
    if (extensionRewardData.isEmpty) {
      isLoading = true;
    }

    Http().doPost(
      'https://mock.apifox.cn/m1/2153127-0-default/api/extension/reward',
      {"pageNum": pageNum, "pageSize": pageSize},
      success: (json) {
        if (json['success']) {
          Map data = json['data'] ?? {};
          List newData = data['rows'] ?? [];
          total = data['total'] ?? 0;
          if (newData.length <= total) {
            extensionRewardData = [...extensionRewardData, ...newData];
          }
          update();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  @override
  void onInit() {
    startNoticeBar();
    getExtensionRewardData();
    super.onInit();
  }

  @override
  void onClose() {
    if (noticeTimer != null) {
      noticeTimer!.cancel();
      noticeTimer = null;
    }
    super.onClose();
  }
}

class ExtensionRewardPage extends GetView<ExtensionRewardController> {
  const ExtensionRewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, '拓新奖励'),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            child: headerContainer(),
          ),
          Positioned.fill(top: 208.w, left: 15.w, right: 15.w, bottom: 0, child: extensionRewardContainer()),
        ],
      ),
    );
  }

  Widget headerContainer() {
    return Container(
      width: 375.w,
      height: 255.w,
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xFFFD573B),
        Color(0xFFFF3A3A),
      ])),
      child: Column(
        children: [
          Container(
            width: 375.w,
            height: 28.w,
            padding: EdgeInsets.only(left: 12.5.w),
            decoration: BoxDecoration(border: Border.all(width: 0.5.w, color: Color(0xFFEFE6D4)), color: Color(0xFFFBFAE6)),
            child: Row(
              children: [
                Image(
                  width: 18.w,
                  height: 18.w,
                  image: AssetImage(
                    assetsName('extension_reward/icon_notice'),
                  ),
                ),
                gwb(5),
                SizedBox(
                  width: 320.w,
                  height: 28.w,
                  child: GetBuilder<ExtensionRewardController>(
                    builder: (_) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.noticeList.length,
                        controller: controller._scrollController,
                        itemExtent: 320.w,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return getSimpleText("${controller.noticeList[index]['title']}", 10, Color(0xFFFF881E), textHeight: 2);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 375.w,
            height: 227.w,
            child: Column(
              children: [
                ghb(20),
                getSimpleText('总入账奖励金额(元)', 12, Colors.white),
                ghb(12.5),
                getSimpleText('2613.00', 30, Colors.white, isBold: true),
                ghb(30),
                SizedBox(
                  width: 375.w - 75.w * 2,
                  height: 100.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getSimpleText('本月新增(人)', 12, Colors.white),
                          ghb(11.5),
                          getSimpleText('12', 18, Colors.white, isBold: true),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getSimpleText('本月入账(人)', 12, Colors.white),
                          ghb(11.5),
                          getSimpleText('200.00', 18, Colors.white, isBold: true),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // 奖励记录列表
  Widget extensionRewardContainer() {
    return Container(
        width: 375.w - 15.w * 2,
        padding: EdgeInsets.only(left: 15.w, right: 15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              height: 45.w + 1.w,
              child: Column(
                children: [
                  SizedBox(
                    width: 345.w - 15.w * 2,
                    height: 45.w,
                    child: Row(
                      children: [
                        Container(
                          width: 3.w,
                          height: 15.w,
                          decoration: BoxDecoration(color: Color(0xFFFE4D3B), borderRadius: BorderRadius.circular(1.25.w)),
                        ),
                        gwb(10.5),
                        getSimpleText('奖励记录', 16, Color(0xFF333333), isBold: true)
                      ],
                    ),
                  ),
                  Container(
                    width: 345.w - 15.w * 2,
                    height: 0.5.w,
                    color: Color(0xFFEEEEEE),
                  ),
                ],
              ),
            ),
            Positioned.fill(
                top: 45.w,
                bottom: 0,
                child: GetBuilder<ExtensionRewardController>(
                  builder: (_) {
                    if (controller.extensionRewardData.isEmpty) {
                      return SingleChildScrollView(
                        child: Center(
                          child: CustomEmptyView(isLoading: controller.isLoading),
                        ),
                      );
                    } else {
                      return EasyRefresh.builder(
                          onLoad: controller.extensionRewardData.length > controller.total
                              ? null
                              : () {
                                  controller.pageNum++;
                                  controller.getExtensionRewardData();
                                },
                          childBuilder: (context, physics) {
                            return ListView.builder(
                                physics: physics,
                                itemCount: controller.extensionRewardData.length,
                                itemBuilder: (context, index) {
                                  Map data = controller.extensionRewardData[index] ?? {};
                                  return extensionRewardItem(data);
                                });
                          });
                    }
                  },
                ))
          ],
        ));
  }

  Widget extensionRewardItem(item) {
    return Container(
        width: 345.w,
        padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
        child: Column(
          children: [
            SizedBox(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(45.w / 2),
                    child: Image.asset(assetsName('mine/default_head')),
                  ),
                  gwb(9.5),
                  SizedBox(
                      width: 345.w - 15.w * 2 - 45.w - 9.5.w - 25.w,
                      height: 45.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  getSimpleText("${item['name']}", 16, Color(0xFF333333)),
                                  Image.asset(
                                    width: 31.5.w,
                                    height: 15.5.w,
                                    assetsName("extension_reward/level${item['levelIndex']}"),
                                    fit: BoxFit.fill,
                                  ),
                                ],
                              ),
                              getSimpleText("+${item['reward']}元", 14, Color(0xFFFE493B), isBold: true)
                            ],
                          ),
                          getSimpleText("注册时间：${item['time']}", 12, Color(0xFF333333))
                        ],
                      )),
                ],
              ),
            ),
            ghb(15),
            Container(
              width: 345.w - 15.w * 2,
              height: 45.w,
              padding: EdgeInsets.only(left: 15.w, right: 15.w),
              decoration: BoxDecoration(color: Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(4.w)),
              child: Row(
                children: [
                  SizedBox(
                    width: (345.w - 30.w * 2) / 2,
                    child: Row(
                      children: [
                        getSimpleText('采购台数：', 12, Color(0xFF333333)),
                        gwb(8.5),
                        getSimpleText("${item['purchaseCount']}", 14, Color(0xFFFE4D3B), isBold: true),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: (345.w - 30.w * 2) / 2,
                    child: Row(
                      children: [
                        getSimpleText('激活台数：', 12, Color(0xFF333333)),
                        gwb(8.5),
                        getSimpleText("${item['activateCount']}", 14, Color(0xFFFE4D3B), isBold: true),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
