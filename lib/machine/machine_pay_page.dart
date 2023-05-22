import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/machine/machine_pay_confirm.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class MachinePayPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachinePayPageController>(
        MachinePayPageController(datas: Get.arguments));
  }
}

class MachinePayPageController extends GetxController {
  final dynamic datas;
  MachinePayPageController({this.datas});

  final _allSelected = false.obs;
  bool get allSelected => _allSelected.value;
  set allSelected(v) => _allSelected.value = v;

  final _payTypeIndex = 0.obs;
  int get payTypeIndex => _payTypeIndex.value;
  set payTypeIndex(v) => _payTypeIndex.value = v;

  final _pickIndex = 0.obs;
  int get pickIndex => _pickIndex.value;
  set pickIndex(v) => _pickIndex.value = v;

  final _isLoadding = false.obs;
  bool get isLoadding => _isLoadding.value;
  set isLoadding(v) => _isLoadding.value = v;

  final _isFirstLoadding = true.obs;
  bool get isFirstLoadding => _isFirstLoadding.value;
  set isFirstLoadding(v) => _isFirstLoadding.value = v;

  TextEditingController cellInput = TextEditingController();
  FocusNode node = FocusNode();

  int inputIndex = -1;

  List dataList = [];

  // RefreshController pullCtrl = RefreshController();

  List payTypeList = [];

  int pageNo = 1;
  int pageSize = 20;
  int count = 50;

  onLoad() {
    loadData(isLoad: true);
  }

  onRefresh() {
    loadData();
  }

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoadding = true;
    }
    simpleRequest(
      url: Urls.memberList,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
        // "level_Type": 2,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List requestDatas = data["data"] ?? [];
          dataList = isLoad ? [...dataList, ...requestDatas] : requestDatas;
          checkSelect();
          // isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();

          update();
        }
      },
      after: () {
        isLoadding = false;
        isFirstLoadding = false;
      },
    );
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   List requestDatas = [];
    //   for (var i = 0; i < pageSize; i++) {
    //     requestDatas.add({
    //       "id": 0,
    //       "name": "融享付大机",
    //       "xh": "YDQ",
    //       "price": 128.0,
    //       "img": "D0031/2023/1/202301311856422204X.png",
    //       "count": 3,
    //     });
    //   }

    //   for (var e in requestDatas) {
    //     e["selected"] = false;
    //     e["num"] = 1;
    //   }

    // });
  }

  allSelectAction() {
    checkSelect(allSelect: !allSelected);
    update();
  }

  checkSelect({bool? allSelect}) {
    if (dataList.isEmpty) {
      return;
    }
    bool isAllSelect = true;

    for (var e in dataList) {
      if (allSelect != null) {
        e["selected"] = allSelect;
        isAllSelect = allSelect;
      } else {
        if (!(e["selected"] ?? false)) {
          isAllSelect = false;
          break;
        }
      }
    }
    allSelected = isAllSelect;
  }

  payAction() {
    List selectList = [];
    for (var e in dataList) {
      if (e["selected"] ?? false) {
        selectList.add(e);
      }
    }
    if (selectList.isEmpty) {
      ShowToast.normal("请至少选择一件商品");
      return;
    }

    push(const MachinePayConfirm(), null,
        binding: MachinePayConfirmBinding(),
        arguments: {
          "machines": selectList,
          "payType": payTypeList[payTypeIndex]
        });
  }

  clickCellAction(Map data) {
    data["selected"] = !(data["selected"] ?? false);
    checkSelect();
    update();
  }

  @override
  void onInit() {
    payTypeIndex = ((datas ?? {})["isXh"] ?? false) ? 1 : 0;

    int myLevel = AppDefault().homeData["uL_Level"] ?? 1;
    if (myLevel < 3) {
      payTypeList = [
        {
          "id": 1,
          "name": "正常采购",
        },
      ];
    } else {
      payTypeList = [
        {
          "id": 1,
          "name": "正常采购",
        },
        {
          "id": 2,
          "name": "续约奖励采购",
        }
      ];
    }
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    cellInput.dispose();
    node.dispose();
    super.onClose();
  }

  bool keyborderIsShow = false;
  isShowOrHideKeyborder(bool show) {
    if (Get.currentRoute != "/MachinePayPage") {
      return;
    }
    if (keyborderIsShow != show) {
      keyborderIsShow = show;
      if (!keyborderIsShow) {
        if (int.tryParse(cellInput.text) == null) {
          ShowToast.normal("请输入正确的数量");
          inputIndex = -1;
          update();
          return;
        }
        int count = dataList[inputIndex]["levelGiftProductCount"] ?? 1;
        if (int.parse(cellInput.text) > count) {
          ShowToast.normal("输入数量超出该商品库存");
          dataList[inputIndex]["num"] = count;
          inputIndex = -1;
          update();
          return;
        } else if (int.parse(cellInput.text) == 0) {
          ShowToast.normal("最少选择一件哦");
          dataList[inputIndex]["num"] = 1;
          inputIndex = -1;
          update();
          return;
        }

        dataList[inputIndex]["num"] = int.parse(cellInput.text);
        inputIndex = -1;
        update();
      }
    }
  }

  showKeyborder(int index) {
    if (keyborderIsShow) {
      inputIndex = -1;
      update();
      node.nextFocus();
      return;
    }
    inputIndex = index;
    cellInput.text = "${dataList[index]["num"]}";
    update();
    node.requestFocus();
  }
}

class MachinePayPage extends StatefulWidget {
  const MachinePayPage({super.key});

  @override
  State<MachinePayPage> createState() => _MachinePayPageState();
}

class _MachinePayPageState extends State<MachinePayPage>
    with WidgetsBindingObserver {
  MachinePayPageController controller = Get.find<MachinePayPageController>();

  @override
  Widget build(BuildContext context) {
    bool isKeyboardShowing = MediaQuery.of(context).viewInsets.vertical > 0;
    controller.isShowOrHideKeyborder(isKeyboardShowing);
    return GestureDetector(
        onTap: () => takeBackKeyboard(context),
        child: Scaffold(
            appBar: getDefaultAppBar(context, "选择采购设备"),
            body: Stack(children: [
              Positioned(
                  width: 375.w,
                  bottom: 0,
                  height: 55.w + paddingSizeBottom(context),
                  child: Container(
                    padding:
                        EdgeInsets.only(bottom: paddingSizeBottom(context)),
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(color: const Color(0x0D000000), blurRadius: 5.w)
                    ]),
                    child: Center(
                      child: sbRow([
                        CustomButton(onPressed: () {
                          controller.allSelectAction();
                        }, child: GetX<MachinePayPageController>(
                          builder: (_) {
                            return centRow([
                              ghb(55),
                              Image.asset(
                                assetsName(
                                    "machine/checkbox_${controller.allSelected ? "selected" : "normal"}"),
                                width: 16.w,
                                fit: BoxFit.fitWidth,
                              ),
                              gwb(12),
                              getSimpleText(
                                  controller.allSelected ? "反选" : "全选",
                                  14,
                                  AppColor.text),
                            ]);
                          },
                        )),
                        CustomButton(
                          onPressed: () {
                            takeBackKeyboard(context);
                            controller.payAction();
                          },
                          child: Container(
                            width: 90.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              color: AppColor.theme,
                              borderRadius: BorderRadius.circular(15.w),
                            ),
                            child: Center(
                              child: getSimpleText("确认采购", 14, Colors.white,
                                  textHeight: 1.3),
                            ),
                          ),
                        )
                      ], width: 375 - 15 * 2),
                    ),
                  )),
              Positioned(
                  left: 15.w,
                  right: 15.w,
                  top: 15.w,
                  height: 60.w,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.w)),
                    child: Center(
                        child: sbRow([
                      getSimpleText("采购类型", 14, AppColor.text, textHeight: 1.3),
                      CustomButton(
                        onPressed: () {
                          showTypeSelectModel();
                        },
                        child: centRow([
                          ghb(60.w),
                          GetX<MachinePayPageController>(
                            builder: (_) {
                              return getSimpleText(
                                  controller
                                          .payTypeList[controller.payTypeIndex]
                                      ["name"],
                                  14,
                                  AppColor.text,
                                  textHeight: 1.3);
                            },
                          ),
                          gwb(5),
                          Image.asset(
                            assetsName("statistics/icon_arrow_right_gray"),
                            width: 12.w,
                            fit: BoxFit.fitWidth,
                          )
                        ]),
                      )
                    ], width: 345 - 17 * 2)),
                  )),
              Positioned.fill(
                  top: 75.w + 15.w,
                  bottom: 55.w + paddingSizeBottom(context),
                  child: GetBuilder<MachinePayPageController>(builder: (_) {
                    return EasyRefresh.builder(
                        onLoad: controller.dataList.length >= controller.count
                            ? null
                            : () => controller.loadData(isLoad: true),
                        // controller: controller.pullCtrl,
                        // onLoading: controller.onLoad,
                        onRefresh: () => controller.loadData(),
                        // enablePullUp:
                        //     controller.count > controller.dataList.length,
                        childBuilder: (context, physics) {
                          return controller.dataList.isEmpty
                              ? GetX<MachinePayPageController>(builder: (_) {
                                  return controller.isFirstLoadding && !kIsWeb
                                      ? SkeletonListView(
                                          item: SkeletonItem(
                                              child: Column(children: [
                                          ghb(15),
                                          Row(children: [
                                            SkeletonAvatar(
                                                style: SkeletonAvatarStyle(
                                                    height: 90.w, width: 90.w)),
                                            gwb(11.5),
                                            Expanded(
                                              child: SkeletonParagraph(
                                                  style: SkeletonParagraphStyle(
                                                      lines: 3,
                                                      spacing: 10.w,
                                                      lineStyle:
                                                          SkeletonLineStyle(
                                                              randomLength:
                                                                  true,
                                                              height: 15.w,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)))),
                                            )
                                          ])
                                        ])))
                                      : CustomListEmptyView(
                                          physics: physics,
                                          isLoading: controller.isLoadding);
                                })
                              : ListView.builder(
                                  padding: EdgeInsets.only(bottom: 20.w),
                                  physics: physics,
                                  itemCount: controller.dataList.length,
                                  itemBuilder: (context, index) {
                                    return cell(
                                        controller.dataList[index], index);
                                  });
                        });
                  }))
            ])));
  }

  Widget cell(Map data, int index) {
    return Align(
      child: CustomButton(
        onPressed: () {
          controller.clickCellAction(data);
        },
        child: Container(
          width: 345.w,
          height: 120.w,
          margin: EdgeInsets.only(top: index == 0 ? 0 : 15.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(3.w)),
          child: Center(
            child: sbhRow([
              centRow([
                SizedBox(
                  height: 90.w,
                  width: 35.w,
                  child: Center(
                    child: Image.asset(
                      assetsName(
                          "machine/checkbox_${(data["selected"] ?? false) ? "selected" : "normal"}"),
                      width: 16.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                CustomNetworkImage(
                  src: AppDefault().imageUrl + (data["levelGiftImg"] ?? ""),
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.fill,
                ),
              ]),
              Padding(
                padding: EdgeInsets.only(right: 11.5.w),
                child: sbClm([
                  centClm([
                    getWidthText(
                        "${data["levelName"] ?? ""}", 15, AppColor.text, 200, 2,
                        isBold: true),
                    ghb(3),
                    getWidthText("型号：${data["levelDescribe"] ?? ""} ", 12,
                        AppColor.text3, 180, 1),
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  sbRow([
                    getSimpleText("￥${priceFormat(data["nowPrice"] ?? 0)}", 15,
                        const Color(0xFFF93635),
                        isBold: true),
                    Container(
                        width: 90.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.5.w),
                            color: AppColor.pageBackgroundColor,
                            border: Border.all(
                                width: 0.5.w, color: AppColor.lineColor)),
                        child: Row(
                          children: List.generate(
                              3,
                              (idx) => idx == 1
                                  ? CustomButton(
                                      onPressed: () {
                                        controller.showKeyborder(index);
                                      },
                                      child: Container(
                                        width: 40.w - 1.w,
                                        height: 21.w,
                                        color: Colors.white,
                                        child: controller.inputIndex == index
                                            ? CustomInput(
                                                width: 40.w - 1.w,
                                                heigth: 21.w,
                                                textEditCtrl:
                                                    controller.cellInput,
                                                focusNode: controller.node,
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                    fontSize: 15.w,
                                                    color: AppColor.text),
                                                placeholderStyle: TextStyle(
                                                    fontSize: 15.w,
                                                    color: AppColor.assisText),
                                              )
                                            : Center(
                                                child: getSimpleText(
                                                    "${data["num"] ?? 1}",
                                                    15,
                                                    AppColor.text),
                                              ),
                                      ),
                                    )
                                  : CustomButton(
                                      onPressed: () {
                                        int num = data["num"] ?? 1;
                                        int count =
                                            data["levelGiftProductCount"] ?? 1;

                                        if (idx == 0) {
                                          if (num > 1) {
                                            data["num"] =
                                                (data["num"] ?? 1) - 1;
                                            controller.update();
                                          } else {
                                            ShowToast.normal("最少选择一件哦");
                                          }
                                        } else {
                                          if (num < count) {
                                            data["num"] =
                                                (data["num"] ?? 1) + 1;
                                            controller.update();
                                          } else {
                                            ShowToast.normal("数量超出该商品库存");
                                          }
                                        }

                                        if (controller.inputIndex == index) {
                                          controller.cellInput.text =
                                              "${data["num"]}";
                                        }
                                      },
                                      child: SizedBox(
                                        width: 25.w - 0.1.w,
                                        height: 25.w,
                                        child: Center(
                                          child: Icon(
                                            idx == 0 ? Icons.remove : Icons.add,
                                            size: 18.w,
                                            color: idx == 0
                                                ? ((data["num"] ?? 1) <= 1
                                                    ? AppColor.assisText
                                                    : AppColor.textBlack)
                                                : ((data["num"] ?? 1) >=
                                                        (data["levelGiftProductCount"] ??
                                                            1)
                                                    ? AppColor.assisText
                                                    : AppColor.textBlack),
                                          ),
                                        ),
                                      ),
                                    )),
                        ))
                  ], width: 200),
                ], height: 90, crossAxisAlignment: CrossAxisAlignment.start),
              ),
            ], height: 120 - 15 * 2, width: 345),
          ),
        ),
      ),
    );
  }

  showTypeSelectModel() {
    Get.bottomSheet(
        Container(
          height: 165.w,
          width: 375.w,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
          child: Column(
            children: [
              sbhRow(
                  List.generate(
                      2,
                      (index) => CustomButton(
                            onPressed: () {
                              if (index == 1) {
                                controller.payTypeIndex = controller.pickIndex;
                              }
                              Get.back();
                            },
                            child: SizedBox(
                              width: 65.w,
                              height: 52.w,
                              child: Center(
                                child: getSimpleText(
                                    index == 0 ? "取消" : "确定",
                                    14,
                                    index == 0
                                        ? AppColor.text3
                                        : AppColor.text),
                              ),
                            ),
                          )),
                  height: 52,
                  width: 375),
              gline(375, 1),
              SizedBox(
                width: 375.w,
                height: 165.w - 52.w - 1.w,
                child: CupertinoPicker.builder(
                  scrollController: FixedExtentScrollController(
                      initialItem: controller.pickIndex),
                  itemExtent: 40.w,
                  childCount: controller.payTypeList.length,
                  onSelectedItemChanged: (value) {
                    controller.pickIndex = value;
                  },
                  itemBuilder: (context, index) {
                    return Center(
                      child: GetX<MachinePayPageController>(
                        builder: (_) {
                          return getSimpleText(
                              controller.payTypeList[index]["name"],
                              15,
                              AppColor.text,
                              fw: controller.pickIndex == index
                                  ? FontWeight.w500
                                  : FontWeight.normal);
                        },
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        enableDrag: false,
        isDismissible: false);
  }
}
