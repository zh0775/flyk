import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_success.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IdentityAuthenticationUploadCompleteBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IdentityAuthenticationUploadCompleteController>(
        IdentityAuthenticationUploadCompleteController());
  }
}

class IdentityAuthenticationUploadCompleteController extends GetxController {
  Map cardData = {};
  Map emblemData = {};
  String headImgUrl = "";
  String emblemImgUrl = "";
  bool isFirst = true;

  final _submitEnable = true.obs;
  get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  dataInit(Map cData, String hUrl, String eUrl, Map eData) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    cardData = cData;
    emblemData = eData;
    headImgUrl = hUrl;
    emblemImgUrl = eUrl;
  }

  userVerifiedAction({required Function(bool, dynamic) success}) {
    submitEnable = false;
    simpleRequest(
      url: Urls.userVerifiedStep2,
      params: {
        "timelimit": emblemData["timelimit"],
        "authority": emblemData["authority"],
        "idCardPhoto1": headImgUrl,
        "idCardPhoto2": emblemImgUrl,
        "sex": cardData["sex"],
        "idName": cardData["name"],
        "idCard": cardData["number"],
      },
      success: success,
      after: () {
        submitEnable = true;
      },
    );
  }

  bool authAlipay = false;

  @override
  void onInit() {
    getUserData().then((value) {
      if (value["homeData"] != null &&
          value["homeData"]["authentication"] != null &&
          value["homeData"]["authentication"]["isAliPay"] != null) {
        authAlipay = value["homeData"]["authentication"]["isAliPay"];
      }
    });
    super.onInit();
  }
}

class IdentityAuthenticationUploadComplete
    extends GetView<IdentityAuthenticationUploadCompleteController> {
  final Map cardData;
  final String headImgUrl;
  final String emblemImgUrl;
  final Map emblemData;
  const IdentityAuthenticationUploadComplete(
      {Key? key,
      required this.cardData,
      required this.headImgUrl,
      required this.emblemImgUrl,
      required this.emblemData})
      : super(key: key);
// {number: null, address: null, year: null, month: null, day: null, nation: null, sex: null, name: null, authority: 武汉市公安局江岸分局, timelimit: 20130911-20330911}
  @override
  Widget build(BuildContext context) {
    controller.dataInit(cardData, headImgUrl, emblemImgUrl, emblemData);
    return Scaffold(
      appBar:
          getDefaultAppBar(context, "实名认证", blueBackground: true, white: true),
      body: Builder(builder: (ctx) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: ScreenUtil().screenHeight -
                    Scaffold.of(ctx).appBarMaxHeight! -
                    80.w +
                    paddingSizeBottom(context),
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        gwb(375),
                        ghb(12),
                        sbRow([
                          getSimpleText("请确认个人信息", 16, AppColor.textDeepBlue,
                              isBold: true),
                        ], width: 375 - 16 * 2),
                        ghb(3),
                        sbRow([
                          getSimpleText(
                              "请确定身份证信息是否正确", 12, const Color(0xFF246EDE)),
                        ], width: 375 - 16 * 2),
                        ghb(12),
                        Container(
                          width: 345.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.w),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0x26333333),
                                    offset: Offset(0, 5.w),
                                    blurRadius: 15.w)
                              ]),
                          child: Column(
                            children: [
                              ghb(16),
                              // sbRow([
                              //   centClm([
                              //     getSimpleText("正面", 14, AppColor.textBlack),
                              //     ghb(15),
                              //     CustomButton(
                              //       onPressed: () {
                              //         toCheckImg(
                              //             image:
                              //                 "${AppDefault().imageUrl}$headImgUrl");
                              //       },
                              //       child: CustomNetworkImage(
                              //         src:
                              //             "${AppDefault().imageUrl}$headImgUrl",
                              //         width: 164.w,
                              //         height: 100.w,
                              //         fit: BoxFit.cover,
                              //       ),
                              //     )
                              //   ]),
                              //   centClm([
                              //     getSimpleText("反面", 14, AppColor.textBlack),
                              //     ghb(15),
                              //     CustomButton(
                              //       onPressed: () {
                              //         toCheckImg(
                              //             image:
                              //                 "${AppDefault().imageUrl}$emblemImgUrl");
                              //       },
                              //       child: CustomNetworkImage(
                              //         src:
                              //             "${AppDefault().imageUrl}$emblemImgUrl",
                              //         width: 164.w,
                              //         height: 100.w,
                              //         fit: BoxFit.cover,
                              //       ),
                              //     )
                              //   ]),
                              // ], width: 375 - 16 * 2),
                              // ghb(20),
                              sbRow([
                                getSimpleText("身份信息", 17, AppColor.textBlack,
                                    isBold: true)
                              ], width: 345 - 16 * 2),
                              ghb(19),
                              sbRow(
                                [
                                  // SizedBox(
                                  //   width: 104.w,
                                  //   child: getSimpleText(
                                  //       "姓名", 16, AppColor.textBlack),
                                  // ),
                                  getSimpleText("姓名", 16, AppColor.textDeepBlue,
                                      fw: FontWeight.w500),
                                  getSimpleText(
                                      cardData != null &&
                                              cardData["name"] != null
                                          ? cardData["name"]
                                          : "",
                                      16,
                                      const Color(0xFFBCC1CF),
                                      fw: FontWeight.w500),
                                  // SizedBox(
                                  //   width: (345 - 104).w,
                                  //   child: getSimpleText(
                                  //       cardData != null &&
                                  //               cardData["name"] != null
                                  //           ? cardData["name"]
                                  //           : "",
                                  //       16,
                                  //       AppColor.textGrey),
                                  // ),
                                ],
                                width: 345 - 16 * 2,
                              ),
                              ghb(15),
                              gline(311, 1, color: const Color(0xFFF7F7F7)),
                              ghb(15),
                              sbRow(
                                [
                                  getSimpleText(
                                      "身份证号", 16, AppColor.textDeepBlue,
                                      fw: FontWeight.w500),
                                  getSimpleText(
                                      cardData != null &&
                                              cardData["number"] != null
                                          ? cardData["number"]
                                          : "",
                                      16,
                                      const Color(0xFFBCC1CF),
                                      fw: FontWeight.w500)
                                ],
                                width: 345 - 16 * 2,
                              ),
                              ghb(18),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
              GetX<IdentityAuthenticationUploadCompleteController>(
                init: controller,
                builder: (_) {
                  return getSubmitBtn("提交", () {
                    controller.userVerifiedAction(
                      success: (success, json) {
                        if (success) {
                          ShowToast.normal("身份认证成功！");
                          Get.find<HomeController>().homeOnRefresh();
                          Future.delayed(const Duration(seconds: 1), () {
                            Get.to(
                                IdentityAuthenticationSuccess(
                                  alipayNoAuth: !controller.authAlipay,
                                  title: "提交成功",
                                  subTitle: "您的身份证信息已提交成功，平台已审批通过",
                                ),
                                binding:
                                    IdentityAuthenticationSuccessBinding());
                          });
                        }
                      },
                    );
                  }, enable: controller.submitEnable);
                },
              )
              // Container(
              //   width: 375.w,
              //   height: 80.w + paddingSizeBottom(context) + 45.w,
              //   color: Colors.white,
              //   padding:
              //       EdgeInsets.only(bottom: paddingSizeBottom(context) + 45.w),
              //   child: Center(
              //       child: GetX<IdentityAuthenticationUploadCompleteController>(
              //     init: controller,
              //     builder: (_) {
              //       return getSubmitBtn("提交", () {
              //         controller.userVerifiedAction(
              //           success: (success, json) {
              //             if (success) {
              //               ShowToast.normal("身份认证成功！");
              //               HomeController? homeController =
              //                   Get.find<HomeController>();
              //               if (homeController != null) {
              //                 homeController.homeOnRefresh();
              //               }

              //               Future.delayed(const Duration(seconds: 1), () {
              //                 Get.to(
              //                     IdentityAuthenticationSuccess(
              //                       alipayNoAuth: !controller.authAlipay,
              //                       title: "提交成功",
              //                       subTitle: "您的身份证信息已提交成功，平台已审批通过",
              //                     ),
              //                     binding:
              //                         IdentityAuthenticationSuccessBinding());
              //               });
              //             }
              //           },
              //         );
              //       }, enable: controller.submitEnable);
              //     },
              //   )),
              // )
            ],
          ),
        );
      }),
    );
  }
}
