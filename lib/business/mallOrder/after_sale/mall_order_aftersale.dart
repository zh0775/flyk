import 'package:cxhighversion2/business/mallOrder/after_sale/mall_order_aftersale_apply.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MallOrderAftersale extends StatelessWidget {
  final Map orderData;
  final Map product;

  const MallOrderAftersale(
      {super.key, this.orderData = const {}, this.product = const {}});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "申请售后"),
      body: Column(
        children: [
          ghb(15),
          gwb(375),
          Container(
            alignment: Alignment.center,
            width: 345.w,
            decoration: getDefaultWhiteDec(radius: 8),
            child: centClm(List.generate(
                3,
                (index) => index == 1
                    ? gline(315, 0.5)
                    : CustomButton(
                        onPressed: () {
                          push(const MallOrderAftersaleApply(), context,
                              binding: MallOrderAftersaleApplyBinding(),
                              arguments: {
                                "type": index == 0 ? 0 : 1,
                                "order": orderData,
                                "product": product,
                              });
                        },
                        child: sbhRow([
                          centRow([
                            Image.asset(
                              assetsName(
                                  "business/sale/${index == 0 ? "icon_refund_speed" : "icon_return_goods"}"),
                              width: 30.w,
                              fit: BoxFit.fitWidth,
                            ),
                            gwb(12),
                            sbClm([
                              getSimpleText(
                                  index == 0 ? "我要退款（无需退货）" : "我要退款退货",
                                  14,
                                  AppColor.textBlack),
                              getSimpleText(
                                  index == 0
                                      ? "没收到货，或与卖家协商后只退款不退货"
                                      : "已收到货，需要退还货物",
                                  12,
                                  AppColor.textGrey),
                            ],
                                height: 36,
                                crossAxisAlignment: CrossAxisAlignment.start),
                          ]),
                          Image.asset(
                            assetsName("business/mall/arrow_right"),
                            width: 12.w,
                            fit: BoxFit.fitWidth,
                          )
                        ], width: 315, height: 75),
                      ))),
          ),
        ],
      ),
    );
  }
}
