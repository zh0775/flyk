import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cxhighversion2/component/app_scan_barcode.dart'
    deferred as app_scan_barcode;
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_check_photo.dart'
    deferred as custom_check_photo;
import 'package:cxhighversion2/component/custom_dotted_line_painter.dart';
import 'package:cxhighversion2/component/custom_info_content.dart'
    deferred as custom_info_content;
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/news/news_detail.dart'
    deferred as news_detail;
import 'package:cxhighversion2/login/user_login.dart' deferred as user_login;
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/mine/debitCard/debit_card_info.dart'
    deferred as debit_card_info;
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_alipay.dart'
    deferred as identity_authentication_alipay;
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_upload.dart'
    deferred as identity_authentication_upload;
// import 'package:cxhighversion2/mine/mineStoreOrder/mine_integral_order_detail.dart';
import 'package:cxhighversion2/mine/mineStoreOrder/mine_store_order_detail.dart'
    deferred as mine_store_order_detail;
// import 'package:cxhighversion2/mine/mineStoreOrder/mine_store_order_list.dart'
//     deferred as mine_store_order_list;
import 'package:cxhighversion2/mine/mine_verify_identity.dart'
    deferred as mine_verify_identity;
import 'package:cxhighversion2/product/product_pay_result_page.dart'
    deferred as product_pay_result_page;
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/device_util.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/storage_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/user_default.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver/gallery_saver.dart' deferred as gallery_saver;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ota_update/ota_update.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:universal_html/js.dart' as js;
import 'package:url_launcher/url_launcher.dart';

class AppDefault {
  static const bool isDebug = true;
  static const String companyName = "";

  static const FontWeight fontBold = FontWeight.w600;
  static const String projectName = "付利优客";
  static const String fromDate = "2022-11-09 09:00:00";
  // static const String oldSystem = "192.168.1.200:1026";
  static const String oldSystem = "app.plus.my66668888.com";

  static const int jfWallet = 4;
  static const int awardWallet = 3;

  static const int appDelay = 0;

  static AppDefault? _instance;
  factory AppDefault() => _instance ?? AppDefault.init();

  // static Future<void> ensureScreenSize(int num) async {
  //   await ScreenUtil.ensureScreenSize();
  // }

  AppDefault.init() {
    versionOrigin = kIsWeb
        ? 3
        : DeviceUtil.isIOS
            ? 2
            : 1;
    // PlatformDeviceId.getDeviceId.then((value) {
    //   deviceId = value!;
    // });
    checkDay = checkDateForDay();
    _instance = this;
  }
  Map homeData = {};
  int versionOrigin = 0;
  String deviceId = "";
  static bool firstLaunchApp = false;
  String imageView = "";
  bool checkDay = false;
  //设备推广记录选中设备
  List popularizeMachineSelectIds = [];
  //积分商城记录购物车
  List integralStoreCarSelectIds = [];
  bool safeAlert = true;
  Map publicHomeData = {};
  Map loginData = {};
  bool loginStatus = false;
  String imageUrl = "";
  String appName = "";
  String packageName = "";
  double scaleWidth = 0;
  String version = "";
  String buildNumber = "";
  String token = "";
  List requstCacheList = [];
  List themeColorList = [];
  bool appHideScan() {
    if (kIsWeb) {
      return true;
    }
    return true;
  }

  setThemeColorList() {
    if (publicHomeData.isEmpty) return;
    List colorList = ((publicHomeData["versionInfo"] ?? {})["theme"] ??
            {})["themeColorList"] ??
        [];
    themeColorList = colorList.map((e) {
      String colorStr = e["color"];
      int transparency = ((e["transparency"] as double) / 100 * 255).ceil();
      colorStr = colorStr.substring(1);
      String opacity = transparency.toRadixString(16);
      String colorHex = "0x$opacity$colorStr";
      return colorHex;
    }).toList();
  }

  Color? getThemeColor({int index = 0, bool open = false}) {
    if (!open) {
      return null;
    }
    if (themeColorList.isNotEmpty && themeColorList.length > index) {
      int? hex = int.tryParse(themeColorList[index]);
      return hex != null ? Color(hex) : null;
    } else {
      return null;
    }
  }

  Map updateData = {};
  int versionOriginForPay() {
    return kIsWeb
        ? 2
        : Platform.isAndroid
            ? 1
            : 2;
    // return 1;
  }

  bool firstAlertFromLogin = false;

  String getAccountImg(int aNo) {
    String img = "";
    for (var e in homeData["u_Account"] ?? []) {
      if (e["a_No"] == aNo) {
        img = e["img"] ?? "";
        break;
      }
    }
    return img;
  }
}

class AppColor {
  static Color theme = const Color(0xFFFE4D3B);
  static Color themeOrange = const Color(0xFFFF6231);

  static Color theme2 = const Color(0xFF4F7AFD);
  static Color theme3 = const Color(0xFFFF8629);
  static Color text = const Color(0xFF333333);
  static Color text2 = const Color(0xFF666666);
  static Color text3 = const Color(0xFFbcc2cb);
  static Color assisText = const Color(0xFFcccccc);
  static Color red = const Color(0xFFF93635);

  static Color gradient1 = const Color(0xFFFD573B);
  static Color gradient2 = const Color(0xFFFF3A3A);

  static MaterialColor mTheme = MaterialColor(
    theme.value,
    <int, Color>{
      50: theme,
      100: theme,
      200: theme,
      300: theme,
      400: theme,
      500: theme,
      600: theme,
      700: theme,
      800: theme,
      900: theme,
    },
  );

  static Color pageBackgroundColor = const Color(0xFFF6F6F6);
  static Color pageBackgroundColor2 = const Color(0xFFF2F2F2);
  // static Color blue = const Color(0xFF2368F2);
  static Color textBlack = const Color(0xFF333333);
  static Color textBlack2 = const Color(0xFF4C4C4C);
  static Color textBlack3 = const Color(0xFF2D3033);
  static Color textBlack4 = const Color(0xFF373948);
  static Color textBlack5 = const Color(0xFF464A57);
  static Color textBlack6 = const Color(0xFF525C66);
  static Color textBlack7 = const Color(0xFF4A4A4A);
  static Color textBlack8 = const Color(0xFF16181A);
  static Color textDeepBlue = const Color(0xFF2D2C38);

  static Color textGrey = const Color(0xFF999999);
  static Color textGrey2 = const Color(0xFF666666);
  static Color textGrey3 = const Color(0xFFB3B3B3);
  static Color textGrey4 = const Color(0xFF7B8A99);
  static Color textGrey5 = const Color(0xFF999999);
  static Color lineColor = const Color(0xFFeeeeee);
  static Color lineColor2 = const Color(0xFFF7F7F7);
  static Color textRed = const Color(0xFFFE4D3B);
  static Color textRed2 = const Color(0xFFF34A3D);
  static Color tabBarRed = const Color(0xFFF21F2E);
  static Color integralTextRed = const Color(0xFFF13030);
  static Color buttonTextBlue = const Color(0xFF5290F2);
  static Color buttonTextBlack = const Color(0xFF333333);

  static Color color40 = const Color(0xFF525C66);
  static Color color20 = const Color(0xFF2D3033);
}

enum Sex { boy, girl }

typedef IndexClick = Function();

const Color appTheme = Color.fromRGBO(230, 184, 92, 1);
const Color appTheme_disable = Color.fromRGBO(230, 184, 92, 0.6);
const Color appTheme_splash = Color.fromRGBO(230, 184, 92, 0.2);
const Color line_color = Color(0xFFF0F2F5);
// const Color line_color = Color.fromRGBO(0, 0, 0, 0.12);
const Color text_black = Color(0xff404352);
const Color text_gray = Color(0xffaaacb2);
const Color placeholder_color = Color(0xffaab2bd);
const Color bg_gray_color = Color(0xFFF0F2F5);
const IconData naviBack = Icons.navigate_before;
// const Icon naviBack_icon = Icon(
//   naviBack,
//   size: 40,
//   color: Colors.white,
// );
// const Icon naviAdd_icon = Icon(
//   Icons.add,
//   size: 40,
//   color: Colors.white,
// );

Widget gline(double width, double height, {Color? color}) {
  return Container(
    width: width.w,
    height: height,
    color: color ?? AppColor.lineColor,
  );
}

void callSMS(dynamic phone, String text) {
  if (phone == null || phone is! String || phone.isEmpty) {
    return;
  }
  launchUrl(Uri(
    scheme: 'sms',
    path: phone,
    queryParameters: <String, String>{
      'body': Uri.encodeComponent(text),
    },
  ));
}

void callPhone(String phone) {
  if (phone != null) {
    if (AppDefault.isDebug) {
      print('拨打电话--tel://$phone');
    }

    launchUrl(Uri(
      scheme: 'tel',
      path: phone,
    ));
  }
}

String hidePhoneNum(String? phone) {
  if (phone == null || phone.isEmpty || phone.length < 11) {
    return "";
  }
  if (phone.length < 7) {
    if (phone.length < 3) {
      return "****";
    }
    return phone.substring(0, 3) + "****";
  }
  return phone.replaceRange(3, 7, "****");
}

void push(dynamic widget, BuildContext? context,
    {String setName = "", Bindings? binding, dynamic arguments}) {
  if (binding != null) {
    Get.to(widget,
        binding: binding,
        arguments: arguments,
        routeName: setName.isEmpty ? widget.runtimeType.toString() : setName);
  } else {
    Navigator.of(context ?? Global.navigatorKey.currentContext!).push(
        CupertinoPageRoute(
            settings: RouteSettings(
                name:
                    setName.isEmpty ? widget.runtimeType.toString() : setName),
            builder: (_) {
              return widget;
            }));
  }
}

void toScanBarCode(Function(String barCode) barcodeCallBack) {
  app_scan_barcode.loadLibrary().then((value) => Get.to(
      app_scan_barcode.AppScanBarcode(
        barcodeCallBack: barcodeCallBack,
      ),
      binding: app_scan_barcode.AppScanBarcodeBinding(),
      transition: Transition.fadeIn));
}

Widget getSimpleButton(Function()? onPressed, Widget title,
    {double? width,
    double? height,
    List<Color>? colors,
    Color? color,
    double? borderradius,
    Alignment? begin,
    Alignment? end}) {
  return CustomButton(
    onPressed: onPressed,
    child: Container(
      width: width?.w,
      height: height?.w,
      decoration: BoxDecoration(
          color: color,
          gradient: colors == null
              ? null
              : simpleGradient(colors, begin: begin, end: end),
          borderRadius: height == null
              ? null
              : BorderRadius.circular(borderradius ?? (height / 2))),
      child: Center(
        child: title,
      ),
    ),
  );
}

bool isLoginRoute() {
  return (Get.currentRoute.contains("UserLogin") ||
      Get.currentRoute.contains("UserRegist") ||
      Get.currentRoute.contains("ForgetPwd") ||
      Get.currentRoute.contains("UserAgreementView"));
}

void toLogin(
    {bool allowBack = false, isErrorStatus = false, int errorCode = 0}) {
  if (isLoginRoute()) {
    return;
  }
  // print("Get.currentRoute === ${Get.currentRoute}");
  // Get.to(
  //     UserLogin(
  //       allowBack: allowBack,
  //     ),
  //     binding: UserLoginBinding(),
  //     routeName: "UserLogin");
  popToLogin(
      allowBack: allowBack,
      isErrorStatus: errorCode != 0,
      errorCode: errorCode);
}

// Future<void> _installApk(String url) async {
//   File? apkFile = await Http().downloadAPK(url);
//   if (apkFile == null) {
//     return;
//   }
//   String apkFilePath = apkFile.path;
//   if (apkFilePath.isEmpty) {
//     return;
//   }
//   InstallPlugin.installApk(apkFilePath, Config.APP_ID).then((result) {
//     print('install apk $result');
//   }).catchError((error) {
//     print('install apk error: $error');
//   });
// }

updateErr(String title) {
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      String downloadUrl = "";
      if (HttpConfig.baseUrl.contains(AppDefault.oldSystem)) {
        downloadUrl = (AppDefault().publicHomeData["webSiteInfo"] ??
                {})["System_Download_Url"] ??
            "";
      } else {
        downloadUrl =
            (((AppDefault().publicHomeData["webSiteInfo"] ?? {})["app"] ??
                    {})["apP_ExternalReg_Url"] ??
                "");
      }
      if (downloadUrl.isNotEmpty) {
        if (downloadUrl.substring(downloadUrl.length - 1, downloadUrl.length) ==
            "/") {
          downloadUrl = downloadUrl.substring(0, downloadUrl.length - 1);
        }
      }
      showAlert(
        Global.navigatorKey.currentContext!,
        title,
        confirmOnPressed: () {
          Navigator.pop(Global.navigatorKey.currentContext!);
          launchUrl(
            // Uri.parse(downloadUrl),
            Uri.parse("$downloadUrl/pages/downApp/downApp"),
            mode: LaunchMode.externalApplication,
          );
        },
      );
    }
  }
}

void showUpdateEvent(String url, Map d) {
  bool first = true;
  OtaEvent? currentEvent;
  StreamSubscription<OtaEvent>? s;

  showGeneralDialog(
    context: Global.navigatorKey.currentContext!,
    routeSettings: const RouteSettings(name: "showUpdateEventAlert"),
    pageBuilder: (context, animation, secondaryAnimation) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (first) {
            String fileName = url.split("/").last;
            try {
              //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
              OtaUpdate otaUpdate = OtaUpdate();
              Stream<OtaEvent> stream = otaUpdate.execute(
                // url.substring(0, url.length - 3),
                url,
                // OPTIONAL
                destinationFilename: fileName,
                //OPTIONAL, ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
                // sha256checksum: "",
              );

              StreamSubscription<OtaEvent> streamSubscription = stream.listen(
                (OtaEvent event) {
                  switch (event.status) {
                    case OtaStatus.DOWNLOADING: // 下载中
                      setState(() => currentEvent = event);
                      break;
                    case OtaStatus.INSTALLING: //安装中
                      s?.cancel();
                      Navigator.pop(context);
                      break;
                    case OtaStatus.PERMISSION_NOT_GRANTED_ERROR: // 权限错误
                      // ShowToast.normal("未设置权限，升级失败");
                      s?.cancel();
                      Navigator.pop(context);
                      updateErr("升级失败，是否跳转到外部下载");
                      break;
                    default: // 其他问题
                      // ShowToast.normal("升级失败，请检查您的网络");
                      s?.cancel();
                      Navigator.pop(context);
                      updateErr("升级失败，是否跳转到外部下载");
                      break;
                  }

                  // if ((event) {
                  //         setState(() => currentEvent = event);
                  //       } != null) {
                  //   (event) {
                  //         setState(() => currentEvent = event);
                  //       }(event);
                  // }
                  // if (state != null) {
                  //   state(() => currentEvent = event);
                  // }
                  // setState(() => currentEvent = event);
                },
              );
              s = streamSubscription;
              // return streamSubscription;
            } catch (e) {
              ShowToast.normal("升级失败，请检查您的网络或权限");
              // print('Failed to make OTA update. Details: $e');
            }
            first = false;
          }
          double downloadPercent = currentEvent != null
              ? ((int.tryParse(currentEvent!.value ?? "1") ?? 1) / 100.0)
              : 0;
          double percentMaxWidth = 190.w;
          double percentWidth = downloadPercent * percentMaxWidth;

          return currentEvent == null
              ? gemp()
              : UnconstrainedBox(
                  child: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 265.w,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12.w),
                                child: Container(
                                    width: 265.w,
                                    // height: 370.w,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.fitWidth,
                                            alignment: Alignment.topCenter,
                                            image: AssetImage(assetsName(
                                                "common/bg_newversion")))),
                                    child: Column(children: [
                                      ghb(24),
                                      sbRow([
                                        Container(
                                          height: 20.w,
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFFD4536),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8.w),
                                                  bottomRight:
                                                      Radius.circular(8.w))),
                                          child: getSimpleText(
                                              "V${d["newVersionNumber"] ?? ""}",
                                              13,
                                              Colors.white,
                                              isBold: true),
                                        ),
                                      ], width: 265),
                                      ghb(150),
                                      Container(
                                          width: 265.w,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                          12.w))),
                                          child: Column(children: [
                                            getWidthText(
                                                d["version_Content"] ?? "",
                                                12,
                                                AppColor.textBlack,
                                                195,
                                                50,
                                                textHeight: 1.6),
                                            ghb(40),
                                            SizedBox(
                                                width: percentMaxWidth,
                                                height: 5.w,
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: Container(
                                                        width: percentMaxWidth,
                                                        height: 5.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      2.5.w),
                                                          color: AppColor
                                                              .lineColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                        left: 0,
                                                        top: 0,
                                                        height: 5.w,
                                                        width: percentMaxWidth,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Container(
                                                              width:
                                                                  percentWidth,
                                                              height: 5.w,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            2.5.w),
                                                                color: AppDefault()
                                                                        .getThemeColor() ??
                                                                    AppColor
                                                                        .theme,
                                                              )),
                                                        ))
                                                  ],
                                                )),
                                            ghb(10),
                                            getSimpleText(
                                                "正在努力下载...${(downloadPercent * 100).floor()}%",
                                                12,
                                                AppColor.textGrey5),
                                            ghb(27)
                                          ]))
                                    ]))),
                            // SizedBox(
                            //   width: 250.w,
                            //   height: 167.w,
                            //   child: Stack(
                            //     clipBehavior: Clip.none,
                            //     children: [
                            //       Positioned.fill(
                            //         bottom: -1.w,
                            //         child: Image.asset(
                            //           assetsName("common/bg_newversion"),
                            //           width: 250.w,
                            //           height: 168.w,
                            //           fit: BoxFit.fill,
                            //         ),
                            //       ),
                            //       Positioned(
                            //           left: 18.w,
                            //           top: 84.w,
                            //           child: getSimpleText(
                            //               "V${d["newVersionNumber"] ?? ""}",
                            //               13.2,
                            //               Colors.white,
                            //               isBold: true))
                            //     ],
                            //   ),
                            // ),
                            // Container(
                            //   width: 250.w,
                            //   decoration: BoxDecoration(
                            //       color: Colors.white,
                            //       borderRadius: BorderRadius.vertical(
                            //           bottom: Radius.circular(5.w))),
                            //   child: Column(
                            //     mainAxisSize: MainAxisSize.min,
                            //     children: [
                            //       ghb(30),
                            //       getSimpleText("正在为您升级，请耐心等待...", 12,
                            //           AppColor.textBlack),
                            //       ghb(18),
                            //       SizedBox(
                            //         width: 250.w,
                            //         child: Row(
                            //           children: [
                            //             SizedBox(
                            //               width:
                            //                   ((250.w - percentMaxWidth) / 2 -
                            //                           20.w -
                            //                           1.w) +
                            //                       percentWidth,
                            //             ),
                            //             SizedBox(
                            //               width: 40.w,
                            //               height: 25.w,
                            //               child: Stack(
                            //                 children: [
                            //                   Positioned.fill(
                            //                     child: Image.asset(
                            //                       assetsName(
                            //                           "common/icon_update_percent_pop"),
                            //                       width: 40.w,
                            //                       height: 25.w,
                            //                       fit: BoxFit.fill,
                            //                     ),
                            //                   ),
                            //                   Positioned.fill(
                            //                     child: Align(
                            //                       alignment:
                            //                           Alignment.topCenter,
                            //                       child: Padding(
                            //                         padding: EdgeInsets.only(
                            //                             top: 3.5.w),
                            //                         child: getSimpleText(
                            //                             "${(downloadPercent * 100).floor()}%",
                            //                             12,
                            //                             Colors.white),
                            //                       ),
                            //                     ),
                            //                   )
                            //                 ],
                            //               ),
                            //             )
                            //           ],
                            //         ),
                            //       ),
                            //       ghb(7),
                            //       SizedBox(
                            //           width: percentMaxWidth,
                            //           height: 6.w,
                            //           child: Stack(
                            //             children: [
                            //               Positioned.fill(
                            //                 child: Container(
                            //                   width: percentMaxWidth,
                            //                   height: 6.w,
                            //                   decoration: BoxDecoration(
                            //                     borderRadius:
                            //                         BorderRadius.circular(3.w),
                            //                     color: const Color(0xFFE0E0E0),
                            //                   ),
                            //                 ),
                            //               ),
                            //               Positioned(
                            //                   left: 0,
                            //                   top: 0,
                            //                   height: 6.w,
                            //                   width: percentMaxWidth,
                            //                   child: Align(
                            //                     alignment: Alignment.centerLeft,
                            //                     child: Container(
                            //                         width: percentWidth,
                            //                         height: 6.w,
                            //                         decoration: BoxDecoration(
                            //                           borderRadius:
                            //                               BorderRadius.circular(
                            //                                   3.w),
                            //                           color: AppDefault()
                            //                                   .getThemeColor() ??
                            //                               AppColor.theme,
                            //                         )),
                            //                   ))
                            //             ],
                            //           )),
                            //       ghb(30),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      )),
                );
        },
      );
    },
  );
}

saveQRImage() async {
  Uint8List byte = await ScreenshotController().captureFromWidget(
    QrImageView(
      data: (((AppDefault().publicHomeData["webSiteInfo"] ?? {})["app"] ??
                  {})["apP_ExternalReg_Url"] ??
              "") +
          (AppDefault().homeData["u_Number"] ?? ""),
      // size: !kIsWeb ? 66.w : 56.w,
      size: 80.w,
      padding: EdgeInsets.zero,
    ),
  );
  UserDefault.saveImage(QR_IMAGE_DATA, byte);
}

void popToLogin(
    {bool allowBack = false,
    bool isErrorStatus = false,
    int errorCode = 0}) async {
  await user_login.loadLibrary();
  Get.offUntil(
      GetPageRoute(
          page: () => user_login.UserLogin(
              isErrorStatus: isErrorStatus, errorCode: errorCode),
          binding: user_login.UserLoginBinding(),
          routeName: "UserLogin"), (route) {
    if (route is GetPageRoute) {
      if (route.binding is MainPageBinding) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  });
}

Gradient simpleGradient(List<Color> colors,
    {Alignment? begin, Alignment? end}) {
  return LinearGradient(
    colors: colors,
    begin: begin ?? Alignment.centerLeft,
    end: end ?? Alignment.centerRight,
  );
}

void toPayResult({
  // OrderResultType type = OrderResultType.orderResultTypePackage,
  // StoreOrderType orderType = StoreOrderType.storeOrderTypePackage,
  Map<dynamic, dynamic> orderData = const {},
  bool success = true,
  String subContent = "",
  bool offUntil = true,
  bool toOrderDetail = false,
}) async {
  if (offUntil) {
    if (toOrderDetail) {
      await mine_store_order_detail.loadLibrary();
    } else {
      await product_pay_result_page.loadLibrary();
    }
    Get.offUntil(
        GetPageRoute(
          page: () => toOrderDetail
              ? mine_store_order_detail.MineStoreOrderDetail(
                  data: orderData,
                )
              : product_pay_result_page.ProductPayResultPage(
                  orderData: orderData,
                  success: success,
                  subContent: subContent),
          binding: toOrderDetail
              ? mine_store_order_detail.MineStoreOrderDetailBinding()
              : product_pay_result_page.ProductPayResultPageBinding(),
        ), (route) {
      if (route is GetPageRoute) {
        if (route.binding is MainPageBinding) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    });
  } else {
    Get.to(
        toOrderDetail
            ? mine_store_order_detail.MineStoreOrderDetail(
                data: orderData,
              )
            : product_pay_result_page.ProductPayResultPage(
                orderData: orderData, success: success, subContent: subContent),
        binding: toOrderDetail
            ? mine_store_order_detail.MineStoreOrderDetailBinding()
            : product_pay_result_page.ProductPayResultPageBinding());
  }
}

// void toIntegralPayResult({
//   Map<dynamic, dynamic> orderData = const {},
//   bool success = true,
//   String subContent = "",
//   bool offUntil = true,
//   bool toOrderDetail = false,
// }) {
//   if (offUntil) {
//     Get.offUntil(
//         GetPageRoute(
//           page: () => toOrderDetail
//               ? MineIntegralOrderDetail(
//                   data: orderData,
//                 )
//               : ProductPayResultPage(
//                   type: OrderResultType.orderResultTypeIntegral,
//                   orderData: orderData,
//                   success: success,
//                   subContent: subContent),
//           binding: toOrderDetail
//               ? MineIntegralOrderDetailBinding()
//               : ProductPayResultPageBinding(),
//         ), (route) {
//       if (route is GetPageRoute) {
//         if (route.binding is AppBinding) {
//           return true;
//         }
//         return false;
//       } else {
//         return false;
//       }
//     });
//   } else {
//     Get.to(
//         toOrderDetail
//             ? MineIntegralOrderDetail(
//                 data: orderData,
//               )
//             : ProductPayResultPage(
//                 type: OrderResultType.orderResultTypeIntegral,
//                 orderData: orderData,
//                 success: success,
//                 subContent: subContent),
//         binding: toOrderDetail
//             ? MineIntegralOrderDetailBinding()
//             : ProductPayResultPageBinding());
//   }
// }

void popToUntil<T>(
    {Widget? page,
    Bindings? binding,
    T? popTo,
    dynamic alignment,
    String? name}) {
  if (page != null && binding != null) {
    Get.offUntil(
        GetPageRoute(
            page: () => page,
            binding: binding,
            settings: RouteSettings(arguments: alignment, name: name)),
        (route) => route is GetPageRoute
            ? route.binding is MainPageBinding
                ? true
                : false
            : false);
  } else {
    Get.until((route) => route is GetPageRoute
        ? route.binding is MainPageBinding
            ? true
            : false
        : false);
  }
}

void saveNetWorkImgToAlbum(String imgPath) async {
  await gallery_saver.loadLibrary();
  bool? success = await gallery_saver.GallerySaver.saveImage(imgPath);
  // Http().downImg(
  //   imgPath,
  //   {},
  //   success: (json) async {
  //     // await image_gallery_saver.loadLibrary();
  //     // image_gallery_saver.ImageGallerySaver.saveImage(
  //     //   Uint8List.fromList(json),
  //     // );
  //     ShowToast.normal("保存成功");
  //   },
  // );
  if (success != null && success) {
    ShowToast.normal("保存成功");
  }
}

void toCheckImg({required dynamic image, bool needSave = false}) {
  custom_check_photo.loadLibrary().then((value) => Get.to(
      custom_check_photo.CustomCheckPhoto(image: image, needSave: needSave),
      binding: custom_check_photo.CustomCheckPhotoBinding(),
      transition: Transition.zoom));
}

AppBar getDefaultAppBar(
  BuildContext context,
  String title, {
  Widget? leading,
  List<Widget>? action,
  double elevation = 0,
  Color color = Colors.white,
  Color shadowColor = Colors.transparent,
  TextStyle? titleStyle,
  Widget? flexibleSpace,
  bool blueBackground = false,
  SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle.dark,
  Function()? backPressed,
  bool white = false,
  bool centerTitle = true,
  bool needBack = true,
  double? leadingWidth,
}) {
  return AppBar(
    centerTitle: centerTitle,
    elevation: elevation,
    systemOverlayStyle:
        white ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    shadowColor: shadowColor,
    backgroundColor: color,
    flexibleSpace: flexibleSpace == null && blueBackground
        ? Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              AppDefault().getThemeColor(index: 0) ?? const Color(0xFF6796F5),
              AppDefault().getThemeColor(index: 2) ?? const Color(0xFF2368F2),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          )
        : flexibleSpace,
    // shadowColor: const Color(0xFFFFFEE0),
    title: getDefaultAppBarTitile(title,
        titleStyle: titleStyle, white: white, centerTitle: centerTitle),

    leadingWidth: leadingWidth,

    leading: leading ??
        (needBack
            ? defaultBackButton(context, backPressed: backPressed, white: white)
            : null),
    actions: action ?? [],
  );
}

/// 礼包/兑换/采购 商品订单状态
String getOrderStatustStr(int status) {
  String statusStr = "";
  switch (status) {
    case 0:
      statusStr = "待付款";
      break;
    case 1:
      statusStr = "待发货";
      break;
    case 2:
      statusStr = "待收货";
      break;
    case 3:
      statusStr = "已完成";
      break;
    case 4:
      statusStr = "退货中";
      break;
    case 5:
      statusStr = "退货完成";
      break;
    case 6:
      statusStr = "支付超时";
      break;
    case 7:
      statusStr = "已取消";
      break;
    case 8:
      statusStr = "已取消";
      break;
  }
  return statusStr;
}

Widget getDefaultAppBarTitile(String title,
    {TextStyle? titleStyle, bool white = false, bool centerTitle = false}) {
  return getSimpleText(
      title,
      titleStyle != null
          ? titleStyle.fontSize!
          : centerTitle
              ? 18
              : 21,
      titleStyle != null
          ? titleStyle.color!
          : (white ? Colors.white : AppColor.text),
      isBold: titleStyle != null && titleStyle.fontWeight != AppDefault.fontBold
          ? false
          : true,
      fw: titleStyle != null && titleStyle.fontWeight != null
          ? titleStyle.fontWeight
          : null);
}

String snNoFormat(String sn) {
  String formatSn = "";
  if (sn.isNotEmpty) {
    String substring = sn;
    int i = 0;
    int length = 5;
    while (substring.length > length) {
      switch (i) {
        case 0:
          length = 5;
          break;
        case 1:
          length = 6;
          break;
        case 2:
          length = 5;
          break;
        case 3:
          length = 4;
          break;
        default:
          length = 4;
      }
      String tmp =
          substring.substring(substring.length - length, substring.length);

      formatSn = i == 0 ? tmp : "$tmp $formatSn";
      substring = substring.substring(0, substring.length - length);
      i++;
    }
    if (substring.isNotEmpty) {
      formatSn = "$substring $formatSn";
    }
    int index = formatSn.indexOf(" ");
    if (index != -1 && index < 5) {
      formatSn = formatSn.replaceRange(index, index + 1, "");
    }
    return formatSn;
  }
  return formatSn;
}

Widget getTerminalNoText(String terminalNo,
    {TextStyle? highlightStyle, TextStyle? style}) {
  List<Widget> texts = [];
  List<Widget> returnWidget = [];
  TextStyle hStyle = highlightStyle ??
      TextStyle(
        fontSize: 16.sp,
        color: const Color(
          0xFFEB5757,
        ),
        fontWeight: AppDefault.fontBold,
      );
  TextStyle nStyle = highlightStyle ??
      TextStyle(
        fontSize: 16.sp,
        color: AppColor.textBlack,
        fontWeight: AppDefault.fontBold,
      );

  if (terminalNo.isNotEmpty) {
    String substring = terminalNo;
    int i = 0;
    int length = 5;

    while (substring.length > length) {
      switch (i) {
        case 0:
          length = 5;
          break;
        case 1:
          length = 6;
          break;
        case 2:
          length = 5;
          break;
        case 3:
          length = 4;
          break;
        default:
          length = 4;
      }
      String tmp =
          substring.substring(substring.length - length, substring.length);

      texts.add(Text(
        tmp,
        style: i == 0 ? hStyle : nStyle,
      ));

      texts.add(gwb(5));
      substring = substring.substring(0, substring.length - length);
      i++;
    }
    if (substring.isNotEmpty) {
      texts.add(Text(
        substring,
        style: nStyle,
      ));
    } else {
      texts.removeLast();
    }

    for (var i = texts.length - 1; i >= 0; i--) {
      returnWidget.add(texts[i]);
    }
  }
  return centRow(returnWidget);
}

String assetsName(String img) {
  return "assets/images/$img.png";
}

String addZero(dynamic num) {
  if (num == null) {
    return "";
  }
  late int n;
  if (num is int) {
    n = num;
  } else if (num is double) {
    n = num.ceil();
  } else if (num is String) {
    n = int.parse(num);
  }
  if (n < 10) {
    return "0$n";
  } else {
    return "$n";
  }
}

Widget getInputSubmitBody(BuildContext context, String title,
    {Function()? onPressed,
    List<Widget>? children,
    double? marginTop,
    double? fromTop,
    Color? contentColor,
    double? buttonHeight,
    Widget Function(double boxHeight, BuildContext context)? build}) {
  return Builder(
    builder: (context) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ghb(marginTop ?? 0),
            getRealityBody(context,
                children: children,
                buttonHeight: buttonHeight,
                marginTop: marginTop,
                contentColor: contentColor,
                fromTop: fromTop,
                build: build),
            getBottomBlueSubmitBtn(context, title, onPressed: onPressed)
          ],
        ),
      );
    },
  );
}

Widget getInputBodyNoBtn(BuildContext context,
    {List<Widget>? children,
    double? marginTop,
    Color? contentColor,
    Widget? submitBtn,
    double? buttonHeight = 80,
    double? fromTop,
    Widget Function(double boxHeight, BuildContext context)? build}) {
  return Builder(
    builder: (context) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ghb(marginTop ?? 0),
            getRealityBody(context,
                children: children,
                marginTop: marginTop,
                buttonHeight: buttonHeight ?? 80,
                contentColor: contentColor,
                fromTop: fromTop,
                build: build),
            submitBtn ?? const SizedBox(),
          ],
        ),
      );
    },
  );
}

Widget getBottomBlueSubmitBtn(BuildContext context, String title,
    {Function()? onPressed, bool enalble = true}) {
  return Container(
    width: 375.w,
    height: 80.w + paddingSizeBottom(context),
    color: Colors.white,
    padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
    child: Center(
      child: getSubmitBtn(title, onPressed ?? () {}, enable: enalble),
    ),
  );
}

Widget getRealityBody(BuildContext context,
    {List<Widget>? children,
    double? marginTop,
    double? fromTop,
    Color? contentColor,
    double? buttonHeight,
    Widget Function(double boxHeight, BuildContext context)? build}) {
  double screenHeight = ScreenUtil().screenHeight;

  double appBarMaxHeight = (Scaffold.of(context).appBarMaxHeight ?? 0);

  double btnHeight = buttonHeight ?? (80.w + paddingSizeBottom(context));

  // double paddingBottom = paddingSizeBottom(context);
  double paddingBottom = 0;

  double tMargin = (marginTop != null ? marginTop.w : 0);
  double topSpace = (fromTop != null ? fromTop.w : 0);

  double boxHeight = screenHeight -
      appBarMaxHeight -
      btnHeight -
      paddingBottom -
      tMargin -
      topSpace;

  return Container(
      color: contentColor ?? AppColor.pageBackgroundColor,
      width: 375.w,
      height: boxHeight,
      child: children != null
          ? SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: children,
              ),
            )
          : build != null
              ? build(boxHeight, context)
              : Container());
}

Widget assetsSizeImage(String img, double width, double height) {
  return Image.asset(
    assetsName(img),
    width: width.w,
    height: height.w,
    fit: BoxFit.fill,
  );
}

String integralFormat(dynamic num) {
  if (num == null || (num is String && num.isEmpty)) {
    return "0";
  }
  if (num is int) {
    return "$num";
  } else if (num is double) {
    List tmpList = "$num".split(".");
    if (tmpList.length > 1) {
      if (int.parse(tmpList[1]) > 0) {
        return "$num";
      } else if (int.parse(tmpList[1]) == 0) {
        return "${tmpList[0]}";
      }
    }
  } else if (num is String) {
    double e = double.parse(num);
    List tmpList = "$e".split(".");
    if (tmpList.length > 1) {
      if (int.parse(tmpList[1]) > 0) {
        return "$e";
      } else if (int.parse(tmpList[1]) == 0) {
        return "${tmpList[0]}";
      }
    }
  }
  return "$num";
}

void copyClipboard(String text,
    {bool needToast = true, String toastText = "已复制"}) {
  Clipboard.setData(ClipboardData(text: text));
  if (needToast) {
    ShowToast.normal(toastText);
  }
}

Widget defaultBackButtonView({
  Color? color,
  double? width,
  bool white = false,
  bool close = false,
}) {
  return SizedBox(
    width: width ?? (16 + 16).w,
    height: kToolbarHeight,
    child: Align(
        alignment: Alignment(close ? 1 : -0.3, 0.1),
        // alignment: Alignment.centerRight,
        child: close
            ? Image.asset(
                assetsName("common/btn_model_close2"),
                width: 12.w,
                fit: BoxFit.fitWidth,
              )
            : Image.asset(
                assetsName(white
                    ? "common/btn_navigater_back_white"
                    : "common/btn_navigater_back"),
                height: 18.w,
                // width: 16.w,
                fit: BoxFit.fitHeight,
              )),
  );
}

Widget defaultBackButton(
  BuildContext context, {
  Color? color,
  Function()? backPressed,
  double? width,
  bool white = false,
  bool close = false,
}) {
  return CustomButton(
      onPressed: () {
        if (backPressed != null) {
          backPressed();
        } else {
          Navigator.pop(context);
        }
      },
      child: defaultBackButtonView(
          color: color, white: white, close: close, width: width));
}

showAppUpdateAlert(Map data, {Function()? close}) {
  if (data != null && data.isNotEmpty) {
    Map d = data;
    if (d["isShow"] != null && d["isShow"] == false) {
      return;
    }
    bool isDownload = d["isDownload"] ?? false;
    // bool isDownload = false;
    // // String? name = ModalRoute.of(context!)!.settings.name;
    // print("Get.currentRoute === ${Get.currentRoute}");
    // if (Get.currentRoute.contains("appUpdateAlert")) {
    //   return;
    // }

    showGeneralDialog(
      barrierLabel: "",
      routeSettings: const RouteSettings(name: "appUpdateAlert"),
      context: Global.navigatorKey.currentContext!,
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return UnconstrainedBox(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 265.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.w),
                    child: Container(
                      width: 265.w,
                      // height: 370.w,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topCenter,
                              image: AssetImage(
                                  assetsName("common/bg_newversion")))),
                      child: Column(
                        children: [
                          ghb(24),
                          sbRow([
                            Container(
                              height: 20.w,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFD4536),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8.w),
                                      bottomRight: Radius.circular(8.w))),
                              child: getSimpleText(
                                  "V${d["newVersionNumber"] ?? ""}",
                                  13,
                                  Colors.white,
                                  isBold: true),
                            ),
                          ], width: 265),
                          ghb(150),
                          Container(
                            width: 265.w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(12.w))),
                            child: Column(
                              children: [
                                getWidthText(d["version_Content"] ?? "", 12,
                                    AppColor.textBlack, 195, 50,
                                    textHeight: 1.6),
                                ghb(40),
                                getSubmitBtn("立即体验", () {
                                  String urlStr =
                                      d["newVersionDownloadUrl"] ?? "";
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                  showUpdateEvent(urlStr, d);
                                },
                                    linearGradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFD573B),
                                          Color(0xFFFF3A3A),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter),
                                    width: 180,
                                    height: 45,
                                    fontSize: 15),
                                ghb(27),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  ghb(isDownload ? 0 : 31.5),
                  !isDownload
                      ? CustomButton(
                          onPressed: () {
                            Navigator.pop(context);
                            simpleRequest(
                              url: Urls.closeTodayUpdateVersion,
                              params: {
                                "userVersionNumber": AppDefault().version
                              },
                              success: (success, json) {},
                              after: () {},
                            );
                          },
                          child: Image.asset(
                              assetsName("common/btn_alert_close"),
                              width: 30.w,
                              height: 30.w,
                              fit: BoxFit.fill),
                        )
                      : ghb(0)
                  // SizedBox(
                  //   width: 250.w,
                  //   height: 167.w,
                  //   child: Stack(
                  //     clipBehavior: Clip.none,
                  //     children: [
                  //       Positioned.fill(
                  //         bottom: -1.w,
                  //         child: Image.asset(
                  //           assetsName("common/bg_newversion"),
                  //           width: 250.w,
                  //           height: 168.w,
                  //           fit: BoxFit.fill,
                  //         ),
                  //       ),
                  //       Positioned(
                  //           left: 18.w,
                  //           top: 84.w,
                  //           child: getSimpleText(
                  //               "V${d["newVersionNumber"] ?? ""}",
                  //               13.2,
                  //               Colors.white,
                  //               isBold: true))
                  //     ],
                  //   ),
                  // ),
                  // Container(
                  //   width: 250.w,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius:
                  //         BorderRadius.vertical(bottom: Radius.circular(8.w)),
                  //   ),
                  //   child: Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       ghb(14),
                  //       getWidthText(d["version_Content"] ?? "", 12,
                  //           AppColor.textBlack, 200, 50),
                  //       ghb(20),
                  // CustomButton(
                  //   onPressed: () {
                  //     String urlStr = d["newVersionDownloadUrl"] ?? "";
                  //     // urlStr = "https://www.baidu.com";
                  //     // if (urlStr.isEmpty) {
                  //     //   Navigator.pop(context);
                  //     //   return;
                  //     // }
                  //     // String allUrl = "";
                  //     // if (urlStr
                  //     //     .contains(HttpConfig.baseUrl.split("//")[1])) {
                  //     //   allUrl = urlStr;
                  //     // } else {
                  //     //   allUrl = urlStr.substring(0, 1) == "/"
                  //     //       ? HttpConfig.baseUrl.substring(
                  //     //               0, HttpConfig.baseUrl.length - 1) +
                  //     //           urlStr
                  //     //       : HttpConfig.baseUrl + urlStr;
                  //     // }
                  //     // updateApk(topUrl + urlStr);
                  //     if (context.mounted) {
                  //       Navigator.pop(context);
                  //     }
                  //     showUpdateEvent(urlStr, d);
                  //     // bool lanuch = await launchUrl(
                  //     //     Uri.parse(topUrl + urlStr),
                  //     //     mode: LaunchMode.externalApplication);
                  //   },
                  //         child: Container(
                  //           width: 180.w,
                  //           height: 30.w,
                  //           decoration: BoxDecoration(
                  //               color: AppDefault().getThemeColor() ??
                  //                   AppColor.theme,
                  //               borderRadius: BorderRadius.circular(15.w)),
                  //           child: Center(
                  //             child: getSimpleText("立即升级", 12, Colors.white),
                  //           ),
                  //         ),
                  //       ),
                  //       // !isDownload ? ghb(10) : ghb(0),
                  // !isDownload
                  //     ? CustomButton(
                  //         onPressed: () {
                  //           simpleRequest(
                  //             url: Urls.closeTodayUpdateVersion,
                  //             params: {
                  //               "userVersionNumber": AppDefault().version
                  //             },
                  //             success: (success, json) {},
                  //             after: () {
                  //               Navigator.pop(context);
                  //             },
                  //           );
                  //         },
                  //         child: SizedBox(
                  //           width: 250.w,
                  //           height: 35.w,
                  //           child: Center(
                  //             child: getSimpleText(
                  //                 "暂不升级", 13, AppColor.textBlack5),
                  //           ),
                  //         ),
                  //       )
                  //     : gwb(0),
                  // ghb(isDownload ? 23.5 : 5),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) {
      if (close != null) {
        close();
      }
    });
  }
}

showReminderAlert({
  bool haveClose = true,
  String content = "",
  String subContent = "",
  String btnTitle = "",
  bool untilToRoot = true,
  required Widget page,
  required Bindings binding,
  Function()? routeAction,
  Function()? close,
  Function()? closePress,
  barrierDismissible = false,
}) {
  showGeneralDialog(
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    barrierColor: Colors.black.withOpacity(.5),
    context: Global.navigatorKey.currentContext!,
    pageBuilder: (context, animation, secondaryAnimation) {
      return UnconstrainedBox(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 285.w,
            height: 360.w,
            decoration: getDefaultWhiteDec(radius: 8),
            child: Column(
              children: [
                gwb(285),
                ghb(36.5),
                Image.asset(assetsName("mine/authentication/bg_needauth_alert"),
                    width: 105.w, height: 105.w, fit: BoxFit.fill),
                SizedBox(
                    height: 118.5.w,
                    child: Column(
                      children: [
                        ghb(18),
                        getWidthText("根据监管规定，为保障账户安全，请尽快完成实名认证", 18,
                            AppColor.textBlack, 251, 2,
                            isBold: true, textAlign: TextAlign.center),
                        ghb(9),
                        getSimpleText("完成实名认证，解锁更多特权", 12, AppColor.textGrey)
                      ],
                    )),
                getSubmitBtn("马上认证", () {
                  if (routeAction != null) {
                    routeAction();
                  } else {
                    if (untilToRoot) {
                      popToUntil(page: page, binding: binding);
                    } else {
                      Get.back();
                      Get.to(page, binding: binding);
                    }
                  }
                }, height: 45, width: 225, color: AppColor.theme, fontSize: 14),
                haveClose
                    ? CustomButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: SizedBox(
                          width: 225.w,
                          height: 45.w,
                          child: Center(
                            child:
                                getSimpleText("以后再说", 14, AppColor.textGrey5),
                          ),
                        ),
                      )
                    : ghb(0)
              ],
            ),
          ),
        ),
      );

      // Center(
      //   child: SizedBox(
      //     width: 300.w,
      //     height: 360.w + (haveClose ? 56.5.w : 0),
      //     child: Material(
      //       color: Colors.transparent,
      //       child: Column(
      //         children: [
      //           SizedBox(
      //             width: 300.w,
      //             height: 360.w,
      //             child: Stack(
      //               children: [
      //                 Positioned.fill(
      //                     child: Image.asset(
      //                   assetsName("mine/authentication/bg_needauth_alert"),
      //                   width: 300.w,
      //                   height: 360.w,
      //                   fit: BoxFit.fill,
      //                 )),
      //                 Positioned.fill(
      //                     child: Column(
      //                   mainAxisAlignment: MainAxisAlignment.end,
      //                   children: [
      //                     getSimpleText(content, 25, AppColor.textBlack,
      //                         isBold: true),
      //                     ghb(12),
      //                     getWidthText(
      //                         subContent, 14, AppColor.textGrey, 237.w, 2,
      //                         textAlign: TextAlign.center),
      //                     ghb(15),
      //                     CustomButton(
      //                       onPressed: () {
      //                         if (routeAction != null) {
      //                           routeAction();
      //                         } else {
      //                           if (untilToRoot) {
      //                             popToUntil(page: page, binding: binding);
      //                           } else {
      //                             Get.back();
      //                             Get.to(page, binding: binding);
      //                           }
      //                         }

      //                         // Get.offUntil(
      //                         //     GetPageRoute(
      //                         //       page: () => isAuth
      //                         //           ? const IdentityAuthentication()
      //                         //           : const DebitCardManager(),
      //                         //       binding: isAuth
      //                         //           ? IdentityAuthenticationBinding()
      //                         //           : DebitCardManagerBinding(),
      //                         //     ), (route) {
      //                         //   if (route is GetPageRoute) {
      //                         //     if (route.binding is AppBinding) {
      //                         //       return true;
      //                         //     } else {
      //                         //       return false;
      //                         //     }
      //                         //   } else {
      //                         //     return false;
      //                         //   }
      //                         // });
      //                       },
      //                       child: Container(
      //                         width: 240.w,
      //                         height: 40.w,
      //                         decoration: BoxDecoration(
      //                             gradient: LinearGradient(
      //                                 begin: Alignment.topLeft,
      //                                 end: Alignment.bottomRight,
      //                                 colors: [
      //                                   AppDefault().getThemeColor(index: 0) ??
      //                                       const Color(0xFF4282EB),
      //                                   AppDefault().getThemeColor(index: 2) ??
      //                                       const Color(0xFF5BA3F7),
      //                                 ]),
      //                             borderRadius: BorderRadius.circular(20.w)),
      //                         child: Center(
      //                           child: getSimpleText(btnTitle, 16, Colors.white,
      //                               isBold: true),
      //                         ),
      //                       ),
      //                     ),
      //                     ghb(24.5)
      //                   ],
      //                 )),
      //               ],
      //             ),
      //           ),
      //           haveClose
      //               ? CustomButton(
      //                   onPressed: closePress ??
      //                       () {
      //                         Navigator.pop(context);
      //                       },
      //                   child: Transform.rotate(
      //                     angle: -math.pi / 1,
      //                     child: Image.asset(
      //                       assetsName(
      //                         "common/btn_model_close",
      //                       ),
      //                       width: 37.w,
      //                       height: 56.5.w,
      //                       fit: BoxFit.fill,
      //                     ),
      //                   ),
      //                 )
      //               : ghb(0),
      //         ],
      //       ),
      //     ),
      //   ),
      // );
    },
  ).then((value) {
    if (close != null) {
      close();
    }
  });
}

imagePerLoad(String url) {
  if (url.isEmpty) {
    return;
  }
  String loadUrl = AppDefault().imageUrl + url;
  if (loadUrl.contains("localhost") || AppDefault().imageUrl.isEmpty) {
    return;
  }
  try {
    CachedNetworkImageProvider p = CachedNetworkImageProvider(
      loadUrl,
      errorListener: () {},
    );
    p.resolve(const ImageConfiguration());
    // stream.addListener(
    //     ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
    //   // show();
    // }));
  } catch (e) {
    // show();
  }
  // NetworkImage image = NetworkImage(AppDefault().imageUrl + url);
  // image.resolve(const ImageConfiguration());
}

checkIdentityAlert({Function()? toNext, String contentText = "请先进行实名认证"}) {
  if ((AppDefault().homeData["authentication"] ?? {})["isCertified"] ?? false) {
    if (toNext != null) {
      toNext();
    }
  } else {
    showAlert(
      Global.navigatorKey.currentContext!,
      contentText,
      confirmOnPressed: () async {
        Navigator.pop(Global.navigatorKey.currentContext!);
        await identity_authentication_upload.loadLibrary();
        push(
            identity_authentication_upload.IdentityAuthenticationUpload(), null,
            binding: identity_authentication_upload
                .IdentityAuthenticationUploadBinding());
      },
    );
  }
}

showAuthAlert({
  required BuildContext context,
  required bool isAuth,
  Function()? close,
  bool haveClose = true,
  bool alipay = false,
  barrierDismissible = false,
}) async {
  String content = "";
  String subContent = "";
  String btnTitle = "";
  Widget page;
  Bindings binding;

  if (alipay) {
    await identity_authentication_alipay.loadLibrary();
    content = "支付宝绑定提醒";
    subContent = "您目前没有绑定支付宝账户，您需要完成绑定支付宝账户才能使用更多功能";
    btnTitle = "立即绑定";
    page = identity_authentication_alipay.IdentityAuthenticationAlipay();
    binding =
        identity_authentication_alipay.IdentityAuthenticationAlipayBinding();
  } else {
    if (isAuth) {
      await identity_authentication_upload.loadLibrary();
      content = "实名认证提醒";
      subContent = "您目前是未实名认证用户，您需要完成实名认证才能使用更多功能";
      btnTitle = "立即认证";
      page = identity_authentication_upload.IdentityAuthenticationUpload();
      binding =
          identity_authentication_upload.IdentityAuthenticationUploadBinding();
    } else {
      await debit_card_info.loadLibrary();
      content = "绑定结算卡提醒";
      subContent = "您目前未绑定结算卡，您需要绑定结算卡才能使用更多功能";
      btnTitle = "立即绑卡";
      page = debit_card_info.DebitCardInfo();
      binding = debit_card_info.DebitCardInfoBinding();
    }
  }

  showReminderAlert(
      close: close,
      content: content,
      subContent: subContent,
      btnTitle: btnTitle,
      page: page,
      haveClose: haveClose,
      binding: binding,
      barrierDismissible: barrierDismissible);
}

consoleLog(String name, dynamic message) {
  if (AppDefault.isDebug) {
    if (kIsWeb) {
      js.context.callMethod("consoleLog", [name, message]);
    } else {
      if (kDebugMode) {
        print("$name === $message");
      }
    }
  }
}

showPayPwdWarn({
  Function()? close,
  Function()? closePress,
  bool haveClose = false,
  bool popToRoot = true,
  bool untilToRoot = true,
  Function()? setSuccess,
  Function()? noSetBack,
}) async {
  await mine_verify_identity.loadLibrary();
  showReminderAlert(
      close: close,
      closePress: closePress,
      content: "设置支付密码提醒",
      subContent: "您目前未设置支付密码，您需要设置支付密码才能使用更多功能",
      btnTitle: "立即设置",
      untilToRoot: untilToRoot,
      page: mine_verify_identity.MineVerifyIdentity(
        type: mine_verify_identity.MineVerifyIdentityType.setPayPassword,
        popToRoot: popToRoot,
        setSuccess: setSuccess,
        noSetBack: noSetBack,
      ),
      binding: mine_verify_identity.MineVerifyIdentityBinding(),
      haveClose: haveClose);
}

showNewsAlert(
    {required BuildContext context,
    Map newData = const {},
    Function()? close,
    barrierDismissible = false}) {
  bool pushToDetail = false;
  showGeneralDialog(
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    barrierColor: Colors.black.withOpacity(.5),
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return UnconstrainedBox(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.w),
              child: SizedBox(
                width: 300.w,
                height: ScreenUtil().screenHeight - 40.w,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 300.w,
                          color: AppDefault().getThemeColor() ??
                              const Color.fromRGBO(35, 65, 145, 1),
                          padding: EdgeInsets.only(top: 25.w, bottom: 15.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              getWidthText(newData["n_Meta"], 15, Colors.white,
                                  260, 1000,
                                  alignment: Alignment.topCenter,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        CustomButton(
                          onPressed: () async {
                            pushToDetail = true;
                            Navigator.pop(context);
                            await news_detail.loadLibrary();
                            push(
                                news_detail.NewsDetail(
                                  newsData: newData,
                                ),
                                context);
                          },
                          child: Container(
                            width: 300.w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(8.w))),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ghb(20),
                                SizedBox(
                                    width: 245.w,
                                    height: 45.w,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                                AppDefault().getThemeColor() ??
                                                    Colors.white,
                                                BlendMode.modulate),
                                            child: Image.asset(
                                              assetsName("home/btn_homealert"),
                                              width: 245.w,
                                              height: 45.w,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                            child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(top: 8.5.w),
                                            child: getWidthText(
                                                newData["title"] ?? "",
                                                16,
                                                Colors.white,
                                                170,
                                                1,
                                                alignment: Alignment.topCenter),
                                          ),
                                        )),
                                      ],
                                    )),
                                ghb(20),
                                CustomNetworkImage(
                                  src: AppDefault().imageUrl +
                                      (newData["n_Image"] ?? ""),
                                  width: 175.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                ghb(35),
                              ],
                            ),
                          ),
                        ),
                        CustomButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Transform.rotate(
                            angle: -math.pi / 1,
                            child: Image.asset(
                              assetsName(
                                "common/btn_model_close",
                              ),
                              width: 37.w,
                              height: 56.5.w,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  ).then((value) {
    if (close != null && !pushToDetail) {
      close();
    }
  });
}

Widget gemp() {
  return const Align(
      child: SizedBox(
    width: 0,
    height: 0,
  ));
}

saveImageToAlbum(Uint8List? imageBytes,
    {bool showToast = true,
    bool isVideo = false,
    String suffix = "",
    Function(bool? result)? resultCallback}) async {
  await gallery_saver.loadLibrary();
  if (imageBytes != null) {
    Directory tmpDir = await getTemporaryDirectory();
    bool? result;
    if (isVideo) {
      File myFile = await File(
              "${tmpDir.path}/video_${DateTime.now().millisecond}${suffix.isNotEmpty ? ".$suffix" : ""}")
          .create();
      myFile.writeAsBytesSync(imageBytes);
      result = await gallery_saver.GallerySaver.saveVideo(
        myFile.path,
      );
    } else {
      File myFile =
          await File("${tmpDir.path}/img_${DateTime.now().millisecond}.jpg")
              .create();
      myFile.writeAsBytesSync(imageBytes);
      File file =
          await FlutterNativeImage.compressImage(myFile.path, quality: 30);
      result = await gallery_saver.GallerySaver.saveImage(
        file.path,
      );
    }
    print("result === $result");

    if (resultCallback != null) {
      resultCallback(result);
    }

    if (showToast) {
      if (result != null && result) {
        ShowToast.normal("保存成功");
      } else {
        ShowToast.normal("保存失败");
      }
    }
  }
}

Future<bool?> showAlert(
  BuildContext context,
  String content, {
  String title = "友情提示",
  String confirmText = "确定",
  String cancelText = "我再想想",
  String singleText = "知道了",
  TextStyle? titleStyle,
  TextStyle? confirmStyle,
  TextStyle? cancelStyle,
  TextStyle? singlelStyle,
  Function()? confirmOnPressed,
  Function()? cancelOnPressed,
  Function()? singleOnPressed,
  bool otherBtn = false,
  TextStyle? otherStyle,
  String otherText = "取消",
  double height = 163,
  Widget? contentWidget,
  Color? singleBtnColor,
  Color? cancelBtnColor,
  Color? confirmBtnColor,
  Function()? otherOnPressed,
  bool barrierDismissible = true,
  bool orangeTheme = false,
  bool singleButton = false,
}) async {
  bool? show = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Center(
            child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: Container(
                        width: 300.w,
                        height: height.w,
                        color: Colors.white,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              centClm([
                                ghb(30),
                                getSimpleText(title, 16, AppColor.textBlack,
                                    isBold: true, textHeight: 1.0),
                                ghb(17),
                                getWidthText(
                                  content,
                                  13,
                                  AppColor.textGrey5,
                                  300 - 15 * 2,
                                  2,
                                  alignment: Alignment.center,
                                  textAlign: TextAlign.center,
                                ),
                                contentWidget ?? ghb(0),
                              ]),
                              centClm([
                                gline(300, 1),
                                centRow(List.generate(singleButton ? 1 : 3,
                                    (index) {
                                  return index == 1
                                      ? gline(1, 50)
                                      : CustomButton(
                                          onPressed: () {
                                            if (index == 0) {
                                              if (singleButton) {
                                                if (singleOnPressed != null) {
                                                  singleOnPressed();
                                                } else {
                                                  Navigator.pop(context);
                                                }
                                              } else {
                                                if (cancelOnPressed != null) {
                                                  cancelOnPressed();
                                                } else {
                                                  Navigator.pop(context);
                                                }
                                              }
                                            } else if (index == 1 ||
                                                index == 2) {
                                              if (confirmOnPressed != null) {
                                                confirmOnPressed();
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            }
                                          },
                                          child: Container(
                                              width: 300.w /
                                                      (singleButton ? 1 : 2) -
                                                  0.1.w -
                                                  (singleButton ? 0 : 1.w),
                                              height: 50.w,
                                              color: index == 0
                                                  ? singleButton
                                                      ? singleBtnColor ??
                                                          Colors.white
                                                      : cancelBtnColor ??
                                                          Colors.white
                                                  : orangeTheme
                                                      ? AppColor.themeOrange
                                                      : confirmBtnColor ??
                                                          AppColor.theme,
                                              child: Center(
                                                  child: Text(
                                                      index == 0
                                                          ? (singleButton
                                                              ? singleText
                                                              : cancelText)
                                                          : confirmText,
                                                      style: index == 0
                                                          ? singleButton
                                                              ? (singlelStyle ??
                                                                  TextStyle(
                                                                      fontSize:
                                                                          14.sp,
                                                                      color: AppColor
                                                                          .theme))
                                                              : (cancelStyle ??
                                                                  TextStyle(
                                                                      fontSize:
                                                                          14.sp,
                                                                      color: AppColor
                                                                          .textGrey5))
                                                          : (confirmStyle ??
                                                              TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: Colors
                                                                      .white))))));
                                }))
                              ])
                            ])))));
      });
  return show;
}

CupertinoDialogAction getAlertAction(
  String title,
  TextStyle? style,
  Function()? onPressed,
) {
  return CupertinoDialogAction(
    isDestructiveAction: true,
    onPressed: () {
      if (onPressed != null) {
        onPressed();
      } else {
        Navigator.pop(Global.navigatorKey.currentContext!);
      }
      // Navigator.of(context).pop();
    },
    child: getSimpleText(
        title,
        style != null && style.fontSize != null ? style.fontSize! : 15,
        style != null && style.color != null
            ? style.color!
            : AppColor.textGrey2,
        isBold: style != null && style.fontWeight != null
            ? (style.fontWeight! == AppDefault.fontBold ? true : false)
            : false),
  );
}

bool checkDateForDay() {
  DateTime now = DateTime.now();
  DateTime before =
      DateFormat("yyyy-MM-dd HH:mm:ss").parse(AppDefault.fromDate);
  before = before.add(const Duration(days: AppDefault.appDelay));
  return now.isAfter(before);
}

SizedBox ghb(double height) {
  return SizedBox(
    height: height.w,
  );
}

SizedBox gwb(double width) {
  return SizedBox(
    width: width.w,
  );
}

Future<void> otherRequest({
  required String path,
  String? method,
  Map<String, dynamic>? data,
  Map<String, dynamic>? queryParameters,
  required Function(bool success, dynamic json) success,
  required Function() after,
}) async {
  Dio dio = Dio();
  try {
    await dio
        .request(path,
            options: Options(method: method ?? "GET"),
            data: data,
            queryParameters: queryParameters)
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        success(data["success"] ?? true, response.data);
        // if (data["success"] != null && data["success"] is bool) {
        //   success(data["success"], response.data);
        //   if (data["success"]) {
        //   } else {
        //     if (data["messages"] != null &&
        //         data["messages"] is String &&
        //         data["messages"].isNotEmpty) {
        //       ShowToast.normal(data["messages"] ?? "");
        //     }
        //   }
        // }
      } else {
        if (response.statusMessage != null &&
            response.statusMessage!.isNotEmpty) {
          success(false, response.statusMessage!);
        }
        // ShowToast.normal(data["messages"] ?? "");
        // if (fail != null) {
        //   fail(response.statusMessage!, response.statusCode!,
        //       response.data ?? {});
        // }
      }
      if (after != null) {
        after();
      }
    });
  } on DioError catch (e) {
    if (after != null) {
      after();
    }
    if (e.response != null &&
        e.response!.data != null &&
        e.response!.data is Map &&
        e.response!.data["messages"] != null) {
      success(false, e.response?.data["messages"] ?? "");
    } else {
      success(false, e.message);
      if (e.type == DioErrorType.connectTimeout) {
        ShowToast.normal("网络连接超时");
      } else {
        ShowToast.normal(e.message);
      }
    }
  }

  return Future.value();
}

simpleRequest(
    {required String url,
    required Map<String, dynamic> params,
    required Function(bool success, dynamic json) success,
    required Function() after,
    CancelToken? cancelToken,
    dynamic otherData,
    bool useCache = false}) async {
  String key = url + convert.jsonEncode(params);
  if (AppDefault().token.isNotEmpty && AppDefault().token.length > 9) {
    int subIndex = (AppDefault().token.length / 9).floor();
    key += AppDefault().token.substring(subIndex, subIndex * 2);
  }
  dynamic data;
  if (useCache) {
    data = await UserDefault.get(key);
    if (data != null) {
      success(true, convert.jsonDecode(data));
    }
  }
  Http().doPost(
    url,
    params,
    cancelToken: cancelToken,
    otherData: otherData,
    success: (json) {
      if (json is String) {
        success(false, json);
        return;
      }
      if (json["success"]) {
        if (useCache) {
          String resStr = convert.jsonEncode(json);
          if (resStr != data) {
            UserDefault.saveStr(key, resStr).then((value) {
              if (value && !AppDefault().requstCacheList.contains(key)) {
                AppDefault().requstCacheList.add(key);
              }
            });
            success(true, json);
          }
        } else {
          success(true, json);
        }
      } else {
        success(false, json);
      }
    },
    fail: (reason, code, json) {
      success(false, json);
    },
    after: () {
      after();
    },
  );
}

Widget sbRow(
  List<Widget> children, {
  double? width,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
}) {
  return SizedBox(
    width: width != null ? width.w : 345.w,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    ),
  );
}

Widget sbhRow(
  List<Widget> children, {
  double? width,
  double? height,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
}) {
  return SizedBox(
    width: width != null ? width.w : 345.w,
    height: height == null ? 30.w : height.w,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    ),
  );
}

// 起始机具号去除字母，取后5位数字
String seqNumFormat(String no) {
  String replacedStr = no.replaceAll(RegExp('[a-zA-Z]'), '');
  return replacedStr.length <= 5
      ? replacedStr
      : replacedStr.substring(replacedStr.length - 5);
}

Column centClm(
  List<Widget> children, {
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: crossAxisAlignment,
    mainAxisSize: MainAxisSize.min,
    children: children,
  );
}

pushInfoContent({
  String title = "",
  String name = "",
  String content = "",
  bool isText = false,
}) async {
  await custom_info_content.loadLibrary();
  Get.to(
      custom_info_content.CustomInfoContent(
        content: content,
        name: name,
        title: title,
        isText: isText,
      ),
      transition: Transition.downToUp);
}

Widget sbClm(
  List<Widget> children, {
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceBetween,
  double height = 200,
}) {
  return SizedBox(
    height: height.w,
    child: Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    ),
  );
}

Widget sbwClm(
  List<Widget> children, {
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  double height = 200,
  double width = 100,
}) {
  return SizedBox(
    height: height.w,
    width: width.w,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    ),
  );
}

Row centRow(List<Widget> children,
    {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: crossAxisAlignment,
    children: children,
  );
}

AppBar getMainAppBar(int index,
    {Widget? leftWidget,
    Widget? rightWidget,
    Function()? leftDefaultAction,
    Function()? rightDefaultAction}) {
  bool checkDay = AppDefault().checkDay;
  List t = checkDay ? ["收益", "数据", "首页", "产品", "个人"] : ["积分", "首页", "产品", "个人"];
  return AppBar(
    leading: leftWidget ??
        (index == (checkDay ? 2 : 1)
            ? CustomButton(
                onPressed: leftDefaultAction,
                child: Image.asset("assets/images/home/icon_navi_left.png",
                    width: 20.w, fit: BoxFit.fitWidth),
              )
            : null),
    actions: [
      Padding(
        padding: EdgeInsets.only(right: 15.w),
        child: rightWidget ??
            (index == (checkDay ? 2 : 1)
                ? CustomButton(
                    onPressed: rightDefaultAction,
                    child: Image.asset("assets/images/home/icon_navi_left.png",
                        width: 20.w, fit: BoxFit.fitWidth),
                  )
                : null),
      ),
    ],
    centerTitle: true,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.3, 0.7],
              colors: [Color(0xFF4282EB), Color(0xFF5BA3F7)])),
    ),
    title: SizedBox(
        width: 170.w,
        height: 28.w,
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: checkDay
                      ? [
                          Text(
                            //  0 = 3  1 = 4
                            t[index - 2 < 0 ? index + 3 : index - 2],
                            style: TextStyle(
                                color: Colors.white38, fontSize: 12.sp),
                          ),
                          Text(
                            t[index - 1 < 0 ? t.length - 1 - index : index - 1],
                            style: TextStyle(
                                color: Colors.white60, fontSize: 14.sp),
                          ),
                          Text(
                            t[index],
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.sp),
                          ),
                          Text(
                            t[index + 1 > t.length - 1
                                ? index + 1 - t.length
                                : index + 1],
                            style: TextStyle(
                                color: Colors.white60, fontSize: 14.sp),
                          ),
                          Text(
                            t[index + 2 > t.length - 1
                                ? index + 2 - t.length
                                : index + 2],
                            style: TextStyle(
                                color: Colors.white38, fontSize: 12.sp),
                          ),
                        ]
                      : [
                          Text(
                            t[index - 1 < 0 ? t.length - 1 - index : index - 1],
                            style: TextStyle(
                                color: Colors.white60, fontSize: 14.sp),
                          ),
                          Text(
                            t[index],
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.sp),
                          ),
                          Text(
                            t[index + 1 > t.length - 1
                                ? index + 1 - t.length
                                : index + 1],
                            style: TextStyle(
                                color: Colors.white60, fontSize: 14.sp),
                          ),
                        ]),
            ),
            Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 15.w,
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF4282EB), Color(0x1E4282EB)])),
                )),
            Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 15.w,
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0x1E5BA3F7), Color(0xFF5BA3F7)])),
                ))
          ],
        )),
  );
}

Text nSimpleText(String text, double fontSize,
    {Color? color,
    bool isBold = false,
    FontWeight? fw,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    TextBaseline? textBaseline,
    double? textHeight,
    TextOverflow overflow = TextOverflow.ellipsis}) {
  return getSimpleText(text, fontSize, color,
      isBold: isBold,
      fw: fw,
      maxLines: maxLines,
      textAlign: textAlign,
      textBaseline: textBaseline,
      textHeight: textHeight,
      overflow: overflow);
}

Text getSimpleText(
  String text,
  double fontSize,
  Color? color, {
  bool isBold = false,
  FontWeight? fw,
  int maxLines = 1,
  TextAlign textAlign = TextAlign.start,
  TextBaseline? textBaseline,
  double? textHeight = 1.3,
  TextOverflow overflow = TextOverflow.ellipsis,
  double? wordSpacing,
  double? letterSpacing,
}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    style: TextStyle(
        fontSize: fontSize.sp,
        color: color ?? AppColor.text,
        height: textHeight,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        fontWeight: fw ?? (isBold ? AppDefault.fontBold : FontWeight.normal)),
  );
}

Widget getRichText(
  String text,
  String text2,
  double fontSize,
  Color color,
  double fontSize2,
  Color color2, {
  bool isBold = false,
  FontWeight? fw,
  int maxLines = 1,
  bool isBold2 = false,
  FontWeight? fw2,
  double? widht,
  double? h1 = 1.3,
  double? h2 = 1.3,
}) {
  return SizedBox(
    width: widht?.w,
    child: Text.rich(
      TextSpan(text: "", children: [
        TextSpan(
            text: text,
            style: TextStyle(
                fontSize: fontSize.sp,
                color: (isBold || fw == AppDefault.fontBold) &&
                        color == AppColor.textBlack
                    ? AppColor.textBlack2
                    : color,
                height: h1,
                fontWeight:
                    fw ?? (isBold ? AppDefault.fontBold : FontWeight.normal))),
        TextSpan(
            text: text2,
            style: TextStyle(
                fontSize: fontSize2.sp,
                color: (isBold2 || fw2 == AppDefault.fontBold) &&
                        color2 == AppColor.textBlack
                    ? AppColor.textBlack2
                    : color2,
                height: h2,
                fontWeight:
                    fw2 ?? (isBold2 ? AppDefault.fontBold : FontWeight.normal)))
      ]),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget getCustomDashLine(double length, double width,
    {bool v = true,
    double dashSingleWidth = 6,
    double dashSingleGap = 8,
    double strokeWidth = 1,
    Color? color}) {
  Path path = Path();
  path.moveTo(0, 0);
  if (v) {
    path.lineTo(0, length.w);
  } else {
    path.lineTo(length.w, 0);
  }
  return CustomPaint(
    painter: CustomDottedPinePainter(
        color: color ?? AppColor.textGrey,
        dashSingleWidth: dashSingleWidth.w,
        dashSingleGap: dashSingleGap.w,
        strokeWidth: strokeWidth.w,
        // path: parseSvgPathData('m0,0 l0,${62.5.w} Z')),
        path: path),
    size: Size(v ? width.w : length.w, v ? length.w : width.w),
  );
}

Widget getDefaultTilte(String title, {Widget? rightWidget}) {
  return sbRow([
    centRow([
      Container(
        width: 4.w,
        height: 16.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.w),
            gradient: LinearGradient(
              colors: [
                AppDefault().getThemeColor(index: 0) ?? const Color(0xFF2368F2),
                AppDefault().getThemeColor(index: 3) ?? const Color(0x002368F2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
      ),
      gwb(8),
      getSimpleText(title, 18, AppColor.textBlack)
    ]),
    rightWidget ?? gwb(0),
  ], width: 345);
}

int getMaxCount(double maxNum) {
  int maxInt = maxNum.ceil();
  if (maxInt <= 20) {
    return 20;
  } else if (maxInt <= 40) {
    return 40;
  } else if (maxInt <= 80) {
    return 80;
  } else {
    String numStr = "1";
    for (var i = 0; i < "$maxInt".length; i++) {
      numStr += "0";
    }
    int num = int.parse(numStr);
    if (num / 5 > maxNum) {
      return (num / 5).floor();
    } else if (num / 2 > maxNum) {
      return (num / 2).floor();
    } else {
      return num;
    }
  }
}

Map getChartScale(double maxNum) {
  Map scale = {0: "0", 1: "1", 2: "2", 3: "3", 4: "4"};
  int maxInt = getMaxCount(maxNum);
  int decrease = (maxInt / (scale.values.length - 1)).ceil();
  for (var i = (scale.values.length - 1); i >= 0; i--) {
    int s = maxInt - decrease * (i - (scale.values.length - 1)).abs();
    scale[i] = "${s > 1000 ? "${s / 1000}K" : s}";
  }
  return scale;
}

BoxDecoration getBBDec({List<Color>? colors, Color? color}) {
  return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8.w),
      gradient: color != null
          ? null
          : colors != null && colors.length > 1
              ? LinearGradient(
                  colors: colors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: colors ??
                      [
                        const Color(0xFFEBF3F7),
                        const Color(0xFFFAFAFA),
                      ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
      boxShadow: [
        BoxShadow(
            color: const Color(0x33666666),
            offset: Offset(0, 5.w),
            blurRadius: 8.w),
      ]);
}

BoxDecoration getDefaultWhiteDec({double radius = 5}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular((radius).w),
  );
}

BoxDecoration getDefaultWhiteDec2({double radius = 12}) {
  return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        (radius).w,
      ),
      boxShadow: [
        BoxShadow(
            color: const Color(0x26333333),
            offset: Offset(0, 5.w),
            blurRadius: 15.w)
      ]);
}

String numToChinessNum(int num) {
  List nums = [
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
    "七",
    "八",
    "九",
    "十",
  ];
  if (num < 11) {
    return nums[num - 1];
  } else if (num > 10 && num < 100) {
    String n = "$num";
    int first = int.parse(n.substring(0, 1));
    int second = int.parse(n.substring(1, 2));
    if (second == 0) {
      return "${nums[first - 1]}十";
    } else if (num < 20) {
      return "十${nums[second - 1]}";
    } else {
      return "${nums[first - 1]}十${nums[second - 1]}";
    }
  }

  return "$num";
}

Widget getContentText(
  String text,
  double fontSize,
  Color color,
  double w,
  double h,
  int maxLine, {
  bool isBold = false,
  TextAlign textAlign = TextAlign.start,
  AlignmentGeometry alignment = Alignment.centerLeft,
  FontWeight? fw,
  TextOverflow overflow = TextOverflow.ellipsis,
  double? textHeight,
}) {
  return SizedBox(
    width: w.w,
    height: h.w,
    child: Align(
      alignment: alignment,
      child: Text(
        text,
        maxLines: maxLine,
        overflow: overflow,
        textAlign: textAlign,
        style: TextStyle(
            fontSize: fontSize.sp,
            color: (isBold || fw == AppDefault.fontBold) &&
                    color == AppColor.textBlack
                ? AppColor.textBlack2
                : color,
            height: textHeight,
            fontWeight:
                fw ?? (isBold ? AppDefault.fontBold : FontWeight.normal)),
      ),
    ),
  );
}

Widget getWidthText(
  String text,
  double fontSize,
  Color color,
  double width,
  int? maxLine, {
  bool isBold = false,
  Alignment alignment = Alignment.centerLeft,
  TextAlign textAlign = TextAlign.start,
  StrutStyle? strutStyle,
  FontWeight? fw,
  double? textHeight,
}) {
  return SizedBox(
    width: width.w,
    child: Align(
      alignment: alignment,
      child: Text(
        text,
        maxLines: maxLine,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        strutStyle: strutStyle,
        style: TextStyle(
            height: textHeight,
            fontSize: fontSize.sp,
            color: (isBold || fw == AppDefault.fontBold) &&
                    color == AppColor.textBlack
                ? AppColor.textBlack2
                : color,
            fontWeight:
                fw ?? (isBold ? AppDefault.fontBold : FontWeight.normal)),
      ),
    ),
  );
}

String priceFormat(dynamic price,
    {bool tenThousand = false,
    int savePoint = 2,
    bool tenThousandUnit = true}) {
  if (price is String && price.isEmpty) {
    price = "0";
  }
  if (price is String && price.isNotEmpty && double.tryParse(price) != null) {
    price = double.parse(price);
  }

  if (price is int) {
    if (tenThousand && price >= 10000) {
      return "${doublePriceFormat(price / 10000.0, savePoint: savePoint)}${tenThousandUnit ? "万" : ""}";
    } else {
      return stringPriceFormat("$price", savePoint: savePoint);
    }
  } else if (price is double) {
    if (tenThousand && price >= 10000) {
      return "${doublePriceFormat(price / 10000.0, savePoint: savePoint)}${tenThousandUnit ? "万" : ""}";
    } else {
      return doublePriceFormat(price, savePoint: savePoint);
    }
  } else if (price is String) {
    if (tenThousand &&
        double.tryParse(price) != null &&
        double.tryParse(price)! >= 10000) {
      return "${doublePriceFormat(double.parse(price) / 10000, savePoint: savePoint)}${tenThousandUnit ? "万" : ""}";
    } else {
      return stringPriceFormat(price, savePoint: savePoint);
    }
  }
  return "";
}

String doublePriceFormat(double price, {int savePoint = 2}) {
  return stringPriceFormat("$price", savePoint: savePoint);
}

String stringPriceFormat(String price, {int savePoint = 2}) {
  List t2 = price.split(".");
  if (t2.length > 1) {
    if (savePoint == 0) {
      return "${t2[0]}";
    } else if ((t2[1] as String).length > savePoint) {
      String firstStr = savePoint < 2 ? "" : (t2[1] as String).substring(0, 1);
      String pointStr =
          (t2[1] as String).substring(savePoint < 2 ? 0 : 1, savePoint);
      pointStr += ".${(t2[1] as String).substring(savePoint, savePoint + 1)}";
      int pointInt = double.parse(pointStr).round();
      if (pointInt >= 10) {
        int inte = int.parse(t2[0]);
        if (savePoint < 2) {
          inte += 1;
        } else {
          int firstInt = int.parse(firstStr) + 1;
          if ("$firstInt".length > firstStr.length) {
            inte += 1;
            String zeros = ".";
            for (var i = 0; i < savePoint; i++) {
              zeros += "0";
            }
            return "$inte$zeros";
          } else {
            return "$inte.${firstInt}0";
          }
        }
      }
      return "${t2[0]}.$firstStr$pointInt";
    } else if ((t2[1] as String).length == savePoint) {
      return "${t2[0]}.${t2[1]}";
    } else {
      for (var i = 0; i < (savePoint - (t2[1] as String).length); i++) {
        t2[1] += "0";
      }
      return "${t2[0]}.${t2[1]}";
    }
  } else {
    String zero = "";
    if (savePoint > 0) {
      for (var i = 0; i < savePoint; i++) {
        if (i == 0) zero += ".";
        zero += "0";
      }
    }
    return "${t2[0]}$zero";
  }
}

String thousandFormat(dynamic num, {int savePoint = 0, bool haveUnit = true}) {
  double dTmp = 0.0;
  if (num is int) {
    dTmp = num * 1.0;
    return "${("${(num / 10000)}".split("."))[0]}${haveUnit ? "万" : ""}";
  } else if (num is double) {
    dTmp = num;
  } else if (num is String) {
    List t = num.split(".");
    if (t.length > 1) {
      dTmp = int.parse(t[0]) * 1.0;
    } else {
      dTmp = int.parse(num) * 1.0;
    }
  }

  List t2 = "${dTmp / 10000}".split(".");
  if (t2.length > 1) {
    if (savePoint > 0) {
      String result = "";
      if (t2[1].length < savePoint) {
        result = "${t2[0]}.${t2[1]}";
        for (var i = 0; i < savePoint - t2[1].length; i++) {
          result += "0";
        }
      } else {
        result = "${t2[0]}.${(t2[1] as String).substring(0, savePoint)}";
      }
      return "$result${haveUnit ? "万" : ""}";
    } else {
      return "${t2[0]}${haveUnit ? "万" : ""}";
    }
  } else {
    if (savePoint > 0) {
      String result = "${t2[0]}.";
      for (var i = 0; i < savePoint; i++) {
        result += "0";
      }
      return "$result${haveUnit ? "万" : ""}";
    } else {
      return "${t2[0]}${haveUnit ? "万" : ""}";
    }
  }
}

Widget getSubmitBtn(
  String? title,
  Function() onPressed, {
  bool enable = true,
  double? width,
  double? height,
  Color? color,
  Color? textColor,
  double? radius,
  double? fontSize,
  LinearGradient? linearGradient,
  bool isBold = false,
}) {
  return CustomButton(
    onPressed: enable ? onPressed : null,
    child: Opacity(
      opacity: enable ? 1.0 : 0.5,
      child: Container(
        width: width != null ? width.w : 345.w,
        height: height != null ? height.w : 45.w,
        decoration: BoxDecoration(
          gradient: color != null
              ? null
              : (linearGradient ??
                  LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppDefault().getThemeColor(index: 0) ??
                            const Color(0xFF6796F5),
                        AppDefault().getThemeColor(index: 2) ??
                            const Color(0xFF2368F2),
                      ])),
          color: color,
          borderRadius: BorderRadius.circular(radius ?? 25.w),
        ),
        child: Center(
          child: getSimpleText(
              title ?? "", fontSize ?? 15, textColor ?? Colors.white,
              isBold: isBold),
        ),
      ),
    ),
  );
}

void alipayH5payBack(
    {required String url,
    required Map<String, dynamic> params,
    // required OrderResultType type,
    // required StoreOrderType orderType,

    bool needJump = true}) {
  simpleRequest(
    url: url,
    params: params,
    success: (success, json) {
      if (success) {
        Map data = json["data"] ?? {};
        if (data["orderState"] != null) {
          alipayCallBackHandle(
              result: {
                "resultStatus": data["orderState"] == 0 ? "6001" : "9000"
              },
              payOrder: data,
              // orderType: orderType,
              // type: type,
              needJump: needJump);
        }
      }
    },
    after: () {},
  );
}

void alipayCallBackHandle(
    {required Map result,
    // required OrderResultType type,
    // required StoreOrderType orderType,
    bool needJump = true,
    required Map payOrder}) {
  if (result["resultStatus"] == "6001") {
    if (needJump) {
      toPayResult(orderData: payOrder, toOrderDetail: true);
    }
  } else if (result["resultStatus"] == "9000") {
    toPayResult(orderData: payOrder);
  }
}

Widget getLoginBtn(
  String? title,
  Function() onPressed, {
  bool enable = true,
  double? width,
  double? height,
  Color? color,
  Color? textColor,
  bool haveShadow = false,
}) {
  return CustomButton(
    onPressed: enable ? onPressed : null,
    child: Opacity(
      opacity: enable ? 1.0 : 0.5,
      child: Container(
        width: width != null ? width.w : 345.w,
        height: height != null ? height.w : 45.w,
        decoration: BoxDecoration(
            color: AppDefault().getThemeColor() ?? AppColor.theme,
            borderRadius: BorderRadius.circular(22.5.w),
            boxShadow: enable && haveShadow
                ? [
                    BoxShadow(
                        color: const Color(0x4C1652C9),
                        offset: Offset(0, 5.w),
                        blurRadius: 15.w)
                  ]
                : null),
        child: Center(
          child: getSimpleText(title ?? "", 15, textColor ?? Colors.white,
              isBold: true),
        ),
      ),
    ),
  );
}

takeBackKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

String bankCardFormat(String cardId) {
  String tmp = "";
  String tmp2 = cardId;
  if (cardId.isNotEmpty && cardId.length > 3) {
    tmp += tmp2.substring(0, 4);
    tmp2 = tmp2.substring(4, tmp2.length);

    while (tmp2.length > 3) {
      tmp += "  ${tmp2.substring(0, 4)}";
      tmp2 = tmp2.substring(4, tmp2.length);
    }

    if (tmp2.length > 0) {
      tmp += "  ${tmp2.substring(0, tmp2.length)}";
    }
  }

  return tmp;
}

// showPayPasswordModel(Function()? payback) {
//   Get.bottomSheet(

//   );
// }

double paddingSizeBottom(BuildContext context) {
  final MediaQueryData data = MediaQuery.of(context);
  EdgeInsets padding = data.padding;
  padding = padding.copyWith(bottom: data.viewPadding.bottom);
  return padding.bottom;
}

double paddingSizeTop(BuildContext context) {
  final MediaQueryData data = MediaQuery.of(context);
  EdgeInsets padding = data.padding;
  padding = padding.copyWith(bottom: data.viewPadding.top);
  return padding.top;
}

Future<String> image2Base64(String path) async {
  File file = File(path);
  List<int> imageBytes = await file.readAsBytes();
  return convert.base64Encode(imageBytes);
}

Future<void> setUserDataFormat(
    bool isSetOrClean, Map? hData, Map? pData, Map? lData,
    {bool sendNotification = false}) async {
  AppDefault appDefault = AppDefault();
  if (isSetOrClean) {
    appDefault.loginStatus = true;
    if (hData != null && hData.isNotEmpty) {
      appDefault.homeData = hData;
      appDefault.imageView = hData["imageView"] ?? "";
      bool cClient = (appDefault.homeData["u_Role"] ?? 0) == 0;
      bus.emit(NOTIFY_CHANGE_USER_STATUS, cClient);
      await UserDefault.saveStr(HOME_DATA, convert.jsonEncode(hData));
      await UserDefault.saveBool(USER_STATUS_DATA, (hData["u_Role"] ?? 0) == 0);
    }
    if (pData != null && pData.isNotEmpty) {
      appDefault.publicHomeData = pData;
      await UserDefault.saveStr(PUBLIC_HOME_DATA, convert.jsonEncode(pData));
      getImageUrl(pData);
      appDefault.setThemeColorList();
    }
    if (lData != null && lData.isNotEmpty) {
      appDefault.loginData = lData;
      await UserDefault.saveStr(LOGIN_DATA, convert.jsonEncode(lData));
      if (lData["token"] != null) {
        await UserDefault.saveStr(USER_TOKEN, lData["token"]);
        appDefault.token = lData["token"];
      }
    }
    if (sendNotification) {
      bus.emit(USER_LOGIN_NOTIFY);
    }
  } else {
    if (appDefault.loginStatus == true) {
      appDefault.loginStatus = false;
    }
    UserDefault.removeByKey(HOME_DATA);
    // UserDefault.removeByKey(PUBLIC_HOME_DATA);
    UserDefault.removeByKey(LOGIN_DATA);
    UserDefault.removeByKey(USER_TOKEN);
    UserDefault.removeByKey(QR_IMAGE_DATA);
    UserDefault.removeByKey(USER_STATUS_DATA);
    for (var key in AppDefault().requstCacheList) {
      UserDefault.removeByKey(key);
    }
    AppDefault().requstCacheList.clear();
    appDefault.token = "";
    appDefault.homeData = {};
    // appDefault.publicHomeData = {};
    appDefault.loginData = {};
    // appDefault.imageUrl = "";
    if (sendNotification) {
      bus.emit(USER_LOGIN_NOTIFY);
    }
  }
  return Future.value();
}

Future<Map> getUserData() async {
  AppDefault appDefault = AppDefault();
  Map userData = {};
  if (appDefault.homeData.isEmpty) {
    String homeDataStr = await UserDefault.get(HOME_DATA) ?? "";
    userData["homeData"] =
        homeDataStr.isNotEmpty ? convert.jsonDecode(homeDataStr) : {};
    appDefault.homeData = userData["homeData"];

    String publicHomeDataStr = await UserDefault.get(PUBLIC_HOME_DATA) ?? "";
    userData["publicHomeData"] = publicHomeDataStr.isNotEmpty
        ? convert.jsonDecode(publicHomeDataStr)
        : {};
    appDefault.publicHomeData = userData["publicHomeData"] ?? {};
    getImageUrl(appDefault.publicHomeData);
    appDefault.setThemeColorList();
    appDefault.imageView = appDefault.homeData["imageView"] ?? "";
  } else {
    userData["homeData"] = appDefault.homeData;
    userData["publicHomeData"] = appDefault.publicHomeData;
    // appDefault.imageUrl = appDefault.publicHomeData.isNotEmpty
    //     ? userData["publicHomeData"]["webSiteInfo"]["System_Images_Url"]
    //     : "";
    getImageUrl(appDefault.publicHomeData);
    appDefault.setThemeColorList();
    appDefault.imageView = appDefault.homeData["imageView"] ?? "";
  }
  appDefault.loginStatus =
      appDefault.homeData.isNotEmpty && appDefault.publicHomeData.isNotEmpty;
  if (appDefault.loginStatus && appDefault.deviceId.isEmpty) {
    appDefault.deviceId = await PlatformDeviceId.getDeviceId ?? "";
  }
  return userData;
}

String getImageUrl(Map pData) {
  AppDefault appDefault = AppDefault();
  if (HttpConfig.baseUrl.contains(AppDefault.oldSystem)) {
    appDefault.imageUrl =
        (pData["webSiteInfo"] ?? {})["System_Images_Url"] ?? "";
  } else {
    appDefault.imageUrl =
        ((pData["webSiteInfo"] ?? {})["app"] ?? {})["apP_Images_Url"] ?? "";
  }
  return appDefault.imageUrl;
}

String jsonConvert(dynamic object, int deep, {bool isObject = false}) {
  var buffer = StringBuffer();
  var nextDeep = deep + 1;
  if (object is Map) {
    var list = object.keys.toList();
    if (!isObject) {
      //如果map来自某个字段，则不需要显示缩进
      buffer.write(getDeepSpace(deep));
    }
    buffer.write("{");
    if (list.isEmpty) {
      //当map为空，直接返回‘}’
      buffer.write("}");
    } else {
      buffer.write("\n");
      for (int i = 0; i < list.length; i++) {
        buffer.write("${getDeepSpace(nextDeep)}\"${list[i]}\":");
        buffer.write(jsonConvert(object[list[i]], nextDeep, isObject: true));
        if (i < list.length - 1) {
          buffer.write(",");
          buffer.write("\n");
        }
      }
      buffer.write("\n");
      buffer.write("${getDeepSpace(deep)}}");
    }
  } else if (object is List) {
    if (!isObject) {
      //如果list来自某个字段，则不需要显示缩进
      buffer.write(getDeepSpace(deep));
    }
    buffer.write("[");
    if (object.isEmpty) {
      //当list为空，直接返回‘]’
      buffer.write("]");
    } else {
      buffer.write("\n");
      for (int i = 0; i < object.length; i++) {
        buffer.write(jsonConvert(object[i], nextDeep));
        if (i < object.length - 1) {
          buffer.write(",");
          buffer.write("\n");
        }
      }
      buffer.write("\n");
      buffer.write("${getDeepSpace(deep)}]");
    }
  } else if (object is String) {
    //为字符串时，需要添加双引号并返回当前内容
    buffer.write("\"$object\"");
  } else if (object is num || object is bool) {
    //为数字或者布尔值时，返回当前内容
    buffer.write(object);
  } else {
    //如果对象为空，则返回null字符串
    buffer.write("null");
  }
  return buffer.toString();
}

String getDeepSpace(int deep) {
  var tab = StringBuffer();
  for (int i = 0; i < deep; i++) {
    tab.write("\t");
  }
  return tab.toString();
}

int getRandomInt(int min, int max) {
  final _random = math.Random();
//将 参数min + 取随机数（最大值范围：参数max -  参数min）的结果 赋值给变量 result;
  var result = min + _random.nextInt(max - min);
//返回变量 result 的值;
  return result;
}

class Global {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool showLogin = false;
  static void toLogin({bool isLogin = true, bool animation = true}) {
    // if (!showLogin) {
    //   showLogin = true;
    //   Navigator.of(Global.navigatorKey.currentState!.context).push(animation
    //       ? MaterialPageRoute(
    //           builder: (_) {
    //             return Login(
    //               isLogin: isLogin,
    //             );
    //           },
    //           fullscreenDialog: true)
    //       : PageRouteBuilder(
    //           pageBuilder: (context, animation, secondaryAnimation) {
    //             return Login(
    //               isLogin: isLogin,
    //             );
    //           },
    //         ));
    // }
  }
}

// class SelectView extends StatefulWidget {
//   final double margin;
//   final String title;
//   final double labelWidth;
//   final double lineHeight;
//   final TextStyle labelStyle;
//   final List dataList;

//   final Function(int value, dynamic data)? selectValueChange;
//   SelectView(
//       {this.margin = 0,
//       this.title = '',
//       this.labelWidth = 0,
//       @required this.dataList = [],
//       this.lineHeight = 50,
//       this.selectValueChange,
//       this.labelStyle = text_black_style14});
//   @override
//   _SelectViewState createState() => _SelectViewState();
// }

// class _SelectViewState extends State<SelectView> {
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return Padding(
//       padding: EdgeInsets.only(left: widget.margin),
//       child: RegistSelectInput(
//         labelStyle: widget.labelStyle,
//         title: widget.title,
//         width: SizeConfig.screenWidth - widget.margin * 2,
//         labelWidth: widget.labelWidth ?? SizeConfig.blockSizeHorizontal * 22,
//         dataList: widget.dataList,
//         hintText: '请选择' + widget.title,
//         height: widget.lineHeight,
//         border: Border.all(color: Colors.transparent, width: 0.0),
//         selectedChange: widget.selectValueChange != null
//             ? widget.selectValueChange
//             : (int value, dynamic data) {},
//       ),
//     );
//   }
// }

//   void showList(List data) {
//     // focusNode.unfocus();
//     // pushSearchView(
//     //   context,
//     //   dataList: data,
//     //   hintText: widget.hintText,
//     //   text: selfValue,
//     // );
//     // if (!isShow) {
//     //   FocusScope.of(context).requestFocus(FocusNode());
//     //   this._overlayEntry = this.createOverlayEntry(data);
//     //   Overlay.of(context).insert(this._overlayEntry);
//     //   isShow = true;
//     // }
//   }

//   void removeList() {
//     // Overlay.of(context).
//     // if (isShow) {
//     //   _overlayEntry.remove();
//     //   isShow = false;
//     // }
//     if (isShow) {
//       Navigator.pop(context);
//     }
//   }

//   OverlayEntry createOverlayEntry(List data) {
//     RenderBox renderBox = context.findRenderObject();
//     var size = renderBox.size;
//     Widget c = Container();
//     return OverlayEntry(
//         builder: (context) => Positioned(
//               width: size.width,
//               child: CompositedTransformFollower(
//                 link: this._layerLink,
//                 showWhenUnlinked: false,
//                 offset: Offset(0.0, size.height + 5.0),
//                 child: Material(
//                   elevation: 4.0,
//                   child: ListView.builder(
//                     padding: EdgeInsets.zero,
//                     shrinkWrap: true,
//                     itemCount: data.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text((data[index])['name']),
//                         onTap: () {
//                           if (widget.showListClick != null) {
//                             widget.showListClick(data[index]);
//                           }
//                           removeList();
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ));
//   }

//   Widget getlabel(String title, bool must) {
//     Widget textWidget;
//     if (must) {
//       textWidget = RichText(
//         text: TextSpan(
//             text: '*',
//             style: TextStyle(color: Colors.red, fontSize: 14),
//             children: <TextSpan>[
//               TextSpan(text: title, style: widget.labelStyle)
//             ]),
//       );
//     } else {
//       textWidget = Text(
//         title,
//         style: widget.labelStyle,
//       );
//     }
//     return textWidget;
//   }
// }
