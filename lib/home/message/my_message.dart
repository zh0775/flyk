import 'dart:convert' as convert;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_webview.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/storage_default.dart';
import 'package:cxhighversion2/util/user_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyMessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyMessageController>(() => MyMessageController());
  }
}

class MyMessageController extends GetxController {
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;
  final _topButtonIndex = 0.obs;

  bool isPageAnimateTo = false;

  set topButtonIndex(value) {
    if (isPageAnimateTo) {
      return;
    }
    isPageAnimateTo = true;
    _topButtonIndex.value = value;
    if (value == 1 && orderPageList.isEmpty) {
      loadList();
    } else if (value == 2 && noticePageList.isEmpty) {
      loadList();
    } else if (value == 3 && earnPageList.isEmpty) {
      loadList();
    }
    pageCtrl
        .animateTo(value * 375.w,
            duration: const Duration(milliseconds: 300), curve: Curves.linear)
        .then((value) {
      isPageAnimateTo = false;
    });
  }

  final Permission _permission = Permission.notification;

  get topButtonIndex => _topButtonIndex.value;

  final _nofityBtnClose = false.obs;
  set nofityBtnClose(value) => _nofityBtnClose.value = value;
  get nofityBtnClose => _nofityBtnClose.value;

  final _earnPageNo = 1.obs;
  set earnPageNo(value) => _earnPageNo.value = value;
  get earnPageNo => _earnPageNo.value;

  final _messagePageNo = 1.obs;
  set messagePageNo(value) => _messagePageNo.value = value;
  get messagePageNo => _messagePageNo.value;

  final _noticePageNo = 1.obs;
  set noticePageNo(value) => _noticePageNo.value = value;
  get noticePageNo => _noticePageNo.value;

  final _orderPageNo = 1.obs;
  set orderPageNo(value) => _orderPageNo.value = value;
  get orderPageNo => _orderPageNo.value;

  final _pageSize = 10.obs;
  set pageSize(value) => _pageSize.value = value;
  get pageSize => _pageSize.value;

  int messageCount = 0;
  int orderCount = 0;
  int noticeCount = 0;
  int earnCount = 0;

  String messageListId = "messageListId";
  String orderListId = "orderListId";
  String noticeListId = "noticeListId";
  String earnListId = "earnListId";

  final pageCtrl = PageController();

  final messageRefreshController = RefreshController();
  final orderRefreshController = RefreshController();
  final noticeRefreshController = RefreshController();
  final earnRefreshController = RefreshController();

  // final _earnPageList = Rx<List>([]);
  // set earnPageList(value) => _earnPageList.value = value;
  // List get earnPageList => _earnPageList.value;
  List earnPageList = [];
  final _messagePageList = Rx<List>([]);
  set messagePageList(value) => _messagePageList.value = value;
  List get messagePageList => _messagePageList.value;

  final _orderPageList = Rx<List>([]);
  set orderPageList(value) => _orderPageList.value = value;
  List get orderPageList => _orderPageList.value;

  final _noticePageList = Rx<List>([]);
  set noticePageList(value) => _noticePageList.value = value;
  List get noticePageList => _noticePageList.value;

  void pageListener() {
    // print("pageCtrl.page == ${pageCtrl.page}");
  }

  loadList({bool isLoad = false}) {
    if (mPageData == null || mPageData.isEmpty) {
      return;
    }
    if ((mPageData.length - 1) < topButtonIndex) {
      return;
    }
    late int pageNo;
    late String buildId;
    late List dataList;
    late RefreshController pullCtrl;
    switch (topButtonIndex) {
      case 0:
        isLoad ? messagePageNo++ : messagePageNo = 1;
        pageNo = messagePageNo;
        buildId = messageListId;
        dataList = messagePageList;
        pullCtrl = messageRefreshController;
        break;
      case 1:
        isLoad ? orderPageNo++ : orderPageNo = 1;
        pageNo = orderPageNo;

        buildId = orderListId;
        dataList = orderPageList;
        pullCtrl = orderRefreshController;
        break;
      case 2:
        isLoad ? noticePageNo++ : noticePageNo = 1;
        pageNo = noticePageNo;

        buildId = noticeListId;
        dataList = noticePageList;
        pullCtrl = noticeRefreshController;
        break;
      case 3:
        isLoad ? earnPageNo++ : earnPageNo = 1;
        pageNo = earnPageNo;

        buildId = earnListId;
        dataList = earnPageList;
        pullCtrl = earnRefreshController;
        break;
      default:
        isLoad ? messagePageNo++ : messagePageNo = 1;
        pageNo = messagePageNo;

        buildId = messageListId;
        dataList = messagePageList;
        pullCtrl = messageRefreshController;
    }

    if (dataList == null || dataList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.myMessage,
      params: {
        "id": mPageData[topButtonIndex]["id"],
        "d_Type": mPageData[topButtonIndex]["friend_Type"],
        "pageSize": pageSize,
        "pageNo": pageNo
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"];

          if (isLoad) {
            switch (topButtonIndex) {
              case 0:
                messageCount = data["count"];
                messagePageList = [...messagePageList, ...data["data"]];
                break;
              case 1:
                orderCount = data["count"];
                orderPageList = [...orderPageList, ...data["data"]];
                break;
              case 2:
                noticeCount = data["count"];
                noticePageList = [...noticePageList, ...data["data"]];
                break;
              case 3:
                earnCount = data["count"];
                earnPageList = [...earnPageList, ...data["data"]];
                break;
              default:
            }
            pullCtrl.loadComplete();
          } else {
            switch (topButtonIndex) {
              case 0:
                messageCount = data["count"];
                messagePageList = data["data"];
                break;
              case 1:
                orderCount = data["count"];
                orderPageList = data["data"];
                break;
              case 2:
                noticeCount = data["count"];
                noticePageList = data["data"];
                break;
              case 3:
                earnCount = data["count"];
                earnPageList = data["data"];
                break;
              default:
            }
            pullCtrl.refreshCompleted();
          }
          update([buildId]);
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  onLoad() async {
    loadList(isLoad: true);
  }

  onRefresh() async {
    loadList();
  }

  Map homeData = {};
  Map publicHomeData = {};

  List mPageData = [];

  @override
  void onInit() async {
    pageCtrl.addListener(pageListener);
    String homeDataStr = await UserDefault.get(HOME_DATA) ?? "";
    homeData = homeDataStr.isNotEmpty ? convert.jsonDecode(homeDataStr) : {};
    String publicHomeDataStr = await UserDefault.get(PUBLIC_HOME_DATA) ?? "";
    publicHomeData = publicHomeDataStr.isNotEmpty
        ? convert.jsonDecode(publicHomeDataStr)
        : {};
    mPageData = homeData['friendLog'] ?? [];
    checkNotifi();
    update();

    // messageOnRefresh();
    loadList();
    // orderOnRefresh();
    // noticeOnRefresh();
    // earnOnRefresh();
    super.onInit();
  }

  @override
  void dispose() {
    pageCtrl.removeListener(pageListener);
    pageCtrl.dispose();
    messageRefreshController.dispose();
    orderRefreshController.dispose();
    noticeRefreshController.dispose();
    earnRefreshController.dispose();
    super.dispose();
  }

  void checkNotifi() async {
    // final status = await _permission.status;
    // nofityBtnClose = (status == PermissionStatus.granted);
    nofityBtnClose = true;
  }
}

class MyMessage extends GetView<MyMessageController> {
  const MyMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
        context, "我的消息",
        // action: [
        //   CustomButton(
        //     onPressed: () {},
        //     child: SizedBox(
        //       width: 70.w,
        //       height: 50,
        //       child: Center(
        //         child: getSimpleText("全部已读", 14, AppColor.textBlack),
        //       ),
        //     ),
        //   ),
        // ]
      ),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50.w,
              child: GetBuilder<MyMessageController>(
                init: controller,
                builder: (_) {
                  return Row(
                    children: controller.mPageData.isEmpty
                        ? []
                        : controller.mPageData
                            .asMap()
                            .entries
                            .map((e) => GetX<MyMessageController>(
                                  init: controller,
                                  builder: (_) {
                                    return getTopButton(
                                        e.key,
                                        controller.mPageData[e.key]
                                            ["friend_Title"],
                                        controller.topButtonIndex == e.key);
                                  },
                                ))
                            .toList(),
                  );
                },
              )),
          Positioned(
              top: 60.w,
              left: 15.w,
              right: 15.w,
              height: 80.w,
              child: GetX<MyMessageController>(
                init: controller,
                builder: (_) {
                  return Visibility(
                      visible: !controller.nofityBtnClose,
                      child: Container(
                          decoration: getDefaultWhiteDec(),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                  child: centClm([
                                sbRow([
                                  centClm([
                                    getSimpleText(
                                        "开启消息通知", 17, AppColor.textBlack,
                                        isBold: true),
                                    ghb(10),
                                    getSimpleText("您将收到来自手机系统的消息通知", 12,
                                        AppColor.textGrey2)
                                  ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start),
                                  CustomButton(
                                    onPressed:
                                        AppSettings.openNotificationSettings,
                                    child: Container(
                                      width: 75.w,
                                      height: 30.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.w),
                                          gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF4282EB),
                                                Color(0xFF5BA3F7)
                                              ])),
                                      child: Center(
                                        child: getSimpleText(
                                            "开启通知", 12, Colors.white),
                                      ),
                                    ),
                                  )
                                ], width: (375 - 15 * 2 - 24 * 2))
                              ])),
                              Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CustomButton(
                                    onPressed: () {
                                      controller.nofityBtnClose =
                                          !controller.nofityBtnClose;
                                    },
                                    child: SizedBox(
                                      width: 30.w,
                                      height: 30.w,
                                      child: Center(
                                        child: Icon(
                                          Icons.close,
                                          size: 15.w,
                                          color: AppColor.textGrey2,
                                        ),
                                      ),
                                    ),
                                  ))
                            ],
                          )));
                },
              )),
          GetX<MyMessageController>(
            init: controller,
            initState: (_) {},
            builder: (_) {
              return AnimatedPositioned(
                  top: controller.nofityBtnClose ? 60.w : 150.w,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    child: PageView(
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (value) {
                        controller.topButtonIndex = value;
                      },
                      controller: controller.pageCtrl,
                      children: [
                        GetBuilder<MyMessageController>(
                          init: controller,
                          id: controller.messageListId,
                          initState: (_) {},
                          builder: (_) {
                            return SmartRefresher(
                              physics: const BouncingScrollPhysics(),
                              enablePullDown: true,
                              enablePullUp: controller.messagePageList.length <
                                  controller.messageCount,
                              controller: controller.messageRefreshController,
                              onLoading: controller.onLoad,
                              onRefresh: controller.onRefresh,
                              child: controller.messagePageList.isEmpty
                                  ? GetX<MyMessageController>(
                                      init: controller,
                                      builder: (_) {
                                        return CustomEmptyView(
                                          type: CustomEmptyType.noData,
                                          isLoading: controller.isLoading,
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      itemCount: controller.messagePageList !=
                                                  null &&
                                              controller
                                                  .messagePageList.isNotEmpty
                                          ? controller.messagePageList.length
                                          : 0,
                                      itemBuilder: (context, index) {
                                        return messageWidget(
                                            index,
                                            controller.messagePageList[index],
                                            context);
                                      },
                                    ),
                            );
                          },
                        ),
                        GetBuilder<MyMessageController>(
                          init: controller,
                          id: controller.orderListId,
                          initState: (_) {},
                          builder: (_) {
                            return SmartRefresher(
                              physics: const BouncingScrollPhysics(),
                              enablePullDown: true,
                              enablePullUp: controller.orderPageList.length <
                                  controller.orderCount,
                              controller: controller.orderRefreshController,
                              onLoading: controller.onLoad,
                              onRefresh: controller.onRefresh,
                              child: controller.orderPageList.isEmpty
                                  ? GetX<MyMessageController>(
                                      init: controller,
                                      builder: (_) {
                                        return CustomEmptyView(
                                          type: CustomEmptyType.noData,
                                          isLoading: controller.isLoading,
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      itemCount:
                                          controller.orderPageList != null
                                              ? controller.orderPageList.length
                                              : 0,
                                      itemBuilder: (context, index) {
                                        return orderWidget(
                                            index,
                                            controller.orderPageList[index],
                                            context);
                                      },
                                    ),
                            );
                          },
                        ),
                        GetBuilder<MyMessageController>(
                          init: controller,
                          id: controller.noticeListId,
                          initState: (_) {},
                          builder: (_) {
                            return SmartRefresher(
                              physics: const BouncingScrollPhysics(),
                              enablePullDown: true,
                              enablePullUp: controller.noticePageList.length <
                                  controller.noticeCount,
                              controller: controller.noticeRefreshController,
                              onLoading: controller.onLoad,
                              onRefresh: controller.onRefresh,
                              child: controller.noticePageList.isEmpty
                                  ? GetX<MyMessageController>(
                                      init: controller,
                                      builder: (_) {
                                        return CustomEmptyView(
                                          type: CustomEmptyType.noData,
                                          isLoading: controller.isLoading,
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      itemCount:
                                          controller.noticePageList != null
                                              ? controller.noticePageList.length
                                              : 0,
                                      itemBuilder: (context, index) {
                                        return noticeWidget(
                                            index,
                                            controller.noticePageList[index],
                                            context);
                                      },
                                    ),
                            );
                          },
                        ),
                        GetBuilder<MyMessageController>(
                          init: controller,
                          id: controller.earnListId,
                          initState: (_) {},
                          builder: (_) {
                            return SmartRefresher(
                              physics: const BouncingScrollPhysics(),
                              enablePullDown: true,
                              enablePullUp: controller.earnPageList.length <
                                  controller.earnCount,
                              controller: controller.earnRefreshController,
                              onLoading: controller.onLoad,
                              onRefresh: controller.onRefresh,
                              child: controller.earnPageList.isEmpty
                                  ? GetX<MyMessageController>(
                                      init: controller,
                                      builder: (_) {
                                        return CustomEmptyView(
                                          type: CustomEmptyType.noData,
                                          isLoading: controller.isLoading,
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      itemCount: controller.earnPageList != null
                                          ? controller.earnPageList.length
                                          : 0,
                                      itemBuilder: (context, index) {
                                        return earnWidget(
                                            index,
                                            controller.earnPageList[index],
                                            context);
                                      },
                                    ),
                            );
                          },
                        ),
                      ],
                      // onPageChanged: (value) {
                      // controller.topButtonIndex = value;
                      // },
                    ),
                  ),
                  duration: const Duration(milliseconds: 300));
            },
          )
        ],
      ),
    );
  }

  Widget getTopButton(int index, String t1, bool isCurrent) {
    return CustomButton(
      onPressed: () {
        controller.topButtonIndex = index;
      },
      child: Container(
        color: Colors.white,
        width: (375 /
                (controller.mPageData.isNotEmpty
                    ? controller.mPageData.length
                    : 1))
            .w,
        height: 50.w,
        child: Center(
          child: getSimpleText(t1, 15,
              isCurrent ? const Color(0xFF5290F2) : const Color(0xFFB3B3B3),
              isBold: true),
        ),
      ),
    );
  }

  Widget earnWidget(int index, Map data, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data["detailUrl"] != null && data["detailUrl"].length > 0) {
          push(
              CustomWebView(
                title: data["title"],
                url: data["detailUrl"],
              ),
              context);
        }
      },
      child: Align(
        child: Container(
          width: 345.w,
          margin: EdgeInsets.only(bottom: 10.w),
          decoration: getDefaultWhiteDec(),
          child: Column(
            children: [
              sbhRow([
                centRow([
                  Image.asset(
                    assetsName("home/icon_earn_messgae"),
                    width: 16.w,
                    height: 16.w,
                    fit: BoxFit.fill,
                  ),
                  gwb(11.5),
                  getSimpleText("收益信息", 15, AppColor.textBlack, isBold: true),
                ]),
                getSimpleText(data["addTime"], 14, AppColor.textGrey)
              ], width: 345 - 15 * 2, height: 50.w),
              gline(345, 0.5),
              ghb(20.w),
              sbRow([
                getSimpleText(data["title"], 17, AppColor.textBlack,
                    isBold: true),
              ], width: 345 - 15 * 2),
              ghb(14.5.w),
              SizedBox(
                width: (345 - 15 * 2).w,
                child: Text(
                  data["content"],
                  style: TextStyle(fontSize: 14.sp, color: AppColor.textBlack),
                  textAlign: TextAlign.left,
                ),
              ),
              ghb(10.w),
              // sbRow([
              //   const SizedBox(),
              //   CustomButton(
              //     onPressed: () {},
              //     child: centRow([
              //       getSimpleText("查看详情", 14, AppColor.textBlack),
              //       gwb(8.5.w),
              //       Image.asset(
              //         assetsName("common/icon_right_arrow"),
              //         width: 5.5.w,
              //         height: 10.w,
              //         fit: BoxFit.fill,
              //       )
              //     ]),
              //   ),
              // ], width: 345 - 15 * 2),
              ghb(19.5.w)
            ],
          ),
        ),
      ),
    );
  }

  Widget messageWidget(int index, Map data, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data["detailUrl"] != null && data["detailUrl"].length > 0) {
          push(
              CustomWebView(
                title: data["title"],
                url: data["detailUrl"],
              ),
              context);
        }
      },
      child: Align(
        child: Container(
          width: 345.w,
          margin: EdgeInsets.only(bottom: 10.w),
          decoration: getDefaultWhiteDec(),
          child: Column(
            children: [
              sbhRow([
                centRow([
                  Image.asset(
                    assetsName("home/icon_system_message"),
                    width: 16.w,
                    height: 16.w,
                    fit: BoxFit.fill,
                  ),
                  gwb(11.5),
                  getSimpleText("系统信息", 15, AppColor.textBlack, isBold: true),
                ]),
                getSimpleText(data["addTime"], 14, AppColor.textGrey)
              ], width: 345 - 15 * 2, height: 50.w),
              gline(345, 0.5),
              ghb(20.w),
              sbRow([
                getSimpleText(data["title"], 17, AppColor.textBlack,
                    isBold: true),
              ], width: 345 - 15 * 2),
              ghb(14.5.w),
              SizedBox(
                width: (345 - 15 * 2).w,
                child: Text(
                  data["content"],
                  style: TextStyle(fontSize: 14.sp, color: AppColor.textBlack),
                  textAlign: TextAlign.left,
                ),
              ),
              ghb(10.w),
              // sbRow([
              //   const SizedBox(),
              //   CustomButton(
              //     onPressed: () {},
              //     child: centRow([
              //       getSimpleText("查看详情", 14, AppColor.textBlack),
              //       gwb(8.5.w),
              //       Image.asset(
              //         assetsName("common/icon_right_arrow"),
              //         width: 5.5.w,
              //         height: 10.w,
              //         fit: BoxFit.fill,
              //       )
              //     ]),
              //   ),
              // ], width: 345 - 15 * 2),
              ghb(19.5.w)
            ],
          ),
        ),
      ),
    );
  }

  Widget orderWidget(int index, Map data, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data["detailUrl"] != null && data["detailUrl"].length > 0) {
          push(
              CustomWebView(
                title: data["title"],
                url: data["detailUrl"],
              ),
              context);
        }
      },
      child: Align(
        child: Container(
          width: 345.w,
          margin: EdgeInsets.only(bottom: 10.w),
          decoration: getDefaultWhiteDec(),
          child: Column(
            children: [
              sbhRow([
                centRow([
                  Image.asset(
                    assetsName("home/icon_order_messgae"),
                    width: 16.w,
                    height: 16.w,
                    fit: BoxFit.fill,
                  ),
                  gwb(11.5),
                  getSimpleText("订单信息", 15, AppColor.textBlack, isBold: true),
                ]),
                getSimpleText(data["addTime"], 14, AppColor.textGrey)
              ], width: 345 - 15 * 2, height: 50.w),
              gline(345, 0.5),
              ghb(20.w),
              sbRow([
                getSimpleText(data["title"], 17, AppColor.textBlack,
                    isBold: true),
              ], width: 345 - 15 * 2),
              ghb(14.5.w),
              SizedBox(
                width: (345 - 15 * 2).w,
                child: Text(
                  data["content"],
                  style: TextStyle(fontSize: 14.sp, color: AppColor.textBlack),
                  textAlign: TextAlign.left,
                ),
              ),
              ghb(10.w),
              // sbRow([
              //   const SizedBox(),
              //   CustomButton(
              //     onPressed: () {},
              //     child: centRow([
              //       getSimpleText("查看详情", 14, AppColor.textBlack),
              //       gwb(8.5.w),
              //       Image.asset(
              //         assetsName("common/icon_right_arrow"),
              //         width: 5.5.w,
              //         height: 10.w,
              //         fit: BoxFit.fill,
              //       )
              //     ]),
              //   ),
              // ], width: 345 - 15 * 2),
              ghb(19.5.w)
            ],
          ),
        ),
      ),
    );
  }

  Widget noticeWidget(int index, Map data, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data["detailUrl"] != null && data["detailUrl"].length > 0) {
          push(
              CustomWebView(
                title: data["title"],
                url: data["detailUrl"],
              ),
              context);
        }
      },
      child: Align(
        child: Container(
          width: 345.w,
          margin: EdgeInsets.only(bottom: 10.w),
          decoration: getDefaultWhiteDec(),
          child: Column(
            children: [
              sbhRow([
                centRow([
                  Image.asset(
                    assetsName("home/icon_system_message"),
                    width: 16.w,
                    height: 16.w,
                    fit: BoxFit.fill,
                  ),
                  gwb(11.5),
                  getSimpleText("公告信息", 15, AppColor.textBlack, isBold: true),
                ]),
                getSimpleText(data["addTime"], 14, AppColor.textGrey)
              ], width: 345 - 15 * 2, height: 50.w),
              gline(345, 0.5),
              ghb(20.w),
              sbRow([
                getSimpleText(data["title"], 17, AppColor.textBlack,
                    isBold: true),
              ], width: 345 - 15 * 2),
              ghb(14.5.w),
              SizedBox(
                width: (345 - 15 * 2).w,
                child: Text(
                  data["content"],
                  style: TextStyle(fontSize: 14.sp, color: AppColor.textBlack),
                  textAlign: TextAlign.left,
                ),
              ),
              ghb(10.w),
              // sbRow([
              //   const SizedBox(),
              //   CustomButton(
              //     onPressed: () {},
              //     child: centRow([
              //       getSimpleText("查看详情", 14, AppColor.textBlack),
              //       gwb(8.5.w),
              //       Image.asset(
              //         assetsName("common/icon_right_arrow"),
              //         width: 5.5.w,
              //         height: 10.w,
              //         fit: BoxFit.fill,
              //       )
              //     ]),
              //   ),
              // ], width: 345 - 15 * 2),
              ghb(19.5.w)
            ],
          ),
        ),
      ),
    );
  }
}
