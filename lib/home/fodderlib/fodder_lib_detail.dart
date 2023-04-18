import 'package:cached_network_image/cached_network_image.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/fodderlib/fodder_lib.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as di;

class FodderLibDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<FodderLibDetailController>(
        FodderLibDetailController(datas: Get.arguments));
  }
}

class FodderLibDetailController extends GetxController {
  final dynamic datas;
  FodderLibDetailController({this.datas});

  int type = 0;
  Map myData = {};

  downImg(
      Function(
    Uint8List data,
  )
          result) async {
    // Directory tempDir = await getTemporaryDirectory();
    try {
      di.Response res = await Http().dio.get(
          AppDefault().imageUrl + (myData["bgImg"] ?? ""),
          // "https://img10.360buyimg.com/seckillcms/s500x500_jfs/t1/208940/25/29416/121995/63f2ef87F7b3b0d34/c700abc587a6b0b5.jpg",
          options: di.Options(responseType: di.ResponseType.bytes));
      if (res.statusCode == 200) {
        result(res.data);
      }
    } on di.DioError catch (e) {}
  }

  collectAction() {
    simpleRequest(
      url: Urls.userShareCollection(
          id: myData[fromCollect ? "collectId" : "id"], type: type),
      params: {},
      success: (success, json) {
        if (success) {
          myData["isCollect"] = 1;
          ShowToast.normal("已收藏");
          // loadDetail();
          if (updateList != null) {
            updateList!();
          }
          update();
        }
      },
      after: () {},
    );
  }

  cancelCollectAction() {
    simpleRequest(
      url:
          Urls.userDelShareCollection(myData[fromCollect ? "collectId" : "id"]),
      params: {},
      success: (success, json) {
        if (success) {
          myData["isCollect"] = 0;
          ShowToast.normal("已取消收藏");
          if (updateList != null) {
            updateList!();
          }
          // loadDetail();
          update();
        }
      },
      after: () {},
    );
  }

  // loadDetail() {
  //   simpleRequest(
  //     url: Urls.newDetail(myData["id"]),
  //     params: {},
  //     success: (success, json) {
  //       if (success) {
  //         Map data = json["data"] ?? {};
  //         myData = data["cur"] ?? {};
  //         update();
  //       }
  //     },
  //     after: () {},
  //   );
  // }

  String fileLastName = "";
  String fileSzie = "";
  String fileWH = "";

  loadImage() {
    String img = myData["bgImg"] ?? "";
    if (img.isNotEmpty) {
      List l = img.split("/");
      if (l.isNotEmpty) {
        fileLastName = l.last.split(".").last;
      }
    }
    update();

    di.CancelToken cancelToken = di.CancelToken();

    Http().dio.get(
      AppDefault().imageUrl + (myData["bgImg"] ?? ""),
      // "https://img10.360buyimg.com/seckillcms/s500x500_jfs/t1/208940/25/29416/121995/63f2ef87F7b3b0d34/c700abc587a6b0b5.jpg",
      options: di.Options(responseType: di.ResponseType.bytes),
      cancelToken: cancelToken,
      onReceiveProgress: (count, total) {
        if (total > 0) {
          cancelToken.cancel();
          double k = total / 1028;

          if (k < 1024) {
            fileSzie = "${priceFormat(k)} KB";
          } else {
            double mb = k / 1024;
            if (mb < 1024) {
              fileSzie = "${priceFormat(mb)} MB";
            } else {
              double gb = mb / 1024;
              if (gb < 1024) {
                fileSzie = "${priceFormat(gb)} GB";
              }
            }
          }
        }
        update();
      },
    );

    CachedNetworkImageProvider p = CachedNetworkImageProvider(
      AppDefault().imageUrl + (myData["bgImg"] ?? ""),
      // "https://img10.360buyimg.com/seckillcms/s500x500_jfs/t1/208940/25/29416/121995/63f2ef87F7b3b0d34/c700abc587a6b0b5.jpg",
      errorListener: () {},
    );

    ImageStream stream = p.resolve(const ImageConfiguration());
    stream.addListener(
        ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
      fileWH = "${imageInfo.image.width}*${imageInfo.image.height}像素";
      update();
    }));
  }

  bool fromCollect = false;

  Function()? updateList;

  final _btnEnable = true.obs;
  bool get btnEnable => _btnEnable.value;
  set btnEnable(v) => _btnEnable.value = v;

  loadDownload(Function(bool succ) result) {
    btnEnable = false;
    simpleRequest(
      url: Urls.userNewDownload(myData["id"]),
      params: {},
      success: (success, json) {
        result(success);
        if (success) {
          type == 1
              ? Get.find<FodderLibController>().loadTop()
              : Get.find<FodderLibController>().loadData();

          myData["dnNum"] = (myData["dnNum"] ?? 0) + 1;
          update();
        }
      },
      after: () {
        btnEnable = true;
      },
    );
  }

  @override
  void onInit() {
    if (datas != null) {
      type = datas["type"] ?? 2;
      myData = datas["data"] ?? {};
      fromCollect = datas["collect"] ?? false;
      updateList = datas["updateList"];

      if (fromCollect) {
        myData["isCollect"] = 1;
        if (myData["bgImg"] == null || myData["bgImg"].isEmpty) {
          myData["bgImg"] = myData["coverImg"] ?? "";
        }
      }

      loadImage();
      // loadDetail();
    }
    super.onInit();
  }
}

class FodderLibDetail extends GetView<FodderLibDetailController> {
  const FodderLibDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "详情", action: [
        CustomButton(
          onPressed: () {
            showShareModel();
          },
          child: SizedBox(
            width: 55.w,
            height: kToolbarHeight,
            child: Center(
              child: Image.asset(
                assetsName("home/fodderlib/btn_nav_share"),
                width: 20.w,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      ]),
      body: Stack(children: [
        Positioned.fill(
            bottom: 60.w + paddingSizeBottom(context),
            child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: GetBuilder<FodderLibDetailController>(
                  builder: (_) {
                    return Column(
                      children: [
                        CustomNetworkImage(
                          src: AppDefault().imageUrl +
                              (controller.myData["bgImg"] ?? ""),
                          // src:
                          // "https://img10.360buyimg.com/seckillcms/s500x500_jfs/t1/208940/25/29416/121995/63f2ef87F7b3b0d34/c700abc587a6b0b5.jpg",
                          width: 375.w,
                          fit: BoxFit.fitWidth,
                        ),
                        Container(
                          width: 375.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              ghb(15),
                              getWidthText(controller.myData["title"], 18,
                                  AppColor.text2, 345, 100,
                                  isBold: true),
                              ghb(10),
                              getWidthText(
                                "文件格式：${controller.fileLastName}",
                                15,
                                AppColor.text3,
                                345,
                                100,
                              ),
                              ghb(5),
                              getWidthText(
                                "文件大小：${controller.fileSzie}",
                                15,
                                AppColor.text3,
                                345,
                                100,
                              ),
                              ghb(5),
                              getWidthText(
                                "尺寸/分辨率：${controller.fileWH}",
                                15,
                                AppColor.text3,
                                345,
                                100,
                              ),
                              ghb(5),
                              getWidthText(
                                "文件下载次数：${controller.myData["dnNum"] ?? 0}",
                                15,
                                AppColor.text3,
                                345,
                                100,
                              ),
                              ghb(5),
                              getWidthText(
                                "上传时间：${controller.myData["addTime"] ?? ""}",
                                15,
                                AppColor.text3,
                                345,
                                100,
                              ),
                              ghb(20),
                            ],
                          ),
                        ),
                        ghb(15),
                        Container(
                          width: 375.w,
                          color: Colors.white,
                          child: Column(
                            children: [
                              ghb(12),
                              sbRow([
                                getSimpleText("文案介绍：", 15, AppColor.text3),
                              ], width: 345),
                              ghb(10),
                              SizedBox(
                                width: 345.w,
                                child: HtmlWidget(
                                    controller.myData["content"] ?? ""),
                              ),
                              ghb(30)
                            ],
                          ),
                        )
                      ],
                    );
                  },
                ))),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60.w + paddingSizeBottom(context),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: const Color(0x0D000000),
                    offset: Offset(0, 2.w),
                    blurRadius: 4.w)
              ]),
              child: sbhRow([
                centRow([
                  gwb(5),
                  CustomButton(
                    onPressed: () {
                      popToUntil();
                    },
                    child: SizedBox(
                        height: 60.w,
                        width: 31.w,
                        child: centClm([
                          Image.asset(
                            assetsName("home/fodderlib/btn_home"),
                            width: 24.w,
                            fit: BoxFit.fitWidth,
                          ),
                          ghb(2),
                          getSimpleText("首页", 12, AppColor.text2),
                        ])),
                  ),
                  gwb(30),
                  CustomButton(
                    onPressed: () {
                      if ((controller.myData["isCollect"] ?? 0) == 1) {
                        controller.cancelCollectAction();
                      } else {
                        controller.collectAction();
                      }
                    },
                    child: SizedBox(
                        height: 60.w,
                        width: 31.w,
                        child: centClm([
                          GetBuilder<FodderLibDetailController>(
                            builder: (_) {
                              return Image.asset(
                                assetsName(
                                    "home/fodderlib/btn_sc_${(controller.myData["isCollect"] ?? 0) == 1 ? "selected" : "normal"}"),
                                width: 24.w,
                                fit: BoxFit.fitWidth,
                              );
                            },
                          ),
                          ghb(2),
                          getSimpleText("收藏", 12, AppColor.text2),
                        ])),
                  )
                ]),
                kIsWeb
                    ? gwb(0)
                    : GetX<FodderLibDetailController>(
                        builder: (_) {
                          return CustomButton(
                            onPressed: !controller.btnEnable
                                ? null
                                : () {
                                    controller.loadDownload(
                                        (succ) => controller.downImg((data) {
                                              saveImageToAlbum(data,
                                                  showToast: false);
                                              showDownloadSucc();
                                            }));
                                  },
                            child: Container(
                              width: 105.w,
                              height: 40.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: AppColor.theme.withOpacity(
                                      controller.btnEnable ? 1.0 : 0.1),
                                  borderRadius: BorderRadius.circular(20.w)),
                              child: getSimpleText("免费下载", 15, Colors.white),
                            ),
                          );
                        },
                      )
              ], height: 60, width: 375 - 16 * 2),
            ))
      ]),
    );
  }

  showShareModel() {
    Get.bottomSheet(Container(
      width: 375.w,
      height: 240.w + paddingSizeBottom(Global.navigatorKey.currentContext!),
      decoration: BoxDecoration(
          color: AppColor.pageBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.w))),
      child: Column(
        children: [
          gwb(375),
          SizedBox(
            height: 50.w,
            child: Center(
              child: getSimpleText("分享到", 15, AppColor.text2, isBold: true),
            ),
          ),
          gline(345, 1),
          SizedBox(
            height: 127.w,
            child: CustomButton(
              onPressed: () {
                copyClipboard(
                    AppDefault().imageUrl + (controller.myData["bgImg"] ?? ""));
              },
              child: centClm([
                Image.asset(
                  assetsName("share/icon_share_copy"),
                  height: 50.w,
                  fit: BoxFit.fitHeight,
                ),
                ghb(8),
                getSimpleText("复制链接", 12, AppColor.text2),
              ]),
            ),
          ),
          getSubmitBtn("取消", () {
            Get.back();
          }, color: Colors.white, textColor: AppColor.text2, height: 45)
        ],
      ),
    ));
  }

  showDownloadSucc() {
    showGeneralDialog(
      context: Global.navigatorKey.currentContext!,
      barrierLabel: "",
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return UnconstrainedBox(
          child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 270.w,
                  height: 330.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.w)),
                  child: Column(
                    children: [
                      ClipPath(
                        clipper: ModelClippper(arc: 25.w),
                        child: Container(
                          width: 270.w,
                          height: 98.w + 25.w / 2,
                          color: const Color(0xFF6993FA),
                          child: Column(
                            children: [
                              ghb(23),
                              getSimpleText("下载成功！", 18, Colors.white,
                                  isBold: true),
                              ghb(11),
                              getSimpleText("图片已保存，可在“手机相册”中查看", 12,
                                  Colors.white.withOpacity(0.5))
                            ],
                          ),
                        ),
                      ),
                      ghb(19),
                      Image.asset(
                        assetsName("home/fodderlib/bg_download_succ"),
                        height: 125.w,
                        fit: BoxFit.fitHeight,
                      ),
                      ghb(21),
                      getSubmitBtn("知道了", () {
                        Get.back();
                      },
                          height: 40,
                          width: 240,
                          color: AppColor.theme,
                          fontSize: 15)
                    ],
                  ),
                ),
              )),
        );
      },
    );
  }
}

class ModelClippper extends CustomClipper<Path> {
  final double arc;
  ModelClippper({required this.arc});
  Path path = Path();

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height - arc);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - arc);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
