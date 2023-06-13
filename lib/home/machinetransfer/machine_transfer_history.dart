import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_order_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineTransferHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferHistoryController>(
        MachineTransferHistoryController());
  }
}

class MachineTransferHistoryController extends GetxController {
  // PageController pageController = PageController();
  List<RefreshController> pullCtrls = [
    RefreshController(),
    RefreshController()
  ];
  List dataLists = [[], []];
  List pageNos = [1, 1];
  List pageSizes = [10, 10];
  List counts = [0, 0];

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  // bool isAnimateToPage = false;
  set topIndex(v) {
    // if (isAnimateToPage) {
    //   return;
    // }
    _topIndex.value = v;
    loadList(index: topIndex);

    // isAnimateToPage = true;
    // pageController
    //     .animateToPage(topIndex,
    //         duration: const Duration(milliseconds: 300), curve: Curves.linear)
    //     .then((value) {
    //   isAnimateToPage = false;
    // });
  }

  String listBuildId(dynamic index) =>
      "MachineTransferHistory_listBuildId_$index";

  loadList({bool isLoad = false, int index = 0}) {
    isLoad ? pageNos[index]++ : pageNos[index] = 1;
    simpleRequest(
      // url: Urls.terminalTransferOrder,
      // params: {
      //   "pageSize": pageSizes[index],
      //   "pageNo": pageNos[index],
      //   "type": index == 0 ? 1 : 2
      // },
      url: Urls.terminalTransferList,
      params: {
        "pageSize": pageSizes[index],
        "pageNo": pageNos[index],
        "terminal_Type": 1
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[index] = data["count"] ?? 0;
          List datas = data["data"] ?? [];
          if (isLoad) {
            dataLists[index] = [...dataLists[index], ...datas];
            pullCtrls[index].loadComplete();
          } else {
            dataLists[index] = datas;
            pullCtrls[index].refreshCompleted();
          }
          update([listBuildId(index)]);
        } else {
          isLoad
              ? pullCtrls[index].loadFailed()
              : pullCtrls[index].refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  onLoad() {
    loadList(isLoad: true, index: topIndex);
  }

  onRefresh() {
    loadList(index: topIndex);
  }

  @override
  void onInit() {
    loadList();
    super.onInit();
  }

  @override
  void onClose() {
    // pageController.dispose();
    for (var e in pullCtrls) {
      e.dispose();
    }
    super.onClose();
  }
}

class MachineTransferHistory extends GetView<MachineTransferHistoryController> {
  const MachineTransferHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "划拨记录"),
      body: Stack(
        children: [
          // Positioned(
          //     top: 0,
          //     left: 0,
          //     right: 0,
          //     height: 44.w,
          //     child: Container(
          //       // width: 375.w,
          //       // height: 44.w,
          //       color: Colors.white,
          //       child: GetX<MachineTransferHistoryController>(
          //         builder: (_) {
          //           return sbhRow(
          //               List.generate(
          //                   2,
          //                   (index) => CustomButton(
          //                         onPressed: () {
          //                           controller.topIndex = index;
          //                         },
          //                         child: SizedBox(
          //                           width: (375 / 2).w,
          //                           height: 44.w,
          //                           child: Center(
          //                             child: getSimpleText(
          //                                 index == 0 ? "划拨" : "接收",
          //                                 16,
          //                                 controller.topIndex == index
          //                                     ? AppColor.buttonTextBlue
          //                                     : AppColor.textGrey,
          //                                 isBold: true),
          //                           ),
          //                         ),
          //                       )),
          //               width: 375,
          //               height: 44);
          //         },
          //       ),
          //     )),
          Positioned(
              top:
                  // 44.w
                  0,
              left: 0,
              right: 0,
              bottom: 0,
              child: listView(0)

              // PageView(
              //   controller: controller.pageController,
              //   onPageChanged: (value) {
              //     controller.topIndex = value;
              //   },
              //   children: List.generate(2, (index) => listView(index)),
              // )

              )
        ],
      ),
    );
  }

  Widget listView(int index) {
    return GetBuilder<MachineTransferHistoryController>(
      init: controller,
      id: controller.listBuildId(index),
      builder: (controller) {
        return SmartRefresher(
          physics: const BouncingScrollPhysics(),
          controller: controller.pullCtrls[index],
          onLoading: controller.onLoad,
          onRefresh: controller.onRefresh,
          // enablePullUp: controller.counts[index] >
          //     controller.dataLists[index].length,
          child: controller.dataLists[index].isEmpty
              ? GetX<MachineTransferHistoryController>(
                  builder: (_) {
                    return CustomEmptyView(
                      isLoading: controller.isLoading,
                    );
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 20.w),
                  itemCount: controller.dataLists[index] != null &&
                          controller.dataLists[index].isNotEmpty
                      ? controller.dataLists[index].length
                      : 0,
                  itemBuilder: (context, listIndex) {
                    return historyCell(
                        listIndex, controller.dataLists[index][listIndex]);
                  },
                ),
        );
      },
    );
  }

  Widget historyCell(int index, Map data) {
    return Align(
      child: GestureDetector(
        onTap: () {
          // Get.to(
          //     () => MachineTransferOrderDetail(
          //           orderData: data,
          //           type: 2,
          //         ),
          //     binding: MachineTransferOrderDetailBinding());
        },
        child: Container(
          margin: EdgeInsets.only(top: 15.w),
          width: 345.w,
          decoration: getDefaultWhiteDec(radius: 4),
          child: Stack(
            children: [
              SizedBox(
                width: 345.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    sbhRow([
                      centRow([
                        getSimpleText(
                            "发给${data["iU_Name"] ?? (hidePhoneNum(data["iU_Mobile"] ?? ""))}的划拨订单",
                            14,
                            AppColor.textBlack,
                            isBold: true)
                      ])
                    ], width: 315, height: 50),
                    // ghb(19),
                    // sbRow([
                    //   Text.rich(TextSpan(
                    //       text: "接收人：",
                    //       style: TextStyle(
                    //         fontSize: 16.sp,
                    //         color: AppColor.textGrey,
                    //       ),
                    //       children: [
                    //         TextSpan(
                    //             text:
                    //                 "${data["suName"] ?? (hidePhoneNum(data["suMobile"] ?? ""))}(${hidePhoneNum(data["suMobile"])})",
                    //             style: TextStyle(
                    //                 fontSize: 16.sp,
                    //                 color: AppColor.textBlack,
                    //                 fontWeight: AppDefault.fontBold))
                    //       ]))
                    // ], width: 345 - 20.5 * 2),
                    // ghb(19),
                    Container(
                      width: 315.w,
                      height: 80.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColor.pageBackgroundColor,
                          borderRadius: BorderRadius.circular(4.w)),
                      child: centClm(List.generate(
                          3,
                          (index) => sbhRow([
                                getWidthText(
                                    index == 0
                                        ? "接收人"
                                        : index == 1
                                            ? "划拨台数"
                                            : "划拨时间",
                                    12,
                                    AppColor.textGrey,
                                    55.5,
                                    1,
                                    textHeight: 1.3),
                                getWidthText(
                                    index == 0
                                        ? data["iU_Name"] ?? ""
                                        : index == 1
                                            ? "${data["countNum"] ?? ""}台"
                                            : data["addtime"] ?? "",
                                    12,
                                    AppColor.textGrey,
                                    315 - 15 * 2 - 55.5,
                                    1,
                                    textHeight: 1.3),
                              ], width: 315 - 15 * 2, height: 25))),
                    ),

                    ghb(15),
                  ],
                ),
              ),
              // Positioned(
              //     top: -24.w,
              //     right: -24.w,
              //     width: 60.w,
              //     height: 50.w,
              //     child: Transform.rotate(
              //       angle: math.pi / 2 * 0.45,
              //       child: Container(
              //         width: 60.w,
              //         height: 50.w,
              //         color: data["applyType"] == 1
              //             ? const Color(0xFFEB6100)
              //             : const Color(0xFF72C36C),
              //         child: Align(
              //           alignment: Alignment.bottomCenter,
              //           child: getSimpleText(
              //               data["applyType"] == 1 ? "兑换" : "划拨",
              //               12,
              //               Colors.white,
              //               isBold: true),
              //         ),
              //       ),
              //     )),
            ],
          ),
        ),
      ),
    );
  }
}
