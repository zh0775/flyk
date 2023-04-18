import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities_add.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities_change.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities_history.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatisticsMachineEquitiesBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineEquitiesController>(
        StatisticsMachineEquitiesController(datas: Get.arguments));
  }
}

class StatisticsMachineEquitiesController extends GetxController {
  final dynamic datas;
  StatisticsMachineEquitiesController({this.datas});

  final pullCtrl = RefreshController();
  final searchInputCtrl = TextEditingController();

  int modelPPIndex = 0;
  int modelPPPageIndex = 0;

  List hjppList = [
    {
      "id": 0,
      "name": "联动换机",
      "img": "statistics/machine/icon_hj_pp",
    },
    {
      "id": 1,
      "name": "盛电宝换机",
      "img": "statistics/machine/icon_hj_pp",
    },
    {
      "id": 0,
      "name": "盛电宝换机1",
      "img": "statistics/machine/icon_hj_pp",
    },
    {
      "id": 1,
      "name": "联动换机2",
      "img": "statistics/machine/icon_hj_pp",
    },
    {
      "id": 0,
      "name": "联动换机3",
      "img": "statistics/machine/icon_hj_pp",
    }
  ];

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  int pageNo = 1;
  int pageSize = 20;
  int count = 0;

  List dataList = [];

  onLoad() {
    loadData(isLoad: true);
  }

  onRefresh() {
    loadData();
  }

  searchAction() {
    loadData();
  }

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
    };
    if (searchInputCtrl.text.isNotEmpty) {
      params["termNO"] = searchInputCtrl.text;
    }

    simpleRequest(
      url: Urls.userTerminalAssociateList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List mData = data["data"] ?? [];
          dataList = isLoad ? [...dataList, ...mData] : mData;
          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          update();
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );

    // Future.delayed(const Duration(milliseconds: 500), () {
    //   count = 100;
    //   List tmpDatas = [];
    //   for (var i = 0; i < pageSize; i++) {
    //     tmpDatas.add({
    //       "id": dataList.length + i,
    //       "name": i % 2 == 0 ? "盛电宝K300" : "渝钱宝电签",
    //       "img": "D0031/2023/1/202301311856422204X.png",
    //       "no": "T550006698$i",
    //       "tNo": "T550006698$i",
    //       "useDay": 20 + i,
    //       "bName": "欢乐人",
    //       "bPhone": "13598901253",
    //       "bXh": i % 2 == 0 ? "盛电宝K300123" : "渝钱宝电签123",
    //       "aTime": "2020-01-23 13:26:09",
    //       "isChange": i % 5 == 0,
    //       "open": !isLoad && i == 0
    //     });
    //   }
    //   dataList = isLoad ? [...dataList, ...tmpDatas] : tmpDatas;
    //   mainData = {"allCount": 6, "use": 5, "unUse": 1};
    //   mainData["machines"] = dataList;

    //   update();
    //   isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
    //   isLoading = false;
    // });
  }

  Map equityInfo = {};
  List machineTypes = [];

  @override
  void onInit() {
    equityInfo = AppDefault().homeData["equityInfo"] ?? {};
    Map publicHomeData = AppDefault().publicHomeData;
    if (publicHomeData.isNotEmpty &&
        publicHomeData["terminalConfig"].isNotEmpty &&
        publicHomeData["terminalConfig"] is List) {
      machineTypes = List.generate(
          (publicHomeData["terminalConfig"] as List).length, (index) {
        Map e = (publicHomeData["terminalConfig"] as List)[index];
        return {
          ...e,
          "name": e["terninal_Name"] ?? "",
          "img": e["terninal_Pic"] ?? ""
        };
      });
    }

    loadData();
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onInit();
  }

  homeDataNotify(arg) {
    equityInfo = AppDefault().homeData["equityInfo"] ?? {};
    update();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onClose();
  }
}

class StatisticsMachineEquities
    extends GetView<StatisticsMachineEquitiesController> {
  const StatisticsMachineEquities({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "权益设备", action: [
          CustomButton(
            onPressed: () {
              push(const StatisticsMachineEquitiesHistory(), context,
                  binding: StatisticsMachineEquitiesHistoryBinding());
            },
            child: SizedBox(
              width: 70.w,
              height: kToolbarHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: getSimpleText("换机记录", 15, AppColor.text2),
              ),
            ),
          )
        ]),
        body: Stack(children: [
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 55.w,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    gwb(375),
                    ghb(5.5),
                    Container(
                      width: 345.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                          color: AppColor.pageBackgroundColor,
                          borderRadius: BorderRadius.circular(20.w)),
                      child: Row(
                        children: [
                          gwb(20),
                          CustomInput(
                            textEditCtrl: controller.searchInputCtrl,
                            width: (345 - 20 - 62 - 1 - 0.1).w,
                            heigth: 40.w,
                            placeholder: "请输入想要搜索的设备编号",
                            placeholderStyle: TextStyle(
                                fontSize: 12.sp, color: AppColor.assisText),
                            style: TextStyle(
                                fontSize: 12.sp, color: AppColor.text),
                            onSubmitted: (p0) {
                              takeBackKeyboard(context);
                              controller.searchAction();
                            },
                          ),
                          CustomButton(
                            onPressed: () {
                              takeBackKeyboard(context);
                              controller.searchAction();
                            },
                            child: SizedBox(
                              width: 62.w,
                              height: 40.w,
                              child: Center(
                                child: Image.asset(
                                  assetsName("machine/icon_search"),
                                  width: 18.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
          Positioned(
              top: 55.w,
              left: 0,
              right: 0,
              height: 150.w,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    sbhRow([
                      centRow([
                        Container(
                          width: 3.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                              color: AppColor.theme,
                              borderRadius: BorderRadius.circular(1.25.w)),
                        ),
                        gwb(9),
                        getSimpleText("权益设备", 15, AppColor.text),
                      ]),
                      CustomButton(
                        onPressed: () {
                          push(const StatisticsMachineEquitiesAdd(), context,
                              binding: StatisticsMachineEquitiesAddBinding(),
                              arguments: {
                                "machineData": controller.equityInfo
                              });
                        },
                        child: SizedBox(
                          height: 55.w,
                          child: centRow([
                            Image.asset(
                              assetsName("statistics/machine/btn_navi_add"),
                              width: 24.w,
                              fit: BoxFit.fitWidth,
                            ),
                            gwb(1.5),
                            getSimpleText("添加", 14, AppColor.text2),
                          ]),
                        ),
                      )
                    ], width: 375 - 15 * 2, height: 55),
                    ghb(13),
                    GetBuilder<StatisticsMachineEquitiesController>(
                      builder: (_) {
                        return centRow(
                          List.generate(3, (index) {
                            return centRow([
                              SizedBox(
                                width: 117.w,
                                child: centClm([
                                  getSimpleText(
                                      index == 0
                                          ? "总名额"
                                          : index == 1
                                              ? "已使用"
                                              : "未使用",
                                      12,
                                      AppColor.text2),
                                  ghb(7),
                                  SizedBox(
                                    height: 40.w,
                                    child: Center(
                                      child: getSimpleText(
                                          "${index == 0 ? controller.equityInfo["equityTolNum"] ?? 0 : index == 1 ? controller.equityInfo["isUsed"] ?? 0 : controller.equityInfo["isUnused"] ?? 0}",
                                          24,
                                          AppColor.text2,
                                          isBold: true),
                                    ),
                                  )
                                ]),
                              ),
                              index < 2
                                  ? gline(
                                      1,
                                      40,
                                    )
                                  : gwb(0)
                            ], crossAxisAlignment: CrossAxisAlignment.end);
                          }),
                        );
                      },
                    )
                  ],
                ),
              )),
          Positioned.fill(
              top: 205.w,
              child: GetBuilder<StatisticsMachineEquitiesController>(
                builder: (_) {
                  return SmartRefresher(
                    controller: controller.pullCtrl,
                    onLoading: controller.onLoad,
                    onRefresh: controller.onRefresh,
                    enablePullUp: controller.count > controller.dataList.length,
                    child: controller.dataList.isEmpty
                        ? GetX<StatisticsMachineEquitiesController>(
                            builder: (_) {
                              return CustomEmptyView(
                                isLoading: controller.isLoading,
                              );
                            },
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 20.w),
                            itemCount: controller.dataList.length,
                            itemBuilder: (context, index) =>
                                cell(index, controller.dataList[index]),
                          ),
                  );
                },
              ))
        ]),
      ),
    );
  }

  Widget cell(int index, Map data) {
    bool open = data["open"] ?? false;
    return UnconstrainedBox(
      child: AnimatedContainer(
        margin: EdgeInsets.only(top: 15.w),
        duration: const Duration(milliseconds: 200),
        width: 345.w,
        height: open ? 250.w : 135.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
        child: Column(
          children: [
            SizedBox(
              height: 75.w,
              child: Center(
                child: sbRow([
                  centRow([
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.w),
                      child: CustomNetworkImage(
                        src: AppDefault().imageUrl + (data["bgImg"] ?? ""),
                        width: 45.w,
                        height: 45.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                    gwb(9),
                    centClm([
                      centRow([
                        getSimpleText(
                            data["brandName"] ?? "", 15, AppColor.text2,
                            isBold: true),
                        gwb(3.5),
                        Container(
                          width: 55.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                              color: const Color(0xFFFE8E3B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(9.w)),
                          child: Center(
                            child: getSimpleText(
                                "权益设备", 10, const Color(0xFFFE8E3B)),
                          ),
                        ),
                      ]),
                      ghb(5),
                      getSimpleText(
                          "设备编号：${data["termNo"] ?? ""}", 12, AppColor.text3)
                    ], crossAxisAlignment: CrossAxisAlignment.start)
                  ]),
                  CustomButton(
                    onPressed: () {
                      showPPSelect(data);
                    },
                    child: Container(
                      width: 60.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.w),
                          border:
                              Border.all(width: 0.5.w, color: AppColor.theme)),
                      child: Center(
                          child: getSimpleText("更换设备", 12, AppColor.theme)),
                    ),
                  )
                ],
                    width: 345 - 15 * 2,
                    crossAxisAlignment: CrossAxisAlignment.start),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 315.w,
              height: open ? 160.w : 45.w,
              decoration: BoxDecoration(
                  color: AppColor.pageBackgroundColor,
                  borderRadius: BorderRadius.circular(4.w)),
              child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      CustomButton(
                        onPressed: () {
                          if (data["open"] == null) {
                            data["open"] = false;
                          }
                          data["open"] = !data["open"];
                          controller.update();
                        },
                        child: sbhRow([
                          Padding(
                            padding: EdgeInsets.only(left: 15.5.w),
                            child: Text.rich(TextSpan(
                                text: "累积使用天数(天)：",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColor.text2,
                                    fontWeight: AppDefault.fontBold),
                                children: [
                                  TextSpan(
                                      text: "${data["tolDays"] ?? 0}",
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColor.red,
                                          fontWeight: AppDefault.fontBold)),
                                  const TextSpan(
                                    text: "天",
                                  ),
                                ])),
                          ),
                          SizedBox(
                            width: 31.w,
                            height: 45.w,
                            child: Center(
                                child: AnimatedRotation(
                              turns: open ? 1.25 : 1,
                              duration: const Duration(milliseconds: 200),
                              child: Image.asset(
                                assetsName("statistics/icon_arrow_right_gray"),
                                width: 12.w,
                                fit: BoxFit.fitWidth,
                              ),
                            )),
                          ),
                        ], width: 315, height: 45),
                      ),
                      gline(300, 0.5, color: const Color(0xFFDFDFDF)),
                      SizedBox(
                        height: 114.5.w,
                        child: centClm(List.generate(4, (index) {
                          String t1 = "";
                          String t2 = "";
                          switch (index) {
                            case 0:
                              t1 = "商家";
                              t2 = data["merName"] ?? "";
                              break;
                            case 1:
                              t1 = "手机号";
                              t2 = data["merPhone"] ?? "";
                              break;
                            case 2:
                              t1 = "设备型号";
                              t2 = data["modelName"] ?? "";
                              break;
                            case 3:
                              t1 = "激活时间";
                              t2 = data["activTime"] ?? "";
                              break;
                          }

                          return sbhRow([
                            getSimpleText(t1, 12, AppColor.text3),
                            getSimpleText(t2, 12, AppColor.text2)
                          ], width: 315 - 15 * 2, height: 22);
                        })),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  showPPSelect(Map data) {
    controller.modelPPIndex = 0;
    controller.modelPPPageIndex = 0;
    int pageCount = (controller.machineTypes.length / 2).ceil();

    showGeneralDialog(
      context: Global.navigatorKey.currentContext!,
      barrierLabel: "",
      barrierDismissible: true,
      pageBuilder: (dlgCtx, animation, secondaryAnimation) {
        return UnconstrainedBox(
          child: Material(
            color: Colors.transparent,
            child: Container(
                width: 330.w,
                height: 300.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.w)),
                child: Column(
                  children: [
                    sbhRow([
                      gwb(42),
                      getSimpleText("选择置换机型", 18, AppColor.text, isBold: true),
                      CustomButton(
                        onPressed: () {
                          Navigator.pop(dlgCtx);
                        },
                        child: SizedBox(
                          width: 42.w,
                          height: 55.w,
                          child: Center(
                            child: Image.asset(
                              assetsName("statistics/machine/btn_model_close"),
                              width: 20.w,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      )
                    ], width: 330, height: 55),
                    ghb(8),
                    StatefulBuilder(
                      builder: (stateCtx, setState) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 120.w,
                              width: 330.w,
                              child: PageView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: pageCount,
                                onPageChanged: (value) {
                                  setState(() {
                                    controller.modelPPPageIndex = value;
                                  });
                                },
                                itemBuilder: (pageCtx, index) {
                                  return SizedBox(
                                    width: 330.w,
                                    child: Center(
                                      child: sbRow(
                                          List.generate(2, (idx) {
                                            Map ppData = index * 2 + idx >
                                                    controller.machineTypes
                                                            .length -
                                                        1
                                                ? {}
                                                : controller.machineTypes[
                                                    index * 2 + idx];
                                            return index * 2 + idx >
                                                    controller.machineTypes
                                                            .length -
                                                        1
                                                ? gwb(0)
                                                : CustomButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        controller
                                                                .modelPPIndex =
                                                            index * 2 + idx;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 120.w,
                                                      height: 120.w,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.w),
                                                          color: controller
                                                                      .modelPPIndex ==
                                                                  index * 2 +
                                                                      idx
                                                              ? Colors.white
                                                              : AppColor
                                                                  .pageBackgroundColor,
                                                          border: controller
                                                                      .modelPPIndex ==
                                                                  index * 2 +
                                                                      idx
                                                              ? Border.all(
                                                                  width: 1.5.w,
                                                                  color: AppColor
                                                                      .theme,
                                                                )
                                                              : null),
                                                      child: Stack(
                                                        children: [
                                                          Positioned.fill(
                                                              child: centClm([
                                                            ColorFiltered(
                                                              colorFilter: ColorFilter.mode(
                                                                  controller.modelPPIndex ==
                                                                          index * 2 +
                                                                              idx
                                                                      ? AppColor
                                                                          .theme
                                                                      : AppColor
                                                                          .text2,
                                                                  BlendMode
                                                                      .modulate),
                                                              child:
                                                                  CustomNetworkImage(
                                                                src: AppDefault()
                                                                        .imageUrl +
                                                                    (ppData["img"] ??
                                                                        ""),
                                                                height: 30.w,
                                                                fit: BoxFit
                                                                    .fitHeight,
                                                              ),
                                                            ),
                                                            ghb(19),
                                                            getSimpleText(
                                                                ppData["name"],
                                                                12,
                                                                controller.modelPPIndex ==
                                                                        index * 2 +
                                                                            idx
                                                                    ? AppColor
                                                                        .theme
                                                                    : AppColor
                                                                        .text2)
                                                          ]))
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                          }),
                                          width: 330 - 30 * 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 45.w,
                              child: centRow(List.generate(pageCount, (pIdx) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(
                                      left: pIdx != 0 ? 8.w : 0),
                                  width: controller.modelPPPageIndex == pIdx
                                      ? 12.w
                                      : 5.w,
                                  height: 5.w,
                                  decoration: BoxDecoration(
                                      color: controller.modelPPPageIndex == pIdx
                                          ? AppColor.theme
                                          : Colors.black.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(2.25.w)),
                                );
                              })),
                            )
                          ],
                        );
                      },
                    ),
                    getSubmitBtn("确定", () {
                      Navigator.pop(dlgCtx);
                      push(const StatisticsMachineEquitiesChange(), null,
                          binding: StatisticsMachineEquitiesChangeBinding(),
                          arguments: {
                            "machine": data,
                            "brand":
                                controller.machineTypes[controller.modelPPIndex]
                          });
                    }, width: 300, height: 45, color: AppColor.theme)
                  ],
                )),
          ),
        );
      },
    );
  }
}
