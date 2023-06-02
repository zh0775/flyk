import 'package:cxhighversion2/service/http_config.dart';
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
    if (pData.isNotEmpty) {
      publicHomeData = pData;
    } else {
      publicHomeData = AppDefault().publicHomeData;
    }

    bool haveData = false;
    String appName = "";
    String subTitle = "";
    Map webSiteInfo = publicHomeData["webSiteInfo"] ?? {};
    if (HttpConfig.baseUrl.contains(AppDefault.oldSystem)) {
      haveData = publicHomeData.isNotEmpty &&
          webSiteInfo.isNotEmpty &&
          webSiteInfo["System_Home_Name"] != null &&
          webSiteInfo["System_Home_Name"].isNotEmpty &&
          webSiteInfo["System_Home_SubTitle"] != null &&
          webSiteInfo["System_Home_SubTitle"].isNotEmpty;
      appName = haveData ? webSiteInfo["System_Home_Name"] : "";
      subTitle = haveData ? webSiteInfo["System_Home_SubTitle"] : "";
    } else {
      Map app = webSiteInfo["app"] ?? {};
      haveData = app.isNotEmpty &&
          app["apP_Name"] != null &&
          app["apP_Name"].isNotEmpty &&
          app["apP_SubTitle"] != null &&
          app["apP_SubTitle"].isNotEmpty;
      appName = haveData ? app["apP_Name"] : "";
      subTitle = haveData ? app["apP_SubTitle"] : "";
    }

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
