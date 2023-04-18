import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/mybusiness/mybusiness_info.dart';
import 'package:cxhighversion2/home/team_detail.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_draw.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TeamAlliesBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TeamAlliesController>(TeamAlliesController());
  }
}

class TeamAlliesController extends GetxController {
  final _filterIdx = 0.obs;
  int get filterIdx => _filterIdx.value;
  set filterIdx(v) => _filterIdx.value = v;

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _activeDesc = true.obs;
  bool get activeDesc => _activeDesc.value;
  set activeDesc(v) => _activeDesc.value = v;

  final _dealDesc = true.obs;
  bool get dealDesc => _dealDesc.value;
  set dealDesc(v) => _dealDesc.value = v;

  int pageSize = 10;
  int pageNo = 1;
  int count = 0;

  RefreshController pullCtrl = RefreshController();
  TextEditingController searchInputCtrl = TextEditingController();

  onLoad() async {
    loadBusinessListData(isLoad: true);
  }

  onRefresh() async {
    loadBusinessListData();
  }

  loadBusinessListData({bool isLoad = false, bool isSearch = false}) {
    isLoad ? pageNo++ : pageNo = 1;

    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
      "tmStatus": int.parse("${businessData["enumValue"]}")
    };
    if (filterIdx == 1) {
      params["tmInTime"] = activeDesc ? 1 : 0;
    } else if (filterIdx == 2) {
      params["tmOrderTotalAmt"] = dealDesc ? 1 : 0;
    }

    if (isSearch) {
      params["tmName"] = searchInputCtrl.text;
    }

    simpleRequest(
      url: Urls.userMerchantDetail,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          count = data["count"];
          if (isLoad) {
            alliesDatas = [...alliesDatas, ...data["data"]];
            pullCtrl.loadComplete();
          } else {
            alliesDatas = data["data"];
            pullCtrl.refreshCompleted();
          }
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
        update();
      },
      after: () {
        isLoading = false;
      },
    );
  }

  Map businessData = {};
  List businessStatus = [];
  bool isFirst = true;
  dataInit(Map bData, List bStatus) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    businessData = bData;
    businessStatus = bStatus;
    loadBusinessListData();
  }

  List alliesDatas = [];

  @override
  void dispose() {
    pullCtrl.dispose();
    searchInputCtrl.dispose();
    super.dispose();
  }
}

class TeamAllies extends GetView<TeamAlliesController> {
  final bool? isDirectly;
  final bool? isMyBusiness;
  final String? myBusinessTitle;
  final Map businessData;
  final List businessStatus;
  const TeamAllies({
    Key? key,
    this.isDirectly = true,
    this.isMyBusiness = false,
    this.myBusinessTitle = "全部",
    required this.businessData,
    this.businessStatus = const [],
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    controller.dataInit(businessData, businessStatus);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(
            context,
            isMyBusiness!
                ? myBusinessTitle ?? ""
                : isDirectly!
                    ? "直属团队"
                    : "团队盟友"),
        body: Stack(
          children: [
            Positioned(
                top: 0,
                height: 130.w,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    ghb(15),
                    Container(
                      padding: EdgeInsets.only(left: 10.w),
                      width: 345.w,
                      height: 50.w,
                      decoration: getDefaultWhiteDec(),
                      child: Align(
                        child: Row(
                          children: [
                            CustomInput(
                              textEditCtrl: controller.searchInputCtrl,
                              placeholder: "请输入姓名或者手机号查询",
                              onChange: (str) {},
                              onEditingComplete: (str) {},
                              width: 256.w,
                              heigth: 50.w,
                            ),
                            CustomButton(
                              onPressed: () {
                                controller.loadBusinessListData(isSearch: true);
                                takeBackKeyboard(context);
                              },
                              child: Container(
                                width: 64.w,
                                height: 30.w,
                                decoration: BoxDecoration(
                                    color: AppColor.textBlack,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Center(
                                  child: getSimpleText("搜索", 15, Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    ghb(15),
                    Container(
                      width: 375.w,
                      height: 50.w,
                      color: Colors.white,
                      child: Center(
                        child: Row(
                          children: [
                            centClm([
                              gwb(78),
                              getSimpleText("共计", 12, AppColor.textBlack),
                              GetBuilder<TeamAlliesController>(
                                builder: (_) {
                                  return getSimpleText("${controller.count}户",
                                      12, AppColor.textBlack);
                                },
                              )
                            ]),
                            gline(1, 25),
                            filterButton(0),
                            filterButton(1),
                            filterButton(2),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
            Positioned(
                top: 140.w,
                left: 0,
                right: 0,
                bottom: 0,
                child: GetBuilder<TeamAlliesController>(
                  init: controller,
                  initState: (_) {},
                  builder: (_) {
                    return SmartRefresher(
                      physics: const BouncingScrollPhysics(),
                      controller: controller.pullCtrl,
                      onLoading: controller.onLoad,
                      onRefresh: controller.onRefresh,
                      enablePullUp:
                          controller.count > controller.alliesDatas.length,
                      child: controller.alliesDatas.isEmpty
                          ? GetX<TeamAlliesController>(
                              init: controller,
                              builder: (_) {
                                return CustomEmptyView(
                                  isLoading: controller.isLoading,
                                );
                              },
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: controller.alliesDatas != null
                                  ? controller.alliesDatas.length
                                  : 0,
                              itemBuilder: (context, index) {
                                return ShCell(
                                  index: index,
                                  data: controller.alliesDatas[index],
                                  isMyBusiness: isMyBusiness ?? false,
                                  isDirectly: isDirectly,
                                  bStatus: controller.businessStatus,
                                  cellClick: (idx, cellData) {
                                    takeBackKeyboard(context);

                                    if (isMyBusiness!) {
                                      push(
                                          MyBusinessInfo(
                                            businessData: cellData,
                                            businessType: businessData,
                                          ),
                                          context,
                                          binding: MyBusinessInfoBinding());
                                    } else {
                                      push(
                                        TeamDetail(
                                          teamData: cellData,
                                        ),
                                        context,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }

  Widget filterButton(int idx) {
    return CustomButton(
      onPressed: () {
        if (controller.filterIdx == idx) {
          if (idx == 1) {
            controller.activeDesc = !controller.activeDesc;
          } else if (idx == 2) {
            controller.dealDesc = !controller.dealDesc;
          }
        } else {
          controller.filterIdx = idx;
          controller.activeDesc = true;
          controller.dealDesc = true;
        }
        controller.loadBusinessListData();
      },
      child: SizedBox(
        width: 375.w / 4 - 0.4.w,
        height: 50.w,
        child: Center(
            child: GetX<TeamAlliesController>(
          init: controller,
          builder: (_) {
            return centRow([
              getSimpleText(
                idx == 0
                    ? "全部"
                    : idx == 1
                        ? "按激活"
                        : "按交易",
                15,
                controller.filterIdx == idx
                    ? AppColor.buttonTextBlue
                    : const Color(0xFFB3B3B3),
              ),
              idx > 0
                  ? Icon(
                      Icons.unfold_more,
                      size: 15.w,
                      color: controller.filterIdx == idx
                          ? AppColor.buttonTextBlue
                          : const Color(0xFFB3B3B3),
                    )
                  : const SizedBox(),
            ]);
          },
        )),
      ),
    );
  }
}

class ShCell extends StatelessWidget {
  final int? index;
  final Map data;
  final bool? isMyBusiness;
  final bool? isDirectly;
  final List bStatus;
  final Function(
    int idx,
    Map cellData,
  )? cellClick;
  const ShCell({
    Key? key,
    this.data = const {},
    this.index,
    this.isDirectly = true,
    this.cellClick,
    this.isMyBusiness,
    this.bStatus = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (cellClick != null) {
          cellClick!(index!, data);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: 375.w,
          height: 140.w,
          color: Colors.white,
          child: Column(
            children: [
              sbhRow([
                Row(
                  children: [
                    getSimpleText("商户名称", 16, AppColor.textBlack, isBold: true),
                    gwb(17),
                    gline(1, 14),
                    gwb(17),
                    getSimpleText(
                      data["merchantName"] ?? "",
                      15,
                      AppColor.textBlack,
                    ),
                    // gwb(10),
                    // getSimpleText(
                    //   data["merchantName"] ?? "",
                    //   15,
                    //   AppColor.textBlack,
                    // ),
                  ],
                ),
                Icon(
                  Icons.play_circle_outline,
                  size: 20.w,
                  color: const Color(0xFFDCDCDC),
                ),
              ], height: 50, width: 375 - 24 * 2),
              gline(345, 1),
              ghb(10),
              sbhRow([
                getSimpleText(
                  "本月交易：${priceFormat(data["thisMTxnAmt"])}元",
                  15,
                  AppColor.textBlack,
                ),
              ], height: 30, width: 375 - 24 * 2),
              ghb(6),
              sbhRow([
                getSimpleText(
                  isMyBusiness!
                      ? "状态：${data["isActivation"] == null || data["isActivation"] > 0 ? "已激活" : "未激活"}"
                      : "本月激活：${data["isActivation"] ?? ""}台",
                  15,
                  AppColor.textBlack,
                ),
                isDirectly!
                    ? const SizedBox()
                    : getSimpleText(
                        "所属团队：" "",
                        15,
                        const Color(0xFFB3B3B3),
                      ),
              ], height: 30, width: 375 - 24 * 2),
            ],
          ),
        ),
      ),
    );
  }

  String getStatus(String status, List bStatus) {
    String tmp = "";
    if (status.isNotEmpty) {
      List l = status.split(",");
      for (var i = 0; i < l.length; i++) {
        int value = int.tryParse(l[i]) ?? -1;
        for (var e in bStatus) {
          if (value == e["enumValue"]) {
            if (i < l.length - 1) {
              tmp += "${e["enumName"] ?? ""},";
            } else {
              tmp += "${e["enumName"] ?? ""}";
            }
          }
        }
      }
    }
    return tmp;
  }
}
