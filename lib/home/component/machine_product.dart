import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/product/component/product_list_cell.dart';
import 'package:cxhighversion2/product/product.dart';
import 'package:cxhighversion2/product/product_purchase_detail.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MachineProduct extends StatelessWidget {
  final List productData;
  const MachineProduct({Key? key, this.productData = const []})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.w, 16, 10.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getSimpleText("机具产品", 17, AppColor.textBlack),
            ghb(10),
            gwb(325),
            ...productData
                .asMap()
                .entries
                .map(
                  (e) => cell(e.key, e.value),
                )
                .toList(),
            CustomButton(
              onPressed: () {
                push(
                    const Product(
                      subPage: true,
                    ),
                    context,
                    binding: ProductBinding());
              },
              child: SizedBox(
                width: 325.w,
                height: 45.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getSimpleText("查看全部", 13, AppColor.textGrey),
                    SizedBox(
                      width: 8.sp,
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColor.textGrey,
                      size: 20.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cell(int index, Map data) {
    return CustomButton(
        onPressed: () {
          push(
              ProductPurchaseDetail(
                productData: data,
              ),
              null,
              binding: ProductPurchaseDetailBinding());
        },
        child: ProductListCell(
          cellData: data,
          haveBottomLine: true,
        ));
  }
}
