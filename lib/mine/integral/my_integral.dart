import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/earn/earn_particulars.dart';
import 'package:cxhighversion2/integralstore/integral_store.dart';
import 'package:cxhighversion2/mine/integral/my_integral_history.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_convert.dart';
import 'package:cxhighversion2/product/product_store/product_store_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class MyIntegralBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyIntegralController>(MyIntegralController(datas: Get.arguments));
  }
}

class MyIntegralController extends GetxController {
  final dynamic datas;
  MyIntegralController({this.datas});

  String infoContent = "";

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _isMachineFirstLoading = true.obs;
  bool get isMachineFirstLoading => _isMachineFirstLoading.value;
  set isMachineFirstLoading(v) => _isMachineFirstLoading.value = v;

  final _integralHistoryList = Rx<List>([]);
  List get integralHistoryList => _integralHistoryList.value;
  set integralHistoryList(v) => _integralHistoryList.value = v;

  final _machineList = Rx<List>([]);
  List get machineList => _machineList.value;
  set machineList(v) => _machineList.value = v;

  loadMachineData() {
    Map<String, dynamic> params = {
      "pageNo": 1,
      "pageSize": 3,
      "level_Type": 3,
    };
    simpleRequest(
      url: Urls.memberList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          List tmpDatas = data["data"] ?? [];
          if (tmpDatas.length > 3) {
            tmpDatas = tmpDatas.sublist(0, 3);
          }
          machineList = tmpDatas;
        }
      },
      after: () {
        isMachineFirstLoading = false;
      },
    );
  }

  // 本月获得积分/豆
  final _thisMonthAmout = 0.0.obs;
  double get thisMonthAmout => _thisMonthAmout.value;
  set thisMonthAmout(v) => _thisMonthAmout.value = v;
  DateTime now = DateTime.now();
  loadIntegralData() {
    simpleRequest(
      url: Urls.userFinanceIntegralList,
      params: {"pageSize": isBean ? 3 : 4, "pageNo": 1, "a_No": isBean ? 5 : 4},
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          integralHistoryList = data["data"] ?? [];
          thisMonthAmout = 0.0;
          List financeInOutData = data["financeInOutData"] ?? [];
          for (var e in financeInOutData) {
            if ((e["year"] ?? 0) == now.year &&
                (e["month"] ?? 0) == now.month) {
              thisMonthAmout = e["inAmount"] ?? 0.0;
              break;
            }
          }
        }
      },
      after: () {
        isFirstLoading = false;
      },
    );
  }

  double jfNum = 0.0;
  final _jfAccount = Rx<Map>({});
  Map get jfAccount => _jfAccount.value;
  set jfAccount(v) => _jfAccount.value = v;

  Map homeData = {};
  dataFormat() {
    homeData = AppDefault().homeData;
    jfNum = 0.0;
    List accounts = homeData["u_Account"] ?? [];
    for (var e in accounts) {
      if (e["a_No"] == (isBean ? 5 : 4)) {
        jfNum = (e["amout"] ?? 0);
        jfAccount = e;
        break;
      }
    }
    update();
  }

  homeDataNotify(arg) {
    dataFormat();
  }

  loadInfoContent() {
    simpleRequest(
      url: Urls.ruleDescriptionByID(4),
      params: {},
      success: (success, json) {
        if (success) {
          List infos = json["data"] ?? [];
          if (infos.isNotEmpty) {
            infoContent = infos[0]["content"] ?? "";
          }
        }
      },
      after: () {},
      useCache: true,
    );
  }

  @override
  void onReady() {
    loadIntegralData();
    if (isBean) {
      loadMachineData();
    }
    super.onReady();
  }

  bool isBean = false;

  @override
  void onInit() {
    isBean = (datas ?? {})["isBean"] ?? false;
    loadInfoContent();
    dataFormat();
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onInit();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onClose();
  }
}

class MyIntegral extends GetView<MyIntegralController> {
  const MyIntegral({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
          context, "我的${controller.jfAccount["name"] ?? "积分"}",
          color: const Color(0xFFFFCC33),
          action: [
            CustomButton(
                onPressed: () {
                  if (controller.isBean) {
                    push(const MyIntegralHistory(), context,
                        binding: MyIntegralHistoryBinding(),
                        arguments: {"isBean": controller.isBean});
                  } else {
                    push(const IntegralStore(), context,
                        binding: IntegralStoreBinding());
                  }
                },
                child: SizedBox(
                  width: 80.w,
                  height: kToolbarHeight,
                  child: Center(
                      child: getSimpleText(controller.isBean ? "明细" : "积分商城",
                          14, AppColor.text2)),
                )),
          ]),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 600.w - 20.w - kToolbarHeight,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  const Color(0xFFFFCC33),
                  AppColor.pageBackgroundColor
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              )),
          Positioned.fill(
            child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ghb(20),
                    Container(
                      width: 345.w,
                      height: 170.w,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(assetsName("mine/jf/bg_jf")))),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 90.w,
                            child: Center(
                              child: sbRow([
                                centClm([
                                  ghb(12),
                                  getSimpleText(
                                      controller.isBean ? "当前可用" : "可用积分",
                                      12,
                                      AppColor.textBlack),
                                  ghb(2),
                                  getSimpleText(
                                      priceFormat(controller.jfNum,
                                          savePoint: 0),
                                      30,
                                      AppColor.textBlack,
                                      isBold: true)
                                ], crossAxisAlignment: CrossAxisAlignment.start)
                              ], width: 345 - 25 * 2),
                            ),
                          ),
                          SizedBox(
                            width: 285.w,
                            height: 80.w,
                            child: centRow(List.generate(
                                2,
                                (index) => SizedBox(
                                      width: 285.w / 2,
                                      child: centClm([
                                        getSimpleText(
                                            index == 0 ? "本月获得" : "累计获得",
                                            12,
                                            AppColor.textBlack),
                                        ghb(6),
                                        GetX<MyIntegralController>(
                                            builder: (_) {
                                          return getSimpleText(
                                              index == 0
                                                  ? priceFormat(
                                                      controller.thisMonthAmout,
                                                      savePoint: 0)
                                                  : priceFormat(
                                                      controller.jfAccount[
                                                              "amout2"] ??
                                                          0.0,
                                                      savePoint: 0),
                                              18,
                                              AppColor.textBlack,
                                              isBold: true);
                                        })
                                      ]),
                                    ))),
                          )
                        ],
                      ),
                    ),
                    controller.isBean
                        ? GetX<MyIntegralController>(
                            builder: (_) {
                              return !controller.isMachineFirstLoading &&
                                      controller.machineList.isEmpty
                                  ? ghb(0)
                                  : Container(
                                      margin: EdgeInsets.only(top: 15.w),
                                      width: 345.w,
                                      decoration: getDefaultWhiteDec(radius: 8),
                                      child: Column(
                                        children: [
                                          myTitle("机具兑换"),
                                          controller.isMachineFirstLoading
                                              ? sbRow(
                                                  List.generate(
                                                      3,
                                                      (index) => SkeletonAvatar(
                                                            style:
                                                                SkeletonAvatarStyle(
                                                                    width: 90.w,
                                                                    height:
                                                                        146.5
                                                                            .w),
                                                          )),
                                                  width: 315)
                                              : Row(
                                                  children: List.generate(
                                                      controller.machineList
                                                          .length, (index) {
                                                  Map machineData = controller
                                                      .machineList[index];

                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        left: index == 0
                                                            ? 15.w
                                                            : (315 - 90 * 3).w /
                                                                2),
                                                    child: CustomButton(
                                                      onPressed: () {
                                                        push(
                                                            const ProductStoreDetail(),
                                                            context,
                                                            binding: ProductStoreDetailBinding(),
                                                            arguments: {
                                                              "data":
                                                                  machineData,
                                                              "levelType": 3
                                                            });
                                                      },
                                                      child: SizedBox(
                                                          width: 90.w,
                                                          child: Column(
                                                            children: [
                                                              CustomNetworkImage(
                                                                src: AppDefault()
                                                                        .imageUrl +
                                                                    (machineData[
                                                                            "levelGiftImg"] ??
                                                                        ""),
                                                                width: 90.w,
                                                                height: 90.w,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            3.w,
                                                                        bottom:
                                                                            3.w),
                                                                child: centRow([
                                                                  Image.asset(
                                                                      assetsName(
                                                                          "common/icon_bean"),
                                                                      width:
                                                                          18.w,
                                                                      fit: BoxFit
                                                                          .fitWidth),
                                                                  gwb(3),
                                                                  getSimpleText(
                                                                      priceFormat(
                                                                          machineData["nowPrice"] ??
                                                                              0,
                                                                          savePoint:
                                                                              0),
                                                                      18,
                                                                      const Color(
                                                                          0xFFFFB540),
                                                                      isBold:
                                                                          true),
                                                                ]),
                                                              ),
                                                              Container(
                                                                width: 60.w,
                                                                height: 24.w,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(12
                                                                            .w),
                                                                    gradient: const LinearGradient(
                                                                        colors: [
                                                                          Color(
                                                                              0xFFFD573B),
                                                                          Color(
                                                                              0xFFFF3A3A)
                                                                        ],
                                                                        begin: Alignment
                                                                            .topCenter,
                                                                        end: Alignment
                                                                            .bottomCenter)),
                                                                child: getSimpleText(
                                                                    "兑换",
                                                                    12,
                                                                    Colors
                                                                        .white),
                                                              )
                                                            ],
                                                          )),
                                                    ),
                                                  );
                                                })),
                                          ghb(17.5)
                                        ],
                                      ),
                                    );
                            },
                          )
                        : Container(
                            margin: EdgeInsets.only(top: 15.w),
                            width: 345.w,
                            decoration: getDefaultWhiteDec(radius: 8),
                            child: Column(
                              children: [
                                myTitle("积分兑换"),
                                sbRow(
                                    List.generate(
                                        2,
                                        (index) => CustomButton(
                                              onPressed: () {
                                                push(
                                                    MyWalletConvert(
                                                      walletNo:
                                                          controller.jfAccount[
                                                                  "a_No"] ??
                                                              0,
                                                      isRedPack: index == 0,
                                                    ),
                                                    context,
                                                    binding:
                                                        MyWalletConvertBinding());
                                              },
                                              child: Image.asset(
                                                  assetsName(
                                                      "mine/jf/btn_${index == 0 ? "hb" : "jlj"}"),
                                                  width: 150.w,
                                                  height: 85.w,
                                                  fit: BoxFit.fill),
                                            )),
                                    width: 315.5),
                                ghb(10)
                              ],
                            ),
                          ),
                    Container(
                      margin: EdgeInsets.only(top: 15.w),
                      width: 345.w,
                      decoration: getDefaultWhiteDec(radius: 8),
                      child: Column(
                        children: [
                          myTitle("${controller.jfAccount["name"] ?? "积分"}明细",
                              rightWidgt: CustomButton(
                                onPressed: () {
                                  push(const MyIntegralHistory(), context,
                                      binding: MyIntegralHistoryBinding(),
                                      arguments: {"isBean": controller.isBean});
                                },
                                child: SizedBox(
                                  width: 50.w,
                                  height: 45.w,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: getSimpleText(
                                          "更多", 12, AppColor.textGrey5)),
                                ),
                              )),
                          gline(315, 0.5),
                          GetX<MyIntegralController>(
                            builder: (_) {
                              return controller.integralHistoryList.isEmpty
                                  ? controller.isFirstLoading
                                      ? SizedBox(
                                          width: 345.w,
                                          height: 61.w * 4,
                                          child: SkeletonListView(),
                                        )
                                      : CustomEmptyView(
                                          topSpace: 30.w,
                                          centerSpace: 12,
                                          bottomSpace: 25.w,
                                        )
                                  : Column(
                                      children: List.generate(
                                          controller.integralHistoryList.length,
                                          (index) {
                                        Map data = controller
                                            .integralHistoryList[index];
                                        return CustomButton(
                                          onPressed: () {
                                            push(
                                                EarnParticulars(
                                                  earnData: data,
                                                  title:
                                                      "${controller.jfAccount["name"] ?? "积分"}明细",
                                                ),
                                                null,
                                                binding:
                                                    EarnParticularsBinding());
                                          },
                                          child: SizedBox(
                                            height: 61.w,
                                            child: centClm([
                                              sbRow([
                                                getSimpleText(
                                                    data["codeName"] ?? "",
                                                    15,
                                                    AppColor.textBlack),
                                                getSimpleText(
                                                    "${(data["bType"] ?? -1) == 0 ? "-" : "+"}${priceFormat(data["amount"] ?? 0, savePoint: 0)}",
                                                    18,
                                                    AppColor.textBlack,
                                                    isBold: true)
                                              ], width: 315),
                                              ghb(3),
                                              getSimpleText(
                                                  data["addTime"] ?? "",
                                                  12,
                                                  AppColor.textGrey5)
                                            ],
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start),
                                          ),
                                        );
                                      }),
                                    );
                            },
                          )
                        ],
                      ),
                    ),
                    // Container(
                    //   width: 375.w,
                    //   height: 246.w,
                    //   // color: Colors.white,
                    //   child: Column(
                    //     children: [
                    //       Container(
                    //         width: 375.w,
                    //         height: 175.w,
                    //         child: Column(
                    //           children: [
                    //             ghb(35),
                    //             sbRow([
                    //               Padding(
                    //                 padding: EdgeInsets.only(left: 15.w),
                    //                 child: centClm([
                    //                   GetBuilder<MyIntegralController>(
                    //                     builder: (_) {
                    //                       return getSimpleText(
                    //                           priceFormat(controller.jfNum,
                    //                               savePoint: 0),
                    //                           35,
                    //                           Colors.white,
                    //                           isBold: true);
                    //                     },
                    //                   ),
                    //                   getSimpleText("当前可用积分", 14,
                    //                       Colors.white.withOpacity(0.5))
                    //                 ],
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.start),
                    //               ),
                    //               CustomButton(
                    //                 onPressed: () {
                    //                   push(const IntegralStatistics(), null,
                    //                       binding: IntegralStatisticsBinding());
                    //                 },
                    //                 child: Container(
                    //                   width: 90.w,
                    //                   height: 30.w,
                    //                   decoration: BoxDecoration(
                    //                       borderRadius:
                    //                           BorderRadius.circular(15.w),
                    //                       color: Colors.black.withOpacity(0.1)),
                    //                   child: Row(
                    //                     children: [
                    //                       gwb(8),
                    //                       Image.asset(
                    //                         assetsName("mine/jf/icon_jf_tj"),
                    //                         width: 18.w,
                    //                         fit: BoxFit.fitWidth,
                    //                       ),
                    //                       gwb(2),
                    //                       getSimpleText(
                    //                           "积分统计", 12, Colors.white)
                    //                     ],
                    //                   ),
                    //                 ),
                    //               )
                    //             ], width: 375 - 15 * 2)
                    //           ],
                    //         ),
                    //       ),
                    //       sbRow(
                    //           List.generate(4, (index) {
                    //             String img = "mine/jf/btn_";
                    //             String title = "";
                    //             switch (index) {
                    //               case 0:
                    //                 img += "sc";
                    //                 title = "积分商城";
                    //                 break;
                    //               case 1:
                    //                 img += "fg";
                    //                 title = "积分复购";
                    //                 break;
                    //               case 2:
                    //                 img += "tx";
                    //                 title = "积分兑现";
                    //                 break;
                    //               case 3:
                    //                 img += "sm";
                    //                 title = "积分说明";
                    //                 break;
                    //             }

                    //             return CustomButton(
                    //               onPressed: () {
                    //                 if (index == 0) {
                    //                   push(const PointsMallPage(), null,
                    //                       binding: PointsMallPageBinding());
                    //                 } else if (index == 1) {
                    //                   push(const IntegralRepurchase(), context,
                    //                       binding: IntegralRepurchaseBinding());
                    //                 } else if (index == 2) {
                    //                   push(const IntegralRepurchase(), context,
                    //                       binding: IntegralRepurchaseBinding(),
                    //                       arguments: {"isRepurchase": false});
                    //                 } else if (index == 3) {
                    //                   pushInfoContent(
                    //                       title: "积分规则说明",
                    //                       content: controller.infoContent);
                    //                 }
                    //               },
                    //               child: centClm([
                    //                 Image.asset(
                    //                   assetsName(img),
                    //                   height: 30.w,
                    //                   fit: BoxFit.fitHeight,
                    //                 ),
                    //                 ghb(5),
                    //                 getSimpleText(title, 12, AppColor.text2)
                    //               ]),
                    //             );
                    //           }),
                    //           width: 375 - 30 * 2)
                    //     ],
                    //   ),
                    // ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget myTitle(String title, {Widget? rightWidgt}) {
    return sbhRow([
      centRow([
        Container(
          width: 3.w,
          height: 15.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.5.w),
              color: AppColor.theme),
        ),
        gwb(6),
        getSimpleText(title, 16, AppColor.textBlack, isBold: true)
      ]),
      rightWidgt ?? gwb(0)
    ], width: 345 - 16 * 2, height: 45);
  }
}

class MyClippper extends CustomClipper<Path> {
  final double arc;
  MyClippper({required this.arc});
  Path path = Path();

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height - arc);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - arc);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
