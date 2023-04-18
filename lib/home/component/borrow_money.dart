import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BorrowMoney extends StatelessWidget {
  final Function()? checkLimitClick;
  const BorrowMoney({Key? key, this.checkLimitClick}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 345.w,
        height: 213.5,
        decoration: getDefaultWhiteDec(),
        child: Center(
          child: SizedBox(
            width: 327.w,
            height: 184.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(5.w, 5, 0, 0),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/home/icon_borrow.png",
                        width: 20.w,
                        height: 20.w,
                        fit: BoxFit.fill,
                      ),
                      gwb(8),
                      getSimpleText("满意借-灵活借还", 15, AppColor.textBlack,
                          isBold: true),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getSimpleText(
                              "最高可借额度(元)", 12, const Color(0xFFB3B3B3)),
                          getSimpleText("300,000", 30, const Color(0xFF3782FF)),
                        ],
                      ),
                      CustomButton(
                        onPressed: () {
                          if (checkLimitClick != null) {
                            checkLimitClick!();
                          }
                        },
                        child: Container(
                          width: 105.w,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17.5),
                              color: const Color(0xFF3782FF)),
                          child: Center(
                            child: getSimpleText("查看我的额度", 13, Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: 327.w,
                  height: 76,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FC),
                      borderRadius: BorderRadius.circular(2)),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: [
                      tipsWidget("单次额度 可重复申请"),
                      tipsWidget("最低日息0.01%"),
                      tipsWidget("最长分36期还"),
                      tipsWidget("次日可提前结清"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget tipsWidget(String name) {
    return SizedBox(
      width: (327.w - 12.5.w * 2) / 2,
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF6D717D),
            size: 18,
          ),
          gwb(5),
          getSimpleText(name, 12, const Color(0xFF6D717D))
        ],
      ),
    );
  }
}
