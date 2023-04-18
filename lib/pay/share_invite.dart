import 'dart:convert';
import 'dart:ui' as ui;

import 'package:card_swiper/card_swiper.dart';
import 'package:cxhighversion2/component/app_wechat_manager.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dotted_line_painter.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
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
  int pageIndex = 0;
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
    if (dataList.isEmpty) {
      dataList.add({"apP_Pic": "share/bg_default"});
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
        appBar: getDefaultAppBar(context, "邀请好友"),
        body: Builder(builder: (buildCtx) {
          controller.dataInit(buildCtx);
          return Stack(
            children: [
              Positioned(
                  top: 15.w,
                  left: 0,
                  right: 0,
                  height: controller.imageHeight,
                  child: SizedBox(
                    width: 375.w,
                    // height: !kIsWeb ? 567.w : 537.w,
                    height: controller.imageHeight,
                    child: Swiper(
                      itemCount: controller.dataList.length,
                      viewportFraction: controller.imageWidth / 375,
                      scale: controller.pageScale,
                      itemBuilder: (context, index) {
                        print(
                            "${controller.imageWidth / controller.imageHeight}");
                        return sharePage(index);
                      },
                      onIndexChanged: (value) {
                        controller.pageIndex = value;
                      },
                    ),
                  )),
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
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(8.w)),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0x26000000), blurRadius: 5.w)
                      ]),
                  child: centRow([
                    shareButotn(3, context),
                    gwb(41.5),
                    shareButotn(2, context),
                  ]),
                ),
              ),
            ],
          );
        }));
  }

  Widget sharePage(int index, {bool shot = false}) {
    Map data = controller.dataList[index];
    bool isNetworkImage = ((data["apP_Pic"] ?? "") as String).contains(".");
    return Container(
      width: controller.imageWidth,
      height: controller.imageHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //       color: const Color(0x26333333),
        //       offset: Offset(0, 5.w),
        //       blurRadius: 15.w)
        // ]
      ),
      child: Stack(
        children: [
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
                : Image.asset(
                    assetsName((data["apP_Pic"] ?? "")),
                    width: controller.imageWidth,
                    // height: !kIsWeb ? 450.w : 443.w,
                    height: controller.imageHeight,
                    fit: BoxFit.fill,
                    alignment: Alignment.topCenter,
                  ),
          ),
          Positioned(
              bottom: 15.w,
              right: 20.w,
              child: centClm([
                GetBuilder<ShareInviteController>(
                  builder: (_) {
                    return Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      width: 75.w,
                      height: 75.w,
                      // color: Colors.amber,
                      child: QrImage(
                        data: controller.shareUrl != null &&
                                controller.shareUrl.isNotEmpty
                            ? "${controller.shareUrl}?id=${controller.homeData["u_Number"] ?? ""}"
                            : "",
                        // size: !kIsWeb ? 66.w : 56.w,
                        size: 72.w,
                        padding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
                // ghb(3),
                // getSimpleText("推荐码", 12, Colors.black),
                // sbRow(
                //   [

                //   ],
                //   width: 345 - 20 * 2,
                // ),
              ])),
          Positioned(
            left: 23.w,
            bottom: 20.5.w,
            child: getSimpleText("邀请码：${controller.homeData["u_Number"] ?? ""}",
                15, Colors.white,
                textHeight: 1.0),
          )
        ],
      ),
    );
  }

  Widget shareButotn(int idx, BuildContext context) {
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

        if (idx == 0) {
          AppWechatManager().sharePriendWithFile(imageBytes);
        } else if (idx == 1) {
          AppWechatManager().shareTimelineWithFile(imageBytes);
        } else if (idx == 2) {
          saveAssetsImg(imageBytes);
        } else if (idx == 3) {
          copyClipboard(
              "${controller.shareUrl}?id=${controller.homeData["u_Number"] ?? ""}");
        }
      },
      child: centClm([
        Image.asset(
          assetsName(idx == 0
              ? "share/wx_friend2"
              : idx == 1
                  ? "share/pyq2"
                  : idx == 2
                      ? "share/icon_share_download"
                      : "share/icon_share_copy"),
          // width: 30.5.w,
          height: 50.w,
          fit: BoxFit.fitHeight,
        ),
        ghb(5),
        getSimpleText(
            idx == 0
                ? "微信好友"
                : idx == 1
                    ? "微信朋友圈"
                    : idx == 2
                        ? "保存图片"
                        : "复制链接",
            12,
            AppColor.text2)
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
      size: Size(298.w, 1.w),
    );
  }

  Future<Uint8List> captureFromWidget(Widget widget,
      {Duration delay = const Duration(seconds: 1),
      double? pixelRatio,
      BuildContext? context,
      Size? targetSize,
      BorderRadiusGeometry? borderRadius}) async {
    ui.Image image = await widgetToUiImage(widget,
        delay: delay,
        pixelRatio: pixelRatio,
        context: context,
        targetSize: targetSize,
        borderRadius: borderRadius);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return byteData!.buffer.asUint8List();
  }

  Future<ui.Image> widgetToUiImage(Widget widget,
      {Duration delay = const Duration(seconds: 1),
      double? pixelRatio,
      BuildContext? context,
      Size? targetSize,
      BorderRadiusGeometry? borderRadius}) async {
    int retryCounter = 3;
    bool isDirty = false;

    Widget child = widget;

    if (context != null) {
      ///
      ///Inherit Theme and MediaQuery of app
      ///
      ///
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
            data: MediaQuery.of(context),
            child: Material(
              child: child,
              color: Colors.transparent,
              borderRadius: borderRadius,
            )),
      );
    }

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    Size logicalSize = targetSize ??
        ui.window.physicalSize / ui.window.devicePixelRatio; // Adapted
    Size imageSize = targetSize ?? ui.window.physicalSize; // Adapted

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) ==
        imageSize.aspectRatio
            .toStringAsPrecision(5)); // Adapted (toPrecision was not available)

    final RenderView renderView = RenderView(
      window: ui.window,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: pixelRatio ?? 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(
        focusManager: FocusManager(),
        onBuildScheduled: () {
          ///
          ///current render is dirty, mark it.
          ///
          isDirty = true;
        });

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
            container: repaintBoundary,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: child,
              ),
            )).attachToRenderTree(
      buildOwner,
    );
    ////
    ///Render Widget
    ///
    ///

    buildOwner.buildScope(
      rootElement,
    );
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image? image;

    do {
      ///
      ///Reset the dirty flag
      ///
      ///
      isDirty = false;

      image = await repaintBoundary.toImage(
          pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

      ///
      ///This delay sholud increas with Widget tree Size
      ///

      await Future.delayed(delay);

      ///
      ///Check does this require rebuild
      ///
      ///
      // if (isDirty) {
      //   ///
      //   ///Previous capture has been updated, re-render again.
      //   ///
      //   ///
      //   buildOwner.buildScope(
      //     rootElement,
      //   );
      //   buildOwner.finalizeTree();
      //   pipelineOwner.flushLayout();
      //   pipelineOwner.flushCompositingBits();
      //   pipelineOwner.flushPaint();
      // }
      // retryCounter--;

      ///
      ///retry untill capture is successfull
      ///
    } while (isDirty && retryCounter >= 0);
    try {
      /// Dispose All widgets
      rootElement.visitChildren((Element element) {
        rootElement.deactivateChild(element);
      });
      buildOwner.finalizeTree();
    } catch (e) {}

    return image; // Adapted to directly return the image and not the Uint8List
  }
}
