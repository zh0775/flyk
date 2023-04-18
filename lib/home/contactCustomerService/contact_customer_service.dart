import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/contactCustomerService/contact_order_list.dart';
import 'package:cxhighversion2/mine/mine_feedback.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class ContactCustomerServiceBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ContactCustomerServiceController>(
        ContactCustomerServiceController(datas: Get.arguments));
  }
}

class ContactCustomerServiceController extends GetxController {
  final dynamic datas;
  ContactCustomerServiceController({this.datas});

  List dataList = [];

  loadList() {
    simpleRequest(
      url: Urls.userHelpList(7),
      params: {},
      success: (success, json) {
        dataList = json["data"] ?? [];
        update();
      },
      after: () {},
      useCache: true,
    );
  }

  @override
  void onInit() {
    loadList();
    super.onInit();
  }
}

class ContactCustomerService extends GetView<ContactCustomerServiceController> {
  const ContactCustomerService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "客服中心"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              width: 375.w,
              height: 266.w,
              child: Stack(children: [
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 210.w,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(assetsName("mine/bg_top_kf")))),
                      child: Column(
                        children: [
                          ghb(35),
                          sbRow([
                            centClm([
                              getSimpleText("Hi,您好", 21, Colors.white,
                                  isBold: true),
                              ghb(8),
                              getSimpleText("很高兴能为您提供帮助！", 15, Colors.white)
                            ], crossAxisAlignment: CrossAxisAlignment.start)
                          ], width: 375 - 31 * 2)
                        ],
                      ),
                    )),
                Positioned(
                    left: 15.w,
                    right: 15.w,
                    bottom: 0,
                    height: 150.w,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.w)),
                      child: Column(
                        children: [
                          sbhRow([
                            getSimpleText("自助服务", 18, AppColor.text,
                                isBold: true)
                          ], height: 53, width: 345 - 17 * 2),
                          ghb(3.5),
                          sbRow([
                            SizedBox(
                              width: 134.w,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(2, (index) {
                                  return CustomButton(
                                    onPressed: () {
                                      if (index == 0) {
                                        push(const ContactOrderList(), context,
                                            binding: ContactOrderListBinding());
                                      } else {
                                        push(const MineFeedback(), context,
                                            binding: MineFeedbackBinding());
                                      }
                                    },
                                    child: Center(
                                      child: centClm([
                                        Image.asset(
                                          assetsName(
                                              "mine/btn_kf_${index == 0 ? "wdgd" : "yjfk"}"),
                                          width: 45.w,
                                          fit: BoxFit.fitWidth,
                                        ),
                                        ghb(10),
                                        getSimpleText(
                                            index == 0 ? "我的工单" : "意见反馈",
                                            12,
                                            AppColor.text2)
                                      ]),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ], width: 345 - 17 * 2),
                        ],
                      ),
                    )),
              ]),
            ),
            ghb(15),
            Container(
              width: 345.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.w)),
              child: GetBuilder<ContactCustomerServiceController>(builder: (_) {
                return Column(
                  children: [
                    sbhRow([
                      getSimpleText("常见问题", 18, AppColor.text, isBold: true),
                    ], width: 345 - 16 * 2, height: 55),
                    gline(345, 1),
                    ...List.generate(controller.dataList.length, (index) {
                      Map data = controller.dataList[index];
                      return CustomButton(
                        onPressed: () {
                          Get.to(
                              ContactCustomerServiceContent(
                                content: data["content"] ?? "",
                                name: data["name"] ?? "",
                              ),
                              transition: Transition.downToUp);
                        },
                        child: sbhRow([
                          Padding(
                              padding: EdgeInsets.only(left: 5.5.w),
                              child: getSimpleText(
                                  data["name"], 15, AppColor.text2)),
                          Image.asset(
                            assetsName("statistics/icon_arrow_right_gray"),
                            width: 18.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ], width: 345 - 9.5 * 2, height: 55),
                      );
                    })
                  ],
                );
              }),
            ),
            ghb(20),
          ],
        ),
      ),
    );
  }
}

class ContactCustomerServiceContent extends StatelessWidget {
  final String content;
  final String name;

  const ContactCustomerServiceContent(
      {super.key, this.content = "", this.name = ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "问题详情",
          leading: CustomButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: centRow([
              defaultBackButtonView(),
              getSimpleText("关闭", 14, AppColor.text2, textHeight: 1.5)
            ]),
          ),
          leadingWidth: 80.w),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: 375.w,
              color: Colors.white,
              constraints: BoxConstraints(minHeight: 300.w),
              child: Column(
                children: [
                  gwb(375),
                  ghb(18),
                  getWidthText(name, 15, AppColor.text, 345, 10, isBold: true),
                  ghb(18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: HtmlWidget(content),
                  ),
                  ghb(50)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
