import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_tmp_detail.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineTransferTmpListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MachineTransferTmpListController>(
        () => MachineTransferTmpListController());
  }
}

class MachineTransferTmpListController extends GetxController {
  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  final _tmpDatas = Rx<List>([]);
  set tmpDatas(value) => _tmpDatas.value = value;
  get tmpDatas => _tmpDatas.value;

  int currentSelectIndex = 0;

  final RefreshController pullCtrl = RefreshController();

  refreshListData() async {
    tmpDatas = [
      {
        "name": "默认模版",
        "createDate": "2021.08.19",
        "selected": true,
        "type": 0,
      },
      {
        "name": "大大利专属模版",
        "createDate": "2021.08.19",
        "selected": false,
        "type": 1,
      },
      {
        "name": "大大利专属模版",
        "createDate": "2021.08.19",
        "subName": "平台系统配置",
        "selected": false,
        "type": 1,
      },
      {
        "name": "大大利专属模版",
        "createDate": "2021.08.19",
        "subName": "平台系统配置",
        "selected": false,
        "type": 1,
      }
    ];
    int i = 0;
    for (var item in tmpDatas) {
      if (item["selected"] != null && item["selected"]) {
        currentSelectIndex = i;
        break;
      }
      i++;
    }
    update();
    pullCtrl.refreshCompleted();
  }

  selectedTmp(int idx) {
    if (idx == currentSelectIndex) {
      return;
    }
    int i = 0;
    for (var item in tmpDatas) {
      if (idx == i) {
        currentSelectIndex = i;
        item["selected"] = true;
      } else {
        item["selected"] = false;
      }
      i++;
    }
    update();
  }
}

class MachineTransferTmpList extends GetView<MachineTransferTmpListController> {
  const MachineTransferTmpList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "划拨模版"),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 80.w + paddingSizeBottom(context),
              child: GetBuilder<MachineTransferTmpListController>(
                init: controller,
                initState: (_) {},
                builder: (_) {
                  return SmartRefresher(
                    controller: controller.pullCtrl,
                    enablePullDown: true,
                    physics: const BouncingScrollPhysics(),
                    onRefresh: controller.refreshListData,
                    child: ListView.builder(
                      itemCount: controller.tmpDatas.isNotEmpty
                          ? controller.tmpDatas.length
                          : 0,
                      itemBuilder: (context, index) {
                        return tmpCell(
                            index, controller.tmpDatas[index], context);
                      },
                    ),
                  );
                },
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80.w + paddingSizeBottom(context),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ghb(15),
                      getSubmitBtn("添加新模版", () {
                        push(
                            const MachineTransferTmpDetail(
                              type: 2,
                            ),
                            context,
                            binding: MachineTransferTmpDetailBinding());
                      })
                    ],
                  ),
                ))
          ],
        ));
  }

  Widget tmpCell(int index, Map data, BuildContext context) {
    return Align(
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        decoration: getDefaultWhiteDec(),
        width: 345.w,
        height: 168.w,
        child: Column(
          children: [
            sbhRow([
              getSimpleText(data["name"] ?? "", 18, AppColor.textBlack,
                  isBold: true),
              CustomButton(
                onPressed: () {
                  controller.selectedTmp(index);
                },
                child: Image.asset(
                  assetsName(
                      "home/machinetransfer/${data["selected"] ? "btn_tmp_selected" : "btn_tmp_normal"}"),
                  width: 19.5.w,
                  height: 19.5.w,
                  fit: BoxFit.fill,
                ),
              )
            ], width: 345 - 22 * 2, height: 64),
            gline(345, 0.5),
            SizedBox(
              width: 345.w,
              height: (168 - 64 - 0.5).w,
              child: Center(
                child: sbRow([
                  centClm([
                    getSimpleText(
                        "创建时间：${data["createDate"]}", 15, AppColor.textBlack),
                    ghb(13),
                    getSimpleText(
                        "模版属性：${data["type"] == 0 ? "平台系统配置" : "自定义配置"}",
                        15,
                        AppColor.textBlack),
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  CustomButton(
                      onPressed: () {
                        push(
                            MachineTransferTmpDetail(
                              type: data["type"] ?? 2,
                              tmpData: data,
                            ),
                            context,
                            binding: MachineTransferTmpDetailBinding());
                      },
                      child: SizedBox(
                        width: 40.w,
                        child: getSimpleText(
                            data["type"] == 0 ? "查看" : "编辑",
                            15,
                            data["type"] == 0
                                ? const Color(0xFF294DB3)
                                : const Color(0xFF3782FF)),
                      ))
                ],
                    width: 345 - 22 * 2,
                    crossAxisAlignment: CrossAxisAlignment.end),
              ),
            )
          ],
        ),
      ),
    );
  }
}
