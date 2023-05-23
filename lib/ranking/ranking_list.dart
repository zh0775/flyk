// 红包兑换 ==》 排行榜页面

import 'dart:async';

import 'package:cxhighversion2/ranking/red_packet_record.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class RankListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RankListController>(RankListController());
  }
}

class RankListController extends GetxController {
  List noticeList = [
    {'title': '钟*辉1', 'money': 0.1},
    {'title': '钟*辉2', 'money': 0.2},
    {'title': '钟*辉3', 'money': 0.3},
    {'title': '钟*辉4', 'money': 0.4},
  ];

  Timer? noticeTimer;
  final ScrollController _scrollController = ScrollController();
  // 规则事件
  handleRulePopup(rulePopupView) {
    showGeneralDialog(
      barrierDismissible: false,
      context: Global.navigatorKey.currentContext!,
      pageBuilder: (context, animation, secondaryAnimation) {
        return rulePopupView;
      },
    );
  }

  // 红包领取事件
  handleRedPacketPopup(redPacketPopupView) {
    showGeneralDialog(
      barrierDismissible: false,
      context: Global.navigatorKey.currentContext!,
      pageBuilder: (context, animation, secondaryAnimation) {
        return redPacketPopupView;
      },
    );
  }

  // noticeBar
  startNoticeBar() {
    noticeTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_scrollController.positions.isNotEmpty) {
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        double pixels = _scrollController.position.pixels;

        if (maxScrollExtent == pixels) {
          noticeList = [...noticeList, ...noticeList];
          update();
        }
        _scrollController.animateTo(pixels + 30.w, duration: const Duration(milliseconds: 500), curve: Curves.linear);
      }
    });
  }

  @override
  void onInit() {
    startNoticeBar();
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

class RankListPage extends GetView<RankListController> {
  const RankListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, '红包兑换', action: [
        CustomButton(
          onPressed: () {
            push(const RedPacketRecordPage(), context, binding: RedPacketRecordBinding());
          },
          child: SizedBox(
            height: kToolbarHeight,
            width: 80.w,
            child: Center(
              child: getSimpleText("领取记录", 14, AppColor.textBlack),
            ),
          ),
        )
      ]),
      body: SingleChildScrollView(
        child: Column(
          children: [drawContainer(), rankListContainer()],
        ),
      ),
    );
  }

  Widget drawContainer() {
    return Container(
      // alignment: Alignment.center,
      width: 375.w,
      height: 430.w,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
              assetsName('ranking/draw_bg'),
            ),
            fit: BoxFit.fill),
      ),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                ghb(95.w),
                Container(
                  width: 215.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: const Color(0x50000000),
                    borderRadius: BorderRadius.circular(15.w),
                  ),
                  child: Row(
                    children: [
                      gwb(11.w),
                      Image(
                        width: 18.w,
                        height: 18.w,
                        image: AssetImage(
                          assetsName('ranking/icon_notice'),
                        ),
                      ),
                      gwb(16.w),
                      GetBuilder<RankListController>(
                        init: RankListController(),
                        initState: (_) {},
                        builder: (_) {
                          return SizedBox(
                              width: 150.w,
                              height: 30.w,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: controller.noticeList.length,
                                  controller: controller._scrollController,
                                  itemExtent: 30.w,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Text.rich(
                                      TextSpan(
                                          text: "${controller.noticeList[index]['title']}已领取奖励金",
                                          style: TextStyle(
                                            height: 2.w,
                                            color: Colors.white,
                                            fontSize: 12.w,
                                          ),
                                          children: const [
                                            TextSpan(text: '0.5', style: TextStyle(color: Color(0xFFFFF53E))),
                                            TextSpan(text: ' 元'),
                                          ]),
                                    );
                                  }));
                        },
                      )
                    ],
                  ),
                ),
                ghb(45.5),
                getSimpleText('今日可领取金额', 12, const Color(0xFFFE4F3B)),
                ghb(6.w),
                SizedBox(
                  child: Text.rich(
                    TextSpan(text: '0.5', style: TextStyle(color: const Color(0xFFFE4F3B), fontSize: 45.w, fontWeight: FontWeight.w500), children: [
                      TextSpan(text: '元', style: TextStyle(fontSize: 18.w)),
                    ]),
                  ),
                ),
                ghb(40),
                SizedBox(
                  child: Text.rich(
                    TextSpan(
                        text: '剩余领取红包金额:',
                        style: TextStyle(
                          height: 1.w,
                          color: Colors.white,
                          fontSize: 18.w,
                        ),
                        children: const [
                          TextSpan(text: '428.00', style: TextStyle(color: Color(0xFFFFF53E))),
                          TextSpan(text: ' 元'),
                        ]),
                  ),
                ),
                ghb(14.5),
                Container(
                  width: 225.5.w,
                  height: 51.5.w,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(assetsName('ranking/claim_btn')),
                  )),
                  child: getSimpleButton(() {
                    controller.handleRedPacketPopup(redPacketPopupView());
                  }, getSimpleText('立即领取', 18, const Color(0xFFFE4F3B))),
                )
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 47.w,
            child: CustomButton(
              onPressed: () {
                controller.handleRulePopup(rulePopupView());
              },
              child: Container(
                  width: 25.w,
                  height: 60.w,
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                      color: const Color(0x50000000),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.w),
                        bottomLeft: Radius.circular(8.w),
                      )),
                  child: Text(
                    '规 则',
                    style: TextStyle(color: Colors.white, fontSize: 14.w),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget rankListContainer() {
    return Container(
      width: 375.w,
      height: 682.w,
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 15.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF226EFF),
            Color(0xFFB7DEFD),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 370.w - 15.w * 2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Column(
              children: const [],
            ),
          ),
          Positioned(
            top: -2,
            child: Container(
              alignment: Alignment.center,
              width: 165.5.w,
              height: 47.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      assetsName('ranking/exchange_btn'),
                    ),
                    fit: BoxFit.fill),
              ),
              child: getSimpleText('兑换排行榜', 18, Colors.white, isBold: true, textHeight: 1.0),
            ),
          ),
          Column(
            children: [
              ghb(62),
              Container(
                width: 370.w - 15.w * 2,
                height: 40.w,
                padding: EdgeInsets.fromLTRB(16.w, 0, 12.w, 0),
                color: const Color(0xFFFAFAFA),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getSimpleText('排名', 12, const Color(0xFF999999)),
                    gwb(37),
                    Expanded(
                      flex: 2,
                      child: getSimpleText('用户', 12, const Color(0xFF999999)),
                    ),
                    getSimpleText('交易笔数', 12, const Color(0xFF999999)),
                  ],
                ),
              ),
              Column(
                  children: List.generate(10, (index) {
                return Container(
                  width: 370.w - 15.w * 2,
                  padding: EdgeInsets.fromLTRB(16.w, 25.w, 12.w, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        width: 22.w,
                        height: 22.w,
                        assetsName('ranking/top1'),
                        fit: BoxFit.fitWidth,
                      ),
                      gwb(37),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30.w / 2),
                              child: Image.asset(
                                width: 30.w,
                                height: 30.w,
                                fit: BoxFit.fill,
                                assetsName('mine/default_head'),
                              ),
                            ),
                            getSimpleText('李**(158****3218) ', 14, const Color(0xFF333333)),
                          ],
                        ),
                      ),

                      getSimpleText('126 ', 14, const Color(0xFF333333)),
                      // getSimpleText('排名', 12, Color(0xFF999999)),
                      // getSimpleText('用户', 12, Color(0xFF999999)),
                      // getSimpleText('交易笔数', 12, Color(0xFF999999)),
                    ],
                  ),
                );
              })),
            ],
          )
        ],
      ),
    );
  }

  // 规则弹框view层
  Widget rulePopupView() {
    return UnconstrainedBox(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              alignment: Alignment.topCenter,
              width: 280.w,
              height: 50.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    assetsName('ranking/rule'),
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Text(
                '红包获取规则',
                style: TextStyle(
                  color: const Color(0xFFFE4F3B),
                  fontSize: 14.w,
                ),
              ),
            ),
            Container(
              width: 280.w,
              height: 300.w,
              padding: EdgeInsets.only(left: 23.5.w, right: 23.5.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEE),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8.w), bottomRight: Radius.circular(8.w)),
              ),
              child: Column(
                children: [
                  const HtmlWidget(
                    "<p>1、积分兑换红包为单次500积分的整数倍起兑</p><p>2、每次兑换红包分为1000份，每日可领取一份</p><p>3、1积分＝1元红包</p><p>4、领取后到账余额钱包</p>",
                  ),
                  ghb(30),
                  CustomButton(
                    onPressed: () {
                      Navigator.pop(Global.navigatorKey.currentContext!);
                    },
                    child: Container(
                      width: 220.w,
                      height: 45.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE4F3B),
                        borderRadius: BorderRadius.circular(45.w / 2),
                      ),
                      child: getSimpleText('好的', 18, Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 红包领取弹框
  Widget redPacketPopupView() {
    return UnconstrainedBox(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              width: 375.w,
              height: 356.5.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    assetsName('ranking/red_packet'),
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 90.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFE4F3B),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.w),
                          bottomRight: Radius.circular(8.w),
                        )),
                    child: Text(
                      '领取成功',
                      style: TextStyle(color: Colors.white, fontSize: 18.w),
                    ),
                  ),
                  ghb(31),
                  getSimpleText('恭喜您获得', 18, const Color(0xFFFE4F3B)),
                  ghb(10),
                  Text.rich(
                    TextSpan(
                      text: '0.5',
                      style: TextStyle(
                        color: const Color(0xFFFE4F3B),
                        fontSize: 45.w,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: ' 元',
                          style: TextStyle(
                            fontSize: 18.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ghb(100),
                  Container(
                    width: 225.5.w,
                    height: 51.5.w,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          assetsName('ranking/claim_btn'),
                        ),
                      ),
                    ),
                    child: getSimpleButton(() {
                      Navigator.pop(Global.navigatorKey.currentContext!);
                    }, getSimpleText('我知道了', 18, const Color(0xFFFE4F3B))),
                  ),
                  ghb(16),
                  getSimpleText('请记得明天再来领取哦~', 12, const Color(0x66FFFFFF)),
                ],
              ),
            ),
            ghb(31),
            GestureDetector(
              onTap: () {
                Navigator.pop(Global.navigatorKey.currentContext!);
              },
              child: Image.asset(
                assetsName('ranking/close_btn'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
