import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatisticsUserManageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsUserManageController>(
        StatisticsUserManageController(datas: Get.arguments));
  }
}

class StatisticsUserManageController extends GetxController {
  final dynamic datas;
  StatisticsUserManageController({this.datas});

  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();

  RefreshController pullCtrl = RefreshController();
  CustomDropDownController filterCtrl1 = CustomDropDownController();
  CustomDropDownController filterCtrl2 = CustomDropDownController();
  final searchInputCtrl = TextEditingController();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _filterIdx = (-1).obs;
  int get filterIdx => _filterIdx.value;
  set filterIdx(v) => _filterIdx.value = v;

  final _isRegistDesc = true.obs;
  bool get isRegistDesc => _isRegistDesc.value;
  set isRegistDesc(v) => _isRegistDesc.value = v;

  List timeFilterList = [
    {"id": 0, "name": "全部"},
    {"id": 1, "name": "近7日"},
    {"id": 2, "name": "近15日"},
    {"id": 3, "name": "近30日"},
  ];
  final _timeFilterIdx = 0.obs;
  int get timeFilterIdx => _timeFilterIdx.value;
  set timeFilterIdx(v) {
    if (_timeFilterIdx.value != v) {
      _timeFilterIdx.value = v;
      loadData();
    }
  }

  final _openTimeFilte = false.obs;
  bool get openTimeFilte => _openTimeFilte.value;
  set openTimeFilte(v) => _openTimeFilte.value = v;

  List jxFilterDatas = [
    {"id": 0, "name": "全部"},
    {"id": 0, "name": "机型1"},
    {"id": 0, "name": "机型2"},
    {"id": 0, "name": "机型3"},
    {"id": 0, "name": "机型4"},
  ];
  final _jxFilterIdx = (-1).obs;
  int get jxFilterIdx => _jxFilterIdx.value;
  set jxFilterIdx(v) => _jxFilterIdx.value = v;
  int realJxFilterIdx = -1;

  List sfFilterDatas = [
    {"id": 0, "name": "全部"},
    {"id": 1, "name": "商户"},
    {"id": 2, "name": "合伙人"},
    {"id": 3, "name": "盘主"},
    {"id": 4, "name": "运营中心"},
  ];
  final _sfFilterIdx = (-1).obs;
  int get sfFilterIdx => _sfFilterIdx.value;
  set sfFilterIdx(v) => _sfFilterIdx.value = v;
  int realSfFilterIdx = -1;

  List ztFilterDatas = [];
  final _ztFilterIdx = (-1).obs;
  int get ztFilterIdx => _ztFilterIdx.value;
  set ztFilterIdx(v) => _ztFilterIdx.value = v;
  int realZtFilterIdx = -1;

  int userType = 0;
  List dataList = [];
  Map mainData = {};

  String title = "";

  int pageSize = 20;
  int pageNo = 1;
  int count = 0;

  filterSelectAction(int index, int clickIdx) {
    if (userType == 0) {
      if (index == 0) {
        sfFilterIdx = clickIdx;
        realSfFilterIdx = sfFilterIdx;
      } else {
        ztFilterIdx = clickIdx;
        realZtFilterIdx = ztFilterIdx;
      }
    } else if (userType == 1 || userType == 2 || userType == 4) {
      ztFilterIdx = clickIdx;
      realZtFilterIdx = ztFilterIdx;
    } else if (userType == 3) {
      if (index == 0) {
        ztFilterIdx = clickIdx;
        realZtFilterIdx = ztFilterIdx;
      } else {
        jxFilterIdx = clickIdx;
        realJxFilterIdx = jxFilterIdx;
      }
    }
    showFilter(index);
    loadData();
  }

  filterSort(int idx) {
    if (idx == 3) {
      isRegistDesc = !isRegistDesc;
      loadData();
    }

    loadData();
  }

  showFilter(int idx) {
    if (filterCtrl1.isShow) {
      filterCtrl1.hide();
      return;
    }
    if (filterCtrl2.isShow) {
      filterCtrl2.hide();
      return;
    }
    idx == 0
        ? filterCtrl1.show(stackKey, headKey)
        : filterCtrl2.show(stackKey, headKey);
    filterIdx = idx;
    // filterHeight =
    //     (filterIdx == 0 ? machineTypes.length : currentTypes.length) * 40.0;
    // showFilter();
  }

  loadLeaderOpenData(Map data, Function(bool succ)? result) {
    int userId = data["user_ID"] ?? -1;
    if (userId == -1) {
      ShowToast.normal("数据出现错误，请稍后再试");
      return;
    }
    simpleRequest(
      url: Urls.userTeamByLeaderShow(userId),
      params: {},
      success: (success, json) {
        if (success) {
          Map oData = json["data"] ?? {};
          data["open"] = true;
          data["openData"] = oData;
          update();
        }

        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }

  loadLeaderBottomData(Map data, Function(bool succ, List datas)? result) {
    int userId = data["user_ID"] ?? -1;
    if (userId == -1) {
      ShowToast.normal("数据出现错误，请稍后再试");
      return;
    }
    simpleRequest(
      url: Urls.userTeamByInventoryShow(userId),
      params: {},
      success: (success, json) {
        List oDatas = [];
        if (success) {
          oDatas = json["data"] ?? [];
        }

        if (result != null) {
          result(success, oDatas);
        }
      },
      after: () {},
    );
  }

  searchAction() {
    loadData(searchStr: searchInputCtrl.text);
  }

  loadData({bool isLoad = false, String? searchStr}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }

    String url = "";
    switch (userType) {
      case 0:
        url = Urls.userTeamByPeopleList;
        break;
      case 1:
      case 2:
      case 4:
        url = Urls.userTeamByLeaderList;
        break;
      case 3:
        url = Urls.userMerchantDetail;
        break;
    }
    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
    };

    if (searchInputCtrl.text.isNotEmpty) {
      // if (searchStr != null && searchStr.isNotEmpty) {
      if (userType == 3) {
        params["tmName"] = searchInputCtrl.text;
      } else {
        params["userInfo"] = searchInputCtrl.text;
      }
    }
    if (userType == 0) {
      params["uFlag"] =
          ztFilterDatas[realZtFilterIdx < 0 ? 0 : realZtFilterIdx]["id"];
      params["levelType"] =
          sfFilterDatas[realSfFilterIdx < 0 ? 0 : realSfFilterIdx]["id"];
    } else if (userType == 1 || userType == 2) {
      params["levelType"] = userType == 2 ? 1 : 2;
      params["typeTime"] = timeFilterList[timeFilterIdx]["id"];
      params["timeSort"] = isRegistDesc ? 0 : 1;
      params["uFlag"] =
          ztFilterDatas[realZtFilterIdx < 0 ? 0 : realZtFilterIdx]["id"];
    } else if (userType == 3) {
      params["tmInTime"] = isRegistDesc ? 1 : 0;
      params["status"] =
          ztFilterDatas[realZtFilterIdx < 0 ? 0 : realZtFilterIdx]["id"];
      if (realJxFilterIdx > 0) {
        params["tcId"] =
            jxFilterDatas[realJxFilterIdx < 0 ? 0 : realJxFilterIdx]["id"];
      }
    }

    simpleRequest(
      url: url,
      params: params,
      success: (success, json) {
        if (success) {
          mainData = json["data"] ?? {};
          Map data = {};
          // 用户
          if (userType == 0) {
            data = mainData;
            // 盘主、合伙人
          } else if (userType == 1 || userType == 2 || userType == 4) {
            data = mainData["userTeamLeaderData"] ?? {};
            // 商户
          } else {
            data = mainData;
          }
          count = data["count"] ?? 0;
          List tmpDatas = data["data"] ?? [];
          dataList = isLoad ? [...dataList, ...tmpDatas] : tmpDatas;
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

  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
  DateFormat dateFormat2 = DateFormat("yyyy-MM-dd");
  String cellDateFormat(String dateStr) {
    if (dateStr.isEmpty) {
      return "";
    }
    return dateFormat2.format(dateFormat.parse(dateStr));
  }

  dataFormat() {
    switch (userType) {
      case 0:
        title = "用户管理";
        break;
      case 1:
        title = "盘主管理";
        break;
      case 2:
        title = "合伙人管理";
        break;
      case 3:
        title = "商户管理";
        break;
      case 4:
        title = "商家管理";
        break;
      default:
    }

    if (userType == 0) {
      ztFilterDatas = [
        {"id": 0, "name": "全部"},
        {"id": 1, "name": "已激活"},
        {"id": 2, "name": "未激活"},
        {"id": 3, "name": "禁止提现"},
        {"id": 4, "name": "禁止登录"},
      ];
    } else if (userType == 1 || userType == 2 || userType == 4) {
      ztFilterDatas = [
        {"id": -1, "name": "全部"},
        {"id": 1, "name": "无效"},
        {"id": 2, "name": "有效"},
      ];
    } else if (userType == 3) {
      ztFilterDatas = [
        {"id": 0, "name": "全部"},
        {"id": 1, "name": "未激活"},
        {"id": 2, "name": "已激活"},
      ];

      Map publicHomeData = AppDefault().publicHomeData;
      if (publicHomeData.isNotEmpty &&
          publicHomeData["terminalMod"].isNotEmpty &&
          publicHomeData["terminalMod"] is List) {
        List tmpList = publicHomeData["terminalMod"];
        jxFilterDatas = [
          {"id": -1, "name": "全部"}
        ];
        List xh = List.generate(tmpList.length, (index) {
          Map e = tmpList[index];
          return {
            "id": e["enumValue"],
            "name": e["enumName"],
          };
        });
        jxFilterDatas = [...jxFilterDatas, ...xh];
      }
    }
  }

  @override
  void onInit() {
    userType = (datas ?? {})["type"] ?? 0;
    dataFormat();
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    pullCtrl.dispose();
    filterCtrl1.dispose();
    filterCtrl2.dispose();
    searchInputCtrl.dispose();
    super.onClose();
  }
}

class StatisticsUserManage extends GetView<StatisticsUserManageController> {
  const StatisticsUserManage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, controller.title),
        body: Stack(
          key: controller.stackKey,
          children: [
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 55.w,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      gwb(375),
                      ghb(5.5),
                      Container(
                        width: 345.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                            color: AppColor.pageBackgroundColor,
                            borderRadius: BorderRadius.circular(20.w)),
                        child: Row(
                          children: [
                            gwb(20),
                            CustomInput(
                              textEditCtrl: controller.searchInputCtrl,
                              width: (345 - 20 - 62 - 1 - 0.1).w,
                              heigth: 40.w,
                              placeholder: "请输入想要搜索的名称或手机号",
                              placeholderStyle: TextStyle(
                                  fontSize: 12.sp, color: AppColor.assisText),
                              style: TextStyle(
                                  fontSize: 12.sp, color: AppColor.text),
                              onSubmitted: (p0) {
                                takeBackKeyboard(context);
                                controller.searchAction();
                              },
                            ),
                            CustomButton(
                              onPressed: () {
                                takeBackKeyboard(context);
                                controller.searchAction();
                              },
                              child: SizedBox(
                                width: 62.w,
                                height: 40.w,
                                child: Center(
                                  child: Image.asset(
                                    assetsName("machine/icon_search"),
                                    width: 18.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )),
            controller.userType == 1 ||
                    controller.userType == 2 ||
                    controller.userType == 4
                ? Positioned(
                    top: 55.w,
                    left: 0,
                    right: 0,
                    height: 150.w,
                    child: peopleView())
                : gemp(),
            Positioned(
                top: 55.w +
                    (controller.userType == 1 ||
                            controller.userType == 2 ||
                            controller.userType == 4
                        ? 150.w
                        : 0),
                left: 0,
                right: 0,
                height: 50.w,
                key: controller.headKey,
                child: Container(
                  color: Colors.white,
                  child: filterFormatBtn(),
                )),
            Positioned.fill(
                top: 105.w +
                    (controller.userType == 1 ||
                            controller.userType == 2 ||
                            controller.userType == 4
                        ? 150.w
                        : 0),
                child: GetBuilder<StatisticsUserManageController>(
                  builder: (_) {
                    return SmartRefresher(
                      controller: controller.pullCtrl,
                      onLoading: () => controller.loadData(isLoad: true),
                      onRefresh: () => controller.loadData(),
                      enablePullUp:
                          controller.count > controller.dataList.length,
                      child: controller.dataList.isEmpty
                          ? GetX<StatisticsUserManageController>(
                              builder: (controller) {
                                return CustomEmptyView(
                                  isLoading: controller.isLoading,
                                );
                              },
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: 20.w),
                              itemCount: controller.dataList.length,
                              itemBuilder: (context, index) {
                                if (controller.userType == 1 ||
                                    controller.userType == 2 ||
                                    controller.userType == 4) {
                                  return teamListCell(
                                      index, controller.dataList[index]);
                                } else if (controller.userType == 3) {
                                  return businessListCell(
                                      index, controller.dataList[index]);
                                } else {
                                  return userListCell(
                                      index, controller.dataList[index]);
                                }
                              },
                            ),
                    );
                  },
                )),
            dropView(0),
            dropView(1),
          ],
        ),
      ),
    );
  }

  Widget filterBtn(
    String title,
    int filterIdx,
    int index,
    List filterList, {
    double? width,
    int count = 2,
    bool sort = false,
  }) {
    return CustomButton(
      onPressed: () {
        if (sort) {
          controller.filterSort(filterIdx);
        } else {
          controller.showFilter(filterIdx);
        }
      },
      child: SizedBox(
        // width: width ?? (375 - 20 * 2).w / count - 0.1.w,
        height: 50.w,
        child: centRow([
          getSimpleText(
              sort
                  ? title
                  : index == -1
                      ? title
                      : filterList[index]["name"],
              15,
              sort || index >= 0 || controller.filterIdx == filterIdx
                  ? AppColor.text2
                  : AppColor.text3,
              isBold: true),
          gwb(5),
          sort
              ? GetX<StatisticsUserManageController>(
                  builder: (_) {
                    return AnimatedRotation(
                      turns: controller.isRegistDesc ? 1 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: Image.asset(
                        assetsName(
                            "statistics/machine/icon_filter_down_selected_arrow"),
                        width: 6.w,
                        fit: BoxFit.fitWidth,
                      ),
                    );
                  },
                )
              : Image.asset(
                  assetsName(
                      "statistics/machine/icon_filter_down_${index >= 0 || controller.filterIdx == filterIdx ? "selected" : "normal"}_arrow"),
                  width: 6.w,
                  fit: BoxFit.fitWidth,
                )
        ]),
      ),
    );
  }

  Widget dropView(int index) {
    double height = 0;

    if (controller.userType == 0) {
      if (index == 0) {
        height = controller.sfFilterDatas.length * 40.0.w;
      } else {
        height = controller.ztFilterDatas.length * 40.0.w;
      }
    } else if (controller.userType == 1 ||
        controller.userType == 2 ||
        controller.userType == 4) {
      height = controller.ztFilterDatas.length * 40.0.w;
    } else if (controller.userType == 3) {
      if (index == 0) {
        height = controller.ztFilterDatas.length * 40.0.w;
      } else {
        height = controller.jxFilterDatas.length * 40.0.w;
      }
    }

    return CustomDropDownView(
        dropDownCtrl:
            index == 0 ? controller.filterCtrl1 : controller.filterCtrl2,
        height: height,
        dropdownMenuChange: (isShow) {
          if (!isShow) {
            controller.filterIdx = -1;
          }
        },
        dropWidget: GetX<StatisticsUserManageController>(
          builder: (_) {
            List datas = [];
            int idx = 0;
            if (controller.userType == 0) {
              if (index == 0) {
                datas = controller.sfFilterDatas;
                idx = controller.sfFilterIdx;
              } else {
                datas = controller.ztFilterDatas;
                idx = controller.ztFilterIdx;
              }
            } else if (controller.userType == 1 ||
                controller.userType == 2 ||
                controller.userType == 4) {
              datas = controller.ztFilterDatas;
              idx = controller.ztFilterIdx;
            } else if (controller.userType == 3) {
              if (index == 0) {
                datas = controller.ztFilterDatas;
                idx = controller.ztFilterIdx;
              } else {
                datas = controller.jxFilterDatas;
                idx = controller.jxFilterIdx;
              }
            }
            return filterView(
              datas,
              idx,
              onPressed: (clickIdx) {
                controller.filterSelectAction(index, clickIdx);
              },
            );
          },
        ));
  }

  Widget filterView(List filterList, int selectIdx,
      {Function(int clickIdx)? onPressed}) {
    return Container(
      color: Colors.white,
      height: filterList.length * 40.0.w,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(
              filterList.length,
              (index) => CustomButton(
                    onPressed: () {
                      if (onPressed != null) {
                        onPressed(index);
                      }
                    },
                    child: sbhRow([
                      getSimpleText(
                          filterList[index]["name"], 14, AppColor.text2),
                      selectIdx == index
                          ? Image.asset(
                              assetsName("machine/icon_type_selected"),
                              width: 15.w,
                              fit: BoxFit.fitWidth,
                            )
                          : gwb(0)
                    ], width: 375 - 15 * 2, height: 40),
                  )),
        ),
      ),
    );
  }

  Widget filterFormatBtn() {
    if (controller.userType == 0) {
      return centRow([
        GetX<StatisticsUserManageController>(
          builder: (_) {
            return filterBtn(
              "按身份",
              0,
              controller.sfFilterIdx,
              controller.sfFilterDatas,
            );
          },
        ),
        gwb(100),
        GetX<StatisticsUserManageController>(
          builder: (_) {
            return filterBtn(
                "按状态", 1, controller.ztFilterIdx, controller.ztFilterDatas);
          },
        ),
      ]);
    } else if (controller.userType == 1 ||
        controller.userType == 2 ||
        controller.userType == 4) {
      return centRow([
        filterBtn(
          "按注册时间",
          3,
          -1,
          [],
          count: 3,
          sort: true,
        ),
        gwb(100),
        GetX<StatisticsUserManageController>(
          builder: (_) {
            return filterBtn(
                "按状态", 0, controller.ztFilterIdx, controller.ztFilterDatas,
                count: 3);
          },
        ),
      ]);
    } else if (controller.userType == 3) {
      return centRow([
        filterBtn(
          "按注册时间",
          3,
          -1,
          [],
          count: 3,
          sort: true,
        ),
        gwb(50),
        GetX<StatisticsUserManageController>(
          builder: (_) {
            return filterBtn(
                "按状态", 0, controller.ztFilterIdx, controller.ztFilterDatas,
                count: 3);
          },
        ),
        gwb(50),
        GetX<StatisticsUserManageController>(
          builder: (_) {
            return filterBtn(
                "按机型", 1, controller.jxFilterIdx, controller.jxFilterDatas,
                count: 3);
          },
        ),
      ]);
    }

    return gemp();
  }

  Widget peopleView() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom:
                  BorderSide(width: 1.w, color: AppColor.pageBackgroundColor))),
      child: Column(
        children: [
          sbhRow([
            centRow([
              Container(
                width: 3.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: AppColor.theme,
                  borderRadius: BorderRadius.circular(1.25.w),
                ),
              ),
              gwb(9),
              getSimpleText("${controller.userType == 1 ? "盘主" : "合伙人"}概览", 15,
                  AppColor.text,
                  isBold: true),
            ]),
            DropdownButtonHideUnderline(
                child: GetX<StatisticsUserManageController>(
              init: controller,
              builder: (_) {
                return DropdownButton2(
                    offset: Offset(0.w, 10.w),
                    customButton: GetX<StatisticsUserManageController>(
                      builder: (_) {
                        return SizedBox(
                          height: 55.w,
                          width: 80.w,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 55.w,
                              height: 18.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    9.w,
                                  ),
                                  border: Border.all(
                                      width: 0.5.w, color: AppColor.lineColor)),
                              child: Center(
                                child: centRow([
                                  gwb(3),
                                  getSimpleText(
                                      controller.timeFilterList[controller
                                              .timeFilterIdx]["name"] ??
                                          "",
                                      10,
                                      AppColor.text2),
                                  gwb(3),
                                  GetX<StatisticsUserManageController>(
                                    builder: (_) {
                                      return AnimatedRotation(
                                        turns:
                                            controller.openTimeFilte ? 0.5 : 1,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Image.asset(
                                          assetsName(
                                              "statistics/machine/icon_filter_down_selected_arrow"),
                                          width: 6.w,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      );
                                    },
                                  )
                                ]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    items: List.generate(
                        controller.timeFilterList.length,
                        (index) => DropdownMenuItem<int>(
                            value: index,
                            child: centClm([
                              SizedBox(
                                height: (18 + 4 * 2).w,
                                child: Center(
                                  child: getSimpleText(
                                      controller.timeFilterList[index]["name"],
                                      12,
                                      controller.timeFilterIdx == index
                                          ? AppColor.theme
                                          : AppColor.textBlack),
                                ),
                              ),
                              index != controller.timeFilterList.length - 1
                                  ? gline(52, 0.5)
                                  : ghb(0)
                            ]))),
                    value: controller.timeFilterIdx,
                    // buttonWidth: 70.w,
                    buttonHeight: kToolbarHeight,
                    itemHeight: 30.w,
                    onChanged: (value) {
                      controller.timeFilterIdx = value;
                    },
                    onMenuStateChange: (isOpen) {
                      controller.openTimeFilte = isOpen;
                    },
                    itemPadding: EdgeInsets.zero,
                    dropdownWidth: 80.w,
                    dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.w),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0x26333333),
                              offset: Offset(0, 5.w),
                              blurRadius: 15.w)
                        ]));
              },
            )),
          ], width: 375 - 15 * 2, height: 55),
          // ghb(18),
          GetBuilder<StatisticsUserManageController>(
            builder: (_) {
              return centRow(
                List.generate(3, (index) {
                  dynamic num;
                  switch (index) {
                    case 0:
                      num = controller.mainData["tolNum"] ?? 0;
                      break;
                    case 1:
                      num = controller.mainData["normalNum"] ?? 0;
                      break;
                    case 2:
                      num = controller.mainData["invalidNum"] ?? 0;
                      break;
                  }

                  return centRow([
                    SizedBox(
                      width: 117.w,
                      height: 95.w - 1.w - 0.1.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getSimpleText(
                              index == 0
                                  ? "总人数"
                                  : index == 1
                                      ? "有效人数"
                                      : "无效人数",
                              12,
                              AppColor.text2),
                          ghb(9.5),
                          getSimpleText("$num", 24, AppColor.text2,
                              isBold: true),
                          // getRichText(
                          //     "较昨日 ",
                          //     "${(data["last"] ?? 0) >= 0 ? "+" : ""}${data["last"] ?? 0}",
                          //     12,
                          //     AppColor.text3,
                          //     14,
                          //     AppColor.text3)
                        ],
                      ),
                    ),
                    index < 2
                        ? gline(
                            1,
                            40,
                          )
                        : gwb(0)
                  ], crossAxisAlignment: CrossAxisAlignment.center);
                }),
              );
            },
          )
        ],
      ),
    );
  }

  Widget userListCell(int index, Map data) {
    return Align(
        child: Container(
      width: 345.w,
      height: 150.w,
      margin: EdgeInsets.only(top: 15.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
      child: Column(
        children: [
          SizedBox(
            height: 75.w,
            child: Center(
              child: sbRow([
                centRow([
                  gwb(15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(45.w / 2),
                    child: CustomNetworkImage(
                      src: AppDefault().imageUrl + (data["u_Avatar"] ?? ""),
                      width: 45.w,
                      height: 45.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  gwb(9.5),
                  centClm([
                    centRow([
                      getSimpleText(
                          data["u_Name"] != null && data["u_Name"].isNotEmpty
                              ? data["u_Name"]
                              : data["u_Mobile"] ?? "",
                          15,
                          AppColor.text2,
                          isBold: true),
                      gwb(5),
                      Image.asset(
                        assetsName("mine/vip/level${data["uL_Level"] ?? 1}"),
                        width: 31.5.w,
                        fit: BoxFit.fitWidth,
                      ),
                      getSimpleText(
                          data["uLevelName"] ?? "", 10, const Color(0xFFBB5D10))
                    ]),
                    ghb(5),
                    getSimpleText(hidePhoneNum(data["u_Mobile"] ?? ""), 12,
                        AppColor.text2),
                  ], crossAxisAlignment: CrossAxisAlignment.start)
                ]),
                Container(
                  width: 50.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(9.w)),
                      color: (data["tStatus"] ?? "") == "已激活"
                          ? AppColor.theme.withOpacity(0.1)
                          : AppColor.red.withOpacity(0.1)),
                  child: Align(
                    child: getSimpleText(
                        data["tStatus"] ?? "",
                        10,
                        (data["tStatus"] ?? "") == "已激活"
                            ? AppColor.theme
                            : AppColor.red),
                  ),
                )
              ], width: 345, crossAxisAlignment: CrossAxisAlignment.start),
            ),
          ),
          gline(315, 0.5),
          SizedBox(
              width: 315.w,
              height: 74.5.w,
              child: Column(
                children: [
                  ghb(11),
                  centRow([
                    userInfoRow("当前积分",
                        priceFormat(data["integral"] ?? 0, savePoint: 0)),
                    userInfoRow("拥有设备",
                        "${data["bindingC"] ?? 0}/${data["actTermiC"] ?? 0}"),
                  ]),
                  centRow([
                    userInfoRow("注册时间",
                        controller.cellDateFormat(data["u_Pass_Date"] ?? "")),
                    userInfoRow(
                        "上次登录",
                        controller
                            .cellDateFormat(data["u_Last_Login_Time"] ?? "")),
                  ]),
                ],
              ))
        ],
      ),
    ));
  }

  Widget userInfoRow(String t1, String t2, {double height = 23}) {
    return centRow([
      ghb(height),
      getWidthText(t1, 12, AppColor.text3, 60, 1, textHeight: 1.3),
      getWidthText(t2, 12, AppColor.text2, (345 - 15 * 2) / 2 - 60, 1,
          textHeight: 1.3),
    ]);
  }

  Widget teamListCell(int index, Map data) {
    bool open = data["open"] ?? false;
    return UnconstrainedBox(
      child: AnimatedContainer(
        margin: EdgeInsets.only(top: 15.w),
        duration: const Duration(milliseconds: 300),
        width: 345.w,
        height: open ? 375.w : 165.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 75.w,
                child: Center(
                  child: sbRow([
                    centRow([
                      gwb(15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(45.w / 2),
                        child: CustomNetworkImage(
                          src: AppDefault().imageUrl + (data["u_Avatar"] ?? ""),
                          width: 45.w,
                          height: 45.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      gwb(9.5),
                      centClm([
                        centRow([
                          getSimpleText(
                              data["u_Name"] != null &&
                                      data["u_Name"].isNotEmpty
                                  ? data["u_Name"]
                                  : data["u_Mobile"] ?? "",
                              15,
                              AppColor.text2,
                              isBold: true),
                          gwb(5),
                          Image.asset(
                            assetsName(
                                "mine/vip/level${data["uL_Level"] ?? 1}"),
                            width: 31.5.w,
                            fit: BoxFit.fitWidth,
                          ),
                          getSimpleText(data["uLevelName"] ?? "", 10,
                              const Color(0xFFBB5D10))
                        ]),
                        ghb(5),
                        getSimpleText(hidePhoneNum(data["u_Mobile"] ?? ""), 12,
                            AppColor.text2),
                      ], crossAxisAlignment: CrossAxisAlignment.start)
                    ]),
                    Container(
                      width: 50.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(9.w)),
                          color: (data["tStatu"] ?? -1) == 1
                              ? AppColor.theme.withOpacity(0.1)
                              : (data["tStatu"] ?? -1) == 0
                                  ? AppColor.red.withOpacity(0.1)
                                  : Colors.transparent),
                      child: Align(
                        child: getSimpleText(
                            (data["tStatu"] ?? -1) == 1
                                ? "有效"
                                : (data["tStatu"] ?? -1) == 0
                                    ? "无效"
                                    : "",
                            10,
                            (data["tStatu"] ?? -1) == 1
                                ? AppColor.theme
                                : (data["tStatu"] ?? -1) == 0
                                    ? AppColor.red
                                    : Colors.transparent),
                      ),
                    )
                  ], width: 345, crossAxisAlignment: CrossAxisAlignment.start),
                ),
              ),
              AnimatedContainer(
                height: open ? 255.w : 45.w,
                width: 315.w,
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                    color: AppColor.pageBackgroundColor,
                    borderRadius: BorderRadius.circular(4.w)),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      CustomButton(
                        onPressed: () {
                          if (data["isLoading"] != null && data["isLoading"]) {
                            return;
                          }
                          if (data["open"] == null) {
                            data["open"] = false;
                          } else if (data["open"]) {
                            data["open"] = false;
                            controller.update();
                          }

                          if (!data["open"] &&
                              (data["openData"] == null ||
                                  data["openData"].isEmpty)) {
                            data["isLoading"] = true;
                            controller.loadLeaderOpenData(data, (succ) {
                              data["isLoading"] = false;
                            });
                          }
                        },
                        child: sbhRow([
                          Padding(
                            padding: EdgeInsets.only(left: 15.5.w),
                            child: Text.rich(TextSpan(
                                text: "累积交易(元)：",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColor.text2,
                                    fontWeight: AppDefault.fontBold),
                                children: [
                                  TextSpan(
                                      text: priceFormat(data["tolAmt"] ?? 0,
                                          savePoint: 2,
                                          tenThousand: true,
                                          tenThousandUnit: false),
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColor.red,
                                          fontWeight: AppDefault.fontBold)),
                                  TextSpan(
                                    text:
                                        "${(data["tolAmt"] ?? 0) > 10000 ? "万" : ""}元",
                                  ),
                                ])),
                          ),
                          SizedBox(
                            width: 31.w,
                            height: 45.w,
                            child: Center(
                                child: AnimatedRotation(
                              turns: open ? 1.25 : 1,
                              duration: const Duration(milliseconds: 200),
                              child: Image.asset(
                                assetsName("statistics/icon_arrow_right_gray"),
                                width: 12.w,
                                fit: BoxFit.fitWidth,
                              ),
                            )),
                          ),
                        ], width: 315, height: 45),
                      ),
                      gline(300, 0.5, color: const Color(0xFFDFDFDF)),
                      SizedBox(
                        width: 315.w,
                        height: 209.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(8, (index) {
                            String t1 = "";
                            String t2 = "";
                            Map oData = data["openData"] ?? {};
                            switch (index) {
                              case 0:
                                t1 = "注册时间";
                                t2 = "${oData["zcTime"] ?? ""}";
                                break;
                              case 1:
                                t1 = "盘主数量(人)";
                                t2 = "${oData["ul3Num"] ?? 0}";
                                break;
                              case 2:
                                t1 = "伙伴数量(人)";
                                t2 = "${oData["ul2Num"] ?? 0}";
                                break;
                              case 3:
                                t1 = "累计贡献(元)";
                                t2 = priceFormat(oData["toAmt"] ?? 0,
                                    tenThousand: true);
                                break;
                              case 4:
                                t1 = "累计收益(元)";
                                t2 = priceFormat(oData["myAmt"] ?? 0,
                                    tenThousand: true);
                                break;
                              case 5:
                                t1 = "库存(台)";
                                t2 = "${oData["noBingNum"] ?? 0}";
                                break;
                              case 6:
                                t1 = "已激活(台)";
                                t2 = "${oData["atcNum"] ?? 0}";
                                break;
                              case 7:
                                t1 = "有效激活(台)";
                                t2 = "${oData["haveAtcNum"] ?? 0}";
                                break;
                            }

                            return sbhRow([
                              getSimpleText(t1, 12, AppColor.text3),
                              getSimpleText(t2, 12, AppColor.text2),
                            ], width: 315 - 15 * 2, height: 23);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomButton(
                  onPressed: () {
                    if (data["bottomLoading"] != null &&
                        data["bottomLoading"]) {
                      return;
                    }
                    if (data["inventory"] == null ||
                        data["inventory"].isEmpty) {
                      data["bottomLoading"] = true;
                      controller.loadLeaderBottomData(data, (succ, bData) {
                        data["inventory"] = bData;
                        showTableModel(data["inventory"] ?? [], 0);
                        data["bottomLoading"] = false;
                      });
                    } else {
                      showTableModel(data["inventory"] ?? [], 0);
                    }
                  },
                  child: SizedBox(
                    width: 345.w,
                    height: 45.w - 0.1.w,
                    child: Center(
                      child: centRow([
                        Image.asset(
                          assetsName("statistics/icon_check_kc"),
                          width: 16.w,
                          fit: BoxFit.fitWidth,
                        ),
                        gwb(3),
                        getSimpleText("查看库存详情", 12, AppColor.text2,
                            textHeight: 1.2)
                      ]),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget businessListCell(int index, Map data) {
    return Align(
      child: Container(
        width: 345.w,
        margin: EdgeInsets.only(top: 15.w),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
        child: Column(children: [
          gwb(345),
          sbhRow([
            getSimpleText(data["merchantName"] ?? "", 15, AppColor.text2,
                isBold: true),
            // centRow([
            //   Image.asset(
            //     assetsName("machine/icon_machine_count"),
            //     width: 18.w,
            //     fit: BoxFit.fitWidth,
            //   ),
            //   gwb(10),
            //   getSimpleText("拥有设备 ${data["cMc"] ?? 0}/${data["aMc"] ?? 0}", 12,
            //       AppColor.text2)
            // ])
          ], width: 345 - 15 * 2, height: 55),
          gline(315, 0.5),
          SizedBox(
            height: 71.w,
            child: Center(
              child: centRow(List.generate(3, (index) {
                return index == 1
                    ? gline(1, 40, color: AppColor.lineColor)
                    : SizedBox(
                        width: (345 - 6 * 2).w / 2,
                        child: centClm([
                          getSimpleText(
                              priceFormat(
                                  index == 0
                                      ? data["totalTxnAmt"] ?? 0
                                      : data["thisMTxnAmt"] ?? 0,
                                  tenThousand: true,
                                  tenThousandUnit: false),
                              15,
                              AppColor.text2,
                              isBold: true),
                          ghb(10),
                          getSimpleText(
                              index == 0
                                  ? "累计交易(${(data["totalTxnAmt"] ?? 0) > 10000.0 ? "万" : ""}元)"
                                  : "本月交易(${(data["thisMTxnAmt"] ?? 0) > 10000.0 ? "万" : ""}元)",
                              12,
                              AppColor.text3)
                        ]),
                      );
              })),
            ),
          ),
          ghb(10),
          ...List.generate(2, (index) {
            String t1 = "";
            String t2 = "";
            switch (index) {
              case 0:
                t1 = "注册时间";
                t2 = data["merchantInTime"] ?? "";
                break;
              // case 1:
              //   t1 = "负责人";
              //   t2 = data["merchantName"] ?? "";
              //   break;
              case 1:
                t1 = "联系电话";
                t2 = data["merchantPhone"] ?? "";
                break;
              case 2:
                t1 = "设备类型";
                t2 = data["terminalName"] ?? "";
                break;
              // case 3:
              //   t1 = "设备编号";
              //   t2 = data["tNo"] ?? "";
              //   break;
              // default:
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                gwb(15),
                ghb(22),
                getWidthText(t1, 12, AppColor.text3, 59.5, 1, textHeight: 1.2),
                getWidthText(t2, 12, AppColor.text2, 315 - 59.5, 3,
                    textHeight: 1.2),
              ],
            );
          }),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              gwb(15),
              ghb(22),
              getWidthText("设备编号", 12, AppColor.text3, 59.5, 1,
                  textHeight: 1.2),
              // getWidthText(t2, 12, AppColor.text2, 315 - 59.5, 3,
              //     textHeight: index == 3 ? 1.3 : 1.2),
              getSimpleText(data["tNo"] ?? "", 12, AppColor.text2,
                  textHeight: 1.2),
              gwb(5),
              Container(
                height: 18.w,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9.w),
                    color: ((data["isActivation"] ?? 0) > 0
                            ? AppColor.theme
                            : AppColor.red)
                        .withOpacity(0.1)),
                alignment: Alignment.center,
                child: getSimpleText(
                    (data["isActivation"] ?? 0) > 0 ? "已激活" : "未激活",
                    10,
                    (data["isActivation"] ?? 0) > 0
                        ? AppColor.theme
                        : AppColor.red,
                    textHeight: 1.3),
              )
            ],
          ),
          ghb(20),
          // gline(315, 0.5),
          // CustomButton(
          //     onPressed: () {
          //       showTableModel(data["machineDatas"] ?? [], 1);
          //     },
          //     child: SizedBox(
          //       width: 345.w,
          //       height: 45.w - 0.1.w,
          //       child: Center(
          //         child: centRow([
          //           Image.asset(
          //             assetsName("statistics/icon_check_sb"),
          //             width: 16.w,
          //             fit: BoxFit.fitWidth,
          //           ),
          //           gwb(3),
          //           getSimpleText("查看设备详情", 12, AppColor.text2, textHeight: 1.2)
          //         ]),
          //       ),
          //     ))
        ]),
      ),
    );
  }

  showTableModel(List tableDatas, int type) {
    Get.bottomSheet(
      Container(
        width: 375.w,
        height: 450.w + paddingSizeBottom(Global.navigatorKey.currentContext!),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
        child: Column(
          children: [
            gwb(375),
            sbhRow([
              gwb(42),
              getSimpleText(type == 0 ? "库存详情" : "设备详情", 18, AppColor.text,
                  isBold: true),
              CustomButton(
                onPressed: () {
                  Get.back();
                },
                child: SizedBox(
                  width: 42.w,
                  height: 48.w,
                  child: Center(
                    child: Image.asset(
                      assetsName("statistics/machine/btn_model_close"),
                      width: 18.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              )
            ], width: 375, height: 53),
            gline(375, 1),
            SizedBox(
              width: 375.w,
              height: 396.w - 0.1.w,
              child: Stack(
                children: [
                  Positioned(
                      top: 14.w,
                      left: 0,
                      right: 0,
                      height: 40.w,
                      child: Center(
                        child: tableRow(-1, tableDatas, type),
                      )),
                  Positioned(
                      top: 14.w + 40.w,
                      left: 0,
                      right: 0,
                      bottom: 33.5.w,
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: tableDatas.isEmpty
                              ? const CustomEmptyView(
                                  topSpace: 30,
                                  centerSpace: 20,
                                )
                              : Column(
                                  children: [
                                    gwb(375),
                                    ...List.generate(
                                        tableDatas.length,
                                        (index) =>
                                            tableRow(index, tableDatas, type)),
                                    ghb(35),
                                  ],
                                ),
                        ),
                      )),
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: 15.w,
                      height: 45.w,
                      child: getSubmitBtn("确定", () {
                        Get.back();
                      }, height: 45.w, color: AppColor.theme, fontSize: 15))
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: false,
    );
  }

  Widget tableRow(int index, List tableDatas, int type) {
    List tableTitles =
        type == 0 ? ["名称", "库存", "激活", "有效激活"] : ["设备名称", "机身号", "状态"];

    int length = tableTitles.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (idx) {
        String str = "";

        Color tColor = AppColor.text2;
        if (index >= 0) {
          Map data = tableDatas[index];
          switch (idx) {
            case 0:
              str = data["title"];
              break;
            case 1:
              str = type == 0
                  ? "${data["inToryNum"] ?? 0}"
                  : "${data["tNo"] ?? ""}";
              break;
            case 2:
              str = type == 0
                  ? "${data["actNum"] ?? 0}"
                  : (data["isAct"] ?? false)
                      ? "已激活"
                      : "未激活";
              type != 0
                  ? tColor =
                      (data["isAct"] ?? false) ? AppColor.text2 : AppColor.red
                  : AppColor.text2;

              break;
            case 3:
              str = "${data["assNum"] ?? 0}";
              break;
            // case 4:
            //   str = "${data["jh"] ?? 0}";
            //   break;
            // case 5:
            //   str = "${data["yxjh"] ?? 0}";
            // break;
          }
        }
        double width = type == 0
            ? (idx == 0 ? 80 : (345 - 80) / (length - 1))
            : idx == 0
                ? 90
                : idx == 1
                    ? 180
                    : (345 - 180 - 90);
        return Container(
          width: width.w,
          height: 40.w,
          decoration: BoxDecoration(
            border: Border(
                right: BorderSide(
                  width: 0.5.w,
                  color: Colors.white,
                ),
                bottom: BorderSide(width: 0.5.w, color: Colors.white)),
            color:
                index == -1 ? AppColor.theme : AppColor.theme.withOpacity(0.1),
          ),
          child: Center(
            child: getWidthText(index == -1 ? tableTitles[idx] : str, 12,
                index == -1 ? Colors.white : tColor, width, 1,
                alignment: Alignment.center, textAlign: TextAlign.center),
          ),
        );
      }),
    );
  }
}
