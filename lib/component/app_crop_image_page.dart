import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/util/app_default.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AppCropImagePage extends StatefulWidget {
  final XFile image;
  final Function(Uint8List image)? cropResult;
  const AppCropImagePage({
    super.key,
    required this.image,
    this.cropResult,
  });

  @override
  State<AppCropImagePage> createState() => _AppCropImagePageState();
}

class _AppCropImagePageState extends State<AppCropImagePage> {
  final cropCtrl = CropController();
  Uint8List? cropImg;
  final GlobalKey key = GlobalKey();
  bool isOk = false;

  // ExtendedImageState? myImageState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "编辑图片", action: [
        !isOk
            ? gwb(0)
            : CustomButton(
                onPressed: () {
                  setState(() {
                    isOk = false;
                  });
                },
                child: SizedBox(
                  width: 35.w,
                  height: kToolbarHeight,
                  child: Center(child: getSimpleText("放弃", 14, AppColor.text)),
                ),
              ),
        CustomButton(
          onPressed: () {
            if (!isOk) {
              cropImage();
            } else {
              if (widget.cropResult != null) {
                widget.cropResult!(cropImg!);
              }
              Get.back();
            }
          },
          child: SizedBox(
            width: 50.w,
            height: kToolbarHeight,
            child: Center(
                child: isOk
                    ? Icon(
                        Icons.done_rounded,
                        color: AppColor.text,
                        size: 25.w,
                      )
                    : getSimpleText("确定", 14, AppColor.text)),
          ),
        )
      ]),
      body: isOk
          ? Center(
              child: Image.memory(
                cropImg!,
                width: 375.w,
                height: 375.w,
                fit: BoxFit.fill,
              ),
            )
          : FutureBuilder<Uint8List>(
              future: widget.image.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Crop(
                      controller: cropCtrl,
                      initialSize: 1,
                      image: snapshot.requireData,
                      baseColor: Colors.black,
                      maskColor: Colors.white.withAlpha(100),
                      cornerDotBuilder: (size, edgeAlignment) {
                        return DotControl(
                          color: AppColor.theme,
                        );
                      },
                      interactive: true,
                      aspectRatio: 1.0,
                      radius: 0,
                      initialAreaBuilder: (rect) {
                        return Rect.fromCenter(
                            center: Offset(ScreenUtil().screenWidth / 2,
                                ScreenUtil().screenHeight / 2 - kToolbarHeight),
                            width: 365.w,
                            height: 365.w);
                      },
                      onCropped: (value) {
                        cropImg = value;
                        setState(() {
                          isOk = true;
                        });
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: CustomEmptyView(
                      isLoading: true,
                    ),
                  );
                }
              },
            ),
    );
  }

  cropImage() {
    cropCtrl.crop();
    // bakeOrientation()
    // fileData = await cropImageDataWithDartLibrary(state: key.currentState!);
    // if (myImageState != null) {
    //   ExtendedImageEditorState state =
    //       key.currentState! as ExtendedImageEditorState;
    //   Rect? cropRect = state.getCropRect();

    //   final lb = await im.loadBalancer;
    //   Image src = await lb.run<Image, List<int>>(im.decodeImage, cropImg);
    //   print("123");
    // }
    // ExtendedImageEditorState state =
    // //     (key.currentState as ExtendedImageEditorState);
    // Rect? cropRect = state.getCropRect();

    // Uint8List data = state.rawImageData;
    // if (cropRect != null) {
    // final Uint8List data = kIsWeb &&
    //       state.widget.extendedImageState.imageWidget.image
    //           is ExtendedNetworkImageProvider
    //   ? await _loadNetwork(state.widget.extendedImageState.imageWidget.image
    //       as ExtendedNetworkImageProvider)

    //   im.Image image = im.copyCrop(
    //       im.Image.fromBytes(
    //           width: cropRect.width.toInt(),
    //           height: cropRect.width.toInt(),
    //           bytes: data.buffer),
    //       x: cropRect.left.toInt(),
    //       y: cropRect.top.toInt(),
    //       width: cropRect.width.toInt(),
    //       height: cropRect.height.toInt());
    // }
    // }
  }
}
