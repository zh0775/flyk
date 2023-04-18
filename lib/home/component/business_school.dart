import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/businessSchool/business_school_detail.dart';
import 'package:cxhighversion2/home/businessSchool/business_school_page.dart';
import 'package:cxhighversion2/home/component/business_school_list.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BusinessSchoolBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessSchoolController>(() => BusinessSchoolController());
  }
}

class BusinessSchoolController extends GetxController {}

class BusinessSchool extends GetView<BusinessSchoolController> {
  final List bcListData;
  const BusinessSchool({Key? key, this.bcListData = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.w, 16.w, 10.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getSimpleText("商学院", 17, AppColor.textBlack),
            ghb(10),
            ...bcListData
                .asMap()
                .entries
                .map(
                  (e) => businessCell(e.key, e.value),
                )
                .toList(),
            ghb(5),
            CustomButton(
              onPressed: () {
                push(const BusinessSchoolPage(), context,
                    binding: BusinessSchoolPageBinding());
              },
              child: SizedBox(
                width: 325.w,
                height: 45.5.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getSimpleText("查看全部", 13, AppColor.textGrey),
                    gwb(8),
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

  Widget businessCell(int index, Map data) {
    return CustomButton(
      onPressed: () {
        push(
            BusinessSchoolDetail(
              id: data["id"] ?? 0,
            ),
            null,
            binding: BusinessSchoolDetailBinding());
      },
      child: centClm([
        ghb(17.5),
        sbRow([
          CustomNetworkImage(
            src: AppDefault().imageUrl + (data["coverImages"] ?? ""),
            width: 115.w,
            height: 80.w,
            fit: BoxFit.fill,
          ),
          centClm([
            getContentText(
                data["title"] ?? "", 15, AppColor.textBlack, 176, 53, 2,
                alignment: Alignment.topLeft),
            ghb(3),
            getSimpleText("浏览：${data["view"] ?? 0}", 12, AppColor.textGrey),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ], width: 345 - 10 * 2),
        ghb(15),
        gline(325, 0.5),
      ]),
    );
  }
}
