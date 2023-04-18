import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'package:get/get.dart';

// class BusinessSchoolCellController extends GetxController {}

class BusinessSchoolCell extends StatelessWidget {
  final Map cellData;
  final int index;
  final int type;
  final bool topLine;
  final bool bottomLine;
  final double width;
  final double? marginFirstTop;
  final Function(int type, int index, Map cellData)? onPressed;
  const BusinessSchoolCell({
    Key? key,
    this.cellData = const {},
    this.index = 0,
    this.type = 0,
    this.bottomLine = false,
    this.topLine = false,
    this.width = 325,
    this.marginFirstTop,
    this.onPressed,
  }) : super(key: key);
  // BusinessSchoolCellController controller = BusinessSchoolCellController();
  @override
  Widget build(BuildContext context) {
    return Align(
      child: CustomButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed!(type, index, cellData);
          }
        },
        child: Container(
            decoration: getDefaultWhiteDec2(),
            margin: EdgeInsets.only(
                top: marginFirstTop ?? (index != 0 ? 14.5.w : 0)),
            width: width.w,
            height: (112 + (topLine ? 0.5 : 0) + (bottomLine ? 0.5 : 0)).w,
            child: Column(
              children: [
                topLine ? gline(325, 0.5) : ghb(0),
                sbhRow([
                  SizedBox(
                      width: 115.w,
                      height: 80.w,
                      child: Stack(children: [
                        Positioned.fill(
                            child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.w),
                          child: CustomNetworkImage(
                            src: AppDefault().imageUrl +
                                (cellData["coverImg"] ?? ""),
                            width: 115.w,
                            height: 80.w,
                            fit: BoxFit.fill,
                          ),
                        )),
                        Align(
                          alignment: Alignment.center,
                          child: cellData["type"] == 0
                              ? Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 40.w,
                                )
                              : const SizedBox(),
                        ),
                        // Positioned.fill(
                        //     child: Container(
                        //   color: Colors.red,
                        // ))
                      ])),
                  centClm([
                    getContentText(cellData["title"] ?? "", 15,
                        AppColor.textBlack, 179, 53, 2,
                        alignment: Alignment.topLeft),
                    getSimpleText(
                        "浏览：${cellData["view"] ?? "0"}", 12, AppColor.textGrey),
                  ], crossAxisAlignment: CrossAxisAlignment.start)
                ], width: width - 15 * 2, height: 112),
                bottomLine ? gline(width - 15 * 2, 0.5) : ghb(0),
              ],
            )),
      ),
    );
  }
}
