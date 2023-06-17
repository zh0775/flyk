import 'dart:convert';
import 'dart:ui' as ui;

import 'package:card_swiper/card_swiper.dart';
import 'package:cxhighversion2/component/app_wechat_manager.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dotted_line_painter.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:universal_html/html.dart' as html;

class ShareInviteBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ShareInviteController>(ShareInviteController());
  }
}

class ShareInviteController extends GetxController {
  GlobalKey shareViewKey = GlobalKey();
  List<ScreenshotController> screens = [];
  List<GlobalKey> screenKeys = [];
  SwiperControl swiperControl = SwiperControl(
    size: 317.w,
  );
  // late final StreamSubscription<BaseResp> respSubs;
  // AuthResp? authResp;
  // void listenResp(BaseResp resp) {
  //   if (resp is AuthResp) {
  //     authResp = resp;
  //     final String content = 'auth: ${resp.errorCode} ${resp.errorMsg}';
  //     // ShowToast.normal("resp.errorCode == ${resp.errorCode}");
  //     // _showTips('登录', content);
  //   } else if (resp is ShareMsgResp) {
  //     final String content = 'share: ${resp.errorCode} ${resp.errorMsg}';
  //     // _showTips('分享', content);
  //     // ShowToast.normal(content);
  //   } else if (resp is PayResp) {
  //     final String content = 'pay: ${resp.errorCode} ${resp.errorMsg}';
  //     // _showTips('支付', content);
  //   } else if (resp is LaunchMiniProgramResp) {
  //     final String content = 'mini program: ${resp.errorCode} ${resp.errorMsg}';
  //     // _showTips('拉起小程序', content);
  //   }
  // }
  final _pageIndex = 0.obs;
  int get pageIndex => _pageIndex.value;
  set pageIndex(v) => _pageIndex.value = v;
  Map homeData = {};

  String shareUrl = "";
  // loadRegistUrl() {
  //   simpleRequest(
  //       url: Urls.getAPPExternalRegInfo,
  //       params: {},
  //       success: (success, json) {
  //         if (success) {
  //           shareUrl = json["data"]["regUrl"] ?? "";
  //           update();
  //         }
  //       },
  //       after: () {},
  //       useCache: true);
  // }

  List btns = [
    // {"name": "微信好友", "img": "share/wx_friend2"},
    // {"name": "朋友圈", "img": "share/pyq2"},
    {"name": "保存图片", "img": "share/icon_share_download"}
  ];

  double imageHeight = 0;
  double imageWidth = 300;
  Map publicHomeData = {};
  List dataList = [];

  @override
  void onInit() {
    // respSubs = Wechat.instance.respStream().listen(listenResp);
    // loadRegistUrl();
    homeData = AppDefault().homeData;
    publicHomeData = AppDefault().publicHomeData;

    if (HttpConfig.baseUrl.contains(AppDefault.oldSystem)) {
      shareUrl =
          ((publicHomeData["webSiteInfo"] ?? {})["System_Download_Url"] ?? "");
      if (shareUrl.isNotEmpty) {
        String t = shareUrl.substring(shareUrl.length - 1, shareUrl.length);
        if (t == "/") {
          shareUrl = shareUrl.substring(0, shareUrl.length - 1);
        }
      }
      // dataList = (publicHomeData["appCofig"] ?? {})["shareBanner"] ?? [];
      dataList = (publicHomeData["appCofig"] ?? {})["shareBanner"] ?? [];
    } else {
      shareUrl = (((publicHomeData["webSiteInfo"] ?? {})["app"] ??
              {})["apP_ExternalReg_Url"] ??
          "");
      if (shareUrl.isNotEmpty) {
        String t = shareUrl.substring(shareUrl.length - 1, shareUrl.length);
        if (t == "/") {
          shareUrl = shareUrl.substring(0, shareUrl.length - 1);
        }
      }
      // dataList = (publicHomeData["appCofig"] ?? {})["shareBanner"] ?? [];
      dataList = (publicHomeData["appCofig"] ?? {})["hotRecommend"] ?? [];
    }

    if (dataList.isEmpty) {
      dataList.add({"apP_Pic": "common/bg_default"});
    }
    for (var e in dataList) {
      screens.add(ScreenshotController());
      screenKeys.add(GlobalKey());
    }

    AppWechatManager().registApp();
    super.onInit();
  }

  double boxHeight = 0;
  bool screenNotLong = false;
  bool isFirst = true;
  // double pageScale = (300 - 22.5 * 2) / 300;
  double pageScale = (300 - 22.5 * 2) / 300;
  dataInit(BuildContext ctx) {
    if (!isFirst) return;
    isFirst = false;
    double appbarHeight = (Scaffold.of(ctx).appBarMaxHeight ?? 0);
    boxHeight = ScreenUtil().screenHeight -
        appbarHeight -
        paddingSizeBottom(ctx) -
        paddingSizeTop(ctx);
    ScreenUtil util = ScreenUtil();
    imageHeight = (300.w / util.screenWidth) / pageScale * 540.w;
    double tmpHeight = (300.w / util.screenWidth) * 540.w;
    double realSpace = (boxHeight - 15.w - imageHeight - 105.w - 20.w);

    if (realSpace < 0) {
      imageHeight += realSpace;
      imageWidth = imageWidth.w * (tmpHeight / imageHeight);
    } else {
      imageWidth = imageWidth.w;
    }
    screenNotLong = realSpace < 0;
  }
}

class ShareInvite extends GetView<ShareInviteController> {
  const ShareInvite({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "分享邀请"),
        body: Builder(builder: (buildCtx) {
          controller.dataInit(buildCtx);
          return Stack(children: [
            Positioned(
                top: 15.w,
                left: 0,
                right: 0,
                // height: controller.imageHeight,
                child: Column(children: [
                  SizedBox(
                      width: 375.w,
                      // height: !kIsWeb ? 567.w : 537.w,

                      height: controller.imageHeight,
                      child: Swiper(
                          itemCount: controller.dataList.length,
                          viewportFraction: 300 / 375,
                          // scale: controller.pageScale,
                          scale: 0.65,
                          itemBuilder: (context, index) {
                            print(
                                "${controller.imageWidth / controller.imageHeight}");
                            return sharePage(index);
                          },
                          onIndexChanged: (value) {
                            controller.pageIndex = value;
                          })),
                  ghb(15),
                  centRow(List.generate(
                      controller.dataList.length,
                      (index) => GetX<ShareInviteController>(builder: (_) {
                            return AnimatedContainer(
                              margin:
                                  EdgeInsets.only(left: index != 0 ? 5.w : 0),
                              duration: const Duration(milliseconds: 300),
                              width: controller.pageIndex == index ? 15.w : 5.w,
                              height: 5.w,
                              decoration: BoxDecoration(
                                  color: controller.pageIndex == index
                                      ? AppColor.theme
                                      : AppColor.theme.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(2.5.w)),
                            );
                          })))
                ])),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 105.w + paddingSizeBottom(context),
                child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      bottom: paddingSizeBottom(context),
                    ),
                    // decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius:
                    //         BorderRadius.vertical(top: Radius.circular(8.w)),
                    //     boxShadow: [
                    //       BoxShadow(
                    //           color: const Color(0x26000000), blurRadius: 5.w)
                    //     ]),
                    child: centRow(List.generate(
                        controller.btns.length,
                        (index) => Padding(
                              padding:
                                  EdgeInsets.only(left: index == 0 ? 0 : 36.w),
                              child: shareButotn(index, context),
                            )))))
          ]);
        }));
  }

  Widget sharePage(int index, {bool shot = false}) {
    Map data = controller.dataList[index];
    bool isNetworkImage = ((data["apP_Pic"] ?? "") as String).contains(".");
    return Container(
        width: controller.imageWidth,
        height: controller.imageHeight,
        decoration: const BoxDecoration(color: Colors.white
            // boxShadow: [
            //   BoxShadow(
            //       color: const Color(0x26333333),
            //       offset: Offset(0, 5.w),
            //       blurRadius: 15.w)
            // ]
            ),
        child: Stack(children: [
          Positioned.fill(
              child: isNetworkImage
                  ? CustomNetworkImage(
                      src: AppDefault().imageUrl + (data["apP_Pic"] ?? ""),
                      width: controller.imageWidth,
                      // height: !kIsWeb ? 450.w : 443.w,
                      height: controller.imageHeight,
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter,
                    )
                  : Image.asset(assetsName((data["apP_Pic"] ?? "")),
                      width: controller.imageWidth,
                      // height: !kIsWeb ? 450.w : 443.w,
                      height: controller.imageHeight,
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter)),
          Positioned(
              bottom: 15.w,
              right: 20.w,
              child: centClm([
                GetBuilder<ShareInviteController>(builder: (_) {
                  return Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      width: 75.w,
                      height: 75.w,
                      // color: Colors.amber,
                      child: QrImageView(
                          data: controller.shareUrl != null &&
                                  controller.shareUrl.isNotEmpty
                              ? "${controller.shareUrl}?id=${controller.homeData["u_Number"] ?? ""}"
                              : "",
                          // size: !kIsWeb ? 66.w : 56.w,
                          size: 72.w,
                          padding: EdgeInsets.zero));
                })
              ])),
          Positioned(
              left: 23.w,
              bottom: 20.5.w,
              child: getSimpleText(
                  "邀请码：${controller.homeData["u_Number"] ?? ""}",
                  15,
                  Colors.white,
                  textHeight: 1.0))
        ]));
  }

  Widget shareButotn(int idx, BuildContext context) {
    Map btnData = controller.btns[idx];
    return CustomButton(
      onPressed: () async {
        // if (controller.webCtrl == null) {
        //   ShowToast.normal("请等待页面加载完毕");
        // }
        // RenderRepaintBoundary boundary = controller
        //     .screenKeys[controller.pageIndex].currentContext!
        //     .findRenderObject() as RenderRepaintBoundary;
        // ui.Image image = await boundary.toImage();
        // ByteData? byteData =
        //     await (image.toByteData(format: ui.ImageByteFormat.png));

        // if (byteData == null) {
        //   ShowToast.normal("出现错误，请稍后再试");
        //   return;
        // }
        // Uint8List imageBytes = byteData.buffer.asUint8List();
        // RenderRepaintBoundary? boundary =
        //     controller.shareViewKey.currentContext?.findRenderObject()
        //         as RenderRepaintBoundary?;

        // ui.Image image = await boundary!.toImage();
        // ByteData? byteData =
        //     await (image.toByteData(format: ui.ImageByteFormat.png));

        // if (byteData == null) {
        //   // ShowToast.normal("出现错误，请稍后再试");
        //   return;
        // }
        // Uint8List imageBytes = byteData.buffer.asUint8List();

        Uint8List imageBytes = await ScreenshotController().captureFromWidget(
            sharePage(controller.pageIndex, shot: true),
            delay: const Duration(milliseconds: 100),
            context: context);

        if (btnData["name"] == "微信好友") {
          AppWechatManager().sharePriendWithFile(imageBytes);
        } else if (btnData["name"] == "朋友圈") {
          AppWechatManager().shareTimelineWithFile(imageBytes);
        } else if (btnData["name"] == "保存图片") {
          saveAssetsImg(imageBytes);
        } else if (btnData["name"] == "复制链接") {
          copyClipboard(
              "${controller.shareUrl}?id=${controller.homeData["u_Number"] ?? ""}");
        }
      },
      child: centClm([
        Container(
          width: 52.5.w,
          height: 52.5.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(52.5.w / 2)),
          child: Image.asset(
            assetsName(btnData["img"] ?? ""),
            // width: 30.5.w,
            height: 30.w,
            width: 30.w,
            fit: BoxFit.fill,
          ),
        ),
        ghb(8),
        getSimpleText(btnData["name"], 12, AppColor.text2)
      ]),
    );
  }

  saveAssetsImg(Uint8List? imageBytes) async {
    // bool havePermission = await checkStoragePermission();
    // if (!havePermission) {
    //   ShowToast.normal("没有权限，无法保存图片");
    //   return;
    // }
    // Uint8List? byte = await controller.webCtrl!.takeScreenshot();
    if (kIsWeb) {
      if (imageBytes != null) {
        final base64data = base64Encode(imageBytes.toList());
        final a =
            html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');
        a.download = "${DateTime.now().millisecondsSinceEpoch}";
        a.click();
        a.remove();
      }
      // js.context.callMethod(
      //   "savePicture",
      //   [
      //     // html.Blob(
      //     //   imageBytes,
      //     // ),
      //     imageBytes,
      //     "${DateTime.now().millisecondsSinceEpoch}.png"
      //   ],
      // );
    } else {
      saveImageToAlbum(imageBytes);
    }
  }

  Widget getDashLine() {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(298.w, 0);
    return CustomPaint(
        painter: CustomDottedPinePainter(
            color: AppColor.textGrey,
            dashSingleWidth: 6,
            dashSingleGap: 8,
            strokeWidth: 1,
            // path: parseSvgPathData('m0,0 l0,${62.5.w} Z')),
            path: path),
        size: Size(298.w, 1.w));
  }
}
