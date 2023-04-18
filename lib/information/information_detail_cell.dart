import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InformationDetailCell extends StatelessWidget {
  final int infomationType;
  final Map infoData;
  final bool isMonth;
  const InformationDetailCell(
      {Key? key,
      this.infomationType = 0,
      this.infoData = const {},
      this.isMonth = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 375.w,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 50.w,
              width: 345.w,
              child: Align(
                alignment: Alignment.centerLeft,
                child: getRichText(
                    isMonth
                        ? "${addZero(infoData["year"])}/"
                        : "${addZero(infoData["year"])}/${addZero(infoData["month"])}/",
                    isMonth
                        ? addZero(infoData["month"])
                        : addZero(infoData["day"]),
                    14,
                    AppColor.textBlack,
                    20,
                    AppColor.textBlack,
                    fw2: AppDefault.fontBold),
              ),
            ),
            gline(345, 0.5),
            cells(infomationType, infoData),
          ],
        ));
  }

  Widget cells(int type, Map data) {
    switch (type) {
      case 0:
        return type0(data);
      case 1:
        return type1(data);
      case 2:
        return type2(data);
      case 3:
        return type3(data);
      default:
    }
    return gwb(0);
  }

  Widget type0(Map data) {
    return Column(
      children: [
        ghb(20),
        jyCell("全部交易金额", "¥${priceFormat(data["tolTraN"] ?? 0)}"),
        jyCell("全部交易笔数", "${data["tolTraC"] ?? 0}"),
        jyCell("贷记卡交易额", "¥${priceFormat(data["traType1"] ?? 0)}"),
        jyCell("借记卡交易额", "¥${priceFormat(data["traType2"] ?? 0)}"),
        jyCell("其他交易额", "¥${priceFormat(data["traType3"] ?? 0)}"),
        ghb(20),
        gline(345, 0.5),
      ],
    );
  }

  Widget jyCell(String t1, String t2) {
    return sbhRow([
      getSimpleText(t1, 14, AppColor.textGrey2),
      getSimpleText(t2, 14, AppColor.textBlack, isBold: true)
    ], height: 40, width: 345);
  }

  Widget type1(Map data) {
    return Column(
      children: [
        ghb(20),
        jyCell("累计激活台数", "${data["tolActivC"] ?? 0}台"),
        ghb(20),
        gline(345, 0.5),
      ],
    );
  }

  Widget type2(Map data) {
    return Column(
      children: [
        ghb(20),
        jyCell("累计新增商户", "${data["tolBindC"] ?? 0}户"),
        ghb(20),
        gline(345, 0.5),
      ],
    );
  }

  Widget type3(Map data) {
    return Column(
      children: [
        ghb(20),
        jyCell("累计新增伙伴", "${data["tolPartnerC"] ?? 0}人"),
        ghb(20),
        gline(345, 0.5),
      ],
    );
  }
}
