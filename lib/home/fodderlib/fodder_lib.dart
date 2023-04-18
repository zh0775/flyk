import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/fodderlib/fodder_lib_detail.dart';
import 'package:cxhighversion2/home/fodderlib/fodder_lib_search.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FodderLibBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<FodderLibController>(FodderLibController());
  }
}

class FodderLibController extends GetxController {
  final dynamic datas;
  FodderLibController({this.datas});

  RefreshController pullCtrl = RefreshController();
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  String frameAndTopBuild = "FodderLibController_frameAndTopBuild";

  final _filterIdx = 0.obs;
  int get filterIdx => _filterIdx.value;
  set filterIdx(v) {
    if (_filterIdx.value != v) {
      _filterIdx.value = v;
      if (filterIdx == 0) {
        uploadSort = -1;
        downloadSort = -1;
      } else if (filterIdx == 1) {
        allSort = -1;
        downloadSort = -1;
      } else if (filterIdx == 2) {
        allSort = -1;
        uploadSort = -1;
      }
    }
  }

  final _allSort = (-1).obs;
  int get allSort => _allSort.value;
  set allSort(v) => _allSort.value = v;

  final _uploadSort = (-1).obs;
  int get uploadSort => _uploadSort.value;
  set uploadSort(v) => _uploadSort.value = v;

  final _downloadSort = (-1).obs;
  int get downloadSort => _downloadSort.value;
  set downloadSort(v) => _downloadSort.value = v;

  List choicenessList = [];

  int topCount = 0;
  int topPageSize = 20;
  int topPageNo = 1;

  List dataList = [];

  int count = 0;
  int pageSize = 20;
  int pageNo = 1;

  loadTop({bool isLoad = false}) {
    isLoad ? topPageNo++ : topPageNo = 1;
    simpleRequest(
      url: Urls.newList,
      params: {
        "classType": 2,
        "pageSize": topPageSize,
        "pageNo": topPageNo,
        "nOrderTime": -1,
        "nOrderDownload": -1,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          topCount = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];
          choicenessList = isLoad ? [...choicenessList, ...tmpList] : tmpList;
          update([frameAndTopBuild]);
        }
      },
      after: () {},
    );
  }

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;

    // Future.delayed(const Duration(milliseconds: 500), () {
    //   choicenessList = [{}, {}, {}];
    //   update([frameAndTopBuild]);
    // });
    if (dataList.isEmpty) {
      isLoading = true;
    }

    Map<String, dynamic> params = {
      "classType": 1,
      "description": "",
      "pageSize": pageSize,
      "pageNo": pageNo,
    };
    if (filterIdx == 0) {
      params["nOrderTime"] = -1;
      params["nOrderDownload"] = -1;
    } else if (filterIdx == 1) {
      params["nOrderTime"] = uploadSort == 0 ? 1 : 0;
      params["nOrderDownload"] = -1;
    } else if (filterIdx == 2) {
      params["nOrderTime"] = -1;
      params["nOrderDownload"] = downloadSort == 0 ? 1 : 0;
    }
    simpleRequest(
      url: Urls.newList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];

          dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
          update();
          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  @override
  void onInit() {
    loadTop();
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    pullCtrl.dispose();
    super.onClose();
  }
}

class FodderLib extends GetView<FodderLibController> {
  final bool isSearch;
  const FodderLib({super.key, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "素材库", action: [
        CustomButton(
          onPressed: () {
            push(const FodderLibSearch(), context,
                binding: FodderLibSearchBinding());
          },
          child: SizedBox(
            height: kToolbarHeight,
            width: 50.w,
            child: Center(
              child: Image.asset(
                assetsName("common/btn_navi_search"),
                width: 24.w,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        )
      ]),
      body: Stack(
        children: [
          GetBuilder<FodderLibController>(
            id: controller.frameAndTopBuild,
            builder: (_) {
              return controller.choicenessList.isEmpty
                  ? gemp()
                  : Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 165.w,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                top: BorderSide(
                                    width: 1.w,
                                    color: AppColor.pageBackgroundColor))),
                        child: Column(
                          children: [
                            gwb(375),
                            sbhRow([
                              getSimpleText("精选素材", 16, AppColor.text,
                                  isBold: true),
                            ], width: 345, height: 49),
                            SizedBox(
                              height: 97.w,
                              width: 375.w,
                              child: EasyRefresh.builder(
                                onLoad: controller.topCount <=
                                        controller.choicenessList.length
                                    ? null
                                    : () => controller.loadTop(isLoad: true),
                                onRefresh: () => controller.loadTop(),
                                childBuilder: (context, physics) {
                                  return ListView.builder(
                                    physics: physics,
                                    padding: EdgeInsets.only(right: 20.w),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller.choicenessList.length,
                                    itemBuilder: (context, index) {
                                      Map data =
                                          controller.choicenessList[index];
                                      return Padding(
                                        padding: EdgeInsets.only(left: 15.w),
                                        child: CustomButton(
                                          onPressed: () {
                                            push(const FodderLibDetail(),
                                                context,
                                                binding:
                                                    FodderLibDetailBinding(),
                                                arguments: {
                                                  "type": 1,
                                                  "data": data,
                                                  "updateList": () {
                                                    controller.loadData();
                                                  }
                                                });
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4.w),
                                            child: CustomNetworkImage(
                                              src: AppDefault().imageUrl +
                                                  (data["bgImg"] ?? ""),
                                              // margin: EdgeInsets.only(left: 15.w),
                                              width: 144.w,
                                              height: 97.w,
                                              fit: BoxFit.cover,
                                              errorColor:
                                                  AppColor.pageBackgroundColor,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ));
            },
          ),
          GetBuilder<FodderLibController>(
            id: controller.frameAndTopBuild,
            builder: (_) {
              return Positioned(
                top: controller.choicenessList.isEmpty ? 0 : 180.w,
                left: 0,
                right: 0,
                height: 55.w,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                              width: 1.w,
                              color: AppColor.pageBackgroundColor))),
                  child: sbhRow(
                      List.generate(3, (index) {
                        String title = "";

                        switch (index) {
                          case 0:
                            title = "综合排序";

                            break;
                          case 1:
                            title = "最新上传";

                            break;
                          case 2:
                            title = "下载最多";

                            break;
                        }

                        return CustomButton(
                          onPressed: () {
                            controller.filterIdx = index;
                            if (index == 0) {
                              if (controller.allSort == -1) {
                                controller.allSort = 0;
                              }
                              //  else if (controller.allSort == 0) {
                              //   controller.allSort = 1;
                              // } else {
                              //   controller.allSort = 0;
                              // }
                            } else if (index == 1) {
                              if (controller.uploadSort == -1) {
                                controller.uploadSort = 0;
                              } else if (controller.uploadSort == 0) {
                                controller.uploadSort = 1;
                              } else {
                                controller.uploadSort = 0;
                              }
                            } else if (index == 2) {
                              if (controller.downloadSort == -1) {
                                controller.downloadSort = 0;
                              } else if (controller.downloadSort == 0) {
                                controller.downloadSort = 1;
                              } else {
                                controller.downloadSort = 0;
                              }
                            }

                            controller.loadData();
                          },
                          child: GetX<FodderLibController>(
                            builder: (_) {
                              return SizedBox(
                                height: 55.w,
                                child: centRow([
                                  getSimpleText(
                                      title,
                                      15,
                                      controller.filterIdx == index
                                          ? AppColor.text2
                                          : AppColor.text3,
                                      isBold: controller.filterIdx == index),
                                  gwb(3),
                                  GetX<FodderLibController>(
                                    builder: (controller) {
                                      double turns = 0.5;
                                      if (index == 0 &&
                                          (controller.allSort == -1 ||
                                              controller.allSort == 0)) {
                                        turns = 1.0;
                                      } else if (index == 1 &&
                                          (controller.uploadSort == -1 ||
                                              controller.uploadSort == 0)) {
                                        turns = 1.0;
                                      } else if (index == 2 &&
                                          (controller.downloadSort == -1 ||
                                              controller.downloadSort == 0)) {
                                        turns = 1.0;
                                      }

                                      return AnimatedRotation(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        turns: turns,
                                        child: Image.asset(
                                          assetsName(
                                              "statistics/machine/icon_filter_down_${controller.filterIdx == index ? "selected" : "normal"}_arrow"),
                                          width: 6.w,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      );
                                    },
                                  )
                                ]),
                              );
                            },
                          ),
                        );
                      }),
                      height: 55.w,
                      width: 375 - 28 * 2),
                ),
              );
            },
          ),
          GetBuilder<FodderLibController>(
            id: controller.frameAndTopBuild,
            builder: (_) {
              return Positioned.fill(
                  top: controller.choicenessList.isEmpty ? 55.w : 180.w + 55.w,
                  child: Container(
                    color: Colors.white,
                    child: GetBuilder<FodderLibController>(
                      builder: (_) {
                        return SmartRefresher(
                          controller: controller.pullCtrl,
                          onLoading: () => controller.loadData(isLoad: true),
                          onRefresh: () => controller.loadData(),
                          enablePullUp:
                              controller.count > controller.dataList.length,
                          child: controller.dataList.isEmpty
                              ? GetX<FodderLibController>(
                                  builder: (_) {
                                    return CustomEmptyView(
                                      isLoading: controller.isLoading,
                                    );
                                  },
                                )
                              : ListView.builder(
                                  itemCount:
                                      (controller.dataList.length / 2).ceil(),
                                  itemBuilder: (context, index) {
                                    return cell(index);
                                  },
                                ),
                        );
                      },
                    ),
                  ));
            },
          )
        ],
      ),
    );
  }

  Widget cell(int index) {
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 15.w : 0),
      child: Center(
        child: sbRow(
            List.generate(2, (idx) {
              Map data = {};
              if (index * 2 + idx <= controller.dataList.length - 1) {
                data = controller.dataList[index * 2 + idx];
              }

              return data.isEmpty
                  ? gwb(0)
                  : CustomButton(
                      onPressed: () {
                        push(const FodderLibDetail(), null,
                            binding: FodderLibDetailBinding(),
                            arguments: {
                              "type": 2,
                              "data": data,
                              "updateList": () {
                                controller.loadData();
                              }
                            });
                      },
                      child: centClm([
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.w),
                          child: CustomNetworkImage(
                            src: AppDefault().imageUrl + (data["bgImg"] ?? ""),
                            width: 165.w,
                            height: 165.w,
                            fit: BoxFit.cover,
                            errorColor: AppColor.pageBackgroundColor,
                          ),
                        ),
                        SizedBox(
                          width: 165.w,
                          height: 60.w,
                          child: Column(
                            children: [
                              ghb(10),
                              getWidthText(data["title"] ?? "", 15,
                                  AppColor.text2, 165, 2)
                            ],
                          ),
                        )
                      ]),
                    );
            }),
            width: 345),
      ),
    );
  }
}
