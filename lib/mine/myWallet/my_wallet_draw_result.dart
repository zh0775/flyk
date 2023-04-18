import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyWalletDrawResult extends StatelessWidget {
  final Map resultData;
  final bool success;
  final num money;
  final String accountName;
  final String describe;
  final String contentTitle;

  const MyWalletDrawResult(
      {super.key,
      this.resultData = const {},
      this.accountName = "",
      this.success = true,
      this.money = 0,
      this.contentTitle = "提现申请提交成功",
      this.describe = "提现后7个工作日内到账，若有疑问请联系客服"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        "提现结果",
        backPressed: () {
          popToUntil(
            page: const MyWallet(),
            binding: MyWalletBinding(),
          );
        },
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ghb(16),
            SizedBox(
              width: 375.w,
              height: 300.w,
              child: Stack(
                children: [
                  Positioned.fill(
                      left: 15.w,
                      right: 15.w,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 197.5.w,
                              child: centClm([
                                ghb(25),
                                Image.asset(
                                  assetsName(
                                      "machine/icon_result_${success ? "success" : "fail"}"),
                                  width: 57.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                ghb(23.5),
                                getSimpleText(contentTitle, 18, AppColor.text,
                                    isBold: true),
                                ghb(10),
                                getSimpleText(describe, 12, AppColor.text2),
                              ]),
                            ),
                            getCustomDashLine(
                              300,
                              0.5,
                              v: false,
                              dashSingleGap: 3,
                              strokeWidth: 0.5,
                              color: AppColor.lineColor,
                            ),
                            SizedBox(
                              height: 102.w - 0.1.w,
                              child: Center(
                                child: centClm(List.generate(
                                    2,
                                    (index) => sbhRow([
                                          getSimpleText(
                                              index == 0 ? "收款账户" : "提现金额",
                                              12,
                                              AppColor.text3),
                                          getSimpleText(
                                              index == 0
                                                  ? accountName
                                                  : "￥${priceFormat(money)}",
                                              12,
                                              AppColor.text2),
                                        ], width: 345 - 23 * 2, height: 30))),
                              ),
                            )
                          ],
                        ),
                      )),
                  Positioned(
                      top: 190.w,
                      left: 15.w - 15.5.w / 2,
                      width: 15.5.w,
                      height: 15.5.w,
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColor.pageBackgroundColor,
                            borderRadius: BorderRadius.circular(15.5.w / 2)),
                      )),
                  Positioned(
                      top: 190.w,
                      right: 15.w - 15.5.w / 2,
                      width: 15.5.w,
                      height: 15.5.w,
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColor.pageBackgroundColor,
                            borderRadius: BorderRadius.circular(15.5.w / 2)),
                      ))
                ],
              ),
            ),
            ghb(31),
            CustomButton(
              onPressed: () {
                popToUntil(
                  page: const MyWallet(),
                  binding: MyWalletBinding(),
                );
              },
              child: Container(
                width: 345.w,
                height: 45.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      width: 0.5.w,
                      color: AppColor.theme,
                    ),
                    borderRadius: BorderRadius.circular(45.w / 2)),
                child: getSimpleText(
                    success ? "查看详情" : "返回钱包", 15, AppColor.theme),
              ),
            )
          ],
        ),
      ),
    );
  }
}
