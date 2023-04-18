import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IntegralCell extends StatelessWidget {
  final int? type;
  final Map? cellData;
  const IntegralCell({Key? key, this.type = 1, this.cellData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 159.w,
      height: 240.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(5),
      ),
      child: cellData!["type"] == 0
          ? Stack(
              children: [
                Positioned.fill(
                    child: Image.asset(
                  cellData!["img"],
                  width: 159.w,
                  height: 240.w,
                  fit: BoxFit.fill,
                )),
                Positioned(
                    left: 36.w,
                    bottom: 11.5,
                    width: 86.5.w,
                    height: 26,
                    child: CustomButton(
                      onPressed: () {},
                      child: Container(
                        width: 86.5.w,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9453),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: getSimpleText("立即查看", 13, Colors.white),
                        ),
                      ),
                    ))
              ],
            )
          : Column(
              children: [
                SizedBox(
                  width: 159.w,
                  height: 159.w,
                  child: Image.asset(
                    cellData!["img"],
                    width: 159.w,
                    height: 159.w,
                    fit: BoxFit.fill,
                  ),
                ),
                ghb(5),
                getWidthText(cellData!["title"] ?? "", 13, AppColor.textBlack,
                    159 - 10 * 2, 2),
                ghb(3),
                sbRow([
                  getSimpleText("积分：${cellData!["integral"]}", 13,
                      const Color(0xFFFF6326)),
                ], width: 159 - 10 * 2),
              ],
            ),
    );
  }
}
