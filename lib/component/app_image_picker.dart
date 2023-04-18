import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

enum AppImageUploadType { image, video, imageOrVideo }

class AppImagePicker {
  final ImagePicker _picker = ImagePicker();
  final Function(XFile imgFile)? imgCallback;
  final Function(List<XFile> imgFile)? imgsCallback;
  final int count;
  final int imageQuality;
  final bool multiple;
  final AppImageUploadType type;
  AppImagePicker(
      {this.imgCallback,
      this.imgsCallback,
      this.multiple = false,
      this.count = 9,
      this.imageQuality = 30,
      this.type = AppImageUploadType.image});
  List<XFile>? _imageFileList;
  // Pick an image

  double height = 200;

  void showImage(BuildContext context, {int? imgCount}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return SizedBox(
            height: 200.w,
            child: Column(
              children: [
                getButton('拍照', () {
                  loadAssets(true);
                  Navigator.pop(context);
                  // _getImageFromCamera(ctx);
                }),
                getButton('从相册选择', () async {
                  if (kIsWeb) {
                    loadAssets(false, imgCount: imgCount);
                  } else {
                    // if (Platform.isIOS) {
                    // } else {
                    // }
                    PermissionStatus status = await Permission.photos.status;
                    if (status.isDenied) {
                      status = await Permission.photos.request();
                      if (status.isPermanentlyDenied) {
                        showAlert(
                          Global.navigatorKey.currentContext!,
                          "没有权限使用相册，请在设置中授予APP相册权限",
                          confirmOnPressed: () {
                            AppSettings.openAppSettings();
                          },
                        );
                      }
                    }
                    if (status.isGranted ||
                        await Permission.camera.request().isGranted) {
                      loadAssets(false, imgCount: imgCount);
                    }
                  }

                  Navigator.pop(context);
                  // _getImageFromGallery(ctx);
                }),
                getButton('取消', () {
                  Navigator.pop(context);
                }),
              ],
            ),
          );
        });
  }

  Widget getButton(String title, void Function() pressed) {
    return SizedBox(
      height: 200.0.w / 3,
      width: 375.w,
      child: TextButton(
        onPressed: pressed,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 16.sp, color: AppColor.textBlack),
          ),
        ),
      ),
    );
  }

  void loadAssets(bool isCamera, {int? imgCount}) async {
    if (!kIsWeb && !isCamera && !multiple) {
      List<AssetEntity>? images = await AssetPicker.pickAssets(
        Global.navigatorKey.currentContext!,
        pickerConfig: AssetPickerConfig(
            maxAssets: 1,
            specialPickerType: SpecialPickerType.noPreview,
            textDelegate: const AssetPickerTextDelegate(),
            requestType: type == AppImageUploadType.image
                ? RequestType.image
                : type == AppImageUploadType.video
                    ? RequestType.video
                    : RequestType.common),
      );
      if (images != null && images.isNotEmpty) {
        AssetEntity entity = images.first;
        File? file = await entity.file;

        if (file != null) {
          // if (result != null) {
          // image = XFile.fromData(result);
          File result =
              await FlutterNativeImage.compressImage(file.path, quality: 30);
          final XFile image = XFile(result.path);
          if (imgCallback != null) {
            imgCallback!(image);
          }
          // }
        }
      }
    } else {
      if (multiple && !isCamera) {
        if (kIsWeb) {
          final List<XFile> pickedFiles = await _picker.pickMultiImage();
          if (pickedFiles != null &&
              imgsCallback != null &&
              imgsCallback != null) {
            imgsCallback!(pickedFiles);
          }
        } else {
          List<AssetEntity>? images = await AssetPicker.pickAssets(
            Global.navigatorKey.currentContext!,
            pickerConfig: AssetPickerConfig(
                maxAssets: imgCount ?? count,
                specialPickerType: (imgCount ?? count) > 1
                    ? null
                    : SpecialPickerType.noPreview,
                textDelegate: const AssetPickerTextDelegate(),
                requestType: type == AppImageUploadType.image
                    ? RequestType.image
                    : type == AppImageUploadType.video
                        ? RequestType.video
                        : RequestType.common),
          );

          if (images != null && images.isNotEmpty) {
            List<XFile> xImages = [];
            for (AssetEntity e in images) {
              File? file = await e.file;
              if (file != null) {
                File result = await FlutterNativeImage.compressImage(file.path,
                    quality: 30);
                final XFile image = XFile(result.path);
                xImages.add(image);
              }
            }
            if (imgsCallback != null) {
              imgsCallback!(xImages);
            }
          }
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          // imageQuality:imageQuality,
        );
        if (pickedFile != null && imgCallback != null && imgCallback != null) {
          imgCallback!(pickedFile);
        }
      }
    }
  }

  // void _setImageFileListFromFile(XFile? value) {
  //   _imageFileList = value == null ? null : <XFile>[value];
  // }
}

    
  // List<Asset> resultList;
  // String error;
  //   resultList = await MultiImagePicker.pickImages(
  //     maxImages: count,
  //     enableCamera: isCamera,
  //     // materialOptions: MaterialOptions(
  //     //     actionBarTitle: "选择图像",
  //     //     allViewTitle: "所有图像",
  //     //     // 显示所有照片，值为 false 时显示相册
  //     //     startInAllView: true,
  //     //     actionBarColor: '#00b1f5',
  //     //     textOnNothingSelected: '没有选择图像',
  //     //     useDetailsView: true,
  //     //     selectionLimitReachedText: "超过最大选择数目."),
  //     // cupertinoOptions: CupertinoOptions(
  //     //     backgroundColor: '#E6B85C',
  //     //     takePhotoIcon: '选择图像',
  //     //     selectionCharacter: '选择图像2')
  //   );

  //   if (resultList != null && imageSelected != null) {
  //     imageSelected(resultList);
  //     // List<Future> list = List.generate(resultList.length, (index) {
  //     //   Asset asset = resultList[index];
  //     //   return asset.getByteData();
  //     // });
  //     // Future.wait(list).then((value) {
  //     //   imageSelected(value);
  //     // });
  //   }
  // }

