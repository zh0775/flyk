import 'package:cxhighversion2/component/custom_background.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/merchantAccessNetwork/merchant_access_network_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MerchantAccessNetworkBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MerchantAccessNetworkController>(MerchantAccessNetworkController());
  }
}

class MerchantAccessNetworkController extends GetxController {
  RefreshController pullCtrl = RefreshController();

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  List dataList = [];

  int pageNo = 1;
  int pageSize = 10;
  int count = 0;

  onLoad() {
    loadList(isLoad: true);
  }

  onRefresh() {
    loadList();
  }

  loadList({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    simpleRequest(
      url: Urls.merchantsNetList,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          isLoad
              ? dataList = [...dataList, ...(data["data"] ?? [])]
              : dataList = data["data"] ?? [];
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

  @override
  void onInit() {
    loadList();
    super.onInit();
  }
}

class MerchantAccessNetwork extends GetView<MerchantAccessNetworkController> {
  const MerchantAccessNetwork({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getDefaultAppBar(context, "产品展示", color: Colors.white),
      body: CustomBackground(
        child: GetBuilder<MerchantAccessNetworkController>(
          builder: (controller) {
            return SmartRefresher(
              controller: controller.pullCtrl,
              onLoading: controller.onLoad,
              onRefresh: controller.onRefresh,
              enablePullUp: controller.count > controller.dataList.length,
              child: controller.dataList.isEmpty
                  ? GetX<MerchantAccessNetworkController>(
                      builder: (_) {
                        return CustomEmptyView(
                          isLoading: controller.isLoading,
                        );
                      },
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 15.w),
                      itemCount: controller.dataList.length,
                      itemBuilder: (context, index) {
                        return productCell(
                            index, controller.dataList[index], context);
                      },
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget productCell(int index, Map data, BuildContext context) {
    return Align(
      child: CustomButton(
        onPressed: () {
          push(
              MerchantAccessNetworkDetail(
                productInfo: data,
              ),
              context);
        },
        child: Container(
          margin: EdgeInsets.only(top: 14.w),
          width: 345.w,
          decoration: getDefaultWhiteDec2(radius: 8),
          child: Column(
            children: [
              ghb(12),
              sbRow([
                getSimpleText(data["title"] ?? "", 14, const Color(0xFF525C66),
                    fw: AppDefault.fontBold),
              ], width: 345 - 12 * 2),
              ghb(5),
              sbRow([
                centRow([
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.w),
                    child: CustomNetworkImage(
                      src: AppDefault().imageUrl + (data["m_Image"] ?? ""),
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  gwb(11),
                  getWidthText(
                      data["meta"] ?? "", 14, const Color(0xFF525C66), 170, 3),
                ]),
                Container(
                  width: 76.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                      color: const Color(0xFF57B0FF),
                      borderRadius: BorderRadius.circular(11.w)),
                  child: Center(
                    child: getSimpleText("商户入网", 12, Colors.white,
                        fw: AppDefault.fontBold),
                  ),
                )
              ], width: 345 - 12 * 2),
              ghb(9)
            ],
          ),
        ),
      ),
    );
  }
}
