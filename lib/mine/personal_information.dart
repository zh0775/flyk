import 'package:cxhighversion2/component/app_crop_image_page.dart';
import 'package:cxhighversion2/component/app_image_picker.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/mine_changename.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'identityAuthentication/identity_authentication_check.dart';
import 'identityAuthentication/identity_authentication_upload.dart';

class PersonalInformationBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<PersonalInformationController>(PersonalInformationController());
  }
}

class PersonalInformationController extends GetxController {
  bool isFirst = true;
  final _imageUrl = "".obs;
  String get imageUrl => _imageUrl.value;
  set imageUrl(v) => _imageUrl.value = v;

  final _homeData = Rx<Map>({});
  Map get homeData => _homeData.value;
  set homeData(v) => _homeData.value = v;

  final _userNameIsEdit = false.obs;
  bool get userNameIsEdit => _userNameIsEdit.value;
  set userNameIsEdit(v) => _userNameIsEdit.value = v;

  final userNameInputCtrl = TextEditingController();
  final userNameNode = FocusNode();

  String uploadImageUrl = "";

  Uint8List? uploadImageFile;
  String uploadImageFileBuildId = "PersonalInformation_uploadImageFileBuildId";

  Map publicHomeData = {};

  // Rx<XFile>? _uploadImageFile;
  // XFile? get uploadImageFile {
  //   if (_uploadImageFile == null) {
  //     return null;
  //   } else {
  //     _uploadImageFile!.value;
  //   }
  // }

  // set uploadImageFile(XFile? v) {
  //   if (_uploadImageFile == null) {
  //     _uploadImageFile = Rx<XFile>(v!);
  //   } else {
  //     _uploadImageFile!.value = v!;
  //   }
  // }

  AppImagePicker? imagePicker;

  dataInit() {
    if (!isFirst) {
      return;
    }
    isFirst = false;
  }

  refreshHomeData(bool isUserName) {
    if (isUserName) {
      if (userNameInputCtrl.text.isNotEmpty &&
          homeData["nickName"] != userNameInputCtrl.text) {
        Get.find<HomeController>().homeOnRefresh();
      }
    } else {
      Get.find<HomeController>().homeOnRefresh();
    }
  }

  changeUserInfo(bool isUserName) {
    //1昵称2头像
    simpleRequest(
      url: Urls.userProfileEdit,
      params: {
        "u_Type": isUserName ? 1 : 2,
        "strConut": isUserName ? userNameInputCtrl.text : uploadImageUrl
      },
      success: (success, json) {
        if (success) {
          refreshHomeData(isUserName);
        }
      },
      after: () {},
    );
  }

  upLoadImg(imgFile) {
    Http().uploadImages(
      [imgFile],
      success: (json) {
        uploadImageUrl = json["data"]["src"];
        changeUserInfo(false);
      },
      fail: (reason, code, json) {},
      after: () {},
    );
  }

  String rzText = "";
  bool isAuth = false;
  Map authentication = {};

  getInfo() {
    AppDefault appDefault = AppDefault();
    // if (appDefault.loginStatus) {

    // } else {
    //   popToLogin();
    // }
    imageUrl = appDefault.imageUrl;
    homeData = appDefault.homeData;
    publicHomeData = appDefault.publicHomeData;
    authentication = homeData["authentication"] ?? {};
    isAuth = authentication["isCertified"] ?? false;

    Map drawInfo = publicHomeData["drawInfo"] ?? {};
    List payTypes = drawInfo["draw_Account_PayType"] ?? [];
    bool openAlipay = false;
    bool openBankCard = false;
    bool authAlipay = false;
    bool authCard = false;
    // for (var e in payTypes) {
    //   if (e["id"] == 2) {
    //     openAlipay = true;
    //   } else if (e["id"] == 1) {
    //     openBankCard = true;
    //   }
    // }

    // authAlipay = authentication["isAliPay"] ?? false;
    // authCard = authentication["isCertified"] ?? false;
    rzText = (authentication["isCertified"] ?? false) ? "已认证" : "未认证";

    userNameInputCtrl.text =
        homeData.isNotEmpty ? (homeData["nickName"] ?? "") : "";

    // if (openAlipay && !authAlipay) {
    //   rzText = "支付宝未认证";
    // } else if (openBankCard && !authCard) {
    //   rzText = "银行卡未认证";
    // } else {
    //   rzText = "已认证";
    // }
    update();
    update([uploadImageFileBuildId]);
  }

  @override
  void onInit() {
    imagePicker = AppImagePicker(
      imgCallback: (imgFile) {
        Get.to(
            AppCropImagePage(
              image: imgFile,
              cropResult: (img) {
                // var tempDir = await getTemporaryDirectory();
                // var file = await File(
                //         '${tempDir.path}/image_${DateTime.now().millisecond}.jpg')
                //     .create();
                // file.writeAsBytesSync(img);
                // uploadImageFile =  XFile(file.path);
                uploadImageFile = img;
                upLoadImg(uploadImageFile!);
                update([uploadImageFileBuildId]);
              },
            ),
            transition: Transition.noTransition);
      },
    );
    getInfo();
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeNotify);
    super.onInit();
  }

  getHomeNotify(arg) {
    getInfo();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeNotify);
    userNameInputCtrl.dispose();
    userNameNode.dispose();
    super.onClose();
  }
}

class PersonalInformation extends GetView<PersonalInformationController> {
  const PersonalInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit();
    return GestureDetector(
      onTap: () {
        takeBackKeyboard(context);
        if (controller.userNameIsEdit) {
          controller.userNameIsEdit = false;
          controller.userNameInputCtrl.text =
              controller.homeData["nickName"] ?? "";
        }
      },
      child: Scaffold(
        appBar: getDefaultAppBar(context, "编辑资料", color: Colors.white),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ghb(1),
              infoSection("修改头像"),
              ghb(15),

              infoSection("用户昵称"),
              // GetBuilder<PersonalInformationController>(
              //   builder: (_) {
              //     return infoSection("提现认证", t2: controller.rzText);
              //   },
              // ),
              infoSection("手机号",
                  t2: hidePhoneNum(controller.homeData["u_Mobile"] ?? "")),
              infoSection("ID号", t2: controller.homeData["u_Number"] ?? ""),
              infoSection("注册时间",
                  t2: controller.homeData["u_Pass_Date"] != null &&
                          controller.homeData["u_Pass_Date"].isNotEmpty
                      ? DateFormat("yyyy-MM-dd").format(
                          DateFormat("yyyy/MM/DD HH:ss:ss")
                              .parse(controller.homeData["u_Pass_Date"]))
                      : ""),

              GetBuilder<PersonalInformationController>(builder: (_) {
                return controller.isAuth
                    ? centClm([
                        ghb(15),
                        Container(
                          width: 375.w,
                          height: 55.w,
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: sbRow([
                            getRichText("实名信息", "（已认证）", 16, AppColor.textBlack,
                                14, AppColor.textGrey,
                                isBold: true)
                          ], width: 375 - 31 * 2),
                        ),
                        infoSection("真实姓名",
                            t2: controller.authentication["u_Name"] ?? ""),
                        infoSection("身份证号",
                            t2: controller.authentication["u_IdCard"] ?? ""),
                      ])
                    : ghb(0);
              }),
              // Column(
              //   children: [
              //     // userHeadCell(context),

              //     gline(345, 1),
              //     GetX<PersonalInformationController>(
              //       builder: (_) {
              //         return infoCell(
              //             "我的名称",
              //             controller.homeData.isNotEmpty
              //                 ? (controller.homeData["nickName"] != null &&
              //                         controller.homeData["nickName"].isNotEmpty
              //                     ? controller.homeData["nickName"]
              //                     : "请设置昵称")
              //                 : "",
              //             context,
              //             isNickName: true);
              //       },
              //     ),
              //     gline(345, 1),
              //     GetX<PersonalInformationController>(
              //       builder: (_) {
              //         return infoCell(
              //           "注册时间",
              //           controller.homeData.isNotEmpty
              //               ? controller.homeData["u_Pass_Date"]
              //               : "",
              //           context,
              //           isNickName: false,
              //         );
              //       },
              //     ),
              //     gline(345, 1),
              //   ],
              // ),
              // GetX<PersonalInformationController>(
              //   builder: (_) {
              //     return controller.homeData.isNotEmpty
              //         ? section("用户信息", "登录账号", "用户ID号", "u_Mobile", "u_Number",
              //             context,
              //             isNickName: false)
              //         : const SizedBox();
              //   },
              // ),

              // section("实名信息", "真实姓名", "身份证号", "realname", "person_code"),
              // section("支付宝信息", "真实姓名", "支付宝账号", "alipay_name", "alipay_account"),
              // ghb(50),
            ],
          ),
        ),
      ),
    );
  }

  Widget section(String sectionName, String t1, String t2, String v1, String v2,
      BuildContext context,
      {required bool isNickName}) {
    return Container(
      margin: EdgeInsets.only(top: 10.w),
      width: 375.w,
      color: Colors.white,
      child: Column(
        children: [
          infoSection(sectionName),
          gline(345, 1),
          infoCell(t1, controller.homeData[v1], context,
              isNickName: isNickName),
          gline(345, 1),
          infoCell(t2, controller.homeData[v2], context,
              isNickName: isNickName),
        ],
      ),
    );
  }

  Widget userHeadCell(BuildContext context) {
    return CustomButton(
      onPressed: () {
        controller.imagePicker!.showImage(context);
      },
      child: sbhRow([
        getSimpleText("修改头像", 15, AppColor.textGrey2),
        Row(
          children: [
            GetBuilder<PersonalInformationController>(
              init: controller,
              id: controller.uploadImageFileBuildId,
              builder: (_) {
                return ClipRRect(
                    borderRadius: BorderRadius.circular(25.w),
                    child: controller.uploadImageFile != null
                        ? Image.memory(
                            controller.uploadImageFile!,
                            width: 50.w,
                            height: 50.w,
                            fit: BoxFit.fitWidth,
                          )
                        : GetX<PersonalInformationController>(
                            builder: (_) {
                              return controller.imageUrl.isNotEmpty
                                  ? CustomNetworkImage(
                                      src:
                                          "${controller.imageUrl}${controller.homeData["userAvatar"]}",
                                      width: 50.w,
                                      height: 50.w,
                                      fit: BoxFit.fill,
                                    )
                                  : const SizedBox();
                            },
                          ));
              },
            ),
            gwb(10),
            Image.asset(
              assetsName(
                "common/icon_cell_right_arrow",
              ),
              width: 20.w,
              height: 20.w,
              fit: BoxFit.fill,
            )
          ],
        )
      ], height: 80, width: 345),
    );
  }

  Widget infoCell(String t1, String t2, BuildContext context,
      {required bool isNickName}) {
    return sbhRow([
      getSimpleText(t1, 15, AppColor.textGrey2),
      isNickName
          ? GetX<PersonalInformationController>(
              init: controller,
              builder: (_) {
                double inputHeight = 35.w;
                return controller.userNameIsEdit
                    ? centRow([
                        Container(
                            height: inputHeight,
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: AppColor.lineColor),
                                borderRadius: BorderRadius.circular(5.w)),
                            child: centRow([
                              CustomInput(
                                width: 140.w,
                                heigth: inputHeight,
                                textEditCtrl: controller.userNameInputCtrl,
                                focusNode: controller.userNameNode,
                                placeholder: "请输入昵称",
                                onSubmitted: (p0) {
                                  controller.userNameIsEdit = false;
                                  controller.userNameInputCtrl.text =
                                      controller.homeData["nickName"];
                                },
                              ),
                            ])),
                        gwb(5),
                        CustomButton(
                          onPressed: () {
                            controller.userNameIsEdit = false;
                            if (controller.userNameInputCtrl.text ==
                                controller.homeData["nickName"]) {
                              return;
                            }
                            if (controller.userNameInputCtrl.text.isEmpty) {
                              ShowToast.normal("昵称不能为空");
                              controller.userNameInputCtrl.text =
                                  controller.homeData["nickName"];
                              return;
                            }

                            if (controller.userNameInputCtrl.text.length < 2) {
                              ShowToast.normal("昵称长度过短");
                              controller.userNameInputCtrl.text =
                                  controller.homeData["nickName"];
                              return;
                            }
                            controller.changeUserInfo(true);
                          },
                          child: Container(
                            width: 50.w,
                            height: inputHeight - 3.w,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF4282EB),
                                    Color(0xFF5BA3F7),
                                  ]),
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                            child: Center(
                                child: getSimpleText("保存", 14, Colors.white)),
                          ),
                        ),
                      ])
                    : CustomButton(
                        onPressed: () {
                          controller.userNameIsEdit = true;
                          Future.delayed(const Duration(milliseconds: 300), () {
                            FocusScope.of(context)
                                .requestFocus(controller.userNameNode);
                          });
                        },
                        child: getSimpleText(t2, 16, AppColor.textBlack,
                            isBold: true));
              },
            )
          : getSimpleText(t2, 16, AppColor.textBlack, isBold: true),
    ], height: 64.5, width: 345);
  }

  Widget infoSection(String t1, {String? t2, Widget? t2Widget}) {
    return CustomButton(
        onPressed: () {
          if (t1 == "用户昵称") {
            push(const MineChangeName(), null,
                binding: MineChangeNameBinding());
          } else if (t1 == "修改头像") {
            controller.imagePicker!
                .showImage(Global.navigatorKey.currentContext!);
          } else if (t1 == "提现认证") {
            if (controller.isAuth) {
              push(const IdentityAuthenticationCheck(isAlipay: false), null,
                  binding: IdentityAuthenticationCheckBinding());
            } else {
              push(const IdentityAuthenticationUpload(), null,
                  binding: IdentityAuthenticationUploadBinding());
            }
          }
        },
        child: Container(
          width: 375.w,
          height: 55.w,
          color: Colors.white,
          child: Center(
            child: sbhRow([
              getSimpleText(t1, 16, AppColor.textBlack),
              centRow([
                t1 != "修改头像"
                    ? gwb(0)
                    : GetBuilder<PersonalInformationController>(
                        id: controller.uploadImageFileBuildId,
                        builder: (_) {
                          return ClipRRect(
                              borderRadius: BorderRadius.circular(25.w),
                              child: controller.uploadImageFile != null
                                  ? Image.memory(
                                      controller.uploadImageFile!,
                                      width: 40.w,
                                      height: 40.w,
                                      fit: BoxFit.cover,
                                    )
                                  : GetX<PersonalInformationController>(
                                      builder: (_) {
                                        return controller.imageUrl.isNotEmpty
                                            ? CustomNetworkImage(
                                                src:
                                                    "${controller.imageUrl}${controller.homeData["userAvatar"]}",
                                                width: 40.w,
                                                height: 40.w,
                                                fit: BoxFit.cover,
                                              )
                                            : const SizedBox();
                                      },
                                    ));
                        },
                      ),
                t2 != null
                    ? CustomButton(
                        onPressed: () {
                          if (t1 == "ID号") {
                            copyClipboard(t2);
                          }
                        },
                        child: getSimpleText(t2, 16, AppColor.textGrey5),
                      )
                    : gwb(0),
                t1 == "用户昵称"
                    ? GetBuilder<PersonalInformationController>(
                        builder: (_) {
                          return getSimpleText(
                              controller.homeData["nickName"] ?? "请设置昵称",
                              16,
                              AppColor.textGrey5);
                        },
                      )
                    : gwb(0),
                t1 == "修改头像" || t1 == "用户昵称"
                    ? centRow([
                        gwb(7.5),
                        Image.asset(
                          assetsName("statistics/icon_arrow_right_gray"),
                          width: 18.w,
                          fit: BoxFit.fitWidth,
                        )
                      ])
                    : gwb(0),
                t2 == null ? t2Widget ?? ghb(0) : gwb(0),
              ])
            ], width: 375 - 30.5 * 2, height: 55),
          ),
        )

        // centClm([
        //   sbhRow([
        //     getSimpleText(t1, 16, AppColor.textBlack, isBold: true),
        //     type == 0
        //         ? Image.asset(
        //             assetsName("common/icon_cell_right_arrow"),
        //             width: 20.w,
        //             fit: BoxFit.fitWidth,
        //           )
        //         : type == 1
        //             ? getSimpleText(t2 ?? "", 14, AppColor.textGrey)
        //             : const SizedBox(),
        //   ], height: 70, width: 345 - 19.5 * 2),
        //   needLine ? gline(345, 0.5) : const SizedBox(),
        // ]),
        );
  }
}
