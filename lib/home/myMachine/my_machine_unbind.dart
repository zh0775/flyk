import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/myMachine/my_machine_unbind_history.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyMachineUnbindController extends GetxController {
  TextEditingController snInputCtrl = TextEditingController();

  final _machineDatas = [
    {
      "id": 0,
      "sn": "0000 1102C 831993 79123",
      "ulock": false,
      "selected": false
    },
    {
      "id": 1,
      "sn": "0000 1102C 831993 79124",
      "ulock": false,
      "selected": false
    },
    {
      "id": 2,
      "sn": "0000 1102C 831993 79125",
      "ulock": false,
      "selected": false
    },
    {
      "id": 3,
      "sn": "0000 1102C 831993 79126",
      "ulock": false,
      "selected": false
    },
    {
      "id": 4,
      "sn": "0000 1102C 831993 79127",
      "ulock": false,
      "selected": false
    },
    {
      "id": 5,
      "sn": "0000 1102C 831993 79128",
      "ulock": false,
      "selected": false
    },
    {
      "id": 6,
      "sn": "0000 1102C 831993 79129",
      "ulock": false,
      "selected": false
    },
    {
      "id": 7,
      "sn": "0000 1102C 831993 79130",
      "ulock": false,
      "selected": false
    },
    {
      "id": 8,
      "sn": "0000 1102C 831993 79131",
      "ulock": false,
      "selected": false
    },
    {
      "id": 9,
      "sn": "0000 1102C 831993 79132",
      "ulock": false,
      "selected": false
    },
    {
      "id": 10,
      "sn": "0000 1102C 831993 79133",
      "ulock": false,
      "selected": false
    },
    {
      "id": 11,
      "sn": "0000 1102C 831993 79134",
      "ulock": false,
      "selected": false
    },
    {
      "id": 12,
      "sn": "0000 1102C 831993 79135",
      "ulock": false,
      "selected": false
    },
    {
      "id": 13,
      "sn": "0000 1102C 831993 79136",
      "ulock": false,
      "selected": false
    },
    {
      "id": 14,
      "sn": "0000 1102C 831993 79137",
      "ulock": false,
      "selected": false
    },
    {
      "id": 15,
      "sn": "0000 1102C 831993 79138",
      "ulock": false,
      "selected": false
    },
  ].obs;

  get machineDatas => _machineDatas.value;
  set machineDatas(value) => _machineDatas.value = value;

  updateMachineDatas(value) {
    _machineDatas.value = value;
  }

  bool allSelected = false;

  int selectedCount = 0;

  void checkAllSelected() {
    bool t = true;
    int count = 0;
    for (var e in machineDatas) {
      if (!e["selected"]) {
        t = false;
      } else {
        count++;
      }
    }
    allSelected = t;
    selectedCount = count;
  }

  selectedAndUnSelectedAll(bool selected) {
    for (var e in machineDatas) {
      e["selected"] = selected;
    }
    selectedCount = selected ? machineDatas.length : 0;
    allSelected = selected;
    update();
  }

  updateListView() {
    checkAllSelected();
    update();
  }

  List getSelectedDatas() {
    List selectedList = [];
    for (var e in machineDatas) {
      if (e["selected"]) selectedList.add(e);
    }
    return selectedList;
  }

  List selectedList = [];
  deleteData(dynamic e) {
    if (selectedList.indexOf(e) != -1) {
      selectedList.remove(e);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    snInputCtrl.dispose();
    super.dispose();
  }
}

class MyMachineUnbind extends StatelessWidget {
  MyMachineUnbind({Key? key}) : super(key: key);
  final MyMachineUnbindController ctrl = MyMachineUnbindController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "解绑机具", action: [
          CustomButton(
            onPressed: () {
              push(const MyMachineUnbindHistory(), context);
            },
            child: SizedBox(
              width: 70.w,
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: getSimpleText("历史记录", 14, AppColor.textBlack),
              ),
            ),
          )
        ]),
        body: Stack(children: [
          Positioned(
              left: 15.w,
              top: 15,
              child: Container(
                width: 345.w,
                height: 50,
                decoration: getDefaultWhiteDec(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      gwb(15),
                      CustomButton(
                          onPressed: () {
                            toScanBarCode(
                                ((barCode) => ctrl.snInputCtrl.text = barCode));
                          },
                          child: assetsSizeImage(
                              "home/machinemanage/tiaoxingma", 24, 24)),
                      gwb(15),
                      CustomInput(
                        width: 214.w,
                        heigth: 50,
                        textEditCtrl: ctrl.snInputCtrl,
                        placeholder: "请输入机具SN号进行搜索",
                        placeholderStyle: TextStyle(
                            color: const Color(0xFFCCCCCC), fontSize: 15.sp),
                      ),
                      CustomButton(
                        onPressed: () {},
                        child: Container(
                            width: 64.w,
                            height: 30,
                            decoration: BoxDecoration(
                                color: AppColor.textBlack,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: getSimpleText("搜索", 15, Colors.white),
                            )),
                      )
                    ],
                  ),
                ),
              )),
          Positioned(
            top: 65,
            height: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: (375 - 15 * 2).w,
                  height: 50,
                  child: Align(
                    child: Row(
                      children: [
                        getSimpleText("可选择绑定机具：", 15, AppColor.textBlack),
                        getSimpleText("${ctrl.machineDatas.length}", 15,
                            const Color(0xFFEB5757)),
                        getSimpleText("台", 15, AppColor.textBlack),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 375.w,
                  height: 50,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                              width: 0.5, color: Color(0xFFEBEBEB)))),
                  child: Center(
                      child: sbRow([
                    getSimpleText("机具编号（SN号）", 14, const Color(0xFF808080)),
                    GetBuilder<MyMachineUnbindController>(
                      init: ctrl,
                      initState: (_) {},
                      builder: (_) {
                        return CustomButton(
                          onPressed: () {
                            ctrl.selectedAndUnSelectedAll(!ctrl.allSelected);
                          },
                          child: SizedBox(
                            height: 50,
                            child: Center(
                                child: getSimpleText(
                                    ctrl.allSelected ? "反选" : "全选",
                                    14,
                                    const Color(0xFF5290F2))),
                          ),
                        );
                      },
                    )
                  ], width: 375 - 15 * 2)),
                )
              ],
            ),
          ),
          Positioned(
            top: 165,
            left: 0,
            right: 0,
            bottom: 80 + paddingSizeBottom(context),
            child: GetBuilder<MyMachineUnbindController>(
              init: ctrl,
              initState: (_) {},
              builder: (_) {
                return ListView.builder(
                  itemCount:
                      ctrl.machineDatas != null ? ctrl.machineDatas.length : 0,
                  itemBuilder: (context, index) {
                    return unbindCell(ctrl.machineDatas[index], index);
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80 + paddingSizeBottom(context),
            child: Container(
              width: 375.w,
              height: 80,
              color: Colors.white,
              padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
              child: Center(
                child: getSubmitBtn("确定", (() {
                  if (ctrl.selectedCount < 1) {
                    ShowToast.normal("请选择要解绑的机具");
                    return;
                  }
                  ctrl.selectedList = ctrl.getSelectedDatas();
                  showSelectedSN(context);
                })),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget unbindCell(Map data, int idx) {
    return CustomButton(
      onPressed: () {
        data["selected"] = !data["selected"];
        ctrl.updateListView();
      },
      child: Container(
        width: 375,
        height: 60,
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(width: 0.5, color: Color(0xFFEBEBEB)))),
        child: Align(
          child: sbhRow([
            getSimpleText(data["sn"], 13, AppColor.textBlack),
            Image.asset(
              assetsName(
                data["selected"]
                    ? "common/btn_checkbox_selected"
                    : "common/btn_checkbox_normal",
              ),
              width: 22.w,
              height: 22.w,
              fit: BoxFit.fill,
            )

            //         btn_checkbox_normal.png
            // btn_checkbox_selected.png
          ], width: 375 - 15 * 2),
        ),
      ),
    );
  }

  showSelectedSN(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (__, setSBState) {
            return Container(
              height: 429 + paddingSizeBottom(context),
              width: 375.w,
              color: const Color(0xFFF7F7F7),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      width: 375.w,
                      height: 50,
                      color: Colors.white,
                      child: Align(
                        child: sbhRow([
                          getSimpleText("已选SN", 15, AppColor.textBlack,
                              isBold: true)
                        ], width: 375 - 15 * 2, height: 50),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      bottom: 50 + paddingSizeBottom(context),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        itemCount: ctrl.selectedList != null
                            ? ctrl.selectedList.length
                            : 0,
                        itemBuilder: (context, index) {
                          return Align(
                            child: sbhRow([
                              getSimpleText(ctrl.selectedList[index]["sn"], 15,
                                  AppColor.textBlack),
                              CustomButton(
                                onPressed: () {
                                  ctrl.deleteData(ctrl.selectedList[index]);
                                  setSBState(
                                    () {},
                                  );
                                },
                                child: Icon(
                                  Icons.remove_circle,
                                  color: const Color(0xFFFB4746),
                                  size: 25.w,
                                ),
                              )
                            ], width: 375 - 15 * 2, height: 50),
                          );
                        },
                      )),
                  Positioned(
                    height: 50 + paddingSizeBottom(context),
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                        width: 375.w,
                        height: 50 + paddingSizeBottom(context),
                        color: Colors.white,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            children: [
                              CustomButton(
                                onPressed: () => Navigator.pop(context),
                                child: SizedBox(
                                  width: 110.w,
                                  height: 50,
                                  child: Center(
                                    child: getSimpleText(
                                        "重选", 16, AppColor.textBlack),
                                  ),
                                ),
                              ),
                              CustomButton(
                                onPressed: () {
                                  if (ctrl.selectedList == null ||
                                      ctrl.selectedList.length == 0) {
                                    ShowToast.normal("没有选择解绑的机具");
                                    return;
                                  }
                                  Navigator.pop(_);
                                  push(const MyMachineUnbindSuccess(), context);
                                },
                                child: Container(
                                  width: 265.w,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                        Color(0xFF4282EB),
                                        Color(0xFF5BA3F7),
                                      ])),
                                  child: Center(
                                    child:
                                        getSimpleText("确定解绑", 16, Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class MyMachineUnbindSuccess extends StatelessWidget {
  const MyMachineUnbindSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      body: Stack(children: [
        Positioned(
            top: 0 + paddingSizeTop(context),
            left: 0,
            height: 50,
            width: 50.w,
            child: defaultBackButton(context)),
        Positioned(
            top: 0 + paddingSizeTop(context) + 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                assetsSizeImage("home/bg_machine_unbind_success", 170.w, 80),
                ghb(50),
                getSimpleText("解绑完成", 22, AppColor.textBlack, isBold: true),
                ghb(24),
                getSimpleText("解绑的机具状态已变更为未绑定", 14, AppColor.textGrey),
                ghb(150),
                getSubmitBtn("继续解绑", () {
                  Navigator.pop(context);
                }),
              ],
            )),
      ]),
    );
  }
}
