// 创业支持页面

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/entrepreneurship_support/apply_record.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SupportBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<SupportPageController>(() => SupportPageController(
    //    SupportPageRepository(MyApi())));

    Get.put<SupportController>(SupportController());
  }
}

class SupportController extends GetxController {
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  set currentIndex(v) => _currentIndex.value = v;

  // 默认分期 0
  final _stagCurrentIndex = 0.obs;
  int get stagCurrentIndex => _stagCurrentIndex.value;
  set stagCurrentIndex(v) => _stagCurrentIndex.value = v;

  List supportData = [];

  getSupportData() {
    Http().doPost(
      'https://mock.apifox.cn/m1/2153127-0-default/api/entrepreneurship/support/list',
      {},
      success: (json) {
        if (json['success']) {
          Map data = json['data'] ?? {};
          supportData = data['rows'] ?? [];

          update();
        }
      },
    );
  }

  // 初始化
  @override
  void onInit() {
    getSupportData();
    super.onInit();
  }
}

class SupportPage extends GetView<SupportController> {
  const SupportPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFD3C6),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [headerContainer(), supportContainer()],
              ),
            ),
            Positioned(
                right: 0,
                top: 225.w,
                child: CustomButton(
                  onPressed: () {
                    push(const SupportApplyRecordPage(), null, binding: SupportApplyRecordBinding());
                  },
                  child: Container(
                      width: 25.w,
                      // height: 75.w,
                      padding: EdgeInsets.fromLTRB(5.w, 10.w, 5.w, 10.w),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12.w), bottomLeft: Radius.circular(12.w)),
                          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                            Color(0xFFFD573B),
                            Color(0xFFFF3A3A),
                          ])),
                      child: Text(
                        '申请记录',
                        style: TextStyle(
                          fontSize: 12.w,
                          color: Colors.white,
                        ),
                      )),
                ))
          ],
        ));
  }

  // 头部区域
  Widget headerContainer() {
    return Container(
      width: 375.w,
      height: 255.w,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
              assetsName('support/top_bg'),
            ),
            fit: BoxFit.fill),
      ),
      child: Column(
        children: [
          ghb(44.w),
          CustomButton(
            onPressed: () {
              Get.back();
            },
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 15.w),
              child: Image.asset(width: 18.w, height: 18.w, assetsName('support/icon_left')),
            ),
          ),
          ghb(44),

          Container(
            width: 375.w - 12.w * 2,
            height: 122.w,
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getSimpleText('创业支持', 36, Colors.white, isBold: true),
                ghb(15),
                getSimpleText('助力发展 携手前行', 18, Colors.white, isBold: true),
              ],
            ),
          )
          // centClm(crossAxisAlignment: CrossAxisAlignment.start, [
          //   getSimpleText('创业支持', 36, Colors.white, isBold: true),
          //   getSimpleText('助力发展 携手前行', 18, Colors.white, isBold: true),
          // ])
        ],
      ),
    );
  }

  // body区域

  Widget supportContainer() {
    return GetBuilder<SupportController>(
      builder: (_) {
        return Container(
            width: 375.w,
            padding: EdgeInsets.only(top: controller.supportData.isNotEmpty ? 15.w : 120.w + 15.w),
            child: Column(
                children: List.generate(controller.supportData.length, (index) {
              Map data = controller.supportData[index] ?? {};
              return supportItem(data, index);
            })));
      },
    );
  }

  Widget supportItem(item, int current) {
    return Container(
      width: 375.w - 15.w * 2,
      height: 120.w,
      margin: EdgeInsets.only(bottom: 15.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.w), color: Colors.white),
      child: Column(
        children: [
          Container(
            width: 375.w - 15.w * 2,
            height: 45.w,
            padding: EdgeInsets.only(left: 15.w),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                gradient: LinearGradient(colors: [
                  Color(0xFFFFEBE0),
                  Color(0xFFFFFFFF),
                ])),
            child: Row(
              children: [
                Image.asset(
                  width: 16.w,
                  height: 16.w,
                  assetsName('support/icon_gift'),
                  fit: BoxFit.fill,
                ),
                gwb(12.5),
                getSimpleText("${item['supportName']}", 16, const Color(0xFF333333)),
                item['isStageable']
                    ? Container(
                        padding: EdgeInsets.fromLTRB(5.w, 3.w, 5.w, 3.w),
                        margin: EdgeInsets.only(left: 7.w),
                        decoration: BoxDecoration(
                          color: const Color(0x10FE4D3B),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: getSimpleText('可分期', 12, const Color(0xFFFE4D3B)),
                      )
                    : gwb(0),
                (item['isStageable'] && item['maxPeriods'] > 0)
                    ? Container(
                        padding: EdgeInsets.fromLTRB(5.w, 3.w, 5.w, 3.w),
                        margin: EdgeInsets.only(left: 7.w),
                        decoration: BoxDecoration(
                          color: const Color(0x10FE4D3B),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: getSimpleText("最多${item['maxPeriods']}期", 12, const Color(0xFFFE4D3B)),
                      )
                    : gwb(0)
              ],
            ),
          ),
          Container(
            width: 345.w,
            // height: 75.w,
            padding: EdgeInsets.all(15.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [getSimpleText("${item['maxAmount']}", 18, const Color(0xFF333333), isBold: true), getSimpleText('最大额度(元)', 12, const Color(0xFF999999))],
                ),
                Column(
                  children: [getSimpleText("> ${item['monthlyShare']}", 18, const Color(0xFF333333), isBold: true), getSimpleText('月分润', 12, const Color(0xFF999999))],
                ),
                CustomButton(
                  onPressed: () {
                    controller.currentIndex = current;
                    ShowToast.normal("您还未获得申请资格");
                    supportPopupSheet(Global.navigatorKey.currentContext!);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 70.w,
                    height: 30.w,
                    decoration: BoxDecoration(color: const Color(0xFFFF3A3A), borderRadius: BorderRadius.circular(30.w / 2)),
                    child: getSimpleText('去申请', 14, Colors.white, isBold: true),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  supportPopupSheet(BuildContext context) {
    Get.bottomSheet(Container(
      width: 375.w,
      height: 300.w,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16.w), topRight: Radius.circular(16.w)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 375.w - 15.w * 2,
            height: 50.w - 15.w,
            child: Stack(
              children: [
                Center(
                  child: getSimpleText('选择分期', 16, const Color(0xFF333333), isBold: true),
                ),
                Positioned(
                    right: 0,
                    top: 10.w,
                    child: CustomButton(
                      onPressed: () {
                        controller.stagCurrentIndex = 0;
                        Get.back();
                      },
                      child: Image.asset(
                        width: 12.w,
                        height: 12.w,
                        assetsName('support/icon_close'),
                        fit: BoxFit.fill,
                      ),
                    ))
              ],
            ),
          ),
          Container(
            width: 375.w - 15.w * 2,
            height: 0.5.w,
            color: const Color(0xFFEEEEEE),
          ),
          ghb(20.w),
          Column(
            children: [
              getContentText('选择您想要的分期套餐，审核达标后客服会与您联系，请保持电 话畅通并耐心等待。', 12, const Color(0xFF333333), 345.w, 32.5.w, 2),
              ghb(26.5),
              SizedBox(
                width: 375.w,
                height: 90.w,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.supportData[controller.currentIndex]['maxPeriods'] ?? 0,
                    itemBuilder: (context, index) {
                      return CustomButton(
                        onPressed: () {
                          controller.stagCurrentIndex = index;
                        },
                        child: GetX<SupportController>(
                          builder: (_) {
                            return Container(
                              width: 90.w,
                              height: 90.w,
                              margin: EdgeInsets.only(right: 21.5.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                border: Border.all(width: 0.5.w, color: controller.stagCurrentIndex == index ? const Color(0xFFFE4B3B) : const Color(0xFFCCCCCC)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  getSimpleText("${controller.supportData[controller.currentIndex]['periodsList'][index]['periodMonth']}", 24, controller.stagCurrentIndex == index ? const Color(0xFFFE4B3B) : const Color(0xFF333333), isBold: true),
                                  getSimpleText("￥${controller.supportData[controller.currentIndex]['periodsList'][index]['periodMoney']}/期", 12, controller.stagCurrentIndex == index ? const Color(0xFFFE4B3B) : const Color(0xFF333333)),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }),
              )
            ],
          ),
          ghb(15.w),
          CustomButton(
            onPressed: () {
              ShowToast.success("${controller.currentIndex}-${controller.stagCurrentIndex}");
            },
            child: Container(
              width: 345.w,
              height: 45.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFFFD573B),
                    Color(0xFFFF3A3A),
                  ]),
                  borderRadius: BorderRadius.circular(45.w / 2)),
              child: getSimpleText('确定', 16, Colors.white),
            ),
          )
        ],
      ),
    ));
  }
}
