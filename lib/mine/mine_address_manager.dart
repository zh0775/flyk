import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/mine/mine_address_add.dart';
import 'package:cxhighversion2/product/product_confirm_order.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MineAddressManagerBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineAddressManagerController>(MineAddressManagerController());
  }
}

class MineAddressManagerController extends GetxController {
  bool isFirst = true;
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _addressDataList = Rx<List>([]);
  set addressDataList(value) => _addressDataList.value = value;
  List get addressDataList => _addressDataList.value;
  AddressType addressType = AddressType.address;

  String addressListBuildId = "MineAddressManager_addressListBuildId";
  // int pageNo = 1;
  // int pageSize = 10;
  // int count = 0;

  final pullCtrl = RefreshController();

  setDefaultAddress(Map data, bool isDefault) {
    Map<String, dynamic> params = {
      "id": data["id"],
      "contact_Recipient": data["recipient"],
      "province_ID": data["provinceId"],
      "city_ID": data["cityId"],
      "area_ID": data["areaId"],
      "contact_Address": data["address"],
      "contact_Mobile": data["recipientMobile"],
      "contact_Default": isDefault ? 1 : 0,
    };

    simpleRequest(
      url: Urls.userContactEdit,
      params: params,
      success: (success, json) {
        if (success) {
          ShowToast.normal(isDefault ? "设置默认地址成功" : "取消默认地址成功");
          loadAddress();
        }
      },
      after: () {},
    );
  }

  deleteContactRequest(Map<String, dynamic> params, int id,
      Function(bool success, dynamic json)? success) {
    Http().doPost(
      Urls.deleteContact(id),
      params,
      success: (json) {
        if (success != null) {
          success(true, json);
        }
      },
      fail: (reason, code, json) {
        if (success != null) {
          success(false, json);
        }
      },
    );
  }

  deleteAddress(Map data) {
    deleteContactRequest({}, data["id"], (success, json) {
      if (success) {
        loadAddress();
        ShowToast.normal("删除成功");

        // Get.find<MineAddressManagerController>().loadAddress();
        // Future.delayed(const Duration(seconds: 1), () {
        //   Get.until((route) {
        //     if (route is GetPageRoute) {
        //       if (route.binding is MineAddressManagerBinding) {
        //         return true;
        //       } else {
        //         return false;
        //       }
        //     } else {
        //       return false;
        //     }
        //   });
        // });
        loadAddress();
      }
    });
  }

  onRefresh() async {
    loadAddress();
  }

  loadAddress() {
    simpleRequest(
        url: addressType == AddressType.address
            ? Urls.userContactList
            : Urls.userNetworkContactList,
        params: {},
        success: (success, json) {
          if (success) {
            addressDataList = json["data"];
            pullCtrl.refreshCompleted();
            update([addressListBuildId]);
          } else {
            pullCtrl.refreshFailed();
          }
        },
        after: () {
          isLoading = false;
        },
        useCache: true);
  }

  dataInit(AddressType type) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    addressType = type;
    loadAddress();
  }

  @override
  void onInit() {
    super.onInit();
  }

  // onLoad() async {
  //   userContactListRequest({}, (bool success, dynamic json) {
  //     if (success) {
  //       addressDataList = json["data"];
  //       pullCtrl.refreshCompleted();
  //     } else {
  //       pullCtrl.refreshFailed();
  //     }
  //   });
  //   pullCtrl.loadComplete();
  // }
}

enum AddressType {
  address,
  branch,
}

class MineAddressManager extends GetView<MineAddressManagerController> {
  final dynamic getCtrl;
  final AddressType addressType;
  final Function(Map address)? addressCallBack;
  final bool orangeTheme;
  const MineAddressManager({
    Key? key,
    this.getCtrl,
    this.addressType = AddressType.address,
    this.addressCallBack,
    this.orangeTheme = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(addressType);
    return Scaffold(
      appBar: getDefaultAppBar(
          context, addressType == AddressType.address ? "我的收货地址" : "网点地址",
          color: Colors.white),
      body: Stack(
        children: [
          addressType == AddressType.branch
              ? const Align(
                  child: SizedBox(),
                )
              : Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 80.w + paddingSizeBottom(context),
                  child: Container(
                    color: Colors.transparent,
                    padding:
                        EdgeInsets.only(bottom: paddingSizeBottom(context)),
                    width: 375.w,
                    height: 80.w + paddingSizeBottom(context),
                    child: Center(
                      child: getSubmitBtn("新增地址", () {
                        Get.to(
                            MineAddressAdd(
                              address: null,
                              orangeTheme: orangeTheme,
                            ),
                            binding: MineAddressAddBinding());
                      },
                          color: orangeTheme
                              ? AppColor.themeOrange
                              : AppColor.theme),
                    ),
                  )),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: addressType == AddressType.branch
                  ? 0
                  : 80.w + paddingSizeBottom(context),
              child: SmartRefresher(
                  physics: const BouncingScrollPhysics(),
                  controller: controller.pullCtrl,
                  onRefresh: controller.onRefresh,
                  enablePullDown: true,
                  child: GetBuilder<MineAddressManagerController>(
                    id: controller.addressListBuildId,
                    init: controller,
                    builder: (_) {
                      return controller.addressDataList.isEmpty
                          ? GetX<MineAddressManagerController>(
                              builder: (_) {
                                return CustomEmptyView(
                                  isLoading: controller.isLoading,
                                );
                              },
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: controller.addressDataList.isNotEmpty
                                  ? controller.addressDataList.length
                                  : 0,
                              itemBuilder: (context, index) {
                                return addressCell(
                                    index, controller.addressDataList[index],
                                    (int index, Map data) {
                                  if (getCtrl != null) {
                                    if (getCtrl
                                        is ProductConfirmOrderController) {
                                      if (addressType == AddressType.address) {
                                        (getCtrl
                                                as ProductConfirmOrderController)
                                            .selectAddressLocation(data);
                                      } else if (addressType ==
                                          AddressType.branch) {
                                        (getCtrl
                                                as ProductConfirmOrderController)
                                            .selectBranchLocation(data);
                                      }

                                      Get.back();
                                    } else if (getCtrl.setAddress != null) {
                                      getCtrl.setAddress(data);
                                      Get.back();
                                    }
                                  } else if (addressCallBack != null) {
                                    addressCallBack!(data);
                                    Get.back();
                                  }
                                });
                              },
                            );
                    },
                  )))
        ],
      ),
    );
  }

  Widget cell(int index, Map data, Function(int index, Map data) onPressed) {
    return Align(
      child: Container(
        width: 345.w,
        height: 105.w,
        // height: 143.5.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: Column(
          children: [
            ghb(18),
            gwb(345),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                centRow([
                  gwb(19),
                  Visibility(
                    visible: (data["isDefault"] ?? 0) == 1,
                    child: Container(
                      width: 30.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                          color: orangeTheme
                              ? AppColor.themeOrange
                              : AppColor.theme,
                          borderRadius: BorderRadius.circular(2.w)),
                      child: Center(
                          child: getSimpleText("默认", 12, Colors.white,
                              textHeight: 1.25)),
                    ),
                  ),
                  gwb((data["isDefault"] ?? 0) == 1 ? 8 : 0),
                  getWidthText(
                      "${data["recipient"] ?? ""}   ${data["recipientMobile"] ?? ""}",
                      15,
                      AppColor.text,
                      345 - 19 - 30 - 34.5 - 8 - 5,
                      1)
                ]),
                Visibility(
                  visible: addressType == AddressType.address,
                  child: CustomButton(
                    onPressed: () {
                      Get.to(
                          MineAddressAdd(
                            address: data,
                            orangeTheme: orangeTheme,
                          ),
                          binding: MineAddressAddBinding());
                    },
                    child: SizedBox(
                      width: 18.w + 16.5.w,
                      height: 18.w,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          assetsName(
                            "common/btn_edit",
                          ),
                          width: 18.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            ghb(12),
            sbRow([
              getWidthText(
                  "${data["provinceName"]}${data["cityName"]}${data["areaName"]}${data["address"]}",
                  12,
                  AppColor.text3,
                  242,
                  2)
            ], width: 345 - 19 * 2)

            // sbhRow([
            //   centRow([
            //     getWidthText(data["recipient"] ?? "", 16, Colors.black, 60, 2),
            //     gwb(10),
            //     centClm([
            // getWidthText(
            //     "${data["provinceName"]}${data["cityName"]}${data["areaName"]}${data["address"]}",
            //     14,
            //     Colors.black,
            //     190,
            //     2)
            //     ])
            //   ]),
            // ], width: 345 - 16 * 2, height: 88),
          ],
        ),
      ),
    );
  }

  Widget slidableCell(
      int index, Map data, Function(int index, Map data) onPressed) {
    bool isDefault = data["isDefault"] == 1;
    return Slidable(
        // backgroundColor: Colors.red,
        // selectedForegroundColor: Colors.transparent,
        key: ValueKey(index),
        endActionPane: ActionPane(
            extentRatio: 0.12,
            motion: const ScrollMotion(),
            children: [
              // CustomSlidableAction(
              //   flex: 1,
              //   padding: EdgeInsets.zero,
              //   backgroundColor: Colors.transparent,
              //   foregroundColor: Colors.transparent,
              //   onPressed: (context) {
              //     controller.setDefaultAddress(data, !isDefault);
              //   },
              //   child: Container(
              //     margin: EdgeInsets.only(right: 10.w),
              //     width: 32.w,
              //     height: 105.w,
              //     color: const Color(0xFF558AF4),
              //     child: Center(
              //         child: getWidthText(isDefault ? "取消默认" : "设为默认", 12,
              //             Colors.white, 12, 4)),
              //   ),
              // ),

              // CustomButton(
              //   onPressed: () {
              //     controller.setDefaultAddress(data, !isDefault);
              //   },
              //   child: Container(
              //     margin: EdgeInsets.only(right: 10.w),
              //     width: 32.w,
              //     height: 88.w,
              //     color: const Color(0xFF558AF4),
              //     child: Center(
              //         child: getWidthText(isDefault ? "取消默认" : "设为默认", 12,
              //             Colors.white, 12, 4)),
              //   ),
              // ),

              CustomSlidableAction(
                flex: 1,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.transparent,
                onPressed: (context) {
                  controller.deleteAddress(data);
                },
                child: Container(
                  // margin: EdgeInsets.only(right: 10.w),
                  width: 45.w,
                  height: 105.w,
                  color: const Color(0xFFFB5252),
                  child: Center(
                      child: getWidthText("删除", 15, Colors.white, 12, 4)),
                ),
              )
              // CustomButton(
              //   onPressed: () {
              //     controller.deleteAddress(data);
              //   },
              //   child: Container(
              //     // margin: EdgeInsets.only(top: 15.w),
              //     width: 32.w,
              //     height: 88.w,
              //     decoration: BoxDecoration(
              //         color: const Color(0xFFFF9E6E),
              //         borderRadius: BorderRadius.horizontal(
              //             right: Radius.circular(12.w))),
              //     child: Center(
              //         child: getWidthText("删除", 12, Colors.white, 12, 4)),
              //   ),
              // )
            ]),
        // trailingActions: [
        //   SwipeAction(
        //       widthSpace: 45.w,
        //       color: Colors.white,
        //       onTap: (p0) {
        //         controller.deleteAddress(data);
        //       },
        //       content: Container(
        //         // margin: EdgeInsets.only(top: 15.w),
        //         width: 32.w,
        //         height: 88.w,
        //         decoration: BoxDecoration(
        //             color: const Color(0xFFFF9E6E),
        //             borderRadius: BorderRadius.horizontal(
        //                 right: Radius.circular(12.w))),
        //         child: Center(
        //             child: getWidthText("删除", 12, Colors.white, 12, 4)),
        //       )),
        // SwipeAction(
        //     widthSpace: 40.w,
        //     color: Colors.transparent,
        //     onTap: (p0) {
        //       controller.setDefaultAddress(data, !isDefault);
        //     },
        //     content: Container(
        //       // margin: EdgeInsets.only(top: 15.w),
        //       width: 32.w,
        //       height: 88.w,
        //       color: const Color(0xFF558AF4),
        //       child: Center(
        //           child: getWidthText(isDefault ? "取消默认" : "设为默认", 12,
        //               Colors.white, 12, 4)),
        //     ))
        // ],
        child: cell(index, data, onPressed));
  }

  Widget addressCell(
      int index, Map data, Function(int index, Map data) onPressed) {
    return Padding(
        padding: EdgeInsets.only(top: 15.w),
        child: CustomButton(
          onPressed: () => onPressed(index, data),
          child: addressType == AddressType.branch
              ? cell(index, data, onPressed)
              : slidableCell(index, data, onPressed),
        ));
  }
}
