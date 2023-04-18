import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/businessSchool/business_school_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BusinessSchoolListPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<BusinessSchoolListPageController>(
        BusinessSchoolListPageController(datas: Get.arguments));
  }
}

class BusinessSchoolListPageController extends GetxController {
  final dynamic datas;
  BusinessSchoolListPageController({this.datas});

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
      if (pageCtrl.positions.isEmpty) {
        return;
      }
      loadData(loadIdx: topIndex);
      changePage(topIndex);
    }
  }

  List listStatus = [
    {"id": -1, "name": "操作指南"},
    {"id": 0, "name": "注册流程"},
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

  late PageController pageCtrl;

  List<int> pageSizes = [];
  List<int> pageNos = [];
  List<int> counts = [];
  List<RefreshController> pullCtrls = [];
  List<List> dataLists = [];

  onRefresh(int refreshIdx) {
    loadData(loadIdx: refreshIdx);
  }

  onLoad(int loadIdx) {
    loadData(isLoad: true, loadIdx: loadIdx);
  }

  String loadListBuildId = "InformationDetail_loadListBuildId_";

  loadData({bool isLoad = false, int? loadIdx, String? searchText}) {
    int myLoadIdx = loadIdx ?? topIndex;
    isLoad ? pageNos[myLoadIdx]++ : pageNos[myLoadIdx] = 1;
    if (dataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "pageNo": pageNos[myLoadIdx],
      "pageSize": pageSizes[myLoadIdx],
    };
    if (type == 0) {
      params["classId"] = listStatus[myLoadIdx]["id"] ?? 0;
    } else {
      params["classType"] = 3;
    }

    // if (searchText != null && searchText.isNotEmpty) {
    //   params["devNo"] = searchText;
    // }
    simpleRequest(
      url: type == 0 ? Urls.userBusinessSchoolList : Urls.newList,
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

    // Future.delayed(const Duration(milliseconds: 200), () {
    //   counts[myLoadIdx] = 100;
    //   List datas = [];
    //   for (var i = 0; i < pageSizes[myLoadIdx]; i++) {
    //     datas.add({
    //       "id": dataLists[myLoadIdx].length + i,
    //       "type": i % 2,
    //       "addTime": "2023-02-13 20:21:20",
    //       "no": "2102523020156150",
    //       "reason": "设备无响应，无法开机",
    //       "status": i % 4,
    //       "toMe": i % 3,
    //       "userImg": "D0031/2023/2/20230201214710P4FVH.jpg",
    //       "userName": "李文敏",
    //       "ono": "2523020156150123",
    //       "nno": "2523020156150125",
    //       "machine": {
    //         "id": 123,
    //         "img": "D0031/2023/1/202301311856422204X.png",
    //         "name": "嘉联电签K300",
    //         "tNo": "T550006698",
    //         "status": 0,
    //         "addTime": "2020-01-23 13:26:09",
    //       }
    //     });
    //   }

    //   dataLists[myLoadIdx] =
    //       isLoad ? [...dataLists[myLoadIdx], ...datas] : datas;
    //   update(["$loadListBuildId$myLoadIdx"]);
    //   isLoad
    //       ? pullCtrls[myLoadIdx].loadComplete()
    //       : pullCtrls[myLoadIdx].refreshCompleted();
    //   isLoading = false;
    // });
  }

  backoutAction(Map data) {
    simpleRequest(
      url: Urls.featuresOverRefuse(data["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadData();
        }
      },
      after: () {},
    );
  }

  agreeAction(Map data) {
    loadData();
  }

  rejectAction(Map data) {
    simpleRequest(
      url: Urls.featuresWithdraw(data["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadData();
        }
      },
      after: () {},
    );
  }

  // List
  bool isFirst = true;
  // 0: 商学院 1: 金融区相关资讯
  int type = 0;

  @override
  void onInit() {
    type = (datas ?? {})["type"] ?? 0;
    if (type == 0) {
      listStatus = (AppDefault().publicHomeData["appHelpRule"] ??
              {})["businessSchool"] ??
          [];
    } else if (type == 1) {
      listStatus = [{}];
    }

    counts = [];
    pageNos = [];
    pageSizes = [];
    dataLists = <List>[];
    pullCtrls = <RefreshController>[];
    for (var item in listStatus) {
      counts.add(0);
      pageNos.add(1);
      pageSizes.add(10);
      dataLists.add([]);
      pullCtrls.add(RefreshController());
    }
    int index = (datas ?? {})["index"] ?? 0;

    pageCtrl = PageController(initialPage: index);
    topIndex = index;

    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    for (var e in pullCtrls) {
      e.dispose();
    }
    pageCtrl.dispose();
    super.onClose();
  }
}

class BusinessSchoolListPage extends GetView<BusinessSchoolListPageController> {
  const BusinessSchoolListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(
          context,
          controller.type == 0 ? "商学院" : "相关资讯",
        ),
        body: Stack(
          children: [
            controller.type == 1
                ? gemp()
                : Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 55.w,
                    child: Container(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 46.w,
                              child: Row(
                                children: List.generate(
                                    controller.listStatus.length, (index) {
                                  return CustomButton(
                                    onPressed: () {
                                      controller.topIndex = index;
                                    },
                                    child: Column(
                                      children: [
                                        ghb(20),
                                        GetX<BusinessSchoolListPageController>(
                                            builder: (_) {
                                          return SizedBox(
                                            width: 375.w /
                                                    controller
                                                        .listStatus.length -
                                                0.1.w,
                                            child: Center(
                                              child: getSimpleText(
                                                controller.listStatus[index]
                                                    ["name"],
                                                15,
                                                controller.topIndex == index
                                                    ? AppColor.theme
                                                    : AppColor.text2,
                                                isBold: controller.topIndex ==
                                                    index,
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                }),
                              )),
                          GetX<BusinessSchoolListPageController>(
                            builder: (_) {
                              return AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  top: 46.w,
                                  width: 15.w,
                                  left: controller.topIndex *
                                          (375.w /
                                                  controller.listStatus.length -
                                              0.1.w) +
                                      ((375.w / controller.listStatus.length -
                                                  0.1.w) -
                                              15.w) /
                                          2,
                                  height: 9.w,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(0.5.w),
                                        color: AppColor.theme,
                                      ),
                                      height: 2.w,
                                    ),
                                  ));
                            },
                          )
                        ],
                      ),
                    )),
            Positioned.fill(
                top: controller.type == 1 ? 0 : 55.w,
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
        ),
      ),
    );
  }

  Widget list(int listIdx) {
    return GetBuilder<BusinessSchoolListPageController>(
      id: "${controller.loadListBuildId}$listIdx",
      builder: (_) {
        return SmartRefresher(
          controller: controller.pullCtrls[listIdx],
          onLoading: () => controller.onLoad(listIdx),
          onRefresh: () => controller.onRefresh(listIdx),
          enablePullUp:
              controller.counts[listIdx] > controller.dataLists[listIdx].length,
          child: controller.dataLists[listIdx].isEmpty
              ? GetX<BusinessSchoolListPageController>(
                  builder: (_) {
                    return CustomEmptyView(
                      isLoading: controller.isLoading,
                    );
                  },
                )
              : ListView.builder(
                  itemCount: controller.dataLists[listIdx].length,
                  padding: EdgeInsets.only(bottom: 20.w),
                  itemBuilder: (context, index) {
                    return listIdx == 3
                        ? cell2(index, controller.dataLists[listIdx][index],
                            listIdx)
                        : cell(index, controller.dataLists[listIdx][index],
                            listIdx);
                  },
                ),
        );
      },
    );
  }

  Widget cell2(int index, Map data, int listIdx) {
    return CustomButton(
      onPressed: () {
        push(BusinessSchoolDetail(id: data["id"]), null,
            binding: BusinessSchoolDetailBinding(),
            arguments: {"type": controller.type, "data": data});
      },
      child: Container(
          width: 375.w,
          height: 250.w,
          margin: EdgeInsets.only(top: index == 0 ? 6.w : 0),
          color: Colors.white,
          child: Column(
            children: [
              ghb(15),
              SizedBox(
                width: 345.w,
                height: 171.w,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.w),
                        child: CustomNetworkImage(
                          src: AppDefault().imageUrl + (data["coverImg"] ?? ""),
                          width: 345.w,
                          height: 171.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                        left: 13.5.w,
                        bottom: 6.w,
                        child: centRow([
                          Image.asset(
                            assetsName("common/icon_lookcount"),
                            width: 18.w,
                          ),
                          gwb(2),
                          getWidthText(
                              "${data["view"] ?? 0}", 12, Colors.white, 35, 1,
                              textHeight: 1.25)
                        ])),
                    data["audio"] != null && data["audio"].isNotEmpty
                        ? Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              assetsName("common/btn_video_play"),
                              width: 26.w,
                              fit: BoxFit.fitWidth,
                            ),
                          )
                        : gemp(),
                  ],
                ),
              ),
              ghb(13),
              getWidthText(data["title"] ?? "", 15, AppColor.text2, 345, 2,
                  isBold: true),
              ghb(8),
              sbRow([
                centRow([
                  Image.asset(
                    assetsName("common/icon_addtime"),
                    width: 18.w,
                  ),
                  gwb(2),
                  getSimpleText(data["addTime"] ?? "", 12, AppColor.text3,
                      textHeight: 1.25)
                ])
              ], width: 345)
            ],
          )),
    );
  }

  Widget cell(int index, Map data, int listIdx) {
    return Align(
      child: CustomButton(
        onPressed: () {
          push(BusinessSchoolDetail(id: data["id"]), null,
              binding: BusinessSchoolDetailBinding(),
              arguments: {"type": controller.type, "data": data});
        },
        child: Container(
          margin: EdgeInsets.only(top: index == 0 ? 6.w : 0),
          width: 375.w,
          color: Colors.white,
          // height: maintainStatus == 0 ? 180.w : 165.w,

          child: Column(
            children: [
              ghb(15),
              sbhRow([
                sbClm([
                  getWidthText(
                      controller.type == 0
                          ? (data["title"] ?? "")
                          : ((data["meta"] ?? "")),
                      15,
                      AppColor.text2,
                      224,
                      2,
                      isBold: true),
                  centRow([
                    Image.asset(
                      assetsName("common/icon_lookcount"),
                      width: 18.w,
                    ),
                    gwb(2),
                    getWidthText(
                        "${data[controller.type == 0 ? "view" : "viewNum"] ?? 0}",
                        12,
                        AppColor.text3,
                        35,
                        1,
                        textHeight: 1.25),
                    Image.asset(
                      assetsName("common/icon_addtime"),
                      width: 18.w,
                    ),
                    gwb(2),
                    getSimpleText(data["addTime"] ?? "", 12, AppColor.text3,
                        textHeight: 1.25)
                  ])
                ], height: 77, crossAxisAlignment: CrossAxisAlignment.start),
                SizedBox(
                  width: 100.w,
                  height: 77.w,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: CustomNetworkImage(
                        src: AppDefault().imageUrl +
                            (controller.type == 0
                                ? (data["coverImg"] ?? "")
                                : (data["bgImg"] ?? "")),
                        width: 100.w,
                        height: 77.w,
                        fit: BoxFit.cover,
                      )),
                      data["audio"] != null && data["audio"].isNotEmpty
                          ? Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                assetsName("common/btn_video_play"),
                                width: 26.w,
                                fit: BoxFit.fitWidth,
                              ),
                            )
                          : gemp(),
                    ],
                  ),
                )
              ], width: 345, height: 77),
              ghb(14),
              gline(315, 0.5),
            ],
          ),
        ),
      ),
    );
  }
}
