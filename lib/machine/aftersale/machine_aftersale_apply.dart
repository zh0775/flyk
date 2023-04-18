import 'package:cxhighversion2/component/app_image_picker.dart';
import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/component/custom_upload_imageview.dart';
import 'package:cxhighversion2/machine/machine_order_aftersale.dart';
import 'package:cxhighversion2/machine/machine_order_list.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineAftersaleApplyBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineAftersaleApplyController>(
        MachineAftersaleApplyController(datas: Get.arguments));
  }
}

class MachineAftersaleApplyController extends GetxController {
  final dynamic datas;
  MachineAftersaleApplyController({this.datas});

  final _buttonEnable = true.obs;
  bool get buttonEnable => _buttonEnable.value;
  set buttonEnable(v) => _buttonEnable.value = v;

  MachineOrderUtil util = MachineOrderUtil();
  final _address = Rx<Map>({});
  Map get address => _address.value;
  set address(v) => _address.value = v;

  final _selectCount = 0.obs;
  int get selectCount => _selectCount.value;
  set selectCount(v) => _selectCount.value = v;

  Map orderData = {};
  int aftersaleType = 0;

  final _transIndex = 0.obs;
  int get transIndex => _transIndex.value;
  set transIndex(v) => _transIndex.value = v;

  late AppImagePicker imagePicker;

  final _uploadImageUrls = Rx<List>([]);
  List get uploadImageUrls => _uploadImageUrls.value;
  set uploadImageUrls(v) => _uploadImageUrls.value = v;

  final _backIndex = 0.obs;
  int get backIndex => _backIndex.value;
  set backIndex(v) => _backIndex.value = v;

  final _backPickIndex = 0.obs;
  int get backPickIndex => _backPickIndex.value;
  set backPickIndex(v) => _backPickIndex.value = v;

  String uploadImgViewBuildId = "MachineAftersaleApply_uploadImgViewBuildId";

  TextEditingController inputCtrl = TextEditingController();

  List backTypes = [
    {
      "id": 1,
      "name": "自寄退回",
    },
    {
      "id": 2,
      "name": "线下交易",
    }
  ];

  loadAddress() {
    simpleRequest(
        url: Urls.userContactList,
        params: {},
        success: (success, json) {
          if (success) {
            List aList = json["data"] ?? [];
            if (aList.isNotEmpty) {
              if (aList.length == 1) {
                address = aList[0];
              } else {
                for (var item in aList) {
                  if (item["isDefault"] == 1) {
                    address = item;
                    break;
                  }
                }
              }
              update();
            }
            // if (deliveryType == 0) {
            //   address = addressLocation;
            // }
            // loadPreviewOrder();
          }
        },
        after: () {},
        useCache: true);
  }

  setAddress(Map data) {
    address = data;
  }

  deleteImg(int index) {
    showAlert(
      Global.navigatorKey.currentContext!,
      "确定要删除该照片吗",
      confirmOnPressed: () {
        uploadImageUrls.removeAt(index);
        update([uploadImgViewBuildId]);
        Get.back();
      },
    );
  }

  upLoadImg(List imgFiles) {
    Http().uploadImages(
      imgFiles,
      success: (json) {
        if ((json["code"] ?? -1) == 0) {
          Map data = json["data"] ?? {};
          String src = data["src"] ?? "";
          if (src.isNotEmpty) {
            uploadImageUrls.add(src);
          }
          update([uploadImgViewBuildId]);
        }
      },
      fail: (reason, code, json) {},
      after: () {},
      resList: (success, jsons) {
        if (success) {
          for (var e in jsons) {
            Map res = e.data;
            Map data = res["data"] ?? {};
            String src = data["src"] ?? "";
            if (src.isNotEmpty) {
              uploadImageUrls.add(src);
            }
          }
          update([uploadImgViewBuildId]);
        } else {}
      },
    );
  }

  final _machines = Rx<List>([]);
  List get machines => _machines.value;
  set machines(v) => _machines.value = v;

  final _selectMachines = Rx<List>([]);
  List get selectMachines => _selectMachines.value;
  set selectMachines(v) => _selectMachines.value = v;

  aftersaleAction() {
    if (selectMachines.isEmpty) {
      ShowToast.normal("请选择需要${aftersaleType == 0 ? "换货" : "退货"}的设备");
      return;
    }

    if (inputCtrl.text.isEmpty) {
      ShowToast.normal("请描述您的申请原因");
      return;
    }

    String voucher = "";
    for (var i = 0; i < uploadImageUrls.length; i++) {
      voucher += "${i == 0 ? "" : ","}${uploadImageUrls[i]}";
    }

    Map<String, dynamic> params = {
      "id": orderData["id"],
      "serviceType": aftersaleType + 1,
      "userReason": inputCtrl.text,
      "deliveryNote": List.generate(selectMachines.length, (index) {
        Map e = selectMachines[index];
        return {
          "id": e["id"],
          "levleConfig_ID": orderData["commodity"][productIdx]
              ["levleConfig_ID"],
          "name": e["name"],
          "tNo": e["tNo"],
          "stateStr": e["stateStr"],
        };
      })
    };
    if (voucher.isNotEmpty) {
      params["voucher"] = voucher;
    }

    //换货
    if (aftersaleType == 0) {
      params["delivery_Method"] = transIndex + 1;
      params["contactID"] =
          transIndex == 1 || address.isEmpty ? 0 : address["id"];
      //退货
    } else {}
    buttonEnable = false;
    simpleRequest(
      url: Urls.userLevelUpAfterSaleApply,
      params: params,
      success: (success, json) {
        if (success) {
          Get.find<MachineOrderListController>().loadData();
          push(
              AppSuccessResult(
                title: aftersaleType == 0 ? "换货结果" : "退货结果",
                contentTitle: "提交成功",
                buttonTitles: const ["查看订单", "返回列表"],
                backPressed: () {
                  util.popToList();
                },
                onPressed: (index) {
                  if (index == 0) {
                    util.popToList(
                        page: const MachineOrderAftersale(),
                        binding: MachineOrderAftersaleBinding(),
                        arguments: {
                          "orderData": {
                            "id": 1225,
                          },
                          "isMine": true
                        });
                  } else {
                    util.popToList();
                  }
                },
              ),
              Global.navigatorKey.currentContext);
        }
      },
      after: () {
        buttonEnable = true;
      },
    );
  }

  loadMachines() {
    simpleRequest(
      url: Urls.returnTerminalList(orderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          List jsonDatas = json["data"] ?? [];
          if (productIdx < jsonDatas.length) {
            List mList = jsonDatas[productIdx]["terminalList"] ?? [];
            machines = List.generate(mList.length, (index) {
              Map e = mList[index];
              return {...e, "selected": true};
            });
            selectMachines = machines;
            selectCount = machines.length;
          }
        }
      },
      after: () {},
    );
  }

  int productIdx = 0;

  @override
  void onInit() {
    if (datas != null && datas is Map && datas.isNotEmpty) {
      orderData = datas["orderData"] ?? {};
      aftersaleType = datas["type"] ?? 0;
      if (aftersaleType == 0) {
        loadAddress();
      }
      productIdx = datas["index"] ?? 0;
      loadMachines();
    }

    imagePicker = AppImagePicker(
      multiple: true,
      imgsCallback: (imgFile) {
        upLoadImg(imgFile);
      },
      imgCallback: (imgFile) {
        upLoadImg([imgFile, imgFile]);
      },
    );
    super.onInit();
  }

  unSelectAction(int index) {
    selectMachines = selectMachines.where((e) => e["selected"]).toList();
    selectCount = selectMachines.length;
  }

  addMachines(List addMachines) {
    List adds = addMachines.where((e) => e["selected"]).toList();
    // machines = adds;
    selectMachines = adds;
    selectCount = selectMachines.length;
    Get.back();
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    super.onClose();
  }
}

class MachineAftersaleApply extends GetView<MachineAftersaleApplyController> {
  const MachineAftersaleApply({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(
            context, "申请${controller.aftersaleType == 0 ? "换" : "退"}货"),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              gwb(375),
              sbhRow([
                getSimpleText(
                    "选择${controller.aftersaleType == 0 ? "换" : "退"}货设备",
                    12,
                    AppColor.text3),
                GetX<MachineAftersaleApplyController>(
                  builder: (_) {
                    return getSimpleText(
                        "已选择：${controller.selectCount}台", 12, AppColor.text2);
                  },
                )
              ], width: 345, height: 41.5),
              GetX<MachineAftersaleApplyController>(
                builder: (_) {
                  return controller.util.getOrSetMachineList(
                    controller.aftersaleType,
                    controller.machines,
                    controller.selectMachines,
                    controller.orderData,
                    addMachines: (machines) {
                      controller.addMachines(machines);
                    },
                    unSelectAction: (index) {
                      controller.unSelectAction(index);
                    },
                    aftersaleIdx: controller.productIdx,
                  );
                },
              ),
              ghb(15),
              inputView(),
              ghb(15),
              controller.aftersaleType == 1 ? backTypeView() : addressView(),
              ghb(15),
              uploadImageView(),
              ghb(30),
              GetX<MachineAftersaleApplyController>(
                builder: (_) {
                  return getSubmitBtn("确定", () {
                    controller.aftersaleAction();
                  },
                      height: 45,
                      fontSize: 15,
                      color: AppColor.theme,
                      enable: controller.buttonEnable);
                },
              ),
              ghb(20)
            ],
          ),
        ),
      ),
    );
  }

  Widget backTypeView() {
    return CustomButton(
      onPressed: () {
        showTypeSelectModel();
      },
      child: Container(
        width: 345.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: Center(
            child: sbhRow([
          getSimpleText("退货方式", 14, AppColor.text3),
          centRow([
            GetX<MachineAftersaleApplyController>(
              builder: (_) {
                return getSimpleText(
                    controller.backTypes[controller.backIndex]["name"],
                    14,
                    AppColor.text);
              },
            ),
            gwb(5),
            Image.asset(
              assetsName("statistics/icon_arrow_right_gray"),
              width: 12.w,
              fit: BoxFit.fitWidth,
            )
          ])
        ], width: 345 - 15 * 2, height: 50)),
      ),
    );
  }

  Widget inputView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          gwb(345),
          sbhRow([
            getRichText("*", "申请原因(必填)", 14, AppColor.red, 14, AppColor.text3)
          ], width: 345 - 15.5 * 2, height: 50),
          CustomInput(
            width: 315.w,
            textEditCtrl: controller.inputCtrl,
            heigth: 75.w,
            style: TextStyle(fontSize: 12.w, color: AppColor.text),
            placeholderStyle: TextStyle(fontSize: 12.w, color: AppColor.text3),
            placeholder: "请详细描述您的申请原因...",
            maxLines: 10,
            maxLength: 50,
          ),
          ghb(10),
        ],
      ),
    );
  }

  Widget uploadImageView() {
    return Container(
        width: 345.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: Column(
          children: [
            gwb(345),
            sbhRow([
              getSimpleText("上传凭证", 14, AppColor.text3),
            ], width: 345 - 15.5 * 2, height: 50),
            CustomUploadImageView(
              maxImgCount: 3,
              tipStr: "注：最多可上传3张图片",
              imageUpload: (imgs) {
                controller.uploadImageUrls = imgs;
              },
            ),
            SizedBox(
              width: 315.w,
              child: GetBuilder<MachineAftersaleApplyController>(
                id: controller.uploadImgViewBuildId,
                builder: (_) {
                  return Wrap(
                    runSpacing: 15.w / 2 - 0.1.w,
                    spacing: 15.w / 2 - 0.1.w,
                    children: [
                      ...List.generate(
                          controller.uploadImageUrls.length,
                          (index) => SizedBox(
                                width: 100.w,
                                height: 100.w,
                                child: Stack(
                                  children: [
                                    Align(
                                        alignment: Alignment.center,
                                        child: CustomButton(
                                          onPressed: () {
                                            toCheckImg(
                                                image:
                                                    "${AppDefault().imageUrl}${controller.uploadImageUrls[index]}");
                                          },
                                          child: CustomNetworkImage(
                                            src: AppDefault().imageUrl +
                                                controller
                                                    .uploadImageUrls[index],
                                            width: 90.w,
                                            height: 90.w,
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: CustomButton(
                                        onPressed: () {
                                          controller.deleteImg(index);
                                        },
                                        child: SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Image.asset(
                                              assetsName(
                                                "machine/btn_sub_machine",
                                              ),
                                              width: 18.w,
                                              height: 18.w,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                      Visibility(
                          visible: controller.uploadImageUrls.length < 6,
                          child: CustomButton(
                            onPressed: () {
                              controller.imagePicker.showImage(
                                  Global.navigatorKey.currentContext!,
                                  imgCount:
                                      6 - controller.uploadImageUrls.length);
                            },
                            child: Container(
                              width: 100.w,
                              height: 100.w,
                              color: AppColor.pageBackgroundColor,
                              child: Center(
                                  child: centClm([
                                Image.asset(
                                  assetsName("machine/icon_img_upload"),
                                  width: 31.5.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                ghb(5),
                                getSimpleText("上传图片", 12, AppColor.assisText)
                              ])),
                            ),
                          )),
                    ],
                  );
                },
              ),
            ),
            sbhRow([getSimpleText("注：最多可上传6张图片", 12, AppColor.text3)],
                width: 315, height: 32),
            ghb(3),
          ],
        ));
  }

  Widget addressView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          gwb(345),
          sbhRow([
            getSimpleText("配送方式", 14, AppColor.text3),
            centRow(List.generate(
                2,
                (index) => CustomButton(onPressed: () {
                      controller.transIndex = index;
                    }, child: GetX<MachineAftersaleApplyController>(
                      builder: (_) {
                        return centRow([
                          gwb(index == 0 ? 0 : 13),
                          ghb(
                            49.5,
                          ),
                          Image.asset(
                            assetsName(
                                "machine/checkbox_${controller.transIndex == index ? "selected" : "normal"}"),
                            width: 16.w,
                            fit: BoxFit.fitWidth,
                          ),
                          gwb(8),
                          getSimpleText(
                              index == 0 ? "快递配送" : "线下自提", 14, AppColor.text2,
                              textHeight: 1.3),
                        ]);
                      },
                    )))),
          ], width: 345 - 14.5 * 2, height: 49.5),
          GetX<MachineAftersaleApplyController>(
            builder: (_) {
              return controller.transIndex == 1
                  ? ghb(0)
                  : GetX<MachineAftersaleApplyController>(
                      builder: (_) {
                        return CustomButton(
                          onPressed: () {
                            push(
                                MineAddressManager(
                                  getCtrl: controller,
                                  addressType: AddressType.address,
                                ),
                                null,
                                binding: MineAddressManagerBinding());
                          },
                          child: centClm([
                            gline(315, 1),
                            sbRow([
                              centRow([
                                gwb(12),
                                Image.asset(
                                  assetsName("machine/icon_address"),
                                  width: 18.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              ]),
                              SizedBox(
                                width: 234.5.w,
                                child: controller.address.isEmpty
                                    ? SizedBox(
                                        height: 81.5.w,
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: getSimpleText(
                                                "请选择收货地址", 12, AppColor.text3)))
                                    : centClm([
                                        ghb(12),
                                        getWidthText(
                                            "${controller.address["recipient"] ?? ""}   ${controller.address["recipientMobile"] ?? ""}",
                                            15,
                                            AppColor.text,
                                            234.5,
                                            1),
                                        ghb(6),
                                        getWidthText(
                                            "${controller.address["provinceName"]}${controller.address["cityName"]}${controller.address["areaName"]}${controller.address["address"]}",
                                            12,
                                            AppColor.text3,
                                            242,
                                            2),
                                        ghb(12),
                                      ]),
                              ),
                              Image.asset(
                                assetsName("statistics/icon_arrow_right_gray"),
                                width: 18.w,
                                fit: BoxFit.fitWidth,
                              ),
                            ], width: 345 - 11.5 * 2),
                            Image.asset(
                              assetsName("machine/address_bottom_line"),
                              width: 345.w,
                              height: 3.w,
                              fit: BoxFit.fill,
                            ),
                          ]),
                        );
                      },
                    );
            },
          )
        ],
      ),
    );
  }

  showTypeSelectModel() {
    Get.bottomSheet(Container(
      height: 165.w,
      width: 375.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
      child: Column(
        children: [
          sbhRow(
              List.generate(
                  2,
                  (index) => CustomButton(
                        onPressed: () {
                          if (index == 1) {
                            controller.backIndex = controller.backPickIndex;
                          }
                          Get.back();
                        },
                        child: SizedBox(
                          width: 65.w,
                          height: 52.w,
                          child: Center(
                            child: getSimpleText(index == 0 ? "取消" : "确定", 14,
                                index == 0 ? AppColor.text3 : AppColor.text),
                          ),
                        ),
                      )),
              height: 52,
              width: 375),
          gline(375, 1),
          SizedBox(
            width: 375.w,
            height: 165.w - 52.w - 1.w,
            child: CupertinoPicker.builder(
              scrollController: FixedExtentScrollController(
                  initialItem: controller.backIndex),
              itemExtent: 40.w,
              childCount: controller.backTypes.length,
              onSelectedItemChanged: (value) {
                controller.backPickIndex = value;
              },
              itemBuilder: (context, index) {
                return Center(
                  child: GetX<MachineAftersaleApplyController>(
                    builder: (_) {
                      return getSimpleText(controller.backTypes[index]["name"],
                          15, AppColor.text,
                          fw: controller.backIndex == index
                              ? FontWeight.w500
                              : FontWeight.normal);
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    ));
  }
}
