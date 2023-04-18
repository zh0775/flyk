import 'package:cxhighversion2/component/app_wechat_manager.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/native_ui.dart'
    if (dart.library.html) 'package:cxhighversion2/util/web_ui.dart' as ui;
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:universal_html/html.dart';
import 'package:universal_html/js.dart' as js;

class MineCertificateAuthorizationBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineCertificateAuthorizationController>(
        MineCertificateAuthorizationController());
  }
}

class MineCertificateAuthorizationController extends GetxController {
  GlobalKey certificateKey = GlobalKey();
  InAppWebViewController? webCtrl;
  ScreenshotController screenshotCtrl = ScreenshotController();
  String viewType = "MineCertificateAuthorization_web";
  int viewId = 0;
  loadCertificateRequest(
      {required Function(bool success, dynamic json) success}) {
    simpleRequest(
        url: Urls.userHtmlToImg,
        params: {},
        success: success,
        after: () {},
        useCache: true);
  }

  final _certificateHtml = "".obs;
  String get certificateHtml => _certificateHtml.value;
  set certificateHtml(v) => _certificateHtml.value = v;
  @override
  void onInit() {
    // WebView.platform =
    //     AppDefault().versionOrigin == 2 ? CupertinoWebView() : AndroidWebView();
    AppWechatManager().registApp();
    // Wechat.instance.registerApp(
    //   appId: WECHAT_APPID,
    //   universalLink: WECHAT_UNIVERSAL_LINK,
    // );
    loadCertificateRequest(
      success: (success, json) {
        if (success && json["data"] != null) {
          certificateHtml = json["data"];
          if (kIsWeb) {
            ui.platformViewRegistry.registerViewFactory(viewType, (int vId) {
              viewId = vId;
              return IFrameElement()
                ..id = viewType
                ..style.width = '100%'
                ..style.height = '100%'
                ..srcdoc = certificateHtml
                ..style.border = 'none';
            });
          }
        }
      },
    );
    // certificateHtml = TmpHtml.tmpHtml;
    super.onInit();
  }
}

class MineCertificateAuthorization
    extends GetView<MineCertificateAuthorizationController> {
  const MineCertificateAuthorization({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          getDefaultAppBar(context, "授权证书", blueBackground: true, white: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ghb(37.5),
            gwb(375),
            SizedBox(
              width: 313,
              height: 440,
              key: controller.certificateKey,
              child: GetX<MineCertificateAuthorizationController>(builder: (_) {
                return controller.certificateHtml.isNotEmpty
                    ? (kIsWeb
                        ? Screenshot(
                            controller: controller.screenshotCtrl,
                            child: Container(
                              color: Colors.white,
                              child:
                                  // WebView(
                                  //   zoomEnabled: false,
                                  //   onWebViewCreated: (webCtrl) {
                                  //     webCtrl.loadHtmlString(
                                  //         controller.certificateHtml);
                                  //   },
                                  // )
                                  HtmlElementView(
                                      viewType: controller.viewType),
                            ),
                          )
                        : InAppWebView(
                            onWebViewCreated: (webCtrl) {
                              controller.webCtrl = webCtrl;
                              webCtrl.loadData(
                                  data: controller.certificateHtml);
                            },
                          ))
                    : ghb(0);
              }),

              // WebView(
              //   zoomEnabled: false,
              //   onWebViewCreated: (webCtrl) {
              //     webCtrl.loadHtmlString(controller.certificateHtml);
              //   },
              //   onPageFinished: (url) {
              //     print('object');
              //   },
              // ),

              // child: CustomHtmlView(
              //   src: controller.certificateHtml,
              //   // src: TmpHtml.tmpHtml,
              // )
              // child: Html(
              //   data: controller.certificateHtml,
              //   shrinkWrap: true,
              // )
            ),
            ghb(32),
            kIsWeb
                ? ghb(0)
                : CustomButton(
                    onPressed: () {
                      saveImageAction(2);
                    },
                    child: Container(
                      width: 279.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FE),
                          borderRadius: BorderRadius.circular(24.w)),
                      child: Center(
                        child: centRow([
                          Image.asset(
                            assetsName("common/icon_save"),
                            width: 14.w,
                            fit: BoxFit.fitWidth,
                          ),
                          gwb(13),
                          getSimpleText("保存证书", 16, AppColor.textBlack)
                        ]),
                      ),
                    ),
                  ),
            // sbRow([
            //   Container(
            //     color: const Color(0xFF434343),
            //     width: 18.5.w,
            //     height: 1.w,
            //   ),
            //   getSimpleText("分享图片到", 14, AppColor.textBlack),
            //   Container(
            //     color: const Color(0xFF434343),
            //     width: 18.5.w,
            //     height: 1.w,
            //   ),
            // ], width: 150),
            ghb(38),
            // sbRow([
            //   shareButotn(0),
            //   shareButotn(1),
            //   // shareButotn(2),
            // ], width: 251),
            ghb(79.5),
          ],
        ),
      ),
    );
  }

  saveImageAction(int idx) async {
    if ((!kIsWeb && controller.webCtrl == null) ||
        (kIsWeb && controller.certificateHtml.isEmpty)) {
      ShowToast.normal("请等待页面加载完毕");
      return;
    }
    Uint8List? byte;
    if (!kIsWeb) byte = await controller.webCtrl!.takeScreenshot();
    if (idx == 0) {
      // await Wechat.instance
      //     .shareImage(scene: WechatScene.SESSION, imageData: byte);
      AppWechatManager().sharePriendWithFile(byte);
    } else if (idx == 1) {
      AppWechatManager().shareTimelineWithFile(byte);
      // await Wechat.instance
      //     .shareImage(scene: WechatScene.TIMELINE, imageData: byte);

    } else if (idx == 2) {
      if (!kIsWeb) {
        saveAssetsImg(byte);
      } else {
        Rect? rect;
        RenderObject? renderObject =
            controller.certificateKey.currentContext?.findRenderObject();
        if (renderObject == null) {
          return;
        }
        var translation = renderObject.getTransformTo(null).getTranslation();
        if (translation != null && renderObject.paintBounds != null) {
          rect = renderObject.paintBounds
              .shift(Offset(translation.x, translation.y));
        } else {
          return;
        }

        // document
        //     .getElementsByTagName('flutter-platform-view')[0]
        //     .shadowRoot!
        //     .getElementById('iframe');

        // html.HtmlElement elem =
        //     (html.document.getElementsByTagName('flt-platform-view')[0]
        //         as html.HtmlElement);

        // print('node === $node');
        if (rect != null) {
          js.context.callMethod('capture', [
            controller.viewType,
            "${DateTime.now().millisecondsSinceEpoch}.png"
          ]);
        }
      }
    }
  }

  Widget shareButotn(int idx) {
    return CustomButton(
      onPressed: () {
        saveImageAction(idx);
      },
      child: centRow([
        Image.asset(
          assetsName(idx == 0
              ? "share/wx_friend"
              : idx == 1
                  ? "share/pyq"
                  : "share/save"),
          // width: 30.5.w,
          height: 25.w,
          fit: BoxFit.fitHeight,
        ),
        gwb(10),
        getSimpleText(
            idx == 0
                ? "微信"
                : idx == 1
                    ? "朋友圈"
                    : "保存图片",
            12,
            AppColor.textBlack)
      ]),
    );
  }

  // Future<bool> checkStoragePermission() async {
  //   Permission permission = Permission.storage;
  //   final status = await permission.status;
  //   return (status == PermissionStatus.granted);
  // }

  saveAssetsImg(Uint8List? byte) async {
    // bool havePermission = await checkStoragePermission();
    // if (!havePermission) {
    //   ShowToast.normal("没有权限，无法保存图片");
    //   return;
    // }

    // RenderRepaintBoundary boundary = controller.certificateKey.currentContext!
    //     .findRenderObject() as RenderRepaintBoundary;
    // ui.Image image = await boundary.toImage();
    // ByteData? byteData =
    //     await (image.toByteData(format: ui.ImageByteFormat.png));

    saveImageToAlbum(byte);
  }
}
