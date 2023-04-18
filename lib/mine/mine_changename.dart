import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MineChangeNameBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineChangeNameController>(MineChangeNameController());
  }
}

class MineChangeNameController extends GetxController {
  TextEditingController nickCtrl = TextEditingController();

  final _haveClean = false.obs;
  bool get haveClean => _haveClean.value;
  set haveClean(v) => _haveClean.value = v;

  final _btnEnable = true.obs;
  bool get btnEnable => _btnEnable.value;
  set btnEnable(v) => _btnEnable.value = v;

  Map homeData = {};
  @override
  void onInit() {
    dataFormat();
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    nickCtrl.addListener(textListen);
    nickCtrl.text = homeData["nickName"] ?? "";
    super.onInit();
  }

  getHomeDataNotify(arg) {
    dataFormat();
  }

  changeNameAciton() {
    if (nickCtrl.text.length < 2 || nickCtrl.text.length > 16) {
      ShowToast.normal("长度必须为2到16个字符");
      return;
    }
    // if (nickCtrl.text.length > 16) {
    //   ShowToast.normal("昵称大于16位");
    //   return;
    // }
    btnEnable = false;

    simpleRequest(
      url: Urls.userProfileEdit,
      params: {"u_Type": 1, "strConut": nickCtrl.text},
      success: (success, json) {
        if (success) {
          ShowToast.normal("设置成功");
          Get.find<HomeController>().refreshHomeData();
          Future.delayed(const Duration(milliseconds: 1000), () {
            popToUntil();
          });
        }
      },
      after: () {
        btnEnable = true;
      },
    );
  }

  textListen() {
    haveClean = nickCtrl.text.isNotEmpty;
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    nickCtrl.removeListener(textListen);
    nickCtrl.dispose();
    super.onClose();
  }

  dataFormat() {
    homeData = AppDefault().homeData;
    update();
  }
}

class MineChangeName extends GetView<MineChangeNameController> {
  const MineChangeName({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        takeBackKeyboard(context);
      },
      child: Scaffold(
        appBar: getDefaultAppBar(context, "修改昵称"),
        body: SingleChildScrollView(
          child: Column(
            children: [
              gwb(375),
              ghb(20),
              Container(
                width: 345.w,
                height: 113.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.w),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 4.w),
                          color: const Color(0x19C8C8C8),
                          blurRadius: 8.w)
                    ]),
                child: Column(
                  children: [
                    ghb(20),
                    sbRow([getSimpleText("昵称", 18, AppColor.textBlack4)],
                        width: 345 - 20 * 2),
                    ghb(8),
                    sbRow([
                      CustomInput(
                        width: 240.w,
                        heigth: 40.w,
                        textEditCtrl: controller.nickCtrl,
                        style: TextStyle(
                            color: AppColor.textBlack4, fontSize: 15.sp),
                        placeholderStyle: TextStyle(
                            color: const Color(0xFF919599), fontSize: 15.sp),
                        placeholder: "填写昵称，不超过16位",
                        cursorHeight: 18.w,
                      ),
                      GetX<MineChangeNameController>(
                        builder: (_) {
                          return controller.haveClean
                              ? CustomButton(
                                  onPressed: () {
                                    controller.nickCtrl.clear();
                                  },
                                  child: SizedBox(
                                    width: 50.w,
                                    height: 40.w,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Image.asset(
                                        assetsName("login/input_clean"),
                                        width: 16.w,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                )
                              : gwb(0);
                        },
                      )
                    ], width: 300),
                    gline(300, 1)
                  ],
                ),
              ),
              ghb(60),
              GetX<MineChangeNameController>(
                builder: (_) {
                  return getLoginBtn("完成", () {
                    takeBackKeyboard(context);
                    controller.changeNameAciton();
                  }, enable: controller.btnEnable);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
