/// 积分商城 我的评价、待评价 列表页面

import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:cxhighversion2/business/mallEvaluate/shopping_form_evaluate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:cxhighversion2/business/pointsMall/shopping_product_detail.dart';

class MallEvaluatePageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MallEvaluatePageController>(MallEvaluatePageController(datas: Get.arguments));
  }
}

class MallEvaluatePageController extends GetxController {
  final dynamic datas;

  MallEvaluatePageController({this.datas});

  bool isFirst = true;
  bool topAnimation = false; // top动画

  late PageController pageCtrl;
  RefreshController allPullCtrl = RefreshController(); // 全部
  RefreshController processingPullCtrl = RefreshController(); // 处理中

  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  set isLoading(v) => _isLoading.value = v;

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (!topAnimation) {
      _topIndex.value = v;
      changePage(topIndex);
      loadList(status: topIndex);
    }
  }

  int pageSize = 10;
  int userHasEvalutePageNo = 1; // 我的评价页码
  int userHasEvaluteCount = 0; // 我的评价
  final _userHasEvaluteOrderData = Rx<List>([]);
  List get userHasEvaluteOrderList => _userHasEvaluteOrderData.value;
  set userHasEvaluteOrderList(v) => _userHasEvaluteOrderData.value = v;

  // 获取已经评价数据
  loadHasEvaluteList({bool isLoad = false}) {
    isLoad ? userHasEvalutePageNo++ : userHasEvalutePageNo = 1;
    if (userHasEvaluteOrderList.isEmpty) {
      isLoading = true;
    }

    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": userHasEvalutePageNo,
      "cType": 2,
    };
    simpleRequest(
      url: Urls.userMyCommentList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          List tmp = data["data"] ?? [];
          userHasEvaluteOrderList = isLoad ? [...userHasEvaluteOrderList, ...tmp] : tmp;
          isLoad ? allPullCtrl.loadComplete() : allPullCtrl.refreshCompleted();
          update();
        } else {
          isLoad ? allPullCtrl.loadFailed() : allPullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  // 未评价分页大小
  int userNotEvalutePageNo = 1; // 未评价页码
  int userNotEvaluteCount = 0; // 待评价总数

  final _mallNotEvaluteOrderData = Rx<List>([]); // 待评价数据
  List get mallNotEvaluteOrderList => _mallNotEvaluteOrderData.value;
  set mallNotEvaluteOrderList(v) => _mallNotEvaluteOrderData.value = v;

  // 获取待评价数据
  loadNotEvaluteList({bool isLoad = false}) {
    isLoad ? userNotEvalutePageNo++ : userNotEvalutePageNo = 1;
    if (mallNotEvaluteOrderList.isEmpty) {
      isLoading = true;
    }

    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": userNotEvalutePageNo,
      "cType": 1,
    };
    simpleRequest(
      url: Urls.userMyCommentList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          userNotEvaluteCount = data['count'] ?? 0;
          List tmp = data["data"] ?? [];
          mallNotEvaluteOrderList = isLoad ? [...mallNotEvaluteOrderList, ...tmp] : tmp;
          update();

          isLoad ? processingPullCtrl.loadComplete() : processingPullCtrl.refreshCompleted();
        } else {
          isLoad ? processingPullCtrl.loadFailed() : processingPullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  loadList({bool isLoad = false, required int status}) {
    RefreshController pullCtrl;
    if (status == 0) {
      pullCtrl = allPullCtrl;
    } else {
      pullCtrl = processingPullCtrl;
    }
    pullCtrl.loadComplete();
  }

  // 切换top-tabber
  changePage(int index) {
    if (isFirst) {
      return;
    }

    topAnimation = true;
    pageCtrl.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.linear).then((value) {
      topAnimation = false;
    });
  }

  List stringImgToArray(String strImg) {
    return strImg.split(',');
  }

  onLoad(int status) {
    loadList(status: status, isLoad: true);
  }

  onRefresh(int status) {
    loadList(status: status);
  }

  @override
  void onInit() {
    pageCtrl = PageController(initialPage: datas["index"] ?? 0);
    topIndex = datas["index"] ?? 0;
    isFirst = false;

    loadNotEvaluteList();
    loadHasEvaluteList();
    super.onInit();
  }
}

class MallEvaluatePage extends GetView<MallEvaluatePageController> {
  const MallEvaluatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MallEvaluatePageController>(
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          appBar: getDefaultAppBar(context, "我的评价"),
          body: Stack(
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
                child: mallOrderPageView(),
              )
            ],
          ),
        );
      },
    );
  }

  // topBar
  Widget topBar() {
    return Container(
      width: 375.w,
      height: 51.w,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ["待评价", "我的评价"]
            .asMap()
            .entries
            .map(
              (item) => CustomButton(
                onPressed: () {
                  controller.topIndex = item.key;
                },
                child: Center(
                  child: GetX<MallEvaluatePageController>(
                    init: controller,
                    initState: (_) {},
                    builder: (_) {
                      return SizedBox(
                        width: (375 / 4).w,
                        height: 55.w,
                        child: centClm([
                          getSimpleText(
                            item.key == 0 ? "${item.value}(${controller.userNotEvaluteCount})" : item.value,
                            15,
                            controller.topIndex != item.key ? const Color(0xFFBCC0C9) : const Color(0xFFFF6231),
                          ),
                          ghb(controller.topIndex == item.key ? 3 : 0),
                          controller.topIndex != item.key
                              ? ghb(0)
                              : Container(
                                  width: 30.w,
                                  height: 2.w,
                                  decoration: BoxDecoration(color: const Color(0xFFFF6231), borderRadius: BorderRadius.circular(2.w)),
                                )
                        ]),
                      );
                    },
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // 我的评价
  Widget mallOrderPageView() {
    return PageView(
      physics: const BouncingScrollPhysics(),
      controller: controller.pageCtrl,
      scrollDirection: Axis.horizontal,
      onPageChanged: (value) {
        controller.topIndex = value;
      },
      children: [
        GetBuilder<MallEvaluatePageController>(
          init: controller,
          builder: (_) {
            return mallEvaluateList(controller.mallNotEvaluteOrderList, controller.userNotEvaluteCount, 0, 0, controller.processingPullCtrl, () async {
              controller.loadNotEvaluteList();
            }, () async {
              controller.loadNotEvaluteList(isLoad: true);
            });
          },
        ),
        GetBuilder<MallEvaluatePageController>(
          init: controller,
          builder: (_) {
            return mallEvaluateList(controller.userHasEvaluteOrderList, controller.userHasEvaluteCount, 0, 1, controller.allPullCtrl, () async {
              controller.loadHasEvaluteList();
            }, () async {
              controller.loadHasEvaluteList(isLoad: true);
            });
          },
        ),
      ],
    );
  }

  // 待评价
  /// datas item 数据
  /// count  累计  分页
  /// listIndex 索引
  /// evaluateType  类型
  Widget mallEvaluateList(List datas, int count, int listIndex, int evaluateType, RefreshController pullCtrl, Function()? onRefresh, Function()? onLoading) {
    return SmartRefresher(
      controller: pullCtrl,
      onRefresh: onRefresh,
      onLoading: onLoading,
      physics: const BouncingScrollPhysics(),
      enablePullUp: datas.length < count ? true : false,
      child: datas.isEmpty
          ? GetX<MallEvaluatePageController>(
              init: controller,
              builder: (_) {
                return CustomEmptyView(
                  isLoading: controller.isLoading,
                );
              },
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 15.w + paddingSizeBottom(Global.navigatorKey.currentContext!)),
              itemCount: datas.isEmpty ? 0 : datas.length,
              itemBuilder: (context, index) {
                return evaluateType == 0 ? mallEvaluateItem(datas[index], index, context, listIndex) : myEvaluateItem(datas[index], index, context, listIndex);
              },
            ),
    );
  }

  //待评价
  Widget mallEvaluateItem(
    Map data,
    int index,
    BuildContext context,
    int listIndex,
  ) {
    return Container(
      width: 375.w - 15.w * 2,
      margin: EdgeInsets.only(top: 15.w, right: 15.w, left: 15.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          // SizedBox(
          //   child: sbRow([
          //     getSimpleText("订单编号：${data['orderNo']}", 10.w, const Color(0xFF999999)),
          //     getSimpleText("${data['orderTypeText']}", 12.w, const Color(0xFFFF6231)),
          //   ], width: (345.w - 15.w * 2)),
          // ),
          // ghb(14.w),
          Container(
            // decoration: BoxDecoration(
            //   color: const Color(0xFFF8F8F8),
            //   borderRadius: BorderRadius.circular(8.w),
            // ),
            // padding: EdgeInsets.fromLTRB(10.w, 7.5.w, 10.w, 7.5.w),
            child: sbRow([
              CustomNetworkImage(
                src: AppDefault().imageUrl + (data["shopImg"] ?? ""),
                width: 60.w,
                height: 60.w,
                fit: BoxFit.fitWidth,
              ),
              gwb(11.w),
              SizedBox(
                width: 345.w - 60.w - 15 * 2 - 13.w,
                height: 60.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getSimpleText("${data['shopName']}", 12.w, const Color(0xFF333333)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        borderButton('评价', const Color(0xFFFF6231), data),
                      ],
                    ),
                  ],
                ),
              )
            ]),
          ),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     getSimpleText("总计：", 10.w, const Color(0xFF333333)),
          //     getSimpleText("${data['integralTotal']}积分", 12.w, const Color(0xFFFF6231)),
          //   ],
          // ),
          // ghb(13.w),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [borderButton('评价', const Color(0xFFFF6231), data['logisticsId'], '1')],
          // )
        ],
      ),
    );
  }

  Widget borderButton(
    String buttonTitle,
    Color color,
    Map data,
  ) {
    return GestureDetector(
      onTap: () {
        push(const EvaluateFormPage(), null, binding: EvaluateFormPageBinding(), arguments: data);
        //
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 6.w, 20.w, 6.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: color,
            ),
            boxShadow: [BoxShadow(color: Colors.white, offset: Offset.zero, blurRadius: 2.w, spreadRadius: 2.w, blurStyle: BlurStyle.solid)]),
        child: getSimpleText("$buttonTitle ", 12, color, textHeight: 1.1),
      ),
    );
  }

  // 我的评价item

  Widget myEvaluateItem(Map data, int index, BuildContext context, int listIndex) {
    return Container(
      width: 375.w,
      color: Colors.white,
      padding: EdgeInsets.all(15.w),
      margin: EdgeInsets.only(top: 15.w),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.w),
                child: CustomNetworkImage(
                  src: AppDefault().imageUrl + (data["shopImg"] ?? ""),
                  width: 30.w,
                  height: 30.w,
                  fit: BoxFit.fitWidth,
                ),
              ),
              gwb(6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        getSimpleText(data['u_Name'] ?? '匿名', 15, const Color(0xFF333333)),
                        getSimpleText(data['addTime'], 12, const Color(0xFF333333)),
                      ],
                    ),
                    Container(
                      child: startRating(currentStart: 3),
                    )
                  ],
                ),
              ),
            ],
          ),
          ghb(13),
          SizedBox(
            width: 345.w,
            child: Text(data['comment'] ?? '',
                style: TextStyle(
                  fontSize: 15.w,
                  color: const Color(0xFF333333),
                ),
                textAlign: TextAlign.start),
          ),
          ghb(8),
          SizedBox(
            width: 345.w,
            child: Wrap(
              spacing: 15.w,
              runSpacing: 10.w,
              children: List.generate(controller.stringImgToArray(data['images'] ?? '').length, (index) {
                String imgsItem = controller.stringImgToArray(data['images'])[index];
                return GestureDetector(
                  onTap: () {
                    toCheckImg(image: "${AppDefault().imageUrl}${imgsItem}");
                  },
                  child: Image.network(
                    // 'https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_1280.jpg',
                    AppDefault().imageUrl + imgsItem,
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.cover,
                  ),
                );
              }),
            ),
          ),
          ghb(20),
          Container(
            width: 345.w,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.w),
              color: const Color(0xFFF5F5F7),
            ),
            padding: EdgeInsets.fromLTRB(10.w, 7.5.w, 10.w, 7.5.w),
            child: GestureDetector(
              onTap: () {
                push(const ShoppingProductDetail(), null, binding: ShoppingProductDetailBinding(), arguments: {"data": controller.datas});
              },
              child: Row(
                children: [
                  CustomNetworkImage(
                    src: AppDefault().imageUrl + (data["shopImg"] ?? ""),
                    width: 45.w,
                    height: 45.w,
                    fit: BoxFit.fitWidth,
                  ),
                  gwb(12),
                  SizedBox(
                    width: 345.w - 45.w - 20.w - 12.w - 15.w,
                    child: getSimpleText(
                      data['shopName'] ?? '',
                      12,
                      const Color(0xFF333333),
                    ),
                  ),
                  Image.asset(
                    assetsName("mine/icon_right_arrow"),
                    width: 12.w,
                    fit: BoxFit.fitWidth,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget startRating({int currentStart = 0}) {
    return Row(
        children: List.generate(5, (index) {
      return Icon(
        index < currentStart ? Icons.star : Icons.star_border,
        size: 11.w,
        color: const Color(0xFFFEB501),
      );
    }));
  }
}
