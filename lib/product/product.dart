import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/home/component/machine_product_list.dart';
import 'package:cxhighversion2/product/product_purchase_detail.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProductController>(ProductController());
  }
}

class ProductController extends GetxController {
  final _isList = true.obs;
  set isList(value) => _isList.value = value;
  get isList => _isList.value;
  CustomEmptyType emptyType = CustomEmptyType.noData;
  updataListType(value) {
    _isList.value = value;
  }

  final _topIdx = 0.obs;
  get topIdx => _topIdx.value;
  set topIdx(v) => _topIdx.value = v;

  String xhListBuildId = "Product_xhListBuildId";
  String zcListBuildId = "Product_zcListBuildId";
  String ppListBuildId = "Product_ppListBuildId";

  final _productDatas = Rx<List>([]);

  get productDatas => _productDatas.value;
  set productDatas(v) => _productDatas.value = v;

  int pageNo = 1;
  int pageSize = 10;
  int count = 0;

  userLevelGiftRequest(String url, Map<String, dynamic> params,
      Function(bool success, dynamic json) success) {
    Http().doPost(
      url,
      params,
      success: (json) {
        if (json["success"]) {
          success(true, json);
        } else {
          success(false, json);
        }
      },
      fail: (reason, code, json) {
        success(false, json);
      },
    );
  }

  final _xhList = Rx<List>([]);
  List get xhList => _xhList.value;
  set xhList(v) => _xhList.value = v;

  final _zcList = Rx<List>([]);
  get zcList => _zcList.value;
  set zcList(v) => _zcList.value = v;

  final _ppList = Rx<List>([]);
  get ppList => _ppList.value;
  set ppList(v) => _ppList.value = v;

  loadList(Function(bool success) success, {bool isLoad = false}) {
    if (isLoad) {
      pageNo++;
    } else {
      pageNo = 1;
    }

    Map<String, dynamic> params = {
      "pageNo": pageNo,
      "pageSize": pageSize,
      "level_Type": "3"
    };

    if (topIdx != 0) {
      params["tmId"] = "${xhList[topIdx]["enumValue"]}";
    }

    String ppStr = "";
    for (var item in ppList) {
      if (item["selected"]) {
        if (ppStr.isEmpty) {
          ppStr += "${item["enumValue"]}";
        } else {
          ppStr += ",${item["enumValue"]}";
        }
      }
    }
    if (ppStr.isNotEmpty) {
      params["tbId"] = ppStr;
    }

    String zcStr = "";
    for (var item in zcList) {
      if (item["selected"]) {
        if (zcStr.isEmpty) {
          zcStr += "${item["id"]}";
        } else {
          zcStr += ",${item["id"]}";
        }
      }
    }
    if (zcStr.isNotEmpty) {
      params["tcId"] = zcStr;
    }

    userLevelGiftRequest(Urls.memberList, params, (suc, json) {
      if (suc) {
        success(true);
        emptyType = CustomEmptyType.noData;
        Map data = json["data"];
        count = data["count"];
        if (isLoad) {
          productDatas = [...productDatas, ...data["data"]];
        } else {
          productDatas = data["data"];
        }
      } else {
        emptyType = CustomEmptyType.networkError;
        success(false);
      }
    });
  }

  @override
  void onInit() {
    needUpdate();
    bus.on(USER_LOGIN_NOTIFY, getNotify);
    bus.on(HOME_DATA_UPDATE_NOTIFY, getNotify);
    bus.on(HOME_PUBLIC_DATA_UPDATE_NOTIFY, getNotify);
    super.onInit();
  }

  getNotify(arg) {
    needUpdate();
  }

  needUpdate() async {
    Map userData = await getUserData();
    // Map homeData = userData["homeData"];
    Map publicHomeData = userData["publicHomeData"];
    if (publicHomeData.isNotEmpty &&
        publicHomeData["terminalBrand"].isNotEmpty &&
        publicHomeData["terminalBrand"] is List) {
      ppList = (publicHomeData["terminalBrand"] as List)
          .map((e) => {...e, "selected": false})
          .toList();

      update([ppListBuildId]);
    }
    if (publicHomeData.isNotEmpty &&
        publicHomeData["terminalConfig"].isNotEmpty &&
        publicHomeData["terminalConfig"] is List) {
      zcList = (publicHomeData["terminalConfig"] as List)
          .map((e) => {...e, "selected": false})
          .toList();
      update([zcListBuildId]);
    }
    if (publicHomeData.isNotEmpty &&
        publicHomeData["terminalMod"].isNotEmpty &&
        publicHomeData["terminalMod"] is List) {
      xhList = [
        {"enumValue": -1, "enumName": "全部"},
        ...publicHomeData["terminalMod"]
      ].map((e) => {...e, "selected": false}).toList();
      update([xhListBuildId]);
    }
    loadList((bool success) {});
  }

  @override
  void onClose() {
    bus.off(USER_LOGIN_NOTIFY, getNotify);
    bus.off(HOME_DATA_UPDATE_NOTIFY, getNotify);
    bus.off(HOME_PUBLIC_DATA_UPDATE_NOTIFY, getNotify);
    super.onClose();
  }
}

class Product extends StatefulWidget {
  final bool subPage;
  const Product({Key? key, this.subPage = false}) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> with AutomaticKeepAliveClientMixin {
  final controller = Get.find<ProductController>();
  final pullCtrl = RefreshController();

  @override
  void dispose() {
    pullCtrl.dispose();
    super.dispose();
  }

  onRefresh() async {
    controller.loadList((success) {
      if (success) {
        pullCtrl.refreshCompleted();
      } else {
        pullCtrl.refreshFailed();
      }
    });
  }

  onLoad() async {
    controller.loadList((success) {
      if (success) {
        pullCtrl.loadComplete();
      } else {
        pullCtrl.loadFailed();
      }
    }, isLoad: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: getDefaultAppBar(context, "机具产品",
          leading: widget.subPage ? null : gemp()),
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 55.w,
              child: Container(
                color: Colors.white,
                child: Row(children: [
                  SizedBox(
                    width: 275.w,
                    height: 55.w,
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: GetBuilder<ProductController>(
                          init: controller,
                          id: controller.xhListBuildId,
                          initState: (_) {},
                          builder: (_) {
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.xhList.isNotEmpty
                                  ? controller.xhList.length
                                  : 0,
                              itemBuilder: (context, index) {
                                return xhButtons(
                                    index, controller.xhList[index]);
                              },
                            );
                          },
                        ))
                      ],
                    ),
                  ),
                  GetX<ProductController>(
                    init: ProductController(),
                    builder: (_) {
                      return CustomButton(
                        onPressed: () {
                          _.updataListType(!_.isList);
                        },
                        child: SizedBox(
                          width: 50.w,
                          height: 55.w,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _.isList
                                ? Icon(
                                    Icons.table_rows_rounded,
                                    color: AppColor.textBlack,
                                    size: 20.w,
                                  )
                                : Icon(
                                    Icons.grid_view_rounded,
                                    color: AppColor.textBlack,
                                    size: 20.w,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  CustomButton(
                      onPressed: () {
                        _showFilter();
                      },
                      child: SizedBox(
                        height: 55.w,
                        width: 50.w,
                        child: Center(
                          child: Icon(
                            Icons.filter_alt_rounded,
                            color: AppColor.textBlack,
                            size: 20.w,
                          ),
                        ),
                      ))
                ]),
              )),
          Positioned(
              top: 55.w,
              left: 0,
              right: 0,
              bottom: 0,
              child: GetX<ProductController>(
                init: controller,
                builder: (_) {
                  return MachineProductList(
                    pullCtrl: pullCtrl,
                    paddingBottom: 20.w,
                    emptyType: controller.emptyType,
                    isList: controller.isList,
                    onLoading: onLoad,
                    onRefresh: onRefresh,
                    retryAction: () {
                      controller.loadList((success) {});
                    },
                    enablePullUp:
                        controller.productDatas.length < controller.count,
                    machineDatas: controller.productDatas,
                    toPay: (idx) {
                      push(
                          ProductPurchaseDetail(
                            productData: controller.productDatas[idx],
                          ),
                          context,
                          binding: ProductPurchaseDetailBinding());
                      // push(
                      //     ProductPurchaseList(
                      //       productData: controller.productDatas[idx],
                      //     ),
                      //     context);
                    },
                  );
                },
              )),
        ],
      ),
    );
  }

  void _showFilter() {
    Get.bottomSheet(
      SizedBox(
        width: 375.w,
        height: (530 + 56.5).w,
        child: Stack(
          children: [
            Positioned(
                right: 24.w,
                top: 0,
                width: 37.w,
                height: 56.5.w,
                child: CustomButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Image.asset(
                    assetsName(
                      "common/btn_model_close",
                    ),
                    width: 37.w,
                    height: 56.5.w,
                    fit: BoxFit.fill,
                  ),
                )),
            Positioned(
                top: 56.5.w,
                left: 0,
                right: 0,
                bottom: (29 * 2 + 50).w + paddingSizeBottom(context),
                child: Container(
                  color: const Color(0xFFEBEBEB),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ghb(19.5),
                        getSimpleText("其他筛选", 20, AppColor.textBlack,
                            isBold: true),
                        ghb(19.5),
                        gline(345, 0.5),
                        ghb(10),
                        SizedBox(
                          width: 325.w,
                          child: Row(
                            children: [
                              getSimpleText(
                                "品牌",
                                17,
                                AppColor.textBlack,
                              ),
                            ],
                          ),
                        ),
                        ghb(10),
                        GetBuilder<ProductController>(
                          id: controller.ppListBuildId,
                          init: controller,
                          builder: (_) {
                            return _buildBrandButton();
                          },
                        ),
                        ghb(24),
                        SizedBox(
                          width: 325.w,
                          child: Row(
                            children: [
                              getSimpleText("机具型号", 17, AppColor.textBlack),
                            ],
                          ),
                        ),
                        ghb(10),
                        GetBuilder<ProductController>(
                          id: controller.zcListBuildId,
                          init: controller,
                          builder: (_) {
                            return _buildPolicyButton();
                          },
                        ),
                        ghb(20),
                      ],
                    ),
                  ),
                )),
            Positioned(
                bottom: 0,
                height: (29 * 2 + 50).w + paddingSizeBottom(context),
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFEBEBEB),
                      border: Border(
                          top: BorderSide(
                              width: 0.5.w, color: const Color(0xFFE0E0E0)))),
                )),
            Positioned(
                left: 15.w,
                bottom: 29.w + paddingSizeBottom(context),
                child: CustomButton(
                  onPressed: () {
                    controller.loadList((success) {});
                    Get.back();
                  },
                  child: Container(
                    width: 345.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        color: const Color(0xFF4282EB)),
                    child: Center(
                      child:
                          getSimpleText("确定", 15, Colors.white, isBold: true),
                    ),
                  ),
                ))
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget xhButtons(int index, Map data) {
    return CustomButton(
      onPressed: () {
        controller.topIdx = index;
        controller.loadList((success) {});
        controller.update([controller.xhListBuildId]);
      },
      child: SizedBox(
          height: 55.w,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: getSimpleText(
                  data["enumName"] ?? "",
                  14,
                  index == controller.topIdx
                      ? AppColor.buttonTextBlue
                      : AppColor.textGrey2),
            ),
          )),
    );
  }

  Widget _buildBrandButton() {
    return Center(
      child: SizedBox(
        width: 345.w,
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.w,
          children: (controller.ppList as List).map((e) {
            return CustomButton(
              onPressed: () {
                e["selected"] = !e["selected"];
                controller.update([controller.ppListBuildId]);
              },
              child: UnconstrainedBox(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  height: 45.w,
                  // constraints: BoxConstraints(minWidth: 0, maxWidth: 200.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: e["selected"]
                          ? AppColor.buttonTextBlue
                          : Colors.white),
                  child: Center(
                    child: getSimpleText(e["enumName"] ?? "", 16,
                        e["selected"] ? Colors.white : AppColor.textBlack),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPolicyButton() {
    return SizedBox(
      width: 345.w,
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.w,
        children: (controller.zcList as List).map((e) {
          return CustomButton(
            onPressed: () {
              e["selected"] = !e["selected"];
              controller.update([controller.zcListBuildId]);
            },
            child: UnconstrainedBox(
              child: Container(
                height: 45.w,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        e["selected"] ? AppColor.buttonTextBlue : Colors.white),
                child: Center(
                  child: getSimpleText(e["terninal_Name"], 14,
                      e["selected"] ? Colors.white : AppColor.textBlack),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => !widget.subPage;
}
