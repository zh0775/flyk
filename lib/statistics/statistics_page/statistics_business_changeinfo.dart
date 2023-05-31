import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatisticsBusinessChangeInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsBusinessChangeInfoController>(
        StatisticsBusinessChangeInfoController(datas: Get.arguments));
  }
}

class StatisticsBusinessChangeInfoController extends GetxController {
  final dynamic datas;
  StatisticsBusinessChangeInfoController({this.datas});

  final nameInputCtrl = TextEditingController();
  final phoneInputCtrl = TextEditingController();

  Map businessData = {};

  final _submitEnable = true.obs;
  bool get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  loadEdit() {
    if (nameInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入商户名称");
      return;
    }
    if (phoneInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入商户手机号");
      return;
    }

    submitEnable = false;
    simpleRequest(
        url: Urls.userMerchantEdit,
        params: {
          "id": businessData["tId"],
          "contact_Recipient": nameInputCtrl.text,
          "contact_Mobile": phoneInputCtrl.text
        },
        success: (success, json) {},
        after: () {
          submitEnable = true;
        });
  }

  @override
  void onInit() {
    businessData = (datas ?? {})["data"] ?? {};
    nameInputCtrl.text = businessData["merchantName"] ?? "";
    phoneInputCtrl.text = businessData["merchantPhone"] ?? "";
    super.onInit();
  }

  @override
  void onClose() {
    nameInputCtrl.dispose();
    phoneInputCtrl.dispose();
    super.onClose();
  }
}

class StatisticsBusinessChangeInfo
    extends GetView<StatisticsBusinessChangeInfoController> {
  /// 商户-修改商户信息
  ///
  /// 参数
  ///
  /// data 必传  商户信息
  const StatisticsBusinessChangeInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => takeBackKeyboard(context),
        child: Scaffold(
            appBar: getDefaultAppBar(context, "修改基本信息"),
            body: Stack(children: [
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60.w + paddingSizeBottom(context),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: GetX<StatisticsBusinessChangeInfoController>(
                          builder: (_) {
                        return getSubmitBtn("确认保存", () {
                          takeBackKeyboard(context);
                          controller.loadEdit();
                        },
                            textColor: Colors.white,
                            linearGradient: const LinearGradient(
                                colors: [Color(0xFFFD573B), Color(0xFFFF3A3A)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                            enable: controller.submitEnable);
                      }))),
              Positioned.fill(
                  bottom: 60.w + paddingSizeBottom(context),
                  child: Column(
                      children: List.generate(
                          2,
                          (index) => Container(
                              width: 375.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                      top: BorderSide(
                                          width: 0.5.w,
                                          color: AppColor.lineColor))),
                              child: sbRow([
                                getWidthText(index == 0 ? "备注姓名" : "手机号", 15,
                                    AppColor.textBlack, 90, 1,
                                    textHeight: 1.3),
                                CustomInput(
                                  width: 345.w - 90.w,
                                  heigth: 50.w,
                                  textEditCtrl: index == 0
                                      ? controller.nameInputCtrl
                                      : controller.phoneInputCtrl,
                                  placeholder:
                                      index == 0 ? "请输入备注姓名" : "请输入手机号",
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      color: AppColor.textBlack,
                                      height: 1.3),
                                  placeholderStyle: TextStyle(
                                      fontSize: 15.sp,
                                      color: AppColor.assisText,
                                      height: 1.3),
                                  keyboardType: index == 0
                                      ? TextInputType.text
                                      : TextInputType.phone,
                                )
                              ], width: 345)))))
            ])));
  }
}
