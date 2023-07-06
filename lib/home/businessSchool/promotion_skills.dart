// 推广技巧 列表

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/businessSchool/business_school_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class PromotionSkillsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<PromotionSkillsController>(PromotionSkillsController(datas: Get.arguments));
  }
}

class PromotionSkillsController extends GetxController {
  final dynamic datas;
  PromotionSkillsController({this.datas});

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isFirstLoadding = true.obs;
  bool get isFirstLoadding => _isFirstLoadding.value;
  set isFirstLoadding(v) => _isFirstLoadding.value = v;

  int pageNo = 1;
  int count = 0;
  int pageSize = 20;
  List dataList = [];

  loadData({bool isLoad = false}) {
    simpleRequest(
      url: Urls.userBusinessSchoolList,
      params: {"pageNo": pageNo, "pageSize": pageSize, "classId": 1092},
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];
          dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
          update();
        }
      },
      after: () {
        isLoading = false;
        isFirstLoadding = false;
      },
    );
  }

  @override
  void onReady() {
    loadData();
    super.onReady();
  }
}

class PromotionSkills extends GetView<PromotionSkillsController> {
  const PromotionSkills({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "推广技巧"),
        body: GetBuilder<PromotionSkillsController>(builder: (_) {
          return EasyRefresh.builder(
              // controller: controller.pullCtrls[listIdx],
              // onLoading: () => controller.onLoad(listIdx),
              onRefresh: () => controller.loadData(),
              onLoad: controller.dataList.length >= controller.count ? null : () => controller.loadData(isLoad: true),
              // enablePullUp: controller.counts[listIdx] >
              // controller.dataLists[listIdx].length,
              childBuilder: (context, physics) {
                return controller.dataList.isEmpty
                    ? GetX<PromotionSkillsController>(builder: (controller) {
                        return controller.isFirstLoadding && !kIsWeb
                            ? SkeletonListView(
                                item: SkeletonItem(
                                    child: Column(children: [
                                ghb(15),
                                Column(children: [
                                  SkeletonAvatar(
                                    style: SkeletonAvatarStyle(
                                      width: 345.w,
                                      height: 171.w,
                                    ),
                                  ),
                                  SkeletonParagraph(
                                      style: SkeletonParagraphStyle(
                                          lines: 2,
                                          // spacing: 10.w,
                                          lineStyle: SkeletonLineStyle(randomLength: true, height: 20.w, borderRadius: BorderRadius.circular(8))))
                                ])
                              ])))
                            : CustomListEmptyView(physics: physics, isLoading: controller.isLoading);
                      })
                    : ListView.builder(
                        physics: physics,
                        itemCount: controller.dataList.length,
                        padding: EdgeInsets.only(bottom: 20.w),
                        itemBuilder: (context, index) {
                          return cell2(index, controller.dataList[index]);
                        });
              });
        }));
  }

  Widget cell2(int index, Map data) {
    return CustomButton(
      onPressed: () {
        push(BusinessSchoolDetail(id: data["id"]), null, binding: BusinessSchoolDetailBinding(), arguments: {"needSave": true});
      },
      child: Container(
          width: 375.w,
          height: 250.w,
          margin: EdgeInsets.only(top: index == 0 ? 6.w : 0),
          color: Colors.transparent,
          child: Column(children: [
            ghb(15),
            SizedBox(
                width: 345.w,
                height: 171.w,
                child: Stack(children: [
                  Positioned.fill(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.w),
                          child: CustomNetworkImage(
                              src: AppDefault().imageUrl + (data["coverImg"] ?? ""), width: 345.w, height: 171.w, fit: BoxFit.cover))),
                  Positioned(
                      left: 13.5.w,
                      bottom: 6.w,
                      child: centRow([
                        Image.asset(assetsName("common/icon_lookcount"), width: 18.w),
                        gwb(2),
                        getWidthText("${data["view"] ?? 0}", 12, Colors.white, 35, 1, textHeight: 1.25)
                      ])),
                  data["audio"] != null && data["audio"].isNotEmpty
                      ? Align(alignment: Alignment.center, child: Image.asset(assetsName("common/btn_video_play"), width: 26.w, fit: BoxFit.fitWidth))
                      : gemp()
                ])),
            ghb(13),
            getWidthText(data["title"] ?? "", 15, AppColor.text2, 345, 2, isBold: true),
            ghb(8),
            sbRow([
              centRow([
                Image.asset(assetsName("common/icon_addtime"), width: 18.w),
                gwb(2),
                getSimpleText(data["addTime"] ?? "", 12, AppColor.text3, textHeight: 1.25)
              ])
            ], width: 345)
          ])),
    );
  }
}
