import 'package:cxhighversion2/component/app_image_picker.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomUploadImageView extends StatefulWidget {
  final int maxImgCount;
  final Function(List imgs)? imageUpload;
  final String? tipStr;
  final String title;
  final bool uploadVideo;
  const CustomUploadImageView(
      {super.key,
      this.maxImgCount = 6,
      this.imageUpload,
      this.title = "上传凭证",
      this.uploadVideo = false,
      this.tipStr});

  @override
  State<CustomUploadImageView> createState() => _CustomUploadImageViewState();
}

class _CustomUploadImageViewState extends State<CustomUploadImageView> {
  upLoadImg(List imgFiles) {
    Http().uploadImages(
      imgFiles,
      success: (json) {
        if ((json["code"] ?? "-1") == "0") {
          Map data = json["data"] ?? {};
          String src = data["src"] ?? "";
          if (src.isNotEmpty) {
            setState(() {
              uploadImageUrls.add(src);
            });
          }
        }
        if (widget.imageUpload != null) {
          widget.imageUpload!(uploadImageUrls);
        }
      },
      fail: (reason, code, json) {},
      after: () {},
      resList: (success, jsons) {
        if (success) {
          for (var e in jsons) {
            Map res = e.data;
            Map data = res["data"] ?? {};
            String src = data["src"] ?? "";
            if (src.isNotEmpty) {
              uploadImageUrls.add(src);
            }
          }
          setState(() {});
          if (widget.imageUpload != null) {
            widget.imageUpload!(uploadImageUrls);
          }
        } else {}
      },
    );
  }

  List uploadImageUrls = [];
  late AppImagePicker imagePicker;
  @override
  void initState() {
    imagePicker = AppImagePicker(
      multiple: true,
      type: widget.uploadVideo
          ? AppImageUploadType.imageOrVideo
          : AppImageUploadType.image,
      imgsCallback: (imgFile) {
        upLoadImg(imgFile);
      },
      imgCallback: (imgFile) {
        upLoadImg([imgFile]);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 345.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: Column(
          children: [
            gwb(345),
            sbhRow([
              getSimpleText(widget.title, 14, AppColor.text3),
            ], width: 345 - 15.5 * 2, height: 50),
            SizedBox(
                width: 315.w,
                child: Wrap(
                  runSpacing: 15.w / 2 - 0.1.w,
                  spacing: 15.w / 2 - 0.1.w,
                  children: [
                    ...List.generate(
                        uploadImageUrls.length,
                        (index) => SizedBox(
                              width: 100.w,
                              height: 100.w,
                              child: Stack(
                                children: [
                                  Align(
                                      alignment: Alignment.center,
                                      child: CustomButton(
                                        onPressed: () {
                                          toCheckImg(
                                              image:
                                                  "${AppDefault().imageUrl}${uploadImageUrls[index]}");
                                        },
                                        child: CustomNetworkImage(
                                          src: AppDefault().imageUrl +
                                              uploadImageUrls[index],
                                          width: 90.w,
                                          height: 90.w,
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: CustomButton(
                                      onPressed: () {
                                        deleteImg(index);
                                      },
                                      child: SizedBox(
                                        width: 20.w,
                                        height: 20.w,
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Image.asset(
                                            assetsName(
                                              "statistics/machine/icon_phone_delete",
                                            ),
                                            width: 18.w,
                                            height: 18.w,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )),
                    Visibility(
                        visible: uploadImageUrls.length < widget.maxImgCount,
                        child: CustomButton(
                          onPressed: () {
                            imagePicker.showImage(
                                Global.navigatorKey.currentContext!,
                                imgCount: widget.maxImgCount -
                                    uploadImageUrls.length);
                          },
                          child: Container(
                            width: 100.w,
                            height: 100.w,
                            color: AppColor.pageBackgroundColor,
                            child: Center(
                                child: centClm([
                              Image.asset(
                                assetsName("machine/icon_img_upload"),
                                width: 31.5.w,
                                fit: BoxFit.fitWidth,
                              ),
                              ghb(5),
                              getSimpleText("上传图片", 12, AppColor.assisText)
                            ])),
                          ),
                        )),
                  ],
                )),
            sbhRow([
              getSimpleText(widget.tipStr ?? "注：最多可上传${widget.maxImgCount}张图片",
                  12, AppColor.text3)
            ], width: 315, height: 32),
            ghb(3),
          ],
        ));
  }

  deleteImg(int index) {
    showAlert(
      Global.navigatorKey.currentContext!,
      "确定要删除该照片吗",
      confirmOnPressed: () {
        setState(() {
          uploadImageUrls.removeAt(index);
        });
        if (widget.imageUpload != null) {
          widget.imageUpload!(uploadImageUrls);
        }
        Navigator.pop(context);
      },
    );
  }
}
