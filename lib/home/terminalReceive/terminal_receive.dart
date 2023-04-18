import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/terminalReceive/terminal_receive_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TerminalReceiveBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TerminalReceiveController>(TerminalReceiveController());
  }
}

class TerminalReceiveController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  RefreshController pullCtrl = RefreshController();
  int pageSize = 10;
  int pageNo = 1;
  int count = 0;

  loadList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.enumList,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List datas = data["data"] ?? [];
          isLoad ? dataList = [...dataList, ...datas] : dataList = datas;
          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          update();
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  List dataList = [
    {},
    {},
    {},
    {},
    {},
    {},
    {},
  ];

  onRefresh() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      pullCtrl.refreshCompleted();
    });
  }

  onLoad() {}
  @override
  void dispose() {
    pullCtrl.dispose();
    super.dispose();
  }
}

class TerminalReceive extends GetView<TerminalReceiveController> {
  const TerminalReceive({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [buildSliverAppBar(context)];
          },
          body: SmartRefresher(
            controller: controller.pullCtrl,
            onRefresh: controller.onRefresh,
            child: ListView.builder(
              padding:
                  EdgeInsets.only(bottom: paddingSizeBottom(context) + 15.w),
              itemCount: controller.dataList.length,
              itemBuilder: (context, index) {
                return cellWidget(index, controller.dataList[index]);
              },
            ),
          )),
    );
  }

  Widget cellWidget(int index, Map data) {
    return CustomButton(
      onPressed: () {
        push(const TerminalReceiveDetail(), null,
            binding: TerminalReceiveDetailBinding());
      },
      child: Align(
        child: Container(
          width: 345.w,
          height: 150.w,
          margin: EdgeInsets.only(top: 15.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12.w)),
          child: Center(
              child: sbhRow([
            SizedBox(
              width: 140.w,
              height: 140.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.w),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        assetsName(
                          "home/jifen_04",
                        ),
                        width: 140.w,
                        height: 140.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(top: 0, left: 0, child: Container())
                  ],
                ),
              ),
            ),
            sbClm([
              getWidthText("金小宝新一代全能型现代支付 电签POS机", 16, Colors.black, 175, 2,
                  fw: AppDefault.fontBold),
              centClm([
                sbRow([
                  centClm([
                    getSimpleText("立刷POS机电签版", 13, AppColor.textGrey),
                    getRichText("￥", "269", 10, Colors.red, 16, Colors.red,
                        fw2: AppDefault.fontBold)
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  Container(
                    width: 60.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6796F5),
                              Color(0xFF2368F2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(15.w)),
                    child: Center(
                      child: getSimpleText("去采购", 13, Colors.white),
                    ),
                  ),
                ], width: 175)
              ])
            ], height: 150 - 10 * 2),
          ], width: 345 - 10 * 2, height: 150 - 10 * 2)),
        ),
      ),
    );
  }

  Widget buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: false,
      expandedHeight: 300.w,
      snap: false,
      elevation: 0,
      // floating: true,
      centerTitle: true,
      // title: getDefaultAppBarTitile("123"),
      backgroundColor: Colors.white,
      leading: defaultBackButton(context),
      flexibleSpace: FlexibleSpaceBar(
        // title: getDefaultAppBarTitile("设备领取"),
        // expandedTitleScale: 1.1,
        collapseMode: CollapseMode.parallax,
        // stretchModes: const <StretchMode>[
        //   StretchMode.fadeTitle,
        // StretchMode.blurBackground,
        // StretchMode.zoomBackground
        // ],
        background: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color(0xFFE1E9F4),
                Color(0xFFEFF7F9),
              ])),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size(375.w, 50.w),
        child: Container(
          width: 375.w,
          height: 50.w,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => filterBtn(index)),
          ),
        ),
      ),
    );
  }

  Widget filterBtn(int index) {
    String? rightImg;
    String title = "";
    switch (index) {
      case 0:
        title = "全部";
        break;
      case 1:
        title = "销量";
        break;
      case 2:
        title = "最新";
        break;
      case 3:
        title = "价格";
        break;
    }
    return CustomButton(
      onPressed: () {},
      child: SizedBox(
        width: 355.w / 4,
        height: 50.w,
        child: centRow([
          getSimpleText(title, 15, Colors.black),
          gwb(rightImg != null ? 3 : 0),
          rightImg != null
              ? Image.asset(
                  assetsName("home/$rightImg"),
                  width: 8.w,
                  fit: BoxFit.fitWidth,
                )
              : gwb(0),
        ]),
      ),
    );
  }
}
