import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class MessageNotifyDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MessageNotifyDetailController>(
        MessageNotifyDetailController(datas: Get.arguments));
  }
}

class MessageNotifyDetailController extends GetxController {
  final dynamic datas;
  MessageNotifyDetailController({this.datas});

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;
  final _isFirstLoading = false.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  Map myData = {};

  // loadData() {
  //   Future.delayed(const Duration(seconds: 1), () {
  //     isLoading = false;
  //     isFirstLoading = false;
  //   });
  // }

  @override
  void onInit() {
    myData = (datas ?? {})["data"] ?? {};
    // loadData();
    super.onInit();
  }
}

class MessageNotifyDetail extends GetView<MessageNotifyDetailController> {
  const MessageNotifyDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: getDefaultAppBar(context, "详情"),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: GetX<MessageNotifyDetailController>(
              builder: (_) {
                return Column(
                  children: [
                    gline(375, 0.5),
                    ghb(18),
                    controller.isFirstLoading
                        ? SkeletonParagraph(
                            style: SkeletonParagraphStyle(
                                lines: 1,
                                // spacing: 10.w,
                                lineStyle: SkeletonLineStyle(
                                  randomLength: true,
                                  height: 21.w,
                                  borderRadius: BorderRadius.circular(8),
                                  // minLength: 150.w,
                                  // maxLength: 160.w,
                                )),
                          )
                        : getWidthText(controller.myData["title"] ?? "", 21,
                            AppColor.textBlack, 345, 2,
                            isBold: true),
                    ghb(18),
                    controller.isFirstLoading
                        ? SkeletonParagraph(
                            style: SkeletonParagraphStyle(
                                lines: 1,
                                // spacing: 10.w,
                                lineStyle: SkeletonLineStyle(
                                  randomLength: true,
                                  height: 12.w,
                                  borderRadius: BorderRadius.circular(6.w),
                                  // minLength: 150.w,
                                  // maxLength: 160.w,
                                )),
                          )
                        : getWidthText(
                            controller.myData["addTime"] ?? "",
                            12,
                            AppColor.textGrey,
                            345,
                            1,
                          ),
                    ghb(20),
                    gline(345, 0.5),
                    ghb(15),
                    controller.isFirstLoading
                        ? SkeletonParagraph(
                            style: SkeletonParagraphStyle(
                                lines: 6,
                                spacing: 5.w,
                                lineStyle: SkeletonLineStyle(
                                  randomLength: true,
                                  height: 14.w,
                                  borderRadius: BorderRadius.circular(7.w),
                                  // minLength: 150.w,
                                  // maxLength: 160.w,
                                )),
                          )
                        : getWidthText(controller.myData["content"] ?? "", 14,
                            AppColor.textBlack, 345, 1000,
                            textHeight: 1.5),
                  ],
                );
              },
            )));
  }
}
