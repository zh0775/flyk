import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCell extends StatelessWidget {
  final int? index;
  final double? width;
  final double? height;
  final Widget? avatar;
  final Widget? title;
  final List<Widget>? subTitles;
  final bool? needRightArrow;
  final double? avatarPadding;
  final double? titleVSpace;
  final double? titleLeftPadding;
  final Color? bgColor;
  final BorderRadius? cellBorderRadius;
  final Function(int idx)? cellClick;

  const CustomCell({
    Key? key,
    this.index,
    this.width,
    this.height,
    this.avatar,
    this.title,
    this.avatarPadding,
    this.bgColor = Colors.white,
    this.cellBorderRadius,
    this.subTitles,
    this.needRightArrow = true,
    this.titleLeftPadding = 34.5,
    this.titleVSpace = 12.5,
    this.cellClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (cellClick != null) {
          cellClick!(index ?? -1);
        }
      },
      child: Container(
          width: width ?? 345.w,
          height: height ?? 100.w,
          decoration: BoxDecoration(
              color: bgColor ?? Colors.white,
              borderRadius: cellBorderRadius ?? BorderRadius.circular(5)),
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: [
                    gwb(avatarPadding ?? (avatar != null ? 23 : 0)),
                    avatar ?? const SizedBox(),
                    gwb(titleLeftPadding ?? 0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title ?? const SizedBox(),
                        ghb(titleVSpace ?? 0),
                        ...subTitleNullSafe(subTitles ?? []),
                      ],
                    ),
                  ],
                ),
              ),
              needRightArrow != null && needRightArrow!
                  ? Padding(
                      padding: EdgeInsets.only(right: 15.5.sp),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: assetsSizeImage(
                              "common/icon_cell_right_arrow", 20, 20)),
                    )
                  : const SizedBox(),
            ],
          )),
    );
  }

  List<Widget> subTitleNullSafe(List<Widget> wlist) {
    if (wlist != null) return wlist;
    return [const SizedBox()];
  }
}
