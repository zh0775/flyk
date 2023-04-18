import 'package:flutter/material.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_success.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class MachineTransferAdvanceOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferAdvanceOrderController>(
        MachineTransferAdvanceOrderController());
  }
}

class MachineTransferAdvanceOrderController extends GetxController {
  final _submitEnable = true.obs;
  set submitEnable(value) => _submitEnable.value = value;
  get submitEnable => _submitEnable.value;

  submitOrder() {
    // submitEnable = false;
    // String tNo = "";
    // for (var i = 0; i < machineDatas.length; i++) {
    //   Map item = machineDatas[i];
    //   tNo += (i == 0 ? "${item["terminalNo"]}" : ",${item["terminalNo"]}");
    // }
    List content = [];
    for (var i = 0; i < machineDatas.length; i++) {
      Map item = machineDatas[i];
      content.add(
          {"tId": item["tId"], "tNO": item["tNo"], "productId": item["tcId"]});
    }
    simpleRequest(
      url: Urls.terminalTransfer,
      params: {
        "iuserId": userData["uId"],
        "createType": 1,
        "content": content,
        "customId": 0,
        "transferType": 2,
        // "transferType": isLock ? 3 : 2,
      },
      success: (success, json) {
        if (success) {
          Get.to(() => const MachineTransferSuccess(isLock: false),
              binding: MachineTransferSuccessBinding());
        }
      },
      after: () {
        submitEnable = true;
      },
    );
  }

  bool isFirst = true;

  Map orderData = {};

  List machineDatas = [];
  Map userData = {};
  bool isLock = false;
  dataInit(Map uData, List mDatas, bool lock) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    machineDatas = mDatas;
    userData = uData;
    isLock = lock;
  }

  @override
  void onInit() {
    super.onInit();
  }
}

class MachineTransferAdvanceOrder
    extends GetView<MachineTransferAdvanceOrderController> {
  final List machineData;
  final Map userData;
  final bool isLock;
  const MachineTransferAdvanceOrder(
      {Key? key,
      required this.machineData,
      required this.userData,
      this.isLock = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(userData, machineData, isLock);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.7, 0),
                    colors: [
                  Color(0xFF484E5E),
                  Color(0xFF292732),
                ])),
          )),
          Positioned(
              top: paddingSizeTop(context),
              left: 0,
              right: 0,
              height: kToolbarHeight,
              child: Center(
                child: getDefaultAppBarTitile("生成订单",
                    titleStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: AppDefault.fontBold)),
              )),
          Positioned(
              top: paddingSizeTop(context),
              left: 0,
              height: kToolbarHeight,
              child: defaultBackButton(context, color: Colors.white)),
          Positioned(
              top: paddingSizeTop(context) + kToolbarHeight + 15.w,
              left: 15.w,
              right: 15.w,
              bottom: 50.w + paddingSizeBottom(context) + 15.5.w + 13.5.w,
              child: Container(
                decoration: getDefaultWhiteDec(),
              )),
          Positioned(
              top: paddingSizeTop(context) + kToolbarHeight + 15.w,
              left: 15.w + 20.w,
              right: 15.w + 20.w,
              height: 123.w,
              child: SizedBox(
                child: centClm([
                  getSimpleText(
                      "接收人：${controller.userData.isNotEmpty && controller.userData["uName"] != null ? controller.userData["uName"] : controller.userData["uMobile"] ?? ""}${controller.userData.isNotEmpty && controller.userData["uMobile"] != null ? "(${controller.userData["uMobile"]})" : ""}",
                      15,
                      AppColor.textBlack,
                      isBold: true),
                  ghb(12),
                  getSimpleText("订单类别：划拨订单", 15, AppColor.textBlack,
                      isBold: true),
                  ghb(12),
                  getSimpleText(
                      "产品名称：${controller.machineDatas.isNotEmpty && controller.machineDatas[0] != null && controller.machineDatas[0]["tbName"] != null ? controller.machineDatas[0]["tbName"] : ""}",
                      15,
                      AppColor.textBlack,
                      isBold: true),
                ], crossAxisAlignment: CrossAxisAlignment.start),
              )),
          Positioned(
              top: paddingSizeTop(context) + kToolbarHeight + 15.w + 123.w,
              left: 15.w + 14.5.w,
              right: 15.w + 14.w,
              bottom:
                  50.w + paddingSizeBottom(context) + 15.5.w + 13.5.w + 31.5.w,
              child: Container(
                padding: EdgeInsets.fromLTRB(18.5.w, 10.w, 15.5.w, 15.w),
                decoration: BoxDecoration(
                    color: AppColor.pageBackgroundColor,
                    borderRadius: BorderRadius.circular(5.w)),
                child: Scrollbar(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.machineDatas.isNotEmpty
                        ? controller.machineDatas.length
                        : 0,
                    itemBuilder: (context, index) {
                      return machineCell(index, controller.machineDatas[index]);
                    },
                  ),
                ),
              )),
          Positioned(
              left: 15.w + 20.5,
              bottom: 50.w + paddingSizeBottom(context) + 15.5.w + 13.5.w,
              height: 31.5.w,
              child: Center(
                child: getSimpleText("总计：${controller.machineDatas.length}台",
                    12, const Color(0xFFEB5757),
                    isBold: true),
              )),
          Positioned(
              bottom: 15.5.w,
              left: 15.w,
              right: 15.w,
              height: 50.w + paddingSizeBottom(context),
              child: GetX<MachineTransferAdvanceOrderController>(
                init: controller,
                builder: (_) {
                  return getSubmitBtn("确认划拨", () {
                    controller.submitOrder();
                  }, enable: controller.submitEnable);
                },
              ))
        ],
      ),
    );
  }

  Widget machineCell(int index, Map data) {
    return SizedBox(
      height: 65.5.w,
      width: (375 - 15 * 2 - 14.5 * 2 - 18.5 - 15.5).w,
      child: centClm([
        getSimpleText("机具编号（SN号）", 14, const Color(0xFF808080)),
        ghb(12),
        getTerminalNoText(
          data.isNotEmpty && data["tNo"] != null ? data["tNo"] : "",
          highlightStyle: TextStyle(
              color: AppColor.textBlack,
              fontSize: 16.sp,
              fontWeight: AppDefault.fontBold),
          style: TextStyle(
              color: AppColor.textBlack,
              fontSize: 16.sp,
              fontWeight: AppDefault.fontBold),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),
    );
  }
}
