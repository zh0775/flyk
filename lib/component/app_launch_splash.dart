import 'dart:async';
import 'dart:typed_data';

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/routers/app_pages.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppLaunchSplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AppLaunchSplashController>(AppLaunchSplashController());
  }
}

class AppLaunchSplashController extends GetxController {
  OverlayEntry? overlayEntry;
  OverlayEntry createOverlayEntry(BuildContext context) {
    return OverlayEntry(
        builder: (context) => Positioned(
              width: ScreenUtil().screenWidth,
              height: ScreenUtil().screenHeight,
              child: Material(
                  elevation: 0.0,
                  child: SpWidget(
                    imageData: qrByte,
                    number: shareNum,
                    logoUrl: logoUrl,
                    colseAction: hideLaunchSpash,
                  )),
            ));
  }

  hideLaunchSpash() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  bool showLaunchSpash(BuildContext context, Function()? safePop) {
    OverlayState? state = Overlay.of(context);
    overlayEntry = createOverlayEntry(context);
    if (state == null) {
      if (safePop != null) {
        safePop();
      }
      return false;
    }
    if (overlayEntry != null) {
      state.insert(overlayEntry!);
      if (safePop != null) {
        safePop();
      }
      return true;
    }
    if (safePop != null) {
      safePop();
    }
    return false;
  }

  Uint8List? qrByte;
  String shareNum = "";
  String logoUrl = "";
  loadData() async {
    await getUserData();
    // Map publicHomeData = AppDefault().publicHomeData;

    // String url =
    //     (((publicHomeData["webSiteInfo"] ?? {})["app"] ?? {})["apP_Logo"] ??
    //         "");
    // if (url.isEmpty) {
    //   show();
    //   return;
    // }
    // logoUrl = AppDefault().imageUrl + url;
    // if (logoUrl.contains("localhost") || AppDefault().imageUrl.isEmpty) {
    //   show();
    //   return;
    // }
    // try {
    //   CachedNetworkImageProvider p = CachedNetworkImageProvider(
    //     logoUrl,
    //     errorListener: () {
    //       show();
    //     },
    //   );
    //   ImageStream stream = p.resolve(const ImageConfiguration());
    //   stream.addListener(
    //       ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
    //     show();
    //   }));
    // } catch (e) {
    //   // show();
    // }

    show();
  }

  show() {
    showLaunchSpash(context, () {
      Future.delayed(Duration.zero, () {
        Get.offUntil(
            GetPageRoute(
              settings: const RouteSettings(name: "MainPage"),
              page: () => const MainPage(),
              binding: MainPageBinding(),
              transition: Transition.noTransition,
            ), (route) {
          if (route.settings.name == Routes.splash ||
              route.settings.name == "showUpdateEventAlert") {
            return false;
          }
          return true;
        });
      });
    });
  }

  bool isFirst = true;
  late BuildContext context;
  Function()? colseAction;

  dataInit(BuildContext ctx) {
    if (!isFirst) return;
    isFirst = false;
    context = ctx;
  }

  @override
  void onReady() {
    loadData();
    super.onReady();
  }
}

class AppLaunchSplash extends GetView<AppLaunchSplashController> {
  const AppLaunchSplash({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    controller.dataInit(context);
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(assetsName("common/launch_image"))))));
  }
}

class SpWidget extends StatefulWidget {
  final Function()? colseAction;
  final Uint8List? imageData;
  final String number;
  final String logoUrl;
  const SpWidget(
      {super.key,
      this.colseAction,
      this.imageData,
      this.number = "",
      this.logoUrl = ""});

  @override
  State<SpWidget> createState() => _SpWidgetState();
}

class _SpWidgetState extends State<SpWidget> {
  int count = 3;
  Timer? timer;
  // Uint8List? imageData;
  // String number = "";

  timerAction(Timer t) {
    if (count == 1) {
      timer?.cancel();
      timer = null;
      if (widget.colseAction != null) {
        widget.colseAction!();
      }
    }
    if (mounted) {
      setState(() {
        count--;
      });
    }
  }

  // loadData() {
  //   getUserData().then((value) {
  //     if ((AppDefault().homeData["u_Number"] ?? "").isNotEmpty) {
  //       setState(() {
  //         number = "推荐码：${AppDefault().homeData["u_Number"] ?? ""}";
  //       });
  //     }
  //   });

  //   UserDefault.get(QR_IMAGE_DATA).then((value) {
  //     setState(() {
  //       imageData = value;
  //     });
  //   });
  //   if (imageData != null) {
  //     setState(() {});
  //   }
  // }

  @override
  void initState() {
    // loadData();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (timer != null) {
        timer?.cancel();
        timer = null;
      }
      timer = Timer.periodic(const Duration(seconds: 1), timerAction);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              assetsName("common/launch_image"),
              fit: BoxFit.fill,
            )),
            Positioned(
              top: paddingSizeTop(context) + 30.w,
              right: 20.w,
              child: CustomButton(
                onPressed: () {
                  if (widget.colseAction != null) {
                    timer?.cancel();
                    timer = null;
                    widget.colseAction!();
                  }
                },
                child: Container(
                  // width: 52.5.w,
                  height: 24.w,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.w),
                      color: Colors.black.withOpacity(0.1)),
                  child: Center(
                    child: getSimpleText("跳过 ${count}S", 14, Colors.white),
                  ),
                ),
              ),
            ),
            Positioned.fill(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // widget.imageData != null
                //     ? Container(
                //         width: 93.w,
                //         height: 93.w,
                //         decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(2.w)),
                //         child: Center(
                //             child: Image.memory(
                //           widget.imageData!,
                //           width: 85.w,
                //           height: 85.w,
                //           fit: BoxFit.fill,
                //         )))
                //     : ghb(0),
                // ghb(14),
                // getSimpleText(widget.number, 12, AppColor.textBlack),
                CustomNetworkImage(
                  src: widget.logoUrl,
                  width: 70.w,
                  height: 70.w,
                  fit: BoxFit.fill,
                ),
                ghb(50),
                gwb(375),
                SizedBox(
                  height: paddingSizeBottom(context),
                )
              ],
            ))
          ],
        ));
  }
}
