import 'package:flutter/material.dart';
import 'package:cxhighversion2/home/component/business_school_cell.dart';

class BusinessSchoolList extends StatefulWidget {
  final List bcListData;
  const BusinessSchoolList({Key? key, this.bcListData = const []})
      : super(key: key);

  @override
  State<BusinessSchoolList> createState() => _BusinessSchoolListState();
}

class _BusinessSchoolListState extends State<BusinessSchoolList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.bcListData != null ? widget.bcListData.length : 0,
      itemBuilder: (context, index) {
        return BusinessSchoolCell(
          cellData: widget.bcListData[index],
          index: index,
        );
      },
    );
  }
}
