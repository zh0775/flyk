import 'dart:typed_data';

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

class MerchantAccessNetworkDetail extends StatelessWidget {
  final Map productInfo;
  const MerchantAccessNetworkDetail({super.key, this.productInfo = const {}});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF314BA8),
      appBar: getDefaultAppBar(context, "商户入网", color: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            gwb(375),
            ghb(4),
            contentView(
                "icon_qr",
                Column(
                  children: [
                    qrImageContent(),
                    ghb(16),
                    getSubmitBtn("保存到相册", () {
                      saveImage();
                    }, width: 295, height: 48)
                  ],
                )),
            ghb(10),
            contentView(
                "icon_download",
                Column(
                  children: [
                    ghb(5),
                    sbRow([
                      centRow([
                        getSimpleText("${productInfo["title"] ?? ""}产品下载地址", 14,
                            const Color(0xFF5C6166),
                            fw: AppDefault.fontBold),
                        gwb(12),
                        Image.asset(
                          assetsName("home/merchantaccessnetwork/icon_link"),
                          width: 18.w,
                          fit: BoxFit.fitWidth,
                        )
                      ])
                    ], width: 343 - 14 * 2),
                    ghb(6),
                    CustomButton(
                      onPressed: () async {
                        bool lanuch = await launchUrl(
                            Uri.parse(productInfo["url"] ?? ""),
                            mode: LaunchMode.externalApplication);
                      },
                      child: getWidthText(productInfo["url"] ?? "", 14,
                          const Color(0xFF2368F2), 343 - 14 * 2, 2),
                    ),
                    ghb(6),
                    getWidthText(
                        "xxx软件提示你进入链接下载软件，帮你商户入网，你只要按照软件提示提供准确信息即可认证入网，方便快捷...",
                        12,
                        const Color(0xFF5C6166),
                        343 - 14 * 2,
                        1000),
                  ],
                )),
            ghb(10),
            contentView(
                "icon_rwts",
                Column(
                  children: [
                    SizedBox(
                        width: (343 - 8.5 * 2).w,
                        child: HtmlWidget(productInfo["content"] ?? "")),
                  ],
                )),
            SizedBox(
              height: paddingSizeBottom(context),
            ),
            ghb(15),
          ],
        ),
      ),
    );
  }

  Widget contentView(String topImg, Widget child) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 43.w,
          width: 345.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  top: 19.w,
                  left: 1.w,
                  right: 1.w,
                  bottom: -1.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(8.w)),
                    ),
                  )),
              Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  height: 38.w,
                  child: Center(
                    child: Image.asset(
                      assetsName("home/merchantaccessnetwork/$topImg"),
                      height: 38.w,
                      fit: BoxFit.fitHeight,
                    ),
                  )),
              Positioned(
                  top: 18.w,
                  left: 0,
                  child: Image.asset(
                    assetsName("home/merchantaccessnetwork/border_topleft"),
                    width: 25.w,
                    fit: BoxFit.fitWidth,
                  )),
              Positioned(
                  right: 0,
                  top: 18.w,
                  child: Image.asset(
                    assetsName("home/merchantaccessnetwork/border_topright"),
                    width: 25.w,
                    fit: BoxFit.fitWidth,
                  )),
            ],
          ),
        ),
        Container(
          width: 343.w,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: child,
        ),
        SizedBox(
          width: 345.w,
          height: 25.5.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  top: -1.w,
                  left: 1.w,
                  right: 1.w,
                  height: 25.5.w,
                  child: Container(
                    // width: 343.w,
                    // height: 24.5.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8.w),
                        ),
                        color: Colors.white),
                  )),
              Positioned(
                  bottom: 0,
                  left: 0,
                  height: 24.5.w,
                  child: Image.asset(
                    assetsName("home/merchantaccessnetwork/border_bottomleft"),
                    height: 24.5.w,
                    fit: BoxFit.fitHeight,
                  )),
              Positioned(
                  bottom: 0,
                  right: 0,
                  height: 24.5.w,
                  child: Image.asset(
                    assetsName("home/merchantaccessnetwork/border_bottomright"),
                    height: 24.5.w,
                    fit: BoxFit.fitHeight,
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget qrImageContent() {
    return SizedBox(
      width: 317.w,
      height: 336.w,
      child: Stack(
        children: [
          Positioned.fill(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: CustomNetworkImage(
                    src:
                        AppDefault().imageUrl + (productInfo["coverImg"] ?? ""),
                    width: 317.w,
                    height: 336.w,
                  ))),
          Positioned(
              bottom: 6.w,
              left: 0,
              right: 0,
              child: Center(
                child: sbRow([
                  centRow([
                    ClipRRect(
                        borderRadius: BorderRadius.circular(6.w),
                        child: CustomNetworkImage(
                          src: AppDefault().imageUrl +
                              (productInfo["m_Image"] ?? ""),
                          width: 42.w,
                          height: 42.w,
                          fit: BoxFit.cover,
                        )),
                    gwb(12),
                    centClm([
                      getSimpleText(
                          productInfo["title"] ?? "", 14, Colors.white,
                          fw: AppDefault.fontBold),
                      ghb(3),
                      getWidthText(
                          productInfo["meta"] ?? "", 14, Colors.white, 180, 3),
                    ], crossAxisAlignment: CrossAxisAlignment.start),
                  ]),
                  QrImage(
                    data: productInfo["url"] ?? "",
                    size: 42.w,
                    padding: EdgeInsets.zero,
                  ),
                ], width: 317 - 14 * 2),
              ))
        ],
      ),
    );
  }

  saveImage() async {
    Uint8List byte = await ScreenshotController().captureFromWidget(
      qrImageContent(),
      delay: const Duration(milliseconds: 100),
    );
    saveImageToAlbum(byte);
  }
}
