import 'package:flutter/material.dart';
import 'package:cxhighversion2/home/mybusiness/mybusiness_info.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyMachineInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyMachineInfoController>(MyMachineInfoController());
  }
}

class MyMachineInfoController extends GetxController {
  bool isFirst = true;
  Map machineData = {};
  Map machineInfo = {};
  dataInit(Map data) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    machineData = data;
    loadInfo();
  }

  String statusTitle = "";
  bool isBinding = false;

  loadInfo() {
    simpleRequest(
      url: Urls.userTerminalInfo(machineData["tId"]),
      params: {},
      success: (success, json) {
        if (success) {
          machineInfo = json["data"];
          String s = machineInfo["tStatus"] ?? "";
          statusTitle = "";
          if (s.length > 2) {
            statusTitle = s.substring(1, s.length);
          } else if (s.length == 2) {
            statusTitle = s;
          }
          isBinding = !((machineInfo["isBinding"] ?? 0) == 0);
          update();
        }
      },
      after: () {},
    );
  }
}

class MyMachineInfo extends GetView<MyMachineInfoController> {
  final Map machineData;
  final bool isDirectly;
  const MyMachineInfo(
      {Key? key, this.machineData = const {}, this.isDirectly = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(machineData);
    return Scaffold(
        body: Stack(
      children: [
        isDirectly
            ? gemp()
            : Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80.w + paddingSizeBottom(context),
                child: getBottomBlueSubmitBtn(
                  context,
                  "查看商户信息",
                  onPressed: () {
                    push(
                        MyBusinessInfo(
                          fromMachine: true,
                          // merchantId: controller.machineInfo["merchantId"] ?? 0,
                          merchantId: machineData["tId"] ?? 0,
                        ),
                        context,
                        binding: MyBusinessInfoBinding());
                  },
                )),
        Positioned(
            top: 0,
            right: 0,
            bottom: isDirectly ? 0 : (80.w + paddingSizeBottom(context)),
            left: 0,
            child: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [buildSliverAppBar(context)];
                },
                body: GetBuilder<MyMachineInfoController>(
                  builder: (controller) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          titleWidget(0),
                          Container(
                            width: 345.w,
                            decoration: getDefaultWhiteDec(),
                            child: Column(
                              children: [
                                ghb(15),
                                infoCell("品牌",
                                    controller.machineInfo["tbName"] ?? ""),
                                infoCell("类型",
                                    controller.machineInfo["tmName"] ?? ""),
                                infoCell("属性",
                                    controller.machineInfo["tRate"] ?? ""),
                                infoCell("机具状态",
                                    controller.machineInfo["tStatus"] ?? "",
                                    overTime: controller
                                                    .machineInfo["tipsDay"] !=
                                                null &&
                                            controller.machineInfo["tipsDay"] >
                                                0 &&
                                            controller.machineInfo["tipsDay"] <
                                                7
                                        ? "${controller.machineInfo["tipsDay"]}"
                                        : null),
                                !controller.isBinding
                                    ? ghb(0)
                                    : infoCell(
                                        "${controller.statusTitle}时间",
                                        controller.machineInfo["bindingTime"] ??
                                            ""),
                                ghb(15),
                              ],
                            ),
                          ),
                          titleWidget(1),
                          Container(
                            width: 345.w,
                            decoration: getDefaultWhiteDec(),
                            child: Column(
                              children: [
                                ghb(15),
                                infoCell("昨日交易",
                                    "${priceFormat(controller.machineInfo["yesdayAmt"] ?? 0)}元"),
                                infoCell("本月交易",
                                    "${priceFormat(controller.machineInfo["thisMonAmt"] ?? 0)}元"),
                                infoCell("累计交易",
                                    "${priceFormat(controller.machineInfo["totalAmt"] ?? 0)}元"),
                                ghb(15),
                              ],
                            ),
                          ),
                          ghb(20),
                        ],
                      ),
                    );
                  },
                )))
      ],
    ));
  }

  Widget buildSliverAppBar(BuildContext context) {
    return GetBuilder<MyMachineInfoController>(
      builder: (_) {
        return SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: 190.w,
          snap: false,
          elevation: 0,
          centerTitle: true,
          title: getDefaultAppBarTitile("机具信息"),
          backgroundColor: Colors.white,
          leading: defaultBackButton(context),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: const Color(0xFFE3E9F9),
              child: Column(
                children: [
                  SizedBox(
                    height: paddingSizeTop(context),
                  ),
                  const SizedBox(
                    height: kToolbarHeight,
                  ),
                  ghb(15),
                  sbRow([
                    centClm([
                      getSimpleText(
                          "${controller.machineInfo["u_Name"] ?? ""}${controller.machineInfo["u_Number"] != null && controller.machineInfo["u_Number"].isNotEmpty ? "(${controller.machineInfo["u_Number"]})" : ""}",
                          15,
                          AppColor.textBlack),
                      ghb(23),
                      getSimpleText(
                          "机具SN：${snNoFormat(controller.machineInfo["tNo"] ?? "")}",
                          15,
                          AppColor.textBlack),
                    ]),
                    gwb(0),
                  ], width: 375 - 15.5 * 2)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget titleWidget(int index) {
    String title = index == 0
        ? "基本信息"
        : index == 1
            ? "交易信息"
            : "其他信息";
    Size size = calculateTextSize(title, 16, AppDefault.fontBold, 1000, 1,
        Global.navigatorKey.currentContext!);
    return sbhRow([
      SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 25.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.w),
                      color: index == 0
                          ? const Color(0xFF22AC38)
                          : index == 1
                              ? const Color(0xFFF39800)
                              : const Color(0xFF4176F6)),
                )),
            Positioned(
                top: 0,
                left: 0,
                child:
                    getSimpleText(title, 16, AppColor.textBlack, isBold: true)),
          ],
        ),
      )
    ], width: 375 - 30 * 2, height: 53.5);
  }

  Widget infoCell(String t1, String t2, {String? overTime}) {
    return sbhRow([
      centRow([
        getRichText(
            "$t1：", t2, 15, const Color(0xFF6E6E6E), 15, AppColor.textBlack),
        overTime != null
            ? centRow([
                gwb(10),
                Icon(
                  Icons.error_rounded,
                  color: const Color(0xFFE3463D),
                  size: 12.5.w,
                ),
                gwb(10),
                getSimpleText("即将激活过期：$overTime", 12, const Color(0xFFE3463D))
              ])
            : gwb(0),
      ]),
      gwb(0),
    ], width: 345 - 15 * 2, height: 35);
  }
}
