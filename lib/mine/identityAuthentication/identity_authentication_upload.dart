import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_check.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class IdentityAuthenticationUploadBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IdentityAuthenticationUploadController>(IdentityAuthenticationUploadController());
  }
}

class IdentityAuthenticationUploadController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  String headPhotoID = "headPhotoID";
  String emblemPhotoID = "emblemPhotoID";

  final nameInputCtrl = TextEditingController();
  final noInputCtrl = TextEditingController();

  XFile? headPhoto;
  XFile? emblemPhoto;

  String imgUrl = "";
  String headPhotoUrl = "";
  String emblemPhotoUrl = "";

  final _headPhotoPass = false.obs;
  bool get headPhotoPass => _headPhotoPass.value;
  set headPhotoPass(v) => _headPhotoPass.value = v;

  final _emblemPhotoPass = false.obs;
  bool get emblemPhotoPass => _emblemPhotoPass.value;
  set emblemPhotoPass(v) => _emblemPhotoPass.value = v;

  Map cardData = {};
  Map emblemData = {};

  String headErrorMsg = "";
  String emblemErrorMsg = "";

  final _isGetPhoto = false.obs;
  bool get isGetPhoto => _isGetPhoto.value;
  set isGetPhoto(v) => _isGetPhoto.value = v;

  final _submitEnable = true.obs;
  get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  authInputConfirm() {
    if (nameInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入身份证姓名");
      return;
    }
    if (nameInputCtrl.text.length < 2 || nameInputCtrl.text.length > 9) {
      ShowToast.normal("姓名长度为2-8位");
      return;
    }
    if (noInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入身份证号码");
      return;
    }
    if (noInputCtrl.text.length != 15 && noInputCtrl.text.length != 18) {
      ShowToast.normal("请输入正确位数的身份证号码");
      return;
    }
    submitEnable = false;
    simpleRequest(
      url: Urls.userVerified,
      params: {"idName": nameInputCtrl.text, "idCard": noInputCtrl.text},
      success: (success, json) {
        if (success) {
          Get.find<HomeController>().refreshHomeData();
          push(const AuthCompletePage(), Global.navigatorKey.currentContext!);
        }
      },
      after: () {
        submitEnable = true;
      },
    );
  }

  authConfirmAction(Function(bool succ)? result) {
    if (headPhoto == null) {
      ShowToast.normal("请上传头像面的身份证");
      return;
    }
    if (!headPhotoPass) {
      ShowToast.normal(headErrorMsg.isNotEmpty ? headErrorMsg : "您的身份证头像面还未认证成功，请等待上传结果或重新验证");
      return;
    }

    if (headPhoto == null) {
      ShowToast.normal("请上传身份证头像面的来进行认证");
      return;
    }
    if (!emblemPhotoPass) {
      ShowToast.normal(emblemErrorMsg.isNotEmpty ? emblemErrorMsg : "您的身份证国徽面还未认证成功，请等待上传结果或重新验证");
      return;
    }
    if (headPhoto == null) {
      ShowToast.normal("请上传身份证国徽面的来进行认证");
      return;
    }
    userVerifiedAction(
      success: (success, json) {
        if (success) {
          Get.find<HomeController>().refreshHomeData();
        }
        if (result != null) {
          result(success);
        }
      },
    );
  }

  userVerifiedAction({required Function(bool, dynamic) success}) {
    submitEnable = false;
    simpleRequest(
      url: Urls.userVerifiedStep2,
      params: {
        "timelimit": emblemData["timelimit"],
        "authority": emblemData["authority"],
        "idCardPhoto1": headPhotoUrl,
        "idCardPhoto2": emblemPhotoUrl,
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

  getPhoto(bool isGallery, bool isHead) async {
    // isGallery = true;
    if (kIsWeb) {
      pickAction(isHead: isHead, isGallery: isGallery);
    } else {
      PermissionStatus status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
        if (status.isPermanentlyDenied) {
          showAlert(
            Global.navigatorKey.currentContext!,
            "没有权限使用相机，请在设置中授予APP相机权限",
            confirmOnPressed: () {
              Get.back();
              AppSettings.openAppSettings();
            },
          );
        }
      }
      if (status.isGranted || await Permission.camera.request().isGranted) {
        pickAction(isHead: isHead, isGallery: isGallery);
      }
    }
  }

  Future<void> pickAction({required bool isHead, required bool isGallery}) async {
    isGetPhoto = true;
    XFile? image;
    if (!kIsWeb && isGallery) {
      List<AssetEntity>? images = await AssetPicker.pickAssets(
        Global.navigatorKey.currentContext!,
        pickerConfig: AssetPickerConfig(maxAssets: 1, specialPickerType: SpecialPickerType.noPreview, textDelegate: const AssetPickerTextDelegate(), requestType: RequestType.image),
      );
      if (images != null && images.isNotEmpty) {
        AssetEntity entity = images.first;
        File? file = await entity.file;

        if (file != null) {
          // if (result != null) {
          // image = XFile.fromData(result);
          File result = await FlutterNativeImage.compressImage(file.path, quality: 30);
          image = XFile(result.path);
          // }
        }
      }
    } else {
      image = await _picker.pickImage(
        imageQuality: 30,
        source: isGallery ? ImageSource.gallery : ImageSource.camera,
      );
    }
    isGetPhoto = false;
    if (image != null) {
      if (isHead) {
        headPhoto = image;
        // Navigator.push(
        //     Global.navigatorKey.currentContext!,
        //     GetPageRoute(
        //         page: () => IdentityPhotoFormat(img: headPhoto!),
        //         binding: IdentityPhotoFormatBinding(),
        //         transition: Transition.zoom));
        update([headPhotoID]);
      } else {
        emblemPhoto = image;
        update([emblemPhotoID]);
      }
      uploadHeadOrEmblemPhoto(isHead);
    }
  }

  uploadImgRequest(XFile file, Function(bool success, dynamic json)? success) {
    // authButtonState = AuthCodeButtonState.sendAndWait;
    Http().uploadImages(
      [file],
      success: (json) {
        // ShowToast.normal(json["msg"]);
        // authButtonState = AuthCodeButtonState.countDown;
        if (success != null) {
          success(true, json);
        }
      },
      fail: (reason, code, json) {
        if (success != null) {
          success(false, json);
        }
      },
      after: () {},
    );
  }

  uploadHeadOrEmblemPhoto(bool isHead) {
    if (isHead && headPhoto == null) {
      // ShowToast.normal("请上传身份证头像面");
      return;
    } else if (!isHead && emblemPhoto == null) {
      // ShowToast.normal("请上传身份证国徽面");
      return;
    }
    // verifiedAction("${imgUrl}2022/8/202208181144396JP00.jpg", isHead);
    uploadImgRequest(isHead ? headPhoto! : emblemPhoto!, (success, json) {
      if (success) {
        isHead ? (headPhotoUrl = json["data"]["src"]) : (emblemPhotoUrl = json["data"]["src"]);
        verifiedAction(json["data"]["src"], isHead);
      }
    });
  }

  verifiedAction(String url, bool isHead) {
    simpleRequest(
      url: Urls.userVerifiedStep1,
      params: {"idCardPhoto": url, "idCardPhotoType": isHead ? 1 : 2},
      success: (success, json) {
        isHead ? headPhotoPass = success : emblemPhotoPass = success;
        if (success) {
          if (isHead) {
            ShowToast.normal("身份证头像面上传成功");
            cardData = json["data"];
            headErrorMsg = "";
          } else {
            ShowToast.normal("身份证国徽面上传成功");
            emblemData = json["data"];
            emblemErrorMsg = "";
          }
        } else {
          isHead ? headErrorMsg = json["messages"] ?? "" : emblemErrorMsg = json["messages"];
        }
      },
      after: () {},
    );
  }

  bool isUpload = false;

  @override
  void onInit() {
    if (AppDefault().publicHomeData.isNotEmpty) {
      imgUrl = AppDefault().imageUrl;
    }
    super.onInit();
  }
}

class IdentityAuthenticationUpload extends GetView<IdentityAuthenticationUploadController> {
  const IdentityAuthenticationUpload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "实名认证"),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: controller.isUpload ? uploadInfoView(context) : inputInfoView(context),
        ),
      ),
    );
  }

  Widget inputInfoView(BuildContext context) {
    return Column(
      children: [
        gwb(375),
        Container(
          width: 345.w,
          margin: EdgeInsets.only(top: 17.w),
          decoration: getDefaultWhiteDec(radius: 6),
          child: centClm([
            SizedBox(
              width: 345.w,
              height: 55.w,
              child: Center(
                  child: Row(
                children: [
                  gwb(15),
                  getWidthText("姓名", 14, AppColor.textGrey5, 90, 1),
                  CustomInput(
                    width: 345.w - 90.w - 30.w,
                    heigth: 55.w,
                    placeholder: "请输入您的真实姓名",
                    textEditCtrl: controller.nameInputCtrl,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppColor.textBlack,
                      fontSize: 14.w,
                    ),
                    placeholderStyle: TextStyle(
                      color: AppColor.assisText,
                      fontSize: 14.w,
                    ),
                  ),
                ],
              )),
            ),
            gline(330, 0.5),
            SizedBox(
              width: 345.w,
              height: 55.w,
              child: Center(
                  child: Row(
                children: [
                  gwb(15),
                  getWidthText("身份证号", 14, AppColor.textGrey5, 90, 1),
                  CustomInput(
                    width: 345.w - 90.w - 30.w,
                    heigth: 55.w,
                    placeholder: "请输入您的身份证号",
                    textEditCtrl: controller.noInputCtrl,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppColor.textBlack,
                      fontSize: 14.w,
                    ),
                    placeholderStyle: TextStyle(
                      color: AppColor.assisText,
                      fontSize: 14.w,
                    ),
                  ),
                ],
              )),
            ),
          ]),
        ),
        ghb(50),
        GetX<IdentityAuthenticationUploadController>(
          builder: (_) {
            return getSubmitBtn("确认提交", () {
              controller.authInputConfirm();
              // Get.to(
              //     IdentityAuthenticationUploadComplete(
              //       headImgUrl: controller.headPhotoUrl,
              //       emblemImgUrl: controller.emblemPhotoUrl,
              //       cardData: controller.cardData,
              //       emblemData: controller.emblemData,
              //     ),
              //     binding:
              //         IdentityAuthenticationUploadCompleteBinding());
            }, enable: controller.submitEnable || !controller.isGetPhoto, height: 45, color: AppColor.theme, fontSize: 15);
          },
        ),
      ],
    );
  }

  Widget uploadInfoView(BuildContext context) {
    return Column(
      children: [
        gwb(375),
        ghb(15),
        sbRow([
          getSimpleText(
            "* 请上传本人有效期内的身份证照片，以确保信息无误。",
            12,
            AppColor.text3,
          ),
        ], width: 375 - 16 * 2),
        ghb(20),
        GetX<IdentityAuthenticationUploadController>(
          builder: (_) {
            return uploadView(0);
          },
        ),
        ghb(35),
        GetX<IdentityAuthenticationUploadController>(
          builder: (_) {
            return uploadView(1);
          },
        ),
        ghb(50),
        GetX<IdentityAuthenticationUploadController>(
          builder: (_) {
            return getSubmitBtn("确认提交", () {
              controller.authConfirmAction((succ) {
                if (succ) {
                  push(const AuthCompletePage(), context);
                }
              });
              // Get.to(
              //     IdentityAuthenticationUploadComplete(
              //       headImgUrl: controller.headPhotoUrl,
              //       emblemImgUrl: controller.emblemPhotoUrl,
              //       cardData: controller.cardData,
              //       emblemData: controller.emblemData,
              //     ),
              //     binding:
              //         IdentityAuthenticationUploadCompleteBinding());
            }, enable: controller.submitEnable || !controller.isGetPhoto, height: 45, color: AppColor.theme, fontSize: 15);
          },
        ),
        ghb(10),
        getSimpleText("您的隐私信息仅用于验证保障您的账号安全", 12, AppColor.text3),
        ghb(30)
      ],
    );
  }

  Widget uploadView(int type) {
    bool uploadSuccess = false;
    XFile? photo;
    if (type == 0) {
      uploadSuccess = controller.headPhotoPass;
      photo = controller.headPhoto;
    } else {
      uploadSuccess = controller.emblemPhotoPass;
      photo = controller.emblemPhoto;
    }

    return Column(
      children: [
        CustomButton(
          onPressed: () async {
            if (uploadSuccess && photo != null) {
              Uint8List bytes = await photo.readAsBytes();
              toCheckImg(image: bytes);
            } else {
              showPickImageModel(type == 0);
            }
          },
          child: Container(
            width: 266.w,
            height: 161.w,
            decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill, image: AssetImage(assetsName("mine/wallet/bg_idcard_${type == 0 ? "head" : "gh"}")))),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    assetsName("mine/wallet/icon_camera"),
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned.fill(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.w),
                  child: uploadSuccess && photo != null
                      ? FutureBuilder(
                          future: photo.readAsBytes(),
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? Image.memory(
                                    snapshot.requireData,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  )
                                : gemp();
                          },
                        )
                      : gemp(),
                ))
              ],
            ),
          ),
        ),
        ghb(5),
        getSimpleText("点击上传身份证${type == 0 ? "正" : "反"}面", 12, AppColor.text2)
      ],
    );
  }

  Widget tipsView(int index) {
    String img = "ok";
    String tip = "标准";
    switch (index) {
      case 0:
        img = "ok";
        tip = "标准";
        break;
      case 1:
        img = "bk";
        tip = "边框缺失";
        break;
      case 2:
        img = "mh";
        tip = "照片模糊";
        break;
      case 3:
        img = "sg";
        tip = "光线强烈";
        break;
    }

    return SizedBox(
      width: 80.w,
      height: 86.w,
      child: Column(
        children: [
          SizedBox(
            width: 80.w,
            height: 66.w,
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    bottom: 10.w,
                    child: Image.asset(
                      assetsName("mine/authentication/icon_tips_$img"),
                      width: 80.w,
                      height: 56.w,
                      fit: BoxFit.fill,
                    )),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 24.w,
                    child: Center(
                      child: Image.asset(
                        assetsName("mine/authentication/icon_tips_${index == 0 ? "right" : "wrong"}"),
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.fill,
                      ),
                    )),
              ],
            ),
          ),
          ghb(2),
          getSimpleText(tip, 12, const Color(0xFF928FB0), fw: FontWeight.w500)
        ],
      ),
    );
  }

  void showPickImageModel(bool isHead) {
    Get.bottomSheet(Container(
      color: Colors.white,
      height: 200.w,
      child: Column(
        children: [
          getButton('拍照', () {
            controller.getPhoto(false, isHead);
            Get.back();
            // _getImageFromCamera(ctx);
          }),
          getButton('从相册选择', () {
            controller.getPhoto(true, isHead);
            Get.back();
            // _getImageFromGallery(ctx);
          }),
          getButton('取消', () {
            Get.back();
          }),
        ],
      ),
    ));
  }

  Widget getButton(String title, void Function() pressed) {
    return SizedBox(
      height: 200.0.w / 3,
      width: 375.w,
      child: TextButton(
        onPressed: pressed,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 16.sp, color: AppColor.textBlack),
          ),
        ),
      ),
    );
  }
}

class AuthCompletePage extends StatelessWidget {
  const AuthCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getDefaultAppBar(
        context,
        "认证结果",
        backPressed: () {
          popToUntil();
        },
      ),
      body: UnconstrainedBox(
        child: Container(
          width: 375.w,
          decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(width: 1.w, color: AppColor.pageBackgroundColor))),
          child: Column(
            children: [
              ghb(30.5),
              gwb(375),
              Image.asset(
                assetsName("common/bg_auth_success"),
                width: 183.w,
                fit: BoxFit.fitWidth,
              ),
              ghb(35),
              getSimpleText("认证成功", 18, AppColor.text, isBold: true),
              ghb(15),
              getSimpleText("恭喜您，成功通过实名认证。", 12, AppColor.text3),
              ghb(30),
              getSubmitBtn("查看认证信息", () => popToUntil(page: const IdentityAuthenticationCheck(), binding: IdentityAuthenticationCheckBinding()), height: 45, color: AppColor.theme)
            ],
          ),
        ),
      ),
    );
  }
}
