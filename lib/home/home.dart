import 'package:cxhighversion2/component/app_banner.dart';
import 'package:cxhighversion2/component/app_bottom_tips.dart';
// import 'package:cxhighversion2/component/app_lottery_webview.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_deferred.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/component/custom_webview.dart'
    deferred as customwebview;
import 'package:cxhighversion2/entrepreneurship_support/support.dart'
    deferred as support;
import 'package:cxhighversion2/home/businessSchool/business_school_detail.dart'
    deferred as business_school_detail;
import 'package:cxhighversion2/home/component/custom_message.dart';
import 'package:cxhighversion2/home/contactCustomerService/contact_customer_service.dart'
    deferred as contact_customer_service;
import 'package:cxhighversion2/home/integralRepurchase/integral_repurchase.dart'
    deferred as integral_repurchase;
import 'package:cxhighversion2/home/machine_manage.dart'
    deferred as machine_manage;
import 'package:cxhighversion2/home/machinetransfer/machine_transfer.dart'
    deferred as machine_transfer;
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_userlist.dart'
    deferred as machine_transfer_userlist;
import 'package:cxhighversion2/home/merchantAccessNetwork/merchant_access_network.dart'
    deferred as merchant_access_network;
import 'package:cxhighversion2/home/myTeam/my_team.dart' deferred as my_team;
import 'package:cxhighversion2/home/mybusiness/mybusiness.dart'
    deferred as mybusiness;
import 'package:cxhighversion2/home/news/news_detail.dart'
    deferred as news_detail;
import 'package:cxhighversion2/home/news/news_list.dart' deferred as news_list;
import 'package:cxhighversion2/home/store/vip_store.dart' deferred as vip_store;
import 'package:cxhighversion2/home/terminal_binding.dart'
    deferred as terminal_binding;
import 'package:cxhighversion2/machine/machine_pay_page.dart'
    deferred as machine_pay_page;
import 'package:cxhighversion2/machine/machine_register.dart'
    deferred as machine_register;
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication.dart'
    deferred as identity_authentication;
import 'package:cxhighversion2/mine/myWallet/my_wallet.dart'
    deferred as my_wallet;
import 'package:cxhighversion2/pay/share_invite.dart' deferred as share_invite;
import 'package:cxhighversion2/product/product.dart' deferred as product;
import 'package:cxhighversion2/product/product_purchase_list.dart'
    deferred as product_purchase_list;
import 'package:cxhighversion2/product/product_store/product_store_list.dart'
    deferred as product_store_list;
import 'package:cxhighversion2/rank/rank.dart' deferred as rank;
import 'package:cxhighversion2/ranking/ranking_list.dart' deferred as rankList;
import 'package:cxhighversion2/service/http.dart' as ht;
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/userManage/statistics_user_manage.dart'
    deferred as statistics_user_manage;
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/storage_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:cxhighversion2/util/user_default.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:dynamic_icon_flutter/dynamic_icon_flutter.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../business/pointsMall/points_mall_page.dart'
    deferred as points_mall_page;
import 'businessSchool/business_school_list_page.dart'
    deferred as business_school_list_page;

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class HomeController extends FullLifeCycleController {
  // PageController bannerCtrl = PageController();
  //从后台到前台时刷新公共数据
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // refreshPublicHomeData();
        // Map data = await compute(HomeController.backUpRefreshPublicData, false);
        // parsePublicData(data, notify: false);
        break;
      case AppLifecycleState.inactive:
        // DynamicIconFlutter.setIcon(
        //     icon: "vip2", listAvailableIcon: ["vip1", "vip2", "MainActivity"]);
        break;
      default:
    }
  }

  List btnDatas = [];

  // 机具数据切换
  final _machineDataIdx = 0.obs;
  int get machineDataIdx => _machineDataIdx.value;
  set machineDataIdx(v) => _machineDataIdx.value = v;

  bool haveNews = false;

  //是否实名
  bool isAuth = false;
  //是否绑卡
  bool isBindCard = false;
  //是否弹窗
  bool haveAlertShow = false;
  //是否已经存在升级弹窗
  bool updateAlertExist = false;
  //弹出窗口
  showHomeAlert() {
    AppDefault().firstAlertFromLogin = false;
    if (haveAlertShow) {
      return;
    }
    bool haveAlertNews = false;

    if (homeData["authentication"] != null &&
        homeData["authentication"]["isCertified"] != null) {
      isAuth = (homeData["authentication"] ?? {})["isCertified"] ?? false;
    }

    if (homeData["appHomeNews"] != null && homeData["appHomeNews"].isNotEmpty) {
      imagePerLoad(homeData["appHomeNews"][0]["n_Image"] ?? "");
      haveAlertNews = true;
    }
    haveAlertShow = true;
    homeFirst = false;
    if (haveAlertNews) {
      Future.delayed(const Duration(milliseconds: 500), () {
        showNewsAlert(
          context: Global.navigatorKey.currentContext!,
          newData: homeData["appHomeNews"][0],
          barrierDismissible: true,
          close: () {
            haveAlertShow = false;
            if (!isAuth) {
              if (Global.navigatorKey.currentContext != null) {
                showAuthAlert(
                    barrierDismissible: true,
                    context: Global.navigatorKey.currentContext!,
                    isAuth: true);
              }
            }
          },
        );
      });
    } else {
      if (!isAuth) {
        // homeFirst = false;
        Future.delayed(const Duration(milliseconds: 500), () {
          showAuthAlert(
            context: Global.navigatorKey.currentContext!,
            isAuth: true,
            barrierDismissible: true,
            close: () {
              haveAlertShow = false;
            },
          );
        });
      }
    }
  }

  //请求HomeData
  refreshHomeData({Function(bool succ)? succ, bool format = true}) async {
    AppDefault appDefault = AppDefault();
    if (appDefault.deviceId.isEmpty) {
      String? dId = await PlatformDeviceId.getDeviceId;
      appDefault.deviceId = dId ?? "";
    }
    if (appDefault.version.isEmpty) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appDefault.version = packageInfo.version;
      appDefault.appName = packageInfo.appName;
      appDefault.buildNumber = packageInfo.buildNumber;
      appDefault.packageName = packageInfo.packageName;
    }
    simpleRequest(
      url: Urls.homeData,
      params: {
        "phoneKey": appDefault.deviceId,
        "versionNumber": appDefault.version,
        "versionOrigin": appDefault.versionOrigin
      },
      success: (success, json) async {
        Map data = json["data"] ?? {};
        if (success) {
          setUserDataFormat(true, data, {}, {}).then((value) async {
            await getHomeData();
            if (format) {
              dataFormat(isHomeData: true);
            }
            bus.emit(HOME_DATA_UPDATE_NOTIFY);
          });
        }
        if (succ != null) {
          succ(success);
        }
      },
      after: () {
        Future.delayed(const Duration(seconds: 10), () {
          if (succ != null) {
            succ(false);
          }
        });
      },
    );
  }

  //请求PublicHomeData
  refreshPublicHomeData({bool coerce = false}) async {
    if (!coerce && !AppDefault().loginStatus) {
      return;
    }
    simpleRequest(
      url: Urls.publicHomeData,
      params: {},
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          parsePublicData(data);
          // pullCtrl?.refreshCompleted();
        } else {
          // pullCtrl?.refreshFailed();
        }
      },
      after: () {},
    );
  }

  static Future<Map> backUpRefreshPublicData(bool noNotify) async {
    // if (!coerce && !AppDefault().loginStatus) {
    //   return;
    // }
    dio.Response response = await ht.Http().dio.post(
      Urls.publicHomeData,
      data: {},
    );
    if (response.statusCode == 200) {
      Map<dynamic, dynamic> data = response.data;
      if (response.data["success"] ?? false) {
        return data["data"] ?? {};
      }
    }

    return {};
  }

  parsePublicData(Map data, {bool notify = true}) {
    setUserDataFormat(true, {}, data, {}).then((value) {
      getHomeData();
      dataFormat(isHomeData: false);
      if (notify) {
        bus.emit(HOME_PUBLIC_DATA_UPDATE_NOTIFY);
      }
    });
  }

  homeOnRefresh({Function(bool success)? succ}) {
    refreshHomeData(succ: succ);
    refreshPublicHomeData();
  }

  final scrollCtrl = ScrollController();

  Map homeData = {};
  Map publicHomeData = {};
  List myMessages = [];

  final _topBanners = Rx<List<BannerData>>([]);
  List<BannerData> get topBanners => _topBanners.value;
  set topBanners(v) => _topBanners.value = v;

  String imageUrl = "";
  final _centerBtnIndex = 0.obs;
  get centerBtnIndex => _centerBtnIndex.value;
  set centerBtnIndex(value) => _centerBtnIndex.value = value;
  bool homeFirst = true;
  @override
  void onInit() async {
    ambiguate(WidgetsBinding.instance)?.addObserver(this);
    bus.on(NOTIFY_LOGIN_BACK_CHECK_HOME_ALERT, (arg) {
      if (AppDefault().loginStatus) {
        showHomeAlert();
      }
    });
    needUpdate();
    refreshHomeData();
    bus.on(USER_LOGIN_NOTIFY, getUserLoginNotify);
    super.onInit();
  }

  getUserLoginNotify(arg) {
    needUpdate();
  }

  @override
  void onClose() {
    ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    scrollCtrl.dispose();
    bus.off(USER_LOGIN_NOTIFY, getUserLoginNotify);
    super.onClose();
  }

  needUpdate() async {
    await getHomeData();
    dataFormat();
  }

  getHomeData() async {
    homeData = AppDefault().homeData;
    publicHomeData = AppDefault().publicHomeData;
    if (homeData.isEmpty || publicHomeData.isEmpty) {
      await getUserData();
    }
    homeData = AppDefault().homeData;
    publicHomeData = AppDefault().publicHomeData;
    if (homeData.isEmpty) {
      setUserDataFormat(false, {}, {}, {})
          .then((value) => toLogin(isErrorStatus: true, errorCode: 202));
      return;
    } else {
      Map authData = homeData["authentication"] ?? {};
      isAuth = authData["isCertified"] ?? false;
      isBindCard = authData["isBank"] ?? false;
      imageUrl = AppDefault().imageUrl;
      // if (!isAuth) {
      //   if (Global.navigatorKey.currentContext != null) {
      //     showAuthAlert(
      //         context: Global.navigatorKey.currentContext!, isAuth: true);
      //   }
      // }
    }
  }

  final _haveAddModule = false.obs;
  bool get haveAddModule => _haveAddModule.value;
  set haveAddModule(v) => _haveAddModule.value = v;
  List middleIcons = [];

  String subTitle = "";

  dataFormat({bool isHomeData = false}) {
    if (!AppDefault().loginStatus) {
      return;
    }

    haveNews = homeData["news"] != null && homeData["news"].isNotEmpty;
    myMessages = homeData["news"] ?? [];

    if (publicHomeData.isNotEmpty) {
      List tmpBanners = (publicHomeData["appCofig"] ?? {})["topBanner"] ?? [];
      tmpBanners = tmpBanners.where((e) {
        String type = e["u_Type"] ?? "";
        List types = type.split(",");
        if (types.contains("1")) {
          return true;
        } else {
          return false;
        }
      }).toList();

      tmpBanners = topBanners = tmpBanners.map((e) {
        return BannerData(
            imagePath: "$imageUrl${e["apP_Pic"]}",
            id: "${e["id"]}",
            data: e,
            imgWidth: 345,
            imgHeight: 100,
            boxFit: BoxFit.fill);
      }).toList();
      btnDatas = [];
      List tmpMiddle = (publicHomeData["appCofig"] ?? {})["middleIcon"] ?? [];
      middleIcons = [];
      if (AppDefault().checkDay) {
        middleIcons = (publicHomeData["appCofig"] ?? {})["middleIcon"] ?? [];
        //测试
        // middleIcons = [...middleIcons, ...middleIcons];
      } else {
        for (var e in tmpMiddle) {
          if (e["id"] != 2082 && e["id"] != 2083) {
            middleIcons.add(e);
          }
        }
      }

      List tmpBtnDatas = middleIcons.map((e) {
        return Map<String, dynamic>.from({
          "img": "$imageUrl${e["apP_Pic"]}",
          "name": e["apP_Title"] ?? "",
          "id": e["id"],
          "path": e["apP_Url"]
        });
      }).toList();

      int centerBtnIdx = 0;
      for (var i = 0; i < tmpBtnDatas.length; i++) {
        if (i % 8 == 0) {
          if (i != 0) centerBtnIdx++;
          btnDatas.add([]);
        }
        Map e = tmpBtnDatas[i];
        btnDatas[centerBtnIdx].add(Map<String, dynamic>.from({
          "img": e["img"],
          "name": e["name"],
          "id": e["id"],
          "path": e["path"]
        }));
      }
      subTitle =
          ((publicHomeData["webSiteInfo"] ?? {})["app"])["apP_SubTitle"] ?? "";
      subTitle = "欢迎您！";
    }
    if (AppDefault().safeAlert &&
        isHomeData &&
        (AppDefault().firstAlertFromLogin || homeFirst)) {
      showHomeAlert();
    }
    update();
  }

  applyRequest() {
    simpleRequest(
      url: Urls.approveApply,
      params: {},
      success: (success, json) {
        if (success) {
          String messages = json["messages"] ?? "";
          if (messages.isNotEmpty) {
            ShowToast.normal(messages);
          }
        }
      },
      after: () {},
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
  static refreshBackUp(int num) async {
    Get.find<HomeController>().refreshPublicHomeData();
  }
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  HomeController ctrl = Get.find<HomeController>();

  double jgwidth = 345;
  double jgRunSpace = 25;
  double jgBtnGap = 10;
  double jgImageHeight = 33;
  double jgHeight = 0;
  double jgFontSize = 12;
  double jgTagMarginTop = 17;
  double jgTextHeight = 0;

  // final pullCtrl = RefreshController();
  final yjScrollCtrl =
      ScrollController(initialScrollOffset: 500 * 285.w - 15.w);

  @override
  void initState() {
    super.initState();
  }

  // yjScrollListener() {}

  @override
  void dispose() {
    // yjScrollCtrl.removeListener(yjScrollListener);
    yjScrollCtrl.dispose();

    // pullCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
          body: EasyRefresh.builder(
        onRefresh: () => ctrl.homeOnRefresh(),
        childBuilder: (context, physics) {
          return SingleChildScrollView(
            physics: physics,
            child: Column(
              children: [
                centClm([
                  // 轮播图/金刚区
                  GetBuilder<HomeController>(
                      init: ctrl,
                      builder: (_) {
                        AppDefault().scaleWidth = 1.w;
                        return topContent();
                      }),
                  machineDataView(),
                ]),
                ghb(14),
                GetBuilder<HomeController>(
                  builder: (_) {
                    return AppBottomTips(
                      pData: ctrl.publicHomeData,
                    );
                  },
                )
              ],
            ),
          );
        },
      )),
    );
  }

  bannerPress(Map data) async {
    if (data.isNotEmpty &&
        data["apP_Url"] != null &&
        data["apP_Url"].isNotEmpty) {
      String path = data["apP_Url"] ?? "";
      if (path.contains("http")) {
        customwebview.loadLibrary().then((value) => push(
            customwebview.CustomWebView(
              title: data["apP_Title"] ?? "",
              url: path,
            ),
            context));
      } else if (path.contains("/home/integral/rank")) {
        // new排行榜
        await rankList.loadLibrary();
        push(rankList.RankListPage(), null,
            binding: rankList.RankListBinding());
      } else {
        if (path.contains("news")) {
          toBannerDetail(0, path);
        } else if (path.contains("businessschool")) {
          toBannerDetail(1, path);
        }
      }
    }
  }

  toBannerDetail(int type, String path) {
    int id = -1;
    List subs = path.split("?");
    path = subs.length > 1 ? subs[1] : "";
    if (path.isEmpty) {
      return;
    }
    List params = path.split("&");
    for (String e in params) {
      List l = e.split("=");
      if (l.isNotEmpty && l.length > 1 && l[0] == "id") {
        id = int.tryParse(l[1]) != null ? int.parse(l[1]) : -1;
        break;
      }
    }
    if (type == 0) {
      news_detail.loadLibrary().then((value) => push(
          news_detail.NewsDetail(
            newsData: {"id": id},
          ),
          context));
    } else if (type == 1) {
      business_school_detail.loadLibrary().then((value) => Get.to(
          business_school_detail.BusinessSchoolDetail(id: id),
          binding: business_school_detail.BusinessSchoolDetailBinding()));
    }
  }

  Widget topContent() {
    jgTextHeight = calculateTextHeight(
        "设备管理", jgFontSize, FontWeight.normal, double.infinity, 1, context);
    // jgHeight = (jgTextHeight + jgBtnGap.w + jgImageHeight.w) * 2 +
    //     jgRunSpace.w;
    double bottomPadding = 18;
    double height = (jgTextHeight + jgBtnGap.w + jgImageHeight.w) * 2 +
        jgRunSpace.w +
        (kIsWeb ? 12.w : 0);
    double tagHeight = ctrl.btnDatas.length > 1
        ? (jgTagMarginTop.w + 3.w + 12.w)
        : bottomPadding.w;
    Map tanNo = ctrl.homeData["homeTeamTanNo"] ?? {};

    return SizedBox(
        width: 375.w,
        // height: 375.w,
        // height: (218).w + height + tagHeight,
        child: Column(
          children: [
            Container(
              width: 375.w,
              height: 330.w,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(assetsName("home/bg_top")))),
              child: Column(
                children: [
                  SizedBox(
                    height: 210.w,
                    child: Column(
                      children: [
                        ghb(80),
                        sbRow([
                          getSimpleText("今日团队总交易额", 12, Colors.white),
                        ], width: 375 - 30 * 2),
                        ghb(5),
                        sbRow([
                          getSimpleText(
                              priceFormat(tanNo["soleThisMAmount"] ?? 0),
                              40,
                              Colors.white,
                              isBold: true),
                        ], width: 375 - 30 * 2),
                        ghb(20),
                        sbRow([
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: "本月团队总交易额",
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.white)),
                            WidgetSpan(child: gwb(13)),
                            TextSpan(
                                text:
                                    priceFormat(tanNo["soleThisMAmount"] ?? 0),
                                style: TextStyle(
                                    fontSize: 16.sp, color: Colors.white))
                          ]))
                        ], width: 375 - 30 * 2)
                      ],
                    ),
                  ),
                  Container(
                    width: 345.w,
                    height: 105.w,
                    alignment: Alignment.center,
                    decoration: getDefaultWhiteDec(radius: 8.w),
                    child: sbhRow(
                        List.generate(
                            4,
                            (index) => CustomButton(
                                  onPressed: () async {
                                    if (index == 0) {
                                      await share_invite.loadLibrary();
                                      push(share_invite.ShareInvite(), null,
                                          binding: share_invite
                                              .ShareInviteBinding());
                                    } else if (index == 1) {
                                    } else if (index == 2) {
                                      await machine_transfer.loadLibrary();
                                      push(
                                          machine_transfer.MachineTransfer(
                                              isLock: false),
                                          null,
                                          binding: machine_transfer
                                              .MachineTransferBinding());
                                    } else if (index == 3) {
                                      await product_store_list.loadLibrary();
                                      push(
                                          product_store_list.ProductStoreList(),
                                          null,
                                          binding: product_store_list
                                              .ProductStoreListBinding(),
                                          arguments: {
                                            "levelType": 2,
                                            "title": "采购商城"
                                          });
                                    }
                                  },
                                  child: SizedBox(
                                    width: 345.w / 4,
                                    child: centClm([
                                      Image.asset(
                                        assetsName(
                                            "home/icon_${index == 0 ? "fxyq" : index == 1 ? "shzc" : index == 2 ? "zdhb" : "cgsc"}"),
                                        width: 45.w,
                                        height: 45.w,
                                        fit: BoxFit.fill,
                                      ),
                                      ghb(3),
                                      getSimpleText(
                                          index == 0
                                              ? "分享邀请"
                                              : index == 1
                                                  ? "商户注册"
                                                  : index == 2
                                                      ? "终端划拨"
                                                      : "采购商城",
                                          12,
                                          AppColor.textBlack),
                                    ]),
                                  ),
                                )),
                        width: 345,
                        height: 105),
                  )
                ],
              ),
            ),
            AppBanner(
              // controller: ctrl.bannerCtrl,
              // isFullScreen: false,
              width: 375,
              height: 100,
              banners: ctrl.topBanners,
              borderRadius: 8,
              bannerClick: (data) {
                bannerPress(data);
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 15.w),
              decoration: getDefaultWhiteDec(radius: 8),
              child: Column(
                children: [
                  sbhRow([
                    getSimpleText("精选服务", 16, AppColor.textBlack,
                        isBold: true, textHeight: 1.3)
                  ], width: 345 - 15 * 2, height: 50),
                  ghb(6),
                  SizedBox(
                      width: jgwidth.w,
                      height: height,
                      child: PageView.builder(
                        physics:
                            ctrl.btnDatas == null || ctrl.btnDatas.length == 1
                                ? const NeverScrollableScrollPhysics()
                                : const BouncingScrollPhysics(),
                        itemCount:
                            ctrl.btnDatas != null && ctrl.btnDatas.isNotEmpty
                                ? ctrl.btnDatas.length
                                : 0,
                        itemBuilder: (context, index) {
                          return Center(
                            child: SizedBox(
                              width: jgwidth.w,
                              height: height,
                              child: Wrap(
                                  runSpacing: jgRunSpace.w,
                                  children: homeButtons(
                                      ctrl.btnDatas[index], context)),
                            ),
                          );
                        },
                        onPageChanged: (value) {
                          ctrl.centerBtnIndex = value;
                        },
                      )),
                  //金刚区滑动标记
                  Visibility(
                    visible: ctrl.btnDatas.length > 1,
                    child: Padding(
                        padding: EdgeInsets.only(top: jgTagMarginTop.w),
                        child: GetX<HomeController>(
                          builder: (_) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(1.5.w),
                              child: centRow([
                                ...ctrl.btnDatas
                                    .asMap()
                                    .entries
                                    .map((e) => Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 0.w),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                ctrl.centerBtnIndex == e.key
                                                    ? 1.5.w
                                                    : 0),
                                            color: ctrl.centerBtnIndex == e.key
                                                ? AppDefault()
                                                        .getThemeColor() ??
                                                    AppColor.theme
                                                : AppDefault()
                                                            .getThemeColor() ==
                                                        null
                                                    ? const Color(0xFFA9DAFC)
                                                    : AppDefault()
                                                        .getThemeColor()!
                                                        .withOpacity(0.3),
                                          ),
                                          width: ctrl.centerBtnIndex == e.key
                                              ? 11.w
                                              : 5.w,
                                          height: 3.w,
                                        ))
                                    .toList()
                              ]),
                            );
                          },
                        )),
                  ),
                  ghb(ctrl.btnDatas.length > 1 ? 15 : bottomPadding),
                ],
              ),
            )
          ],
        ));
  }

  Widget messageView() {
    return Column(
      children: [
        ghb(ctrl.haveNews ? 10 : 0),
        //消息中心
        !ctrl.haveNews
            ? ghb(0)
            : GestureDetector(
                onTap: () {
                  news_list.loadLibrary().then((value) => push(
                      news_list.NewsList(), context,
                      binding: news_list.NewsListBinding()));
                },
                child: Container(
                  height: 40.w,
                  width: 345.w,
                  decoration: BoxDecoration(
                      color: AppColor.pageBackgroundColor,
                      borderRadius: BorderRadius.circular(8.w)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 13.5.w),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/home/icon_notifi.png",
                          width: 28.w,
                          fit: BoxFit.fitWidth,
                        ),
                        gwb(10),
                        gline(1, 12, color: AppColor.assisText),
                        gwb(7),
                        Image.asset(
                          assetsName("home/icon_message"),
                          width: 24.w,
                          fit: BoxFit.fitWidth,
                        ),
                        gwb(3.5),
                        GetBuilder<HomeController>(
                          init: ctrl,
                          builder: (_) {
                            return CustomMessage(
                              datas: ctrl.myMessages,
                              width: 243.3.w,
                              height: 50.w,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget cellTitle(String title,
      {List<Widget> right = const [], Function()? rightOnPressed}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.w),
      child: sbRow([
        centRow([
          Image.asset(
            assetsName("home/cell_tag"),
            width: 6.w,
            fit: BoxFit.fitWidth,
          ),
          gwb(9),
          getSimpleText(title, 16, AppColor.text, isBold: true),
        ]),
        CustomButton(onPressed: rightOnPressed, child: centRow(right))
      ], width: 345),
    );
  }

  Widget dataView(String t1, String t2, {int type = 1}) {
    return centClm([
      getSimpleText(t1, type == 0 ? 30 : 12, Colors.white,
          fw: type == 0 ? FontWeight.w500 : FontWeight.w400),
      ghb(type == 0 ? 6 : 5),
      getSimpleText(t2, type == 0 ? 18 : 12, Colors.white,
          fw: type == 0 ? FontWeight.w400 : FontWeight.w500),
    ]);
  }

  List<Widget> homeButtons(List data, BuildContext context) {
    List<Widget> buttons = [];

    for (var e in data) {
      buttons.add(CustomButton(
        onPressed: () async {
          String path = e["path"] ?? "";
          if (e["path"] == "/home/machinemanage") {
            // 设备管理
            await machine_manage.loadLibrary();
            push(machine_manage.MachineManage(), null,
                binding: machine_manage.MachineManageBinding());
          } else if (path.contains("/home/rank")) {
            // 排行榜
            await rank.loadLibrary();
            push(rank.Rank(), null, binding: rank.RankBinding());
          } else if (path.contains("/home/entrepreneurial/support")) {
            // 创业支持
            CustomDeferred().toSupportPage();
          } else if (e['id'] == 2079) {
            // 分享注册
            await share_invite.loadLibrary();
            push(share_invite.ShareInvite(), null,
                binding: share_invite.ShareInviteBinding());
          } else if (e["path"] == "/home/productpurchase") {
            // 礼包商城
            await product_purchase_list.loadLibrary();
            push(product_purchase_list.ProductPurchaseList(), null,
                binding: product_purchase_list.ProductPurchaseListBinding());
          } else if (e["path"] == "/home/teammanage") {
            // 团队管理
            await my_team.loadLibrary();
            push(my_team.MyTeam(), null, binding: my_team.MyTeamBinding());
          } else if (path == "/pages/authentication") {
            // 实名认证
            CustomDeferred().toIdentityAuthentication();
          } else if (e["path"] == "/home/businessinfo") {
            // 商户信息
            await mybusiness.loadLibrary();
            push(mybusiness.MyBusiness(), null,
                binding: mybusiness.MyBusinessBinding());
          } else if (e["path"] == "/home/integralstore") {
            // 积分商城
            CustomDeferred().toIntegralStore();
          } else if (e["path"] == "/home/machinetransfer") {
            // 机具划拨
            await machine_transfer.loadLibrary();
            push(machine_transfer.MachineTransfer(isLock: false), null,
                binding: machine_transfer.MachineTransferBinding());
          } else if (e['path'] == "/home/machinetransferback") {
            // 机具回拨
            await machine_transfer_userlist.loadLibrary();
            push(
                machine_transfer_userlist.MachineTransferUserList(
                    isTerminalBack: true),
                null,
                binding:
                    machine_transfer_userlist.MachineTransferUserListBinding());
          } else if (e["path"] == "/home/shareinvite") {
            await share_invite.loadLibrary();
            push(share_invite.ShareInvite(), null,
                binding: share_invite.ShareInviteBinding());
          } else if (e["path"] == "/home/vipstore") {
            pushStore(e);
          } else if (e["path"] == "/home/businessschool") {
            // 商学院
            await business_school_list_page.loadLibrary();
            push(business_school_list_page.BusinessSchoolListPage(), null,
                binding:
                    business_school_list_page.BusinessSchoolListPageBinding(),
                arguments: {"index": 0});
          } else if (path == "/home/usermanage") {
            // 用户管理
            await statistics_user_manage.loadLibrary();
            push(statistics_user_manage.StatisticsUserManage(), null,
                binding: statistics_user_manage.StatisticsUserManageBinding());
          } else if (path == "/home/contactcustomerservice") {
            // 联系客服
            await contact_customer_service.loadLibrary();
            push(contact_customer_service.ContactCustomerService(), null,
                binding:
                    contact_customer_service.ContactCustomerServiceBinding());
          } else if (path == "/home/integralrepurchase") {
            await integral_repurchase.loadLibrary();
            // 积分复购
            push(integral_repurchase.IntegralRepurchase(), null,
                binding: integral_repurchase.IntegralRepurchaseBinding());
          } else if (path == "/home/machineregister") {
            //设备注册
            await machine_register.loadLibrary();
            push(machine_register.MachineRegister(), null,
                binding: machine_register.MachineRegisterBinding());
          } else if (path == "/home/mywallet") {
            // 我的钱包
            await my_wallet.loadLibrary();
            push(my_wallet.MyWallet(), null,
                binding: my_wallet.MyWalletBinding());
          } else if (path == "/home/machinestore") {
            await machine_pay_page.loadLibrary();
            push(machine_pay_page.MachinePayPage(), null,
                binding: machine_pay_page.MachinePayPageBinding());
          } else if (e["path"] == "/home/merchantaccessnetwork") {
            await merchant_access_network.loadLibrary();
            push(merchant_access_network.MerchantAccessNetwork(), null,
                binding:
                    merchant_access_network.MerchantAccessNetworkBinding());
          } else if (e["path"] == "/pages/booked/booked") {
          } else if (e["path"] == "/home/terminalreceive") {
            // push(const TerminalReceive(), context,
            //     binding: TerminalReceiveBinding());
            await product.loadLibrary();

            push(product.Product(subPage: true), null,
                binding: product.ProductBinding());
          } else if (e["path"] == "/home/terminalbinding") {
            terminal_binding.loadLibrary().then(
                (value) => push(terminal_binding.TerminalBinding(), context));
          } else if (path.contains("/pages/store")) {
            await product_store_list.loadLibrary();
            int type = 1;
            List subs = path.split("?");
            path = subs.length > 1 ? subs[1] : "";
            if (path.isNotEmpty) {
              List params = path.split("&");
              for (String e in params) {
                List l = e.split("=");
                if (l.isNotEmpty && l.length > 1 && l[0] == "type") {
                  type = int.tryParse(l[1]) != null ? int.parse(l[1]) : 1;
                  break;
                }
              }
            }
            push(product_store_list.ProductStoreList(), null,
                binding: product_store_list.ProductStoreListBinding(),
                arguments: {"levelType": type, "title": e["name"] ?? ""});
          } else if (path == "/pages/extensionreward") {
            /// 拓新奖励
            CustomDeferred().toExtensionRewardPage();
          } else if (path == "/pages/promotionskills") {
            /// 推广技巧
            CustomDeferred().toPromotionSkills();
          } else if (path == "/pages/contactservice") {
            /// 在线客服
            CustomDeferred().toContactCustomerService();
          } else if (path == "/home/equitiesadd") {
            // 权益添加
            CustomDeferred().toStatisticsMachineEquitiesAdd();
          } else if (path == "/home/equitiesmachine") {
            // 权益设备
            CustomDeferred().toStatisticsMachineEquities();
          }
        },
        child: SizedBox(
          width: jgwidth.w / 4 - 0.1.w,
          child: centClm(
            [
              CustomNetworkImage(
                key: ValueKey(e),
                src: e["img"],
                height: jgImageHeight.w,
                // height: jgImageHeight.w,
                fit: BoxFit.fitHeight,
                errorWidget: gemp(),
              ),
              ghb(jgBtnGap),
              getSimpleText(e["name"], jgFontSize, AppColor.textBlack)
            ],
          ),
        ),
      ));
    }
    return buttons;
  }

  Widget machineDataView() {
    return GetBuilder<HomeController>(
      builder: (_) {
        Map tNo = ctrl.homeData["homeTeamTanNo"] ?? {};
        return Container(
          width: 345.w,
          margin: EdgeInsets.only(top: 15.w),
          decoration: getDefaultWhiteDec(radius: 8),
          child: GetX<HomeController>(builder: (_) {
            return Column(
              children: [
                ghb(12),
                sbRow([
                  centRow([
                    Image.asset(
                      assetsName("home/icon_data"),
                      width: 18.w,
                      fit: BoxFit.fitWidth,
                    ),
                    gwb(6),
                    getSimpleText(ctrl.machineDataIdx == 0 ? "机具数据" : "商户数据",
                        16, AppColor.textBlack,
                        isBold: true),
                  ]),
                  DropdownButtonHideUnderline(
                      child: DropdownButton2(
                          dropdownElevation: 0,
                          buttonElevation: 0,
                          offset: Offset(11.w, -5.w),
                          customButton: Container(
                            width: 105.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: AppColor.pageBackgroundColor,
                              borderRadius: BorderRadius.circular(12.w),
                            ),
                            alignment: Alignment.center,
                            child: sbhRow([
                              getSimpleText(
                                  ctrl.machineDataIdx == 0 ? "押金/激活" : "达标/返现",
                                  12,
                                  AppColor.textBlack),
                              Image.asset(
                                assetsName("home/icon_arrow_down"),
                                width: 6.w,
                                height: 4.w,
                                fit: BoxFit.fill,
                              ),
                            ], width: 105 - 15 * 2, height: 24),
                          ),
                          items: List.generate(
                              2,
                              (index) => DropdownMenuItem<int>(
                                  value: index,
                                  child: centClm([
                                    SizedBox(
                                      height: 30.w,
                                      child: Align(
                                        alignment: const Alignment(-0.3, 0),
                                        child: getSimpleText(
                                            index == 0 ? "押金/激活" : "达标/返现",
                                            12,
                                            ctrl.machineDataIdx == index
                                                ? AppColor.textRed
                                                : AppColor.textBlack),
                                      ),
                                    ),
                                  ]))),
                          value: ctrl.machineDataIdx,
                          // buttonWidth: 70.w,
                          buttonHeight: 60.w,
                          itemHeight: 30.w,
                          onChanged: (value) {
                            ctrl.machineDataIdx = value;
                          },
                          itemPadding: EdgeInsets.zero,
                          dropdownPadding: EdgeInsets.zero,
                          dropdownWidth: 90.w,
                          dropdownDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.w),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0x1A040000),
                                    // offset: Offset(0, 5.w),
                                    blurRadius: 5.w)
                              ]))),
                ], width: 315),
                ghb(25),
                Padding(
                  padding: EdgeInsets.only(left: (26 - 15).w / 2),
                  child: sbRow(
                      List.generate(
                          3,
                          (index) => centClm([
                                getSimpleText(
                                    index == 0
                                        ? ctrl.machineDataIdx == 0

                                            /// 累计总激活
                                            ? tNo["teamTotalActTerminal"] ?? "0"

                                            /// 累计总达标
                                            : tNo["teamTotalActivTerminal"] ??
                                                "0"
                                        : index == 1
                                            ? ctrl.machineDataIdx == 0

                                                /// 团队当月激活
                                                ? tNo["teamThisMActTerminal"] ??
                                                    "0"

                                                /// 团队当月达标
                                                : tNo["teamThisMActivTerminal"] ??
                                                    "0"
                                            : ctrl.machineDataIdx == 0

                                                /// 团队当日激活
                                                ? tNo["teamThisDActTerminal"] ??
                                                    "0"
                                                ////团队当日达标
                                                : tNo["teamThisDActivTerminal"] ??
                                                    "0",
                                    18,
                                    AppColor.textBlack,
                                    isBold: true,
                                    textHeight: 1.0),
                                ghb(13),
                                getSimpleText(
                                  index == 0
                                      ? ctrl.machineDataIdx == 0
                                          ? "累计总激活"
                                          : "累计总达标"
                                      : index == 1
                                          ? ctrl.machineDataIdx == 0
                                              ? "团队当月激活"
                                              : "团队当月达标"
                                          : ctrl.machineDataIdx == 0
                                              ? "团队当日激活"
                                              : "团队当日达标",
                                  12,
                                  AppColor.textBlack,
                                ),
                              ])),
                      width: 345 - 15 - 26),
                ),
                ghb(25),
              ],
            );
          }),
        );
      },
    );
  }

  pushStore(Map e) async {
    String token = await UserDefault.get(USER_TOKEN);
    String? dId = await PlatformDeviceId.getDeviceId;
    Map appData = {
      "homeData": AppDefault().homeData,
      "publicHomeData": AppDefault().publicHomeData,
      "token": token,
      "version": AppDefault().version,
      "deviceId": dId ?? "",
      "imageUrl": AppDefault().imageUrl,
      "baseUrl": HttpConfig.baseUrl,
    };

    if (mounted) {
      vip_store.loadLibrary().then((value) => push(
          vip_store.VipStore(
            title: e["name"] ?? "VIP礼包",
            appData: appData,
          ),
          context));
    }
  }

  @override
  bool get wantKeepAlive => true;
}
