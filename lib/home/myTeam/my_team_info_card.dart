import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/myTeam/my_team_accountingrate_change.dart';
import 'package:cxhighversion2/home/myTeam/my_team_baseinfo.dart';
import 'package:cxhighversion2/home/myTeam/my_team_data.dart';
import 'package:cxhighversion2/home/myTeam/my_team_person_data.dart';
import 'package:cxhighversion2/home/myTeam/my_team_policy_change.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTeamInfoCard extends StatelessWidget {
  final bool isDirectly;
  final bool haveAuth;
  final Map infoData;
  const MyTeamInfoCard(
      {Key? key,
      this.haveAuth = true,
      this.isDirectly = true,
      this.infoData = const {}})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!haveAuth) {
      ShowToast.normal("还未认证");
    }
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 240.w + paddingSizeTop(context),
              child: Container(
                color: Colors.white,
              )),
          Positioned(
              top: paddingSizeTop(context),
              left: 0,
              width: 50.w,
              height: 50.w,
              child: CustomButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: Center(
                    child: Image.asset(
                      "assets/images/vip/btn_navi_back.png",
                      width: 50.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              )),
          Positioned(
              top: paddingSizeTop(context) + 50.w + 20.w,
              left: 22.w,
              right: 22.w,
              height: 170.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                        color: !haveAuth
                            ? const Color(0xFFA0A0A0)
                            : const Color(0xFF73C380),
                        borderRadius: BorderRadius.circular(2)),
                    child: Center(
                      child: getSimpleText(
                          haveAuth ? "已认证" : "未认证", 13, Colors.white),
                    ),
                  ),
                  ghb(10),
                  sbRow([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            getSimpleText(
                                infoData["u_Name"], 19, AppColor.textBlack,
                                isBold: true),
                            gwb(9),
                            Container(
                              width: 1.w,
                              height: 13.w,
                              color: AppColor.textGrey2,
                            ),
                            gwb(9),
                            getSimpleText(
                                infoData["u_Mobile"], 19, AppColor.textBlack,
                                isBold: true),
                          ],
                        ),
                        ghb(10),
                        getSimpleText("所属团队：${infoData["t_Name"]}", 15,
                            const Color(0xFF808080)),
                      ],
                    ),
                    // assetsSizeImage(infoData["img"], 65, 65),
                  ]),
                  ghb(23),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getSimpleText(
                              infoData["sU_Level"], 15, AppColor.textBlack,
                              isBold: true),
                          ghb(3),
                          getSimpleText("分润会员", 12, const Color(0xFF808080)),
                        ],
                      ),
                      gwb(25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getSimpleText(
                              infoData["sU_Level"], 15, AppColor.textBlack,
                              isBold: true),
                          ghb(3),
                          getSimpleText("礼包会员", 12, const Color(0xFF808080)),
                        ],
                      ),
                    ],
                  )
                ],
              )),
          Positioned(
            top: paddingSizeTop(context) + 50.w + 20.w + 170.w,
            left: 15.w,
            right: 15.w,
            bottom: 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  ghb(15),
                  SizedBox(
                    child: Wrap(
                      runSpacing: 15.w,
                      spacing: (375 - 30 - 167 * 2).w,
                      children: [
                        boxButton("pay/icon_equities", "个人数据", () {
                          push(const MyTeamPersonData(), context);
                        }),
                        boxButton("pay/icon_equities", "盟友数据", () {
                          push(MyTeamData(), context);
                        }),
                        boxButton("pay/icon_equities", "结算费率", () {
                          push(const MyTeamAccountingrateChange(), context,
                              binding: MyTeamAccountingrateChangeBinding());
                        }),
                        boxButton("pay/icon_equities", "政策修改", () {
                          push(const MyTeamPolicyChange(), context);
                        }),
                        boxButton("pay/icon_equities", "基本信息", () {
                          push(
                              MyTeamBaseInfo(
                                info: infoData,
                              ),
                              context);
                        }),
                      ],
                    ),
                  ),
                  ghb(20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget boxButton(String img, String name, Function() onPressed) {
    return CustomButton(
      onPressed: onPressed,
      child: Container(
        width: 167.w,
        height: 109.w,
        decoration: getDefaultWhiteDec(),
        child: Center(
          child: centClm([
            assetsSizeImage(img, 40, 40),
            ghb(20),
            getSimpleText(name, 15, AppColor.textBlack, isBold: true),
          ]),
        ),
      ),
    );
  }
}
