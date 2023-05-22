import 'package:cxhighversion2/business/mallOrder/mall_order_page.dart'
    deferred as mall_order_page;
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/contactCustomerService/contact_customer_service.dart';
import 'package:cxhighversion2/home/integralRepurchase/integral_repurchase_order.dart'
    deferred as integral_repurchase_order;
import 'package:cxhighversion2/integralstore/integral_store_order_list.dart';
import 'package:cxhighversion2/machine/machine_order_list.dart'
    deferred as machine_order_list;
import 'package:cxhighversion2/message_notify/message_notify_list.dart'
    deferred as message_notify_list;
import 'package:cxhighversion2/mine/debitCard/debit_card_info.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_check.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_upload.dart';
import 'package:cxhighversion2/mine/integral/integral_cash_order_list.dart'
    deferred as integral_cash_order_list;
import 'package:cxhighversion2/mine/integral/my_integral.dart'
    deferred as my_integral;
import 'package:cxhighversion2/mine/mineStoreOrder/mine_store_order_list.dart'
    deferred as mine_store_order_list;
import 'package:cxhighversion2/mine/mine_setting_list.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_draw.dart'
    deferred as my_wallet_draw;
import 'package:cxhighversion2/mine/personal_information.dart'
    deferred as personal_information;
import 'package:cxhighversion2/mine/vip/vip_levelup.dart';
import 'package:cxhighversion2/product/product.dart';
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MinePageController>(() => MinePageController());
  }
}

class MinePageController extends GetxController {
  String aboutMeInfoContent = "";
  String serverInfo = "";

  loadAgreement() {
    simpleRequest(
      url: Urls.agreementListByID(1),
      params: {},
      success: (success, json) {
        if (success) {
          serverInfo = (json["data"] ?? {})["content"] ?? "";
        }
      },
      after: () {},
    );
  }

  final _cClient = true.obs;
  bool get cClient => _cClient.value;
  set cClient(v) => _cClient.value = v;

  final _haveVip = false.obs;
  bool get haveVip => _haveVip.value;
  set haveVip(v) => _haveVip.value = v;

  final _haveNewMessage = false.obs;
  bool get haveNewMessage => _haveNewMessage.value;
  set haveNewMessage(v) => _haveNewMessage.value = v;

  final _xhFinish = (-1).obs;
  int get xhFinish => _xhFinish.value;
  set xhFinish(v) => _xhFinish.value = v;

  final _isLogin = false.obs;
  set isLogin(value) {
    _isLogin.value = value;
    update();
  }

  get isLogin => _isLogin.value;

  Map homeData = {};
  Map publicHomeData = {};
  String imageUrl = "";

  String topUserCellBuildId = "MinePage_topUserCellBuildId";

  @override
  void onReady() {
    needUpdate();

    super.onReady();
  }

  @override
  void onInit() {
    loadAgreement();

    bus.on(USER_LOGIN_NOTIFY, getNotify);
    bus.on(HOME_DATA_UPDATE_NOTIFY, getNotify);
    bus.on(HOME_PUBLIC_DATA_UPDATE_NOTIFY, getNotify);
    super.onInit();
  }

  getNotify(arg) {
    needUpdate();
  }

  needUpdate() {
    // dataFormat();
    getUserData().then((value) {
      homeData = AppDefault().homeData;
      publicHomeData = AppDefault().publicHomeData;
      dataFormat();
    });
  }

  // @override
  // void onReady() {
  //   homeRequest({}, (success) {});
  //   super.onReady();
  // }

  // double moneyNum = 0.0;
  // double jfNum = 0.0;

  bool isAuth = false;

  int level = 1;
  // 豆账户余额
  Map beanAccount = {};
  // 积分账户余额
  Map integraAccount = {};

  dataFormat() {
    imageUrl = AppDefault().imageUrl;
    isLogin = AppDefault().loginStatus;
    // publicHomeData = AppDefault().publicHomeData;
    cClient = false;
    // moneyNum = 0.0;
    // jfNum = 0.0;
    List accounts = homeData["u_Account"] ?? [];
    // for (var e in accounts) {
    //   if (e["a_No"] >= 4) {
    //     jfNum += (e["amout"] ?? 0);
    //   } else if (e["a_No"] <= 3) {
    //     moneyNum += (e["amout"] ?? 0);
    //   }
    // }
    for (var e in accounts) {
      if (e["a_No"] == 4) {
        integraAccount = e;
      } else if (e["a_No"] == 5) {
        beanAccount = e;
      }
    }

    Map info = (publicHomeData["webSiteInfo"] ?? {})["app"] ?? {};
    // cClient = (AppDefault().homeData["u_Role"] ?? 0) == 0;
    aboutMeInfoContent = info["apP_Introduction"] ?? "";
    isAuth = (homeData["authentication"] ?? {})["isCertified"] ?? false;
    level = homeData["uL_Level"] ?? 1;
    if (level > 9) {
      level = 9;
    }
    xhFinish = homeData["isFinsh"] != null
        ? homeData["isFinsh"]
            ? 1
            : 0
        : -1;

    haveNewMessage = homeData["unread"] ?? false;
    update([topUserCellBuildId]);
    update();
  }

  @override
  void onClose() {
    bus.off(USER_LOGIN_NOTIFY, getNotify);
    bus.off(HOME_DATA_UPDATE_NOTIFY, getNotify);
    bus.off(HOME_PUBLIC_DATA_UPDATE_NOTIFY, getNotify);
    super.onClose();
  }
}

class MinePage extends StatefulWidget {
  const MinePage({Key? key}) : super(key: key);
  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.find<MinePageController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: getDefaultAppBar(context, "我的",
            centerTitle: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(assetsName("mine/bg_top")),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter)),
            ),
            needBack: false,
            color: Colors.transparent,
            action: [
              CustomButton(
                onPressed: () async {
                  await message_notify_list.loadLibrary();
                  push(message_notify_list.MessageNotifyList(), null,
                      binding: message_notify_list.MessageNotifyListBinding());
                  controller.haveNewMessage = false;
                },
                child: Container(
                  padding: EdgeInsets.only(right: 5.w),
                  height: kToolbarHeight,
                  width: (22 + 15 * 2).w,
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          assetsName("mine/btn_tz"),
                          width: 21.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      GetX<MinePageController>(
                        builder: (_) {
                          return !controller.haveNewMessage
                              ? gemp()
                              : Positioned(
                                  top: 14.5.w,
                                  right: 13.5.w,
                                  width: 5.w,
                                  height: 5.w,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColor.red,
                                        borderRadius:
                                            BorderRadius.circular(2.5.w)),
                                  ));
                        },
                      )
                    ],
                  ),
                ),
              )
            ]),
        body: Builder(builder: (context) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 375.w,
                  height: 235.5.w - (Scaffold.of(context).appBarMaxHeight ?? 0),
                  child: Column(
                    children: [
                      Image.asset(
                        assetsName("mine/bg_top"),
                        width: 375.w,
                        height: 235.5.w -
                            (Scaffold.of(context).appBarMaxHeight ?? 0),
                        alignment: Alignment.bottomCenter,
                        fit: BoxFit.fitWidth,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ghb(10),
                      //头像区域
                      toLoginButton(context),
                      ghb(22),
                      GetBuilder<MinePageController>(builder: (_) {
                        return sbRow(
                            List.generate(
                                3,
                                (index) => CustomButton(
                                      onPressed: () async {
                                        if (index == 0 || index == 1) {
                                          await my_integral.loadLibrary();
                                          push(my_integral.MyIntegral(), null,
                                              binding: my_integral
                                                  .MyIntegralBinding(),
                                              arguments: {
                                                "isBean": index == 1
                                              });
                                        }
                                      },
                                      child: centClm([
                                        getSimpleText(
                                            index == 0
                                                ? priceFormat(
                                                    controller.integraAccount[
                                                            "amout"] ??
                                                        0,
                                                    savePoint: 0)
                                                : index == 1
                                                    ? priceFormat(
                                                        controller.beanAccount[
                                                                "amout"] ??
                                                            0,
                                                        savePoint: 0)
                                                    : "2",
                                            21,
                                            AppColor.textBlack,
                                            isBold: true),
                                        ghb(5),
                                        getSimpleText(
                                            index == 0
                                                ? "可用${controller.integraAccount["name"] ?? ""}"
                                                : index == 1
                                                    ? controller.beanAccount[
                                                            "name"] ??
                                                        ""
                                                    : "银行卡",
                                            12,
                                            AppColor.textGrey5)
                                      ]),
                                    )),
                            width: 375 - 47 * 2);
                      }),
                      ghb(25),
                      // vip
                      vipCardView(),
                      // 我的订单
                      orderView(),
                      ghb(15),
                      GetBuilder<MinePageController>(
                        builder: (_) {
                          return GetX<MinePageController>(
                            builder: (_) {
                              return controller.haveVip ? rewardCell() : ghb(0);
                            },
                          );
                        },
                      ),
                      GetBuilder<MinePageController>(
                        builder: (_) {
                          double viewWidth = 315.w;
                          return Container(
                              width: 345.w,
                              padding: EdgeInsets.symmetric(vertical: 4.25.w),
                              decoration: getDefaultWhiteDec(radius: 8),
                              child: Column(
                                children: [
                                  ghb(15),
                                  sbRow([
                                    getSimpleText("常用功能", 16, AppColor.text,
                                        isBold: true)
                                  ], width: 345 - 15.5 * 2),
                                  ghb(25),
                                  SizedBox(
                                    width: viewWidth,
                                    child: Wrap(runSpacing: 22.w, children: [
                                      funcButton("机具兑换", viewWidth),
                                      funcButton("积分订单", viewWidth),
                                      funcButton("我的钱包", viewWidth),
                                      funcButton("我的银行卡", viewWidth),
                                      funcButton("通知公告", viewWidth),
                                      funcButton("实名认证", viewWidth),
                                      funcButton("在线客服", viewWidth),
                                      funcButton("设置", viewWidth),
                                    ]),
                                  ),
                                  ghb(22),
                                  // ...List.generate(5, (index) {
                                  //   String image = "";
                                  //   String title = "";
                                  //   int last = 5 - 1;
                                  //   switch (index) {
                                  //     case 0:
                                  //       image = "mine/icon_jyjl";
                                  //       title = "交易明细";
                                  //       break;
                                  //     // case 1:
                                  //     //   image = "mine/icon_syjl";
                                  //     //   title = "收益记录";
                                  //     //   break;
                                  //     case 1:
                                  //       image = "mine/icon_bzzx";
                                  //       title = "帮助中心";
                                  //       break;
                                  //     case 2:
                                  //       image = "mine/icon_wdsc";
                                  //       title = "我的收藏";
                                  //       break;
                                  //     case 3:
                                  //       image = "mine/icon_gywm";
                                  //       title = "关于我们";
                                  //       break;
                                  //     case 4:
                                  //       image = "mine/icon_fwly";
                                  //       title = "服务协议";
                                  //       break;
                                  //     default:
                                  //   }

                                  //   return CustomButton(
                                  //     onPressed: () async {
                                  //       if (index == 0) {
                                  //         // push(const MyWallet(), context,
                                  //         //     binding: MyWalletBinding());
                                  //         await information_detail.loadLibrary();
                                  //         push(
                                  //             information_detail
                                  //                 .InformationDetail(),
                                  //             null,
                                  //             binding: information_detail
                                  //                 .InformationDetailBinding());
                                  //       } else if (index == 1) {
                                  //         // ShowToast.normal("敬请期待!");
                                  //         await mine_help_center.loadLibrary();
                                  //         push(mine_help_center.MineHelpCenter(),
                                  //             null,
                                  //             binding: mine_help_center
                                  //                 .MineHelpCenterBinding());
                                  //       } else if (index == 2) {
                                  //         // controller.cClient
                                  //         //     ? push(
                                  //         //         const IdentityAuthentication(), context,
                                  //         //         binding:
                                  //         //             IdentityAuthenticationBinding())
                                  //         //     : push(const MineAddressManager(), context,
                                  //         //         binding: MineAddressManagerBinding());
                                  //         await business_school_collect
                                  //             .loadLibrary();
                                  //         push(
                                  //             business_school_collect
                                  //                 .BusinessSchoolCollect(),
                                  //             null,
                                  //             binding: business_school_collect
                                  //                 .BusinessSchoolCollectBinding());
                                  //       } else if (index == 3) {
                                  //         // controller.cClient
                                  //         //     ? push(const MineCustomerService(), context,
                                  //         //         binding: MineCustomerServiceBinding())
                                  //         //     : push(const MineCertificateAuthorization(),
                                  //         //         context,
                                  //         //         binding:
                                  //         //             MineCertificateAuthorizationBinding());
                                  //         pushInfoContent(
                                  //           title: "关于我们",
                                  //           content:
                                  //               controller.aboutMeInfoContent,
                                  //           isText: true,
                                  //         );
                                  //       } else if (index == 4) {
                                  //         // push(const IdentityAuthentication(), context,
                                  //         //     binding: IdentityAuthenticationBinding());
                                  //         // push(const MachinePayPage(), context,
                                  //         //     binding: MachinePayPageBinding());
                                  //         pushInfoContent(
                                  //           title: "服务协议",
                                  //           content: controller.serverInfo,
                                  //         );
                                  //       } else if (index == 5) {
                                  //         // push(const MineCustomerService(), context,
                                  //         //     binding: MineCustomerServiceBinding());
                                  //         // push(const MachinePayPage(), context,
                                  //         //     binding: MachinePayPageBinding());
                                  //       } else if (index == 6) {
                                  //         // push(const MineTransactionFormat(), context,
                                  //         //     binding: MineTransactionFormatBinding());
                                  //       }
                                  //     },
                                  //     child: sbRow([
                                  //       Image.asset(
                                  //         assetsName(image),
                                  //         height: 30.w,
                                  //         fit: BoxFit.fitHeight,
                                  //       ),
                                  //       SizedBox(
                                  //         height: 54.5.w,
                                  //         child: Center(
                                  //           child: sbRow([
                                  //             getSimpleText(title, 14,
                                  //                 const Color(0xFF565B66),
                                  //                 textHeight: 1.1),
                                  //             Image.asset(
                                  //               assetsName(
                                  //                   "mine/icon_right_arrow"),
                                  //               width: 11.w,
                                  //               fit: BoxFit.fitWidth,
                                  //             )
                                  //           ], width: 345 - 16 * 2 - 40 - 0.1),
                                  //         ),
                                  //       )
                                  //     ], width: 345 - 16 * 2),
                                  //   );
                                  // })
                                ],
                              ));
                        },
                      ),
                      ghb(16),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget vipCardView() {
    return GetBuilder<MinePageController>(
      builder: (controller) {
        return SizedBox(
          width: 345.w,
          height: 63.5.w,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 345.w,
                  height: 10.w,
                  color: Colors.white,
                ),
              ),
              Positioned.fill(
                  child: Image.asset(assetsName("mine/bg_vip_card"),
                      width: 345.w, height: 63.5.w, fit: BoxFit.fill)),
              Positioned.fill(
                  // bottom: 0.5.w,
                  child: Center(
                child: sbRow([
                  centClm([
                    Image.asset(
                      assetsName("mine/text_svip"),
                      width: 120.5.w,
                      height: 16.5.w,
                      fit: BoxFit.fill,
                    ),
                    ghb(5),
                    getSimpleText("会员有效期：2023-08-11 到期", 10, Colors.white)
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  Image.asset(
                    assetsName("mine/arrow_vip_card"),
                    width: 5.w,
                    fit: BoxFit.fitWidth,
                  )
                ], width: 345 - 20 * 2),
              ))
            ],
          ),
        );
      },
    );
  }

  Widget funcButton(String title, double fullWidth) {
    Function()? onPressed;
    String imgSubStr = "";
    switch (title) {
      case "机具兑换":
        imgSubStr = "jjdh";
        onPressed = () {
          push(const Product(), context,
              binding: ProductBinding(), arguments: {"levelType": 3});

          // showAppUpdateAlert({
          //   "isDownload": false,
          //   "isShow": true,
          //   "newVersionNumber": "测试版",
          //   "newVersionDownloadUrl":
          //       "http://image.gxkunyuan.cn/D0034/Android/1.0.02X0R6.apk",
          //   "version_Content": "问题修改"
          // });
        };

        break;
      case "积分订单":
        imgSubStr = "jfdd";
        onPressed = () {
          push(const IntegralStoreOrderList(), context,
              binding: IntegralStoreOrderListBinding());
        };

        break;
      case "我的钱包":
        imgSubStr = "wdqb";
        onPressed = () {
          push(const MyWallet(), context, binding: MyWalletBinding());
        };

        break;
      case "我的银行卡":
        imgSubStr = "wdyhk";
        onPressed = () {
          checkIdentityAlert(
            toNext: () {
              push(const DebitCardInfo(), null,
                  binding: DebitCardInfoBinding());
            },
          );
        };

        break;
      case "通知公告":
        imgSubStr = "tzgg";
        onPressed = () async {
          await message_notify_list.loadLibrary();
          push(message_notify_list.MessageNotifyList(), null,
              binding: message_notify_list.MessageNotifyListBinding());
        };

        break;
      case "实名认证":
        imgSubStr = "smrz";
        onPressed = () {
          bool isAuth =
              (controller.homeData["authentication"] ?? {})["isCertified"] ??
                  false;
          if (isAuth) {
            push(const IdentityAuthenticationCheck(), context,
                binding: IdentityAuthenticationCheckBinding());
          } else {
            push(const IdentityAuthenticationUpload(), context,
                binding: IdentityAuthenticationUploadBinding());
          }
        };

        break;
      case "在线客服":
        imgSubStr = "zxkf";
        onPressed = () {
          push(const ContactCustomerService(), context,
              binding: ContactCustomerServiceBinding());
        };

        break;
      case "设置":
        imgSubStr = "sz";
        onPressed = () {
          push(const MineSettingList(), context,
              binding: MineSettingListBinding());
        };

        break;
      default:
        imgSubStr = "jjdh";
    }

    return CustomButton(
      onPressed: onPressed,
      child: SizedBox(
        width: fullWidth / 4 - 0.1.w,
        child: centClm([
          Image.asset(
            assetsName("mine/btn_$imgSubStr"),
            width: 30.w,
            height: 30.w,
            fit: BoxFit.fill,
          ),
          ghb(11),
          getSimpleText(title, 12, AppColor.textBlack)
        ]),
      ),
    );
  }

  Widget walletView(String title, String amout, {Function()? onPressed}) {
    return CustomButton(
      onPressed: onPressed,
      child: Container(
          width: 165.w,
          height: 65.w,
          padding: EdgeInsets.only(right: 15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: centRow([
            centRow([
              Image.asset(
                assetsName(
                    "mine/${title == "我的钱包" ? "icon_qbye" : "icon_jfye"}"),
                height: 26.w,
                fit: BoxFit.fitHeight,
              ),
              gwb(17.5),
              centClm([
                getSimpleText(title, 15, AppColor.text, isBold: true),
                getSimpleText(amout, 12, AppColor.text2),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ])
          ])),
    );
  }

  Widget orderView() {
    return GetBuilder<MinePageController>(
      id: controller.topUserCellBuildId,
      builder: (_) {
        // String levelStr = controller.homeData["uLevel"] ?? "";
        return Container(
          width: 345.w,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(8.w))),
          child: Column(
            children: [
              ghb(15),
              sbRow([
                getSimpleText("采购订单", 16, AppColor.text, isBold: true),
                CustomButton(
                  onPressed: () {},
                  child: centRow([
                    getSimpleText("全部订单", 12, AppColor.textGrey5),
                    gwb(5),
                    ghb(20),
                    Image.asset(assetsName("mine/arror_order_view"),
                        width: 5.w, fit: BoxFit.fitWidth)
                  ]),
                )
              ], width: 345 - 15.5 * 2),
              ghb(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  String image = "mine/btn_";
                  String text = "已完成";

                  switch (index) {
                    case 0:
                      image += "dfk";
                      text = "待付款";
                      break;
                    case 1:
                      image += "dfh";
                      text = "待发货";
                      break;
                    case 2:
                      image += "dsh";
                      text = "待收货";
                      break;
                    case 3:
                      image += "ywc";
                      text = "已完成";
                      break;

                    // case 4:
                    //   image = "mine/btn_ywc";
                    //   text = "已完成";
                    //   break;
                    default:
                      image += "ywc";
                  }

                  return CustomButton(
                    onPressed: () async {
                      // if (index == 0) {

                      // } else if (index == 1) {
                      // } else if (index == 2) {
                      // } else if (index == 3) {}
                      if (index == 0) {
                        await mall_order_page.loadLibrary();
                        push(mall_order_page.MallOrderPage(), null,
                            binding: mall_order_page.MallOrderPageBinding(),
                            arguments: {"index": 0});
                      } else if (index == 1) {
                        await integral_cash_order_list.loadLibrary();
                        push(integral_cash_order_list.IntegralCashOrderList(),
                            null,
                            binding: integral_cash_order_list
                                .IntegralCashOrderListBinding());
                      } else if (index == 2) {
                        await integral_repurchase_order.loadLibrary();
                        push(
                            integral_repurchase_order.IntegralRepurchaseOrder(),
                            null,
                            binding: integral_repurchase_order
                                .IntegralRepurchaseOrderBinding());
                      } else if (index == 3) {
                        await machine_order_list.loadLibrary();
                        push(machine_order_list.MachineOrderList(), null,
                            binding:
                                machine_order_list.MachineOrderListBinding());
                      } else {
                        await mine_store_order_list.loadLibrary();
                        push(
                            mine_store_order_list.MineStoreOrderList(
                              index: index,
                            ),
                            null,
                            binding: mine_store_order_list
                                .MineStoreOrderListBinding());
                      }
                    },
                    child: SizedBox(
                      width: (345 / 4 - 0.1).w,
                      child: centClm([
                        Image.asset(
                          assetsName(image),
                          height: 33.w,
                          fit: BoxFit.fitHeight,
                        ),
                        ghb(8),
                        getSimpleText(text, 12, AppColor.text2)
                      ]),
                    ),
                  );
                }),
              ),
              ghb(12)
            ],
          ),
        );
      },
    );
  }

  Widget rewardCell() {
    Map publicHomeData = AppDefault().publicHomeData;
    Map drawInfo = publicHomeData["drawInfo"] ?? {};
    List tmpWallet = [];

    if (!HttpConfig.baseUrl.contains("woliankeji")) {
      tmpWallet = ((controller.homeData["u_Account"] ?? []) as List).map((e) {
        e["show"] = true;
        Map walletDrawInfo = {};
        if (drawInfo["draw_Account${e["a_No"] ?? -1}"] != null) {
          walletDrawInfo = drawInfo["draw_Account${e["a_No"] ?? -1}"];
        }
        e["haveDraw"] = walletDrawInfo.isNotEmpty;
        if (walletDrawInfo.isNotEmpty) {
          e["minCharge"] =
              "${walletDrawInfo["draw_Account_SingleAmountMin"] ?? 0}";
          e["charge"] = "${walletDrawInfo["draw_Account_ServiceCharges"] ?? 0}";
          e["fee"] = "${walletDrawInfo["draw_Account_SingleFee"] ?? 0}";
        }
        return e;
      }).toList();
    } else if (HttpConfig.baseUrl.contains("woliankeji")) {
      List drawWallets =
          ((drawInfo["System_AllowDrawAccount"] ?? "") as String).split(",");
      List drawCharges =
          ((drawInfo["System_TiHandlingCharge"] ?? "") as String).split(",");
      List drawFees = ((drawInfo["System_DrawFee"] ?? "") as String).split(",");

      tmpWallet = ((controller.homeData["u_Account"] ?? []) as List).map((e) {
        e["show"] = true;

        int walletIdx = -1;
        for (var i = 0; i < drawWallets.length; i++) {
          if (e["a_No"] == int.parse(drawWallets[i])) {
            walletIdx = i;
            break;
          }
        }
        e["haveDraw"] = walletIdx != -1 ? true : false;

        if (walletIdx != -1) {
          e["minCharge"] = drawInfo["System_MinHandingCharge"];
          e["charge"] = drawCharges[walletIdx];
          e["fee"] = drawFees[walletIdx];
        }
        return e;
      }).toList();
    }

    Map walletData = {};
    for (var e in tmpWallet) {
      if (e["haveDraw"] != null && e["haveDraw"]) {
        walletData = e;
        break;
      }
    }

    return CustomButton(
      onPressed: () async {
        if (walletData.isEmpty) {
          toLogin();
          return;
        }
        await my_wallet_draw.loadLibrary();
        push(my_wallet_draw.MyWalletDraw(walletData: walletData), null,
            binding: my_wallet_draw.MyWalletDrawBinding());
      },
      child: Container(
        width: 345.w,
        height: 80.w,
        decoration: BoxDecoration(
            color: AppDefault().getThemeColor() ?? AppColor.theme,
            borderRadius: BorderRadius.circular(12.w),
            image: DecorationImage(
                image: AssetImage(assetsName("mine/bg_reward_cell")),
                fit: BoxFit.fill),
            boxShadow: [
              BoxShadow(
                  color: const Color(0x322368F2),
                  offset: Offset(0, 8.5.w),
                  blurRadius: 5.5.w)
            ]),
        child: Column(
          children: [
            ghb(20),
            Row(
              children: [
                gwb(25),
                getRichText("￥", priceFormat(walletData["amout"] ?? 0), 12,
                    Colors.white, 24, Colors.white,
                    fw2: AppDefault.fontBold),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget toLoginButton(BuildContext context) {
    return CustomButton(
      onPressed: () {
        if (!controller.isLogin) {
          toLogin();
        }
      },
      child: GetBuilder<MinePageController>(
        init: controller,
        id: controller.topUserCellBuildId,
        initState: (_) {},
        builder: (_) {
          double maxNameWidth = 345 - (71 + 16 + 3 + 5 + 50) - 0.1;

          String name = controller.isLogin
              ? (controller.homeData["nickName"] != null &&
                      controller.homeData["nickName"].isNotEmpty
                  ? controller.homeData["nickName"]
                  : "请设置昵称")
              : "点击登录";
          double nameWidth = maxNameWidth.w;

          return SizedBox(
            width: 375.w,
            child: Align(
              child: sbRow([
                GetX<MinePageController>(
                  builder: (_) {
                    return centRow([
                      gwb(21),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(71.w / 2),
                          child: controller.isLogin
                              ? CustomButton(
                                  onPressed: () {
                                    if (controller.homeData["userAvatar"] !=
                                            null &&
                                        controller.homeData["userAvatar"]
                                            .isNotEmpty) {
                                      toCheckImg(
                                          image:
                                              "${controller.imageUrl}${controller.homeData["userAvatar"]}",
                                          needSave: true);
                                    }
                                  },
                                  child: CustomNetworkImage(
                                    src:
                                        "${controller.imageUrl}${controller.homeData["userAvatar"]}",
                                    width: 71.w,
                                    height: 71.w,
                                    fit: BoxFit.cover,
                                    errorWidget: Image.asset(
                                      assetsName("mine/default_head"),
                                      width: 71.w,
                                      height: 71.w,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  assetsName("mine/default_head"),
                                  width: 71.w,
                                  height: 71.w,
                                  fit: BoxFit.fill,
                                )),
                      gwb(7.5),
                      centClm([
                        SizedBox(
                          width: (375 - 21 - 71 - 7.5 - 1 - 55.5).w,
                          child: Text.rich(
                            TextSpan(
                                text: name,
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    color: (controller.homeData["nickName"] !=
                                                    null &&
                                                controller.homeData["nickName"]
                                                    .isNotEmpty) ||
                                            !controller.isLogin
                                        ? AppColor.text
                                        : AppColor.textGrey,
                                    fontWeight: AppDefault.fontBold,
                                    height: 1.1),
                                children: [
                                  WidgetSpan(
                                      child: Padding(
                                    padding: EdgeInsets.only(left: 5.w),
                                    child: Image.asset(
                                      assetsName(
                                          "mine/vip/level${controller.level}"),
                                      width: 31.5.w,
                                      height: 20.w,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  )),
                                  WidgetSpan(
                                      child: !controller.isAuth
                                          ? gwb(0)
                                          : Padding(
                                              padding:
                                                  EdgeInsets.only(left: 4.w),
                                              child: Image.asset(
                                                assetsName("mine/icon_isauth"),
                                                width: 54.5.w,
                                                height: 20.w,
                                                fit: BoxFit.fitWidth,
                                              ),
                                            )),
                                ]),
                            maxLines: 10,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ghb(10),
                        controller.isLogin
                            ? CustomButton(
                                onPressed: () {
                                  push(const VipLevelup(), context,
                                      binding: VipLevelupBinding());
                                },
                                child: Container(
                                  height: 20.w,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10.w)),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.5.w),
                                  alignment: Alignment.center,
                                  child: centRow([
                                    Image.asset(
                                        assetsName("mine/icon_user_growth"),
                                        width: 15.w,
                                        fit: BoxFit.fitWidth),
                                    // gwb(1),
                                    getSimpleText(
                                        "成长值 45962", 10, AppColor.textBlack),
                                    gwb(4),
                                    Image.asset(
                                      assetsName("mine/icon_user_growth_arrow"),
                                      width: 4.w,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    gwb(4)
                                  ]),
                                ),
                              )
                            : getSimpleText(
                                controller.isLogin
                                    ? "手机号：${controller.homeData["u_Mobile"] ?? ""}"
                                    : "登录同步数据，使用更安心",
                                12,
                                AppColor.text2),
                      ], crossAxisAlignment: CrossAxisAlignment.start)
                    ]);
                  },
                ),
                CustomButton(
                  onPressed: () async {
                    await personal_information.loadLibrary();
                    push(
                      personal_information.PersonalInformation(),
                      null,
                      binding:
                          personal_information.PersonalInformationBinding(),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: 55.5.w,
                    child: centRow([
                      ghb(40),
                      Image.asset(assetsName("mine/btn_userinfo_edit"),
                          width: 15.w, fit: BoxFit.fitWidth),
                      gwb(1),
                      getSimpleText("编辑", 12, AppColor.textBlack)
                    ]),
                  ),
                )
              ], width: 375),
            ),
          );
        },
      ),
    );
  }

  Widget orderButtons(String title, String assets,
      {Function()? onPressed, int type = 0}) {
    return CustomButton(
      onPressed: onPressed,
      child: SizedBox(
        width: 375.w / 4 - 0.1.w,
        height: 67.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetsName(assets.isNotEmpty ? assets : "pay/icon_business"),
              height: type == 1 ? 30.w : 20.w,
              fit: BoxFit.fitHeight,
            ),
            ghb(15),
            getSimpleText(title, 14, AppColor.textBlack),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
