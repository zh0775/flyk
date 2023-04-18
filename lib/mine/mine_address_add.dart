import 'package:cxhighversion2/component/app_location_manager.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MineAddressAddBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineAddressAddController>(MineAddressAddController());
  }
}

class MineAddressAddController extends GetxController {
  bool isFirst = true;
  final nameTextCtrl = TextEditingController();
  final phoneTextCtrl = TextEditingController();
  final detailTextCtrl = TextEditingController();
  FixedExtentScrollController? provincePickCtrl;
  FixedExtentScrollController? cityPickCtrl;
  FixedExtentScrollController? areaPickCtrl;

  double defaultDetailHeight = 60.0;

  final _detailHeight = 0.0.obs;
  double get detailHeight => _detailHeight.value;
  set detailHeight(v) => _detailHeight.value = v;

  final pickKey = GlobalKey();

  final _buttonEnable = true.obs;
  bool get buttonEnable => _buttonEnable.value;
  set buttonEnable(v) => _buttonEnable.value = v;

  final _isDefalut = false.obs;
  get isDefalut => _isDefalut.value;
  set isDefalut(value) => _isDefalut.value = value;

  final _addressData = Rx<List>([]);
  List get addressData => _addressData.value;
  set addressData(value) => _addressData.value = value;

  final _provinceData = Rx<Map>({});
  Map get provinceData => _provinceData.value;
  set provinceData(value) => _provinceData.value = value;

  final _cityData = Rx<Map>({});
  Map get cityData => _cityData.value;
  set cityData(value) => _cityData.value = value;

  final _areaData = Rx<Map>({});
  Map get areaData => _areaData.value;
  set areaData(value) => _areaData.value = value;

  final _provinceIndex = 0.obs;
  get provinceIndex => _provinceIndex.value;
  set provinceIndex(value) => _provinceIndex.value = value;

  final _cityIndex = 0.obs;
  get cityIndex => _cityIndex.value;
  set cityIndex(value) => _cityIndex.value = value;

  final _areaIndex = 0.obs;
  get areaIndex => _areaIndex.value;
  set areaIndex(value) => _areaIndex.value = value;

  final _submitEnable = true.obs;
  get submitEnable => _submitEnable.value;
  set submitEnable(value) => _submitEnable.value = value;

  // final

  // final _isDefalut = false.obs;
  // get isDefalut => _isDefalut.value;
  // set isDefalut(value) => _isDefalut.value = value;
  userContactListRequest(Function(bool success, dynamic json)? succ) {
    simpleRequest(
        url: Urls.getProvinceList,
        params: {},
        success: (success, json) {
          if (succ != null) {
            succ(success, json);
          }
        },
        after: () {},
        useCache: true);
  }

  userContactEditRequest(
      Map<String, dynamic> params, Function(bool success, dynamic json)? succ) {
    simpleRequest(
      url: Urls.userContactEdit,
      params: params,
      success: (success, json) {
        if (succ != null) {
          succ(success, json);
        }
      },
      after: () {},
    );
  }

  deleteContactRequest(Map<String, dynamic> params, int id,
      Function(bool success, dynamic json)? succ) {
    simpleRequest(
      url: Urls.deleteContact(id),
      params: params,
      success: (success, json) {
        if (succ != null) {
          succ(success, json);
        }
      },
      after: () {},
    );
  }

  provincePickCtrlListener() {
    // if (provinceIndex != provincePickCtrl.selectedItem) {
    //   provinceIndex = provincePickCtrl.selectedItem;
    //   provinceData = addressData[provincePickCtrl.selectedItem];
    //   cityIndex = 0;
    //   areaIndex = 0;
    //   cityPickCtrl.animateToItem(cityIndex,
    //       duration: const Duration(milliseconds: 200),
    //       curve: Curves.linearToEaseOut);
    //   areaPickCtrl.animateToItem(areaIndex,
    //       duration: const Duration(milliseconds: 200),
    //       curve: Curves.linearToEaseOut);
    // }
  }

  cityPickCtrlListener() {
    // if (cityIndex != cityPickCtrl.selectedItem) {
    //   cityIndex = cityPickCtrl.selectedItem;
    //   cityData = provinceData["child"][cityIndex];
    //   areaIndex = 0;
    //   areaPickCtrl.animateToItem(areaIndex,
    //       duration: const Duration(milliseconds: 200),
    //       curve: Curves.linearToEaseOut);
    // }
  }

  areaPickCtrlListener() {
    // if (areaIndex != areaPickCtrl.selectedItem) {
    //   areaIndex = areaPickCtrl.selectedItem;
    //   areaData = cityData["child"][areaIndex];
    // }
  }

  Map? myData;

  Function(Map data)? addressCallBack;
  bool formOther = false;

  dataInit(Map? data, Function(Map data)? callBack, bool? form) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    myData = data;
    addressCallBack = callBack;
    formOther = form ?? false;
    if (myData != null && myData!.isNotEmpty) {
      nameTextCtrl.text = myData!["recipient"];
      phoneTextCtrl.text = myData!["recipientMobile"];
      detailTextCtrl.text = myData!["address"];
      isDefalut = (myData!["isDefault"] == 1 ? true : false);
    } else {
      // appLocationManager = AppLocationManager();
      // appLocationManager?.regist(
      //   onLocationChanged: (result) {
      //     locationResult = result;
      //     locationFormat();
      //   },
      // );
    }

    userContactListRequest((bool success, dynamic json) {
      if (success) {
        addressData = json["data"] ?? [];
        if (myData != null) {
          for (var i = 0; i < addressData.length; i++) {
            if ("${addressData[i]["id"]}" == "${myData!["provinceId"]}") {
              provinceData = addressData[i];
              provinceIndex = i;
              break;
            }
          }

          if (provinceData != null &&
              provinceData["child"] != null &&
              provinceData["child"] is List) {
            List tmpCitys = provinceData["child"];
            for (var i = 0; i < tmpCitys.length; i++) {
              if ("${tmpCitys[i]["id"]}" == "${myData!["cityId"]}") {
                cityData = tmpCitys[i];
                cityIndex = i;
                break;
              }
            }
          }
          if (cityData != null &&
              cityData["child"] != null &&
              cityData["child"] is List) {
            List tmpAreas = cityData["child"];
            for (var i = 0; i < tmpAreas.length; i++) {
              if ("${tmpAreas[i]["id"]}" == "${myData!["areaId"]}") {
                areaData = tmpAreas[i];
                areaIndex = i;
                break;
              }
            }
          }
        } else {
          locationFormat();
        }
      }
    });
  }

  locationFormat() {
    if (locationResult.isNotEmpty) {
      for (var i = 0; i < addressData.length; i++) {
        String lProvince = ((locationResult["province"] ?? "") as String);
        String province = addressData[i]["text"] ?? "";
        if (lProvince.isNotEmpty && province.isNotEmpty) {
          if (lProvince.contains(province) || province.contains(lProvince)) {
            provinceIndex = i;
            provinceData = addressData[provinceIndex];
            break;
          }
        }
      }
      if (provinceData.isEmpty) {
        provinceData = addressData[provinceIndex];
      }

      for (var i = 0; i < (provinceData["child"] ?? []).length; i++) {
        String lCity = ((locationResult["city"] ?? "") as String);
        String city = (provinceData["child"] ?? [])[i]["text"] ?? "";
        if (lCity.isNotEmpty && city.isNotEmpty) {
          if (lCity.contains(city) || city.contains(lCity)) {
            cityIndex = i;
            cityData = (provinceData["child"] ?? [])[cityIndex];
            break;
          }
        }
      }
      if (cityData.isEmpty) {
        cityData = (provinceData["child"] ?? [])[provinceIndex];
      }
      for (var i = 0; i < (cityData["child"] ?? []).length; i++) {
        String lArea = ((locationResult["district"] ?? "") as String);
        String area = (cityData["child"] ?? [])[i]["text"] ?? "";
        if (lArea.isNotEmpty && area.isNotEmpty) {
          if (lArea.contains(area) || area.contains(lArea)) {
            areaIndex = i;
            areaData = (cityData["child"] ?? [])[areaIndex];
            break;
          }
        }
      }
      if (areaData.isEmpty) {
        areaData = (cityData["child"] ?? [])[areaIndex];
      }
    } else {
      provinceData = addressData[provinceIndex];
      cityData = provinceData["child"][cityIndex];
      areaData = cityData["child"][areaIndex];
    }
  }

  deleteAddress() {
    if (myData == null) {
      return;
    }
    deleteContactRequest({}, myData!["id"], (success, json) {
      if (success) {
        ShowToast.normal("删除成功");
        Get.find<MineAddressManagerController>().loadAddress();
        Future.delayed(const Duration(seconds: 1), () {
          Get.until((route) {
            if (route is GetPageRoute) {
              if (route.binding is MineAddressManagerBinding) {
                return true;
              } else {
                return false;
              }
            } else {
              return false;
            }
          });
        });
      }
    });
  }

  saveAddress() {
    if (nameTextCtrl.text.isEmpty) {
      ShowToast.normal("请输入收货人姓名");
      return;
    }
    if (phoneTextCtrl.text.isEmpty) {
      ShowToast.normal("请输入收货人手机号");
      return;
    }
    if (!isMobilePhoneNumber(phoneTextCtrl.text)) {
      ShowToast.normal("请输入正确的手机号");
      return;
    }
    if (detailTextCtrl.text.isEmpty) {
      ShowToast.normal("请输入详细地址");
      return;
    }
    if (detailTextCtrl.text.length > 30 || detailTextCtrl.text.length < 6) {
      ShowToast.normal("详细地址需最少6位，最大30位");
      return;
    }

    Map<String, dynamic> params = {
      "id": myData != null ? myData!["id"] : 0,
      "contact_Recipient": nameTextCtrl.text,
      "province_ID": provinceData["id"] is String
          ? int.parse(provinceData["id"])
          : provinceData["id"],
      "city_ID":
          cityData["id"] is String ? int.parse(cityData["id"]) : cityData["id"],
      "area_ID":
          areaData["id"] is String ? int.parse(areaData["id"]) : areaData["id"],
      "contact_Address": detailTextCtrl.text,
      "contact_Mobile": phoneTextCtrl.text,
      "contact_Default": isDefalut ? 1 : 0,
    };
    if (formOther) {
      if (addressCallBack != null) {
        addressCallBack!({
          "name": nameTextCtrl.text,
          "phone": phoneTextCtrl.text,
          "address":
              "${provinceData.isNotEmpty ? provinceData["text"] : ""}${cityData.isNotEmpty ? cityData["text"] : ""}${areaData.isNotEmpty ? areaData["text"] : ""}${detailTextCtrl.text}"
        });
        Get.back();
      }
    } else {
      submitEnable = false;
      userContactEditRequest(params, (success, json) {
        submitEnable = true;
        if (success) {
          ShowToast.normal("保存地址成功");
          Get.find<MineAddressManagerController>().loadAddress();
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      });
    }
  }

  checkDetailHeight() {
    double width = (270 - 16 * 2).w;
    if (detailTextCtrl.text.isNotEmpty) {
      double height = calculateTextHeight(detailTextCtrl.text, 14,
          FontWeight.normal, width, 1000, Global.navigatorKey.currentContext!);
      // height += 20;
      if (height < defaultDetailHeight) {
        height = defaultDetailHeight;
      }
      if (detailHeight != height) {
        detailHeight = height;
      }
    }
  }

  String locationBuildId = "MineAddressAdd_locationBuildId";
  // AppLocationManager? appLocationManager;
  Map<String, Object> locationResult = {};

  @override
  void onInit() {
    detailTextCtrl.addListener(checkDetailHeight);

    detailHeight = defaultDetailHeight;

    // provincePickCtrl.addListener(provincePickCtrlListener);
    // cityPickCtrl.addListener(cityPickCtrlListener);
    // areaPickCtrl.addListener(areaPickCtrlListener);
    super.onInit();
  }

  @override
  void onClose() {
    detailTextCtrl.removeListener(checkDetailHeight);
    nameTextCtrl.dispose();
    phoneTextCtrl.dispose();
    detailTextCtrl.dispose();
    // provincePickCtrl.removeListener(provincePickCtrlListener);
    // cityPickCtrl.removeListener(cityPickCtrlListener);
    // areaPickCtrl.removeListener(areaPickCtrlListener);
    if (provincePickCtrl != null) {
      provincePickCtrl!.dispose();
    }
    if (cityPickCtrl != null) {
      cityPickCtrl!.dispose();
    }
    if (areaPickCtrl != null) {
      areaPickCtrl!.dispose();
    }
    // appLocationManager?.dispose();
    super.onClose();
  }
}

class MineAddressAdd extends GetView<MineAddressAddController> {
  final Map? address;
  final Function(Map address)? addressCallBack;
  final bool fromOther;
  final bool orangeTheme;
  const MineAddressAdd(
      {Key? key,
      this.address,
      this.addressCallBack,
      this.fromOther = false,
      this.orangeTheme = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(address, addressCallBack, fromOther);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, address != null ? "修改地址" : "新增地址",
            color: Colors.white),
        body: getInputBodyNoBtn(context,
            buttonHeight: paddingSizeBottom(context) + 80.w,
            submitBtn: GetX<MineAddressAddController>(
          builder: (_) {
            return getSubmitBtn("保存", () {
              controller.saveAddress();
            },
                enable: controller.buttonEnable,
                color: orangeTheme ? AppColor.themeOrange : AppColor.theme,
                height: 45);
          },
        ), children: [
          ghb(23),
          input(0),
          input(1),
          input(2),
          input(3),
          ghb(15),
          Container(
            width: 345.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Center(
              child: sbRow([
                getSimpleText("设为默认地址", 14, AppColor.text),
                Transform.scale(
                  scaleY: 0.8,
                  scaleX: 0.85,
                  child: GetX<MineAddressAddController>(
                    builder: (_) {
                      return CupertinoSwitch(
                        value: controller.isDefalut,
                        onChanged: (value) {
                          controller.isDefalut = value;
                        },
                      );
                    },
                  ),
                )
              ], width: 345 - 15 * 2),
            ),
          )
        ]),
      ),
    );
  }

  Widget input(
    int index,
  ) {
    String placeholder = "";
    TextEditingController ctrl;
    int? maxLength;
    TextInputType textInputType;
    String title = "";
    switch (index) {
      case 0:
        placeholder = "请输入收货人信息";
        ctrl = controller.nameTextCtrl;
        textInputType = TextInputType.text;
        title = "联系人";
        break;
      case 1:
        placeholder = "请输入手机号";
        maxLength = 11;
        ctrl = controller.phoneTextCtrl;
        textInputType = TextInputType.phone;
        title = "手机号";
        break;
      case 3:
        placeholder = "请输入详细地址";
        ctrl = controller.detailTextCtrl;
        textInputType = TextInputType.text;
        title = "详细地址";
        break;
      default:
        title = "地区";
        ctrl = TextEditingController();
        textInputType = TextInputType.text;
    }

    return Container(
        width: 345.w,
        padding: EdgeInsets.only(top: index == 0 ? 12.w : 0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(index == 0 ? 8.w : 0),
                bottom: Radius.circular(index == 3 ? 8.w : 0))),
        child: Row(
          crossAxisAlignment:
              index == 3 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 19.w),
              child: SizedBox(
                width: 70.w,
                height: 45.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: getSimpleText(title, 14, AppColor.text3),
                ),
              ),
            ),
            gwb(14.5),
            index == 2
                ? CustomButton(
                    onPressed: () {
                      showAddressPick();
                    },
                    child: centRow([
                      SizedBox(
                        width: 215.w,
                        height: 45.w,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: GetX<MineAddressAddController>(
                              builder: (_) {
                                return getSimpleText(
                                    "${controller.provinceData.isNotEmpty ? controller.provinceData["text"] : ""} ${controller.cityData.isNotEmpty ? controller.cityData["text"] : ""} ${controller.areaData.isNotEmpty ? controller.areaData["text"] : ""}",
                                    14,
                                    AppColor.text);
                              },
                            )),
                      ),
                      Image.asset(
                        assetsName("statistics/icon_arrow_right_gray"),
                        width: 18.w,
                        fit: BoxFit.fitWidth,
                      )
                    ]),
                  )
                : index != 3
                    ? CustomInput(
                        width: (270 - 16 * 2).w,
                        heigth: 45.w,
                        maxLength: maxLength,
                        placeholder: placeholder,
                        keyboardType: textInputType,
                        textEditCtrl: ctrl,
                        style: TextStyle(color: AppColor.text, fontSize: 14.sp),
                      )
                    : GetX<MineAddressAddController>(
                        builder: (_) {
                          return Padding(
                            padding: EdgeInsets.only(top: 15.w),
                            child: CustomInput(
                              width: (270 - 16 * 2).w,
                              // heigth: 45.w,
                              heigth: controller.detailHeight.w,
                              placeholder: placeholder,
                              maxLines: maxLength,
                              keyboardType: textInputType,
                              textEditCtrl: ctrl,
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.top,
                              style: TextStyle(
                                  color: AppColor.text, fontSize: 14.sp),
                            ),
                          );
                        },
                      )
          ],
        ));
  }

  Widget areaView(String title, int index) {
    return Container(
      width: 80.w,
      height: 40.w,
      decoration: getDefaultWhiteDec2(),
      child: Center(
        child: sbhRow([
          getSimpleText(
              title.isEmpty
                  ? (index == 0
                      ? "省"
                      : index == 1
                          ? "市"
                          : "区")
                  : title,
              14,
              title.isEmpty ? const Color(0xFF7B8A99) : AppColor.textBlack),
          Image.asset(
            assetsName("common/icon_address_down_arrow"),
            width: 16.w,
            fit: BoxFit.fitWidth,
          )
        ], width: 80 - 8 * 2, height: 40),
      ),
    );
  }

  void showAddressPick() {
    if (controller.provincePickCtrl != null) {
      controller.provincePickCtrl!.dispose();
    }
    if (controller.cityPickCtrl != null) {
      controller.cityPickCtrl!.dispose();
    }
    if (controller.areaPickCtrl != null) {
      controller.areaPickCtrl!.dispose();
    }

    controller.provincePickCtrl =
        FixedExtentScrollController(initialItem: controller.provinceIndex);
    controller.cityPickCtrl =
        FixedExtentScrollController(initialItem: controller.cityIndex);
    controller.areaPickCtrl =
        FixedExtentScrollController(initialItem: controller.areaIndex);

    Get.bottomSheet(
        SizedBox(
          width: 375.w,
          height: 216.w,
          child: Row(
            children: [
              SizedBox(
                  width: 375.w / 3,
                  height: 216.w,
                  child: GetX<MineAddressAddController>(
                    init: controller,
                    builder: (_) {
                      return CupertinoPicker.builder(
                        itemExtent: 40.w,
                        // scrollController: controller.provincePickCtrl,
                        scrollController: controller.provincePickCtrl,
                        childCount: controller.addressData.isNotEmpty
                            ? controller.addressData.length
                            : 0,
                        onSelectedItemChanged: (value) {
                          controller.cityIndex = 0;
                          controller.areaIndex = 0;
                          controller.provinceIndex = value;
                          controller.provinceData =
                              controller.addressData[value];
                          controller.cityData = controller.provinceData["child"]
                              [controller.cityIndex];
                          controller.areaData = controller.cityData["child"]
                              [controller.areaIndex];
                          controller.cityPickCtrl!.animateToItem(
                              controller.cityIndex,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.linearToEaseOut);
                          controller.areaPickCtrl!.animateToItem(
                              controller.areaIndex,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.linearToEaseOut);
                        },
                        itemBuilder: (context, index) {
                          return GetX<MineAddressAddController>(
                            init: controller,
                            builder: (_) {
                              return Center(
                                child: getSimpleText(
                                    controller.addressData[index]["text"],
                                    index == controller.provinceIndex ? 18 : 16,
                                    index == controller.provinceIndex
                                        ? AppColor.textBlack
                                        : AppColor.textGrey,
                                    isBold: index == controller.provinceIndex),
                              );
                            },
                          );
                        },
                      );
                    },
                  )),
              SizedBox(
                  width: 375.w / 3,
                  height: 216.w,
                  child: GetX<MineAddressAddController>(
                    init: controller,
                    builder: (_) {
                      List cityList = controller.provinceData != null &&
                              controller.provinceData["child"] != null &&
                              controller.provinceData["child"] is List
                          ? controller.provinceData["child"]
                          : [];
                      return CupertinoPicker.builder(
                        itemExtent: 40.w,
                        scrollController: controller.cityPickCtrl,
                        childCount: cityList.isNotEmpty ? cityList.length : 0,
                        onSelectedItemChanged: (value) {
                          controller.areaIndex = 0;
                          controller.cityIndex = value;
                          controller.cityData = cityList[value];
                          controller.areaData = controller.cityData["child"]
                              [controller.areaIndex];
                          controller.areaPickCtrl!.animateToItem(
                              controller.areaIndex,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.linearToEaseOut);
                        },
                        itemBuilder: (context, index) {
                          return GetX<MineAddressAddController>(
                            init: controller,
                            builder: (_) {
                              return Center(
                                child: getSimpleText(
                                    cityList[index]["text"],
                                    index == controller.cityIndex ? 18 : 16,
                                    index == controller.cityIndex
                                        ? AppColor.textBlack
                                        : AppColor.textGrey,
                                    isBold: index == controller.cityIndex),
                              );
                            },
                          );
                        },
                      );
                    },
                  )),
              SizedBox(
                  width: 375.w / 3,
                  height: 216.w,
                  child: GetX<MineAddressAddController>(
                    init: controller,
                    builder: (_) {
                      List areaList = controller.cityData != null &&
                              controller.cityData["child"] != null &&
                              controller.cityData["child"] is List
                          ? controller.cityData["child"]
                          : [];
                      return CupertinoPicker.builder(
                        itemExtent: 40.w,
                        scrollController: controller.areaPickCtrl,
                        childCount: areaList.isNotEmpty ? areaList.length : 0,
                        onSelectedItemChanged: (value) {
                          controller.areaIndex = value;
                          controller.areaData = areaList[value];
                        },
                        itemBuilder: (context, index) {
                          return GetX<MineAddressAddController>(
                            init: controller,
                            builder: (_) {
                              return Center(
                                child: getSimpleText(
                                    areaList[index]["text"],
                                    index == controller.areaIndex ? 18 : 16,
                                    index == controller.areaIndex
                                        ? AppColor.textBlack
                                        : AppColor.textGrey,
                                    isBold: index == controller.areaIndex),
                              );
                            },
                          );
                        },
                      );
                    },
                  )),
            ],
          ),
        ),
        backgroundColor: Colors.white);
  }
}
