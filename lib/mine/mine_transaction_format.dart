import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MineTransactionFormatBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineTransactionFormatController>(MineTransactionFormatController());
  }
}

class MineTransactionFormatController extends GetxController {
  List dataList = [[], [], [], []];
  List pageNos = [1, 1, 1, 1];
  List pageSizes = [10, 10, 10, 10];
  List counts = [0, 0, 0, 0];
  List pullCtrls = [
    RefreshController(),
    RefreshController(),
    RefreshController(),
    RefreshController(),
  ];

  bool isAnimation = false;

  changePage(int index) {
    if (isAnimation) {
      return;
    }
    isAnimation = true;
    pageCtrl
        .animateToPage(index,
            duration: const Duration(milliseconds: 300), curve: Curves.linear)
        .then((value) {
      isAnimation = false;
    });
  }

  final pageCtrl = PageController();

  final _pageIndex = 0.obs;
  int get pageIndex => _pageIndex.value;
  set pageIndex(v) {
    if (!isAnimation) {
      _pageIndex.value = v;
      loadList(pageIndex);
      changePage(pageIndex);
    }
  }

  final _isLoadding = false.obs;
  bool get isLoadding => _isLoadding.value;
  set isLoadding(v) => _isLoadding.value = v;

  passOrRejectRequest(bool pass, dynamic id,
      {bool overReject = false, bool back = false}) {
    String url = "";
    if (back) {
      url = Urls.userFeaturesWithdraw(id);
    } else if (overReject) {
      url = Urls.userFeaturesOverRefuse(id);
    } else if (pass) {
      url = Urls.userFeaturesPass(id);
    } else if (!pass) {
      url = Urls.userFeaturesRefuse(id);
    }
    simpleRequest(
      url: url,
      params: {},
      success: (success, json) {
        if (success) {
          loadList(pageIndex);
        }
      },
      after: () {},
    );
  }

  loadList(int index, {bool isLoad = false}) {
    isLoad ? pageNos[index]++ : pageNos[index] = 1;
    if (dataList[index].isEmpty) {
      isLoadding = true;
    }
    simpleRequest(
      url: Urls.featuresApplyList,
      params: {
        "pageSize": pageSizes[index],
        "pageNo": pageNos[index],
        "d_Type": index,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          List datas = data["data"] ?? [];
          counts[index] = data["count"] ?? 0;
          isLoad
              ? dataList[index] = [...dataList[index], ...datas]
              : dataList[index] = datas;

          isLoad
              ? pullCtrls[index].loadComplete()
              : pullCtrls[index].refreshCompleted();
          update(["${listBuild}_$index"]);
        } else {
          isLoad
              ? pullCtrls[index].loadFailed()
              : pullCtrls[index].refreshFailed();
        }
      },
      after: () {
        isLoadding = false;
      },
    );
    // Future.delayed(const Duration(seconds: 2), () {
    //   dataList[index] = [
    //     {
    //       "id": 0,
    //       "name": "申请人员1",
    //       "phone": "13923849023",
    //       "number": "Y283949",
    //       "status": 0,
    //       "content": "申请成为代理",
    //       "time": "2023-01-05 10:33:22"
    //     },
    //     {
    //       "id": 1,
    //       "name": "申请人员2",
    //       "phone": "13923849023",
    //       "number": "Y283949",
    //       "status": 0,
    //       "content": "申请成为代理",
    //       "time": "2023-01-05 10:33:22"
    //     },
    //     {
    //       "id": 2,
    //       "name": "申请人员3",
    //       "phone": "13923849023",
    //       "number": "Y283949",
    //       "status": 1,
    //       "content": "申请成为代理",
    //       "time": "2023-01-05 10:33:22"
    //     },
    //     {
    //       "id": 3,
    //       "name": "申请人员4",
    //       "phone": "13923849023",
    //       "number": "Y283949",
    //       "status": 1,
    //       "content": "申请成为代理",
    //       "time": "2023-01-05 10:33:22"
    //     },
    //     {
    //       "id": 4,
    //       "name": "申请人员5",
    //       "phone": "13923849023",
    //       "number": "Y283949",
    //       "status": 2,
    //       "content": "申请成为代理",
    //       "time": "2023-01-05 10:33:22"
    //     },
    //     {
    //       "id": 5,
    //       "name": "申请人员5",
    //       "phone": "13923849023",
    //       "number": "Y283949",
    //       "status": 2,
    //       "content": "申请成为代理",
    //       "time": "2023-01-05 10:33:22"
    //     },
    // ];

    // });
  }

  // onLoad() {
  //   loadList(0, isLoad: true);
  // }

  // onRefresh() {
  //   loadList(0);
  // }

  // onLoad1() {
  //   loadList(1, isLoad: true);
  // }

  // onRefresh1() {
  //   loadList(1);
  // }

  // onLoad2() {
  //   loadList(2, isLoad: true);
  // }

  // onRefresh2() {
  //   loadList(2);
  // }

  String listBuild = "MineTransactionFormat_listBuild";

  @override
  void onInit() {
    loadList(0);
    super.onInit();
  }

  @override
  void onClose() {
    for (RefreshController e in pullCtrls) {
      e.dispose();
    }
    pageCtrl.dispose();
    super.onClose();
  }
}

class MineTransactionFormat extends GetView<MineTransactionFormatController> {
  const MineTransactionFormat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "申请审批"),
        body: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 44.w,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                              color: AppColor.lineColor, width: 0.5.w))),
                  child: GetX<MineTransactionFormatController>(
                    builder: (_) {
                      int length = 4;
                      return centRow(List.generate(length, (index) {
                        String title = "";
                        switch (index) {
                          case 0:
                            title = "申请中";
                            break;
                          case 1:
                            title = "已通过";
                            break;
                          case 2:
                            title = "已拒绝";
                            break;
                          case 3:
                            title = "永久拒绝";
                            break;
                          default:
                        }
                        return CustomButton(
                          onPressed: () {
                            controller.pageIndex = index;
                          },
                          child: SizedBox(
                            width: 375.w / length - 0.1.w,
                            height: 44.w,
                            child: Center(
                                child: centClm([
                              getSimpleText(
                                  title,
                                  controller.pageIndex == index ? 16 : 14,
                                  controller.pageIndex == index
                                      ? AppDefault().getThemeColor() ??
                                          AppColor.theme
                                      : AppColor.textBlack,
                                  fw: controller.pageIndex == index
                                      ? AppDefault.fontBold
                                      : FontWeight.normal),
                              ghb(controller.pageIndex == index ? 3.5 : 0),
                              controller.pageIndex == index
                                  ? Container(
                                      width: 35.w,
                                      height: 3.w,
                                      decoration: BoxDecoration(
                                          color: AppDefault().getThemeColor() ??
                                              AppColor.theme,
                                          borderRadius:
                                              BorderRadius.circular(1.5.w)),
                                    )
                                  : ghb(0)
                            ])),
                          ),
                        );
                      }));
                    },
                  ),
                )),
            Positioned(
                top: 44.w,
                bottom: 0,
                left: 0,
                right: 0,
                child: PageView.builder(
                  controller: controller.pageCtrl,
                  itemCount: controller.dataList.length,
                  itemBuilder: (context, index) {
                    return GetBuilder<MineTransactionFormatController>(
                      builder: (_) {
                        return list(index, context);
                      },
                    );
                  },
                  onPageChanged: (value) {
                    controller.pageIndex = value;
                  },
                ))
          ],
        ));
  }

  Widget list(int index, BuildContext context) {
    return GetBuilder<MineTransactionFormatController>(
      id: "${controller.listBuild}_$index",
      builder: (_) {
        List datas = controller.dataList[index];
        return SmartRefresher(
            controller: controller.pullCtrls[index],
            onLoading: () {
              controller.loadList(index, isLoad: true);
            },
            onRefresh: () {
              controller.loadList(index);
            },
            enablePullUp: controller.counts[index] > datas.length,
            child: datas.isEmpty
                ? GetX<MineTransactionFormatController>(
                    builder: (_) {
                      return CustomEmptyView(
                        isLoading: controller.isLoadding,
                      );
                    },
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                        top: 10.w, bottom: paddingSizeBottom(context) + 10.w),
                    itemCount: datas.length,
                    itemBuilder: (context, listIndex) {
                      return cell(datas[listIndex], index, context);
                    },
                  ));
      },
    );
  }

  Widget cell(Map data, int index, BuildContext context) {
    // double height = 120;
    int status = (data["featuresApply_Flag"] ?? -1);
    String name = data["u_Name"] ?? "";
    String phone = data["u_Mobile"] ?? "";
    return Container(
      width: 375.w,
      // height: height.w,
      padding: EdgeInsets.only(top: 12.w, bottom: 10.w),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(width: 1.w, color: AppColor.lineColor))),
      child: Center(
        child: sbRow([
          centClm([
            centRow([
              name.isEmpty
                  ? gwb(0)
                  : getSimpleText(name, 15, AppColor.textBlack, isBold: true),
              gwb(name.isEmpty ? 0 : 10),
              phone.isEmpty
                  ? gwb(0)
                  : CustomButton(
                      onPressed: () {
                        callPhone(phone);
                      },
                      child: centRow([
                        (phone).isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 0.3.w),
                                child: Image.asset(
                                  assetsName(
                                      "home/mybusiness/icon_business_phone"),
                                  width: 16.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              )
                            : gwb(0),
                        gwb(3),
                        getSimpleText(phone, 17, AppColor.textBlack,
                            fw: FontWeight.w500),
                      ]),
                    ),
            ]),
            ghb(5),
            getSimpleText("推荐码：${data["u_Number"]}", 14, AppColor.textBlack),
            ghb(2.5),
            getSimpleText("内容：申请成为代理", 14, AppColor.textBlack),
            ghb(2.5),
            getSimpleText(
                "申请单号：${data["orderNo"] ?? ""}", 14, AppColor.textBlack),
            ghb(2.5),
            getSimpleText(
                "${status == 0 ? "申请" : status == 1 ? "通过" : "拒绝"}时间：${data["addTime"] ?? ""}",
                14,
                AppColor.textBlack),
          ], crossAxisAlignment: CrossAxisAlignment.start),
          centRow([
            status == 0
                ? centRow([
                    CustomButton(
                      onPressed: () {
                        showAlert(
                          context,
                          "是否确认通过该申请",
                          confirmOnPressed: () {
                            if (data["id"] != null) {
                              controller.passOrRejectRequest(true, data["id"]);
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                      child: Container(
                        width: 50.w,
                        height: 29.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: AppDefault().getThemeColor() ?? AppColor.theme,
                        ),
                        child: Center(
                          child: getSimpleText("通过", 14, Colors.white),
                        ),
                      ),
                    ),
                    gwb(6),
                    CustomButton(
                      onPressed: () {
                        showAlert(
                          context,
                          "是否确认拒绝该申请",
                          confirmOnPressed: () {
                            if (data["id"] != null) {
                              controller.passOrRejectRequest(false, data["id"]);
                            }
                            Navigator.pop(context);
                          },
                          otherBtn: true,
                          otherText: "永久拒绝",
                          otherOnPressed: () {
                            controller.passOrRejectRequest(false, data["id"],
                                overReject: true);
                            Navigator.pop(context);
                          },
                        );
                      },
                      child: Container(
                        width: 50.w,
                        height: 29.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: AppColor.textRed,
                        ),
                        child: Center(
                          child: getSimpleText("拒绝", 14, Colors.white),
                        ),
                      ),
                    )
                  ])
                : centClm([
                    getSimpleText(
                        "${status == 1 ? "已通过" : status == 2 ? "已拒绝" : "永久拒绝"} ",
                        14,
                        status == 1
                            ? (AppDefault().getThemeColor() ?? AppColor.theme)
                            : AppColor.textRed),
                    ghb(status == 3 ? 6 : 0),
                    status == 3
                        ? CustomButton(
                            onPressed: () {
                              showAlert(
                                context,
                                "确认撤回该申请的永久拒绝，撤回后该用户可再次提交申请",
                                titleStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColor.textBlack,
                                    fontWeight: AppDefault.fontBold),
                                confirmOnPressed: () {
                                  if (data["id"] != null) {
                                    controller.passOrRejectRequest(
                                        true, data["id"],
                                        back: true);
                                  }
                                  Navigator.pop(context);
                                },
                              );
                            },
                            child: Container(
                              width: 50.w,
                              height: 29.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                color: AppDefault().getThemeColor() ??
                                    AppColor.theme,
                              ),
                              child: Center(
                                child: getSimpleText("撤回", 14, Colors.white),
                              ),
                            ),
                          )
                        : ghb(0)
                  ])
          ])
        ], width: 375 - 20 * 2),
      ),
    );
  }
}
