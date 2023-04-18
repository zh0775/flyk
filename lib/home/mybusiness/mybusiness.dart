import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_cell.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/team_allies.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyBusinessBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyBusinessController>(() => MyBusinessController());
  }
}

class MyBusinessController extends GetxController {
  List tmpData = [182, 12, 12, 12, 12, 88];
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  List businessData = [];
  List businessEnum = [];

  loadBusiness() {
    simpleRequest(
      url: Urls.userMerchantStatusData,
      params: {},
      success: (success, json) {
        if (success) {
          List datas = json["data"];
          for (var item in businessData) {
            for (var item2 in datas) {
              if ("${item["enumValue"]}" == "${item2["status"]}") {
                item["count"] = item2["num"];
                break;
              }
            }
          }
          businessEnumFormat();
          update();
        }
      },
      after: () {},
    );
  }

  loadBusinessCondition() {
    simpleRequest(
      url: Urls.userMerchantStatusSearch,
      params: {},
      success: (success, json) {
        if (success) {
          businessData = json["data"];
          loadBusiness();
        }
      },
      after: () {},
    );
  }

  loadBusinessEnum() {
    simpleRequest(
      url: Urls.userMerchantEnum,
      params: {},
      success: (success, json) {
        if (success) {
          businessEnum = json["data"]["children"];
          if (businessData.isNotEmpty) {
            businessEnumFormat();
            update();
          }
        }
      },
      after: () {},
      useCache: true,
    );
  }

  businessEnumFormat() {
    if (businessEnum.isNotEmpty && businessData.isNotEmpty) {
      for (var item in businessData) {
        if ("${item["enumValue"]}" == "0") {
          item["desc"] = "我的所有直属商户";
        }
        for (var item2 in businessEnum) {
          if ("${item["enumValue"]}" == "${item2["enumValue"]}") {
            item["desc"] = item2["enumDesc"];
            item["logo"] = item2["logo"];
          }
        }
      }
      isLoading = false;
    }
  }

  loadData() {
    loadBusinessCondition();
    loadBusinessEnum();
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }
}

class MyBusiness extends GetView<MyBusinessController> {
  const MyBusiness({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "商户管理"),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              gwb(375),
              ghb(20),
              GetBuilder<MyBusinessController>(
                init: controller,
                builder: (_) {
                  return controller.businessData.isEmpty
                      ? GetX<MyBusinessController>(
                          init: controller,
                          builder: (_) {
                            return CustomEmptyView(
                              isLoading: controller.isLoading,
                              // type: CustomEmptyType.networkError,
                              retryAction: () => controller.loadData(),
                            );
                          },
                        )
                      : Column(
                          children: [
                            ...controller.businessData.asMap().entries.map((e) {
                              if (e.key == 0) {
                                return Column(
                                  children: [
                                    getCell(
                                        e.value["enumName"] ?? "",
                                        e.value["desc"] ?? "",
                                        "icon_qbsh",
                                        e.value["count"] ?? "",
                                        0,
                                        context: context,
                                        index: e.key),
                                    ghb(15),
                                  ],
                                );
                              } else if (e.key <=
                                  controller.businessData.length - 2) {
                                return Column(
                                  children: [
                                    getCell(
                                        e.value["enumName"] ?? "",
                                        e.value["desc"] ?? "",
                                        AppDefault().imageUrl + e.value["logo"],
                                        e.value["count"] ?? "",
                                        e.key == 2
                                            ? 1
                                            : e.key !=
                                                    controller.businessData
                                                            .length -
                                                        2
                                                ? 3
                                                : 2,
                                        context: context,
                                        index: e.key),
                                    e.key != controller.businessData.length - 2
                                        ? ghb(0)
                                        : gline(345, 0.5),
                                  ],
                                );
                              } else {
                                return Column(children: [
                                  ghb(15),
                                  getCell(
                                      e.value["enumName"] ?? "",
                                      e.value["desc"] ?? "",
                                      AppDefault().imageUrl + e.value["logo"],
                                      e.value["count"] ?? "",
                                      0,
                                      context: context,
                                      index: e.key),
                                ]);
                              }
                            }).toList(),
                            SizedBox(
                              height: paddingSizeBottom(context),
                            ),
                            ghb(15),
                          ],
                        );
                },
              ),
              // getCell("活跃商户", "近30天交易10笔＞3天交易额≥5000元", "icon_hysh",
              //     controller.tmpData[2], 2,
              //     context: context),
              // gline(345, 0.5),
              // getCell("沉默商户", "入网＞30天连续无交易＞30天", "icon_cmsh",
              //     controller.tmpData[3], 2,
              //     context: context),
              // gline(345, 0.5),
              // getCell("新增商户", "入网≤30天", "icon_xzsh", controller.tmpData[4], 3,
              //     context: context),
              // gline(345, 0.5),
              // ghb(15),
              // getCell("激活预警/达标预警", "剩余激活＜10天/剩余达标＜20天", "icon_yj",
              //     controller.tmpData[5], 0,
              //     context: context),
              ghb(15)
            ],
          ),
        ));
  }

  Widget getCell(String t1, String t2, String img, dynamic count, int type,
      {required BuildContext context, required int index}) {
    BorderRadius? br;
    switch (type) {
      case 0:
        br = BorderRadius.circular(5.w);
        break;
      case 1:
        br = BorderRadius.only(
            topLeft: Radius.circular(5.w), topRight: Radius.circular(5.w));
        break;
      case 2:
        br = BorderRadius.zero;
        break;
      case 3:
        br = BorderRadius.only(
            bottomLeft: Radius.circular(5.w),
            bottomRight: Radius.circular(5.w));
        break;
    }

    return CustomCell(
      cellClick: (idx) {
        push(
            TeamAllies(
              isMyBusiness: true,
              myBusinessTitle: t1,
              businessData: controller.businessData[index],
            ),
            context,
            binding: TeamAlliesBinding());
      },
      width: 345.w,
      height: 90.w,
      titleLeftPadding: 15.w,
      titleVSpace: 2.w,
      avatarPadding: 18.w,
      cellBorderRadius: br,
      needRightArrow: false,
      avatar: img.contains("http")
          ? CustomNetworkImage(
              src: img,
              width: 42.w,
              // height: 42.w,
              errorWidget: gemp(),
              fit: BoxFit.fitWidth,
            )
          : assetsSizeImage(
              "home/mybusiness/$img",
              42,
              42,
            ),
      title: sbRow([
        getSimpleText(t1, 16, AppColor.textBlack, isBold: true),
        centRow([
          getSimpleText("$count", 16, const Color(0xFFEB5757), isBold: true),
          gwb(10),
          assetsSizeImage("common/icon_cell_right_arrow", 20, 20),
        ])
      ], width: 252),
      subTitles: [
        getWidthText(t2, 13, AppColor.textGrey3, 222.5, 2),
      ],
    );
  }
}
