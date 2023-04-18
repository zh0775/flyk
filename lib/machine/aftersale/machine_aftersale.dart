import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/machine/aftersale/machine_aftersale_apply.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MachineAftersale extends StatelessWidget {
  final Map orderData;
  final int aftersaleIndex;
  const MachineAftersale({
    super.key,
    this.orderData = const {},
    this.aftersaleIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "选择售后类型"),
      body: Column(
        children: [
          gwb(375),
          ghb(15),
          cell(0),
          ghb(15),
          cell(1),
        ],
      ),
    );
  }

  Widget cell(int index) {
    return CustomButton(
      onPressed: () {
        Map arguments = {
          "orderData": orderData,
          "type": index,
          "index": aftersaleIndex
        };
        push(const MachineAftersaleApply(), null,
            binding: MachineAftersaleApplyBinding(), arguments: arguments);
      },
      child: Container(
        width: 345.w,
        height: 75.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: Center(
          child: sbhRow([
            centRow([
              gwb(5),
              Image.asset(
                assetsName("machine/icon_sh_${index == 0 ? "change" : "back"}"),
                width: 30.w,
                fit: BoxFit.fitWidth,
              ),
              gwb(10),
              centClm([
                getSimpleText(
                    "我要${index == 0 ? "换" : "退"}货", 15, AppColor.text),
                ghb(1),
                getSimpleText(index == 0 ? "使用旧设备换购新设备" : "已收到货，需要原路退还设备", 12,
                    AppColor.text3)
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ]),
            Image.asset(
              assetsName("statistics/icon_arrow_right_gray"),
              width: 18.w,
              fit: BoxFit.fitWidth,
            )
          ], width: 345 - 10 * 2, height: 75),
        ),
      ),
    );
  }
}
