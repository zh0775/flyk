import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class MyTeamPolicyChangeController extends GetxController {
  String selectType = "";
  int typeIndex = -1;
  int policyIndex = -1;

  Map selectData = {
    "type": [
      // {"name":"电签",""},
      "电签",
      "大POS",
    ],
    "policy": [
      "电签0.6%服务费版",
      "电签0.6%免服务费版",
      "电签0.6%+3服务费抵押版",
      "MINI电签0.6%+3服务费抵押版"
    ]
  };

  void setSelectType() {
    selectType =
        "${selectData["type"][typeIndex < 0 ? 0 : typeIndex]}${selectData["policy"][policyIndex < 0 ? 0 : policyIndex]}";
    update();
  }
}

class MyTeamPolicyChange extends StatelessWidget {
  const MyTeamPolicyChange({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "政策修改"),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 100.w,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ghb(15),
                    GetBuilder<MyTeamPolicyChangeController>(
                      init: MyTeamPolicyChangeController(),
                      builder: (ctrl) {
                        return GestureDetector(
                          onTap: () {
                            _showFilter(context, ctrl);
                          },
                          child: Container(
                            width: 345.w,
                            height: 50.w,
                            decoration: getDefaultWhiteDec(),
                            child: Column(
                              children: [
                                sbhRow([
                                  getSimpleText(
                                      ctrl.selectType != null &&
                                              ctrl.selectType.isNotEmpty
                                          ? ctrl.selectType
                                          : "选择机具类型",
                                      15,
                                      AppColor.textBlack),
                                  assetsSizeImage(
                                      "common/icon_cell_right_arrow", 20, 20)
                                ], width: 345 - 17.5 * 2, height: 50),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    sectionView("激活返现", "奖励金返现", "积分奖励", "0元", "0积分"),
                    sectionView("达标返现", "达标现金返现", "积分奖励", "0元", "0积分"),
                    sectionView("达标返现", "达标现金返现", "积分奖励", "0元", "0积分"),
                    ghb(15)
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100.w,
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: getSubmitBtn(
                      "提交修改",
                      (() {}),
                    ),
                  ),
                ))
          ],
        ));
  }

  Widget sectionView(String t1, String t2, String t3, String v1, String v2) {
    return SizedBox(
      width: 345.w,
      height: 150.w,
      child: Column(
        children: [
          sbhRow([getSimpleText(t1, 16, AppColor.textBlack, isBold: true)],
              width: (345 - 17.5 * 2).w, height: 50),
          Container(
            width: 345.w,
            height: 50.w,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5))),
            child: Center(
              child: sbRow([
                getSimpleText(t2, 15, AppColor.textGrey2),
                getSimpleText(v1, 15, AppColor.textBlack),
              ], width: 345 - 17.5 * 2),
            ),
          ),
          Container(
            width: 345.w,
            height: 50.w,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5))),
            child: Center(
              child: sbRow([
                getSimpleText(t3, 15, AppColor.textGrey2),
                getSimpleText(v2, 15, AppColor.textBlack),
              ], width: 345 - 17.5 * 2),
            ),
          )
        ],
      ),
    );
  }

  void _showFilter(
      BuildContext context, MyTeamPolicyChangeController ctrl) async {
    Future bottomModel = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modelBottomCtx) {
        return StatefulBuilder(
          builder: (context, setModalBottomState) {
            return SizedBox(
              width: 375.w,
              height: (530 + 57).w,
              child: Stack(
                children: [
                  Positioned(
                      right: 24.w,
                      top: 0,
                      width: 37.w,
                      height: 37.w,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(modelBottomCtx);
                        },
                        icon: const Icon(
                          Icons.highlight_off,
                          size: 37,
                          color: Colors.white,
                        ),
                      )),
                  Positioned(
                      right: 33.75.w,
                      top: 39.w,
                      child: Container(
                        width: 1.5.w,
                        height: 20.w,
                        color: Colors.white,
                      )),
                  Positioned(
                      top: 57.w,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: const Color(0xFFEBEBEB),
                        padding: EdgeInsets.only(left: 15.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ghb(19.5),
                            getSimpleText("其他筛选", 20, AppColor.textBlack,
                                isBold: true),
                            ghb(19.5),
                            gline(345, 0.5),
                            ghb(10),
                            SizedBox(
                              width: 325.w,
                              child: Row(
                                children: [
                                  getSimpleText("类别", 17, AppColor.textBlack),
                                ],
                              ),
                            ),
                            ghb(10),
                            _buildPolicyButton(ctrl.selectData["type"], true,
                                setModalBottomState, ctrl),
                            ghb(24),
                            SizedBox(
                              width: 325.w,
                              child: Row(
                                children: [
                                  getSimpleText("政策", 17, AppColor.textBlack),
                                ],
                              ),
                            ),
                            ghb(10),
                            _buildPolicyButton(ctrl.selectData["policy"], false,
                                setModalBottomState, ctrl),
                          ],
                        ),
                      )),
                  Positioned(
                      left: 15.w,
                      bottom: 29.w,
                      child: CustomButton(
                        onPressed: () {
                          ctrl.setSelectType();
                          Navigator.pop(modelBottomCtx);
                        },
                        child: Container(
                          width: 345.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color(0xFF4282EB)),
                          child: Center(
                            child: getSimpleText("确定", 15, Colors.white,
                                isBold: true),
                          ),
                        ),
                      ))
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPolicyButton(List list, bool isTypeOrPolicy,
      StateSetter setModalBottomState, MyTeamPolicyChangeController ctrl) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.w,
      children: list.map((e) {
        return CustomButton(
          onPressed: () {
            int idx = list.indexOf(e);
            if (isTypeOrPolicy && idx != ctrl.typeIndex) {
              setModalBottomState(() {
                ctrl.typeIndex = idx;
              });
            } else if (!isTypeOrPolicy && idx != ctrl.policyIndex) {
              setModalBottomState(() {
                ctrl.policyIndex = idx;
              });
            }

            // setModalBottomState(() {
            //   // e["selected"] = !e["selected"];
            // });
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.w),
                color: isTypeOrPolicy
                    ? (list.indexOf(e) == ctrl.typeIndex
                        ? const Color(0xFF5290F2)
                        : Colors.white)
                    : list.indexOf(e) == ctrl.policyIndex
                        ? const Color(0xFF5290F2)
                        : Colors.white),
            // color: Colors.white),
            child: Padding(
              padding: EdgeInsets.fromLTRB(22.w, 12.w, 22.w, 12.w),
              child: getSimpleText(
                  e,
                  14,
                  isTypeOrPolicy
                      ? (list.indexOf(e) == ctrl.typeIndex
                          ? Colors.white
                          : AppColor.textBlack)
                      : list.indexOf(e) == ctrl.policyIndex
                          ? Colors.white
                          : AppColor.textBlack),
            ),
          ),
        );
      }).toList(),
    );
  }
}
