import 'package:cxhighversion2/business/finance/finance_space_home.dart';
import 'package:cxhighversion2/business/finance/finance_space_mine.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FinanceSpaceBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<FinanceSpaceController>(
        FinanceSpaceController(datas: Get.arguments));
  }
}

class FinanceSpaceController extends GetxController {
  final dynamic datas;
  FinanceSpaceController({this.datas});

  final _pageIdx = 0.obs;
  set pageIdx(v) => _pageIdx.value = v;
  int get pageIdx => _pageIdx.value;
}

class FinanceSpace extends GetView<FinanceSpaceController> {
  const FinanceSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetX<FinanceSpaceController>(
          builder: (_) {
            return IndexedStack(
              index: controller.pageIdx,
              children: const [
                FinanceSpaceHome(),
                FinanceSpaceMine(),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          height: 60.w + paddingSizeBottom(context),
          width: 375.w,
          decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
                    width: 0.5.w, color: AppColor.pageBackgroundColor)),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
            child: GetX<FinanceSpaceController>(
              initState: (_) {},
              builder: (_) {
                return Row(
                  children: List.generate(2, (index) => getTab(index)),
                );
              },
            ),
          ),
        ));
  }

  Widget getTab(int index) {
    String title = "";
    String img = "";

    switch (index) {
      case 0:
        title = "首页";
        img = "tab_home_";
        break;
      case 1:
        title = "我的";
        img = "tab_mine_";
        break;
    }

    return CustomButton(
        onPressed: () {
          controller.pageIdx = index;
        },
        child: SizedBox(
          width: 375.w / 2,
          height: 60.w,
          child: Padding(
            padding: EdgeInsets.only(bottom: 3.w),
            child: Center(
              child: Column(
                children: [
                  ghb(3.5),
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        AppDefault().getThemeColor() == null
                            ? Colors.white
                            : controller.pageIdx == index
                                ? AppDefault().getThemeColor()!
                                : Colors.white,
                        BlendMode.modulate),
                    child: Image.asset(
                      assetsName(
                          "business/finance/$img${(controller.pageIdx == index && AppDefault().getThemeColor() == null ? "selected" : "normal")}"),
                      height: 30.w,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  ghb(2),
                  getSimpleText(
                      title,
                      10,
                      controller.pageIdx == index
                          ? (AppDefault().getThemeColor() ?? AppColor.theme)
                          : AppColor.textGrey,
                      textHeight: 1.0)
                ],
              ),
            ),
          ),
        ));
  }
}
