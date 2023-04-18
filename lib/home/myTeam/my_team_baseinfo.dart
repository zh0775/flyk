import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTeamBaseInfo extends StatelessWidget {
  final Map info;
  const MyTeamBaseInfo({Key? key, this.info = const {}}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "基本信息"),
        body: Stack(
          children: [
            Positioned(
              top: 24.w,
              left: 15.w,
              right: 15.w,
              child: Container(
                width: 345.w,
                constraints: const BoxConstraints(minHeight: 0),
                decoration: getDefaultWhiteDec(),
                child: Column(
                  children: [
                    ghb(35),
                    getSimpleText("真实姓名", 16, AppColor.textGrey),
                    ghb(15),
                    infoContent(info["u_Name"] ?? ""),
                    ghb(35),
                    getSimpleText("手机号", 16, AppColor.textGrey),
                    ghb(12),
                    infoContent(info["u_Mobile"] ?? ""),
                    ghb(35),
                    getSimpleText("邀请码", 16, AppColor.textGrey),
                    ghb(15),
                    infoContent(info["yqCode"] ?? ""),
                    ghb(35),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget infoContent(String t1) {
    return Container(
      width: (345 - 15 * 2).w,
      height: 50.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: getSimpleText(t1, 16, AppColor.textBlack),
      ),
    );
  }
}
