import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/product/component/product_list_cell.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert' as convert;

class MachineProductCell extends StatelessWidget {
  final int? index;
  final Function(int idx)? toPay;
  final Map cellData;
  final bool isList;
  const MachineProductCell(
      {Key? key,
      this.index,
      this.toPay,
      this.cellData = const {},
      this.isList = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (toPay != null) {
          toPay!(index ?? 0);
        }
      },
      child: UnconstrainedBox(
        child: Container(
          // margin: EdgeInsets.only(left: 10.sp),
          width: isList ? 345.w : 168.w,
          // height: isList ? 160.w : 298.w,
          decoration: BoxDecoration(
            color: isList ? Colors.white : Colors.white,
            borderRadius: BorderRadius.circular(5.w),
          ),

          child: isList ? listCell() : wrapCell(),
        ),
      ),
    );
  }

  Widget wrapCell() {
    bool isReal = true;
    List payMethod =
        convert.jsonDecode(cellData["levelGiftPaymentMethod"] ?? "");
    if (payMethod.isNotEmpty) {
      isReal = (payMethod[0]["u_Type"] ?? 1) == 1;
    }
    return Column(
      children: [
        SizedBox(
          width: 168.w,
          height: 168.w,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(5.w)),
                    child: Container(
                      color: const Color(0xFFF0F0F0),
                      width: 168.w,
                      height: 168.w,
                      child: CustomNetworkImage(
                        src: AppDefault().imageUrl +
                            (cellData["levelGiftImg"] ?? ""),
                        width: 168.w,
                        height: 168.w,
                        fit: BoxFit.contain,
                      ),
                    )),
              ),
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 25.w,
                  child: Container(
                    color: const Color(0xB2000000),
                    child: Center(
                      child: getSimpleText(
                          cellData["levelDescribe"] ?? "", 11, Colors.white,
                          isBold: true),
                    ),
                  ))
            ],
          ),
        ),
        ghb(10),
        // getWidthText(
        //   cellData["levelName"] ?? "",
        //   15,
        //   AppColor.textBlack,
        //   168 - 8 * 2,
        //   1,
        // ),
        ghb(5),
        getWidthText(
            cellData["levelName"] ?? "", 16, AppColor.textBlack, 168 - 8 * 2, 1,
            isBold: true),
        ghb(5),
        // getWidthText(
        //   cellData["levelSubhead"] ?? "",
        //   13,
        //   const Color(0xFF808080),
        //   168 - 8 * 2,
        //   1,
        // ),
        ghb(15),
        SizedBox(
          width: (168 - 8 * 2).w,
          child: getRichText(
              "${isReal ? "￥" : ""}${priceFormat(cellData["nowPrice"] ?? 0)}",
              "起",
              18,
              AppColor.integralTextRed,
              12,
              AppColor.integralTextRed,
              fw: AppDefault.fontBold),
        ),
        ghb(10),
      ],
    );
  }

  Widget listCell() {
    return ProductListCell(
      cellData: cellData,
    );
  }
}
