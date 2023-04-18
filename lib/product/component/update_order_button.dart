import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpdateOrderButton extends StatefulWidget {
  final String? warningStr;
  final Map productData;
  final int? count;
  final String? buttonTitle;
  final double? price;
  final String? unit;
  final String? yfUnit;
  final Function()? confirmAndUpdateOrder;
  final double? freight;
  final bool enable;
  const UpdateOrderButton(
      {Key? key,
      required this.productData,
      this.warningStr,
      this.count,
      this.price,
      this.unit = "元",
      this.yfUnit = "元",
      this.buttonTitle,
      this.freight,
      this.confirmAndUpdateOrder,
      this.enable = true})
      : super(key: key);

  @override
  State<UpdateOrderButton> createState() => _UpdateOrderButtonState();
}

class _UpdateOrderButtonState extends State<UpdateOrderButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 375.w,
      height: widget.warningStr != null && widget.warningStr!.isNotEmpty
          ? 125.w
          : 155.w,
      child: Column(
        children: [
          widget.warningStr != null && widget.warningStr!.isNotEmpty
              ? Container(
                  width: 375.w,
                  height: 30.w,
                  color: const Color(0xFFFFE7E9),
                  child: Center(
                    child: getSimpleText(
                        widget.warningStr!, 12, const Color(0xFFF96A75)),
                  ),
                )
              : const SizedBox(),
          SizedBox(
            width: 375.w,
            height: 125.w,
            child: Stack(
              children: [
                Positioned.fill(
                    child: Column(
                  children: [
                    ghb(12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widget.freight == -1.0
                              ? gwb(0)
                              : Text.rich(TextSpan(
                                  text:
                                      "邮费：${widget.freight == 0 || widget.freight == null ? "包邮" : widget.freight}",
                                  style: TextStyle(
                                      color: AppColor.textBlack,
                                      fontSize: 12.sp),
                                  children: [
                                      TextSpan(
                                          // text: "${widget.count}",
                                          text:
                                              "${widget.freight == 0.0 || widget.freight == null ? "" : widget.freight!.ceil()}",
                                          style: TextStyle(
                                              color: const Color(0xFF3782FF),
                                              fontSize: 20.sp)),
                                      TextSpan(
                                          text: widget.freight != null &&
                                                  widget.freight! > 0
                                              ? widget.yfUnit
                                              : "",
                                          style: TextStyle(
                                              color: AppColor.textBlack,
                                              fontSize: 12.sp)),
                                    ])),
                          Visibility(
                              visible: widget.price != null,
                              child: Text.rich(TextSpan(
                                  text: "总计",
                                  style: TextStyle(
                                      color: AppColor.textBlack,
                                      fontSize: 12.sp),
                                  children: [
                                    TextSpan(
                                        // text: "${widget.count! * widget.price!}",
                                        // text: priceFormat(widget.productData["nowPrice"]),
                                        text: priceFormat(widget.price),
                                        style: TextStyle(
                                            color: const Color(0xFFF13030),
                                            fontSize: 20.sp)),
                                    TextSpan(
                                        text: widget.unit ?? "元",
                                        style: TextStyle(
                                            color: AppColor.textBlack,
                                            fontSize: 12.sp)),
                                  ])))
                        ],
                      ),
                    ),
                  ],
                )),
                Align(
                  alignment: Alignment.center,
                  child: getSubmitBtn(widget.buttonTitle ?? "提交订单", () {
                    if (widget.confirmAndUpdateOrder != null) {
                      widget.confirmAndUpdateOrder!();
                    }
                  }, enable: widget.enable),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
