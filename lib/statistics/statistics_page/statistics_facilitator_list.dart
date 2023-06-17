import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/statistics_page/statistics_facilitator_detail.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class StatisticsFacilitatorListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsFacilitatorListController>(
        StatisticsFacilitatorListController());
  }
}

class StatisticsFacilitatorListController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _needCleanInput = false.obs;
  bool get needCleanInput => _needCleanInput.value;
  set needCleanInput(v) => _needCleanInput.value = v;

  final searchInputCtrl = TextEditingController();

  List teamTypes = [
    {"id": 0, "name": "全部伙伴"},
    {"id": 1, "name": "直营伙伴"},
    {"id": 2, "name": "团队伙伴"},
  ];
  final _teamTypesIdx = 0.obs;
  int get teamTypesIdx => _teamTypesIdx.value;
  set teamTypesIdx(v) {
    if (_teamTypesIdx.value != v) {
      _teamTypesIdx.value = v;
      loadData();
    }
  }

  List filterTypeList = [
    {"id": 0, "name": "默认排序"},
    {"id": 1, "name": "当日激活"},
    {"id": 2, "name": "当月激活"},
    {"id": 3, "name": "当月交易"},
    {"id": 4, "name": "级别排序"}
  ];
  final _filterTypeIdx = 0.obs;
  int get filterTypeIdx => _filterTypeIdx.value;
  set filterTypeIdx(v) {
    if (_filterTypeIdx.value != v) {
      _filterTypeIdx.value = v;
      loadData();
    }
  }

  List dataList = [];
  int pageNo = 1;
  int pageSize = 20;
  int count = 0;
  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
      "relationship_Bind": teamTypes[teamTypesIdx]["id"]
    };
    switch (filterTypeIdx) {
      case 0:
        break;
      case 1:
        params["actDayOrder"] = 1;
        break;
      case 2:
        params["actMonthOrder"] = 1;
        break;
      case 3:
        params["txtAmtOrder"] = 1;
        break;
      case 4:
        params["levelOrder"] = 1;
        break;
    }

    if (searchInputCtrl.text.isNotEmpty) {
      params["userInfo"] = searchInputCtrl.text;
    }

    if (dataList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
        url: Urls.userTerminalDataList,
        params: params,
        success: (success, json) {
          if (success) {
            Map data = json["data"] ?? {};
            count = data["count"];
            List tmpList = data["data"] ?? [];
            dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
            update();
          }
        },
        after: () {
          isLoading = false;
          isFirstLoading = false;
        },
        useCache: !isLoad);
  }

  homeDataNotify(arg) {
    loadData();
  }

  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 200), () {
      loadData();
    });
    super.onReady();
  }

  searchInputListener() {
    needCleanInput = searchInputCtrl.text.isNotEmpty;
  }

  setFacilitatorIdxNotify(arg) {
    filterTypeIdx = arg;
  }

  @override
  void onInit() {
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    bus.on("setFacilitatorIdx", setFacilitatorIdxNotify);
    searchInputCtrl.addListener(searchInputListener);
    super.onInit();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    bus.off("setFacilitatorIdx", setFacilitatorIdxNotify);
    searchInputCtrl.removeListener(searchInputListener);
    searchInputCtrl.dispose();
    super.onClose();
  }
}

class StatisticsFacilitatorList extends StatefulWidget {
  final bool isPage;
  const StatisticsFacilitatorList({Key? key, this.isPage = false})
      : super(key: key);
  @override
  State<StatisticsFacilitatorList> createState() =>
      _StatisticsFacilitatorListState();
}

class _StatisticsFacilitatorListState extends State<StatisticsFacilitatorList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.isPage
        ? Scaffold(
            appBar: getDefaultAppBar(context, "服务商", action: [
              GetBuilder<StatisticsFacilitatorListController>(
                  init: StatisticsFacilitatorListController(),
                  builder: (controller) {
                    return DropdownButtonHideUnderline(
                        child: DropdownButton2(
                            dropdownElevation: 0,
                            buttonElevation: 0,
                            offset: Offset(-10.w, -5.w),
                            customButton: Container(
                              width: 80.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.w),
                                  color: Colors.white),
                              alignment: Alignment.center,
                              child: centRow([
                                Image.asset(
                                  assetsName("product_store/icon_filter"),
                                  width: 14.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                gwb(5),
                                getSimpleText("筛选", 14, AppColor.textBlack)
                              ]),
                            ),
                            items: List.generate(
                                controller.filterTypeList.length,
                                (index) => DropdownMenuItem<int>(
                                    value: index,
                                    child: centClm([
                                      SizedBox(
                                        height: 30.w,
                                        width: 90.w,
                                        child: Align(
                                          alignment: const Alignment(-1, 0),
                                          child: GetX<
                                                  StatisticsFacilitatorListController>(
                                              builder: (_) {
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(left: 11.w),
                                              child: getSimpleText(
                                                  "${controller.filterTypeList[index]["name"] ?? ""}",
                                                  12,
                                                  controller.filterTypeIdx ==
                                                          index
                                                      ? AppColor.textRed
                                                      : AppColor.textBlack),
                                            );
                                          }),
                                        ),
                                      ),
                                    ]))),
                            // value: ctrl.machineDataIdx,
                            value: controller.filterTypeIdx,
                            buttonWidth: 90.w,
                            buttonHeight: 50.w,
                            itemHeight: 30.w,
                            onChanged: (value) {
                              controller.filterTypeIdx = value;
                            },
                            itemPadding: EdgeInsets.zero,
                            dropdownPadding: EdgeInsets.zero,
                            // dropdownWidth: 90.w,
                            dropdownDecoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.w),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0x1A040000),
                                      // offset: Offset(0, 5.w),
                                      blurRadius: 5.w)
                                ])));
                  })
            ]),
            body: contentPage(context),
          )
        : contentPage(context);
  }

  Widget contentPage(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 55.w,
            child: Column(children: [
              ghb(15),
              GetX<StatisticsFacilitatorListController>(
                  init: StatisticsFacilitatorListController(),
                  builder: (controller) {
                    return centRow([
                      DropdownButtonHideUnderline(
                          child: DropdownButton2(
                              dropdownElevation: 0,
                              buttonElevation: 0,
                              offset: Offset(0, -5.w),
                              customButton: Container(
                                width: 90.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.w),
                                    color: Colors.white),
                                alignment: Alignment.center,
                                child: centRow([
                                  GetX<StatisticsFacilitatorListController>(
                                      builder: (_) {
                                    return getSimpleText(
                                        controller.teamTypes[controller
                                                .teamTypesIdx]["name"] ??
                                            "",
                                        12,
                                        AppColor.textBlack);
                                  }),
                                  gwb(12),
                                  Image.asset(
                                    assetsName("income/btn_down_arrow"),
                                    width: 6.w,
                                    fit: BoxFit.fitWidth,
                                  )
                                ]),
                              ),
                              items: List.generate(
                                  controller.teamTypes.length,
                                  (index) => DropdownMenuItem<int>(
                                      value: index,
                                      child: centClm([
                                        SizedBox(
                                          height: 30.w,
                                          width: 90.w,
                                          child: Align(
                                            alignment: const Alignment(-1, 0),
                                            child: GetX<
                                                    StatisticsFacilitatorListController>(
                                                builder: (_) {
                                              return Padding(
                                                padding:
                                                    EdgeInsets.only(left: 11.w),
                                                child: getSimpleText(
                                                    "${controller.teamTypes[index]["name"] ?? ""}",
                                                    12,
                                                    controller.teamTypesIdx ==
                                                            index
                                                        ? AppColor.textRed
                                                        : AppColor.textBlack),
                                              );
                                            }),
                                          ),
                                        ),
                                      ]))),
                              // value: ctrl.machineDataIdx,
                              value: controller.teamTypesIdx,
                              buttonWidth: 90.w,
                              buttonHeight: 60.w,
                              itemHeight: 30.w,
                              onChanged: (value) {
                                controller.teamTypesIdx = value;
                              },
                              itemPadding: EdgeInsets.zero,
                              dropdownPadding: EdgeInsets.zero,
                              // dropdownWidth: 90.w,
                              dropdownDecoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.w),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0x1A040000),
                                        // offset: Offset(0, 5.w),
                                        blurRadius: 5.w)
                                  ]))),
                      gwb(10),
                      Container(
                          width: 245.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.w)),
                          child: Row(children: [
                            gwb(3),
                            CustomButton(
                              onPressed: () {
                                takeBackKeyboard(context);
                                controller.loadData();
                              },
                              child: SizedBox(
                                width: 36.w,
                                height: 40.w,
                                child: Center(
                                  child: Image.asset(
                                    assetsName("machine/icon_search"),
                                    width: 18.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                            CustomInput(
                              textEditCtrl: controller.searchInputCtrl,
                              width: (245 -
                                      3 -
                                      36 -
                                      1 -
                                      0.1 -
                                      (controller.needCleanInput ? 40 : 0))
                                  .w,
                              heigth: 40.w,
                              placeholder: "请输入想要搜索的名称或手机号",
                              placeholderStyle: TextStyle(
                                  fontSize: 12.sp, color: AppColor.assisText),
                              style: TextStyle(
                                  fontSize: 12.sp, color: AppColor.text),
                              onSubmitted: (p0) {
                                takeBackKeyboard(context);
                                controller.loadData();
                              },
                            ),
                            controller.needCleanInput
                                ? CustomButton(
                                    onPressed: () {
                                      controller.searchInputCtrl.clear();
                                    },
                                    child: SizedBox(
                                      width: 40.w,
                                      height: 40.w,
                                      child: Center(
                                        child: Image.asset(
                                          assetsName(
                                              "statistics/machine/icon_phone_delete"),
                                          width: 20.w,
                                          height: 20.w,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  )
                                : gwb(0)
                          ]))
                    ]);
                  })
            ])),
        Positioned.fill(
            top: 55.w,
            child: GetBuilder<StatisticsFacilitatorListController>(
                init: StatisticsFacilitatorListController(),
                builder: (controller) {
                  return EasyRefresh.builder(
                      onLoad: controller.dataList.length >= controller.count
                          ? null
                          : () => controller.loadData(isLoad: true),
                      onRefresh: () => controller.loadData(),
                      childBuilder: (context, physics) {
                        return controller.dataList.isEmpty
                            ? GetX<StatisticsFacilitatorListController>(
                                builder: (controller) {
                                  return controller.isFirstLoading && !kIsWeb
                                      ? SkeletonListView(
                                          padding: EdgeInsets.all(15.w),
                                        )
                                      : CustomListEmptyView(
                                          physics: physics,
                                          isLoading: controller.isLoading,
                                        );
                                },
                              )
                            : ListView.builder(
                                physics: physics,
                                padding: EdgeInsets.only(bottom: 20.w),
                                itemCount: controller.dataList.length,
                                itemBuilder: (context, index) {
                                  return cell(index, controller.dataList[index],
                                      controller);
                                },
                              );
                      });
                }))
      ],
    );
  }

  Widget cell(
      int index, Map data, StatisticsFacilitatorListController controller) {
    bool open = data["open"] ?? false;
    int cellCount = 5;
    bool isZs = (data["location"] ?? 0) <= 1;
    return UnconstrainedBox(
      child: CustomButton(
        onPressed: () {
          push(StatisticsFacilitatorDetail(isDirectly: isZs, teamData: data),
              null,
              binding: StatisticsFacilitatorDetailBinding());
        },
        child: AnimatedContainer(
          margin: EdgeInsets.only(top: 15.w),
          duration: const Duration(milliseconds: 300),
          width: 345.w,
          // height: open ? 75.w + 25.w + cellCount * 23.w + 45.w + 45.w : 165.w,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 75.w,
                  child: Center(
                    child: sbRow([
                      centRow([
                        gwb(15),
                        SizedBox(
                          width: 45.w,
                          height: isZs ? 55.w : 45.w,
                          child: Stack(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(45.w / 2),
                                  child: CustomNetworkImage(
                                    src: AppDefault().imageUrl +
                                        (data["u_Avatar"] ?? ""),
                                    width: 45.w,
                                    height: 45.w,
                                    fit: BoxFit.cover,
                                    errorWidget: Image.asset(
                                        assetsName("common/default_head"),
                                        width: 45.w,
                                        height: 45.w,
                                        fit: BoxFit.fill),
                                  )),
                              !isZs
                                  ? gemp()
                                  : Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                          width: 43.w,
                                          height: 18.w,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFFF8D40),
                                              borderRadius:
                                                  BorderRadius.circular(4.w)),
                                          child: getSimpleText(
                                              "直属", 12, Colors.white)),
                                    )
                            ],
                          ),
                        ),
                        gwb(9.5),
                        centClm([
                          centRow([
                            getSimpleText(
                                data["u_Name"] != null &&
                                        data["u_Name"].isNotEmpty
                                    ? data["u_Name"]
                                    : data["u_Mobile"] ?? "",
                                15,
                                AppColor.text2,
                                isBold: true),
                            gwb(5),
                            Image.asset(
                              assetsName(
                                  "mine/vip/level${data["u_Level"] ?? 1}"),
                              width: 31.5.w,
                              fit: BoxFit.fitWidth,
                            ),
                            getSimpleText(data["uLevelName"] ?? "", 10,
                                const Color(0xFFBB5D10))
                          ]),
                          ghb(5),
                          getSimpleText(hidePhoneNum(data["u_Mobile"] ?? ""),
                              12, AppColor.text2),
                        ], crossAxisAlignment: CrossAxisAlignment.start)
                      ]),
                      isZs
                          ? gwb(0)
                          : Padding(
                              padding: EdgeInsets.only(right: 15.w),
                              child: getSimpleText(
                                  "所属团队：${data["t_Name"] ?? ""}",
                                  12,
                                  AppColor.textGrey5),
                            )
                    ],
                        width: 345,
                        crossAxisAlignment: CrossAxisAlignment.start),
                  ),
                ),
                AnimatedContainer(
                  height: open ? 25.w + cellCount * 23.w + 45.w : 45.w,
                  width: 315.w,
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                      color: AppColor.pageBackgroundColor,
                      borderRadius: BorderRadius.circular(4.w)),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        CustomButton(
                          onPressed: () {
                            data["open"] = !open;
                            controller.update();
                          },
                          child: sbhRow([
                            Padding(
                              padding: EdgeInsets.only(left: 15.5.w),
                              child: Text.rich(TextSpan(
                                  text:
                                      "月交易量(${(data["teamThisMAmount"] ?? 0) >= 100000 ? "万" : ""}元)：",
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColor.text2,
                                      fontWeight: AppDefault.fontBold),
                                  children: [
                                    TextSpan(
                                        text: priceFormat(
                                            data["teamThisMAmount"] ?? 0,
                                            savePoint: 2,
                                            tenThousand:
                                                (data["teamThisMAmount"] ??
                                                        0) >=
                                                    100000,
                                            tenThousandUnit: false),
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColor.red,
                                            fontWeight: AppDefault.fontBold)),
                                  ])),
                            ),
                            SizedBox(
                              width: 31.w,
                              height: 45.w,
                              child: Center(
                                  child: AnimatedRotation(
                                turns: open ? 0.5 : 1,
                                duration: const Duration(milliseconds: 200),
                                child: Image.asset(
                                  assetsName("statistics_page/icon_cell_open"),
                                  width: 18.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              )),
                            ),
                          ], width: 315, height: 45),
                        ),
                        gline(300, 0.5, color: const Color(0xFFDFDFDF)),
                        SizedBox(
                          width: 315.w,
                          height: 25.w + cellCount * 23.w,
                          child: (data["isLoading"] ?? false)
                              ? Center(
                                  child: kIsWeb
                                      ? CustomEmptyView(
                                          isLoading:
                                              (data["isLoading"] ?? false),
                                          topSpace: 20,
                                          bottomSpace: 20,
                                          centerSpace: 10)
                                      : SkeletonParagraph(
                                          style: SkeletonParagraphStyle(
                                              padding: EdgeInsets.only(
                                                  top: 15.w,
                                                  left: 15.w,
                                                  right: 15.w),
                                              lines: cellCount,
                                              spacing: 13.w,
                                              lineStyle: SkeletonLineStyle(
                                                // randomLength: true,
                                                // width: 265.w,
                                                height: 10.w,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                // minLength: 150.w,
                                                // maxLength: 160.w,
                                              )),
                                        ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(cellCount, (index) {
                                    String t1 = "";
                                    String t2 = "";

                                    switch (index) {
                                      case 0:
                                        t1 = "日交易量(元)";
                                        t2 = priceFormat(
                                            data["teamThisDAmount"] ?? 0);
                                        break;
                                      case 1:
                                        t1 = "月激活台数";
                                        t2 =
                                            "${data["actTermiMonthNum"] ?? 0}台/月";
                                        break;
                                      case 2:
                                        t1 = "日激活台数";
                                        t2 =
                                            "${data["teamThisDActTerminal"] ?? 0}台/日";
                                        break;
                                      case 3:
                                        t1 = "月返现台数";
                                        t2 =
                                            "${data["serverTermiMonthNum"] ?? 0}台/月";
                                        break;
                                      case 4:
                                        t1 = "日返现台数";
                                        t2 =
                                            "${data["serverTeamThisDTerminal"] ?? 0}台/日";
                                        break;
                                    }

                                    return sbhRow([
                                      getSimpleText(t1, 12, AppColor.text3),
                                      getSimpleText(t2, 12, AppColor.text2),
                                    ], width: 315 - 15 * 2, height: 23);
                                  }),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                ghb(15)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
