import 'package:chewie/chewie.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_html_view.dart';
import 'package:cxhighversion2/home/businessSchool/business_school_collect.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
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

  @override
  void onInit() {
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
      appBar: getDefaultAppBar(
        context,
        "详情",
      ),
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
