import 'package:cxhighversion2/component/custom_dotted_line_painter.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyWalletDrawDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyWalletDrawDetailController>(
        MyWalletDrawDetailController(datas: Get.arguments));
  }
}

class MyWalletDrawDetailController extends GetxController {
  final dynamic datas;
  MyWalletDrawDetailController({this.datas});
  Map drawData = {};

  final _accountName = "".obs;
  String get accountName => _accountName.value;
  set accountName(v) => _accountName.value = v;

  final _currentAccound = "".obs;
  String get currentAccound => _currentAccound.value;
  set currentAccound(v) => _currentAccound.value = v;

  String img = "";

  @override
  void onInit() {
    drawData = datas["drawData"] ?? {};
    img = AppDefault().getAccountImg(drawData["account"]);
    accountName =
        drawData["bankName"] == null ? "支付宝账户" : "银行账户-${drawData["bankName"]}";
    currentAccound = drawData["bankName"] != null
        ? drawData["bankAccountName"]
        : "支付宝：${drawData["onlineAccount"]}";
    super.onInit();
  }
}

class MyWalletDrawDetail extends GetView<MyWalletDrawDetailController> {
  const MyWalletDrawDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "提现详情"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ghb(16),
            gwb(375),
            Container(
              width: 345.w,
              color: Colors.white,
              child: Column(
                children: [
                  ghb(20),
                  controller.img.isEmpty
                      ? ghb(0)
                      : CustomNetworkImage(
                          src: AppDefault().imageUrl + controller.img,
                          height: 58.w,
                          fit: BoxFit.fitHeight,
                        ),
                  ghb(15),
                  GetX<MyWalletDrawDetailController>(
                    init: controller,
                    builder: (_) {
                      return getSimpleText(
                          "${controller.drawData["accountName"] ?? ""}提现-到${controller.accountName}",
                          14,
                          AppColor.text2);
                    },
                  ),
                  ghb(8),
                  getSimpleText(
                      "￥${priceFormat(controller.drawData["amount"])}",
                      24,
                      AppColor.text,
                      fw: FontWeight.w600),
                  ghb(25),
                  gline(314, 0.5),
                  ghb(30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gwb(31.5),
                      getSimpleText("当前进度", 12, AppColor.text2),
                      gwb(29.5),
                      centClm([
                        ghb(3.5),
                        getPoint(isActive: true, color: AppColor.theme),
                        ghb(1.5),
                        getDashLine(isActive: true),
                        ghb(1.5),
                        getPoint(
                            isActive: true,
                            size: controller.drawData["managed"] == 0 ||
                                    controller.drawData["managed"] == 1
                                ? 33
                                : 7,
                            color: AppColor.theme),
                        ghb(1.5),
                        getDashLine(isActive: true),
                        Image.asset(
                          assetsName(
                              "machine/icon_result_${controller.drawData["managed"] != 0 && controller.drawData["managed"] != 1 && controller.drawData["managed"] != 2 ? "fail" : "success"}"),
                          width: 14.w,
                          fit: BoxFit.fitWidth,
                        ),
                        // getPoint(
                        //   isActive: controller.drawData["managed"] == 0 ||
                        //           controller.drawData["managed"] == 1
                        //       ? false
                        //       : true,
                        //   size: controller.drawData["managed"] == 0 ||
                        //           controller.drawData["managed"] == 1
                        //       ? 7
                        //       : 33,
                        //   color: controller.drawData["managed"] != 0 &&
                        //           controller.drawData["managed"] != 1 &&
                        //           controller.drawData["managed"] != 2
                        //       ? const Color(0xFFFB4746)
                        //       : null,
                        // ),
                      ]),
                      gwb(12),
                      centClm([
                        SizedBox(
                          height: 71.w,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: centClm([
                              getSimpleText("提交申请", 14, AppColor.text3),
                              ghb(5),
                              getSimpleText(controller.drawData["addTime"], 14,
                                  AppColor.text3)
                            ], crossAxisAlignment: CrossAxisAlignment.start),
                          ),
                        ),
                        ghb(
                          (controller.drawData["managed"] == 0 ||
                                  controller.drawData["managed"] == 1
                              ? 13
                              : 0),
                        ),
                        SizedBox(
                          height: 71.w,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: centClm([
                              getSimpleText(
                                  "处理中",
                                  14,
                                  controller.drawData["managed"] == 0 ||
                                          controller.drawData["managed"] == 1
                                      ? AppColor.theme
                                      : AppColor.text3),
                              ghb(5),
                            ], crossAxisAlignment: CrossAxisAlignment.start),
                          ),
                        ),
                        centClm([
                          getSimpleText(
                              controller.drawData["managedStr"],
                              14,
                              (controller.drawData["managed"] != 0 &&
                                      controller.drawData["managed"] != 1 &&
                                      controller.drawData["managed"] != 2)
                                  ? const Color(0xFFEF6B6B)
                                  : AppColor.theme),
                          ghb(5),
                          getSimpleText(
                              controller.drawData["addTime"],
                              14,
                              (controller.drawData["managed"] != 0 &&
                                      controller.drawData["managed"] != 1 &&
                                      controller.drawData["managed"] != 2)
                                  ? const Color(0xFFEF6B6B)
                                  : AppColor.theme),
                        ], crossAxisAlignment: CrossAxisAlignment.start),
                      ], crossAxisAlignment: CrossAxisAlignment.start)
                    ],
                  ),
                  ghb(29.5),
                  gline(314, 0.5),
                  ghb(20),
                  infoCell(
                      "提现金额", "￥${priceFormat(controller.drawData["amount"])}"),
                  infoCell(
                      "服务费", "￥${priceFormat(controller.drawData["income"])}"),
                  infoCell("申请时间", controller.drawData["addTime"]),
                  infoCell(
                      "到账时间",
                      controller.drawData["passTime"] != null &&
                              controller.drawData["passTime"].isNotEmpty
                          ? controller.drawData["passTime"]
                          : "—.—.—"),
                  infoCell("提现账户", controller.currentAccound),
                  infoCell("提现单号", controller.drawData["periodNo"]),
                  infoCell("备注", controller.drawData["managedStr"],
                      color2: AppColor.red),
                  ghb(20),
                  // ghb(74)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget infoCell(String t1, String t2, {Color? color2, double height = 30}) {
    return sbhRow([
      getWidthText(t1, 12, AppColor.text3, 87.5, 1),
      getWidthText(t2, 12, color2 ?? AppColor.text2, 315 - 87.5 - 0.1, 1,
          alignment: Alignment.centerRight)
    ], width: 345 - 15 * 2, height: height);
  }

  Widget getPoint({required bool isActive, double size = 7, Color? color}) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
          color:
              color ?? (isActive ? const Color(0xFF32B16C) : AppColor.textGrey),
          borderRadius: BorderRadius.circular((size / 2).w)),
    );
  }

  Widget getDashLine({required bool isActive}) {
    Path path = Path();
    path.moveTo(0.75.w, 0);
    path.lineTo(0.75.w, 62.5.w);
    return CustomPaint(
      painter: CustomDottedPinePainter(
          color: isActive ? AppColor.theme : AppColor.textGrey,
          // path: parseSvgPathData('m0,0 l0,${62.5.w} Z')),
          path: path),
      size: Size(1.5.w, 62.5.w),
    );
  }
}
