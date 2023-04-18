import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert' as convert;

class ProductListCell extends StatelessWidget {
  final Map cellData;
  final bool haveBottomLine;
  final bool isDemo;
  const ProductListCell({
    Key? key,
    this.cellData = const {},
    this.haveBottomLine = false,
    this.isDemo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isReal = true;
    List payMethod =
        convert.jsonDecode(cellData["levelGiftPaymentMethod"] ?? "");
    if (payMethod.isNotEmpty) {
      isReal = (payMethod[0]["u_Type"] ?? 1) == 1;
    }
    return centClm([
      ghb(15),
      sbRow([
        ClipRRect(
          borderRadius: BorderRadius.circular(5.w),
          child: Container(
            width: 130.w,
            height: 130.w,
            color: AppColor.pageBackgroundColor,
            child: !isDemo
                ? CustomNetworkImage(
                    src: AppDefault().imageUrl +
                        (cellData["levelGiftImg"] ?? ""),
                    width: 130.w,
                    height: 130.w,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    assetsName(cellData["levelLogo"] ?? ""),
                    width: 130.w,
                    height: 130.w,
                    fit: BoxFit.fill,
                  ),
          ),
        ),
        sbClm([
          centClm([
            getWidthText(
              cellData["tbName"] ?? "",
              15,
              AppColor.textBlack,
              176,
              1,
            ),
            ghb(5),
            getWidthText(
                cellData["levelName"] ?? "", 15, AppColor.textBlack, 176, 1,
                isBold: true),
            ghb(3),
            getWidthText(cellData["levelDescribe"] ?? "", 13,
                const Color(0xFF808080), 176, 1,
                isBold: true),
          ]),
          sbRow([
            getSimpleText(
                "${isReal ? "￥" : ""}${priceFormat(cellData["nowPrice"] ?? 0)}起",
                18,
                const Color(0xFFF13030),
                isBold: true),
            Container(
                width: 60.w,
                height: 25.w,
                decoration: BoxDecoration(
                    color: AppColor.textBlack,
                    borderRadius: BorderRadius.circular(5.w)),
                child: Center(
                  child: getSimpleText(
                    "去领取",
                    12,
                    Colors.white,
                  ),
                ))
          ], width: 176),
        ], height: 130),
      ], width: 345 - 10 * 2),
      ghb(15),
      haveBottomLine ? gline(325, 0.5) : ghb(0),
    ]);
  }
}
