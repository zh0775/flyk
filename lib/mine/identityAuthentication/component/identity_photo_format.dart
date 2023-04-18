import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class IdentityPhotoFormatBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IdentityPhotoFormatController>(
        () => IdentityPhotoFormatController());
  }
}

class IdentityPhotoFormatController extends GetxController {
  GlobalKey photoKey = GlobalKey();
  bool isFirst = true;
  final _tep1 = true.obs;
  get tep1 => _tep1.value;
  set tep1(v) => _tep1.value = v;

  XFile? authImg;

  dataInit(XFile img) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    authImg = img;
  }
}

class IdentityPhotoFormat extends GetView<IdentityPhotoFormatController> {
  final XFile img;
  const IdentityPhotoFormat({Key? key, required this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(img);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
              top: paddingSizeTop(context),
              left: 0,
              right: 0,
              bottom: paddingSizeBottom(context) + 80.w + 50.w,
              child: SizedBox(
                child: PhotoView(
                  key: controller.photoKey,
                  // enableRotation: true,
                  imageProvider: FileImage(File(controller.authImg!.path)),
                ),
              )),
          Positioned(
              bottom: paddingSizeBottom(context) + 50.w,
              height: 90.w,
              left: 0,
              right: 0,
              child: centClm([
                SizedBox(
                  height: 30.w,
                  child: GetX<IdentityPhotoFormatController>(
                    init: controller,
                    builder: (_) {
                      return getSimpleText(controller.tep1 ? "拖拽和放大来调整图片" : "",
                          18, Colors.white);
                    },
                  ),
                ),
                GetX<IdentityPhotoFormatController>(
                  init: controller,
                  builder: (_) {
                    return centRow(
                      controller.tep1
                          ? [
                              CustomButton(
                                onPressed: () {
                                  controller.tep1 = false;
                                },
                                child: SizedBox(
                                    width: 120.w,
                                    height: 50.w,
                                    child: Center(
                                        child: getSimpleText(
                                            "确定", 20, Colors.white,
                                            isBold: true))),
                              ),
                            ]
                          : [
                              CustomButton(
                                onPressed: () {
                                  controller.tep1 = true;
                                },
                                child: SizedBox(
                                    width: 120.w,
                                    height: 50.w,
                                    child: Center(
                                        child: getSimpleText(
                                            "取消", 20, Colors.white,
                                            isBold: true))),
                              ),
                              CustomButton(
                                onPressed: () {},
                                child: SizedBox(
                                    width: 120.w,
                                    height: 50.w,
                                    child: Center(
                                        child: getSimpleText(
                                            "完成", 20, Colors.white,
                                            isBold: true))),
                              ),
                            ],
                    );
                  },
                )
              ]))
        ],
      ),
    );
  }
}
