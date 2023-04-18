import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MybusinessTransactionListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MybusinessTransactionListController>(
        MybusinessTransactionListController());
  }
}

class MybusinessTransactionListController extends GetxController {
  RefreshController pullCtrl = RefreshController();

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;
  String startAndEndDateBtnBuildId =
      "MybusinessTransactionListController_startAndEndDateBtnBuildId";

  String dealTypeBuildId =
      "MybusinessTransactionListController_dealTypeBuildId";
  String datePickBuildId =
      "MybusinessTransactionListController_datePickBuildId";

  List transactionListData = [
    // {
    //   "date": "2021年09月12日",
    //   "time": "13:17:55",
    //   "money": 1000000.00,
    //   "type": "信用卡",
    //   "state": 0,
    //   "no": "8483982585872192",
    //   "seq": "100317922144",
    //   "cardNo": "625153****8965",
    //   "cardType": "信用卡",
    //   "serviceCharge": 2.72
    // },
    // {
    //   "date": "2021年09月12日",
    //   "time": "13:17:55",
    //   "money": 1000000.00,
    //   "type": "信用卡",
    //   "state": 0,
    //   "no": "8483982585872192",
    //   "seq": "100317922144",
    //   "cardNo": "625153****8965",
    //   "cardType": "信用卡",
    //   "serviceCharge": 2.72
    // },
    // {
    //   "date": "2021年09月12日",
    //   "time": "13:17:55",
    //   "money": 1000000.00,
    //   "type": "信用卡",
    //   "state": 0,
    //   "no": "8483982585872192",
    //   "seq": "100317922144",
    //   "cardNo": "625153****8965",
    //   "cardType": "信用卡",
    //   "serviceCharge": 2.72
    // },
  ];

  resetFilter(int index) {
    if (index == 0) {
      DateTime dt = DateTime.now();
      start = dateFormat.format(dt.subtract(const Duration(days: 30)));
      currentDate = start;
      end = dateFormat.format(DateTime.now());
      activeDateIdx = 0;
      currentDate = start;
      update([startAndEndDateBtnBuildId, datePickBuildId]);
    } else {
      selectTypes = [];
      if (typeDatas.isNotEmpty) {
        for (var item in typeDatas) {
          item["selected"] = false;
        }
      }
      update([dealTypeBuildId]);
    }
  }

  List typeDatas = [];

  List selectTypes = [];
  final _topOpenIdx = RxInt(-1);
  int get topOpenIdx => _topOpenIdx.value;
  set topOpenIdx(v) => _topOpenIdx.value = v;

  bool timeFilterOpen = false;
  bool typeFilterOpen = false;

  final _activeDateIdx = 0.obs;

  int get activeDateIdx => _activeDateIdx.value;
  set activeDateIdx(v) {
    _activeDateIdx.value = v;
    update([startAndEndDateBtnBuildId]);
  }

  String start = "2022-05-30";
  String end = "2022-07-30";
  final _currentDate = "".obs;
  String get currentDate => _currentDate.value;
  set currentDate(v) => _currentDate.value = v;

  late CustomDropDownController _timeDropDownCtrl;
  late CustomDropDownController _typeDropDownCtrl;
  GlobalKey _stackKey = GlobalKey();
  GlobalKey _headKey = GlobalKey();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  void showOrHideFilter(int idx) {
    // FocusScope.of(context).requestFocus(FocusNode());
    // if (topOpenIdx > 0) {
    //   // filterShow = false;
    //   _dropDownCtrl.hide();
    // } else {
    //   // filterShow = true;
    //   _dropDownCtrl.show(_stackKey, _headKey);
    // }
  }

  loadDealType() {
    simpleRequest(
      url: Urls.getTradeDataConfigList,
      params: {},
      success: (success, json) {
        if (success) {
          typeDatas = json["data"];
          update([dealTypeBuildId]);
        }
      },
      after: () {},
    );
  }

  int pageSize = 10;
  int pageNo = 1;
  int count = 0;

  onLoad() async {
    loadList(isLoad: true);
  }

  onRefresh() async {
    loadList();
  }

  loadList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    Map<String, dynamic> params = {
      "startingTime": start,
      "end_Time": end,
      // "pageSize": pageSize,
      // "pageNo": pageNo,
      "tNo": businessData["tNo"] ?? "",
      "tcId": businessData["tId"] ?? "",
    };
    if (selectTypes.isNotEmpty) {
      String tradeType = "";
      for (var i = 0; i < selectTypes.length; i++) {
        i == 0
            ? tradeType += selectTypes[i]
            : tradeType += ",${selectTypes[i]}";
      }
      params["tradeType"] = tradeType;
    }
    simpleRequest(
      url: Urls.userMerchantOrderList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          count = data["count"] ?? 0;
          if (isLoad) {
            transactionListData = [...transactionListData, ...data["data"]];
            pullCtrl.loadComplete();
          } else {
            transactionListData = data["data"];
            pullCtrl.refreshCompleted();
          }
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  Map businessData = {};
  bool isFirst = true;
  dataInit(Map bData) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    businessData = bData;
    loadList();
  }

  @override
  void onInit() {
    resetFilter(0);

    _timeDropDownCtrl = CustomDropDownController();
    _typeDropDownCtrl = CustomDropDownController();
    loadDealType();
    super.onInit();
  }

  @override
  void dispose() {
    pullCtrl.dispose();
    _timeDropDownCtrl.dispose();
    _typeDropDownCtrl.dispose();
    super.dispose();
  }
}

class MybusinessTransactionList
    extends GetView<MybusinessTransactionListController> {
  final Map businessData;
  const MybusinessTransactionList({Key? key, this.businessData = const {}})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(businessData);
    return Scaffold(
      appBar: getDefaultAppBar(context, "交易信息"),
      body: Stack(
        key: controller._stackKey,
        children: [
          Positioned(
            key: controller._headKey,
            top: 0,
            left: 0,
            right: 0,
            height: 50.w,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom:
                          BorderSide(width: 0.5.w, color: AppColor.lineColor))),
              child: Row(
                children: [
                  topButton(0),
                  topButton(1),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50.w,
            left: 0,
            right: 0,
            bottom: 0,
            child: GetBuilder<MybusinessTransactionListController>(
              init: controller,
              initState: (_) {},
              builder: (_) {
                return SmartRefresher(
                  physics: const BouncingScrollPhysics(),
                  controller: controller.pullCtrl,
                  onLoading: controller.onLoad,
                  onRefresh: controller.onRefresh,
                  enablePullUp:
                      controller.count > controller.transactionListData.length,
                  child: controller.transactionListData.isEmpty
                      ? GetX<MybusinessTransactionListController>(
                          init: controller,
                          builder: (_) {
                            return CustomEmptyView(
                              isLoading: controller.isLoading,
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: controller.transactionListData != null
                              ? controller.transactionListData.length
                              : 0,
                          itemBuilder: (context, index) {
                            return MyBusinessTransactionCell(
                              index: index,
                              cellData: controller.transactionListData[index],
                            );
                          },
                        ),
                );
              },
            ),
          ),
          CustomDropDownView(
              dropdownMenuChange: (isShow) {
                if (!isShow) {
                  // setState(() {
                  controller.activeDateIdx = 0;
                  // });
                }
                controller.timeFilterOpen = isShow;
                if (!isShow && !controller.typeFilterOpen) {
                  controller.topOpenIdx = -1;
                }
              },
              dropDownCtrl: controller._timeDropDownCtrl,
              height: 400.w,
              dropWidget: SizedBox(
                width: 375.w,
                height: 400.w,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: gline(375, 1),
                    ),
                    Positioned(
                        top: 1,
                        left: 0,
                        right: 0,
                        bottom: 50,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ghb(25),
                              sbRow([
                                startAndEndDateBtn(0),
                                Icon(
                                  Icons.swap_horiz_rounded,
                                  color: const Color(0xFFCCCCCC),
                                  size: 25.w,
                                ),
                                startAndEndDateBtn(1),
                              ], width: 328),
                              SizedBox(
                                width: 375.w,
                                height: 265.w,
                                child: GetBuilder<
                                    MybusinessTransactionListController>(
                                  id: controller.datePickBuildId,
                                  init: controller,
                                  initState: (_) {},
                                  builder: (_) {
                                    return CupertinoDatePicker(
                                      key: ValueKey(
                                          "MybusinessTransactionListController_${controller.activeDateIdx}"),
                                      maximumYear: DateTime.now().year,
                                      minimumYear: DateTime.now().year - 10,
                                      minimumDate: DateTime.now().subtract(
                                          const Duration(days: 365 * 10)),
                                      maximumDate: DateTime.now(),
                                      initialDateTime: controller.dateFormat
                                          .parse(controller.currentDate),
                                      mode: CupertinoDatePickerMode.date,
                                      dateOrder: DatePickerDateOrder.ymd,
                                      onDateTimeChanged: (value) {
                                        if (value.isAfter(DateTime.now())) {
                                          ShowToast.normal("不能选择超过当前时间，请重新选择");
                                          return;
                                        }
                                        if (controller.activeDateIdx == 1) {
                                          if (controller.dateFormat
                                              .parse(controller.start)
                                              .isAfter(value)) {
                                            ShowToast.normal(
                                                "截止时间不能小于开始时间，请重新选择");
                                            return;
                                          }
                                        } else {
                                          if (controller.dateFormat
                                              .parse(controller.end)
                                              .isBefore(value)) {
                                            ShowToast.normal(
                                                "开始时间不能大于截止时间，请重新选择");
                                            return;
                                          }
                                        }
                                        // setState(() {
                                        if (controller.activeDateIdx == 0) {
                                          controller.start = controller
                                              .dateFormat
                                              .format(value);
                                        } else {
                                          controller.end = controller.dateFormat
                                              .format(value);
                                        }
                                        controller.update([
                                          controller.startAndEndDateBtnBuildId
                                        ]);
                                        // });
                                        if (AppDefault.isDebug) {
                                          print("CupertinoDatePicker == ");
                                        }
                                      },
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        )),
                    Positioned(
                        left: 0,
                        right: 0,
                        height: 50.w,
                        bottom: 0,
                        child: Row(
                          children: [
                            filterBottomButton(0, 0),
                            filterBottomButton(0, 1)
                          ],
                        )),
                  ],
                ),
              )),
          CustomDropDownView(
              dropdownMenuChange: (isShow) {
                controller.typeFilterOpen = isShow;
                if (!isShow && !controller.timeFilterOpen) {
                  // setState(() {
                  controller.topOpenIdx = -1;
                  // });
                }
              },
              dropDownCtrl: controller._typeDropDownCtrl,
              height: 278.w,
              dropWidget: SizedBox(
                width: 375.w,
                height: 278.w,
                child: Stack(
                  children: [
                    Positioned(
                        top: 18.w,
                        right: 24.w,
                        left: 24.w,
                        bottom: 50.w,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              GetBuilder<MybusinessTransactionListController>(
                                id: controller.dealTypeBuildId,
                                builder: (_) {
                                  return Wrap(
                                    spacing: (375 - 24 * 2 - 155 * 2).w,
                                    runSpacing: 16.w,
                                    children: controller.typeDatas
                                        .map((e) => typeButton(e))
                                        .toList(),
                                  );
                                },
                              ),
                              ghb(15)
                            ],
                          ),
                        )),
                    Positioned(
                        left: 0,
                        right: 0,
                        height: 50.w,
                        bottom: 0,
                        child: Row(
                          children: [
                            filterBottomButton(1, 0),
                            filterBottomButton(1, 1)
                          ],
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget typeButton(Map e) {
    return CustomButton(
      onPressed: () {
        e["selected"] = !e["selected"];
        e["selected"]
            ? controller.selectTypes.add(e["id"])
            : controller.selectTypes.remove(e["id"]);

        controller
            .update(["MybusinessTransactionListController_typeButtonBuildId"]);
      },
      child: GetBuilder<MybusinessTransactionListController>(
        init: controller,
        id: "MybusinessTransactionListController_typeButtonBuildId",
        initState: (_) {},
        builder: (_) {
          return Container(
            width: 155.w,
            height: 40.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.w),
                color: e["selected"]
                    ? (AppDefault().getThemeColor() ?? AppColor.theme)
                    : const Color(0xFFF5F5F5)),
            child: Center(
              child: getSimpleText(e["text"], 16,
                  e["selected"] ? Colors.white : AppColor.textBlack),
            ),
          );
        },
      ),
    );
  }

  Widget startAndEndDateBtn(int idx) {
    return CustomButton(
      onPressed: () {
        controller.currentDate = (idx == 0 ? controller.start : controller.end);
        controller.activeDateIdx = idx;
        controller.update(
            [controller.startAndEndDateBtnBuildId, controller.datePickBuildId]);
      },
      child: GetBuilder<MybusinessTransactionListController>(
        init: controller,
        id: controller.startAndEndDateBtnBuildId,
        initState: (_) {},
        builder: (_) {
          return Container(
            width: 130.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: idx == controller.activeDateIdx
                  ? const Color(0xFFFB5252)
                  : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(5.w),
            ),
            child: Center(
              child: centClm([
                getSimpleText(
                    "${idx == 0 ? "起始" : "截止"}时间",
                    15,
                    idx == controller.activeDateIdx
                        ? Colors.white
                        : const Color(0xFF808080)),
                ghb(5),
                getSimpleText(
                    idx == 0 ? controller.start : controller.end,
                    15,
                    idx == controller.activeDateIdx
                        ? Colors.white
                        : const Color(0xFF808080)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget topButton(int idx) {
    return CustomButton(
      onPressed: () {
        if (idx == 0) {
          if (controller.timeFilterOpen) {
            // timeFilterOpen = false;
            controller._timeDropDownCtrl.hide();
          } else {
            if (controller.typeFilterOpen) {
              // typeFilterOpen = false;
              controller._typeDropDownCtrl.hide();
            }
            // timeFilterOpen = true;
            controller._timeDropDownCtrl
                .show(controller._stackKey, controller._headKey);
          }
        } else {
          if (controller.typeFilterOpen) {
            // typeFilterOpen = false;
            controller._typeDropDownCtrl.hide();
          } else {
            if (controller.timeFilterOpen) {
              // timeFilterOpen = false;
              controller._timeDropDownCtrl.hide();
            }
            // typeFilterOpen = true;
            controller._typeDropDownCtrl
                .show(controller._stackKey, controller._headKey);
          }
        }

        if (idx == controller.topOpenIdx) {
          controller.topOpenIdx = -1;
        } else {
          controller.topOpenIdx = idx;
        }

        // setState(() {

        // });
      },
      child: SizedBox(
        height: 50.w,
        width: (375 / 2).w,
        child: GetX<MybusinessTransactionListController>(
          init: controller,
          initState: (_) {},
          builder: (_) {
            return Center(
              child: centRow([
                getSimpleText(
                    idx == 0 ? "交易时间" : "交易类型",
                    15,
                    controller.topOpenIdx == idx
                        ? AppColor.buttonTextBlue
                        : AppColor.textBlack),
                Icon(
                  Icons.arrow_drop_down_sharp,
                  color: controller.topOpenIdx == idx
                      ? AppColor.buttonTextBlue
                      : AppColor.textBlack,
                )
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget filterBottomButton(int type, int idx) {
    return CustomButton(
      onPressed: () {
        if (idx == 1) {
          controller.loadList();
          type == 0
              ? controller._timeDropDownCtrl.hide()
              : controller._typeDropDownCtrl.hide();
        } else {
          controller.resetFilter(type);
        }
      },
      child: Container(
        width: 375.w / 2,
        height: 50.w,
        decoration: BoxDecoration(
            color: idx == 0
                ? Colors.white
                : (AppDefault().getThemeColor() ?? AppColor.theme),
            border:
                Border(top: BorderSide(width: 1.w, color: AppColor.lineColor))),
        child: Center(
          child: getSimpleText(idx == 0 ? "重置" : "确认", 15,
              idx == 0 ? AppColor.textBlack : Colors.white,
              isBold: true),
        ),
      ),
    );
  }
}

class MyBusinessTransactionCell extends StatefulWidget {
  final Map cellData;
  final int? index;
  const MyBusinessTransactionCell(
      {Key? key, this.cellData = const {}, this.index})
      : super(key: key);

  @override
  State<MyBusinessTransactionCell> createState() =>
      _MyBusinessTransactionCellState();
}

class _MyBusinessTransactionCellState extends State<MyBusinessTransactionCell>
    with TickerProviderStateMixin {
  double cell2Gap = 15;

  Animation<double>? _animation;
  AnimationController? _animationCtrl;
  Animation<double>? _arrowAnimation;
  AnimationController? _arrowAnimationCtrl;
  bool isOpen = false;
  double cellHeight = 108;
  double animationHeight = 236;

  @override
  void initState() {
    _arrowAnimationCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _arrowAnimation =
        Tween<double>(begin: 0, end: 0.5).animate(_arrowAnimationCtrl!);

    _animationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
  }

  void _animationListener() {
    setState(() {});
  }

  _showDropDownItemWidget() {
    _animation?.removeListener(_animationListener);
    _animation = Tween(begin: 0.0, end: animationHeight.w)
        .animate(_animationCtrl!)
      ..addListener(_animationListener);

    if (isOpen) {
      _animationCtrl!.reverse();
      _arrowAnimationCtrl!.reverse();
    } else if (!isOpen) {
      _animationCtrl!.forward();
      _arrowAnimationCtrl!.forward();
    } else {
      _animationCtrl!.value = 0;
      _arrowAnimationCtrl!.value = 0;
    }
  }

  @override
  void dispose() {
    _animation?.removeListener(_animationListener);
    _animationCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0.w),
      child: SizedBox(
        height: cellHeight.w + (_animation != null ? _animation!.value : 0),
        width: 345.w,
        child: Stack(
          children: [
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: animationHeight.w,
                child: Container(
                  width: 345.w,
                  height: animationHeight.w,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5))),
                  child: Column(
                    children: [
                      ghb(19),
                      sbCell(
                          getSimpleText("出款状态", 14, AppColor.textGrey2,
                              fw: FontWeight.w500),
                          getSimpleText(
                            widget.cellData["txnState"] ?? "",
                            14,
                            const Color(0xFFDD1616),
                            isBold: true,
                          )),
                      ghb(cell2Gap),
                      sbCell(
                          getSimpleText("商户号", 14, AppColor.textGrey2,
                              fw: FontWeight.w500),
                          getSimpleText(widget.cellData["merchantsNO"] ?? "",
                              14, AppColor.textBlack,
                              isBold: true)),
                      ghb(cell2Gap),
                      sbCell(
                          getSimpleText("交易流水号", 14, AppColor.textGrey2,
                              fw: FontWeight.w500),
                          getSimpleText(widget.cellData["tradeNo"], 14,
                              AppColor.textBlack,
                              isBold: true)),
                      ghb(cell2Gap),
                      sbCell(
                          getSimpleText("卡号", 14, AppColor.textGrey2,
                              fw: FontWeight.w500),
                          getSimpleText(
                              widget.cellData["cardNo"], 14, AppColor.textBlack,
                              isBold: true)),
                      ghb(cell2Gap),
                      sbCell(
                          getSimpleText("卡类型", 14, AppColor.textGrey2,
                              fw: FontWeight.w500),
                          getSimpleText(widget.cellData["cardType"], 14,
                              AppColor.textBlack,
                              isBold: true)),
                      ghb(cell2Gap),
                      sbCell(
                          getSimpleText("手续费金额", 14, AppColor.textGrey2,
                              fw: FontWeight.w500),
                          getSimpleText(priceFormat(widget.cellData["txnFee"]),
                              14, AppColor.textBlack,
                              isBold: true)),
                    ],
                  ),
                )),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: cellHeight.w,
              child: GestureDetector(
                onTap: () {
                  _showDropDownItemWidget();
                  isOpen = !isOpen;
                },
                child: Container(
                  width: 345.w,
                  height: cellHeight.w,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5))),
                  child: Column(
                    children: [
                      ghb(17),
                      gwb(345),
                      sbCell(
                          getSimpleText(widget.cellData["txnTime"], 15,
                              AppColor.textBlack,
                              isBold: true),
                          // getSimpleText(
                          //     widget.cellData!["time"], 15, AppColor.textBlack,
                          //     fw: FontWeight.w500)
                          gwb(0)),
                      ghb(7),
                      sbCell(
                          getSimpleText(
                              "交易金额：${priceFormat(widget.cellData["txnAmt"])}元",
                              15,
                              const Color(0xFFF34A3D),
                              isBold: true),
                          const SizedBox()),
                      ghb(7),
                      sbCell(
                        getSimpleText("交易类型：${widget.cellData["tradeType"]}",
                            15, AppColor.textBlack,
                            isBold: true),
                        RotationTransition(
                          turns: _arrowAnimation!,
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 25.w,
                            color: AppColor.textGrey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget sbCell(Widget w1, Widget w2) {
    return sbRow([w1, w2], width: 309);
  }
}
