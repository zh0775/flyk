import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class TerminalReceiveDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TerminalReceiveDetailController>(TerminalReceiveDetailController());
  }
}

class TerminalReceiveDetailController extends GetxController {
  final _imgIndex = 0.obs;
  int get imgIndex => _imgIndex.value;
  set imgIndex(v) => _imgIndex.value = v;

  List imgList = [
    "",
    "",
    "",
    "",
  ];
}

class TerminalReceiveDetail extends GetView<TerminalReceiveDetailController> {
  const TerminalReceiveDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          getDefaultAppBar(context, "商品详情", blueBackground: true, white: true),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: paddingSizeBottom(context) + 80.w,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                        width: 375.w,
                        height: 280.w,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: PageView.builder(
                                itemCount: controller.imgList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: Colors.amber,
                                  );
                                },
                                onPageChanged: (value) {
                                  controller.imgIndex = value;
                                },
                              ),
                            ),
                            Positioned(
                                bottom: 8.w,
                                left: 0,
                                right: 0,
                                child: centRow(List.generate(
                                    controller.imgList.length, (index) {
                                  return GetX<TerminalReceiveDetailController>(
                                    builder: (_) {
                                      return AnimatedContainer(
                                        margin: EdgeInsets.only(
                                            right: index !=
                                                    controller.imgList.length -
                                                        1
                                                ? 3.w
                                                : 0),
                                        duration:
                                            const Duration(milliseconds: 300),
                                        width: controller.imgIndex == index
                                            ? 20.w
                                            : 8.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.w),
                                          color: controller.imgIndex == index
                                              ? Colors.white54
                                              : Colors.white24,
                                        ),
                                      );
                                    },
                                  );
                                })))
                          ],
                        )),
                    ghb(15),
                    Container(
                      width: 345.w,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.w)),
                      child: Column(
                        children: [
                          ghb(10),
                          SizedBox(
                            width: 315.w,
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text: "金小宝新一代全能型现代电子支付最新版电签POS机",
                                    style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: AppDefault.fontBold,
                                        color: Colors.black)),
                                WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Container(
                                      width: 70.w,
                                      height: 24.w,
                                      margin: EdgeInsets.only(left: 10.w),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.w, color: Colors.amber),
                                          borderRadius:
                                              BorderRadius.circular(12.w)),
                                      child: Center(
                                        child: getSimpleText(
                                            "会员专享", 13, Colors.amber),
                                      ),
                                    ))
                              ]),
                            ),
                          ),
                          ghb(5),
                          sbRow([
                            getSimpleText(
                                "立刷POS机电签版（0.6%+3服务费）", 12, AppColor.textGrey),
                          ], width: 345 - 15 * 2),
                          ghb(10),
                          sbRow([
                            getRichText(
                                "￥", "269", 10, Colors.red, 16, Colors.red,
                                fw2: AppDefault.fontBold),
                            getSimpleText("总销量 1106", 12, AppColor.textGrey)
                          ], width: 345 - 15 * 2),
                          ghb(15)
                        ],
                      ),
                    ),
                    ghb(15),
                    Container(
                      width: 345.w,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.w)),
                      child: Column(
                        children: [
                          sbhRow([
                            centRow([
                              getSimpleText("已选", 14, Colors.black),
                              gwb(20),
                              getSimpleText("经典蓝", 14, AppColor.textGrey),
                            ])
                          ], width: 345 - 15 * 2, height: 50),
                          sbhRow([
                            centRow([
                              getSimpleText("运费", 14, Colors.black),
                              gwb(20),
                              getSimpleText("在线支付免运费", 14, AppColor.textGrey),
                            ])
                          ], width: 345 - 15 * 2, height: 50)
                        ],
                      ),
                    ),
                    ghb(15),
                    Container(
                      width: 345.w,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.w)),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50.w,
                            child: Center(
                              child: getSimpleText(
                                  "-  图文详情  -", 14, AppColor.textGrey),
                            ),
                          ),
                          HtmlWidget("")
                        ],
                      ),
                    ),
                    ghb(20)
                  ],
                ),
              )),
          Positioned(
              bottom: 0,
              height: paddingSizeBottom(context) + 80.w,
              left: 0,
              right: 0,
              child: Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, -2.w),
                        blurRadius: 5.w)
                  ]),
                  child: Column(
                    children: [
                      ghb(15),
                      sbRow([
                        Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: getRichText(
                              "￥", "269", 12, Colors.red, 18, Colors.red,
                              fw2: AppDefault.fontBold),
                        ),
                        CustomButton(
                          onPressed: () {
                            showSelectModel(context);
                          },
                          child: Container(
                            width: 120.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                                color: AppDefault().getThemeColor() ??
                                    AppColor.theme,
                                borderRadius: BorderRadius.circular(20.w)),
                            child: Center(
                              child: getSimpleText("立即采购", 14, Colors.white),
                            ),
                          ),
                        )
                      ], width: 375 - 15 * 2),
                    ],
                  )))
        ],
      ),
    );
  }

  showSelectModel(BuildContext context) {
    Get.bottomSheet(
        Container(
            width: 375.w,
            height: 500.w + paddingSizeBottom(context),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(15.w))),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      ghb(15),
                      sbhRow([
                        centRow([
                          Image.asset(
                            assetsName("home/jifen_04"),
                            width: 80.w,
                            height: 80.w,
                            fit: BoxFit.cover,
                          ),
                          gwb(20),
                          SizedBox(
                            height: 80.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                getWidthText("金小宝新一代全能型现代电子支付最新版电签POS机", 18,
                                    Colors.black, 345 - 80 - 20 - 30, 3,
                                    isBold: true),
                              ],
                            ),
                          )
                        ])
                      ], width: 375 - 15 * 2, height: 100),
                    ],
                  ),
                ),
                Positioned(
                    top: 20.w,
                    right: 20.w,
                    child: CustomButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: SizedBox(
                        width: 50.w,
                        height: 50.w,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Image.asset(
                            assetsName("common/btn_model_close2"),
                            width: 15.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ))
              ],
            )),
        isScrollControlled: true);
  }
}
