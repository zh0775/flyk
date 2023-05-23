//通超级会员页面

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/member/purchase_history.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class OpenMemberShipBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<OpenMemberShipController>(OpenMemberShipController());
  }
}

class OpenMemberShipController extends GetxController {
  final _currentVipIndex = 0.obs; // 会员默认第一个
  int get currentVipIndex => _currentVipIndex.value;
  set currentVipIndex(v) => _currentVipIndex.value = v;

  // 是否开通会员   默认没有开通
  final _isPay = false.obs;
  bool get isPay => _isPay.value;
  set isPay(v) => _isPay.value = v;
  // bool isPay = false;

  List superVipData = [
    {
      "id": 1,
      "originalPrice": 128,
      "discountedPrice": 98,
      "title": "月",
    },
    {
      "id": 2,
      "originalPrice": 376,
      "discountedPrice": 298,
      "title": "季",
    },
    {
      "id": 3,
      "originalPrice": 1280,
      "discountedPrice": 999,
      "title": "年",
    }
  ];

  // 开通会员mether
  openMemberPopup(openMemberPopupBox) {
    showGeneralDialog(
        barrierDismissible: false,
        context: Global.navigatorKey.currentContext!,
        pageBuilder: (context, animation, secondaryAnimation) {
          return openMemberPopupBox;
        });
  }

  // 购买成功member
  openIsPaySuccessPopup(vipPaySuccess) {
    if (isPay) {
      showGeneralDialog(
        barrierDismissible: false,
        context: Global.navigatorKey.currentContext!,
        pageBuilder: (context, animation, secondaryAnimation) {
          return vipPaySuccess;
        },
      );
    }
  }
}

class OpenMemberShipPage extends GetView<OpenMemberShipController> {
  const OpenMemberShipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, "开通超级会员", action: [
        CustomButton(
          onPressed: () {
            push(const PurchaseHistoryPage(), context, binding: PurchaseHistoryBinding());
          },
          child: SizedBox(
            height: kToolbarHeight,
            width: 80.w,
            child: Center(
              child: getSimpleText("购买记录", 14, AppColor.textBlack),
            ),
          ),
        )
      ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 375.w,
              height: 560.w,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: svipHeaderBox(),
                  ),
                  Positioned(
                    top: 260.w,
                    child: vipSwipe(),
                  )
                ],
              ),
            ),
            ghb(15),
            memberBenefits(),
          ],
        ),
      ),
    );
  }

  // 付立优客plus · svip
  Widget svipHeaderBox() {
    //
    return Container(
      width: 375.w,
      height: 300.w,
      decoration: const BoxDecoration(color: Color(0xFF272D3D)),
      child: Column(
        children: [
          ghb(24),
          SizedBox(
            child: Image.asset(
              assetsName('member/svip-header'),
              width: 278.w,
              height: 44.5.w,
              fit: BoxFit.fitWidth,
            ),
          ),
          ghb(20),
          Container(
            width: 375.w,
            height: 200.w,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(assetsName("member/card-bg")),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  child: sbRow([
                    centRow(
                      [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32.w / 2),
                          child: Image.asset(
                            assetsName('mine/default_head'),
                            width: 32.w,
                            height: 32.w,
                            fit: BoxFit.fill,
                          ),
                        ),
                        gwb(13),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getSimpleText('尊敬的付利优客', 16, Colors.white),
                            getSimpleText('您当前还不是SVIP，请购买会员套餐', 12, Colors.white38),
                          ],
                        )
                      ],
                    ),
                  ]),
                ),
                ghb(20.5),
                SizedBox(
                  width: 375.w - 15.w * 2,
                  height: 102.w,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 15.w,
                        right: 0,
                        child: Container(
                          width: 181.5.w,
                          height: 107.5.w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                assetsName('member/regular-vip'),
                              ),
                            ),
                          ),
                          child: centClm([
                            getSimpleText('刷卡费率低至 0.60', 12, Colors.white),
                            getSimpleText('扫码费率低至 0.38', 12, Colors.white),
                          ]),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: Container(
                          width: 181.5.w,
                          height: 105.w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                assetsName('member/super-vip'),
                              ),
                            ),
                          ),
                          child: centClm([
                            ghb(15),
                            getSimpleText('刷卡费率低至 0.60', 14, const Color(0xFF7D3E04)),
                            getSimpleText('扫码费率低至 0.38', 14, const Color(0xFF7D3E04)),
                          ]),
                        ),
                      ),
                      Positioned.fill(
                        top: 30.w,
                        child: Image.asset(
                          assetsName('member/vs'),
                          width: 40.w,
                          height: 40.w,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // vip-swipper
  Widget vipSwipe() {
    return GetBuilder<OpenMemberShipController>(
      init: OpenMemberShipController(),
      builder: (controller) {
        return Container(
          width: 375.w,
          height: 300.w,
          padding: EdgeInsets.only(top: 34.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
          ),
          child: Column(
            children: [
              Container(
                width: 375.w,
                height: 172.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.w),
                ),

                child: ListView.builder(
                    itemCount: controller.superVipData.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      Map item = controller.superVipData[index] ?? {};
                      return CustomButton(
                          onPressed: () {
                            controller.currentVipIndex = index;
                            controller.update();
                          },
                          child: Container(
                            width: 120.w,
                            height: 172.w,
                            margin: EdgeInsets.only(left: 20.w),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: controller.currentVipIndex == index
                                      ? Image.asset(
                                          assetsName('member/vip-bg'),
                                          width: 120.w,
                                          height: 160.w,
                                          fit: BoxFit.fill,
                                        )
                                      : Container(
                                          width: 120.w,
                                          height: 160.w,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFCF3),
                                            border: Border.all(
                                              color: const Color(0xFFFFE9B1),
                                            ),
                                            borderRadius: BorderRadius.circular(15.w),
                                          ),
                                        ),
                                ),
                                Positioned.fill(
                                    child: centClm([
                                  ghb(25.5),
                                  getSimpleText("包${item['title']}", 14, const Color(0xFF804E13)),
                                  ghb(12),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '¥',
                                          style: TextStyle(
                                            color: const Color(0xFF804E13),
                                            fontSize: 24.w,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "${item['discountedPrice']}",
                                          style: TextStyle(
                                            color: const Color(0xFF804E13),
                                            fontSize: 36.w,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  ghb(5),
                                  Text(
                                    "￥ ${item['originalPrice']}",
                                    style: const TextStyle(
                                      color: Color(0xFF804E13),
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  ghb(20.w),
                                ])),
                                controller.currentVipIndex == index
                                    ? Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: 120.w,
                                          height: 30.w,
                                          alignment: Alignment.center,
                                          child: getSimpleText("立省${item['originalPrice'] - item['discountedPrice']}元", 14, const Color(0xFF804E13)),
                                        ),
                                      )
                                    : gwb(0),
                                controller.currentVipIndex == index
                                    ? Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          width: 75.w,
                                          height: 24.w,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [
                                              Color(0xFFFE5E00),
                                              Color(0xFFFB7600),
                                            ], begin: Alignment.centerLeft, end: Alignment.centerRight),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.w),
                                              bottomRight: Radius.circular(8.w),
                                            ),
                                          ),
                                          child: getSimpleText("限时福利价", 12, Colors.white),
                                        ),
                                      )
                                    : gwb(0)
                              ],
                            ),
                          ));
                    }),
                // child: ListView(
                //   scrollDirection: Axis.horizontal,
                //   children: [
                //     Container(
                //       width: 120.w,
                //       height: 172.w,
                //       margin: EdgeInsets.only(left: 20.w),
                //       child: Stack(
                //         children: [
                //           Align(
                //             alignment: Alignment.bottomCenter,
                //             child: Image.asset(
                //               assetsName('member/vip-bg'),
                //               width: 120.w,
                //               height: 160.w,
                //               fit: BoxFit.fill,
                //             ),
                //           ),
                //           Positioned.fill(
                //               child: centClm([
                //             ghb(25.5),
                //             getSimpleText('包月', 14, const Color(0xFF804E13)),
                //             ghb(12),
                //             Text.rich(
                //               TextSpan(
                //                 children: [
                //                   TextSpan(
                //                     text: '¥',
                //                     style: TextStyle(
                //                       color: const Color(0xFF804E13),
                //                       fontSize: 24.w,
                //                     ),
                //                   ),
                //                   TextSpan(
                //                     text: '98',
                //                     style: TextStyle(
                //                       color: const Color(0xFF804E13),
                //                       fontSize: 36.w,
                //                     ),
                //                   )
                //                 ],
                //               ),
                //             ),
                //             ghb(5),
                //             const Text(
                //               '￥128',
                //               style: TextStyle(
                //                 color: Color(0xFF804E13),
                //                 fontSize: 12,
                //                 decoration: TextDecoration.lineThrough,
                //               ),
                //             ),
                //             ghb(20.w),
                //           ])),
                //           Align(
                //             alignment: Alignment.bottomCenter,
                //             child: Container(
                //               width: 120.w,
                //               height: 30.w,
                //               alignment: Alignment.center,
                //               child: getSimpleText('立省30元', 14, const Color(0xFF804E13)),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.topLeft,
                //             child: Container(
                //               width: 75.w,
                //               height: 24.w,
                //               alignment: Alignment.center,
                //               decoration: BoxDecoration(
                //                 gradient: const LinearGradient(colors: [
                //                   Color(0xFFFE5E00),
                //                   Color(0xFFFB7600),
                //                 ], begin: Alignment.centerLeft, end: Alignment.centerRight),
                //                 borderRadius: BorderRadius.only(
                //                   topLeft: Radius.circular(4.w),
                //                   bottomRight: Radius.circular(8.w),
                //                 ),
                //               ),
                //               child: getSimpleText("限时福利价", 12, Colors.white),
                //             ),
                //           )
                //         ],
                //       ),
                //     ),

                // Container(
                //   width: 120.w,
                //   height: 172.w,
                //   margin: EdgeInsets.only(left: 20.w),
                //   child: Stack(
                //     children: [
                //       Align(
                //         alignment: Alignment.bottomCenter,
                //         child: Container(
                //           width: 120.w,
                //           height: 160.w,
                //           decoration: BoxDecoration(
                //             color: const Color(0xFFFFFCF3),
                //             border: Border.all(
                //               color: const Color(0xFFFFE9B1),
                //             ),
                //             borderRadius: BorderRadius.circular(15.w),
                //           ),
                //         ),
                //       ),
                //       Positioned.fill(
                //           child: centClm([
                //         ghb(25.5),
                //         getSimpleText('包月', 14, const Color(0xFF804E13)),
                //         ghb(12),
                //         Text.rich(
                //           TextSpan(
                //             children: [
                //               TextSpan(
                //                 text: '¥',
                //                 style: TextStyle(
                //                   color: const Color(0xFF804E13),
                //                   fontSize: 24.w,
                //                 ),
                //               ),
                //               TextSpan(
                //                 text: '98',
                //                 style: TextStyle(
                //                   color: const Color(0xFF804E13),
                //                   fontSize: 36.w,
                //                 ),
                //               )
                //             ],
                //           ),
                //         ),
                //         ghb(5),
                //         const Text(
                //           '￥128',
                //           style: TextStyle(
                //             color: Color(0xFF804E13),
                //             fontSize: 12,
                //             decoration: TextDecoration.lineThrough,
                //           ),
                //         ),
                //         ghb(20.w),
                //       ])),
                //     ],
                //   ),
                // ),
                //   ],
                // ),
              ),
              ghb(20.5),
              CustomButton(
                onPressed: () {
                  // print('确认协议并支付');
                },
                child: Container(
                  width: 375.w - 15.w * 2,
                  height: 45.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(0, 0),
                      end: Alignment(1, 1),
                      colors: [
                        Color(0xFFFD573B),
                        Color(0xFFFF3A3A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(45.w / 2),
                  ),
                  child: centClm([
                    getSimpleButton(
                      () {
                        controller.openMemberPopup(openMemberPopupBox());
                      },
                      getSimpleText("确认协议并支付 ￥${controller.superVipData[controller.currentVipIndex]['discountedPrice']}", 15, Colors.white),
                    )
                  ]),
                ),
              ),
              ghb(12),
              centRow([getSimpleText('开通前请阅读', 12, const Color(0xFF999999)), getSimpleText('《SVIP会员服务协议及续费声明》', 12, const Color(0xFFFE4F3B))])
            ],
          ),
        );
      },
    );
  }

  // Member benefits
  Widget memberBenefits() {
    return Container(
      width: 375.w,
      height: 285.w,
      padding: EdgeInsets.all(15.w),
      color: Colors.white,
      child: Column(
        children: [
          sbRow([getSimpleText("超级会员权益", 16, AppColor.text, isBold: true)], width: 375 - 15.5 * 2),
          ghb(18.5),
          SizedBox(
            child: Wrap(
              spacing: 8.w,
              children: [
                Container(
                  width: 80.w,
                  height: 90.w,
                  decoration: BoxDecoration(color: const Color(0xFFFFF5E4), borderRadius: BorderRadius.circular(5.w)),
                  // color: Color(0xFFFFF5E4),
                  child: centClm(
                    [
                      Image.asset(
                        assetsName("member/rate-management"),
                        width: 30.w,
                        height: 30.w,
                        fit: BoxFit.fill,
                      ),
                      ghb(8),
                      getSimpleText('超低', 14, const Color(0xFF804E13), isBold: true),
                      ghb(6.5),
                      getSimpleText('商户费率', 12, const Color(0xFFC6AE94))
                    ],
                  ),
                ),
                Container(
                  width: 80.w,
                  height: 90.w,
                  decoration: BoxDecoration(color: const Color(0xFFFFF5E4), borderRadius: BorderRadius.circular(5.w)),
                  // color: Color(0xFFFFF5E4),
                  child: centClm(
                    [
                      Image.asset(
                        assetsName("member/handover"),
                        width: 30.w,
                        height: 30.w,
                        fit: BoxFit.fill,
                      ),
                      ghb(8),
                      getSimpleText('免费', 14, const Color(0xFF804E13), isBold: true),
                      ghb(6.5),
                      getSimpleText('售后换新', 12, const Color(0xFFC6AE94))
                    ],
                  ),
                ),
                Container(
                  width: 80.w,
                  height: 90.w,
                  decoration: BoxDecoration(color: const Color(0xFFFFF5E4), borderRadius: BorderRadius.circular(5.w)),
                  // color: Color(0xFFFFF5E4),
                  child: centClm(
                    [
                      Image.asset(
                        assetsName("member/merchant"),
                        width: 30.w,
                        height: 30.w,
                        fit: BoxFit.fill,
                      ),
                      ghb(8),
                      getSimpleText('专属', 14, const Color(0xFF804E13), isBold: true),
                      ghb(6.5),
                      getSimpleText('优质商户', 12, const Color(0xFFC6AE94))
                    ],
                  ),
                ),
                Container(
                  width: 80.w,
                  height: 90.w,
                  decoration: BoxDecoration(color: const Color(0xFFFFF5E4), borderRadius: BorderRadius.circular(5.w)),
                  // color: Color(0xFFFFF5E4),
                  child: centClm(
                    [
                      Image.asset(
                        assetsName("member/user-vip"),
                        width: 30.w,
                        height: 30.w,
                        fit: BoxFit.fill,
                      ),
                      ghb(8),
                      getSimpleText('尊享', 14, const Color(0xFF804E13), isBold: true),
                      ghb(6.5),
                      getSimpleText('身份标识', 12, const Color(0xFFC6AE94))
                    ],
                  ),
                )
              ],
            ),
          ),
          ghb(15),
          CustomButton(
            onPressed: () {},
            child: Image.asset(
              assetsName(
                'member/merchant-registration',
              ),
              width: 375.w - 15.w * 2,
              height: 110.w,
            ),
          )
        ],
      ),
    );
  }

  // 购买会员widget
  Widget openMemberPopupBox() {
    return GetBuilder<OpenMemberShipController>(
      init: OpenMemberShipController(),
      builder: (controller) {
        return UnconstrainedBox(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300.w,
              height: 350.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.w),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(assetsName("member/popup-vip")),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 12.w,
                    child: Container(
                      width: 75.w,
                      height: 24.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFFFE5E00),
                          Color(0xFFFB7600),
                        ], begin: Alignment.centerLeft, end: Alignment.centerRight),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.w),
                          bottomRight: Radius.circular(8.w),
                        ),
                      ),
                      child: getSimpleText("限时福利价", 12, Colors.white),
                    ),
                  ),
                  Positioned.fill(
                      child: Column(
                    children: [
                      ghb(19.5),
                      getSimpleText('超值月卡', 18, const Color(0xFFFFDBA2)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getSimpleText('¥', 14, const Color(0xFFFFDBA2)),
                          getSimpleText('98', 24, const Color(0xFFFFDBA2)),
                          gwb(15),
                          getSimpleText('开通超级会员', 24, const Color(0xFFFFDBA2)),
                        ],
                      ),
                      ghb(40.5),
                      getSimpleText('- 会员专享特权 -', 18, const Color(0xFF804E13), isBold: true),
                      ghb(19.5),
                      SizedBox(
                        child: Wrap(
                          spacing: 8.w,
                          children: [
                            Container(
                              width: 56.w,
                              height: 63.w,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.w)),
                              // color: Color(0xFFFFF5E4),
                              child: centClm(
                                [
                                  Image.asset(
                                    assetsName("member/rate-management"),
                                    width: 21.w,
                                    height: 21.w,
                                    fit: BoxFit.fill,
                                  ),
                                  getSimpleText('超低', 12, const Color(0xFF804E13), isBold: true),
                                  getSimpleText('商户费率', 10, const Color(0xFFC6AE94))
                                ],
                              ),
                            ),
                            Container(
                              width: 56.w,
                              height: 63.w,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.w)),
                              // color: Color(0xFFFFF5E4),
                              child: centClm(
                                [
                                  Image.asset(
                                    assetsName("member/handover"),
                                    width: 21.w,
                                    height: 21.w,
                                    fit: BoxFit.fill,
                                  ),
                                  getSimpleText('免费', 12, const Color(0xFF804E13), isBold: true),
                                  getSimpleText('售后换新', 10, const Color(0xFFC6AE94))
                                ],
                              ),
                            ),
                            Container(
                              width: 56.w,
                              height: 63.w,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.w)),
                              // color: Color(0xFFFFF5E4),
                              child: centClm(
                                [
                                  Image.asset(
                                    assetsName("member/merchant"),
                                    width: 21.w,
                                    height: 21.w,
                                    fit: BoxFit.fill,
                                  ),
                                  getSimpleText('专属', 12, const Color(0xFF804E13), isBold: true),
                                  getSimpleText('优质商户', 10, const Color(0xFFC6AE94))
                                ],
                              ),
                            ),
                            Container(
                              width: 56.w,
                              height: 63.w,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.w)),
                              // color: Color(0xFFFFF5E4),
                              child: centClm(
                                [
                                  Image.asset(
                                    assetsName("member/user-vip"),
                                    width: 21.w,
                                    height: 21.w,
                                    fit: BoxFit.fill,
                                  ),
                                  getSimpleText('尊享', 12, const Color(0xFF804E13), isBold: true),
                                  getSimpleText('身份标识', 10, const Color(0xFFC6AE94))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      ghb(21),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getSimpleText('尊享多种会员特权，开通预计可省', 12, const Color(0xFF804E13)),
                          getSimpleText('￥4800', 16, const Color(0xFFFE493B), isBold: true),
                        ],
                      ),
                      ghb(24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomButton(
                            onPressed: () {
                              // Get.back();
                              Navigator.pop(Global.navigatorKey.currentContext!);
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(33.w, 15.w, 33.w, 15.w),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF261D1C),
                                  width: 0.5.w,
                                ),
                                borderRadius: BorderRadius.circular(22.5.w),
                              ),
                              child: getSimpleText('暂不需要', 15, const Color(0xFF261D1C)),
                            ),
                          ),
                          CustomButton(
                            onPressed: () {
                              controller.isPay = true;

                              Navigator.pop(Global.navigatorKey.currentContext!);
                              controller.openIsPaySuccessPopup(vipPaySuccess());
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(33.w, 15.w, 33.w, 15.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF261D1C),
                                border: Border.all(
                                  color: const Color(0xFF261D1C),
                                  width: 0.5.w,
                                ),
                                borderRadius: BorderRadius.circular(22.5.w),
                              ),
                              child: getSimpleText('马上开通', 15, Colors.white),
                            ),
                          )
                        ],
                      )
                    ],
                  ))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 购买会员成功
  Widget vipPaySuccess() {
    return UnconstrainedBox(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 300.w,
          height: 270.w + 25.w + 30.w,
          child: Column(
            children: [
              Container(
                width: 300.w,
                height: 270.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(assetsName('member/popup')),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  children: [
                    ghb(14.5.w),
                    Container(
                      width: 250.w,
                      height: 110.w,
                      padding: EdgeInsets.all(18.5.w),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(assetsName('member/card-bg')),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              getSimpleText('1个月超级会员卡', 18, const Color(0xFFFFDBA2)),
                              Image(
                                width: 46.5.w,
                                height: 14.w,
                                image: AssetImage(assetsName('member/svip')),
                                fit: BoxFit.fill,
                              )
                            ],
                          ),
                          Row(
                            children: [
                              gwb(10),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                        text: '¥',
                                        style: TextStyle(
                                          color: const Color(0xFFFFDCA2),
                                          fontSize: 14.w,
                                        )),
                                    TextSpan(
                                        text: '98',
                                        style: TextStyle(
                                          color: const Color(0xFFFFDCA2),
                                          fontSize: 24.w,
                                        )),
                                  ],
                                ),
                              ),
                              Text(
                                '￥128',
                                style: TextStyle(
                                  color: const Color(0xFFFFDCA2),
                                  fontSize: 12.w,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    ghb(18),
                    getSimpleText('购买成功！', 18, const Color(0xFF333333), isBold: true),
                    ghb(18),
                    getSimpleText('您已成功开通1个月超级会员', 12, const Color(0xFF999999)),
                    ghb(18),
                    CustomButton(
                      onPressed: () {},
                      child: Container(
                        alignment: Alignment.center,
                        width: 150.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.w),
                          color: const Color(0xFFFD573B),
                          gradient: const LinearGradient(colors: [Color(0xFFFD573B), Color(0xFFFF3A3A)]),
                        ),
                        child: getSimpleText('立即体验', 15, Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              ghb(25),
              CustomButton(
                onPressed: () {
                  Navigator.pop(Global.navigatorKey.currentContext!);
                },
                child: Image(
                  width: 30.w,
                  height: 30.w,
                  image: AssetImage(assetsName('member/close')),
                  fit: BoxFit.fill,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
