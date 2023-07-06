// 红包兑换 ==》 排行榜页面

import 'dart:async';

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/ranking/red_packet_receive_history.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class RankListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RankListController>(RankListController());
  }
}

class RankListController extends GetxController {
  // 获取图片路径
  String imageUrl = AppDefault().imageUrl;

  // 获取AppDeafult
  List noticeList = [];

  // 红包获取规则
  String redPackageRuleHtml = "";
  // 今日是否可领取红包
  // final _userTodayReceiveStatus = 1.obs;
  final _userTodayReceiveStatus = 0.obs;
  int get userTodayReceiveStatus => _userTodayReceiveStatus.value;
  set userTodayReceiveStatus(v) => _userTodayReceiveStatus.value = v;

  // 今日可领取金额
  double userTodayReceiveMoney = 0.0;
  // 剩余领取红包的金额
  double userNotReceiveMoney = 0.0;
  // 今日领到的金额
  double userTodayHasReceiveMoney = 0.0;

  // 兑换排行榜
  List receiveRankTopList = [];

  // toDayNotReceive

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
        return redPacketPopupView();
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

  // 获取红包兑换top10
  getRedPackageApi() {
    simpleRequest(
        url: Urls.userInvestOrder,
        params: {},
        success: (success, json) {
          if (success) {
            Map jsonData = json['data'] ?? {};
            noticeList = jsonData['upData'] ?? [];
            redPackageRuleHtml = jsonData['invsetDesc'] ?? '';
            userTodayReceiveStatus = jsonData['toDayNotReceiveFlag'] ?? 0;
            userTodayReceiveMoney = double.parse(jsonData['toDayNotReceive'] ?? '0.0');
            userNotReceiveMoney = double.parse(jsonData['notReceive'] ?? '0.0');
            receiveRankTopList = jsonData['top10'] ?? [];
            update();
          }
        },
        after: () {});
  }

  // 立即领取红包
  userReceiveRedPackageApi(Widget Function() fn) {
    simpleRequest(
        url: Urls.userReceiveHongbao,
        params: {},
        success: (success, json) {
          if (success) {
            // 今日领取金额
            userTodayHasReceiveMoney = double.parse(json['value'] ?? '0.0');
            userTodayReceiveStatus = 0;
            // userTodayReceiveStatus = 1;
            handleRedPacketPopup(fn);
            update();
          }
        },
        after: () {});
  }

  @override
  void onInit() {
    getRedPackageApi();
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
            push(const RedPacketReceiveHistory(), context, binding: RedPacketReceiveHistoryBinding());
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
      width: 375.w,
      height: 430.w,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(assetsName('ranking/draw_bg')), fit: BoxFit.fill),
      ),
      child: GetBuilder<RankListController>(
        builder: (_) {
          return Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    ghb(95.w),
                    Container(
                      width: 215.w,
                      height: 30.w,
                      decoration: BoxDecoration(color: const Color(0x50000000), borderRadius: BorderRadius.circular(15.w)),
                      child: Row(children: [
                        gwb(11.w),
                        Image(width: 18.w, height: 18.w, image: AssetImage(assetsName('ranking/icon_notice'))),
                        gwb(16.w),
                        SizedBox(
                            width: 150.w,
                            height: 30.w,
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: controller.noticeList.length,
                                controller: controller._scrollController,
                                itemExtent: 30.w,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  Map noticeItem = controller.noticeList[index] ?? {};
                                  return Text.rich(TextSpan(
                                      text: "${noticeItem['u_Name']}已领取奖励金",
                                      style: TextStyle(height: 2.w, color: Colors.white, fontSize: 12.w),
                                      children: [
                                        TextSpan(
                                            text: noticeItem['receiveAmount'].toStringAsFixed(2), style: const TextStyle(color: Color(0xFFFFF53E))),
                                        const TextSpan(text: ' 元')
                                      ]));
                                }))
                      ]),
                    ),
                    ghb(45.5),
                    getSimpleText('今日可领取金额', 12, const Color(0xFFFE4F3B)),
                    ghb(6.w),
                    SizedBox(
                      child: Text.rich(
                        TextSpan(
                            text: "${controller.userTodayReceiveMoney}",
                            style: TextStyle(color: const Color(0xFFFE4F3B), fontSize: 45.w, fontWeight: FontWeight.w500),
                            children: [
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
                            children: [
                              TextSpan(text: "${controller.userNotReceiveMoney}", style: const TextStyle(color: Color(0xFFFFF53E))),
                              const TextSpan(text: ' 元'),
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
                        // image: AssetImage(assetsName(controller.userTodayReceiveStatus == 0 ? 'ranking/claim_btn' : 'ranking/ban_btn')),
                        image: AssetImage(assetsName(controller.userTodayReceiveStatus == 1 ? 'ranking/claim_btn' : 'ranking/ban_btn')),
                      )),
                      child: getSimpleButton(() {
                        // if (controller.userTodayReceiveStatus == 0) {
                        if (controller.userTodayReceiveStatus == 1) {
                          // 请求接口
                          controller.userReceiveRedPackageApi(redPacketPopupView);
                        } else {
                          ShowToast.normal("今日已领取");
                        }
                        // controller.handleRedPacketPopup(redPacketPopupView());
                      },
                          getSimpleText(controller.userTodayReceiveStatus == 1 ? "立即领取" : "今日已领取", 18,
                              controller.userTodayReceiveStatus == 1 ? const Color(0xFFFE4F3B) : Colors.white)),
                      // getSimpleText(controller.userTodayReceiveStatus == 0 ? "立即领取" : "今日已领取", 18,
                      //     controller.userTodayReceiveStatus == 0 ? const Color(0xFFFE4F3B) : Colors.white)),
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
          );
        },
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
              child: getSimpleText('兑换排行榜', 18, Colors.white, isBold: true, textHeight: 0.5),
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
              GetBuilder<RankListController>(
                builder: (_) {
                  return controller.receiveRankTopList.isEmpty
                      ? ghb(0)
                      : Column(
                          children: List.generate(controller.receiveRankTopList.length, (index) {
                          Map rankItem = controller.receiveRankTopList[index] ?? {};
                          return Container(
                            width: 370.w - 15.w * 2,
                            padding: EdgeInsets.fromLTRB(16.w, 25.w, 12.w, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                index < 3
                                    ? Image.asset(
                                        width: 22.w,
                                        height: 22.w,
                                        assetsName("ranking/top${rankItem['num']}"),
                                        fit: BoxFit.fitWidth,
                                      )
                                    : Container(
                                        width: 22.w,
                                        height: 22.w,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22.w / 2), color: const Color(0xFFF9C529)),
                                        child: getSimpleText("${rankItem['num']}", 12.w, Colors.white, textAlign: TextAlign.center, textHeight: 1.5),
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
                                      getSimpleText("${rankItem['u_Name']}(${rankItem['user_ID']})", 14, const Color(0xFF333333)),
                                    ],
                                  ),
                                ),

                                getSimpleText("${rankItem['receiveCount']}", 14, const Color(0xFF333333)),
                                // getSimpleText('排名', 12, Color(0xFF999999)),
                                // getSimpleText('用户', 12, Color(0xFF999999)),
                                // getSimpleText('交易笔数', 12, Color(0xFF999999)),
                              ],
                            ),
                          );
                        }));
                },
              ),
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
                  SizedBox(
                    width: 280.w - (23.5.w * 2),
                    height: 225.w,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsetsDirectional.zero,
                      children: [
                        HtmlWidget(
                          controller.redPackageRuleHtml,
                        ),
                      ],
                    ),
                  ),
                  ghb(15),
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
              child: GetBuilder<RankListController>(
                builder: (_) {
                  return Column(
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
                          text: "${controller.userTodayHasReceiveMoney}",
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
                  );
                },
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
