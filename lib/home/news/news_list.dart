import 'package:cxhighversion2/component/custom_background.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/news/news_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewsListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<NewsListController>(NewsListController());
  }
}

class NewsListController extends GetxController {
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  RefreshController pullCtrl = RefreshController();

  List dataList = [];

  int pageNo = 1;
  int pageSize = 10;
  int count = 0;

  onLoad() {
    loadList(isLoad: true);
  }

  onRefresh() {
    loadList();
  }

  loadList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    simpleRequest(
      url: Urls.newList,
      params: {
        "classType": 0,
        "pageNo": pageNo,
        "pageSize": pageSize,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          isLoad
              ? dataList = [...dataList, ...(data["data"] ?? [])]
              : dataList = data["data"] ?? [];
          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          update();
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
  DateFormat dateFormat2 = DateFormat("yyyy年MM月dd日");

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onInit() {
    loadList();
    super.onInit();
  }
}

class NewsList extends GetView<NewsListController> {
  const NewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: getDefaultAppBar(context, "公告",
            flexibleSpace: const CustomBackground()),
        body: CustomBackground(child: GetBuilder<NewsListController>(
          builder: (_) {
            return SmartRefresher(
              controller: controller.pullCtrl,
              onLoading: controller.onLoad,
              onRefresh: controller.onRefresh,
              enablePullUp: controller.count > controller.dataList.length,
              child: controller.dataList.isEmpty
                  ? GetX<NewsListController>(
                      builder: (_) {
                        return CustomEmptyView(
                          isLoading: controller.isLoading,
                        );
                      },
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 15.w),
                      itemCount: controller.dataList.length,
                      itemBuilder: (context, index) {
                        return newCell(
                            index, controller.dataList[index], context);
                      },
                    ),
            );
          },
        )));
  }

  Widget newCell(int index, Map data, BuildContext context) {
    return Align(
      child: CustomButton(
        onPressed: () {
          push(
              NewsDetail(
                newsData: data,
              ),
              context);
        },
        child: Container(
          margin: EdgeInsets.only(top: 8.w),
          width: 345.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(width: 1.w, color: Colors.white),
              gradient: const LinearGradient(
                  colors: [Color(0xFFEBF3F7), Color(0xFFFAFAFA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Column(
            children: [
              ghb(16),
              sbRow(
                [
                  centClm([
                    getWidthText(data["title"] ?? "", 13,
                        const Color(0xFF525C66), 216, 2,
                        fw: AppDefault.fontBold),
                    ghb(10),
                    getWidthText(
                        data["meta"] ?? "", 10, const Color(0xFF525C66), 216, 2,
                        fw: AppDefault.fontBold),
                    ghb(10),
                    sbRow([
                      data["addTime"] != null && data["addTime"].isNotEmpty
                          ? getSimpleText(
                              controller.dateFormat2.format(
                                  controller.dateFormat.parse(data["addTime"])),
                              10,
                              const Color(0xFF525C66))
                          : gwb(0),
                    ], width: 216)
                  ]),
                  CustomNetworkImage(
                    src: AppDefault().imageUrl + (data["bgImg"] ?? ""),
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                  )
                ],
                width: 343 - 16 * 2,
              ),
              ghb(16),
            ],
          ),
        ),
      ),
    );
  }
}
