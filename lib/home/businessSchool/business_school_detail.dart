import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_html_view.dart';
import 'package:cxhighversion2/home/businessSchool/business_school_collect.dart';
import 'package:cxhighversion2/home/fodderlib/fodder_lib_detail.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:dio/dio.dart' as di;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:video_player/video_player.dart';

class BusinessSchoolDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<BusinessSchoolDetailController>(
        BusinessSchoolDetailController(datas: Get.arguments));
  }
}

class BusinessSchoolDetailController extends GetxController {
  final dynamic datas;
  BusinessSchoolDetailController({this.datas});

  bool isFirst = true;
  String videoBuildId = "BusinessSchoolDetailController_videoBuildId";

  VideoPlayerController? videoCtrl;
  ChewieController? chewieController;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isCollect = false.obs;
  bool get isCollect => _isCollect.value;
  set isCollect(v) => _isCollect.value = v;
  String htmlSrc = "";
  int currentId = 0;
  Map collectData = {};
  bool haveAudio = false;
  bool haveVideo = true;

  loadDetailData() {
    if (htmlSrc == null || htmlSrc.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: type == 0
          ? Urls.userBusinessSchoolShow(currentId)
          : Urls.newDetail(currentId),
      params: {},
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};

          if (type == 0) {
            collectData = data;
            htmlSrc = data["bS_Content"];
            isCollect = data["isCollect"] ?? false;
            if (haveVideo &&
                collectData["bS_Audio"] != null &&
                collectData["bS_Audio"].isNotEmpty) {
              // 如果从推广技巧过来并且有视频，开启保存按钮
              haveSave = needSave;
              String bS_Audio = (collectData["bS_Audio"] ?? "");
              String vUrl = bS_Audio.contains("http")
                  ? bS_Audio
                  : AppDefault().imageUrl + bS_Audio;

              videoCtrl = VideoPlayerController.network(vUrl,
                  videoPlayerOptions: VideoPlayerOptions())
                ..initialize().then((value) {
                  videoCtrl!.play();
                  // videoCtrl!.addListener(checkVideo);
                  double i = videoCtrl!.value.aspectRatio;
                  chewieController = ChewieController(
                      videoPlayerController: videoCtrl!,
                      autoPlay: true,
                      aspectRatio: i,
                      showOptions: false
                      // looping: true,
                      );
                  update([videoBuildId]);
                });

              // update([videoBuildId]);
            }
          } else if (type == 1) {
            htmlSrc = data["content"];
            collectData = {
              "bS_Title": data["meta"] ?? "",
              "bS_View": data["viewNum"] ?? 0,
              "addTime": data["addTime"] ?? "",
            };
          }

          update();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  Duration videoDuration = const Duration();
  Duration videoPosition = const Duration();

  String videoDuratonBuildId =
      "BusinessSchoolDetailController_videoDuratonBuildId";
  checkVideo() {
    if (videoCtrl != null) {
      videoDuration = videoCtrl!.value.duration;
      videoPosition = videoCtrl!.value.position;
      update([videoDuratonBuildId]);
      if (videoPosition.inMilliseconds >= videoDuration.inMilliseconds) {
        update([videoBuildId]);
      }
    }
  }

  final _collectEnable = true.obs;
  bool get collectEnable => _collectEnable.value;
  set collectEnable(v) => _collectEnable.value = v;

  loadCollect({bool cancel = false}) {
    collectEnable = false;
    if (cancel) {
      simpleRequest(
        url: Urls.userShareCollection(id: currentId, type: 2),
        params: {},
        success: (success, json) {
          if (success) {
            isCollect = true;
            ShowToast.normal("收藏成功");
            if (fromCollect) {
              Get.find<BusinessSchoolCollectController>().loadData();
            }
          }
        },
        after: () {
          collectEnable = true;
        },
      );
    } else {
      simpleRequest(
        url: Urls.userDelShareCollection(collectData["collectId"] ?? 0),
        params: {},
        success: (success, json) {
          if (success) {
            isCollect = false;
            ShowToast.normal("取消收藏成功");
            if (fromCollect) {
              Get.find<BusinessSchoolCollectController>().loadData();
            }
          }
        },
        after: () {
          collectEnable = true;
        },
      );
    }
  }

  final _saveBtnEnable = true.obs;
  bool get saveBtnEnable => _saveBtnEnable.value;
  set saveBtnEnable(v) => _saveBtnEnable.value = v;

  saveVideo() {
    loadDownloadVideo();
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
                          color: AppColor.theme.withOpacity(0.7),
                          child: Column(
                            children: [
                              ghb(23),
                              getSimpleText("下载成功！", 18, Colors.white,
                                  isBold: true),
                              ghb(11),
                              getSimpleText("视频已保存，可在“手机相册”中查看", 12,
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

  loadDownloadVideo() {
    saveBtnEnable = false;
    downVideo(
      (data, suffix) {
        if (data != null) {
          saveImageToAlbum(
            data,
            showToast: false,
            isVideo: true,
            suffix: suffix,
            resultCallback: (result) {
              if (result != null && result) {
                showDownloadSucc();
              }
            },
          );
        } else {
          ShowToast.normal("保存失败");
        }
        saveBtnEnable = true;
      },
    );
  }

  downVideo(Function(Uint8List? data, String suffix) result) async {
    // Directory tempDir = await getTemporaryDirectory();
    try {
      di.Response res = await Http().dio.get(
          AppDefault().imageUrl + (collectData["bS_Audio"] ?? ""),
          // "https://img10.360buyimg.com/seckillcms/s500x500_jfs/t1/208940/25/29416/121995/63f2ef87F7b3b0d34/c700abc587a6b0b5.jpg",
          options: di.Options(responseType: di.ResponseType.bytes));

      String mySuffix = "";
      res.headers.forEach((name, values) {
        if (name == 'content-type') {
          mySuffix = MediaType.parse(values[0]).subtype;
        }
      });
      if (res.statusCode == 200) {
        result(res.data, mySuffix);
      } else {
        result(null, "");
      }
    } on di.DioError catch (e) {
      result(null, "");
    }
  }

  bool videoTool = false;
  showVideoTools() {
    videoTool = true;
    update([videoBuildId]);
    Future.delayed(const Duration(seconds: 3), () {
      videoTool = false;
      update([videoBuildId]);
    });
  }

  bool fromCollect = false;

  dataInit(int id, bool from) {
    if (!isFirst) return;
    isFirst = false;
    // if (type != 0) {
    //   htmlSrc = infoData["content"];
    //   collectData = {
    //     "bS_Title": infoData["meta"] ?? "",
    //     "bS_View": infoData["view"] ?? 0,
    //     "addTime": infoData["addTime"] ?? "",
    //   };
    //   return;
    // }
    if (type != 0) {
      currentId = infoData["id"];
    } else {
      currentId = id;
    }

    fromCollect = from;
    loadDetailData();
    // loadCollect();
  }

  int type = 0;
  Map infoData = {};
  bool needSave = false;
  final _haveSave = false.obs;
  bool get haveSave => _haveSave.value;
  set haveSave(v) => _haveSave.value = v;

  @override
  void onInit() {
    // 是否需要保存
    needSave = kIsWeb ? false : (datas ?? {})["needSave"] ?? false;
    type = (datas ?? {})["type"] ?? 0;
    infoData = (datas ?? {})["data"] ?? {};
    super.onInit();
  }

  @override
  void onClose() {
    if (haveVideo) {
      if (videoCtrl != null) {
        if (videoCtrl!.value.isPlaying) {
          videoCtrl!.pause();
        }
        videoCtrl?.removeListener(checkVideo);
        videoCtrl?.dispose();
      }
      if (chewieController != null) {
        if (chewieController!.isPlaying) {
          chewieController!.pause();
        }
        chewieController!.dispose();
      }
    }
    super.onClose();
  }
}

class BusinessSchoolDetail extends GetView<BusinessSchoolDetailController> {
  final int id;
  final bool fromCollect;
  const BusinessSchoolDetail(
      {Key? key, required this.id, this.fromCollect = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(id, fromCollect);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getDefaultAppBar(context, "详情", action: [
        GetX<BusinessSchoolDetailController>(
          builder: (_) {
            return !controller.haveSave
                ? gwb(0)
                : CustomButton(
                    onPressed: () {
                      controller.saveVideo();
                    },
                    child: SizedBox(
                        width: 90.w,
                        height: kToolbarHeight,
                        child: Center(
                            child: getSimpleText(
                                "保存到本地",
                                14,
                                controller.saveBtnEnable
                                    ? AppColor.textBlack
                                    : AppColor.textGrey5))),
                  );
          },
        )
      ]),
      body: GetBuilder<BusinessSchoolDetailController>(
        init: controller,
        initState: (_) {},
        builder: (_) {
          return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: controller.htmlSrc.isNotEmpty
                  ? Container(
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          gline(375, 0.5),
                          ghb(15),
                          getWidthText(controller.collectData["bS_Title"] ?? "",
                              21, AppColor.text, 375 - 16 * 2, 10,
                              isBold: true),
                          ghb(15),
                          sbRow([
                            getSimpleText(
                                controller.collectData["addTime"] ?? "",
                                12,
                                AppColor.text3),
                            getSimpleText(
                                "${controller.collectData["bS_View"] ?? 0}次阅读",
                                12,
                                AppColor.text3),
                          ], width: 375 - 16 * 2),
                          ghb(15),
                          gline(345, 0.5),
                          ghb(10),
                          videoView(),
                          CustomHtmlView(
                            src: controller.htmlSrc,
                            width: 345,
                            loadingWidget: Center(
                                child: getSimpleText(
                                    "页面正在加载中", 15, AppColor.textGrey)),
                          ),
                          SizedBox(
                            height: paddingSizeBottom(context),
                          ),
                          ghb(50),
                        ],
                      ),
                    )
                  : GetX<BusinessSchoolDetailController>(
                      builder: (_) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 100.w),
                            child: CustomEmptyView(
                              isLoading: controller.isLoading,
                            ),
                          ),
                        );
                      },
                    ));
        },
      ),
    );
  }

  Widget videoView() {
    return GetBuilder<BusinessSchoolDetailController>(
        id: controller.videoBuildId,
        builder: (_) {
          return controller.haveVideo &&
                  controller.videoCtrl != null &&
                  controller.videoCtrl!.value.isInitialized
              ? Padding(
                  padding: EdgeInsets.only(bottom: 15.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.w),
                    child: SizedBox(
                      width: 345.w,
                      height: 345.w /
                          (controller.chewieController!.aspectRatio ?? 3.0),
                      child: Chewie(
                        controller: controller.chewieController!,
                      ),
                    ),
                  ),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(4.w),
                  //   child: SizedBox(
                  //       width: 345.w,
                  //       height: 171.w,
                  //       child: Stack(
                  //         children: [
                  //           Positioned(
                  //             top: 0,
                  //             left: 0,
                  //             right: 0,
                  //             bottom: 20.w,
                  //             child: Container(
                  //               padding: EdgeInsets.all(5.w),
                  //               color: Colors.black,
                  //               alignment: Alignment.center,
                  //               child: SizedBox(
                  //                 width: 345.w *
                  //                     (151.w /
                  //                         controller
                  //                             .videoCtrl!.value.size.height),
                  //                 height: 151.w,
                  //                 child: VideoPlayer(controller.videoCtrl!),
                  //               ),
                  //             ),
                  //           ),
                  //           Positioned(
                  //               top: 0,
                  //               left: 0,
                  //               right: 0,
                  //               bottom: 20.w,
                  //               child: CustomButton(
                  //                 onPressed: () {
                  //                   if (controller.videoCtrl != null) {
                  //                     if (controller
                  //                         .videoCtrl!.value.isPlaying) {
                  //                       controller.videoCtrl!.pause();
                  //                     } else {
                  //                       controller.videoCtrl!.play();
                  //                     }
                  //                     controller
                  //                         .update([controller.videoBuildId]);
                  //                   }
                  //                 },
                  //                 child: !controller.videoCtrl!.value.isPlaying
                  //                     ? Center(
                  //                         child: Image.asset(
                  //                           assetsName("common/btn_video_play"),
                  //                           width: 34.w,
                  //                           fit: BoxFit.fitWidth,
                  //                         ),
                  //                       )
                  //                     : gemp(),
                  //               )),
                  //           Positioned(
                  //               bottom: 0,
                  //               left: 0,
                  //               right: 0,
                  //               height: 20.w,
                  //               child: Container(
                  //                 color: Colors.black54,
                  //                 child: Center(
                  //                   child: GetBuilder<
                  //                       BusinessSchoolDetailController>(
                  //                     id: controller.videoDuratonBuildId,
                  //                     builder: (_) {
                  //                       int dSeconds =
                  //                           controller.videoDuration.inSeconds;
                  //                       int dHour = (dSeconds / 3600).floor();
                  //                       dSeconds -= dHour * 3600;

                  //                       int dMinutes = (dSeconds / 60).floor();
                  //                       dSeconds -= dMinutes * 60;

                  //                       String d = dHour > 0
                  //                           ? "${dHour < 10 ? "0$dHour" : "$dHour"}:${dMinutes < 10 ? "0$dMinutes" : "$dMinutes"}:${dSeconds < 10 ? "0$dSeconds" : "$dSeconds"}"
                  //                           : "${dMinutes < 10 ? "0$dMinutes" : "$dMinutes"}:${dSeconds < 10 ? "0$dSeconds" : "$dSeconds"}";

                  //                       int pSeconds =
                  //                           controller.videoPosition.inSeconds;
                  //                       int pHour = (pSeconds / 3600).floor();
                  //                       pSeconds -= pHour * 3600;

                  //                       int pMinutes = (pSeconds / 60).floor();
                  //                       pSeconds -= pMinutes * 60;

                  //                       String p = pHour > 0
                  //                           ? "${pHour < 10 ? "0$pHour" : "$pHour"}:${pMinutes < 10 ? "0$pMinutes" : "$pMinutes"}:${pSeconds < 10 ? "0$pSeconds" : "$pSeconds"}"
                  //                           : "${pMinutes < 10 ? "0$pMinutes" : "$pMinutes"}:${pSeconds < 10 ? "0$pSeconds" : "$pSeconds"}";
                  //                       double v = controller
                  //                               .videoPosition.inMilliseconds /
                  //                           controller
                  //                               .videoDuration.inMilliseconds;
                  //                       double tWidth = calculateTextSize(
                  //                               d,
                  //                               12,
                  //                               FontWeight.normal,
                  //                               double.infinity,
                  //                               1,
                  //                               Global.navigatorKey
                  //                                   .currentContext!)
                  //                           .width;
                  //                       return Row(
                  //                         mainAxisAlignment:
                  //                             MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           gwb(10),
                  //                           getSimpleText(p, 12, Colors.white),
                  //                           SizedBox(
                  //                             width: 345.w -
                  //                                 tWidth * 2 -
                  //                                 10.w * 2 -
                  //                                 20.w,
                  //                             child: Slider(
                  //                               value: controller.videoDuration
                  //                                           .inMilliseconds ==
                  //                                       0
                  //                                   ? 0
                  //                                   : v,
                  //                               onChanged: (value) {
                  //                                 if (controller.videoCtrl !=
                  //                                     null) {
                  //                                   // print(value);

                  //                                   controller.videoCtrl!.seekTo(Duration(
                  //                                       milliseconds: (controller
                  //                                                   .videoDuration
                  //                                                   .inMilliseconds *
                  //                                               value)
                  //                                           .ceil()));
                  //                                 }
                  //                               },
                  //                             ),
                  //                           ),
                  //                           getSimpleText(d, 12, Colors.white),
                  //                           gwb(10),
                  //                         ],
                  //                       );
                  //                     },
                  //                   ),
                  //                 ),
                  //               ))
                  //         ],
                  //       )),
                  // ),
                )
              : ghb(0);
        });
  }
}
