import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/component/recent_data_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum RecentDataType { team, personally }

class RecentData extends StatefulWidget {
  final Map data;
  final RecentDataType? recentDataType;

  const RecentData(
      {Key? key,
      this.recentDataType = RecentDataType.personally,
      this.data = const {}})
      : super(key: key);

  @override
  State<RecentData> createState() => _RecentDataState();
}

class _RecentDataState extends State<RecentData> {
  int buttonIdx = 0;
  bool showData = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.w,
      // height: 275.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.w), color: Colors.white),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(15.w, 18.w, 0, 0),
            child: Row(
              children: [
                getSimpleText(
                    "${widget.recentDataType == RecentDataType.team ? "团队" : "个人"}近期数据",
                    17,
                    AppColor.textBlack,
                    isBold: true),
                gwb(10),
                CustomButton(
                  onPressed: () {
                    setState(() {
                      showData = !showData;
                    });
                  },
                  child: Image.asset(
                    "assets/images/login/icon_${showData ? "show" : "hide"}pwd.png",
                    width: 17.w,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          ),
          ghb(18),
          gline(335, 1),
          ghb(16.5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RecentDataButton(
                  index: 0,
                  title: "交易",
                  onPressed: buttonPressed,
                  active: buttonIdx == 0,
                ),
                RecentDataButton(
                  index: 1,
                  title: "激活",
                  onPressed: buttonPressed,
                  active: buttonIdx == 1,
                ),
                RecentDataButton(
                  index: 2,
                  title: "商户",
                  onPressed: buttonPressed,
                  active: buttonIdx == 2,
                ),
                RecentDataButton(
                  index: 3,
                  title: "伙伴",
                  onPressed: buttonPressed,
                  active: buttonIdx == 3,
                ),
              ],
            ),
          ),
          ghb(22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dataWidget("${getDatas()[0]}", "本月", titles()),
              gline(1, 45),
              dataWidget("${getDatas()[1]}", "上月", titles()),
            ],
          ),
          ghb(15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dataWidget("${getDatas()[2]}", "本日", titles()),
              gline(1, 45),
              dataWidget("${getDatas()[3]}", "昨日", titles()),
            ],
          ),
          ghb(20)
        ],
      ),
    );
  }

  void buttonPressed(idx) {
    if (buttonIdx != idx) {
      setState(() {
        buttonIdx = idx;
      });
    }
  }

  String titles() {
    switch (buttonIdx) {
      case 0:
        return "交易金额(元)";
      case 1:
        return "激活台数(台)";
      case 2:
        return "新增商户(户)";
      case 3:
        return "新增伙伴(人)";
      default:
        return "";
    }
  }

  List getDatas() {
    List datas = [];
    switch (buttonIdx) {
      case 0:
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? priceFormat(widget.data["teamThisMAmount"] ?? 0)
                : priceFormat(widget.data["soleThisMAmount"] ?? 0))
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? priceFormat(widget.data["teamLastMAmount"] ?? 0)
                : priceFormat(widget.data[" "] ?? 0))
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? priceFormat(widget.data["teamThisDAmount"] ?? 0)
                : priceFormat(widget.data["soleThisDAmount"] ?? 0))
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? priceFormat(widget.data["teamLastDAmount"] ?? 0)
                : priceFormat(widget.data["soleLastDAmount"] ?? 0))
            : "0");
        return datas;
      case 1:
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamThisMActTerminal"] ?? 0
                : widget.data["soleThisMActTerminal"] ?? 0)
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamLastMActTerminal"] ?? 0
                : widget.data["soleLastMActTerminal"] ?? 0)
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamThisDActTerminal"] ?? 0
                : widget.data["soleThisDActTerminal"] ?? 0)
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamLastDActTerminal"] ?? 0
                : widget.data["soleLastDActTerminal"] ?? 0)
            : "0");
        return datas;
      case 2:
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamThisMAddMerchant"] ?? 0
                : widget.data["soleThisMAddMerchant"] ?? 0)
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamLastMAddMerchant"] ?? 0
                : widget.data["soleLastMAddMerchant"] ?? 0)
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamThisDAddMerchant"] ?? 0
                : widget.data["soleThisDAddMerchant"] ?? 0)
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamLastDAddMerchant"] ?? 0
                : widget.data["soleLastDAddMerchant"] ?? 0)
            : "0");
        return datas;
      case 3:
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamThisMAddUser"] ?? 0
                : widget.data["soleThisMAddUser"] ?? 0)
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamLastMAddUser"] ?? 0
                : widget.data["soleLastMAddUser"] ?? 0)
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamThisDAddUser"] ?? 0
                : widget.data["soleThisDAddUser"] ?? 0)
            : "0");
        datas.add(widget.data.isNotEmpty
            ? (widget.recentDataType == RecentDataType.team
                ? widget.data["teamLastDAddUser"] ?? 0
                : widget.data["soleLastDAddUser"] ?? 0)
            : "0");
        return datas;
      default:
        return datas;
    }
  }

  Widget dataWidget(String data, String time, String sub) {
    return Container(
      margin: EdgeInsets.only(left: 12.w),
      width: 140.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getRichText(
            time,
            sub,
            12,
            AppColor.textBlack,
            12,
            AppColor.textGrey,
          ),
          ghb(13.5),
          getSimpleText(showData ? data : "******", 20, AppColor.textBlack,
              isBold: true)
        ],
      ),
    );
  }
}
