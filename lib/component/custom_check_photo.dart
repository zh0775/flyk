import 'dart:io';

import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class CustomCheckPhotoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomCheckPhotoController>(() => CustomCheckPhotoController());
  }
}

class CustomCheckPhotoController extends GetxController {}

class CustomCheckPhoto extends GetView<CustomCheckPhotoController> {
  final dynamic image;
  final bool needSave;
  const CustomCheckPhoto({Key? key, required this.image, this.needSave = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: GetBuilder<CustomCheckPhotoController>(
            init: controller,
            builder: (controller) {
              ImageProvider provider;
              if (image is XFile) {
                provider = FileImage(File(image.path));
              } else {
                String img = (image as String);
                if (img.contains("http")) {
                  provider = NetworkImage(AppDefault().imageView.isNotEmpty
                      ? "$img?${AppDefault().imageView}"
                      : img);
                } else {
                  provider = AssetImage(img);
                }
              }
              return PhotoView(imageProvider: provider);
            }),
      ),
    );
  }
}
