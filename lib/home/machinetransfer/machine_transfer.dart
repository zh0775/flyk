import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_advance_order.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_brand_list.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_history.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_order_list.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_userlist.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class MachineTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferController>(MachineTransferController());
  }
}

class MachineTransferController extends GetxController {
  final _waitCount = 0.obs;
  set waitCount(value) => _waitCount.value = value;
  get waitCount => _waitCount.value;

  // final _isLoding = false.obs;
  // set waitCount(value) => _waitCount.value = value;
  // get waitCount => _waitCount.value;

  final _historyCount = 0.obs;
  set historyCount(value) => _historyCount.value = value;
  int get historyCount => _historyCount.value;

  double spaceHeight1 = 16;
  String imageUrl = "";

  final _selectUserData = Rx<Map>({});
  set selectUserData(value) => _selectUserData.value = value;
  Map get selectUserData => _selectUserData.value;

  final _selectTmpData = Rx<Map>({});
  set selectTmpData(value) => _selectTmpData.value = value;
  Map get selectTmpData => _selectTmpData.value;

  String selectMachineTilte = "还未选择设备";
  final _selectMachineData = Rx<List>([]);
  List get selectMachineData => _selectMachineData.value;

  set selectMachineData(value) {
    _selectMachineData.value = value;
    if (value.isEmpty) {
      selectMachineTilte = "还未选择设备";
    } else {
      selectMachineTilte = "";
      for (var i = 0; i < selectMachineData.length; i++) {
        Map item = selectMachineData[i];
        if (i == 0) {
          selectMachineTilte +=
              "${item["tbName"] ?? ""}/${item["tmName"] ?? ""}";
        } else {
          selectMachineTilte += "/${item["tmName"] ?? ""}";
        }
      }
    }
  }

  terminalTransferAction() {
    if (selectUserData.isEmpty) {
      ShowToast.normal("请选择划拨对象");
      return;
    }
    if (selectMachineData.isEmpty) {
      ShowToast.normal("请选择划拨设备");
      return;
    }

    Get.to(
        () => MachineTransferAdvanceOrder(
              machineData: selectMachineData,
              userData: selectUserData,
              isLock: isLock,
            ),
        binding: MachineTransferAdvanceOrderBinding());
    // submitEnable = false;
    // terminalTransferRequest({"uId": selectUserData["uId"],"createType":1,"tNo":tNo}, (bool success, dynamic json) {
    //   if (success) {}
    //   submitEnable = true;
    // });
  }

  resetData() {
    selectUserData = {};
    selectMachineData = [];
    selectTmpData = {};
  }

  loadwaitTransferCount() {
    Map homeData = AppDefault().homeData;
    waitCount = homeData["waitTransferCount"] ?? 0;
  }

  bool isFirst = true;
  bool isLock = false;
  dataInit(bool lock) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    isLock = lock;
    loadwaitTransferCount();
  }

  @override
  void onInit() {
    imageUrl = AppDefault().imageUrl;
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onReady() {
    if (AppDefault().homeData == null || AppDefault().homeData.isEmpty) {
      toLogin();
    }
    super.onReady();
  }
}

class MachineTransfer extends GetView<MachineTransferController> {
  final bool isLock;
  const MachineTransfer({Key? key, this.isLock = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(isLock);
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, "终端管理", action: [
        CustomButton(
          onPressed: () {
            Get.to(() => const MachineTransferHistory(),
                binding: MachineTransferHistoryBinding());
          },
          child: SizedBox(
            height: kToolbarHeight,
            width: 80.w,
            child: Center(
              child: getSimpleText("划拨记录", 14, AppColor.textBlack),
            ),
          ),
        )
      ]),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ghb(20),
            gwb(375),
            // Align(
            //   child: sbRow([
            //     topButton(0),
            //     topButton(1),
            //   ], width: 375 - 15 * 2),
            // ),
            ghb(controller.spaceHeight1),
            sbRow(
                [getSimpleText("选择划拨对象", 16, AppColor.textBlack, isBold: true)],
                width: 375 - 24.5 * 2),
            ghb(controller.spaceHeight1),
            GetX<MachineTransferController>(
              init: controller,
              builder: (_) {
                return transferSection(
                    controller.selectUserData["uAvatar"] != null &&
                            controller.imageUrl.isNotEmpty
                        ? CustomNetworkImage(
                            src:
                                "${controller.imageUrl}${controller.selectUserData["uAvatar"]}",
                            width: 60.w,
                            height: 60.w,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            assetsName(
                                "home/machinetransfer/icon_machine_transfer_defaultpeople"),
                            width: 60.w,
                            height: 60.w,
                            fit: BoxFit.fill),
                    controller.selectUserData.isNotEmpty
                        ? controller.selectUserData["uName"] ??
                            (controller.selectUserData["uMobile"] ?? "")
                        : "还未选择划拨对象",
                    controller.selectUserData.isNotEmpty
                        ? "${controller.selectUserData["uNumber"] ?? ""}|${controller.selectUserData["uMobile"] ?? ""}"
                        : "请先选择划拨对象",
                    AppColor.textGrey, () {
                  // push(
                  //     MachineTransferUserList(
                  //       userData: controller.userList,
                  //     ),
                  //     context,
                  //     bindings: MachineTransferUserListBinding());

                  Get.to(const MachineTransferUserList(),
                      binding: MachineTransferUserListBinding());
                });
              },
            ),
            ghb(controller.spaceHeight1),
            sbRow([getSimpleText("选择设备", 16, AppColor.textBlack, isBold: true)],
                width: 375 - 24.5 * 2),
            ghb(controller.spaceHeight1),
            GetX<MachineTransferController>(
              init: controller,
              builder: (_) {
                return transferSection(
                    Image.asset(
                        assetsName(
                            "home/machinetransfer/icon_machine_transfer_machine"),
                        width: 60.w,
                        height: 60.w,
                        fit: BoxFit.fill),
                    controller.selectMachineTilte,
                    controller.selectMachineData.isEmpty
                        ? "请先选择划拨设备"
                        : "已经选择${controller.selectMachineData.length}台设备",
                    controller.selectMachineData.isEmpty
                        ? AppColor.textGrey
                        : AppColor.textBlack, () {
                  Get.to(() => const MachineTransferBrandList(),
                      binding: MachineTransferBrandListBinding());
                });
              },
            ),
            // ghb(controller.spaceHeight1),
            // sbRow([
            //   centRow([
            //     getSimpleText("选择划拨模版", 16, AppColor.textBlack, isBold: true),
            //     gwb(5.5),
            //     CustomButton(
            //       onPressed: () {
            //         showTips(context);
            //       },
            //       child: Image.asset(
            //         assetsName("home/machinetransfer/btn_tips"),
            //         width: 16.5.w,
            //         height: 16.5.w,
            //         fit: BoxFit.fill,
            //       ),
            //     )
            //   ])
            // ], width: 375 - 24.5 * 2),
            // ghb(controller.spaceHeight1),
            // transferSection(
            //     Image.asset(
            //         assetsName(
            //             "home/machinetransfer/icon_machine_transfer_tmp"),
            //         width: 60.w,
            //         height: 60.w,
            //         fit: BoxFit.fill),
            //     "默认模版",
            //     "可添加新模版",
            //     AppColor.textGrey, () {
            //   // push(const MachineTransferTmpList(), context,
            //   //     bindings: MachineTransferTmpListBinding());

            //   Get.to(() => const MachineTransferTmpList(),
            //       binding: MachineTransferTmpListBinding());
            // }),
            ghb(45),
            getSubmitBtn("生成划拨清单", () {
              controller.terminalTransferAction();
            }),
            ghb(30)
          ],
        ),
      ),
    );
  }

  Widget topButton(int index) {
    return CustomButton(
      onPressed: () {
        if (index == 0) {
          Get.to(() => const MachineTransferOrderList(),
              binding: MachineTransferOrderListBinding());
        } else {
          Get.to(() => const MachineTransferHistory(),
              binding: MachineTransferHistoryBinding());
        }
      },
      child: Container(
        width: 166.w,
        height: 80.w,
        decoration: getDefaultWhiteDec(),
        child: Center(
          child: sbRow([
            centClm([
              centRow([
                getSimpleText(
                    index == 0 ? "待办订单" : "划拨记录", 16, AppColor.textBlack,
                    isBold: true),
                gwb(5),
                GetX<MachineTransferController>(
                  init: controller,
                  initState: (_) {},
                  builder: (_) {
                    return Visibility(
                        visible: index == 0
                            ? controller.waitCount != null &&
                                controller.waitCount > 0
                            : controller.historyCount != null &&
                                controller.historyCount > 0,
                        child: Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.w),
                              color: const Color(0xFFF24040)),
                          child: Center(
                            child: getSimpleText(
                                index == 0
                                    ? "${controller.waitCount}"
                                    : "${controller.historyCount}",
                                11,
                                Colors.white),
                          ),
                        ));
                  },
                )
              ]),
              ghb(5),
              getSimpleText("点击查看详情", 13, const Color(0xFFB3B3B3))
            ], crossAxisAlignment: CrossAxisAlignment.start),
            Image.asset(
              assetsName(
                  "home/machinetransfer/${index == 0 ? "icon_machine_transfer_wait" : "icon_machine_transfer_history"}"),
              width: 30.w,
              height: 30.w,
              fit: BoxFit.fill,
            )
          ], width: 166 - 15 * 2),
        ),
      ),
    );
  }

  Widget transferSection(
      Widget img, String t1, String t2, Color t2Color, Function() toNextPage) {
    return CustomButton(
      onPressed: toNextPage,
      child: Container(
          width: 345.w,
          height: 100.w,
          decoration: getDefaultWhiteDec(),
          child: Center(
            child: sbRow([
              centRow([
                img,
                gwb(18.5),
                centClm([
                  getWidthText(t1, 16, const Color(0xFF312F62), 159.5, 1,
                      isBold: true, textAlign: TextAlign.left),
                  ghb(6),
                  getWidthText(t2, 13, t2Color, 159.5, 1,
                      textAlign: TextAlign.left),
                ], crossAxisAlignment: CrossAxisAlignment.start)
              ]),
              Image.asset(
                assetsName("common/icon_cell_right_arrow"),
                width: 20.w,
                height: 20.w,
                fit: BoxFit.fill,
              ),
            ], width: 345 - 16 * 2),
          )),
    );
  }

  void showTips(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return SizedBox(
            width: 375.w,
            height: 463.w,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Image.asset(
                        assetsName("home/machinetransfer/bg_tips"),
                        width: 375.w,
                        height: 121.w,
                        fit: BoxFit.fill,
                      ),
                      Container(
                        width: 375.w,
                        height: 342.w,
                        color: const Color(0xFFEBEBEB),
                      )
                    ],
                  ),
                ),
                Positioned.fill(
                    child: Column(
                  children: [
                    ghb(20.5),
                    sbRow([
                      getSimpleText("划拨模版说明", 20, AppColor.textBlack,
                          isBold: true),
                    ], width: 375 - 30.5 * 2),
                    ghb(36),
                    tipRow("bg_tips_shuoming", "功能说明",
                        "选择好模版后，当前选择的机具都会按照,模版 内的政策进行统一划拨"),
                    ghb(30),
                    tipRow("bg_tips_defaulttmp", "默认模版", "默认模版既平台提供的规则，不可更改"),
                    ghb(30),
                    tipRow("bg_tips_addtmp", "添加新模版",
                        "根据当前实际需求设定下级机具政策，当数据 填写为“0”的时候就是不下发"),
                    ghb(30),
                    getSubmitBtn("知道了", () {
                      Navigator.pop(context);
                    })
                  ],
                )),
              ],
            ));
      },
    );
  }

  Widget tipRow(String img, String t1, String t2) {
    return sbRow([
      Image.asset(
        assetsName("home/machinetransfer/$img"),
        width: 45.w,
        height: 45.w,
        fit: BoxFit.fill,
      ),
      centClm([
        getSimpleText(t1, 18, AppColor.textBlack, isBold: true),
        ghb(5),
        getWidthText(t2, 14, AppColor.textGrey2, 282.5, 3,
            textAlign: TextAlign.start,
            strutStyle: const StrutStyle(
              leading: 0.6,
            )),
      ], crossAxisAlignment: CrossAxisAlignment.start)
    ], width: 375 - 15 * 2, crossAxisAlignment: CrossAxisAlignment.start);
  }
}
