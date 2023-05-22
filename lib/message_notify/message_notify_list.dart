import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/message_notify/message_notify_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class MessageNotifyListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MessageNotifyListController>(
        MessageNotifyListController(datas: Get.arguments));
  }
}

class MessageNotifyListController extends GetxController {
  final dynamic datas;
  MessageNotifyListController({this.datas});

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;
  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  int count = 0;
  int pageNo = 1;
  int pageSize = 20;
  List dataList = [];

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }

    simpleRequest(
      url: Urls.userFriendLogList,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          List tmpList = data["data"] ?? [];
          dataList = isLoad
              ? [
                  ...dataList,
                  ...tmpList,
                ]
              : tmpList;
          update();
        }
      },
      after: () {
        isLoading = false;
        isFirstLoading = false;
      },
    );
  }

  @override
  void onInit() {
    loadData();
    AppDefault().homeData["unread"] = false;
    super.onInit();
  }
}

class MessageNotifyList extends GetView<MessageNotifyListController> {
  const MessageNotifyList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "公告"),
      body: GetBuilder<MessageNotifyListController>(
        builder: (_) {
          return EasyRefresh.builder(
              onLoad: controller.dataList.length >= controller.count
                  ? null
                  : () => controller.loadData(isLoad: true),
              onRefresh: () => controller.loadData(),
              childBuilder: (context, physics) {
                return controller.dataList.isEmpty
                    ? GetX<MessageNotifyListController>(
                        builder: (controller) {
                          return controller.isFirstLoading && !kIsWeb
                              ? SkeletonListView(
                                  item: Column(children: [
                                  ghb(15),
                                  Row(
                                    children: [
                                      // SkeletonAvatar(
                                      //     style: SkeletonAvatarStyle(
                                      //   height: 60.w,
                                      //   width: 60.w,
                                      // )),
                                      // gwb(10),
                                      Expanded(
                                          child: SkeletonParagraph(
                                              style: SkeletonParagraphStyle(
                                                  lines: 5,
                                                  spacing: 10.w,
                                                  lineStyle: SkeletonLineStyle(
                                                      randomLength: true,
                                                      height: 12.w,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)))))
                                    ],
                                  )
                                ]))
                              : CustomListEmptyView(
                                  physics: physics,
                                  isLoading: controller.isLoading);
                        },
                      )
                    : ListView.builder(
                        physics: physics,
                        padding: EdgeInsets.only(bottom: 20.w),
                        itemCount: controller.dataList.length,
                        itemBuilder: (context, index) {
                          return cell(index, controller.dataList[index]);
                        });
              });
        },
      ),
    );
  }

  Widget cell(int index, Map data) {
    int type = (data["fType"] ?? 0);
    String typeStr = "系统消息";
    switch (type) {
      case 1:
        typeStr = "系统消息";
        break;
      case 2:
        typeStr = "订单消息";
        break;
      case 3:
        typeStr = "公告消息";
        break;
      case 4:
        typeStr = "资金变动消息";
        break;
      default:
    }

    return CustomButton(
      onPressed: () {
        push(const MessageNotifyDetail(), null,
            binding: MessageNotifyDetailBinding(),
            arguments: {
              "data": data,
            });
      },
      child: UnconstrainedBox(
        child: Container(
          margin: EdgeInsets.only(top: 15.w),
          // height: 150.w,
          width: 345.w,
          decoration: getDefaultWhiteDec(radius: 6),
          child: Column(
            children: [
              sbhRow([
                centRow([
                  Image.asset(
                    assetsName(
                        "message_notify/icon_${type == 1 ? "notify" : "message"}"),
                    width: 18.w,
                    fit: BoxFit.fitWidth,
                  ),
                  getSimpleText(typeStr, 12, AppColor.textBlack),
                ]),
                getSimpleText(data["addTime"] ?? "", 12, AppColor.textGrey),
              ], width: 345 - 12.5 * 2, height: 36),
              // ghb(7.5),
              getWidthText(data["title"] ?? "", 15, AppColor.textBlack, 315, 1,
                  isBold: true),
              ghb(6),
              getWidthText(
                  data["content"] ?? "", 12, AppColor.textGrey, 315, 2),
              ghb(18),
              gline(315, 0.5),
              sbhRow([
                getSimpleText("查看详情", 12, AppColor.textGrey),
                Image.asset(
                  assetsName("message_notify/arrow_right_gray"),
                  width: 10.w,
                  fit: BoxFit.fitWidth,
                ),
              ], width: 315, height: 34.5),
              ghb(2),
            ],
          ),
        ),
      ),
    );
  }
}
