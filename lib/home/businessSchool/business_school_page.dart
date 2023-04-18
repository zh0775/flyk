import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/businessSchool/business_school_collect.dart';
import 'package:cxhighversion2/home/businessSchool/business_school_detail.dart';
import 'package:cxhighversion2/home/businessSchool/business_school_list_page.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class BusinessSchoolPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<BusinessSchoolPageController>(BusinessSchoolPageController());
  }
}

class BusinessSchoolPageController extends GetxController {
  final List<AudioPlayer> audioPlayerList = [];
  Timer? timer;
  List infoList = [];

  final _inLoading = true.obs;
  bool get inLoading => _inLoading.value;
  set inLoading(v) => _inLoading.value = v;

  final _inSoundLoading = true.obs;
  bool get inSoundLoading => _inSoundLoading.value;
  set inSoundLoading(v) => _inSoundLoading.value = v;

  final _sectionIdx = 0.obs;
  int get sectionIdx => _sectionIdx.value;
  set sectionIdx(v) {
    _sectionIdx.value = v;
    update();
  }

  List sectionList = [];
  Map publicHomeData = {};
  String infoListBuildId = "BusinessSchoolPage_infoListBuildId";
  Map mainData = {};
  List audioList = [];

  loadInfoData() {
    simpleRequest(
      url: Urls.userBusinessSchoolInfo,
      params: {},
      success: (success, json) {
        if (success) {
          mainData = json["data"] ?? {};
          List sList = mainData["typeList"] ?? {};
          sectionList = [];
          for (var i = 0; i < sList.length; i++) {
            var e = sList[i];
            if (e["items"] != null && e["items"].isNotEmpty) {
              sectionList.add(e);
            }
          }
          sectionIdx = 0;
          audioList = (mainData["everyDayListen"]["items"]) ?? [];
          if (audioList != null && audioList.isNotEmpty) {
            for (var item in audioList) {
              item["isPlay"] = false;
              audioPlayerList.add(AudioPlayer());
            }
          }
          setAudio();
          update();
        }
      },
      after: () {
        inLoading = false;
      },
    );
  }

  setAudio() async {
    for (var i = 0; i < audioList.length; i++) {
      Map data = audioList[i];
      AudioPlayer player = audioPlayerList[i];

      String audioUrl = AppDefault().imageUrl + data["audio"];
      print("audioUrl ==== $audioUrl");
      final duration = await player.setUrl(audioUrl);
      if (duration != null) {
        data["duration"] = durationFormat(duration);
      }
    }
    update([playOrPauseAudioBuildId]);
  }

  String durationFormat(Duration? duration) {
    if (duration == null) return "";
    int seconds = duration.inSeconds;
    String format = "";
    if (seconds > 3600) {
      int hour = (seconds / 3600).floor();
      format += "${hour < 10 ? "0$hour" : "$hour"}:";
      seconds -= hour * 3600;
    }
    if (seconds > 60) {
      int minutes = (seconds / 60).floor();
      format += "${minutes < 10 ? "0$minutes" : "$minutes"}:";
      seconds -= minutes * 60;
    } else {
      format += "00:";
    }

    if (seconds > 1) {
      int sec = seconds;
      format += sec < 10 ? "0$sec" : "$sec";
    } else {
      format += "00";
    }

    return format;
  }

  String playOrPauseAudioBuildId = "BusinessSchoolPage_playOrPauseAudioBuildId";

  playOrPauseAudio(int index, Map data) async {
    data["isPlay"] = !data["isPlay"];
    if (data["isPlay"]) {
      for (var i = 0; i < audioList.length; i++) {
        Map item = audioList[i];
        if (item["isPlay"] && i != index) {
          audioPlayerList[i].pause();
          item["isPlay"] = false;
        }
      }
    }

    update([playOrPauseAudioBuildId]);
    AudioPlayer audioPlayer = audioPlayerList[index];
    startAndStopTime(
      data["isPlay"],
      callBack: () {
        data["duration"] = durationFormat(Duration(
            seconds: audioPlayer.duration!.inSeconds -
                audioPlayer.position.inSeconds));
        update([playOrPauseAudioBuildId]);
      },
    );
    data["isPlay"] ? await audioPlayer.play() : await audioPlayer.pause();
    update([playOrPauseAudioBuildId]);
  }

  startAndStopTime(bool start, {Function()? callBack}) {
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
    if (start) {
      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        if (callBack != null) {
          callBack();
        }
      });
    }
  }

  @override
  void onInit() {
    loadInfoData();
    publicHomeData = AppDefault().publicHomeData;
    super.onInit();
  }

  @override
  void dispose() {
    for (var item in audioPlayerList) {
      item.stop();
      item.dispose();
    }
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
    super.dispose();
  }
}

class BusinessSchoolPage extends GetView<BusinessSchoolPageController> {
  const BusinessSchoolPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "商学院", action: [
          CustomButton(
            onPressed: () {
              // Get.to(BusinessSchoolDetail(),
              //     binding: BusinessSchoolDetailBinding());
              Get.to(const BusinessSchoolCollect(),
                  binding: BusinessSchoolCollectBinding());
            },
            child: SizedBox(
              width: 70.w,
              height: kToolbarHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: getSimpleText("我的收藏", 14, AppColor.textBlack),
              ),
            ),
          )
        ]),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: GetX<BusinessSchoolPageController>(
              init: controller,
              builder: (_) {
                return controller.mainData.isEmpty
                    ? Center(
                        child: CustomEmptyView(
                          isLoading: controller.inLoading,
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 106.w,
                            child: Center(
                                child: GetBuilder<BusinessSchoolPageController>(
                              init: controller,
                              builder: (controller) {
                                return sbwClm([
                                  getSimpleText(
                                      controller.mainData.isNotEmpty
                                          ? controller.mainData["title"]
                                          : "",
                                      19,
                                      AppColor.textBlack,
                                      isBold: true),
                                  getSimpleText(
                                      controller.mainData.isNotEmpty
                                          ? controller.mainData["subhead"]
                                          : "",
                                      14,
                                      AppColor.textBlack),
                                ],
                                    width: 375 - 24 * 2,
                                    height: 49,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start);
                              },
                            )),
                          ),
                          GetBuilder<BusinessSchoolPageController>(
                            id: controller.playOrPauseAudioBuildId,
                            builder: (_) {
                              return Visibility(
                                visible: controller.audioList != null &&
                                    controller.audioList.isNotEmpty,
                                child: Container(
                                  width: 345.w,
                                  height: 157.w,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.w),
                                        topRight: Radius.circular(20.w),
                                        bottomLeft: Radius.circular(5.w),
                                        bottomRight: Radius.circular(5.w),
                                      )),
                                  child: Center(
                                      child: sbwClm([
                                    getSimpleText(
                                        "每日一听", 16, AppColor.textBlack,
                                        isBold: true),
                                    ...controller.audioList
                                        .asMap()
                                        .entries
                                        .map((e) => soundCell(e.key, e.value))
                                        .toList()
                                  ],
                                          width: 345 - 10 * 2,
                                          height: 157 - 16.5 * 2,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start)),
                                ),
                              );
                            },
                          ),
                          ghb(17),
                          SizedBox(
                              width: 345.w,
                              child: GetBuilder<BusinessSchoolPageController>(
                                init: controller,
                                builder: (_) {
                                  return controller.sectionList != null &&
                                          controller.sectionList.isNotEmpty
                                      ? Wrap(
                                          spacing: 10.w,
                                          runSpacing: 8.w,
                                          children: [
                                            ...(controller.sectionList
                                                .asMap()
                                                .entries
                                                .map((e) => typeBtn(
                                                    e.key,
                                                    e.value["typeName"],
                                                    e.value["type"]))
                                                .toList())
                                          ],
                                        )
                                      : ghb(0);
                                },
                              )),
                          ghb(17),
                          GetBuilder<BusinessSchoolPageController>(
                            init: controller,
                            builder: (_) {
                              return controller.sectionList != null &&
                                      controller.sectionList.isNotEmpty
                                  ? Column(
                                      children: [
                                        ...(controller.sectionList[controller
                                                .sectionIdx]["items"] as List)
                                            .asMap()
                                            .entries
                                            .map((e) => infoCell(
                                                e.key,
                                                controller.sectionList[
                                                        controller.sectionIdx]
                                                    ["items"][e.key]))
                                            .toList()
                                      ],
                                    )
                                  : ghb(0);
                              // ListView.builder(
                              // itemCount: controller.sectionList != null &&
                              //         controller.sectionList.isNotEmpty &&
                              //         controller.sectionList[controller.sectionIdx]
                              //                 ["items"] !=
                              //             null &&
                              //         controller
                              //             .sectionList[controller.sectionIdx]["items"]
                              //             .isNotEmpty
                              //       ? controller
                              //           .sectionList[controller.sectionIdx]["items"].length
                              //       : 0,
                              //   itemBuilder: (context, index) {
                              //     return infoCell(
                              //         index,
                              //         controller.sectionList[controller.sectionIdx]["items"]
                              //             [index]);
                              //   },
                              // );
                            },
                          ),
                          GetBuilder<BusinessSchoolPageController>(
                            init: controller,
                            builder: (_) {
                              List items = (controller.sectionList.isNotEmpty
                                      ? controller
                                          .sectionList[controller.sectionIdx]
                                      : {})["items"] ??
                                  [];
                              return controller.sectionList != null &&
                                      controller.sectionList.isNotEmpty
                                  ? CustomButton(
                                      onPressed: () {
                                        if (items.isEmpty) {
                                          return;
                                        }
                                        List sectionList = AppDefault()
                                                .publicHomeData["appHelpRule"]
                                            ["businessSchool"];
                                        int index = 0;
                                        for (var i = 0;
                                            i < sectionList.length;
                                            i++) {
                                          if (controller.sectionList[controller
                                                  .sectionIdx]["type"] ==
                                              sectionList[i]["id"]) {
                                            index = i;
                                            break;
                                          }
                                        }

                                        Get.to(const BusinessSchoolListPage(),
                                            binding:
                                                BusinessSchoolListPageBinding(),
                                            arguments: {"index": index});
                                      },
                                      child: Container(
                                        color: Colors.white,
                                        width: 375.w,
                                        height: 45.5.w,
                                        child: Center(
                                          child: items.isNotEmpty
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    getSimpleText("查看全部", 13,
                                                        AppColor.textGrey),
                                                    gwb(8),
                                                    Icon(
                                                      Icons.chevron_right,
                                                      color: AppColor.textGrey,
                                                      size: 20.w,
                                                    ),
                                                  ],
                                                )
                                              : getSimpleText("暂无内容", 13,
                                                  AppColor.textGrey),
                                        ),
                                      ),
                                    )
                                  : ghb(0);
                            },
                          ),
                          ghb(50)
                        ],
                      );
              },
            )));
  }

  Widget soundCell(int index, Map data) {
    if (data["isPlay"] == null) {
      data["isPlay"] = false;
    }
    return CustomButton(
      onPressed: () {
        controller.playOrPauseAudio(index, data);
      },
      child: sbRow([
        centRow([
          Icon(
            data["isPlay"]
                ? Icons.play_circle_outline_rounded
                : Icons.pause_circle_outline_rounded,
            size: 18.w,
            color: AppColor.textBlack,
          ),
          gwb(6),
          getSimpleText(data["title"], 15, AppColor.textBlack, isBold: true),
        ]),
        getSimpleText(data["duration"] ?? "", 15, AppColor.textGrey),
      ], width: 345 - 10 * 2),
    );
  }

  Widget infoCell(int index, Map data) {
    return CustomButton(
      onPressed: () {
        Get.to(
            BusinessSchoolDetail(
              id: data["id"],
            ),
            binding: BusinessSchoolDetailBinding());
      },
      child: Column(
        children: [
          Container(
            width: 375.w,
            color: Colors.white,
            child: Center(
              child: sbhRow([
                SizedBox(
                  width: 115.w,
                  height: 80.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.w),
                    child: CustomNetworkImage(
                      src: AppDefault().imageUrl + data["coverImages"],
                      width: 115.w,
                      height: 80.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                centClm([
                  getContentText(
                      data["title"] ?? "", 15, AppColor.textBlack, 179, 53, 2,
                      alignment: Alignment.topLeft),
                  getSimpleText(
                      "浏览：${data["view"] ?? "0"}", 12, AppColor.textGrey),
                ], crossAxisAlignment: CrossAxisAlignment.start)
              ], width: 375 - 15 * 2, height: 112),
            ),
          ),
          gline(325, 0.5),
        ],
      ),
    );
  }

  Widget typeBtn(int idx, String title, int sectionId) {
    List colorList =
        controller.publicHomeData["versionInfo"]["theme"]["themeColorList"];

    Map themeColor = idx > colorList.length - 1
        ? colorList[colorList.length - 1]
        : colorList[idx];
    String colorStr = themeColor["color"];
    int transparency =
        ((themeColor["transparency"] as double) / 100 * 255).ceil();

    colorStr = colorStr.substring(1);
    String opacity = transparency.toRadixString(16);
    String colorHex = "0x$opacity$colorStr";

    return CustomButton(
      onPressed: () {
        controller.sectionIdx = idx;
      },
      child: Container(
        width: 90.w,
        height: 40.w,
        // margin: EdgeInsets.only(left: 10.w),
        decoration: BoxDecoration(
            color: Color(int.parse(colorHex)),
            borderRadius: BorderRadius.circular(5.w)),
        child: Center(
          child: getSimpleText(title, 14, Colors.white),
        ),
      ),
    );
  }
}
