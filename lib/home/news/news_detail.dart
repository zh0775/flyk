import 'package:cxhighversion2/component/custom_background.dart';
import 'package:cxhighversion2/component/custom_html_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:get/get.dart';

class NewsDetailController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  loadDetail(int id) {
    simpleRequest(
      url: Urls.newDetail(id),
      params: {},
      success: (success, json) {
        if (success) {
          newsData = json["data"] ?? {};
          // newsData = data["cur"] ?? {};
          update();
        }
      },
      after: () {},
    );
  }

  bool isFirst = true;
  Map newsData = {};
  dataInit(Map data) {
    if (!isFirst) return;
    isFirst = false;
    newsData = data;
    if (newsData["content"] == null) {
      loadDetail(newsData["id"] ?? -1);
    }
  }
}

class NewsDetail extends StatelessWidget {
  final Map newsData;
  const NewsDetail({super.key, this.newsData = const {}});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsDetailController>(
      init: NewsDetailController(),
      builder: (controller) {
        controller.dataInit(newsData);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: getDefaultAppBar(
            context,
            "",
            flexibleSpace: const CustomBackground(),
          ),
          body: CustomBackground(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  gwb(375),
                  ghb(20),
                  sbRow([
                    getSimpleText(controller.newsData["title"] ?? "", 16,
                        AppColor.textBlack3,
                        fw: FontWeight.w500),
                  ], width: 375 - 16 * 2),
                  ghb(10),
                  sbRow([
                    getSimpleText(controller.newsData["addTime"] ?? "", 12,
                        AppColor.textGrey5),
                    // getSimpleText("${newsData["bS_View"] ?? 0}人阅读",
                    //     12, AppColor.textGrey5),
                  ], width: 375 - 16 * 2),
                  ghb(15),
                  CustomHtmlView(
                    src: controller.newsData["content"] ?? "",
                    width: 345,
                    loadingWidget: Center(
                        child: getSimpleText("页面正在加载中", 15, AppColor.textGrey)),
                  ),
                  SizedBox(
                    height: paddingSizeBottom(context),
                  ),
                  ghb(30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
