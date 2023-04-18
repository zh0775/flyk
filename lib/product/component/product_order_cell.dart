import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductOrderCell extends StatefulWidget {
  final int index;
  final Map? cellData;
  final int? defaultCount;
  final String? errText;
  final String? name;
  final String? dec;
  final String? imgSrc;
  final int maxCount;
  final String? price;
  final bool isReal;
  final String unit;
  final Function(int count, int idx, {bool? isAdd})? changeCountAction;
  final bool haveCount;
  final bool inputCount;
  const ProductOrderCell(
      {Key? key,
      this.index = 0,
      this.cellData,
      this.name,
      this.price,
      this.imgSrc,
      this.dec,
      this.unit = "",
      this.isReal = true,
      this.defaultCount = 1,
      this.errText,
      this.maxCount = 100,
      this.haveCount = true,
      this.inputCount = false,
      this.changeCountAction})
      : super(key: key);

  @override
  State<ProductOrderCell> createState() => _ProductOrderCellState();
}

class _ProductOrderCellState extends State<ProductOrderCell> {
  TextEditingController countInputCtrl = TextEditingController();
  late StreamSubscription<bool> keyboardSubscription;
  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      // print('Keyboard visibility update. Is visible: $visible');
      if (!visible && widget.changeCountAction != null) {
        if (int.tryParse(countInputCtrl.text) == null) {
          ShowToast.normal("请输入正确的数字");
          countInputCtrl.text = "${widget.defaultCount}";
          return;
        }
        widget.changeCountAction!(int.parse(countInputCtrl.text), widget.index);
      }
    });
    countInputCtrl.text = "${widget.defaultCount}";
  }

  @override
  void didUpdateWidget(covariant ProductOrderCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    countInputCtrl.text = "${widget.defaultCount}";
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    countInputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: EdgeInsets.only(
            top: 15.w, left: 10.5.w, right: 10.5.w, bottom: 10.w),
        child: Column(
          children: [
            Row(
              children: [
                Visibility(
                  visible: widget.imgSrc != null && widget.imgSrc!.isNotEmpty,
                  child: CustomNetworkImage(
                    src: AppDefault().imageUrl + (widget.imgSrc ?? ""),
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.contain,
                  ),
                ),
                gwb(28),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getWidthText(
                        widget.name ?? "", 16, AppColor.textBlack, 192, 1),
                    getWidthText(
                        widget.dec ?? "", 13, const Color(0xFF999999), 192, 3),
                    ghb(15),
                    Visibility(
                        visible: widget.price != null,
                        child: getRichText(
                            "${widget.isReal ? "¥" : ""}${widget.price ?? ""}",
                            widget.unit,
                            18,
                            const Color(0xFFF13030),
                            14,
                            AppColor.textBlack))
                  ],
                )
              ],
            ),
            widget.haveCount
                ? centClm([
                    ghb(15),
                    gline(345 - 10.5 * 2, 0.5),
                    ghb(9),
                    sbhRow([
                      gwb(0),
                      centRow([
                        CustomButton(
                          onPressed: () {
                            if (widget.changeCountAction != null) {
                              widget.changeCountAction!(
                                  widget.defaultCount!, widget.index,
                                  isAdd: false);
                            }
                          },
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(5.w)),
                            child: Center(
                              child: Icon(
                                Icons.remove,
                                color: AppColor.textBlack,
                                size: 12.5.w,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 58.w,
                          child: Center(
                            child: widget.inputCount
                                ? CustomInput(
                                    width: 40.w,
                                    heigth: 30.w,
                                    textEditCtrl: countInputCtrl,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.number,
                                    placeholder: "数量",
                                  )
                                : getSimpleText("${widget.defaultCount ?? 1}",
                                    13, AppColor.textBlack),
                          ),
                        ),
                        CustomButton(
                          onPressed: () {
                            if (widget.changeCountAction != null) {
                              widget.changeCountAction!(
                                  widget.defaultCount!, widget.index,
                                  isAdd: true);
                            }
                          },
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(5.w)),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: AppColor.textBlack,
                                size: 12.5.w,
                              ),
                            ),
                          ),
                        ),
                      ])
                    ], width: 345 - 10.5 * 2, height: 30),
                  ])
                : sbRow([
                    gwb(0),
                    getSimpleText("数量x${widget.defaultCount ?? "1"}", 12,
                        const Color(0xFFB3B3B3))
                  ], width: 345 - 10.5 * 2)
          ],
        ),
      ),
    );
  }
}
