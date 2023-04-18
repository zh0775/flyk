import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/fodderlib/fodder_lib_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BusinessSchoolCollectBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<BusinessSchoolCollectController>(BusinessSchoolCollectController());
  }
}

class BusinessSchoolCollectController extends GetxController {
  bool isFirst = true;

  String topSectionBuildId = "BusinessSchoolListController_topSectionBuildId";
  String infoListBuildId = "BusinessSchoolListController_infoListBuildId";

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (isPageAnimate) {
      return;
    }
    if (_topIndex.value != v) {
      _topIndex.value = v;
      loadData(loadIdx: topIndex);
      changePage(topIndex);
    }
  }

  List listStatus = [
    {"id": 2, "name": "文章"},
    {"id": 1, "name": "素材"},
  ];

  bool isPageAnimate = false;

  changePage(int? toIdx) {
    if (isPageAnimate) {
      return;
    }
    isPageAnimate = true;
    int idx = toIdx ?? topIndex;
    pageCtrl
        .animateToPage(idx,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut)
        .then((value) {
      isPageAnimate = false;
    });
  }

  PageController pageCtrl = PageController();

  List<int> pageSizes = [
    20,
    20,
  ];
  List<int> pageNos = [
    1,
    1,
  ];
  List<int> counts = [
    0,
    0,
  ];
  List<RefreshController> pullCtrls = [
    RefreshController(),
    RefreshController(),
  ];
  List<List> dataLists = [
    [],
    [],
  ];

  onRefresh(int refreshIdx) {
    loadData(loadIdx: refreshIdx);
  }

  onLoad(int loadIdx) {
    loadData(isLoad: true, loadIdx: loadIdx);
  }

  String loadListBuildId = "BusinessSchoolCollect_loadListBuildId_";

  loadData({bool isLoad = false, int? loadIdx, String? searchText}) {
    int myLoadIdx = loadIdx ?? topIndex;
    isLoad ? pageNos[myLoadIdx]++ : pageNos[myLoadIdx] = 1;
    if (dataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "pageNo": pageNos[myLoadIdx],
      "pageSize": pageSizes[myLoadIdx],
      "type": listStatus[myLoadIdx]["id"],
    };
    // if (searchText != null && searchText.isNotEmpty) {
    //   params["devNo"] = searchText;
    // }
    simpleRequest(
      url: Urls.userShareCollectionList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myLoadIdx] = data["count"] ?? 0;
          List mDatas = data["data"] ?? [];
          dataLists[myLoadIdx] =
              isLoad ? [...dataLists[myLoadIdx], ...mDatas] : mDatas;
          isLoad
              ? pullCtrls[myLoadIdx].loadComplete()
              : pullCtrls[myLoadIdx].refreshCompleted();
          update(["$loadListBuildId$myLoadIdx"]);
        } else {
          isLoad
              ? pullCtrls[myLoadIdx].loadFailed()
              : pullCtrls[myLoadIdx].refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  cancelCollect(int index, int listIdx) {
    simpleRequest(
      url: Urls.userDelShareCollection(dataLists[listIdx][index]["collectId"]),
      params: {},
      success: (success, json) {
        if (success) {
          ShowToast.normal("取消收藏成功");
          loadData();
        }
      },
      after: () {},
    );
  }

  // loadListData({bool isLoad = false,int? loadIdx}) {
  //   if (isLoad) {
  //     pageNos[currentPageIndex] += 1;
  //   } else {
  //     pageNos[currentPageIndex] = 1;
  //   }
  //   if (datasList[currentPageIndex] == null ||
  //       datasList[currentPageIndex].isEmpty) {
  //     isLoading = true;
  //   }
  //   simpleRequest(
  //     url: Urls.userShareCollectionList,
  //     params: {
  //       // "classId": sectionList[currentPageIndex]["id"],
  //       "type": 2,
  //       "pageNo": pageNos[currentPageIndex],
  //       "pageSize": pageSizes[currentPageIndex],
  //     },
  //     success: (success, json) {
  //       Map data = json["data"];
  //       if (success) {
  //         counts[currentPageIndex] = data["count"];
  //         if (isLoad) {
  //           datasList[currentPageIndex] = [
  //             ...datasList[currentPageIndex],
  //             ...data["data"]
  //           ];
  //           pullCtrl.loadComplete();
  //         } else {
  //           pullCtrl.refreshCompleted();
  //           datasList[currentPageIndex] = data["data"];
  //         }
  //         update([infoListBuildId]);
  //       } else {
  //         if (isLoad) {
  //           pullCtrl.loadFailed();
  //         } else {
  //           pullCtrl.refreshFailed();
  //         }
  //       }
  //     },
  //     after: () {
  //       isLoading = false;
  //     },
  //   );
  // }

  RefreshController pullCtrl = RefreshController();
  late PageController pageController;
  Map publicHomeData = {};

  @override
  void onInit() {
    // publicHomeData = AppDefault().publicHomeData;
    // if (publicHomeData.isNotEmpty) {
    //   sectionList = publicHomeData["appHelpRule"]["businessSchool"];
    //   for (var item in sectionList) {
    //     counts.add(0);
    //     pageNos.add(1);
    //     pageSizes.add(10);
    //     datasList.add([]);
    //   }
    // }
    loadData();
    super.onInit();
  }

  @override
  void dispose() {
    pullCtrl.dispose();
    pageController.dispose();
    super.dispose();
  }
}

class BusinessSchoolCollect extends GetView<BusinessSchoolCollectController> {
  final int? defaultIndex;
  const BusinessSchoolCollect({Key? key, this.defaultIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "我的收藏"),
        body: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 55.w,
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Positioned(
                          top: 20.w,
                          left: 0,
                          right: 0,
                          height: 20.w,
                          child: Row(
                            children: List.generate(
                                controller.listStatus.length, (index) {
                              return CustomButton(
                                onPressed: () {
                                  controller.topIndex = index;
                                },
                                child: GetX<BusinessSchoolCollectController>(
                                    builder: (_) {
                                  return SizedBox(
                                    width:
                                        375.w / controller.listStatus.length -
                                            0.1.w,
                                    child: Center(
                                      child: getSimpleText(
                                        controller.listStatus[index]["name"],
                                        15,
                                        controller.topIndex == index
                                            ? AppColor.theme
                                            : AppColor.text2,
                                        isBold: controller.topIndex == index,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          )),
                      GetX<BusinessSchoolCollectController>(
                        builder: (_) {
                          return AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              top: 47.w,
                              width: 15.w,
                              left: controller.topIndex *
                                      (375.w / controller.listStatus.length -
                                          0.1.w) +
                                  ((375.w / controller.listStatus.length -
                                              0.1.w) -
                                          15.w) /
                                      2,
                              height: 2.w,
                              child: Container(
                                color: AppColor.theme,
                              ));
                        },
                      )
                    ],
                  ),
                )),
            Positioned.fill(
                top: 55.w,
                child: PageView.builder(
                  controller: controller.pageCtrl,
                  itemCount: controller.dataLists.length,
                  onPageChanged: (value) {
                    controller.topIndex = value;
                  },
                  itemBuilder: (context, index) {
                    return list(index);
                  },
                ))
          ],
        ));
  }

  Widget list(int listIdx) {
    return GetBuilder<BusinessSchoolCollectController>(
      id: "${controller.loadListBuildId}$listIdx",
      builder: (_) {
        return SmartRefresher(
          controller: controller.pullCtrls[listIdx],
          onLoading: () => controller.onLoad(listIdx),
          onRefresh: () => controller.onRefresh(listIdx),
          enablePullUp:
              controller.counts[listIdx] > controller.dataLists[listIdx].length,
          child: controller.dataLists[listIdx].isEmpty
              ? GetX<BusinessSchoolCollectController>(
                  builder: (_) {
                    return CustomEmptyView(
                      isLoading: controller.isLoading,
                    );
                  },
                )
              : ListView.builder(
                  itemCount: controller.dataLists[listIdx].length,
                  padding: EdgeInsets.only(bottom: 20.w, top: 6.w),
                  itemBuilder: (context, index) {
                    return cell(
                        index, controller.dataLists[listIdx][index], listIdx);
                  },
                ),
        );
      },
    );
  }

  Widget articleCell(int index, Map data, int listIdx) {
    return SwipeActionCell(
      key: ObjectKey(data),
      trailingActions: <SwipeAction>[
        SwipeAction(
            // title: "取\n消\n收\n藏",
            widthSpace: 45.w,

            // style: TextStyle(
            //   fontSize: 15.sp,
            //   color: Colors.white,
            // ),
            content: Text(
              "取\n消\n收\n藏",
              maxLines: 4,
              style:
                  TextStyle(fontSize: 15.sp, color: Colors.white, height: 1.3),
            ),
            onTap: (CompletionHandler handler) async {
              handler(false);
              showAlert(
                Global.navigatorKey.currentContext!,
                "是否确定取消收藏",
                confirmOnPressed: () {
                  Get.back();
                  controller.cancelCollect(index, listIdx);
                },
              );
              // controller.dataLists[listIdx].removeAt(listIdx);
              // controller.update([controller.infoListBuildId]);
            },
            color: const Color(0xFFFB5252)),
      ],
      child: CustomButton(
          onPressed: () {
            push(const FodderLibDetail(), null,
                binding: FodderLibDetailBinding(),
                arguments: {
                  "type": listIdx == 0 ? 2 : 1,
                  "data": data,
                  "collect": true,
                  "updateList": () {
                    controller.loadData();
                  }
                });
          },
          child: centClm([
            Container(
              width: 375.w,
              height: 106.w,
              color: Colors.white,
              alignment: Alignment.center,
              child: sbhRow([
                sbClm([
                  getWidthText(data["title"] ?? "", 15, AppColor.text2,
                      345 - 100 - 20, 2),
                  centRow([
                    Image.asset(
                      assetsName("common/icon_lookcount"),
                      width: 18.w,
                    ),
                    gwb(2),
                    getWidthText(
                        "${data["view"] ?? 0}", 12, AppColor.text3, 35, 1,
                        textHeight: 1.25),
                    Image.asset(
                      assetsName("common/icon_addtime"),
                      width: 18.w,
                    ),
                    gwb(2),
                    getSimpleText(data["addTime"] ?? "", 12, AppColor.text3,
                        textHeight: 1.25)
                  ]),
                ], height: 77, crossAxisAlignment: CrossAxisAlignment.start),
                CustomNetworkImage(
                  src: AppDefault().imageUrl + (data["coverImg"] ?? ""),
                  width: 100.w,
                  height: 77.w,
                  fit: BoxFit.cover,
                ),
              ], width: 345, height: 106),
            ),
            gline(345, 0.5),
          ])),
    );
  }

  Widget fodderCell(int index, Map data, int listIdx) {
    return CustomButton(
      onPressed: () {
        push(const FodderLibDetail(), null,
            binding: FodderLibDetailBinding(),
            arguments: {
              "type": listIdx == 0 ? 2 : 1,
              "data": data,
              "collect": true,
              "updateList": () {
                controller.loadData();
              }
            });
      },
      child: Container(
        width: 375.w,
        height: 135.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(width: 0.5.w, color: AppColor.lineColor))),
        child: sbhRow([
          CustomButton(
            onPressed: () {
              showAlert(
                Global.navigatorKey.currentContext!,
                "是否确定取消收藏",
                confirmOnPressed: () {
                  Get.back();
                  controller.cancelCollect(index, listIdx);
                },
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.w),
              child: SizedBox(
                width: 105.w,
                height: 105.w,
                child: Stack(children: [
                  Positioned.fill(
                      child: CustomNetworkImage(
                    src: AppDefault().imageUrl + (data["coverImg"] ?? ""),
                    width: 105.w,
                    height: 105.w,
                    fit: BoxFit.cover,
                  )),
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 24.w,
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.black.withOpacity(0.3),
                        child: centRow([
                          Image.asset(
                            assetsName("home/fodderlib/btn_sc_white"),
                            width: 15.w,
                            fit: BoxFit.fitWidth,
                          ),
                          gwb(3),
                          getSimpleText("取消收藏", 12, Colors.white),
                        ]),
                      ))
                ]),
              ),
            ),
          ),
          sbClm([
            getWidthText(data["title"], 15, AppColor.text2, 224, 2),
            centClm([
              getSimpleText("下载次数：1次", 12, AppColor.text3),
              getSimpleText(
                  "上传时间：${data["addTime"] ?? ""}", 12, AppColor.text3),
            ], crossAxisAlignment: CrossAxisAlignment.start)
          ], height: 105, crossAxisAlignment: CrossAxisAlignment.start)
        ], width: 345, height: 135),
      ),
    );
  }

  Widget cell(int index, Map data, int listIdx) {
    return listIdx == 0
        ? articleCell(index, data, listIdx)
        : fodderCell(index, data, listIdx);
  }
}
