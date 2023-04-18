import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class RankBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RankController>(RankController());
  }
}

class RankController extends GetxController {
  PageController pageController = PageController(viewportFraction: 0.36);

  final _isLoading = true.obs;
  set isLoading(v) => _isLoading.value = v;
  bool get isLoading => _isLoading.value;

  final _buttonIdx = 1.obs;
  set buttonIdx(v) {
    if (_buttonIdx.value != v) {
      _buttonIdx.value = v;
      update();
    }
  }

  bool pageAnimation = false;
  pageAnimationTo(int index) {
    pageAnimation = true;
    pageController
        .animateToPage(index,
            duration: const Duration(milliseconds: 200), curve: Curves.linear)
        .then((value) {
      pageAnimation = false;
    });
  }

  int get buttonIdx => _buttonIdx.value;
  List pageDataList = [];
  Map rankData = {};

  loadRankData() {
    simpleRequest(
      url: Urls.userTOPScoreList,
      params: {},
      success: (success, json) {
        if (success) {
          rankData = json["data"] ?? {};
          pageDataList = [];
          if (rankData["tradeData"] != null) {
            pageDataList.add({
              "field": "tradeData",
              "name": "本月交易排行",
              "datas": ((rankData["tradeData"] ?? []) as List).map((e) {
                e["num"] = priceFormat(e["num"], savePoint: 2);
                return e;
              }).toList()
            });
          }
          if (rankData["activData"] != null) {
            pageDataList.add({
              "field": "activData",
              "name": "激活排行",
              "datas": ((rankData["activData"] ?? []) as List).map((e) {
                e["num"] = priceFormat(e["num"], savePoint: 0);
                return e;
              }).toList()
            });
          }
          if (rankData["bounsData"] != null) {
            pageDataList.add({
              "field": "bounsData",
              "name": "累计收益排行",
              "datas": ((rankData["bounsData"] ?? []) as List).map((e) {
                e["num"] = priceFormat(e["num"], savePoint: 2);
                return e;
              }).toList()
            });
          }
          // if (rankData["tradeTeamData"] != null) {
          //   pageDataList.add({
          //     "field": "tradeTeamData",
          //     "name": "团队累计交易",
          //     "datas": rankData["tradeTeamData"] ?? []
          //   });
          // }

          if (pageDataList.isNotEmpty) {
            // pageController.jumpToPage(500);
          }
          update();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  // checkBtnIndex() {
  //   if (!pageAnimation &&
  //       pageController.page != null &&
  //       pageDataList.isNotEmpty &&
  //       (pageController.page)!.ceil() % pageDataList.length != buttonIdx) {
  //     buttonIdx = pageController.page!.ceil() % pageDataList.length;
  //   }
  // }

  @override
  void onInit() {
    // pageController.addListener(checkBtnIndex);
    loadRankData();

    super.onInit();
  }

  @override
  void dispose() {
    // pageController.removeListener(checkBtnIndex);
    pageController.dispose();
    super.dispose();
  }
}

class Rank extends GetView<RankController> {
  const Rank({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 375.w,
              height: 324.w,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(assetsName("rank/bg_rank")))),
              child: Stack(children: [
                Positioned(
                    top: paddingSizeTop(context),
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        defaultBackButton(context, white: true),
                        gwb(8),
                        SizedBox(
                            width: (375 - 40 * 2).w,
                            height: kToolbarHeight,
                            child: GetBuilder<RankController>(
                              builder: (_) {
                                return Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                        controller.pageDataList.length,
                                        (idx) => CustomButton(
                                              onPressed: () {
                                                controller.buttonIdx = idx;
                                                // controller.pageAnimationTo(index);
                                              },
                                              child: SizedBox(
                                                width: (375 - 40 * 2).w / 3 -
                                                    0.1.w,
                                                child: Align(
                                                  child: centClm([
                                                    getSimpleText(
                                                        controller.pageDataList[
                                                            idx]["name"],
                                                        controller.buttonIdx ==
                                                                idx
                                                            ? 16
                                                            : 14,
                                                        Colors.white,
                                                        fw: FontWeight.w700),
                                                    ghb(controller.buttonIdx ==
                                                            idx
                                                        ? 4
                                                        : 0),
                                                    controller.buttonIdx == idx
                                                        ? Container(
                                                            width: 12.w,
                                                            height: 2.w,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            1.w)),
                                                          )
                                                        : ghb(0)
                                                  ]),
                                                ),
                                              ),
                                            )),
                                  ),
                                );

                                // PageView.builder(
                                //   physics: const NeverScrollableScrollPhysics(),
                                //   controller: controller.pageController,
                                //   itemCount: controller.pageDataList.length,
                                //   onPageChanged: (value) {
                                //     if (controller.pageDataList.isNotEmpty) {
                                //       controller.buttonIdx = value %
                                //           controller.pageDataList.length;
                                //     }
                                //   },
                                //   itemBuilder: (context, index) {
                                //     int idx =
                                //         index % controller.pageDataList.length;
                                //     Map data = controller.pageDataList[idx];
                                //     return CustomButton(
                                //       onPressed: () {
                                //         controller.buttonIdx = idx;
                                //         // controller.pageAnimationTo(index);
                                //       },
                                //       child: centClm([
                                //         getSimpleText(
                                //             data["name"],
                                //             controller.buttonIdx == idx
                                //                 ? 16
                                //                 : 14,
                                //             Colors.white,
                                //             fw: FontWeight.w700),
                                //         ghb(controller.buttonIdx == idx
                                //             ? 4
                                //             : 0),
                                //         controller.buttonIdx == idx
                                //             ? Container(
                                //                 width: 12.w,
                                //                 height: 2.w,
                                //                 decoration: BoxDecoration(
                                //                     color: Colors.white,
                                //                     borderRadius:
                                //                         BorderRadius.circular(
                                //                             1.w)),
                                //               )
                                //             : ghb(0)
                                //       ]),
                                //     );
                                //   },
                                // );
                              },
                            ))
                      ],
                    )),
                Positioned(
                    top: 152.w,
                    left: 23.w,
                    child: GetBuilder<RankController>(
                      builder: (_) {
                        Map data = {};
                        if (controller.pageDataList.length >
                                controller.buttonIdx &&
                            controller
                                    .pageDataList[controller.buttonIdx].length >
                                1 &&
                            controller.pageDataList[controller.buttonIdx]
                                    ["datas"] !=
                                null &&
                            controller
                                    .pageDataList[controller.buttonIdx]["datas"]
                                    .length >
                                1) {
                          data = controller.pageDataList[controller.buttonIdx]
                              ["datas"][1];
                        }
                        return topHead(2, data);
                      },
                    )),
                Positioned(
                    top: 125.w,
                    left: (375 - 96).w / 2,
                    child: GetBuilder<RankController>(
                      builder: (_) {
                        Map data = {};
                        if (controller.pageDataList.length >
                                controller.buttonIdx &&
                            controller
                                    .pageDataList[controller.buttonIdx].length >
                                0 &&
                            controller.pageDataList[controller.buttonIdx]
                                    ["datas"] !=
                                null &&
                            controller
                                    .pageDataList[controller.buttonIdx]["datas"]
                                    .length >
                                0) {
                          data = controller.pageDataList[controller.buttonIdx]
                              ["datas"][0];
                        }
                        return topHead(1, data);
                      },
                    )),
                Positioned(
                    top: 152.w,
                    right: 23.w,
                    child: GetBuilder<RankController>(
                      builder: (_) {
                        Map data = {};
                        if (controller.pageDataList.length >
                                controller.buttonIdx &&
                            controller
                                    .pageDataList[controller.buttonIdx].length >
                                2 &&
                            controller.pageDataList[controller.buttonIdx]
                                    ["datas"] !=
                                null &&
                            controller
                                    .pageDataList[controller.buttonIdx]["datas"]
                                    .length >
                                2) {
                          data = controller.pageDataList[controller.buttonIdx]
                              ["datas"][2];
                        }
                        return topHead(3, data);
                      },
                    ))
              ]),
            ),
            ghb(10),
            GetBuilder<RankController>(
              builder: (controller) {
                List list = [];
                Map pageData = {};
                if (controller.pageDataList.isNotEmpty &&
                    controller.pageDataList.length > controller.buttonIdx &&
                    controller.pageDataList[controller.buttonIdx]["datas"] !=
                        null &&
                    controller.pageDataList[controller.buttonIdx]["datas"]
                        .isNotEmpty) {
                  pageData = controller.pageDataList[controller.buttonIdx];
                  list = pageData["datas"];
                }
                return controller.pageDataList.isEmpty || list.isEmpty
                    ? GetX<RankController>(
                        builder: (_) {
                          return CustomEmptyView(
                            isLoading: controller.isLoading,
                          );
                        },
                      )
                    : Column(
                        children: [
                          listCell(0, {}, pageData, true),
                          ...List.generate(
                              list.length,
                              (index) => listCell(
                                  index, list[index], pageData, false)),
                        ],
                      );
              },
            ),
            ghb(30),
          ],
        ),
      )),
    );
  }

  Widget listCell(int index, Map data, Map pageData, bool isHead) {
    String unit = "";
    String headTitle = "绑定机具";
    String type = pageData["field"] ?? "";
    switch (type) {
      case "bounsData":
        headTitle = "累计收益";
        unit = "元";
        break;
      case "tradeData":
        headTitle = "本月交易";
        unit = "元";
        break;
      case "tradeTeamData":
        headTitle = "累计交易";
        unit = "元";
        break;
      case "activData":
        headTitle = "绑定机具";
        unit = "台";
        break;
    }

    Widget mcWidget;
    Color color = const Color(0xFF525C66);
    if (!isHead && index < 3) {
      switch (index) {
        case 0:
          color = const Color(0xFF2E07F0);
          break;
        case 1:
          color = const Color(0xFF027EFA);
          break;
        case 2:
          color = const Color(0xFFFFB300);
          break;
      }

      mcWidget = Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                assetsName("rank/icon_text${index + 1}"),
                height: 26.w,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Positioned(
            left: 16.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                assetsName("rank/icon_jz${index + 1}"),
                height: 32.w,
                fit: BoxFit.fitHeight,
              ),
            ),
          )
        ],
      );

      // Row(
      //   children: [
      //     Image.asset(
      //       assetsName("rank/icon_text${index + 1}"),
      //       height: 22.w,
      //       fit: BoxFit.fitHeight,
      //     ),
      //     Image.asset(
      //       assetsName("rank/icon_jz${index + 1}"),
      //       height: 18.w,
      //       fit: BoxFit.fitHeight,
      //     ),
      //   ],
      // );
    } else {
      mcWidget = getSimpleText(
          isHead ? "名次" : "${index + 1}", 16, const Color(0xFF525C66));
    }

    return Container(
        margin: EdgeInsets.only(top: isHead ? 0 : 6.w),
        width: 345.w,
        height: isHead ? 32.w : 42.w,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFE9EDF5),
                  blurRadius: 25.5.w,
                  offset: Offset(0, 8.5.w))
            ]),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              gwb(16),
              SizedBox(
                width: 55.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: mcWidget,
                ),
              ),
              SizedBox(
                width: 100.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: getSimpleText(
                      isHead ? "用户名" : "${data["u_Name"] ?? ""}", 16, color),
                ),
              ),
              SizedBox(
                width: 158.w,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: getSimpleText(
                      isHead ? headTitle : "${data["num"] ?? 0}$unit",
                      16,
                      color),
                ),
              ),
            ],
          ),
        ));
  }

  Widget topHead(int index, Map data) {
    String imgHg = "icon_hg$index";
    String imgNo = "icon_n$index";

    bool haveData = data.isNotEmpty;

    return SizedBox(
      width: 96.w,
      height: 126.w,
      child: Stack(
        children: [
          Positioned(
              top: 8.w,
              left: 12.w,
              width: 74.w,
              height: 74.w,
              child: Container(
                decoration: BoxDecoration(
                    image: haveData
                        ? DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(AppDefault().imageUrl +
                                (data["u_Avatar"] ?? "")))
                        : null,
                    borderRadius: BorderRadius.circular(37.w),
                    color: Colors.black26,
                    border: Border.all(
                        width: 2.w,
                        color: index == 0
                            ? const Color(0xFFFFEA7C)
                            : index == 1
                                ? const Color(0xFFFFFCFC)
                                : const Color(0xFFFEDDCA))),
              )),
          Positioned(
            top: 0,
            left: 5.w,
            child: Image.asset(
              assetsName("rank/$imgHg"),
              width: 30.w,
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
              top: 68.w,
              left: 0,
              child: Image.asset(
                assetsName("rank/$imgNo"),
                width: 96.w,
                fit: BoxFit.fitWidth,
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 20.w,
              child: Center(
                child: getSimpleText(data["u_Name"] ?? "", 16, Colors.white,
                    fw: FontWeight.w700),
              ))
        ],
      ),
    );
  }
}
