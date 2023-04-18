import 'package:flutter/material.dart';
import 'package:cxhighversion2/app_binding.dart';
import 'package:cxhighversion2/component/app_success_page.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/terminalBack/terminal_back_history.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TerminalBackSelectBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TerminalBackSelectController>(TerminalBackSelectController());
  }
}

class TerminalBackSelectController extends GetxController {
  List terminalList = [];
  TextEditingController searchInputCtrl = TextEditingController();
  RefreshController pullCtrl = RefreshController();

  bool isSearch = false;

  int pageNo = 1;
  int pageSize = 30;
  int count = 0;

  List selecedTIds = [];

  final _isBeforeLoad = true.obs;
  set isBeforeLoad(v) => _isBeforeLoad.value = v;
  bool get isBeforeLoad => _isBeforeLoad.value;

  onLoad() async {
    loadTerminalList(isLoad: true);
  }

  onRefresh() async {
    loadTerminalList();
  }

  final _isAllSelected = false.obs;
  bool get isAllSelected => _isAllSelected.value;
  set isAllSelected(v) => _isAllSelected.value = v;

  checkTids(Map data) {
    data["selected"]
        ? selecedTIds.add(data["tId"])
        : selecedTIds.remove(data["tId"]);
  }

  selectTerminal(Map data) {
    data["selected"] = !data["selected"];
    checkTids(data);
    checkSelect();
    update();
  }

  allSelect(bool selected) {
    terminalList = terminalList.map((e) {
      e["selected"] = selected;
      checkTids(e);
      return e;
    }).toList();
    isAllSelected = selected;
    update();
  }

  checkSelect() {
    isAllSelected = (terminalList.length == selecedTIds.length);
  }

  dataListFormat() {
    terminalList.map((e) {
      e["selected"] = selecedTIds.contains(e["tId"]);
      return e;
    }).toList();
    update();
  }

  loadTerminalList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    Map<String, dynamic> params = {
      "user_ID": userData["uId"] ?? -1,
      "pageSize": pageSize,
      "pageNo": pageNo,
    };
    if (isSearch && searchInputCtrl.text.isNotEmpty) {
      params["username"] = searchInputCtrl.text;
      // params["terminal_NO"] = searchInputCtrl.text;
    } else if (isSearch && searchInputCtrl.text.isEmpty) {
      isSearch = false;
    }

    simpleRequest(
      url: Urls.userTerminalBackList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          count = data["count"] ?? 0;
          // count = 1000;
          if (isLoad) {
            terminalList = [...terminalList, ...data["data"]];
            pullCtrl.loadComplete();
          } else {
            terminalList = data["data"];
            pullCtrl.refreshCompleted();
          }
          dataListFormat();
        } else {
          if (isLoad) {
            pullCtrl.loadFailed();
          } else {
            pullCtrl.refreshFailed();
          }
        }
      },
      after: () {
        isBeforeLoad = false;
      },
    );
  }

  terminalBackRequest() {
    // Get.to(
    //     AppSuccessPage(
    //       contentText: "回拨机具成功",
    //       subContentText: "",
    //       buttons: [
    //         getSubmitBtn("查看回拨记录", () {
    //           popToUntil(
    //               page: const TerminalBackHistory(),
    //               binding: TerminalBackHistoryBinding());
    //         }, color: Colors.white, textColor: AppColor.textBlack),
    //         getSubmitBtn("回到首页", () {
    //           popToUntil();
    //         }),
    //       ],
    //     ),
    //     binding: AppSuccessPageBinding());
    if (terminalList.isEmpty) {
      return;
    }
    if (selecedTIds.isEmpty) {
      ShowToast.normal("您还没有选择需要回拨的机具，请先选择机具");
    }
    String tids = "";
    for (var i = 0; i < selecedTIds.length; i++) {
      var item = selecedTIds[i];
      i == 0 ? tids = "$item" : tids += ",$item";
    }
    simpleRequest(
      url: Urls.userTerminalCallBack(tids),
      params: {},
      success: (success, json) {
        if (success) {
          Get.to(
              AppSuccessPage(
                contentText: "回拨机具成功",
                subContentText: "",
                buttons: [
                  // getSubmitBtn("查看回拨记录", () {
                  //   popToUntil(
                  //       page: const TerminalBackHistory(),
                  //       binding: TerminalBackHistoryBinding());
                  // }, color: Colors.white, textColor: AppColor.textBlack),
                  getSubmitBtn("回到首页", () {
                    popToUntil();
                  }),
                ],
              ),
              binding: AppSuccessPageBinding());
        }
      },
      after: () {},
    );
  }

  Map userData = {};
  bool isFirst = true;
  dataInit(Map uData) {
    if (!isFirst) {
      return;
    }
    isFirst = false;

    userData = uData;
    loadTerminalList();
  }

  @override
  void dispose() {
    searchInputCtrl.dispose();
    pullCtrl.dispose();
    super.dispose();
  }
}

class TerminalBackSelect extends GetView<TerminalBackSelectController> {
  final Map userData;
  const TerminalBackSelect({Key? key, required this.userData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(userData);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
          appBar: getDefaultAppBar(context, userData["uName"] ?? "选择回拨机具"),
          body: Stack(
            children: [
              Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  height: 80.w,
                  child: SizedBox(
                    child: Center(
                      child: Container(
                        width: 345.w,
                        height: 50.w,
                        decoration: getDefaultWhiteDec(),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              gwb(15),
                              CustomButton(
                                onPressed: () {
                                  toScanBarCode((barCode) => controller
                                      .searchInputCtrl.text = barCode);
                                },
                                child: assetsSizeImage(
                                    "home/machinemanage/tiaoxingma", 24, 24),
                              ),
                              gwb(15),
                              CustomInput(
                                width: 214.w,
                                heigth: 50.w,
                                textEditCtrl: controller.searchInputCtrl,
                                placeholder: "请输入机具SN号进行搜索",
                                placeholderStyle: TextStyle(
                                    color: const Color(0xFFCCCCCC),
                                    fontSize: 15.sp),
                              ),
                              CustomButton(
                                onPressed: () {
                                  controller.isSearch = true;
                                  controller.loadTerminalList();
                                  takeBackKeyboard(context);
                                },
                                child: Container(
                                    width: 64.w,
                                    height: 30.w,
                                    decoration: BoxDecoration(
                                        color: AppColor.textBlack,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                      child:
                                          getSimpleText("搜索", 15, Colors.white),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
              Positioned(
                top: 80.w,
                left: 0,
                right: 0,
                bottom: 0,
                child: getInputSubmitBody(
                  context,
                  "确认回拨",
                  fromTop: 80,
                  onPressed: () {
                    controller.terminalBackRequest();
                  },
                  build: (boxHeight, context) {
                    return SizedBox(
                        width: 375.w,
                        height: boxHeight,
                        child: GetBuilder<TerminalBackSelectController>(
                          init: controller,
                          builder: (controller) {
                            return SmartRefresher(
                              physics: const BouncingScrollPhysics(),
                              controller: controller.pullCtrl,
                              onLoading: controller.onLoad,
                              onRefresh: controller.onRefresh,
                              enablePullUp: controller.count >
                                  controller.terminalList.length,
                              child: controller.terminalList == null ||
                                      controller.terminalList.isEmpty
                                  ? GetX<TerminalBackSelectController>(
                                      builder: (controller) {
                                        return CustomEmptyView(
                                          isLoading: controller.isBeforeLoad,
                                        );
                                      },
                                    )
                                  : SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 375.w,
                                            height: 50.w,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border(
                                                    bottom: BorderSide(
                                                        width: 0.5.w,
                                                        color: const Color(
                                                            0xFFEBEBEB)))),
                                            child: Center(
                                                child: sbRow([
                                              getSimpleText("机具编号（SN号）", 14,
                                                  const Color(0xFF808080)),
                                              CustomButton(
                                                onPressed: () {
                                                  controller.allSelect(
                                                      !controller
                                                          .isAllSelected);
                                                },
                                                child: SizedBox(
                                                  height: 50.w,
                                                  child: Center(
                                                      child: getSimpleText(
                                                          controller
                                                                  .isAllSelected
                                                              ? "反选"
                                                              : "全选",
                                                          14,
                                                          const Color(
                                                              0xFF5290F2))),
                                                ),
                                              )
                                            ], width: 375 - 15 * 2)),
                                          ),
                                          ...controller.terminalList
                                              .asMap()
                                              .entries
                                              .map((e) =>
                                                  terminalCell(e.value, e.key))
                                              .toList()
                                        ],
                                      ),
                                    ),
                            );
                          },
                        ));
                  },
                ),
              )
            ],
          )),
    );
  }

  Widget terminalCell(Map data, int idx) {
    return CustomButton(
      onPressed: () {
        controller.selectTerminal(data);
      },
      child: Container(
        width: 375.w,
        height: 60.w,
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(width: 0.5, color: Color(0xFFEBEBEB)))),
        child: Align(
          child: sbhRow([
            getSimpleText(snNoFormat(data["tNo"]), 13, AppColor.textBlack),
            Image.asset(
              assetsName(
                data["selected"]
                    ? "common/btn_checkbox_selected"
                    : "common/btn_checkbox_normal",
              ),
              width: 22.w,
              height: 22.w,
              fit: BoxFit.fill,
            )

            //         btn_checkbox_normal.png
            // btn_checkbox_selected.png
          ], width: 375 - 15 * 2),
        ),
      ),
    );
  }
}
