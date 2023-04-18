import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBottomTips extends StatelessWidget {
  // final String? appName;
  final Map pData;
  const AppBottomTips({Key? key, this.pData = const {}}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map publicHomeData = {};
    if (pData != null && pData.isNotEmpty) {
      publicHomeData = pData;
    } else {
      publicHomeData = AppDefault().publicHomeData;
    }

    bool haveData = publicHomeData != null &&
        publicHomeData["webSiteInfo"] != null &&
        publicHomeData["webSiteInfo"]["app"] != null &&
        publicHomeData["webSiteInfo"]["app"]["apP_Name"] != null &&
        publicHomeData["webSiteInfo"]["app"]["apP_Name"].isNotEmpty &&
        publicHomeData["webSiteInfo"]["app"]["apP_SubTitle"] != null &&
        publicHomeData["webSiteInfo"]["app"]["apP_SubTitle"].isNotEmpty;
    String appName =
        haveData ? publicHomeData["webSiteInfo"]["app"]["apP_Name"] : "";
    String subTitle =
        haveData ? publicHomeData["webSiteInfo"]["app"]["apP_SubTitle"] : "";
    return SizedBox(
      width: 375.w,
      // height: 40,
      child: Visibility(
        visible: publicHomeData != null && publicHomeData.isNotEmpty,
        child: Column(
          children: [
            getSimpleText(appName, 14, AppColor.text3),
            ghb(haveData ? 3 : 0),
            haveData
                ? centRow([
                    gline(21, 1, color: AppColor.text3),
                    gwb(6.5),
                    getSimpleText(subTitle, 12, AppColor.text3),
                    gwb(5),
                    gline(21, 1, color: AppColor.text3),
                  ])
                : ghb(0),
            // ghb(haveData ? 3 : 0),
            // getSimpleText(
            //     "$appName是一款帮助代理提升客户管理的APP", 13, const Color(0xFF8E9199)),
            ghb(haveData ? (kIsWeb ? 30 : 57) : 0)
          ],
        ),
      ),
    );
  }
}
