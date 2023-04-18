import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ApplyCreditCardBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ApplyCreditCardController>(ApplyCreditCardController());
  }
}

class ApplyCreditCardController extends GetxController {
  final personNameInputCtrl = TextEditingController();
  final personNoInputCtrl = TextEditingController();
  // final personCardIndateInputCtrl = TextEditingController();

  GlobalKey datePickButtonKey = GlobalKey();
  GlobalKey scrollContentKey = GlobalKey();
  ScrollController scrollCtrl = ScrollController();

  final _showPick = false.obs;
  bool get showPick => _showPick.value;
  set showPick(v) => _showPick.value = v;
  final _endTime = "".obs;
  String get endTime => _endTime.value;
  set endTime(v) => _endTime.value = v;

  DateFormat dateFormat = DateFormat("yyyy年MM月dd日");

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void dispose() {
    personNameInputCtrl.dispose();
    personNoInputCtrl.dispose();
    // personCardIndateInputCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }
}

class ApplyCreditCard extends GetView<ApplyCreditCardController> {
  const ApplyCreditCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
          appBar: getDefaultAppBar(context, "申请办卡"),
          body: Stack(
            children: [
              Positioned.fill(child: Container()),
              Positioned.fill(
                  child: getInputSubmitBody(context, "立即申请",
                      build: (boxHeight, context) {
                return SizedBox(
                  height: boxHeight,
                  width: 375.w,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller.scrollCtrl,
                    key: controller.scrollContentKey,
                    child: Column(
                      children: [
                        GetX<ApplyCreditCardController>(
                          init: controller,
                          initState: (_) {},
                          builder: (_) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: controller.showPick ? 0 : 120.w,
                            );
                          },
                        ),
                        Container(
                          width: 345.w,
                          decoration: getDefaultWhiteDec(),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 64.5.w,
                                child: Center(
                                  child: getSimpleText(
                                      "填写身份证信息", 17, AppColor.textBlack,
                                      isBold: true),
                                ),
                              ),
                              input(0),
                              input(1),
                              // input(2),
                              CustomButton(
                                key: controller.datePickButtonKey,
                                onPressed: () {
                                  showDatePick(isStart: false);
                                },
                                child: Container(
                                  width: 295.w,
                                  height: 51.w,
                                  margin: EdgeInsets.only(top: 9.w),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(5.w)),
                                  child: Center(
                                      child: GetX<ApplyCreditCardController>(
                                    builder: (_) {
                                      return getSimpleText(
                                          controller.endTime.isNotEmpty
                                              ? controller.endTime
                                              : "输入身份证背面有效时间",
                                          15,
                                          controller.endTime.isNotEmpty
                                              ? AppColor.textBlack
                                              : AppColor.textGrey);
                                    },
                                  )),
                                ),
                              ),
                              ghb(33.5)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, contentColor: Colors.transparent))
            ],
          )),
    );
  }

  Widget input(int index) {
    return Container(
      width: 295.w,
      height: 51.w,
      margin: EdgeInsets.only(top: index != 0 ? 9.w : 0),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(5.w)),
      child: Center(
        child: CustomInput(
            width: 280.w,
            heigth: 51.w,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.sp, color: AppColor.textBlack),
            placeholderStyle:
                TextStyle(fontSize: 15.sp, color: AppColor.textGrey),
            textEditCtrl: index == 0
                ? controller.personNameInputCtrl
                : controller.personNoInputCtrl,
            placeholder: index == 0
                ? "输入身份证姓名"
                : index == 1
                    ? "输入身份证号码"
                    : "输入身份证背面有效时间"),
      ),
    );
  }

  showDatePick({required bool isStart}) {
    // final boxRender = controller.datePickButtonKey.currentContext!
    //     .findRenderObject() as RenderBox;

    // final ancestorBox =
    //     controller.scrollContentKey.currentContext!.findRenderObject();
    // final position =
    //     boxRender.localToGlobal(Offset.zero, ancestor: ancestorBox);
    // controller.scrollCtrl.createScrollPosition(physics, context, oldPosition)
    // controller.scrollCtrl.jumpTo(position.dy);
    // controller.scrollCtrl.animateTo(position.dy,
    //     duration: const Duration(milliseconds: 200), curve: Curves.linear);

    controller.showPick = true;
    Get.bottomSheet(
            SizedBox(
              width: 375.w,
              height: (56.5 + 265).w,
              child: Column(
                children: [
                  sbRow([
                    gwb(0),
                    CustomButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Image.asset(
                        assetsName(
                          "common/btn_model_close",
                        ),
                        width: 37.w,
                        height: 56.5.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ], width: 375 - 24 * 2),
                  Container(
                    color: Colors.white,
                    width: 375.w,
                    height: 265.w,
                    child: CupertinoDatePicker(
                      initialDateTime: DateTime.now(),
                      mode: CupertinoDatePickerMode.date,
                      dateOrder: DatePickerDateOrder.ymd,
                      onDateTimeChanged: (value) {
                        controller.endTime =
                            controller.dateFormat.format(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            isScrollControlled: true)
        .then((value) {
      // controller.endTime = controller.dateFormat.format(value);
      // controller.currentDateIndex = -1;
      // controller.loadHistory();
      controller.showPick = false;
    });
  }
}
