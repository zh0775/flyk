import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class MineVipLevalExplainBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineVipLevalExplainController>(MineVipLevalExplainController());
  }
}

class MineVipLevalExplainController extends GetxController {
  final _iconPage = 2.obs;
  int get iconPage => _iconPage.value;
  set iconPage(v) => _iconPage.value = v;

  final _iconPageIndex = 0.obs;
  int get iconPageIndex => _iconPageIndex.value;
  set iconPageIndex(v) => _iconPageIndex.value = v;

  Map homeData = {};
  String headImg = "";
  List iconList = [
    // {"img": "hd", "title": "活动"},
  ];

  List infoList = [];

  Map currentLevelData = {};
  bool isFirst = true;
  dataInit(Map data) {
    if (!isFirst) return;
    isFirst = false;
    currentLevelData = data;
    iconList = [];
    List rewardList = currentLevelData["equity_List"] ?? [];
    for (var i = 0; i < rewardList.length; i++) {
      if (i % 8 == 0) {
        iconList.add([]);
      }
      iconList[(i / 8).floor()].add(rewardList[i]);
    }
    iconPage = iconList.length;
  }

  @override
  void onInit() {
    homeData = AppDefault().homeData;
    headImg = homeData["userAvatar"];

    super.onInit();
  }
}

class MineVipLevalExplain extends GetView<MineVipLevalExplainController> {
  final int level;
  final Map currentLevelData;
  final Map levelInfo;
  const MineVipLevalExplain(
      {Key? key,
      required this.level,
      this.currentLevelData = const {},
      this.levelInfo = const {}})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(currentLevelData);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: getDefaultAppBar(
        context,
        "会员等级",
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              width: 375.w,
              height: 37.5.w,
            ),

            SizedBox(
              width: 345.w,
              height: 467.5.w,
              child: Stack(
                children: [
                  Positioned(
                      top: 62.w,
                      left: 15.w,
                      right: 15.w,
                      height: 150.w,
                      child: SizedBox(
                        width: 315.w,
                        height: 150.w,
                        child: currentLevelData.isNotEmpty &&
                                currentLevelData["cardImg"] != null
                            ? CustomNetworkImage(
                                src: AppDefault().imageUrl +
                                    currentLevelData["cardImg"],
                                width: 315.w,
                                height: 150.w,
                                fit: BoxFit.fill,
                              )
                            : gwb(0),
                      )),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 328.5.w,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: LevelPathPainter(),
                          ),
                        ),
                        Positioned(
                            left: 0,
                            bottom: 0,
                            child: Blur(
                                blur: 5,
                                blurColor: const Color(0x4C141519),
                                child: SizedBox(
                                  height: 316.5.w,
                                  width: 345.w,
                                )))
                      ],
                    ),
                  ),
                  Positioned(
                      left: 18.5.w,
                      top: 11.w,
                      child: sbRow([
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40.w),
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            color: Colors.white,
                            child: CustomNetworkImage(
                              src: AppDefault().imageUrl + controller.headImg,
                              width: 40.w,
                              height: 40.w,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        sbwClm([
                          getSimpleText(
                              controller.homeData["nickName"].isEmpty
                                  ? controller.homeData["u_Mobile"]
                                  : controller.homeData["nickName"],
                              13,
                              Colors.white,
                              isBold: true),
                          getSimpleText(
                              "推荐码：${controller.homeData["u_Number"] ?? ""}",
                              11,
                              AppColor.textGrey)
                        ],
                            height: 35,
                            width: 129.5,
                            crossAxisAlignment: CrossAxisAlignment.start)
                      ], width: 187)),
                  Positioned(
                      top: 172.w,
                      height: 47.w,
                      left: 0,
                      right: 0,
                      child: sbwClm([
                        getSimpleText("会员权益", 16, Colors.white, isBold: true),
                        getSimpleText(
                            "成为该等级的会员可享受以下专属权益", 12, const Color(0xFFB3B3B3)),
                      ], width: 375, height: 47)),
                  Positioned(
                      top: (219 + 31.5).w,
                      // left: 23.5.w,
                      // right: 23.5.w,
                      left: 15.w,
                      // right: 15.w,
                      right: 15.w,
                      bottom: 54.w,
                      child: PageView(
                        physics: const BouncingScrollPhysics(),
                        children: controller.iconList
                            .map((e) => SizedBox(
                                  width: 315.w,
                                  child: Wrap(
                                    spacing: 39.2.w,
                                    runSpacing: 23.w,
                                    children: [
                                      ...(e as List)
                                          .map((e) => iconVipBtn(
                                              e["enumName"] ?? "",
                                              e["logo"] ?? ""))
                                          .toList(),
                                    ],
                                  ),
                                ))
                            .toList(),
                      )),
                  Positioned(
                      left: 0,
                      right: 0,
                      height: 77.w,
                      top: 62.w,
                      child: SizedBox(
                        width: 345.w,
                        child: Center(
                          child: sbhRow([
                            getSimpleText(levelInfo["userLevelName"] ?? "", 32,
                                Colors.black,
                                fw: FontWeight.w800)
                          ], width: 345 - 39 * 2, height: 77),
                        ),
                      )),
                  Positioned(
                      bottom: 24.5.w,
                      left: 0,
                      right: 0,
                      height: 1.5.w,
                      child: GetX<MineVipLevalExplainController>(
                        init: controller,
                        builder: (_) {
                          return centRow([
                            ...List.generate(
                                controller.iconPage,
                                (index) => Container(
                                      width: 15.w,
                                      height: 1.5.w,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 2.5.w),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(0.75.w),
                                          color:
                                              index == controller.iconPageIndex
                                                  ? Colors.white
                                                  : AppColor.textGrey),
                                    )).toList()
                          ]);
                        },
                      ))
                ],
              ),
            ),

            // AsperctRaioImage.asset(
            //   assetsName("mine/vip/bg_vip${level}_explain"),
            //   builder: (context, snapshot, url) {
            //     double width = 345;
            //     double scale = snapshot.data!.width / width;
            //     double height = snapshot.data!.height / scale;
            //     debugPrint("height === $height");
            //     return SizedBox(
            //       width: width.w,
            //       height: height.w,
            //       child: Stack(
            //         children: [
            //           Positioned.fill(
            //             child: Image.asset(
            //               assetsName("mine/vip/bg_vip${level}_explain"),
            //               width: width.w,
            //               height: height.w,
            //             ),
            //           ),

            //         ],
            //       ),
            //     );
            //   },
            // ),
            ghb(15),
            Container(
              width: 345.w,
              height: 98.5.w,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(10.w)),
                  gradient: const LinearGradient(
                      begin: Alignment(0, -0.2),
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF151519), Color(0xFF1F2D33)])),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  getSimpleText("会员福利", 16, Colors.white, isBold: true),
                  ghb(15),
                  // infoCell("级别/礼包", "月交易量(元)", "电签机", "传统机", 0, -1),
                ],
              ),
            ),
            controller.currentLevelData["detailImg"] != null
                ? CustomNetworkImage(
                    src: AppDefault().imageUrl +
                        controller.currentLevelData["detailImg"],
                    width: 345.w,
                    fit: BoxFit.fitWidth,
                  )
                : ghb(0),

            // Container(
            //   width: 345.w,
            //   decoration: BoxDecoration(
            //     borderRadius:
            //         BorderRadius.vertical(bottom: Radius.circular(10.w)),
            //     color: const Color(0xFF141519),
            //   ),
            //   child: Column(
            //     children: [
            //       ...controller.infoList
            //           .asMap()
            //           .entries
            //           .map((e) => infoCell(
            //               "V${e.key + 1}/${e.value["levelCound"]}台",
            //               "${e.value["jyCount"]}",
            //               "${e.value["dq"]}",
            //               "${e.value["ct"]}",
            //               1,
            //               e.key))
            //           .toList(),
            //     ],
            //   ),
            // ),
            ghb(65)
          ],
        ),
      ),
    );
  }

  Widget iconVipBtn(String title, String img) {
    return SizedBox(
      width: (315 - 39.3 * 3).w / 4,
      height: 67.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          img.isNotEmpty
              ? CustomNetworkImage(
                  src: AppDefault().imageUrl + img,
                  width: 45.w,
                  height: 45.w,
                  fit: BoxFit.fill,
                )
              : ghb(
                  0,
                ),
          getSimpleText("$title奖", 12, Colors.white)
        ],
      ),
    );
  }

  Widget infoCell(
      String t1, String t2, String t3, String t4, int type, int index,
      {int? level, int? count}) {
    return sbhRow(
      [
        index + 1 == level
            ? SizedBox(
                width: 75.5.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: getRichText("V$level ?? 1", "/$count台", 11,
                      const Color(0xFFFF5353), 11, Colors.white),
                ),
              )
            : getWidthText(t1, type == 0 ? 12 : 11, Colors.white, 75.5, 1),
        getWidthText(t2, type == 0 ? 12 : 11, Colors.white, 118, 1,
            alignment: Alignment.center),
        getWidthText(t3, type == 0 ? 12 : 11,
            type == 0 ? Colors.white : const Color(0xFFF583FF), 70, 1,
            alignment: Alignment.center),
        getWidthText(t4, type == 0 ? 12 : 11,
            type == 0 ? Colors.white : const Color(0xFF54E5FF), 48, 1,
            alignment: Alignment.centerRight),
      ],
      width: 313,
      height: type == 0 ? 42 : 59,
    );
  }
}

class LevelPathPainter extends CustomPainter {
  // final Path? path;
  // final Color? color;
  LevelPathPainter({Key? key
      // this.path,
      // this.color,
      });
  Path? path;
  // @override
  // bool shouldRepaint(LevelPathPainter oldDelegate) =>
  //     oldDelegate.path != path || oldDelegate.color != color;
  @override
  bool shouldRepaint(LevelPathPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    path = Path();
    path!.moveTo(0, 0);
    path!.lineTo(345.w, 0);

    path!.lineTo(345.w, 328.5.w);
    path!.lineTo(0.w, 328.5.w);
    path!.lineTo(0, 0);
    path!.arcToPoint(Offset(345.w, 0),
        radius: Radius.circular(1200.w), clockwise: false);
    canvas.drawPath(
        path!,
        Paint()
          // ..color = Colors.white
          ..color = const Color(0xCC141519)
          ..style = PaintingStyle.fill);
  }

  @override
  bool hitTest(Offset position) => path!.contains(position);
}
