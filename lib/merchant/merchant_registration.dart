// 商户注册页面

import 'dart:ui' as ui;
import 'dart:convert';
import 'package:cxhighversion2/component/custom_button.dart';

import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
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

class MerchantRegisterBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MerchantRegisterController>(MerchantRegisterController());
  }
}

class MerchantRegisterController extends GetxController {
  bool topAnimation = false;

  final _isLogin = false.obs;
  set isLogin(value) {
    _isLogin.value = value;
    update();
  }

  get isLogin => _isLogin.value;

  Map homeData = {};
  Map publicHomeData = {};
  String imageUrl = "";

  needUpdate() {
    getUserData().then((value) {
      homeData = AppDefault().homeData;
      publicHomeData = AppDefault().publicHomeData;
      imageUrl = AppDefault().imageUrl;
      isLogin = AppDefault().loginStatus;
    });
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final PageController pageCtrl = PageController();

  final _topCurrentIndex = 0.obs;
  int get topCurrentIndex => _topCurrentIndex.value;
  set topCurrentIndex(v) => _topCurrentIndex.value = v;

  List merchantRegistrationData = [];

  getMerchantRegistrationApi() {
    simpleRequest(
      url: Urls.merchantsNetList,
      params: {},
      otherData: {"pageSize": 20, "pageNo": 1},
      success: (success, json) {
        Map jsonData = json['data'] ?? {};
        merchantRegistrationData = jsonData['data'] ?? [];
        update();
      },
      after: () {
        isLoading = false;
      },
    );
  }

  @override
  void onReady() {
    needUpdate();
    super.onReady();
  }

  @override
  void onInit() {
    getMerchantRegistrationApi();
    super.onInit();
  }
}

class MerchantRegisterPage extends GetView<MerchantRegisterController> {
  const MerchantRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, '商户注册'),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 55.w,
            child: topBar(),
          ),
          Positioned.fill(
              top: 55.w, left: 0, right: 0, child: merchantBody(context))
        ],
        // children: [
        //   Positioned(
        //     top: 0,
        //     left: 0,
        //     right: 0,
        //     height: 55.w,
        //     child: topBar(),
        //   ),
        //   Positioned.fill(top: 55.w, left: 0, right: 0, child: merchantBody(context))
        // ],
      ),
    );
  }

  // 头部
  Widget topBar() {
    return GetBuilder<MerchantRegisterController>(builder: (_) {
      return Container(
          color: Colors.white,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 15.w, right: 15.w),
              child: Stack(children: [
                Positioned(
                    child: SizedBox(
                        height: 55.w,
                        child: Row(
                            children: List.generate(
                                controller.merchantRegistrationData.length,
                                (index) {
                          Map item =
                              controller.merchantRegistrationData[index] ?? {};
                          return Container(
                              margin: EdgeInsets.only(right: 10.w),
                              child: CustomButton(onPressed: () {
                                controller.topCurrentIndex = index;
                              }, child: GetX<MerchantRegisterController>(
                                  builder: (_) {
                                return Column(children: [
                                  ghb(18),
                                  getSimpleText("${item['title'] ?? ''}", 16,
                                      const Color(0xFF999999)),
                                  ghb(12),
                                  controller.topCurrentIndex == index
                                      ? Container(
                                          width: 15.w,
                                          height: 3.w,
                                          decoration: BoxDecoration(
                                            color: AppColor.theme,
                                            borderRadius:
                                                BorderRadius.circular(3.w / 2),
                                          ),
                                        )
                                      : ghb(0)
                                ]);
                              })));
                        }))))
                // GetX<MerchantRegisterController>(
                //   builder: (_) {
                //     return AnimatedPositioned(
                //         top: 52.w,
                //         left: 20.w,
                //         width: 15.w,
                //         height: 2.w,
                //         duration: const Duration(microseconds: 500),
                //         child: Container(
                //           color: AppColor.theme,
                //         ));
                //   },
                // )
              ])));
    });
  }

  // swipper
  Widget merchantBody(BuildContext context) {
    return GetBuilder<MerchantRegisterController>(
      builder: (_) {
        Map item = controller.merchantRegistrationData.isEmpty
            ? {}
            : (controller
                    .merchantRegistrationData[controller.topCurrentIndex] ??
                {});
        String userName = controller.isLogin
            ? (controller.homeData["nickName"] != null &&
                    controller.homeData["nickName"].isEmpty
                ? "请设置昵称"
                : controller.homeData["nickName"])
            : "请登录";
        return Container(
          width: 375.w,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(assetsName('merchant/bg')),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 65.w,
                left: 33.w,
                child: Container(
                  width: 375.w - 33.w * 2,
                  height: 420.w,
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 375.w - 33.w * 2,
                        height: 125.w,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ghb(61.w),
                            getSimpleText(userName, 18, const Color(0xFF333333),
                                isBold: true),
                            ghb(12.5),
                            getSimpleText(
                                "推荐码：${controller.homeData['u_Number'] ?? ''}",
                                12,
                                const Color(0xFF999999)),
                          ],
                        ),
                      ),
                      ghb(30.w),
                      qrWrapper(item),
                      ghb(13.w),
                      getSimpleText(
                          "长按识别二维码根据提示下载平台", 10, const Color(0xFF999999)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 30.w,
                left: 150.w,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(80.w / 2),
                  ),

                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(64.w / 2),
                      child: controller.isLogin
                          ? CustomButton(
                              onPressed: () {},
                              child: CustomNetworkImage(
                                src:
                                    "${controller.imageUrl}${controller.homeData["userAvatar"]}",
                                width: 64.w,
                                height: 64.w,
                                fit: BoxFit.cover,
                                errorWidget: Image.asset(
                                  assetsName("mine/default_head"),
                                  width: 64.w,
                                  height: 64.w,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            )
                          : Image.asset(
                              assetsName("mine/default_head"),
                              width: 64.w,
                              height: 64.w,
                              fit: BoxFit.fill,
                            )),
                  // child: ClipOval(
                  //   child: Image.network(
                  //     "https://dummyimage.com/100x100",
                  //     width: 64.w,
                  //     height: 64.w,
                  //   ),
                  // ),
                ),
              ),
              Positioned(
                  left: 33.w,
                  bottom: 15.w,
                  child: CustomButton(
                    onPressed: () async {
                      Uint8List imageBytes = await ScreenshotController()
                          .captureFromWidget(qrWrapper(item),
                              delay: const Duration(milliseconds: 100),
                              context: context);
                      saveAssetsImg(imageBytes);
                    },
                    child: Container(
                      width: 375.w - 33.w * 2,
                      height: 45.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFD573B),
                          borderRadius: BorderRadius.circular(45.w / 2)),
                      child: getSimpleText("保存图片", 16.w, Colors.white),
                    ),
                  ))
            ],
          ),
        );
      },
    );
  }

  Widget qrWrapper(item) {
    return Container(
        width: 210.w,
        height: 210.w,
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: const Color(0x1A000000), blurRadius: 10.w)
        ]),
        child: (item['coverImg'] == null)
            ? QrImageView(
                data: item['url'] ?? '',
                size: 195.w,
              )
            : Image.network(
                "${controller.imageUrl}${item['coverImg']}",
                width: 195.w,
                height: 195.w,
              ));
  }

  saveAssetsImg(Uint8List? imageBytes) async {
    if (kIsWeb) {
      if (imageBytes != null) {
        final base64data = base64Encode(imageBytes.toList());
        final a =
            html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');
        a.download = "${DateTime.now().millisecondsSinceEpoch}";
        a.click();
        a.remove();
      }
    } else {
      saveImageToAlbum(imageBytes);
    }
  }
}
