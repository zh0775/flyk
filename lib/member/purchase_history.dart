// 会员购买记录页面
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class PurchaseHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<PurchaseHistoryController>(PurchaseHistoryController());
  }
}

class PurchaseHistoryController extends GetxController {
  int currentPage = 1;
  int total = 0;

  List purchaseHistoryList = [
    // {"id": 1, "vipTitle": "付利优客超级会员(1个月)", "payTime": "2022-10-08 12:35:09", "payStatus": 0, "orderNo": "2022164262457895", "money": "98.00"},
    // {"id": 2, "vipTitle": "付利优客超级会员(2个月)", "payTime": "2022-10-08 12:35:09", "payStatus": 0, "orderNo": "2022164262457895", "money": "198.00"}
  ];

  getPayStatus(statusCode) {
    String payStatusTitle = "";
    switch (statusCode) {
      case 0:
        payStatusTitle = "购买成功";
        break;
      case 1:
        payStatusTitle = "购买失败";
        break;
      default:
    }

    return payStatusTitle;
  }

  // 获取接口数据
  getPurchaseHistoryData() {
    Http().doPost(
      'https://mock.apifox.cn/m1/2153127-0-default/api/member/purchase_history_list',
      {"pageSize": currentPage, "pageNum": 10},
      success: (json) {
        if (json['success']) {
          Map data = json['data'] ?? {};
          total = data['total'];
          if (purchaseHistoryList.length <= total) {
            List newData = data['rows'] ?? [];
            purchaseHistoryList = [...purchaseHistoryList, ...newData];
          }
          update();
        }
      },
    );
  }

  @override
  void onInit() async {
    getPurchaseHistoryData();

    super.onInit();
  }
}

class PurchaseHistoryPage extends GetView<PurchaseHistoryController> {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, '购买记录'),
        body: GetBuilder<PurchaseHistoryController>(
          init: PurchaseHistoryController(),
          initState: (_) {},
          builder: (_) {
            return EasyRefresh.builder(
                onLoad: controller.purchaseHistoryList.length >= controller.total
                    ? null
                    : () {
                        controller.currentPage++;
                        controller.getPurchaseHistoryData();
                      },
                onRefresh: () {
                  controller.currentPage = 1;
                  controller.getPurchaseHistoryData();
                },
                childBuilder: (context, physics) {
                  return SingleChildScrollView(
                    physics: physics,
                    padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 0),
                    child: Column(
                      children: List.generate(controller.purchaseHistoryList.length, (index) {
                        Map vipPaymentItem = controller.purchaseHistoryList[index];
                        return vipPaymentHistory(vipPaymentItem);
                      }),
                    ),
                  );
                });
          },
        ));
  }

  Widget vipPaymentHistory(item) {
    return Stack(
      children: [
        Container(
          width: 375.w - 15.w * 2,
          padding: EdgeInsets.fromLTRB(17.w, 12.w, 8.w, 17.w),
          margin: EdgeInsets.only(bottom: 15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getSimpleText("订单号：${item['orderNo']}", 12, const Color(0xFF999999)),
              ghb(9),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSimpleText("${item['vipTitle']}", 14, const Color(0xFF333333), isBold: true),
                  getSimpleText("${item['money']}", 18, const Color(0xFF333333), isBold: true),
                ],
              ),
              ghb(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getSimpleText("${item['payTime']}", 12, const Color(0xFF999999)),
                  getSimpleText(controller.getPayStatus(item['payStatus']), 12, const Color(0xFF999999)),
                ],
              ),
            ],
          ),
        ),
        Positioned(
            top: 40.w,
            child: Container(
              width: 3.w,
              height: 15.w,
              decoration: BoxDecoration(color: const Color(0xFFED1724), borderRadius: BorderRadius.circular(1.5.w)),
            )),
      ],
    );
  }
}
