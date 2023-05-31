import 'dart:convert' as convert;
import 'dart:io';

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/product/product_store/product_store_detail.dart';
import 'package:cxhighversion2/product/product_store/product_store_order_list.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

class ProductStoreListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductStoreListController>(
        ProductStoreListController(datas: Get.arguments));
  }
}

class ProductStoreListController extends GetxController {
  final dynamic datas;
  ProductStoreListController({this.datas});
  // 是否加载中
  final _isLoading = false.obs;
  set isLoading(value) => _isLoading.value = value;
  bool get isLoading => _isLoading.value;
  // 是否首次加载
  final _isFirstLoading = true.obs;
  set isFirstLoading(value) => _isFirstLoading.value = value;
  bool get isFirstLoading => _isFirstLoading.value;

  // 是否列表模式
  final _isList = false.obs;
  set isList(value) => _isList.value = value;
  get isList => _isList.value;

  /// 是否显示清除搜索文字按钮
  bool get needCleanInput => _needCleanInput.value;
  final _needCleanInput = false.obs;
  set needCleanInput(v) => _needCleanInput.value = v;

  /// 机具兑换 顶部按钮index
  int get exchangeTopBtnIdx => _exchangeTopBtnIdx.value;
  final _exchangeTopBtnIdx = 0.obs;
  set exchangeTopBtnIdx(v) {
    if (_exchangeTopBtnIdx.value != v) {
      _exchangeTopBtnIdx.value = v;
      loadData();
    }
  }

  /// 机具兑换 顶部排序按钮index
  int get exchangeSortIdx => _exchangeSortIdx.value;
  final _exchangeSortIdx = 0.obs;
  set exchangeSortIdx(v) => _exchangeSortIdx.value = v;

  /// 机具兑换 型号index
  int get xhFilterSelectIdx => _xhFilterSelectIdx.value;
  final _xhFilterSelectIdx = (-1).obs;
  set xhFilterSelectIdx(v) => _xhFilterSelectIdx.value = v;

  /// 机具兑换 确认的型号index
  int xhRealFilterSelectIdx = -1;

  /// 机具兑换 品牌index
  int get brandFilterSelectIdx => _brandFilterSelectIdx.value;
  final _brandFilterSelectIdx = (-1).obs;
  set brandFilterSelectIdx(v) => _brandFilterSelectIdx.value = v;

  /// 机具兑换 确认的品牌index
  int brandRealFilterSelectIdx = -1;

  final searchInputCtrl = TextEditingController();
  searchInputListener() {
    needCleanInput = searchInputCtrl.text.isNotEmpty;
  }

  // 机具品牌数据
  final _brandList = Rx<List>([]);
  List get brandList => _brandList.value;
  set brandList(v) => _brandList.value = v;
  // 机具品牌tag的Key数组
  List<GlobalKey> keyList = [];
  // 机具品牌tag x轴坐标
  final _tagX = 0.0.obs;
  double get tagX => _tagX.value;
  set tagX(v) {
    if (_tagX.value != v) {
      _tagX.value = v;
    }
  }

  // 计算机具品牌tag x轴坐标
  changeTagPosition() {
    //延迟50毫秒
    Future.delayed(const Duration(milliseconds: 50), () {
      final RenderBox box = keyList[brandSelectIdx]
          .currentContext!
          .findRenderObject()! as RenderBox;
      final Offset tapPos = box.localToGlobal(Offset.zero);
      tagX = tapPos.dx + ((box.size.width / 2) - (18.w / 2)) + 7.5.w;
    });
    // print(tapPos.dx);
    // print(box.size.width);
  }

  // 下拉视图相关内容
  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();
  CustomDropDownController filterCtrl = CustomDropDownController();

  // 是否显示机具型号下拉视图
  final _isShowFilter = false.obs;
  bool get isShowFilter => _isShowFilter.value;
  set isShowFilter(v) => _isShowFilter.value = v;

  filterSelectAction(int clickIdx) {
    if (typeSelectIdx != clickIdx) {
      typeSelectIdx = clickIdx;
    } else {
      typeSelectIdx = -1;
    }

    // showFilter();
    loadData();
  }

  // 开关机具型号下拉视图
  showFilter() {
    // if (filterCtrl.isShow) {
    //   filterCtrl.hide();
    //   return;
    // }
    // filterCtrl.show(stackKey, headKey);
    isShowFilter = !isShowFilter;
  }

  // 机具品牌选择
  final _brandSelectIdx = 0.obs;
  int get brandSelectIdx => _brandSelectIdx.value;
  set brandSelectIdx(v) {
    if (_brandSelectIdx.value != v) {
      _brandSelectIdx.value = v;
      changeTagPosition();
      loadData();
    }
  }

  // 机具型号数据
  final _typeList = Rx<List>([]);
  List get typeList => _typeList.value;
  set typeList(v) => _typeList.value = v;

  // 机具型号选择
  final _typeSelectIdx = (-1).obs;
  int get typeSelectIdx => _typeSelectIdx.value;
  set typeSelectIdx(v) {
    if (_typeSelectIdx.value != v) {
      _typeSelectIdx.value = v;
      loadData();
    }
  }

  // 机具类型选择视图的高度
  final _typesViewHeight = 0.0.obs;
  double get typesViewHeight => _typesViewHeight.value;
  set typesViewHeight(v) => _typesViewHeight.value = v;

  int pageSize = 20;
  int pageNo = 1;
  int count = 0;
  List dataList = [];

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;

    Map<String, dynamic> params = {
      "pageNo": pageNo,
      "pageSize": pageSize,
      "level_Type": "$levelType"
    };
    if (brandSelectIdx > 0) {
      params["tbId"] = "${brandList[brandSelectIdx]["enumValue"]}";
    }
    if (typeSelectIdx >= 0) {
      params["tcId"] = "${typeList[typeSelectIdx]["id"]}";
    }
    if (dataList.isEmpty) {
      isLoading = true;
    }

    simpleRequest(
      url: Urls.memberList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List tmpDatas = data["data"] ?? [];
          dataList = isLoad ? [...dataList, ...tmpDatas] : tmpDatas;
          update();
        }
      },
      after: () {
        isLoading = false;
        isFirstLoading = false;
      },
    );
  }

  dateFormat() {
    Map publicHomeData = AppDefault().publicHomeData;
    List terminalBrands = publicHomeData["terminalBrand"] ?? [];
    if (terminalBrands.isNotEmpty) {
      brandList = [
        {"enumName": "全部", "enumValue": -1},
        ...terminalBrands.map((e) => {...e, "selected": false}).toList()
      ];
      for (var e in brandList) {
        keyList.add(GlobalKey());
      }
    }
    List terminalConfigs = publicHomeData["terminalConfig"] ?? [];
    if (terminalConfigs.isNotEmpty) {
      typeList = terminalConfigs.map((e) => {...e, "selected": false}).toList();
    }

    if (typeList.isNotEmpty) {
      int lineCount = (typeList.length / 5.0).ceil();
      typesViewHeight = lineCount * 70.w +
          (lineCount > 1 ? (lineCount - 1) * 12.w : 0) +
          19.w +
          15.w;
    }
    // List terminalMods = publicHomeData["terminalMod"] ?? [];
    // if (terminalMods.isNotEmpty) {
    //   xhList = [
    //     {"enumValue": -1, "enumName": "全部"},
    //     ...terminalMods
    //   ].map((e) => {...e, "selected": false}).toList();
    //   update([xhListBuildId]);
    // }
  }

  int levelType = 1;
  String title = "";
  @override
  void onInit() {
    // 1:礼包 2:采购 3:兑换
    levelType = (datas ?? {})["levelType"] ?? 1;
    title = (datas ?? {})["title"] ?? "";
    if (title.isEmpty) {
      title = "${levelType == 1 ? "礼包" : levelType == 2 ? "采购" : "兑换"}商城";
    }
    // 首次加载时获取tagX坐标
    tagX = (calculateTextSize("全部", 16, AppDefault.fontBold, double.infinity, 1,
                    Global.navigatorKey.currentContext!)
                .width) /
            2 -
        9.w +
        15.w +
        15.w;
    searchInputCtrl.addListener(searchInputListener);
    dateFormat();
    super.onInit();
  }

  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 200), () {
      loadData();
    });
    super.onReady();
  }

  @override
  void onClose() {
    searchInputCtrl.removeListener(searchInputListener);
    searchInputCtrl.dispose();
    filterCtrl.dispose();
    super.onClose();
  }
}

class ProductStoreList extends GetView<ProductStoreListController> {
  const ProductStoreList({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, controller.title,
            action: controller.levelType == 2
                ? [
                    CustomButton(
                      onPressed: () {
                        push(
                            const ProductStoreOrderList(
                              isBuyAndVip: true,
                            ),
                            null,
                            binding: ProductStoreOrderListBinding());
                      },
                      child: SizedBox(
                        width: 56.w,
                        height: kToolbarHeight,
                        child: centClm([
                          Image.asset(assetsName("product_store/btn_to_order"),
                              width: 15.w, height: 15.w, fit: BoxFit.fill),
                          getSimpleText("订单", 10, AppColor.textBlack)
                        ]),
                      ),
                    )
                  ]
                : null),
        body: Stack(
          // key: controller.stackKey,
          children: [
            controller.levelType == 1 ? gemp() : dropView(),
            controller.levelType == 1
                ? gemp()
                : Positioned(
                    // key: controller.headKey,
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 105.w,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ghb(10),
                          Row(children: [
                            gwb(15),
                            //搜索框
                            GetX<ProductStoreListController>(builder: (_) {
                              return Container(
                                width: 300.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                    color: AppColor.pageBackgroundColor,
                                    borderRadius: BorderRadius.circular(20.w)),
                                child: Row(
                                  children: [
                                    gwb(15),
                                    CustomInput(
                                      textEditCtrl: controller.searchInputCtrl,
                                      width: (300 -
                                              15 -
                                              36 -
                                              1 -
                                              0.1 -
                                              (controller.needCleanInput
                                                  ? 40
                                                  : 0))
                                          .w,
                                      heigth: 40.w,
                                      placeholder: "请输入想要搜索的产品名称",
                                      placeholderStyle: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColor.assisText),
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColor.text),
                                      onSubmitted: (p0) {
                                        takeBackKeyboard(context);
                                        controller.loadData();
                                      },
                                    ),
                                    controller.needCleanInput
                                        ? CustomButton(
                                            onPressed: () {
                                              controller.searchInputCtrl
                                                  .clear();
                                            },
                                            child: SizedBox(
                                              width: 40.w,
                                              height: 40.w,
                                              child: Center(
                                                child: Image.asset(
                                                  assetsName(
                                                      "statistics/machine/icon_phone_delete"),
                                                  width: 15.w,
                                                  height: 15.w,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          )
                                        : gwb(0),
                                    // 搜索按钮
                                    CustomButton(
                                      onPressed: () {
                                        takeBackKeyboard(context);
                                        controller.loadData();
                                      },
                                      child: SizedBox(
                                        width: 36.w,
                                        height: 40.w,
                                        child: Align(
                                          alignment: const Alignment(-0.9, 0),
                                          child: Image.asset(
                                            assetsName("machine/icon_search"),
                                            width: 18.w,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            // gwb(15),
                            // 切换列表按钮
                            CustomButton(
                              onPressed: () {
                                controller.isList = !controller.isList;
                              },
                              child: SizedBox(
                                width: 60.w,
                                height: 40.w,
                                child: Align(
                                    alignment: const Alignment(0.2, 0),
                                    child: GetX<ProductStoreListController>(
                                        builder: (_) {
                                      return Image.asset(
                                          assetsName(
                                              "product_store/btn_cell_${controller.isList ? "wrap" : "list"}"),
                                          width: 18.w,
                                          fit: BoxFit.fitWidth);
                                    })),
                              ),
                            ),
                          ]),

                          /// 品牌筛选 采购商城
                          controller.levelType == 2
                              ? brandSelectView()
                              : exchangeTopView()
                        ],
                      ),
                    )),
            GetX<ProductStoreListController>(
              builder: (_) {
                return AnimatedPositioned(
                    top: controller.levelType == 1
                        ? 0
                        : 106.w +
                            (controller.isShowFilter
                                ? controller.typesViewHeight + 5.w
                                : 0),
                    left: 0,
                    right: 0,
                    bottom: 0,
                    duration: const Duration(milliseconds: 300),
                    child: GetBuilder<ProductStoreListController>(builder: (_) {
                      return EasyRefresh.builder(
                          onLoad: controller.dataList.length >= controller.count
                              ? null
                              : () => controller.loadData(isLoad: true),
                          onRefresh: () => controller.loadData(),
                          childBuilder: (context, physics) {
                            return GetX<ProductStoreListController>(
                                builder: (_) {
                              return controller.isFirstLoading
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      enabled: true,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 15.w, left: 15.w),
                                            child: SizedBox(
                                              width: 345.w,
                                              child: Wrap(
                                                spacing: 10.w,
                                                runSpacing: 10.w,
                                                children: List.generate(
                                                    4,
                                                    (index) => Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.w)),
                                                        width:
                                                            (375 - 15 * 2 - 10)
                                                                        .w /
                                                                    2 -
                                                                0.1.w,
                                                        height: 255.w)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : controller.dataList.isEmpty
                                      ? CustomListEmptyView(
                                          physics: physics,
                                          isLoading: controller.isLoading)
                                      : ListView.builder(
                                          physics: physics,
                                          padding:
                                              EdgeInsets.only(bottom: 20.w),
                                          itemCount: controller.isList
                                              ? controller.dataList.length
                                              : (controller.dataList.length / 2)
                                                  .ceil(),
                                          itemBuilder: (context, index) {
                                            return controller.isList
                                                ? listCell(index)
                                                : wrapCell(index);
                                          });
                            });
                          });
                    }));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget listCell(int index) {
    Map data = controller.dataList[index];
    bool isReal = controller.levelType != 3;
    bool isBean = false;
    if (controller.levelType == 3) {
      List payTypes = convert.jsonDecode(data["levelGiftPaymentMethod"]);
      if (payTypes.isNotEmpty &&
          payTypes.length == 1 &&
          (payTypes[0]["value"] ?? 0) == 5) {
        isBean = true;
      }
    }

    double imageWidth = 127.5;

    return CustomButton(
      onPressed: () {
        push(const ProductStoreDetail(), null,
            binding: ProductStoreDetailBinding(),
            arguments: {"data": data, "levelType": controller.levelType});
      },
      child: Center(
        child: Container(
          width: 345.w,
          margin: EdgeInsets.only(top: 15.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5.w)),
          child: centClm([
            ghb(10),
            sbRow([
              centRow([
                CustomNetworkImage(
                    src: AppDefault().imageUrl + (data["levelGiftImg"] ?? ""),
                    width: imageWidth.w,
                    height: imageWidth.w,
                    fit: BoxFit.fill,
                    errorWidget: Container(
                      width: imageWidth.w,
                      height: imageWidth.w,
                      color: AppColor.pageBackgroundColor,
                    )),
                gwb(10),
                sbClm([
                  centClm([
                    getWidthText(data["levelName"] ?? "", 15,
                        AppColor.textBlack, 325 - 10 - imageWidth, 1,
                        isBold: true),
                    ghb(3),
                    getWidthText(data["levelDescribe"] ?? "", 13,
                        const Color(0xFF808080), 325 - 10 - imageWidth, 1,
                        isBold: true),
                  ]),
                  sbRow([
                    isBean
                        ? centRow([
                            Image.asset(
                              assetsName("home/store/icon_bean"),
                              width: 18.w,
                              fit: BoxFit.fitWidth,
                            ),
                            gwb(3),
                            getRichText(
                              priceFormat(data["nowPrice"] ?? 0, savePoint: 0),
                              " 起",
                              18,
                              const Color(0xFFFFB540),
                              12,
                              const Color(0xFFFFB540),
                              isBold: true,
                            ),
                            // getSimpleText(
                            //     "${priceFormat(data["nowPrice"] ?? 0, savePoint: 0)} 起",
                            //     18,
                            //     const Color(0xFFFFB540),
                            //     isBold: true),
                          ])
                        : getSimpleText(
                            "${isReal ? "￥" : ""}${priceFormat(data["nowPrice"] ?? 0, tenThousand: true)}起",
                            18,
                            const Color(0xFFF13030),
                            isBold: true),
                    Container(
                        width: 60.w,
                        height: 24.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppDefault().getThemeColor(index: 0) ??
                                      const Color(0xFFFD573B),
                                  AppDefault().getThemeColor(index: 2) ??
                                      const Color(0xFFFF3A3A),
                                ]),
                            borderRadius: BorderRadius.circular(12.w)),
                        child: getSimpleText(
                            controller.levelType == 1
                                ? "去升级"
                                : controller.levelType == 2
                                    ? "采购"
                                    : "兑换",
                            12,
                            Colors.white,
                            textHeight: Platform.isIOS ? 1.5 : 1.3))
                  ], width: 325 - 10 - imageWidth),
                ], height: 130),
              ]),
            ], width: 345 - 10 * 2),
            ghb(10),
          ]),
        ),
      ),
    );
  }

  Widget wrapCell(int index) {
    bool isReal = controller.levelType != 3;
    return Padding(
      padding: EdgeInsets.only(top: 15.w),
      child: Center(
        child: sbRow(
            List.generate(2, (cellIdx) {
              Map data = {};
              if (index * 2 + cellIdx <= controller.dataList.length - 1) {
                data = controller.dataList[index * 2 + cellIdx];
              }
              return data.isEmpty
                  ? gwb(0)
                  : CustomButton(
                      onPressed: () {
                        push(const ProductStoreDetail(), null,
                            binding: ProductStoreDetailBinding(),
                            arguments: {
                              "data": data,
                              "levelType": controller.levelType
                            });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 168.w,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.w)),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 168.w,
                              height: 168.w,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(5.w)),
                                        child: Container(
                                          color: const Color(0xFFF0F0F0),
                                          width: 168.w,
                                          height: 168.w,
                                          child: CustomNetworkImage(
                                            src: AppDefault().imageUrl +
                                                (data["levelGiftImg"] ?? ""),
                                            width: 168.w,
                                            height: 168.w,
                                            alignment: Alignment.center,
                                            fit: BoxFit.fill,
                                          ),
                                        )),
                                  ),
                                  // Positioned(
                                  //     left: 0,
                                  //     right: 0,
                                  //     bottom: 0,
                                  //     height: 25.w,
                                  //     child: Container(
                                  //       color: const Color(0xB2000000),
                                  //       child: Center(
                                  //         child: getSimpleText(
                                  //             data["levelDescribe"] ?? "",
                                  //             11,
                                  //             Colors.white,
                                  //             isBold: true),
                                  //       ),
                                  //     ))
                                ],
                              ),
                            ),
                            ghb(10),
                            // getWidthText(
                            //   cellData["levelName"] ?? "",
                            //   15,
                            //   AppColor.textBlack,
                            //   168 - 8 * 2,
                            //   1,
                            // ),
                            ghb(5),
                            getWidthText(data["levelName"] ?? "", 16,
                                AppColor.textBlack, 168 - 8 * 2, 1,
                                isBold: true),
                            ghb(5),
                            // getWidthText(
                            //   cellData["levelSubhead"] ?? "",
                            //   13,
                            //   const Color(0xFF808080),
                            //   168 - 8 * 2,
                            //   1,
                            // ),
                            ghb(15),
                            SizedBox(
                              width: (168 - 8 * 2).w,
                              child: getRichText(
                                  "${isReal ? "￥" : ""}${priceFormat(data["nowPrice"] ?? 0, tenThousand: true)}",
                                  "起",
                                  18,
                                  AppColor.integralTextRed,
                                  12,
                                  AppColor.integralTextRed,
                                  fw: AppDefault.fontBold),
                            ),
                            ghb(10),
                          ],
                        ),
                      ),
                    );
            }),
            width: 345),
      ),
    );
  }

  Widget dropView() {
    return GetX<ProductStoreListController>(builder: (_) {
      return AnimatedPositioned(
          top: 105.w -
              (controller.isShowFilter ? 0 : controller.typesViewHeight + 5.w),
          left: 0,
          right: 0,
          height:
              controller.isShowFilter ? controller.typesViewHeight + 5.w : 0,
          duration: const Duration(milliseconds: 300),
          child: typesFilterView());
    });
  }

  Widget typesFilterView() {
    return SingleChildScrollView(
      child: GetX<ProductStoreListController>(builder: (_) {
        return SizedBox(
          width: 375.w,
          height: controller.typesViewHeight + 5.w,
          child: Column(
            children: [
              ghb(5),
              Container(
                width: 375.w,
                color: Colors.white,
                child: Column(
                  children: [
                    ghb(19),
                    SizedBox(
                      width: 375.w - 8.w * 2,
                      child: Wrap(
                        runSpacing: 12.w,
                        children:
                            List.generate(controller.typeList.length, (index) {
                          Map data = controller.typeList[index];
                          return CustomButton(
                            onPressed: () {
                              controller.filterSelectAction(index);
                            },
                            child: SizedBox(
                              width: (375.w - 8.w * 2) / 5,
                              height: 70.w,
                              child: Center(
                                child: sbClm([
                                  Container(
                                    width: 50.w,
                                    height: 50.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.w,
                                            color: controller.typeSelectIdx ==
                                                    index
                                                ? AppColor.theme
                                                : Colors.transparent),
                                        borderRadius:
                                            BorderRadius.circular(25.w)),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(49.w / 2),
                                      child: CustomNetworkImage(
                                        src: AppDefault().imageUrl +
                                            (data["terninal_Pic"] ?? ""),
                                        width: 49.w,
                                        height: 49.w,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  getSimpleText(
                                      data["terninal_Name"] ?? "",
                                      10,
                                      controller.typeSelectIdx == index
                                          ? AppColor.theme
                                          : AppColor.textGrey5)
                                ], height: 70),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    ghb(15)
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  /// 品牌筛选 采购商城
  Widget brandSelectView() {
    return centClm([
      SizedBox(
        width: 375.w,
        height: 52.w,
        child: Center(
          child: Row(
            children: [
              SizedBox(
                  width: 325.w,
                  height: 52.w,
                  child: GetX<ProductStoreListController>(builder: (_) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      itemCount: controller.brandList.length,
                      itemBuilder: (context, index) {
                        return CustomButton(
                          key: controller.keyList[index],
                          onPressed: () {
                            controller.brandSelectIdx = index;
                          },
                          child: sbClm([
                            ghb(3),
                            Padding(
                              padding: EdgeInsets.only(left: 15.w),
                              child: GetX<ProductStoreListController>(
                                  builder: (_) {
                                return getSimpleText(
                                    controller.brandList[index]["enumName"] ??
                                        "",
                                    16,
                                    controller.brandSelectIdx == index
                                        ? AppColor.textBlack
                                        : AppColor.textGrey5,
                                    isBold: controller.brandSelectIdx == index);
                              }),
                            ),
                            ghb(0)
                          ], height: 53),
                        );
                      },
                    );
                  })),
              CustomButton(
                onPressed: () {
                  controller.showFilter();
                },
                child: SizedBox(
                  width: 50.w,
                  height: 52.w,
                  child: GetX<ProductStoreListController>(builder: (_) {
                    return centClm([
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: controller.isShowFilter ? 0.5 : 1,
                        child: Image.asset(
                            assetsName("product_store/btn_select_arrow"),
                            width: 18.w,
                            fit: BoxFit.fitWidth),
                      ),
                      getSimpleText(controller.isShowFilter ? "收回" : "展开", 10,
                          AppColor.textGrey5,
                          textHeight: 1.0)
                    ]);
                  }),
                ),
              )
            ],
          ),
        ),
      ),
      SizedBox(
        width: 375.w,
        height: 3.w,
        child: Stack(
          children: [
            GetX<ProductStoreListController>(builder: (context) {
              return AnimatedPositioned(
                  width: 18.w,
                  height: 3.w,
                  left: controller.tagX,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1.5.w),
                        color: AppColor.theme),
                  ));
            })
          ],
        ),
      )
    ]);
  }

  /// 机具兑换 顶部按钮
  Widget exchangeTopView() {
    double width = 375.w / 4;
    return sbRow([
      CustomButton(
          onPressed: () {
            controller.exchangeTopBtnIdx = 0;
          },
          child: SizedBox(
              width: width,
              height: 55.w,
              child:
                  Center(child: GetX<ProductStoreListController>(builder: (_) {
                return sbClm([
                  ghb(3),
                  getSimpleText(
                      "综合",
                      controller.exchangeTopBtnIdx == 0 ? 16 : 15,
                      AppColor.textBlack,
                      isBold: controller.exchangeTopBtnIdx == 0),
                  controller.exchangeTopBtnIdx == 0
                      ? Container(
                          width: 18.w,
                          height: 3.w,
                          decoration: BoxDecoration(
                              color: AppColor.theme,
                              borderRadius: BorderRadius.circular(1.5.w)))
                      : ghb(3)
                ], height: 55);
              })))),
      CustomButton(
        onPressed: () {
          controller.exchangeTopBtnIdx = 1;
          if (controller.exchangeSortIdx >= 2) {
            controller.exchangeSortIdx = 0;
          } else {
            controller.exchangeSortIdx++;
          }
        },
        child: SizedBox(
            width: width,
            height: 55.w,
            child: GetX<ProductStoreListController>(builder: (_) {
              return centRow([
                getSimpleText(
                    "兑换量",
                    controller.exchangeTopBtnIdx == 1 ? 16 : 15,
                    AppColor.textBlack,
                    isBold: controller.exchangeTopBtnIdx == 1),
                gwb(3),
                Transform.rotate(
                  angle: controller.exchangeSortIdx == 1 ? 0 : math.pi / 1,
                  child: Image.asset(
                      assetsName(
                          "product_store/icon_${controller.exchangeSortIdx == 0 ? "un" : ""}sort"),
                      width: 6.w,
                      fit: BoxFit.fitWidth),
                )
              ]);
            })),
      ),
      CustomButton(
        onPressed: () {
          showFilterModel();
        },
        child: SizedBox(
          width: width,
          height: 55.w,
          child: centRow([
            getSimpleText("筛选", 15, AppColor.textBlack),
            gwb(3),
            Image.asset(assetsName("product_store/icon_filter"),
                width: 10.5.w, fit: BoxFit.fitWidth)
          ]),
        ),
      )
    ], width: 375);
  }

  /// 机具兑换 底部筛选弹窗
  showFilterModel() {
    controller.brandFilterSelectIdx = controller.brandRealFilterSelectIdx;
    controller.xhFilterSelectIdx = controller.xhRealFilterSelectIdx;
    Get.bottomSheet(
        UnconstrainedBox(
            child: Container(
          width: 375.w,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.w))),
          child: Column(
            children: [
              sbhRow([
                gwb(42),
                getSimpleText("筛选", 18, AppColor.textBlack, isBold: true),
                CustomButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: SizedBox(
                      width: 42.w,
                      height: 53.w,
                      child: Center(
                          child: Image.asset(
                              assetsName("common/btn_model_close2"),
                              width: 14.w,
                              fit: BoxFit.fitWidth))),
                )
              ], width: 375, height: 53),
              gline(375, 1),
              sbhRow([
                getSimpleText("品牌", 15, AppColor.textBlack, isBold: true),
              ], width: 345, height: 57),
              SizedBox(
                  width: 345.w,
                  child: Wrap(
                      spacing: (345.w - 105.w * 3) / 2 - 0.1,
                      runSpacing: 10.w,
                      children: List.generate(
                          controller.brandList.length,
                          (index) => CustomButton(onPressed: () {
                                if (controller.brandFilterSelectIdx == index) {
                                  controller.brandFilterSelectIdx = -1;
                                } else {
                                  controller.brandFilterSelectIdx = index;
                                }
                              }, child: GetX<ProductStoreListController>(
                                  builder: (context) {
                                return Container(
                                    width: 105.w,
                                    height: 30.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.w),
                                        color:
                                            controller
                                                        .brandFilterSelectIdx ==
                                                    index
                                                ? null
                                                : const Color(0xFFFAFAFA),
                                        gradient: controller
                                                    .brandFilterSelectIdx ==
                                                index
                                            ? const LinearGradient(
                                                colors: [
                                                    Color(0xFFFD573B),
                                                    Color(0xFFFF3A3A)
                                                  ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter)
                                            : null),
                                    child: getSimpleText(
                                        controller.brandList[index]
                                                ["enumName"] ??
                                            "",
                                        12,
                                        controller.brandFilterSelectIdx == index
                                            ? Colors.white
                                            : AppColor.textBlack));
                              }))))),
              sbhRow(
                  [getSimpleText("机具型号", 15, AppColor.textBlack, isBold: true)],
                  width: 345, height: 57),
              SizedBox(
                  width: 345.w,
                  child: Wrap(
                      spacing: (345.w - 105.w * 3) / 2 - 0.1,
                      runSpacing: 10.w,
                      children: List.generate(
                          controller.typeList.length,
                          (index) => CustomButton(onPressed: () {
                                if (controller.xhFilterSelectIdx == index) {
                                  controller.xhFilterSelectIdx = -1;
                                } else {
                                  controller.xhFilterSelectIdx = index;
                                }
                              }, child: GetX<ProductStoreListController>(
                                  builder: (context) {
                                return Container(
                                    width: 105.w,
                                    height: 30.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4
                                            .w),
                                        color: controller
                                                    .xhFilterSelectIdx ==
                                                index
                                            ? null
                                            : const Color(0xFFFAFAFA),
                                        gradient: controller
                                                    .xhFilterSelectIdx ==
                                                index
                                            ? const LinearGradient(
                                                colors: [
                                                    Color(0xFFFD573B),
                                                    Color(0xFFFF3A3A)
                                                  ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter)
                                            : null),
                                    child: getSimpleText(
                                        controller.typeList[index]
                                                ["terninal_Name"] ??
                                            "",
                                        12,
                                        controller.xhFilterSelectIdx == index
                                            ? Colors.white
                                            : AppColor.textBlack));
                              }))))),
              ghb(24),
              centRow(List.generate(
                  2,
                  (index) => CustomButton(
                        onPressed: () {
                          if (index == 0) {
                            controller.brandFilterSelectIdx = -1;
                            controller.xhFilterSelectIdx = -1;
                          } else {
                            controller.brandRealFilterSelectIdx =
                                controller.brandFilterSelectIdx;
                            controller.xhRealFilterSelectIdx =
                                controller.xhFilterSelectIdx;
                            controller.loadData();
                            Get.back();
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                              bottom: paddingSizeBottom(
                                  Global.navigatorKey.currentContext!)),
                          width: 375.w / 2,
                          height: 55.w,
                          decoration: BoxDecoration(
                              color: index == 0
                                  ? AppColor.theme.withOpacity(0.1)
                                  : null,
                              gradient: index == 0
                                  ? null
                                  : const LinearGradient(
                                      colors: [
                                          Color(0xFFFD573B),
                                          Color(0xFFFF3A3A)
                                        ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter)),
                          child: getSimpleText(index == 0 ? "重置" : "确定", 15,
                              index == 0 ? AppColor.theme : Colors.white),
                        ),
                      )))
            ],
          ),
        )),
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true);
  }
}
