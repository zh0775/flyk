// 奖励金领取明细记录
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class RedPacketDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RedPacketDetailController>(RedPacketDetailController());
  }
}

class RedPacketDetailController extends GetxController {
  bool topAnimation = false; // top动画

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _topCurrentIndex = 0.obs;
  int get topCurrentIndex => _topCurrentIndex.value;

  set topCurrentIndex(v) {
    if (!topAnimation) {
      _topCurrentIndex.value = v;
      getRedPacketDetailData(topCurrentIndex);
      toChangePage(topCurrentIndex);
      // 动画发生变化 切换数据和页面
    }
  }

  double listViewHeight = 0;

  // 已领取选择时间
  final _hasSelectDate = "".obs;
  String get hasSelectDate => _hasSelectDate.value;
  set hasSelectDate(v) => _hasSelectDate.value = v;

  // 已失效领取时间
  final _hasBeenSelectDate = "".obs;
  String get hasBeenSelectDate => _hasBeenSelectDate.value;
  set hasBeenSelectDate(v) => _hasBeenSelectDate.value = v;

  DateFormat dateFormat = DateFormat("yyyy年MM月");
  // late PageController pageCtrl;
  final PageController pageCtrl = PageController();

  String hasRedPacketDetailId = "hasRedPacketDetailId";
  String hasNotRedPacketDetailId = "hasNotRedPacketDetailId";

  List redPacketDetailData = [
    {
      "title": "已领取",
      "pageNum": 1,
      "pageSize": 10,
      "data": [
        // {"id": 1, "title": "红包领取", "time": "2022-09-17 15:56:11", "money": "0.5"},
        // {"id": 2, "title": "红包领取", "time": "2022-09-17 15:56:11", "money": "0.5"}
      ]
    },
    {
      "title": "已失效",
      "pageNum": 1,
      "pageSize": 10,
      "data": [
        // {"id": 1, "title": "红包领取失效", "time": "2022-09-17 15:56:22", "money": "0.5"},
        // {"id": 2, "title": "红包领取失效", "time": "2022-09-17 15:56:22", "money": "0.5"},
        // {"id": 3, "title": "红包领取失效", "time": "2022-09-17 15:56:22", "money": "0.5"},
      ]
    }
  ];

  toChangePage(index) {
    topAnimation = true;
    pageCtrl.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.linear).then((value) {
      topAnimation = false;
    });
  }

  getRedPacketDetailData(int topIndex, {bool isLoad = false}) {
    isLoad ? redPacketDetailData[topIndex]['pageNum']++ : redPacketDetailData[topIndex]['pageNum'] = 1;

    if (redPacketDetailData[topIndex]['data'].isEmpty) {
      isLoading = true;
    }

    Http().doPost('https://mock.apifox.cn/m1/2153127-0-default/api/redpacket/detail', {"type": topIndex, "pageNum": redPacketDetailData[topIndex]['pageNum'], "pageSize": 10, "time": topCurrentIndex == 0 ? hasSelectDate : hasBeenSelectDate}, success: (json) {
      if (json['success']) {
        Map data = json['data'] ?? {};
        redPacketDetailData[topIndex]['total'] = data['total'] ?? 0;
        if (redPacketDetailData[topIndex]['data'].length <= redPacketDetailData[topIndex]['total']) {
          List newData = data['rows'] ?? [];
          redPacketDetailData[topIndex]['data'] = isLoad ? [...redPacketDetailData[topIndex]['data'], ...newData] : newData;
        }

        update([topIndex == 0 ? hasRedPacketDetailId : hasNotRedPacketDetailId]);
      }
    }, after: () {
      isLoading = false;
    });
  }

  @override
  void onInit() async {
    hasSelectDate = dateFormat.format(DateTime.now());
    hasBeenSelectDate = dateFormat.format(DateTime.now());

    getRedPacketDetailData(0);
    super.onInit();
  }
}

class RedPacketDetailPage extends GetView<RedPacketDetailController> {
  const RedPacketDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return GetBuilder<RedPacketDetailController>(
    //   init: RedPacketDetailController(),
    //   initState: (_) {},
    //   builder: (_) {
    //     return Scaffold(
    //         appBar: getDefaultAppBar(context, '领取明细'),
    //         body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
    //           // 获取屏幕高度
    //           double screenHeight = MediaQuery.of(context).size.height;
    //           // 计算出AppBar和底部导航栏的高度
    //           double appBarHeight = AppBar().preferredSize.height;
    //           double bottomNavBarHeight = kBottomNavigationBarHeight;
    //           double listViewHeight = screenHeight - appBarHeight - bottomNavBarHeight - 70.w;
    //           controller.listViewHeight = listViewHeight;

    //           return Stack(
    //             children: [
    //               // topBar
    //               Positioned(
    //                 top: 0,
    //                 left: 0,
    //                 right: 0,
    //                 height: 51.w,
    //                 child: topBar(),
    //               ),

    //               Positioned(
    //                 top: 51.w,
    //                 left: 0,
    //                 right: 0,
    //                 bottom: 0,
    //                 child: containerPageView(),
    //               ),
    //             ],
    //           );
    //         }));
    //   },
    // );

    return Scaffold(
        appBar: getDefaultAppBar(context, '领取明细'),
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          // 获取屏幕高度
          double screenHeight = MediaQuery.of(context).size.height;
          // 计算出AppBar和底部导航栏的高度
          double appBarHeight = AppBar().preferredSize.height;
          double bottomNavBarHeight = kBottomNavigationBarHeight;
          double listViewHeight = screenHeight - appBarHeight - bottomNavBarHeight - 70.w;
          controller.listViewHeight = listViewHeight;

          return Stack(
            children: [
              // topBar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 51.w,
                child: topBar(),
              ),

              Positioned(
                top: 51.w,
                left: 0,
                right: 0,
                bottom: 0,
                child: containerPageView(),
              ),
            ],
          );
        }));
  }

  Widget topBar() {
    return Container(
      width: 375.w,
      height: 51.w,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
          children: ["已领取", "已失效"]
              .asMap()
              .entries
              .map(
                (item) => CustomButton(
                  onPressed: () {
                    controller.topCurrentIndex = item.key;
                    // 切换 显示第一页数据
                    controller.getRedPacketDetailData(item.key);
                  },
                  child: GetX<RedPacketDetailController>(
                    init: RedPacketDetailController(),
                    initState: (_) {},
                    builder: (_) {
                      return SizedBox(
                        width: (375 / 2).w,
                        height: 55.w,
                        child: centClm([
                          // ghb(13),
                          getSimpleText(item.value, 16, const Color(0xFF333333)),
                          // ghb(14),
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
                ),
              )
              .toList()),
      // child: GetBuilder<RedPacketDetailController>(
      //   init: RedPacketDetailController(),
      //   initState: (_) {},
      //   builder: (_) {
      //     return Row(
      //         children: ["已领取", "已失效"]
      //             .asMap()
      //             .entries
      //             .map(
      //               (item) => CustomButton(
      //                 onPressed: () {
      //                   controller.topCurrentIndex = item.key;
      //                   // 切换 显示第一页数据
      //                   controller.getRedPacketDetailData(item.key);
      //                 },
      //                 child: GetX<RedPacketDetailController>(
      //                   init: RedPacketDetailController(),
      //                   initState: (_) {},
      //                   builder: (_) {
      //                     return SizedBox(
      //                       width: (375 / 2).w,
      //                       height: 55.w,
      //                       child: centClm([
      //                         // ghb(13),
      //                         getSimpleText(item.value, 16, const Color(0xFF333333)),
      //                         // ghb(14),
      //                         ghb(controller.topCurrentIndex == item.key ? 5 : 0),
      //                         controller.topCurrentIndex != item.key
      //                             ? gwb(0)
      //                             : Container(
      //                                 width: 15.w,
      //                                 height: 2.w,
      //                                 decoration: BoxDecoration(color: const Color(0xFFFE4B3B), borderRadius: BorderRadius.circular(0.5.w)),
      //                               )
      //                       ]),
      //                     );
      //                   },
      //                 ),
      //               ),
      //             )
      //             .toList());
      //   },
      // ),
    );
  }

  // 已领取、已失效 通用pageview
  Widget containerPageView() {
    return PageView(
      physics: const BouncingScrollPhysics(),
      controller: controller.pageCtrl,
      onPageChanged: (value) {
        controller.topCurrentIndex = value;
      },
      children: [containerPage(0), containerPage(1)],
    );
  }

  Widget containerPage(int currentIndex) {
    // return Column(
    //   children: [
    //     GetX<RedPacketDetailController>(
    //       init: RedPacketDetailController(),
    //       initState: (_) {},
    //       builder: (_) {
    //         return Column(
    //           children: [
    //             Container(
    //               width: 375.w,
    //               height: 45.w,
    //               padding: EdgeInsets.only(left: 11.w),
    //               child: CustomButton(
    //                 onPressed: () {
    //                   showDatePick(controller.topCurrentIndex);
    //                 },
    //                 child: Row(
    //                   children: [
    //                     getSimpleText(controller.topCurrentIndex == 0 ? controller.hasSelectDate : controller.hasBeenSelectDate, 12, Color(0xFF333333)),
    //                     Image(
    //                       width: 10.w,
    //                       height: 10.w,
    //                       image: AssetImage(
    //                         assetsName('ranking/red_arrow_down'),
    //                       ),
    //                       fit: BoxFit.fill,
    //                     )
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             SizedBox(
    //               width: 375.w,
    //               height: controller.listViewHeight,
    //               child: ListView.builder(
    //                   physics: const BouncingScrollPhysics(),
    //                   itemCount: 10,
    //                   itemBuilder: (context, index) {
    //                     return redPacketDetailItem();
    //                   }),
    //             )
    //           ],
    //         );
    //       },
    //     ),
    //   ],
    // );

    return GetBuilder<RedPacketDetailController>(
      id: currentIndex == 0 ? controller.hasRedPacketDetailId : controller.hasNotRedPacketDetailId,
      builder: (_) {
        if (controller.redPacketDetailData[currentIndex]['data'].isEmpty) {
          return SingleChildScrollView(
            child: Center(
              child: CustomEmptyView(isLoading: controller.isLoading, bottomSpace: 200.w),
            ),
          );
        } else {
          return Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 45.w,
                  child: Container(
                    width: 375.w,
                    height: 45.w,
                    padding: EdgeInsets.only(left: 11.w),
                    child: CustomButton(
                      onPressed: () {
                        showDatePick(controller.topCurrentIndex);
                      },
                      child: Row(
                        children: [
                          getSimpleText(controller.topCurrentIndex == 0 ? controller.hasSelectDate : controller.hasBeenSelectDate, 12, const Color(0xFF333333)),
                          Image(
                            width: 10.w,
                            height: 10.w,
                            image: AssetImage(
                              assetsName('ranking/red_arrow_down'),
                            ),
                            fit: BoxFit.fill,
                          )
                        ],
                      ),
                    ),
                  )),
              Positioned(
                  top: 45.w,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: EasyRefresh.builder(
                      onLoad: (controller.redPacketDetailData[currentIndex]['data'] ?? []).length >= (controller.redPacketDetailData[currentIndex]['total'] ?? 0)
                          ? null
                          : () {
                              controller.getRedPacketDetailData(currentIndex, isLoad: true);
                            },
                      childBuilder: (context, physics) {
                        return ListView.builder(
                            // physics: const BouncingScrollPhysics(),
                            physics: physics,
                            padding: EdgeInsets.only(bottom: 20.w),
                            itemCount: controller.redPacketDetailData[currentIndex]['data'].length,
                            itemBuilder: (context, index) {
                              return redPacketDetailItem(controller.redPacketDetailData[currentIndex]['data'][index]);
                              // if (controller.redPacketDetailData[currentIndex]['data'].isEmpty) {
                              //   return SingleChildScrollView(
                              //     physics: physics,
                              //     child: Center(
                              //       child: CustomEmptyView(isLoading: controller.isLoading, bottomSpace: 200.w),
                              //     ),
                              //   );
                              // } else {
                              //   return redPacketDetailItem(controller.redPacketDetailData[currentIndex]['data'][index]);
                              // }
                            });
                      })
                  //  GetBuilder<RedPacketDetailController>(
                  //   // id: currentIndex == 0 ? controller.hasRedPacketDetailId : controller.hasNotRedPacketDetailId,
                  //   builder: (_) {

                  //   },
                  // ),
                  )

              // GetX<RedPacketDetailController>(
              //   init: RedPacketDetailController(),
              //   initState: (_) {},
              //   builder: (_) {
              //     return Column(
              //       children: [
              //         Container(
              //           width: 375.w,
              //           height: 45.w,
              //           padding: EdgeInsets.only(left: 11.w),
              //           child: CustomButton(
              //             onPressed: () {
              //               showDatePick(controller.topCurrentIndex);
              //             },
              //             child: Row(
              //               children: [
              //                 getSimpleText(controller.topCurrentIndex == 0 ? controller.hasSelectDate : controller.hasBeenSelectDate, 12, Color(0xFF333333)),
              //                 Image(
              //                   width: 10.w,
              //                   height: 10.w,
              //                   image: AssetImage(
              //                     assetsName('ranking/red_arrow_down'),
              //                   ),
              //                   fit: BoxFit.fill,
              //                 )
              //               ],
              //             ),
              //           ),
              //         ),
              //         ListView.builder(
              //             physics: const BouncingScrollPhysics(),
              //             itemCount: 10,
              //             itemBuilder: (context, index) {
              //               return redPacketDetailItem();
              //             }),
              //       ],
              //     );
              //   },
              // ),
            ],
          );
        }
      },
    );
  }

  Widget redPacketDetailItem(item) {
    return Container(
      width: 375.w,
      height: 75.w,
      color: Colors.white,
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getSimpleText("${item['title']}", 15, const Color(0xFF333333)),
              getSimpleText('+0.5', 18, const Color(0xFF333333)),
            ],
          ),
          ghb(5),
          SizedBox(width: 375.w, child: getSimpleText('2022-09-17 15:56:44', 12, const Color(0xFF999999)))
        ],
      ),
    );
  }

  showDatePick(int index) async {
    DateTime now = DateTime.now();
    DateTime? selectDate = await showMonthPicker(
        context: Global.navigatorKey.currentContext!,
        // initialEntryMode: DatePickerEntryMode.calendar,
        initialDate: controller.dateFormat.parse(controller.hasSelectDate),
        firstDate: DateTime(now.year - 5, now.month),
        lastDate: DateTime.now(),
        cancelWidget: getSimpleText("取消", 15, AppColor.theme),
        confirmWidget: getSimpleText("确认", 15, AppColor.theme));
    if (selectDate != null) {
      String selectDateStr = controller.dateFormat.format(selectDate);
      index == 0 ? controller.hasSelectDate = selectDateStr : controller.hasBeenSelectDate = selectDateStr;
    }
  }
}
