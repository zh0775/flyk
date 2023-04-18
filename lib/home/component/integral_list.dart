import 'package:flutter/material.dart';
import 'package:cxhighversion2/home/component/integral_cell.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IntegralList extends StatelessWidget {
  final List? integraListData;
  const IntegralList({Key? key, this.integraListData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 6.sp,
        runSpacing: 10,
        children: integraListData!.map((e) {
          return IntegralCell(
            cellData: e,
          );
        }).toList());
  }
}
