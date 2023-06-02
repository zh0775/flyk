import 'dart:async';

import 'package:cxhighversion2/business/pointsMall/points_mall_page.dart'
    deferred as points_mall_page;
import 'package:cxhighversion2/business/pointsMall/shopping_product_detail.dart'
    deferred as shopping_product_detail;
import 'package:cxhighversion2/business/pointsMall/shopping_product_list.dart'
    deferred as shopping_product_list;
import 'package:cxhighversion2/component/custom_webview.dart'
    deferred as customwebview;
import 'package:cxhighversion2/entrepreneurship_support/support.dart'
    deferred as support;
import 'package:cxhighversion2/extension_reward/extension_reward.dart'
    deferred as extension_reward;
import 'package:cxhighversion2/home/businessSchool/business_school_detail.dart'
    deferred as business_school_detail;
import 'package:cxhighversion2/home/businessSchool/business_school_list_page.dart'
    deferred as business_school_list_page;
import 'package:cxhighversion2/home/businessSchool/promotion_skills.dart'
    deferred as promotion_skills;
import 'package:cxhighversion2/home/contactCustomerService/contact_customer_service.dart'
    deferred as contact_customer_service;
import 'package:cxhighversion2/home/fodderlib/fodder_lib.dart'
    deferred as fodder_lib;
import 'package:cxhighversion2/home/integralRepurchase/integral_repurchase.dart'
    deferred as integral_repurchase;
import 'package:cxhighversion2/home/machine_manage.dart'
    deferred as machine_manage;
import 'package:cxhighversion2/home/machinetransfer/machine_transfer.dart'
    deferred as machine_transfer;
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_userlist.dart'
    deferred as machine_transfer_userlist;
import 'package:cxhighversion2/home/myTeam/my_team.dart' deferred as my_team;
import 'package:cxhighversion2/home/mybusiness/mybusiness.dart'
    deferred as mybusiness;
import 'package:cxhighversion2/home/news/news_detail.dart'
    deferred as news_detail;
import 'package:cxhighversion2/home/news/news_list.dart' deferred as news_list;
import 'package:cxhighversion2/integralstore/integral_store.dart'
    deferred as integral_store;
// import 'package:cxhighversion2/home/store/vip_store.dart' deferred as vip_store;
import 'package:cxhighversion2/machine/machine_pay_page.dart'
    deferred as machine_pay_page;
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_check.dart'
    deferred as identity_authentication_check;
import 'package:cxhighversion2/mine/mine_help_center.dart'
    deferred as mine_help_center;
import 'package:cxhighversion2/mine/myWallet/my_wallet.dart'
    deferred as my_wallet;
import 'package:cxhighversion2/pay/share_invite.dart' deferred as share_invite;
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities.dart'
    deferred as statistics_machine_equities;
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities_add.dart'
    deferred as statistics_machine_equities_add;
import 'package:cxhighversion2/statistics/statistics_page/statistics_facilitator_list.dart'
    deferred as statistics_facilitator_list;
// import 'package:cxhighversion2/product/product.dart' deferred as product;
// import 'package:cxhighversion2/product/product_purchase_list.dart'
//     deferred as product_purchase_list;
import 'package:cxhighversion2/statistics/userManage/statistics_user_manage.dart'
    deferred as statistics_user_manage;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cxhighversion2/statistics/statistics_page/statistics_business_list.dart'
    deferred as statistics_business_list;

class CustomDeferred {
  static CustomDeferred? _instance;
  factory CustomDeferred() => _instance ?? CustomDeferred.init();
  CustomDeferred.init() {
    _instance = this;
  }

  /// WebView
  toCustomWebView({dynamic arg}) async {
    var completer = Completer();
    customwebview.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(customwebview.CustomWebView(
        title: (arg ?? {})["apP_Title"] ?? "",
        url: (arg ?? {})["path"] ?? "",
      ));
    } else {
      toCustomWebView(arg: arg);
    }
  }

  /// 特惠商城
  toPointsMallPage({dynamic arg}) async {
    var completer = Completer();
    points_mall_page.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(points_mall_page.PointsMallPage(),
          binding: points_mall_page.PointsMallPageBinding(),
          arguments: {"onlyCash": (arg ?? {})["onlyCash"] ?? false});
    } else {
      toPointsMallPage(arg: arg);
    }
  }

  /// 商学院详情
  toBusinessSchoolDetail({dynamic arg}) async {
    var completer = Completer();
    business_school_detail.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(
          business_school_detail.BusinessSchoolDetail(
              id: (arg ?? {})["id"] ?? 0),
          binding: business_school_detail.BusinessSchoolDetailBinding());
    } else {
      toBusinessSchoolDetail(arg: arg);
    }
  }

  /// 拓新奖励/推广奖励
  toExtensionRewardPage({dynamic arg}) async {
    var completer = Completer();
    extension_reward.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(extension_reward.ExtensionRewardPage(),
          binding: extension_reward.ExtensionRewardBinding());
    } else {
      toExtensionRewardPage(arg: arg);
    }
  }

  /// 推广奖励
  toPromotionSkills({dynamic arg}) async {
    var completer = Completer();
    promotion_skills.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(promotion_skills.PromotionSkills(),
          binding: promotion_skills.PromotionSkillsBinding());
    } else {
      toPromotionSkills(arg: arg);
    }
  }

  /// 商学院
  toBusinessSchoolListPage({dynamic arg}) async {
    var completer = Completer();
    business_school_list_page.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(business_school_list_page.BusinessSchoolListPage(),
          binding: business_school_list_page.BusinessSchoolListPageBinding(),
          arguments: {"index": (arg ?? {})["index"] ?? 0});
    } else {
      toBusinessSchoolListPage(arg: arg);
    }
  }

  /// 联系客服
  toContactCustomerService({dynamic arg}) async {
    var completer = Completer();
    contact_customer_service.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(contact_customer_service.ContactCustomerService(),
          binding: contact_customer_service.ContactCustomerServiceBinding());
    } else {
      toContactCustomerService(arg: arg);
    }
  }

  ///素材库
  toFodderLib({dynamic arg}) async {
    var completer = Completer();
    fodder_lib.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(
          fodder_lib.FodderLib(
            key: const ValueKey("Home"),
          ),
          binding: fodder_lib.FodderLibBinding());
    } else {
      toFodderLib(arg: arg);
    }
  }

  // 云券复购/云券兑现
  toIntegralRepurchase({dynamic arg}) async {
    var completer = Completer();
    integral_repurchase.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(integral_repurchase.IntegralRepurchase(),
          binding: integral_repurchase.IntegralRepurchaseBinding(),
          arguments: {"isRepurchase": (arg ?? {})["isRepurchase"] ?? true});
    } else {
      toIntegralRepurchase(arg: arg);
    }
  }

  /// 设备管理
  toMachineManage({dynamic arg}) async {
    var completer = Completer();
    machine_manage.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(machine_manage.MachineManage(),
          binding: machine_manage.MachineManageBinding());
    } else {
      toMachineManage(arg: arg);
    }
  }

  /// 机具划拨
  toMachineTransfer({dynamic arg}) async {
    var completer = Completer();
    machine_transfer.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(machine_transfer.MachineTransfer(),
          binding: machine_transfer.MachineTransferBinding());
    } else {
      toMachineTransfer(arg: arg);
    }
  }

  /// 机具回拨
  toMachineTransferUserList({dynamic arg}) async {
    var completer = Completer();
    machine_transfer_userlist.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(
          machine_transfer_userlist.MachineTransferUserList(
            isTerminalBack: (arg ?? {})["isTerminalBack"],
          ),
          binding: machine_transfer_userlist.MachineTransferUserListBinding());
    } else {
      toMachineTransferUserList(arg: arg);
    }
  }

  /// 团队管理
  toMyTeam({dynamic arg}) async {
    var completer = Completer();
    my_team.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(my_team.MyTeam(), binding: my_team.MyTeamBinding());
    } else {
      toMyTeam(arg: arg);
    }
  }

  /// 分享注册
  toShareInvite({dynamic arg}) async {
    var completer = Completer();
    share_invite.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(share_invite.ShareInvite(),
          binding: share_invite.ShareInviteBinding());
    } else {
      toShareInvite(arg: arg);
    }
  }

  /// 商户信息
  toMyBusiness({dynamic arg}) async {
    var completer = Completer();
    mybusiness.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(mybusiness.MyBusiness(), binding: mybusiness.MyBusinessBinding());
    } else {
      toMyBusiness(arg: arg);
    }
  }

  /// 礼包商城
  toProductPurchaseList({dynamic arg}) async {
    // var completer = Completer();
    // product_purchase_list.loadLibrary().then((_) {
    //   completer.complete(true);
    // }).catchError((e) {
    //   completer.complete(false);
    // });
    // var loaded = await completer.future;
    // if (loaded) {
    //   Get.to(product_purchase_list.ProductPurchaseList(),
    //       binding: product_purchase_list.ProductPurchaseListBinding());
    // } else {
    //   toProductPurchaseList(arg: arg);
    // }
  }

  /// 实名认证
  toIdentityAuthentication({dynamic arg}) async {
    // identity_authentication_check.IdentityAuthenticationCheck();
    var completer = Completer();
    identity_authentication_check.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(identity_authentication_check.IdentityAuthenticationCheck(),
          binding: identity_authentication_check
              .IdentityAuthenticationCheckBinding());
    } else {
      toIdentityAuthentication(arg: arg);
    }
  }

  /// 新闻详情
  toNewsDetail({dynamic arg}) async {
    var completer = Completer();
    news_detail.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(news_detail.NewsDetail(
        newsData: {"id": (arg ?? {})["id"]},
      ));
    } else {
      toNewsDetail(arg: arg);
    }
  }

  /// 公告列表
  toNewsList({dynamic arg}) async {
    var completer = Completer();
    news_list.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(news_list.NewsList(), binding: news_list.NewsListBinding());
    } else {
      toNewsList(arg: arg);
    }
  }

  /// 设备采购
  toMachinePayPage({dynamic arg}) async {
    var completer = Completer();
    machine_pay_page.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(machine_pay_page.MachinePayPage(),
          binding: machine_pay_page.MachinePayPageBinding());
    } else {
      toMachinePayPage(arg: arg);
    }
  }

  /// 用户管理
  toStatisticsUserManage({dynamic arg}) async {
    var completer = Completer();
    statistics_user_manage.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(statistics_user_manage.StatisticsUserManage(),
          binding: statistics_user_manage.StatisticsUserManageBinding());
    } else {
      toStatisticsUserManage(arg: arg);
    }
  }

  // 云商商城
  toShoppingProductList({dynamic arg}) async {
    var completer = Completer();
    shopping_product_list.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var completer2 = Completer();
    points_mall_page.loadLibrary().then((_) {
      completer2.complete(true);
    }).catchError((e) {
      completer2.complete(false);
    });
    List loadeds = await Future.wait([completer.future, completer2.future]);
    bool loaded = true;
    for (var e in loadeds) {
      if (!e) {
        loaded = e;
        break;
      }
    }
    if (loaded) {
      Get.to(points_mall_page.PointsMallPage(),
          binding: points_mall_page.PointsMallPageBinding(), arguments: arg);
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.to(shopping_product_list.ShoppingProductList(),
            binding: shopping_product_list.ShoppingProductListBinding(),
            arguments: arg);
      });
    } else {
      toShoppingProductList(arg: arg);
    }
  }

  // 云商商城详情
  toShoppingProductDetail({dynamic arg}) async {
    var completer = Completer();
    var completer2 = Completer();
    shopping_product_detail.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    points_mall_page.loadLibrary().then((_) {
      completer2.complete(true);
    }).catchError((e) {
      completer2.complete(false);
    });

    List loadeds = await Future.wait([completer.future, completer2.future]);
    bool loaded = true;
    for (var e in loadeds) {
      if (!e) {
        loaded = e;
        break;
      }
    }
    if (loaded) {
      Get.to(points_mall_page.PointsMallPage(),
          binding: points_mall_page.PointsMallPageBinding(), arguments: arg);
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.to(shopping_product_detail.ShoppingProductDetail(),
            binding: shopping_product_detail.ShoppingProductDetailBinding(),
            arguments: arg);
      });
    } else {
      toShoppingProductDetail(arg: arg);
    }
  }

  /// 我的钱包
  toMyWallet({dynamic arg}) async {
    var completer = Completer();
    my_wallet.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(my_wallet.MyWallet(), binding: my_wallet.MyWalletBinding());
    } else {
      toMyWallet(arg: arg);
    }
  }

  /// 帮助中心
  toMineHelpCenter({dynamic arg}) async {
    var completer = Completer();
    mine_help_center.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(mine_help_center.MineHelpCenter(),
          binding: mine_help_center.MineHelpCenterBinding(),
          arguments: {"index": (arg ?? {})["index"] ?? 0});
    } else {
      toMineHelpCenter(arg: arg);
    }
  }

  /// 权益添加
  toStatisticsMachineEquitiesAdd({dynamic arg}) async {
    var completer = Completer();
    statistics_machine_equities_add.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(statistics_machine_equities_add.StatisticsMachineEquitiesAdd(),
          binding: statistics_machine_equities_add
              .StatisticsMachineEquitiesAddBinding());
    } else {
      toStatisticsMachineEquitiesAdd(arg: arg);
    }
  }

  /// 权益设备
  toStatisticsMachineEquities({dynamic arg}) async {
    var completer = Completer();
    statistics_machine_equities.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(statistics_machine_equities.StatisticsMachineEquities(),
          binding:
              statistics_machine_equities.StatisticsMachineEquitiesBinding());
    } else {
      toStatisticsMachineEquities(arg: arg);
    }
  }

  /// 创业支持
  toSupportPage({dynamic arg}) async {
    var completer = Completer();
    support.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(support.SupportPage(), binding: support.SupportBinding());
    } else {
      toSupportPage(arg: arg);
    }
  }

  /// 积分商城
  toIntegralStore({dynamic arg}) async {
    var completer = Completer();
    integral_store.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(integral_store.IntegralStore(),
          binding: integral_store.IntegralStoreBinding());
    } else {
      toIntegralStore(arg: arg);
    }
  }

  /// 商户列表
  toStatisticsBusinessList({dynamic arg}) async {
    var completer = Completer();
    statistics_business_list.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(
          statistics_business_list.StatisticsBusinessList(
            isPage: (arg ?? {})["isPage"] ?? false,
          ),
          binding: statistics_business_list.StatisticsBusinessListBinding());
    } else {
      toStatisticsBusinessList(arg: arg);
    }
  }

  // 服务商列表
  toStatisticsFacilitatorList({dynamic arg}) async {
    var completer = Completer();
    statistics_facilitator_list.loadLibrary().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });
    var loaded = await completer.future;
    if (loaded) {
      Get.to(
          statistics_facilitator_list.StatisticsFacilitatorList(
            isPage: (arg ?? {})["isPage"] ?? false,
          ),
          binding:
              statistics_facilitator_list.StatisticsFacilitatorListBinding());
    } else {
      toStatisticsFacilitatorList(arg: arg);
    }
  }
}

typedef CustomLibraryLoader = Future<void> Function();
typedef CustomDeferredWidgetBuilder = Widget Function();

class CustomDeferredWidgt extends StatefulWidget {
  final CustomLibraryLoader loader;
  final CustomDeferredWidgetBuilder build;
  const CustomDeferredWidgt(
      {super.key, required this.loader, required this.build});

  @override
  State<CustomDeferredWidgt> createState() => _CustomDeferredWidgtState();
}

class _CustomDeferredWidgtState extends State<CustomDeferredWidgt> {
  Widget? targetWidget;

  @override
  void initState() {
    loadBuild();
    super.initState();
  }

  loadBuild() async {
    var completer = Completer();
    widget.loader().then((_) {
      completer.complete(true);
    }).catchError((e) {
      completer.complete(false);
    });

    var loaded = await completer.future;
    if (loaded) {
      setState(() {
        targetWidget = widget.build();
      });
    } else {
      loadBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return targetWidget ?? placeholderWidget();
  }

  Widget placeholderWidget() {
    return Container(
      alignment: Alignment.center,
      child: const CupertinoActivityIndicator(),
    );
  }
}
