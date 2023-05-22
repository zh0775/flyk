import 'dart:convert' as convert;

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/integralstore/integral_store_buycar.dart';
import 'package:cxhighversion2/integralstore/integral_store_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/user_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

class IntegralStoreBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IntegralStoreController>(
        IntegralStoreController(datas: Get.arguments));
  }
}

class IntegralStoreController extends GetxController {
  final dynamic datas;
  IntegralStoreController({this.datas});

  FocusNode searchNode = FocusNode();
  TextEditingController searcInputCtrl = TextEditingController();

  final _isLoadCollect = false.obs;
  bool get isLoadCollect => _isLoadCollect.value;
  set isLoadCollect(v) => _isLoadCollect.value = v;

  final _isList = false.obs;
  bool get isList => _isList.value;
  set isList(v) => _isList.value = v;

  loadAddCollect(Map data) {
    isLoadCollect = true;
    simpleRequest(
      url: Urls.userAddProductCollection(data["productId"], 1),
      params: {},
      success: (success, json) {
        if (success) {
          loadData();
        }
      },
      after: () {
        isLoadCollect = false;
      },
    );
  }

  loadRemoveCollect(Map data) {
    isLoadCollect = true;
    simpleRequest(
      url: Urls.userDeleteCollection(data["productId"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadData();
        }
      },
      after: () {
        isLoadCollect = false;
      },
    );
  }

  // RefreshController pullCtrl = RefreshController();
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _haveCleanInput = false.obs;
  bool get haveCleanInput => _haveCleanInput.value;
  set haveCleanInput(v) => _haveCleanInput.value = v;

  final _haveFocus = false.obs;
  bool get haveFocus => _haveFocus.value;
  set haveFocus(v) => _haveFocus.value = v;

  final _haveCleanAlert = false.obs;
  bool get haveCleanAlert => _haveCleanAlert.value;
  set haveCleanAlert(v) => _haveCleanAlert.value = v;

  final _filterIdx = 0.obs;
  int get filterIdx => _filterIdx.value;
  set filterIdx(v) {
    if (_filterIdx.value != v) {
      _filterIdx.value = v;
      if (filterIdx == 0) {
        buyCountSort = -1;
        priceSore = -1;
        addTimeSore = -1;
      } else if (filterIdx == 1) {
        allSort = -1;
        buyCountSort = -1;
        priceSore = -1;
      } else if (filterIdx == 2) {
        allSort = -1;
        buyCountSort = -1;
        addTimeSore = -1;
      } else if (filterIdx == 3) {
        allSort = -1;
        priceSore = -1;
        addTimeSore = -1;
      }
    }
  }

  final _allSort = (-1).obs;
  int get allSort => _allSort.value;
  set allSort(v) => _allSort.value = v;

  final _buyCountSort = (-1).obs;
  int get buyCountSort => _buyCountSort.value;
  set buyCountSort(v) => _buyCountSort.value = v;

  final _priceSore = (-1).obs;
  int get priceSore => _priceSore.value;
  set priceSore(v) => _priceSore.value = v;

  final _addTimeSore = (-1).obs;
  int get addTimeSore => _addTimeSore.value;
  set addTimeSore(v) => _addTimeSore.value = v;

  searchNodeListener() {
    // if (searchNode.hasFocus) {
    haveFocus = searchNode.hasFocus;
    // print("searchNode.hasFocus === ${searchNode.hasFocus}");
    // }
  }

  searcInputCtrlListener() {
    haveCleanInput = searcInputCtrl.text.isNotEmpty;
  }

  List dataList = [];

  int count = 0;
  int pageSize = 20;
  int pageNo = 1;

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
      // "isBoutique": 0,
      "shop_Type": 2,
    };
    if (filterIdx == 0) {
      // params["nOrderTime"] = -1;
      // params["nOrderDownload"] = -1;
    } else if (filterIdx == 1) {
      params["addTime"] = "${addTimeSore == 0 ? 1 : 0}";
      // params["nOrderDownload"] = -1;
    } else if (filterIdx == 2) {
      // params["nOrderTime"] = -1;
      params["shop_Price"] = "${priceSore == 0 ? 1 : 0}";
    } else if (filterIdx == 3) {
      params["shop_Buy_Count"] = "${buyCountSort == 0 ? 1 : 0}";
      // params["nOrderDownload"] = -1;
    }
    if (searcInputCtrl.text.isNotEmpty) {
      params["shop_Name"] = searcInputCtrl.text;
    }
    if (categoryId1 != -1 && categoryId2 != -1) {
      params["shop_Classe_1"] = categoryId1;
      params["shop_Classe_2"] = categoryId2;
    }

    simpleRequest(
      url: Urls.userProductList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];

          dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
          update();
          // isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
        } else {
          // isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
        isFirstLoading = false;
      },
    );
  }

  final _searchHistorys = Rx<List>([]);
  List get searchHistorys => _searchHistorys.value;
  set searchHistorys(v) => _searchHistorys.value = v;

  setHistory(String str) {
    if (str.isEmpty) {
      return;
    }
    if (searchHistorys.contains(str)) {
      searchHistorys.remove(str);
    }
    if (searchHistorys.length > 20) {
      searchHistorys.removeAt(0);
    }
    searchHistorys.insert(0, str);
    searchHistorys = searchHistorys;
    UserDefault.saveStr("ShoppingProductList_Search_History",
        convert.jsonEncode(searchHistorys));
  }

  removeHistory(String str) {
    if (str.isEmpty) {
      return;
    }
    if (searchHistorys.contains(str)) {
      searchHistorys.remove(str);
    }
    searchHistorys = searchHistorys;
    UserDefault.saveStr("ShoppingProductList_Search_History",
        convert.jsonEncode(searchHistorys));
  }

  getHistory() async {
    String? h = await UserDefault.get("ShoppingProductList_Search_History");
    if (h != null && h.isNotEmpty) {
      searchHistorys = convert.jsonDecode(h);
    } else {
      searchHistorys = [];
    }
  }

  cleanHistory() {
    searchHistorys = [];
    UserDefault.removeByKey("ShoppingProductList_Search_History");
  }

  searchAction() {
    takeBackKeyboard(Global.navigatorKey.currentContext!);
    loadData();
    setHistory(searcInputCtrl.text);
  }

  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: kIsWeb ? 300 : 0), () {
      getHistory();
      loadData();
    });
    if (fromSearch) {
      searchNode.requestFocus();
    }
    super.onReady();
  }

  bool fromSearch = false;
  int categoryId1 = -1;
  int categoryId2 = -1;
  @override
  void onInit() {
    fromSearch = (datas ?? {})["isSearch"] ?? false;
    categoryId1 = (datas ?? {})["categoryId1"] ?? -1;
    categoryId2 = (datas ?? {})["categoryId2"] ?? -1;

    // Map publicHomeData = AppDefault().publicHomeData;
    searchNode.addListener(searchNodeListener);
    searcInputCtrl.addListener(searcInputCtrlListener);

    super.onInit();
  }

  @override
  void onClose() {
    searchNode.removeListener(searchNodeListener);
    searchNode.dispose();
    searcInputCtrl.removeListener(searcInputCtrlListener);
    searcInputCtrl.dispose();
    super.onClose();
  }
}

class IntegralStore extends GetView<IntegralStoreController> {
  const IntegralStore({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "商品列表", action: [
          CustomButton(
            onPressed: () {
              // controller.isList = !controller.isList;
              push(const IntegralStoreBuycar(), context,
                  binding: IntegralStoreBuycarBinding());
            },
            child: SizedBox(
              height: kToolbarHeight,
              width: 50.w,
              child: Center(
                  child: Image.asset(
                assetsName(
                  "integral_store/btn_addcar",
                  // "home/store/btn_${controller.isList ? "list" : "wrap"}",
                ),
                width: 24.w,
                fit: BoxFit.fitWidth,
              )),
            ),
          )
        ]),
        body: Stack(children: [
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 55.w,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    gwb(375),
                    ghb(5.5),
                    Container(
                      width: 345.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                          color: AppColor.pageBackgroundColor,
                          borderRadius: BorderRadius.circular(20.w)),
                      child: Row(
                        children: [
                          gwb(20),
                          CustomInput(
                            textEditCtrl: controller.searcInputCtrl,
                            focusNode: controller.searchNode,
                            width: (345 - 20 - 45 - 1 - 0.1 - 27.5).w,
                            heigth: 40.w,
                            placeholder: "请输入想要搜索的商品名称",
                            placeholderStyle: TextStyle(
                                fontSize: 12.sp, color: AppColor.textGrey2),
                            style: TextStyle(
                                fontSize: 12.sp, color: AppColor.textBlack),
                            onSubmitted: (p0) {
                              takeBackKeyboard(context);
                              controller.searchAction();
                            },
                          ),
                          GetX<IntegralStoreController>(
                            builder: (_) {
                              return !controller.haveCleanInput
                                  ? gwb(27.5)
                                  : CustomButton(
                                      onPressed: () {
                                        controller.searcInputCtrl.clear();
                                        takeBackKeyboard(context);
                                      },
                                      child: SizedBox(
                                        width: 27.5.w,
                                        height: 30.w,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Image.asset(
                                            assetsName(
                                                "common/btn_search_input_close"),
                                            width: 15.w,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                    );
                            },
                          ),
                          CustomButton(
                            onPressed: () {
                              takeBackKeyboard(context);
                              controller.searchAction();
                            },
                            child: SizedBox(
                              width: 30.w,
                              height: 40.w,
                              child: Center(
                                child: Image.asset(
                                  assetsName("machine/icon_search"),
                                  width: 18.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
          Positioned(
            top: 55.w,
            left: 0,
            right: 0,
            height: 55.w,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom: BorderSide(
                          width: 1.w, color: AppColor.pageBackgroundColor))),
              child: Column(
                children: [
                  sbhRow(
                      List.generate(4, (index) {
                        String title = "";

                        switch (index) {
                          case 0:
                            title = "综合";

                            break;
                          case 1:
                            title = "按时间";

                            break;
                          case 2:
                            title = "按积分";

                            break;
                          case 3:
                            title = "按热度";

                            break;
                        }

                        return CustomButton(
                          onPressed: () {
                            controller.filterIdx = index;
                            if (index == 0) {
                              if (controller.allSort == -1) {
                                controller.allSort = 0;
                              }
                              //  else if (controller.allSort == 0) {
                              //   controller.allSort = 1;
                              // } else {
                              //   controller.allSort = 0;
                              // }
                            } else if (index == 1) {
                              if (controller.addTimeSore == -1) {
                                controller.addTimeSore = 0;
                              } else if (controller.addTimeSore == 0) {
                                controller.addTimeSore = 1;
                              } else {
                                controller.addTimeSore = 0;
                              }
                            } else if (index == 2) {
                              if (controller.priceSore == -1) {
                                controller.priceSore = 0;
                              } else if (controller.priceSore == 0) {
                                controller.priceSore = 1;
                              } else {
                                controller.priceSore = 0;
                              }
                            } else if (index == 3) {
                              if (controller.buyCountSort == -1) {
                                controller.buyCountSort = 0;
                              } else if (controller.buyCountSort == 0) {
                                controller.buyCountSort = 1;
                              } else {
                                controller.buyCountSort = 0;
                              }
                            }
                            controller.loadData();
                          },
                          child: GetX<IntegralStoreController>(
                            builder: (_) {
                              return SizedBox(
                                height: 55.w,
                                width: 375.w / 4,
                                child: centRow([
                                  getSimpleText(
                                      title,
                                      15,
                                      controller.filterIdx == index
                                          ? AppColor.textBlack
                                          : AppColor.textGrey,
                                      isBold: controller.filterIdx == index),
                                  GetX<IntegralStoreController>(
                                    builder: (controller) {
                                      bool desc = false;
                                      if (index == 0 &&
                                          (controller.allSort == -1 ||
                                              controller.allSort == 0)) {
                                        desc = true;
                                      } else if (index == 1 &&
                                          (controller.addTimeSore == -1 ||
                                              controller.addTimeSore == 0)) {
                                        desc = true;
                                      } else if (index == 2 &&
                                          (controller.priceSore == -1 ||
                                              controller.priceSore == 0)) {
                                        desc = true;
                                      } else if (index == 3 &&
                                          (controller.buyCountSort == -1 ||
                                              controller.buyCountSort == 0)) {
                                        desc = true;
                                      }
                                      return index == 0
                                          ? ghb(0)
                                          : Padding(
                                              padding:
                                                  EdgeInsets.only(left: 3.w),
                                              child: Image.asset(
                                                assetsName(
                                                    "integral_store/btn_sort_${controller.filterIdx == index ? desc ? "desc" : "asc" : "none"}"),
                                                width: 6.w,
                                                fit: BoxFit.fitWidth,
                                              ),
                                            );
                                    },
                                  )
                                ]),
                              );
                            },
                          ),
                        );
                      }),
                      height: 45,
                      width: 375),
                  SizedBox(
                    height: 9.w,
                    width: 375.w,
                    child: Stack(
                      children: [
                        GetX<IntegralStoreController>(
                          builder: (_) {
                            return AnimatedPositioned(
                              top: 0,
                              left: ((375.w / 4) / 2 - 15.w / 2) +
                                  (controller.filterIdx * (375.w / 4)),
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                width: 15.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: AppColor.theme,
                                  borderRadius: BorderRadius.circular(0.5.w),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned.fill(
              top: 110.w,
              child: GetBuilder<IntegralStoreController>(
                builder: (_) {
                  return EasyRefresh.builder(
                      // controller: controller.pullCtrl,
                      onLoad: controller.dataList.length >= controller.count
                          ? null
                          : () => controller.loadData(isLoad: true),
                      // onLoading: () => controller.loadData(isLoad: true),
                      onRefresh: () => controller.loadData(),
                      // enablePullUp: controller.count > controller.dataList.length,
                      childBuilder: (context, physics) {
                        return controller.dataList.isEmpty
                            ? GetX<IntegralStoreController>(
                                builder: (controller) {
                                return controller.isFirstLoading && !kIsWeb
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            top: 15.w, left: 15.w),
                                        child: SizedBox(
                                            width: 345.w,
                                            child: Wrap(
                                                spacing: 10.w,
                                                runSpacing: 10.w,
                                                children: List.generate(
                                                    4,
                                                    (index) => SkeletonAvatar(
                                                            style:
                                                                SkeletonAvatarStyle(
                                                          width:
                                                              (375 - 15 * 2 - 10)
                                                                          .w /
                                                                      2 -
                                                                  0.1.w,
                                                          height: 270.w,
                                                        ))))))
                                    : CustomListEmptyView(
                                        physics: physics,
                                        isLoading: controller.isLoading);
                              })
                            : GetX<IntegralStoreController>(builder: (_) {
                                return ListView.builder(
                                    physics: physics,
                                    padding: EdgeInsets.only(bottom: 20.w),
                                    itemCount: controller.isList
                                        ? controller.dataList.length
                                        : (controller.dataList.length / 2)
                                            .ceil(),
                                    itemBuilder: (context, index) {
                                      return controller.isList
                                          ? cellList(
                                              index, controller.dataList[index])
                                          : cell(index);
                                    });
                              });
                      });
                },
              )),
          GetX<IntegralStoreController>(
            builder: (_) {
              return !controller.haveFocus && !controller.haveCleanAlert
                  ? gemp()
                  : Positioned(
                      left: 0,
                      right: 0,
                      top: 55.w,
                      height: 300.w,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                top: BorderSide(
                                    width: 1.w,
                                    color: AppColor.pageBackgroundColor))),
                        child: Column(
                          children: [
                            sbhRow([
                              getSimpleText("搜索历史", 15, AppColor.textBlack),
                              CustomButton(
                                onPressed: () async {
                                  controller.haveCleanAlert = true;
                                  await showAlert(
                                    context,
                                    "是否确定删除搜索历史",
                                    confirmOnPressed: () {
                                      Get.back();
                                      controller.cleanHistory();
                                    },
                                    cancelOnPressed: () {
                                      Get.back();
                                    },
                                  );
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    controller.haveCleanAlert = false;
                                  });
                                },
                                child: SizedBox(
                                  height: 58.w,
                                  child: Center(
                                    child: getSimpleText(
                                        "清空", 12, AppColor.textGrey5),
                                  ),
                                ),
                              ),
                            ], width: 345, height: 58),
                            SizedBox(
                              width: 345.w,
                              child: GetX<IntegralStoreController>(
                                builder: (_) {
                                  return Wrap(
                                    runSpacing: 10.w,
                                    spacing: 10.w,
                                    children: List.generate(
                                        controller.searchHistorys.length,
                                        (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          controller.searcInputCtrl.text =
                                              controller.searchHistorys[index];
                                          controller.loadData();
                                          takeBackKeyboard(context);
                                        },
                                        onLongPress: () async {
                                          controller.haveCleanAlert = true;
                                          showAlert(
                                            context,
                                            "是否删除该记录",
                                            confirmOnPressed: () {
                                              Get.back();
                                              controller.removeHistory(
                                                  controller
                                                      .searchHistorys[index]);
                                            },
                                          );

                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            controller.haveCleanAlert = false;
                                          });
                                        },
                                        child: UnconstrainedBox(
                                          child: Container(
                                            // alignment: Alignment.center,
                                            height: 24.w,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15.w),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF6F6F6),
                                              borderRadius:
                                                  BorderRadius.circular(12.w),
                                            ),
                                            child: Center(
                                              child: getSimpleText(
                                                  controller
                                                      .searchHistorys[index],
                                                  14,
                                                  AppColor.textGrey5,
                                                  textHeight: 0.9),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ));
            },
          )
        ]),
      ),
    );
  }

  Widget cellList(int index, Map data) {
    return Center(
      child: CustomButton(
        onPressed: () {
          push(const IntegralstoreDetail(), null,
              binding: IntegralstoreDetailBinding(),
              arguments: {
                "data": data,
              });
        },
        child: Container(
          margin: EdgeInsets.only(top: 15.w),
          width: 345.w,
          height: 120.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(3.w)),
          child: sbRow([
            ClipRRect(
              borderRadius: BorderRadius.circular(3.w),
              child: SizedBox(
                width: 120.w,
                height: 120.w,
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: CustomNetworkImage(
                      src: AppDefault().imageUrl + (data["shopImg"] ?? ""),
                      width: 120.w,
                      height: 120.w,
                      fit: BoxFit.cover,
                    )),
                    (data["cashPrice"] ?? 0) > 0
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: 55.w,
                              height: 15.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFE5E00),
                                      Color(0xFFFB7600),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4.w),
                                  bottomRight: Radius.circular(8.w),
                                ),
                              ),
                              child: getSimpleText("积分+现金", 10, Colors.white),
                            ),
                          )
                        : gemp(),
                  ],
                ),
              ),
            ),
            sbClm([
              getWidthText(
                  data["shopName"] ?? "", 15, AppColor.textBlack, 209, 2),
              centClm([
                getSimpleText(
                    "${priceFormat(data["nowPrice"] ?? 0, savePoint: 0)}积分",
                    18,
                    AppColor.theme,
                    isBold: true),
                sbRow([
                  getSimpleText("已兑${data["shopBuyCount"] ?? 0}个", 12,
                      AppColor.textGrey5),
                  // GetBuilder<IntegralStoreController>(
                  //   builder: (_) {
                  //     return CustomButton(
                  //       onPressed: () {
                  //         if ((data["isCollect"] ?? 0) == 0) {
                  //           controller.loadAddCollect(data);
                  //         } else {
                  //           controller.loadRemoveCollect(data);
                  //         }
                  //         // data["favoriteStatus"] =
                  //         //     !data["favoriteStatus"];
                  //         // //
                  //         // controller.update();
                  //       },
                  //       child: SizedBox(
                  //         width: 52.w,
                  //         height: 28.w,
                  //         child: Align(
                  //           alignment: Alignment.center,
                  //           child: Image.asset(
                  //             assetsName((data["isCollect"] ?? 0) == 0
                  //                 ? 'business/mall/btn_collect'
                  //                 : 'business/mall/btn_iscollect'),
                  //             width: 16.w,
                  //             fit: BoxFit.fitWidth,
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // )
                ], width: 209),
              ], crossAxisAlignment: CrossAxisAlignment.start)
            ], crossAxisAlignment: CrossAxisAlignment.start, height: 100)
          ], width: 345),
        ),
      ),
    );
  }

  Widget cell(int index) {
    return Padding(
      padding: EdgeInsets.only(top: 15.w),
      child: Center(
        child: sbRow(
            List.generate(2, (idx) {
              Map data = {};
              if (index * 2 + idx <= controller.dataList.length - 1) {
                data = controller.dataList[index * 2 + idx];
              }
              return data.isEmpty
                  ? gwb(0)
                  : CustomButton(
                      onPressed: () {
                        push(const IntegralstoreDetail(), null,
                            binding: IntegralstoreDetailBinding(),
                            arguments: {
                              "data": data,
                            });
                      },
                      child: Container(
                        width: 167.5.w,

                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3.w)),
                        // 167.5.w,
                        height: 270.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(3.w)),
                              child: SizedBox(
                                width: 167.5.w,
                                height: 167.5.w,
                                child: Stack(children: [
                                  Positioned.fill(
                                      child: CustomNetworkImage(
                                          src: AppDefault().imageUrl +
                                              (data["shopImg"] ?? ""),
                                          width: 167.5.w,
                                          height: 167.5.w,
                                          fit: BoxFit.cover)),
                                  (data["cashPrice"] ?? 0) > 0
                                      ? Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            width: 55.w,
                                            height: 15.w,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFE5E00),
                                                    Color(0xFFFB7600),
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(4.w),
                                                bottomRight:
                                                    Radius.circular(8.w),
                                              ),
                                            ),
                                            child: getSimpleText(
                                                "积分+现金", 10, Colors.white),
                                          ),
                                        )
                                      : gemp(),
                                ]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0.w),
                              width: 167.5.w,
                              height: 102.5.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 45.w,
                                    child: getWidthText(data['shopName'] ?? "",
                                        14.w, AppColor.textBlack, 149.w, 2,
                                        textAlign: TextAlign.left,
                                        alignment: Alignment.topLeft),
                                  ),
                                  getSimpleText(
                                    "${priceFormat(data['nowPrice'] ?? 0, savePoint: 0)}积分",
                                    18,
                                    AppColor.theme,
                                    isBold: true,
                                  ),
                                  sbhRow([
                                    getSimpleText(
                                        "已兑${data['shopBuyCount'] ?? 0}个",
                                        12,
                                        AppColor.textGrey5,
                                        textAlign: TextAlign.left),
                                    // centRow([
                                    //   GetBuilder<IntegralStoreController>(
                                    //     builder: (_) {
                                    //       return CustomButton(
                                    //         onPressed: () {
                                    //           if ((data["isCollect"] ?? 0) ==
                                    //               0) {
                                    //             controller.loadAddCollect(data);
                                    //           } else {
                                    //             controller
                                    //                 .loadRemoveCollect(data);
                                    //           }
                                    //           // data["favoriteStatus"] =
                                    //           //     !data["favoriteStatus"];
                                    //           // //
                                    //           // controller.update();
                                    //         },
                                    //         child: SizedBox(
                                    //           width: 32.w,
                                    //           height: 28.w,
                                    //           child: Align(
                                    //             alignment:
                                    //                 Alignment.bottomRight,
                                    //             child: Image.asset(
                                    //               assetsName((data[
                                    //                               "isCollect"] ??
                                    //                           0) ==
                                    //                       0
                                    //                   ? 'business/mall/btn_collect'
                                    //                   : 'business/mall/btn_iscollect'),
                                    //               width: 16.w,
                                    //               fit: BoxFit.fitWidth,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       );
                                    //     },
                                    //   )
                                    // ])
                                  ], width: 167.5 - 10 * 2, height: 14.w),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
            }),
            width: 345),
      ),
    );
  }
}
