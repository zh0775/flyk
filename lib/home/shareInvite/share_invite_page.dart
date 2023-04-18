import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_check_photo.dart';
import 'package:cxhighversion2/home/shareInvite/share_invite_preview.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import 'package:image_gallery_saver/image_gallery_saver.dart';

class ShareInvitePageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ShareInvitePageController>(ShareInvitePageController());
  }
}

class ShareInvitePageController extends GetxController {
  PageController pageCtrl = PageController();

  final _addPersonInfo = false.obs;
  bool get addPersonInfo => _addPersonInfo.value;
  set addPersonInfo(v) => _addPersonInfo.value = v;

  Map data = {
    "type1": [
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
      {"id": 0, "img": "home/jifen_04"},
    ],
    "type2": [
      {"id": 0, "img": "home/jifen_02"},
      {"id": 0, "img": "home/jifen_02"},
      {"id": 0, "img": "home/jifen_02"},
      {"id": 0, "img": "home/jifen_02"},
      {"id": 0, "img": "home/jifen_02"},
      {"id": 0, "img": "home/jifen_02"},
      {"id": 0, "img": "home/jifen_02"},
      {"id": 0, "img": "home/jifen_02"},
      {"id": 0, "img": "home/jifen_02"},
      {"id": 0, "img": "home/jifen_02"},
    ],
    "type3": [
      {
        "id": 0,
        "text": "这个世界不会因为你的疲惫，而停下它的脚步。",
      },
      {
        "id": 1,
        "text":
            "也许你一生中走错了不少路，看错了不少人， 承受了许多的叛逆，落魄的狼狈不甚，但都 无所谓，只要还活着，就总有盼望，余生很 长，",
      },
      {
        "id": 2,
        "text":
            "也许你一生中走错了不少路，看错了不少人，承受了许多的叛逆，落魄的狼狈不甚，但都无所谓，只要还活着，就总有盼望，余生很长，何必慌张。。",
      },
      {
        "id": 3,
        "text": "这个世界不会因为你的疲惫，而停下它的脚步。",
      },
    ],
  };

  String currentText = "";
  String currentImg = "";

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    _topIndex.value = v;
    pageCtrl.animateToPage(topIndex,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  @override
  void dispose() {
    pageCtrl.dispose();
    super.dispose();
  }
}

class ShareInvitePage extends GetView<ShareInvitePageController> {
  const ShareInvitePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "分享邀请"),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 44.w,
              child: GetX<ShareInvitePageController>(
                init: controller,
                builder: (controller) {
                  return topButtons();
                },
              )),
          Positioned(
              top: 44.w,
              left: 0,
              right: 0,
              bottom: 0,
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller.pageCtrl,
                children: [
                  photoView(controller.data["type1"], context),
                  photoView(controller.data["type2"], context),
                  textView(controller.data["type3"], context)
                ],
              ))
        ],
      ),
    );
  }

  Widget photoView(List datas, BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          ghb(15),
          Wrap(
            spacing: 15.w,
            runSpacing: 15.w,
            children: [
              ...datas
                  .asMap()
                  .entries
                  .map((e) => CustomButton(
                        onPressed: () {
                          ShowToast.normal("已选择");
                          controller.currentImg = e.value["img"];
                          showShare(context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.w),
                          child: Image.asset(
                            assetsName(e.value["img"]),
                            width: 165.w,
                            height: 241.w,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ))
                  .toList()
            ],
          ),
          ghb(15),
        ],
      ),
    );
  }

  Widget textView(List datas, BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 15.w),
      physics: const BouncingScrollPhysics(),
      itemCount: datas != null && datas.isNotEmpty ? datas.length : 0,
      itemBuilder: (context, index) {
        double textHeight = calculateTextHeight(datas[index]["text"], 15,
                FontWeight.normal, 288.5, 1000, context) +
            20.w * 2;
        textHeight = (textHeight < 133.5.w ? 133.5.w : textHeight);
        return Align(
          child: Container(
            margin: EdgeInsets.only(top: 15.w),
            width: 345.w,
            height: textHeight,
            // padding: EdgeInsets.symmetric(vertical: 20.w),
            decoration: getDefaultWhiteDec(),
            child: Stack(
              children: [
                // Positioned.fill(
                //     child: ClipRRect(
                //   borderRadius: BorderRadius.circular(5.w),
                //   child: Image.asset(
                //     assetsName(""),
                //     width: 345.w,
                //     height: textHeight,
                //     fit: BoxFit.fill,
                //   ),
                // )),
                Positioned.fill(
                    child: Center(
                  child: sbRow([
                    getWidthText(datas[index]["text"], 15, AppColor.textBlack,
                        288.5, 1000)
                  ], width: 345 - 15 * 2),
                )),
                Positioned(
                    bottom: 13.w,
                    right: 9.5.w,
                    width: 47.w,
                    height: 22.w,
                    child: CustomButton(
                      onPressed: () {
                        controller.currentText = datas[index]["text"];
                        copyClipboard(datas[index]["text"]);
                      },
                      child: Container(
                        width: 47.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.w),
                            color: AppColor.textBlack),
                        child: Center(
                            child: getSimpleText("复制", 12, Colors.white)),
                      ),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget topButtons() {
    return Center(
      child: Row(
        children: [
          ...List.generate(
              3,
              (index) => CustomButton(
                    onPressed: () => controller.topIndex = index,
                    child: Container(
                      color: Colors.white,
                      width: (375 / 3).w,
                      height: 44.w,
                      child: Center(
                        child: getSimpleText(
                            index == 0
                                ? "热门推荐"
                                : index == 1
                                    ? "节日节气"
                                    : "日常文案",
                            16,
                            controller.topIndex == index
                                ? AppColor.buttonTextBlue
                                : AppColor.textGrey,
                            isBold: true),
                      ),
                    ),
                  )).toList()
        ],
      ),
    );
  }

  showShare(BuildContext context) {
    Get.bottomSheet(
      Container(
        width: 375.w,
        height: 478.w + paddingSizeBottom(context) + 60.w,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.w))),
        child: Column(
          children: [
            ghb(26.5),
            CustomButton(
              onPressed: () {
                toCheckImg(image: assetsName(controller.currentImg));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.w),
                child: Image.asset(
                  assetsName(controller.currentImg),
                  width: 165.w,
                  height: 245.w,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            ghb(33.5),
            sbhRow([
              centRow([
                getSimpleText("附加个人信息", 15, AppColor.textBlack, isBold: true),
                gwb(10),
                CustomButton(
                  onPressed: () {
                    Get.to(
                        ShareInvitePreview(
                            image: controller.currentImg,
                            haveInfo: controller.addPersonInfo),
                        binding: ShareInvitePreviewBinding(),
                        transition: Transition.downToUp);
                  },
                  child: Container(
                    width: 40.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                        color: const Color(0xFFCCCCCC),
                        borderRadius: BorderRadius.circular(4.w)),
                    child: Center(
                      child: getSimpleText("预览", 12, Colors.white),
                    ),
                  ),
                )
              ]),
              GetX<ShareInvitePageController>(
                init: controller,
                initState: (_) {},
                builder: (_) {
                  return Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: controller.addPersonInfo,
                      onChanged: (value) {
                        controller.addPersonInfo = value;
                      },
                    ),
                  );
                },
              )
            ], width: 375 - 25 * 2, height: 30.w),
            SizedBox(
              height: 76.w,
              child: Center(
                child: sbRow([
                  gline(18.5, 1, color: AppColor.textBlack),
                  getSimpleText("分享图片到", 14, AppColor.textBlack),
                  gline(18.5, 1, color: AppColor.textBlack),
                ], width: 150),
              ),
            ),
            sbRow([
              shareBtn(0),
              shareBtn(1),
              shareBtn(2),
            ], width: 375 - 62 * 2),
            ghb(19),
            CustomButton(
              onPressed: () {
                Get.back();
              },
              child: Container(
                width: 375.w,
                height: 60.w,
                color: AppColor.pageBackgroundColor2,
                child: Center(
                  child:
                      getSimpleText("取消", 17, AppColor.textBlack, isBold: true),
                ),
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget shareBtn(int index) {
    return CustomButton(
      onPressed: () {
        if (index == 0) {
        } else if (index == 1) {
        } else {
          saveAssetsImg();
        }
      },
      child: sbClm([
        Image.asset(
          assetsName(
              "share/${index == 0 ? "wx_friend" : index == 1 ? "pyq" : "save"}"),
          height: 25.w,
          fit: BoxFit.fitHeight,
        ),
        ghb(8),
        getSimpleText(
            index == 0
                ? "微信好友"
                : index == 1
                    ? "微信朋友圈"
                    : "保存图片",
            12,
            AppColor.textBlack)
      ], height: 47),
    );
  }

  saveAssetsImg() async {
    // bool havePermission = await checkStoragePermission();
    // if (!havePermission) {
    //   ShowToast.normal("没有权限，无法保存图片");
    //   return;
    // }
    var key = GlobalKey();
    Widget imageWidget = RepaintBoundary(
      key: key,
      child: Image.asset(assetsName(controller.currentImg)),
    );
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));

    if (byteData != null) {
      saveImageToAlbum(byteData.buffer.asUint8List());
    }
  }
}
