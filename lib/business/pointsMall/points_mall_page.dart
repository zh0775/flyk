import 'package:cxhighversion2/business/mallQuickEntry/redemption_list.dart';
import 'package:cxhighversion2/business/pointsMall/shopping_cart_page.dart';
import 'package:cxhighversion2/business/pointsMall/shopping_product_detail.dart';
import 'package:cxhighversion2/business/pointsMall/shopping_product_list.dart';
import 'package:cxhighversion2/component/app_banner.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

import 'mall_cart_page.dart';
import 'user_mall_page.dart';

class PointsMallPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<PointsMallPageController>(PointsMallPageController());
  }
}

class PointsMallPageController extends GetxController {
  final _tabIdx = 0.obs;
  int get tabIdx => _tabIdx.value;
  set tabIdx(v) => _tabIdx.value = v;
  // final searchInputCtrl = TextEditingController();

  List<BannerData> banner = <BannerData>[
    BannerData(
        imagePath: 'business/mall/mall_banner',
        id: '1',
        boxFit: BoxFit.fitHeight),
  ];

  List productList = [];

  searchAction() {
    // loadData(searchStr: searchInputCtrl.text);
  }

  final _isLoadCollect = false.obs;
  bool get isLoadCollect => _isLoadCollect.value;
  set isLoadCollect(v) => _isLoadCollect.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

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

  loadData({String? searchStr}) {
    Map<String, dynamic> params = {
      "pageSize": 6,
      "pageNo": 1,
      "isBoutique": 1,
      "shop_Type": 2,
    };
    if (searchStr != null && searchStr.isNotEmpty) {
      params["shop_Name"] = searchStr;
    }

    simpleRequest(
      url: Urls.userProductList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          productList = data["data"] ?? [];
          update();
        }
      },
      after: () {
        isFirstLoading = false;
      },
      // useCache: true,
    );
  }

  @override
  void onInit() {
    loadData();

    super.onInit();
  }

  @override
  void onClose() {
    // searchInputCtrl.dispose();
    super.onClose();
  }
}

class PointsMallPage extends GetView<PointsMallPageController> {
  const PointsMallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFFFFFFF),
      body: GetX<PointsMallPageController>(
        builder: (_) {
          return IndexedStack(
            index: controller.tabIdx,
            children: [
              homePage(context),
              const MallCartPage(),
              const ShoppingCartPage(),
              const UserMallPage(),
            ],
          );
        },
      ),
      bottomNavigationBar: GetX<PointsMallPageController>(
        builder: (_) {
          return BottomNavigationBar(
            currentIndex: controller.tabIdx,
            items: List.generate(
                4,
                (index) => BottomNavigationBarItem(
                    icon: centClm([
                      Image.asset(
                        assetsName(
                            "business/tabbar/${index == 0 ? "home_" : index == 1 ? "class_" : index == 2 ? "car_" : "mine_"}normal"),
                        width: 30.w,
                        fit: BoxFit.fitWidth,
                      ),
                    ]),
                    label: index == 0
                        ? "首页"
                        : index == 1
                            ? "分类"
                            : index == 2
                                ? "购物车"
                                : "我的",
                    activeIcon: Image.asset(
                      assetsName(
                          "business/tabbar/${index == 0 ? "home_" : index == 1 ? "class_" : index == 2 ? "car_" : "mine_"}selected"),
                      width: 30.w,
                      fit: BoxFit.fitWidth,
                    ))),
            type: BottomNavigationBarType.fixed,
            iconSize: 30.w,
            selectedItemColor: AppColor.themeOrange,
            unselectedItemColor: AppColor.text3,
            unselectedFontSize: 10.w,
            selectedFontSize: 10.w,
            onTap: (index) {
              controller.tabIdx = index;
            },
          );
        },
      ),
    );
  }

  Widget homePage(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        "积分商城",
      ),
      body: GetBuilder<PointsMallPageController>(
        init: PointsMallPageController(),
        initState: (_) {},
        builder: (_) {
          return EasyRefresh(
            onLoad: null,
            header: kIsWeb ? const MaterialHeader() : const CupertinoHeader(),
            onRefresh: () => controller.loadData(),
            child: SingleChildScrollView(
              child: Column(children: [
                mallTop(context),
                ghb(6),
                recommendationList(),
              ]),
            ),
          );
        },
      ),
    );
  }

  // banner + 商城快捷入口
  Widget mallTop(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
      width: 375.w,
      child: Column(children: [
        ghb(5),
        gwb(375),
        CustomButton(
          onPressed: () {
            push(const ShoppingProductList(), context,
                binding: ShoppingProductListBinding(),
                arguments: {"isSearch": true});
          },
          child: Container(
            width: 345.w,
            height: 40.w,
            decoration: BoxDecoration(
                color: AppColor.pageBackgroundColor,
                borderRadius: BorderRadius.circular(20.w)),
            child: Row(
              children: [
                gwb(20),
                getWidthText("请输入想要搜索的商品名称", 12, AppColor.assisText,
                    (345 - 20 - 62 - 1 - 0.1), 1),

                // CustomInput(
                //   textEditCtrl: controller.searchInputCtrl,
                //   width: (345 - 20 - 62 - 1 - 0.1).w,
                //   heigth: 40.w,
                //   placeholder: "请输入想要搜索的商品名称",
                //   placeholderStyle:
                //       TextStyle(fontSize: 12.sp, color: AppColor.assisText),
                //   style: TextStyle(fontSize: 12.sp, color: AppColor.text),
                //   onSubmitted: (p0) {
                //     takeBackKeyboard(context);
                //     controller.searchAction();
                //   },
                // ),
                SizedBox(
                  width: 62.w,
                  height: 40.w,
                  child: Center(
                    child: Image.asset(
                      assetsName("machine/icon_search"),
                      width: 18.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        ghb(20.5),
        Column(
          children: [
            AppBanner(
              width: 375,
              height: 150,
              banners: controller.banner,
              borderRadius: 5,
              bannerClick: (data) {
                push(const ShoppingProductList(), context,
                    binding: ShoppingProductListBinding(),
                    arguments: {"isSearch": false});
              },
            ),
          ],
        ),
        ghb(15),
        sbRow(
            List.generate(4, (index) {
              String title = "";
              String img = "business/mall/shortcut_icon_";

              switch (index) {
                case 0:
                  title = "兑换榜单";
                  img += "1";
                  break;
                case 1:
                  title = "联聚定制";
                  img += "2";
                  break;
                case 2:
                  title = "活动特惠";
                  img += "3";
                  break;
                case 3:
                  title = "商城新品";
                  img += "4";
                  break;
                default:
              }

              return CustomButton(
                onPressed: () {
                  switch (index) {
                    case 0:
                      push(
                        const RedemptionListPage(),
                        null,
                        binding: RedemptionListPageBinding(),
                      );
                      break;
                    case 3:
                      push(
                        const ShoppingProductList(),
                        null,
                        binding: ShoppingProductListBinding(),
                      );
                      break;
                    default:
                  }
                },
                child: centClm([
                  Image.asset(
                    assetsName(img),
                    width: 54.w,
                    fit: BoxFit.fitWidth,
                  ),
                  ghb(8),
                  getSimpleText(title, 12, AppColor.text2)
                ]),
              );
            }),
            width: 375 - 25.5 * 2),
        ghb(20),
      ]),
    );
  }

  Widget recommendationList() {
    return SizedBox(
      width: 375.w,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
            child: Center(
              child: sbhRow([
                nSimpleText("精品推荐", 16, isBold: true),
                GestureDetector(
                  onTap: () => push(const ShoppingProductList(), null,
                      binding: ShoppingProductListBinding(),
                      arguments: {"isSearch": false}),
                  child: centRow([
                    nSimpleText("查看更多", 12,
                        color: AppColor.text3, textHeight: 1.2),
                    Image.asset(
                      assetsName("mine/icon_right_arrow"),
                      width: 12.w,
                      fit: BoxFit.fitWidth,
                    )
                  ]),
                )
              ], width: 345, height: 50),
            ),
          ),

          ghb(15),
          productListView(),
          // 产品列表
        ],
      ),
    );
  }

  // 积分列表
  Widget productListView() {
    return SizedBox(
      width: 375.w,
      child: Column(
        children: [
          SizedBox(
            width: 345.w,
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.w,
              children: controller.productList.isEmpty &&
                      controller.isFirstLoading
                  ? kIsWeb
                      ? [
                          SizedBox(
                              width: 345.w - 0.1,
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: GetX<PointsMallPageController>(
                                      builder: (controller) {
                                    return CustomEmptyView(
                                        topSpace: 20,
                                        centerSpace: 10,
                                        bottomSpace: 20,
                                        isLoading: controller.isFirstLoading);
                                  })))
                        ]
                      : List.generate(
                          4,
                          (index) => SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                width: (375 - 15 * 2 - 10).w / 2 - 0.1.w,
                                height: 270.w,
                              )))
                  : List.generate(controller.productList.length, (index) {
                      Map data = controller.productList[index];
                      return CustomButton(
                        onPressed: () {
                          push(const ShoppingProductDetail(), null,
                              binding: ShoppingProductDetailBinding(),
                              arguments: {
                                "data": data,
                              });
                        },
                        child: Container(
                          width: (375 - 15 * 2 - 10).w / 2 - 0.1.w,

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
                                      child: getWidthText(
                                          data['shopName'] ?? "",
                                          14.w,
                                          AppColor.textBlack,
                                          149.w,
                                          2,
                                          textAlign: TextAlign.left,
                                          alignment: Alignment.topLeft),
                                    ),
                                    getSimpleText(
                                      "${priceFormat(data['nowPrice'] ?? 0, savePoint: 0)}积分",
                                      18,
                                      AppColor.themeOrange,
                                      isBold: true,
                                    ),
                                    sbhRow([
                                      getSimpleText(
                                          "已兑${data['shopBuyCount'] ?? 0}个",
                                          12,
                                          AppColor.textGrey5,
                                          textAlign: TextAlign.left),
                                      centRow([
                                        GetBuilder<PointsMallPageController>(
                                          builder: (_) {
                                            return CustomButton(
                                              onPressed: () {
                                                if ((data["isCollect"] ?? 0) ==
                                                    0) {
                                                  controller
                                                      .loadAddCollect(data);
                                                } else {
                                                  controller
                                                      .loadRemoveCollect(data);
                                                }
                                                // data["favoriteStatus"] =
                                                //     !data["favoriteStatus"];
                                                // //
                                                // controller.update();
                                              },
                                              child: SizedBox(
                                                width: 32.w,
                                                height: 28.w,
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Image.asset(
                                                    assetsName((data[
                                                                    "isCollect"] ??
                                                                0) ==
                                                            0
                                                        ? 'business/mall/btn_collect'
                                                        : 'business/mall/btn_iscollect'),
                                                    width: 16.w,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      ])
                                    ], width: 167.5 - 10 * 2, height: 15.w),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
            ),
          ),
          ghb(controller.productList.isEmpty ? 290 : 30),
        ],
      ),
    );
  }
}
