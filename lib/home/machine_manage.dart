import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_cell.dart';
import 'package:cxhighversion2/home/my_machine.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineManageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineManageController>(MachineManageController());
  }
}

class MachineManageController extends GetxController {
  final _machineData = Rx<Map>({});
  Map get machineData => _machineData.value;
  set machineData(v) => _machineData.value = v;
  loadData() {
    simpleRequest(
        url: Urls.userTerminalCount,
        params: {},
        success: (success, json) {
          if (success) {
            machineData = json["data"];
          }
        },
        after: () {},
        useCache: true);
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }
}

class MachineManage extends GetView<MachineManageController> {
  const MachineManage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80.w + paddingSizeBottom(context),
              child: getBottomBlueSubmitBtn(
                context,
                "查看全部机具",
                onPressed: () {
                  Get.to(const MyMachine(), binding: MyMachineBinding());
                },
              )),
          Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 80.w + paddingSizeBottom(context),
              child: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [buildSliverAppBar(context)];
                },
                body: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 69.w,
                        child: Center(
                          child: getSimpleText(
                              "机具数量状态统计", 16, AppColor.textBlack,
                              isBold: true),
                        ),
                      ),
                      GetX<MachineManageController>(
                        init: controller,
                        builder: (_) {
                          return centClm([
                            rowCell(
                                "个人机具",
                                controller.machineData["soleTotalTerminal"] ??
                                    0,
                                controller
                                        .machineData["soleTotalBindTerminal"] ??
                                    0,
                                controller.machineData["soleNoBindTerminal"] ??
                                    0,
                                controller
                                        .machineData["soleTotalActTerminal"] ??
                                    0,
                                controller.machineData["soleNoActTerminal"] ??
                                    0,
                                color: const Color(0xFFEDEDED),
                                allBorder: false,
                                topBorder: false),
                            rowCell(
                                "团队机具",
                                controller.machineData["teamTotalTerminal"] ??
                                    0,
                                controller
                                        .machineData["teamTotalBindTerminal"] ??
                                    0,
                                controller.machineData["teamNoBindTerminal"] ??
                                    0,
                                controller
                                        .machineData["teamTotalActTerminal"] ??
                                    0,
                                controller.machineData["teamNoActTerminal"] ??
                                    0,
                                // color: const Color(0xFFEDEDED),
                                topBorder: false),
                            // rowCell(
                            //     "电签机具",
                            //     controller.machineData["soleTotalTerminal"] ??
                            //         0,
                            //     controller.machineData["soleNoActTerminal"] ??
                            //         0,
                            //     topBorder: false),
                            // rowCell(
                            //     "大pos机具",
                            //     controller.machineData["soleTotalTerminal"] ??
                            //         0,
                            //     controller.machineData["soleNoActTerminal"] ??
                            //         0),
                            // rowCell(
                            //     "扫码机具",
                            //     controller.machineData["soleTotalTerminal"] ??
                            //         0,
                            //     controller.machineData["soleNoActTerminal"] ??
                            //         0),
                          ]);
                        },
                      ),
                      ghb(30)
                    ],
                  ),
                ),
              )),
          // Positioned(
          //     top: 0,
          //     left: 0,
          //     right: 0,
          //     height: 200.w + paddingSizeTop(context),
          //     child: Stack(
          //       children: [
          //         Positioned.fill(
          //             child: Container(
          //           decoration: const BoxDecoration(
          //               gradient: LinearGradient(
          //                   begin: Alignment.topCenter,
          //                   end: Alignment.bottomCenter,
          //                   colors: [
          //                 Color(0xFFE1E9F4),
          //                 Color(0xFFEFF7F9),
          //               ])),
          //         )),
          //         Positioned.fill(
          //             child: Column(
          //           children: [
          //             ghb(paddingSizeTop(context)),
          //             sbRow([
          //               defaultBackButton(context),
          //               getDefaultAppBarTitile("机具管理"),
          //               gwb(50)
          //             ]),
          //             ghb(40),
          //             sbRow([
          //               centClm([
          //                 getSimpleText("总机具数量", 18, AppColor.textBlack,
          //                     isBold: true),
          //                 ghb(12),
          //                 GetX<MachineManageController>(
          //                   init: controller,
          //                   initState: (_) {},
          //                   builder: (_) {
          //                     return Text.rich(
          //                       TextSpan(
          //                           text: controller.machineData.isNotEmpty
          //                               ? "${controller.machineData["soleTotalTerminal"] + controller.machineData["teamTotalTerminal"]}"
          //                               : "0",
          //                           style: TextStyle(
          //                               fontSize: 33.sp,
          //                               color: const Color(0xFFBF3030),
          //                               fontWeight: AppDefault.fontBold),
          //                           children: [
          //                             TextSpan(
          //                                 text: " 台",
          //                                 style: TextStyle(
          //                                     fontSize: 19.sp,
          //                                     color: const Color(0xFFBF3030),
          //                                     fontWeight: AppDefault.fontBold))
          //                           ]),
          //                     );
          //                   },
          //                 )
          //               ], crossAxisAlignment: CrossAxisAlignment.start)
          //             ], width: 375 - 29.5 * 2),
          //           ],
          //         )),
          //       ],
          //     )),
          // Positioned(
          //     top: paddingSizeTop(context) + 200.w,
          //     bottom: 80.w + paddingSizeBottom(context),
          //     left: 0,
          //     right: 0,
          //     child: SingleChildScrollView(
          //       physics: const BouncingScrollPhysics(),
          //       child: Column(
          //         children: [
          //           SizedBox(
          //             height: 69.w,
          //             child: Center(
          //               child: getSimpleText("机具数量状态统计", 16, AppColor.textBlack,
          //                   isBold: true),
          //             ),
          //           ),
          //           GetX<MachineManageController>(
          //             init: controller,
          //             builder: (_) {
          //               return centClm([
          //                 rowCell(
          //                     "个人机具",
          //                     controller.machineData["soleTotalTerminal"] ?? 0,
          //                     controller.machineData["soleNoActTerminal"] ?? 0,
          //                     color: const Color(0xFFEDEDED),
          //                     allBorder: false,
          //                     topBorder: false),
          //                 rowCell(
          //                     "团队机具",
          //                     controller.machineData["teamTotalTerminal"] ?? 0,
          //                     controller.machineData["teamNoActTerminal"] ?? 0,
          //                     color: const Color(0xFFEDEDED),
          //                     allBorder: false,
          //                     topBorder: false),
          //                 rowCell(
          //                     "电签机具",
          //                     controller.machineData["soleTotalTerminal"] ?? 0,
          //                     controller.machineData["soleNoActTerminal"] ?? 0,
          //                     topBorder: false),
          //                 rowCell(
          //                     "大pos机具",
          //                     controller.machineData["soleTotalTerminal"] ?? 0,
          //                     controller.machineData["soleNoActTerminal"] ?? 0),
          //                 rowCell(
          //                     "扫码机具",
          //                     controller.machineData["soleTotalTerminal"] ?? 0,
          //                     controller.machineData["soleNoActTerminal"] ?? 0),
          //               ]);
          //             },
          //           ),
          //           ghb(30)
          //         ],
          //       ),
          //     )),
        ],
      ),
    );
  }

  Widget rowCell(String t1, dynamic totalCount, dynamic t2Count,
      dynamic t3Count, dynamic t4Count, dynamic t5Count,
      {Color? color, bool allBorder = true, bool topBorder = true}) {
    Widget centerLine = Container(
      width: 0.5.w,
      height: 26.w,
      color: const Color(0xFFCCCCCC),
    );
    BorderSide side = BorderSide(width: 1.w, color: const Color(0xFFEDEDED));
    BorderSide nonSide = const BorderSide(width: 0, color: Colors.transparent);
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: color,
          border: Border(
              top: topBorder ? side : nonSide,
              left: allBorder ? side : nonSide,
              right: allBorder ? side : nonSide,
              bottom: allBorder ? side : nonSide)),
      child: Row(
        children: [
          SizedBox(
            height: 75.w,
            width: 125.w,
            child: Center(
              child: centClm([
                getSimpleText(t1, 15, AppColor.textBlack, isBold: true),
                ghb(8),
                centRow(
                  [
                    getSimpleText("$totalCount", 17, AppColor.textBlack,
                        isBold: true, textHeight: 1.1),
                    getSimpleText(" 台", 12, AppColor.textBlack,
                        isBold: true, textHeight: null),
                  ],
                ),
              ]),
            ),
          ),
          centClm([
            centRow([
              centerLine,
              machineCount(t2Count, 0),
              centerLine,
              machineCount(t3Count, 1),
            ]),
            centRow([
              centerLine,
              machineCount(t4Count, 2),
              centerLine,
              machineCount(t5Count, 3),
            ]),
          ])
        ],
      ),
    );
  }

  Widget machineCount(dynamic count, int type) {
    String title = "";
    switch (type) {
      case 0:
        title = "已绑定数";
        break;
      case 1:
        title = "未绑定数";
        break;
      case 2:
        title = "激活机具数";
        break;
      case 3:
        title = "未激活数";
        break;
    }

    return SizedBox(
      width: 108.5.w,
      height: 75.w,
      child: Center(
          child: centClm([
        getSimpleText(title, 14, AppColor.textGrey),
        ghb(8),
        centRow(
          [
            getSimpleText("$count", 17, AppColor.textBlack,
                isBold: true, textHeight: 1.1),
            getSimpleText(" 台", 12, AppColor.textBlack,
                isBold: true, textHeight: null),
          ],
        ),
        // getRichText(
        //     "$count", "台", 17, AppColor.textBlack, 12, AppColor.textBlack,
        //     fw: AppDefault.fontBold, fw2: AppDefault.fontBold),
      ])),
    );
  }

  Widget buildSliverAppBar(BuildContext context) {
    return GetBuilder<MachineManageController>(
      builder: (_) {
        return SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: 200.w,
          snap: false,
          elevation: 0,
          centerTitle: true,
          title: getDefaultAppBarTitile("终端管理"),
          backgroundColor: Colors.white,
          leading: defaultBackButton(context),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color(0xFFE1E9F4),
                    Color(0xFFEFF7F9),
                  ])),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  sbRow([
                    centClm([
                      getSimpleText("总机具数量", 18, AppColor.textBlack,
                          isBold: true),
                      ghb(12),
                      GetX<MachineManageController>(
                        init: controller,
                        initState: (_) {},
                        builder: (_) {
                          return centRow([
                            getSimpleText(
                                controller.machineData.isNotEmpty
                                    ? "${controller.machineData["soleTotalTerminal"] + controller.machineData["teamTotalTerminal"]}"
                                    : "0",
                                33,
                                const Color(0xFFBF3030),
                                isBold: true),
                            getSimpleText(" 台", 19, const Color(0xFFBF3030),
                                isBold: true, textHeight: -0.7),
                          ], crossAxisAlignment: CrossAxisAlignment.end);
                        },
                      )
                    ], crossAxisAlignment: CrossAxisAlignment.start)
                  ], width: 375 - 29.5 * 2),
                  ghb(36)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
