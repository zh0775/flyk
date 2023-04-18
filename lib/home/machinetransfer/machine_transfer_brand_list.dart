import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_machine_list.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class MachineTransferBrandListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferBrandListController>(
        MachineTransferBrandListController());
  }
}

class MachineTransferBrandListController extends GetxController {
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _brandList = Rx<List>([]);
  set brandList(value) => _brandList.value = value;
  List get brandList => _brandList.value;

  loadList() {
    simpleRequest(
      url: Urls.userTerminalBrandList,
      params: {},
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          brandList = data["children"];
          update();
        }
      },
      after: () {
        isLoading = false;
      },
      useCache: true,
    );
  }

  @override
  void onInit() {
    loadList();
    super.onInit();
  }
}

class MachineTransferBrandList
    extends GetView<MachineTransferBrandListController> {
  const MachineTransferBrandList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, "选择产品"),
      body: GetBuilder<MachineTransferBrandListController>(
        init: controller,
        builder: (_) {
          return controller.brandList.isEmpty
              ? GetX<MachineTransferBrandListController>(
                  builder: (_) => Align(
                    alignment: const Alignment(0, -0.7),
                    child: CustomEmptyView(
                      isLoading: controller.isLoading,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.brandList.isNotEmpty
                      ? controller.brandList.length
                      : 0,
                  itemBuilder: (context, index) {
                    return brandCell(
                        index, controller.brandList[index], context);
                  },
                );
        },
      ),
    );
  }

  Widget brandCell(int index, Map brandData, BuildContext context) {
    return Align(
      child: GestureDetector(
        onTap: () {
          push(MachineTransferMachineList(brandData: brandData), context,
              binding: MachineTransferMachineListBinding());
        },
        child: Container(
          width: 345.w,
          height: 80.w,
          margin: EdgeInsets.only(
              top: 17.5.w,
              bottom: index == controller.brandList.length - 1 ? 17.5.w : 0),
          padding: EdgeInsets.only(left: 23.w, right: 15.5.w),
          decoration: getDefaultWhiteDec(),
          child: Center(
            child: sbRow([
              centRow([
                CustomNetworkImage(
                  src: AppDefault().imageUrl + (brandData["logo"] ?? ""),
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.fill,
                ),
                gwb(25),
                getSimpleText(
                    brandData["enumName"] ?? "", 17, AppColor.textBlack,
                    isBold: true),
              ]),
              // centClm([
              //   getSimpleText(
              //       brandData["enumName"] ?? "", 17, AppColor.textBlack,
              //       isBold: true),
              //   ghb(6),
              //   sbRow([
              //     getSimpleText("", 14, AppColor.textGrey),
              //     // getSimpleText("点击查看政策详情", 14, AppColor.textGrey),
              //     Image.asset(
              //       assetsName(
              //         "common/icon_cell_right_arrow",
              //       ),
              //       width: 20.w,
              //       height: 20.w,
              //       fit: BoxFit.fill,
              //     ),
              //   ], width: 221.5
              //       // width: 345 - 23 - 15.5
              //       )
              // ], crossAxisAlignment: CrossAxisAlignment.start)
              Image.asset(
                assetsName(
                  "common/icon_cell_right_arrow",
                ),
                width: 20.w,
                height: 20.w,
                fit: BoxFit.fill,
              ),
            ], width: 345 - 23 - 15.5),
          ),
        ),
      ),
    );
  }
}
