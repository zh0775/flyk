import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/machine/machine_order_list.dart';
import 'package:cxhighversion2/machine/machine_ship_select.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities_add_list.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'aftersale/machine_aftersale_select.dart';

extension SizeExtension on num {
  double get ww => AppDefault().scaleWidth * this;
}

enum MachineOrderType {
  sponsor,
  receive,
  aftersale,
}

enum MachineOrderBtnType {
  cancel, //取消订单 下级
  delete, //删除订单 下级
  machineList, // 设备列表 下级
  confirmTake, // 确认收货 下级
  afterSafeDetail, // 售后详情 下级
  applyAfterSafe, // 申请售后 下级
  confirmPay, // 确认支付 上级
  invalid, //作废 上级
  immediatedelivery, //立即发货 上级
  backoutApply, // 撤销申请 下级
  aftersaleTimeLine, //售后进度  下级
  returnGoods, //寄回商品  下级
  agreeAftersale, //同意售后  上级
  invalidAftersale, //作废售后  上级
  confirmReceive, //确认回收  上级
  aftersaleImmediatedelivery, //上级 常规订单售后发货  上级
}

class MachineOrderUtil {
  static MachineOrderUtil? _instance;
  MachineOrderUtil.init() {
    _instance = this;
  }
  factory MachineOrderUtil() {
    return _instance ?? MachineOrderUtil.init();
  }

  double scale = 0;

  Widget getButtons(int status,
      {Function(MachineOrderBtnType type)? onPressed,
      MachineOrderType orderType = MachineOrderType.sponsor,
      bool detail = true,
      int aftersaleType = 0,
      int parenID = 0,
      int serviceType = 0}) {
    List<Widget> widgets = [];
    double space = 10;
    if (orderType == MachineOrderType.sponsor) {
      if (status == 0) {
        if (widgets.isNotEmpty) {
          widgets.add(gwb(space));
        }
        widgets.add(statusButton(
          MachineOrderBtnType.cancel,
          onPressed: () {
            showAlert(
              Global.navigatorKey.currentContext!,
              "确认要取消该订单吗",
              confirmOnPressed: () {
                Get.back();
                if (onPressed != null) {
                  onPressed(MachineOrderBtnType.cancel);
                }
              },
            );
          },
        ));
      }
      // if (status == 1) {
      //   if (widgets.isNotEmpty) {
      //     widgets.add(gwb(space));
      //   }
      //   widgets.add(
      //     statusButton(
      //       MachineOrderBtnType.confirmPush,
      //       onPressed: () {
      //         Get.back();
      //         if (onPressed != null) {
      //           onPressed(MachineOrderBtnType.confirmPush);
      //         }
      //       },
      //     ),
      //   );
      // }

      if (status == 2) {
        if (widgets.isNotEmpty) {
          widgets.add(gwb(space));
        }
        widgets.add(
          statusButton(
            MachineOrderBtnType.confirmTake,
            onPressed: () {
              myAlert("是否确认收货", () {
                if (onPressed != null) {
                  onPressed(MachineOrderBtnType.confirmTake);
                }
              });
            },
          ),
        );
      }

      if (status == 6 || status == 4 || status == 7) {
        if (widgets.isNotEmpty) {
          widgets.add(gwb(space));
        }
        widgets.add(
          statusButton(
            MachineOrderBtnType.delete,
            onPressed: () {
              showAlert(
                Global.navigatorKey.currentContext!,
                "是否删除该订单",
                confirmOnPressed: () {
                  Get.back();
                  if (onPressed != null) {
                    onPressed(MachineOrderBtnType.delete);
                  }
                },
              );
            },
          ),
        );
      }
      if ((status == 2 || status == 3) && !detail) {
        if (widgets.isNotEmpty) {
          widgets.add(gwb(space));
        }
        widgets.add(
          statusButton(
            MachineOrderBtnType.machineList,
            onPressed: () {
              if (onPressed != null) {
                onPressed(MachineOrderBtnType.machineList);
              }
            },
          ),
        );
      }
    } else if (orderType == MachineOrderType.receive) {
      if ((status == 2 || status == 3) && !detail) {
        if (widgets.isNotEmpty) {
          widgets.add(gwb(space));
        }
        widgets.add(
          statusButton(
            MachineOrderBtnType.machineList,
            onPressed: () {
              if (onPressed != null) {
                onPressed(MachineOrderBtnType.machineList);
              }
            },
          ),
        );
      }

      if (status == 0) {
        widgets.add(
          statusButton(
            MachineOrderBtnType.invalid,
            onPressed: () {
              myAlert("是否作废该订单", () {
                if (onPressed != null) {
                  onPressed(MachineOrderBtnType.invalid);
                }
              });
            },
          ),
        );
        widgets.add(gwb(space));
        widgets.add(
          statusButton(
            MachineOrderBtnType.confirmPay,
            onPressed: () {
              myAlert("是否确认支付", () {
                if (onPressed != null) {
                  onPressed(MachineOrderBtnType.confirmPay);
                }
              });
            },
          ),
        );
      } else if (status == 1) {
        if (widgets.isNotEmpty) {
          widgets.add(gwb(space));
        }
        widgets.add(
          statusButton(
            parenID > 0
                ? MachineOrderBtnType.aftersaleImmediatedelivery
                : MachineOrderBtnType.immediatedelivery,
            onPressed: () {
              if (onPressed != null) {
                onPressed(
                  parenID > 0
                      ? MachineOrderBtnType.aftersaleImmediatedelivery
                      : MachineOrderBtnType.immediatedelivery,
                );
              }
            },
          ),
        );
      }
    } else if (orderType == MachineOrderType.aftersale) {
      if (detail) {
        //下级售后订单
        if (aftersaleType == 0) {
          if (status == 0) {
            widgets.add(statusButton(
              MachineOrderBtnType.backoutApply,
              onPressed: () {
                myAlert("是否撤销售后申请", () {
                  if (onPressed != null) {
                    onPressed(MachineOrderBtnType.backoutApply);
                  }
                });
              },
            ));
            widgets.add(gwb(space));
            widgets.add(statusButton(
              MachineOrderBtnType.aftersaleTimeLine,
              onPressed: () {
                if (onPressed != null) {
                  onPressed(MachineOrderBtnType.aftersaleTimeLine);
                }
              },
            ));
          } else if (status == 1) {
            widgets.add(statusButton(
              MachineOrderBtnType.backoutApply,
              onPressed: () {
                myAlert("是否撤销售后申请", () {
                  if (onPressed != null) {
                    onPressed(MachineOrderBtnType.backoutApply);
                  }
                });
              },
            ));
            widgets.add(gwb(space));
            widgets.add(statusButton(
              MachineOrderBtnType.returnGoods,
              onPressed: () {
                if (onPressed != null) {
                  onPressed(MachineOrderBtnType.returnGoods);
                }
              },
            ));
          }

          //上级售后订单
        } else {
          if (status != 4 || status != 5 || status != 6) {
            widgets.add(statusButton(
              MachineOrderBtnType.invalidAftersale,
              onPressed: () {
                myAlert("是否作废售后申请", () {
                  if (onPressed != null) {
                    onPressed(MachineOrderBtnType.invalidAftersale);
                  }
                });
              },
            ));
          }
          if (status == 0) {
            if (widgets.isNotEmpty) {
              widgets.add(gwb(space));
            }

            widgets.add(statusButton(
              MachineOrderBtnType.agreeAftersale,
              onPressed: () {
                if (onPressed != null) {
                  onPressed(MachineOrderBtnType.agreeAftersale);
                }
              },
            ));
          } else if (status == 2) {
            if (widgets.isNotEmpty) {
              widgets.add(gwb(space));
            }
            if (serviceType == 1) {
              widgets.add(statusButton(
                MachineOrderBtnType.immediatedelivery,
                onPressed: () {
                  if (onPressed != null) {
                    onPressed(MachineOrderBtnType.immediatedelivery);
                  }
                },
              ));
              widgets.add(gwb(space));
            }

            widgets.add(statusButton(
              MachineOrderBtnType.confirmReceive,
              onPressed: () {
                myAlert("是否确认回收", () {
                  if (onPressed != null) {
                    onPressed(MachineOrderBtnType.confirmReceive);
                  }
                });
              },
            ));
          } else if (status == 3) {
            if (serviceType == 1) {
              if (widgets.isNotEmpty) {
                widgets.add(gwb(space));
              }
              widgets.add(statusButton(
                MachineOrderBtnType.immediatedelivery,
                onPressed: () {
                  if (onPressed != null) {
                    onPressed(MachineOrderBtnType.immediatedelivery);
                  }
                },
              ));
            }
          }
        }
      } else {
        widgets.add(statusButton(
          MachineOrderBtnType.afterSafeDetail,
          onPressed: () {
            if (onPressed != null) {
              onPressed(MachineOrderBtnType.afterSafeDetail);
            }
          },
        ));
      }
    }
    return centRow(widgets);
  }

  myAlert(String title, Function() confirm) {
    showAlert(
      Global.navigatorKey.currentContext!,
      title,
      confirmOnPressed: () {
        Get.back();
        confirm();
      },
    );
  }

  popToList({Widget? page, Bindings? binding, dynamic arguments}) {
    if (page != null) {
      Get.offUntil(
          GetPageRoute(
              page: () => page,
              binding: binding,
              settings: RouteSettings(arguments: arguments)),
          (route) => route is GetPageRoute
              ? route.binding is MachineOrderListBinding
                  ? true
                  : false
              : false);
    } else {
      Get.until((route) => route is GetPageRoute
          ? route.binding is MachineOrderListBinding
              ? true
              : false
          : false);
    }
  }

  bool haveBtn(int status,
      {MachineOrderType orderType = MachineOrderType.sponsor,
      bool detail = true,
      int aftersaleType = 0,
      int serviceType = 0}) {
    if (status < 0) {
      return false;
    }
    if (orderType == MachineOrderType.sponsor) {
      if (status == 5 || status == 1) {
        return false;
      } else if (status == 3 && detail) {
        return false;
      }
      return true;
    } else if (orderType == MachineOrderType.receive) {
      if (detail && (status == 2 || status == 3 || status == 5)) {
        return false;
      }
      return true;
    } else if (orderType == MachineOrderType.aftersale) {
      if (aftersaleType == 0 &&
          (status == 2 || (status == 3 && serviceType == 2) || status == 4)) {
        return false;
      }
      return true;
    }

    return false;
  }

  Widget statusButton(MachineOrderBtnType type, {Function()? onPressed}) {
    String title = "";
    Color borderColor = Colors.transparent;
    Color textColor = Colors.transparent;

    switch (type) {
      case MachineOrderBtnType.cancel:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "取消";
        break;
      case MachineOrderBtnType.delete:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "删除";
        break;
      case MachineOrderBtnType.machineList:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "设备列表";
        break;
      case MachineOrderBtnType.confirmTake:
        borderColor = AppColor.theme;
        textColor = AppColor.theme;
        title = "确认收货";
        break;
      case MachineOrderBtnType.afterSafeDetail:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "售后详情";
        break;
      case MachineOrderBtnType.applyAfterSafe:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "申请售后";
        break;
      case MachineOrderBtnType.confirmPay:
        borderColor = AppColor.theme;
        textColor = AppColor.theme;
        title = "确认支付";
        break;
      case MachineOrderBtnType.invalid:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "作废";
        break;
      case MachineOrderBtnType.immediatedelivery:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "立即发货";
        break;
      case MachineOrderBtnType.backoutApply:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "撤销申请";
        break;
      case MachineOrderBtnType.aftersaleTimeLine:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "售后进度";
        break;
      case MachineOrderBtnType.agreeAftersale:
        borderColor = AppColor.theme;
        textColor = AppColor.theme;
        title = "同意";
        break;
      case MachineOrderBtnType.invalidAftersale:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "作废";
        break;
      case MachineOrderBtnType.returnGoods:
        borderColor = AppColor.textGrey5;
        textColor = AppColor.text2;
        title = "寄回商品";
        break;
      case MachineOrderBtnType.confirmReceive:
        borderColor = AppColor.theme;
        textColor = AppColor.theme;
        title = "确认回收";
        break;
      case MachineOrderBtnType.aftersaleImmediatedelivery:
        borderColor = Colors.transparent;
        textColor = AppColor.text2;
        title = "售后发货";
        break;
      default:
    }

    return CustomButton(
      onPressed: onPressed,
      child: Container(
        width: 65.ww,
        height: 25.ww,
        decoration: BoxDecoration(
            border: Border.all(width: 0.5.ww, color: borderColor),
            borderRadius: BorderRadius.circular(4.ww),
            color: type == MachineOrderBtnType.aftersaleImmediatedelivery
                ? AppColor.assisText
                : null),
        child: Center(
          child: getSimpleText(title, 12, textColor, textHeight: 1.3),
        ),
      ),
    );
  }

  String getStatusStr(int index, {int type = 0}) {
    String title = "";
    switch (index) {
      case 0:
        title = "订单待付款";
        break;
      case 1:
        title = "订单待发货";
        break;
      case 2:
        title = "订单待收货";
        break;
      case 3:
        title = "订单已完成";
        break;
      case 4:
        title = "订单申请换货";
        break;
      case 5:
        title = "订单换货中";
        break;
      case 6:
        title = "换货完成";
        break;
      case 7:
        title = "订单申请退货";
        break;
      case 8:
        title = "订单退货中";
        break;
      case 9:
        title = "退货完成";
        break;
      case 10:
        title = "订单支付超时";
        break;
      case 11:
        title = "订单已取消";
        break;
      case 12:
        title = "订单已作废";
        break;
    }
    return title;
  }

  Widget orderDetailInfoCell(String title,
      {int type = 0,
      String? t2,
      Widget? rightWidget,
      int maxLines = 1,
      double height = 35}) {
    return SizedBox(
      height: maxLines > 1 ? null : height,
      child: Center(
        child: sbRow([
          centRow([
            getWidthText(title, 14, AppColor.text3, 75, 1,
                textHeight: 1.3,
                alignment: Alignment.topLeft,
                textAlign: TextAlign.start),
            type == 1
                ? getWidthText(t2 ?? "", 14, AppColor.text, 237, maxLines,
                    textHeight: 1.3,
                    alignment: Alignment.topLeft,
                    textAlign: TextAlign.start)
                : gwb(0),
          ], crossAxisAlignment: CrossAxisAlignment.start),
          type == 1
              ? gwb(0)
              : t2 != null
                  ? getSimpleText(t2, 14, AppColor.text, textHeight: 1.3)
                  : rightWidget ?? gwb(0),
        ], width: 345 - 15 * 2, crossAxisAlignment: CrossAxisAlignment.start),
      ),
    );
  }

  Widget orderDetailProductCell(int index, Map data, int length,
      {double height = 105, double bottomMargin = 7.5}) {
    return centClm([
      ghb(index == 0 ? 15 : 7.5),
      Row(
        children: [
          gwb(15),
          CustomNetworkImage(
            src: AppDefault().imageUrl + (data["shopImg"] ?? ""),
            width: height.ww,
            height: height.ww,
            fit: BoxFit.fill,
          ),
          gwb(14),
          SizedBox(
            height: height.ww,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                centClm([
                  getSimpleText(data["shopName"] ?? "", 15, AppColor.text,
                      isBold: true),
                  ghb(10),
                  getSimpleText(
                      "型号：${data["shopModel"] ?? ""}", 12, AppColor.text3),
                ], crossAxisAlignment: CrossAxisAlignment.start),
                sbRow([
                  getSimpleText("￥${priceFormat(data["nowPrice"] ?? 0)}", 15,
                      AppColor.text,
                      isBold: true),
                  getSimpleText("x${data["num"] ?? 0}", 12, AppColor.assisText)
                ], width: 199.5)
              ],
            ),
          ),
        ],
      ),
      ghb(index == length - 1 ? (7.5 + bottomMargin) : 7.5),
    ]);
  }

  Widget getOrSetMachineList(
      int type, List machines, List selectMachines, Map orderData,
      {Function(List machines)? addMachines,
      Function(int index)? unSelectAction,
      Function(int index, int listIdx)? unSelectListAction,
      int aftersaleIdx = 0}) {
    return Container(
      width: 345.ww,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.ww),
      ),
      child: Column(
        children: [
          sbhRow([
            centRow([
              getSimpleText(
                  type == 0
                      ? "旧设备类型"
                      : type == 1
                          ? "设备类型"
                          : "设备列表",
                  14,
                  AppColor.text3),
            ]),
            CustomButton(
              onPressed: () {
                if (type == 1 || type == 0) {
                  // 设备订单-售后发货
                  push(const MachineAftersaleSelect(), null,
                      binding: MachineAftersaleSelectBinding(),
                      arguments: {
                        "machines": machines,
                        "type": type,
                        "orderData": orderData,
                        "addMachines": addMachines,
                        "aftersaleIdx": aftersaleIdx
                      });
                } else if (type == 2) {
                  // 设备订单-卖家发货
                  push(const MachineShipSelect(), null,
                      binding: MachineShipSelectBinding(),
                      arguments: {
                        "machines": selectMachines,
                        "type": type,
                        "orderData": orderData,
                        "addMachines": addMachines
                      });
                } else if (type == 3) {
                  // 权益设备 添加权益设备
                  push(const StatisticsMachineEquitiesAddList(), null,
                      binding: StatisticsMachineEquitiesAddListBinding(),
                      arguments: {
                        "machines": machines,
                        "type": type,
                        "orderData": orderData,
                        "addMachines": addMachines
                      });
                }
              },
              child: SizedBox(
                height: 59.5.ww,
                width: 59.5.ww,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    assetsName("machine/btn_add_machine"),
                    width: 24.ww,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            )
          ], width: 345 - 15 * 2, height: 59.5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: centClm([
              gline(315, 0.5),
              selectMachines.isEmpty
                  ? type == 3
                      ? ghb(0)
                      : CustomButton(
                          onPressed: () {
                            if (type == 1 || type == 0) {
                              // 设备订单-售后发货
                              push(const MachineAftersaleSelect(), null,
                                  binding: MachineAftersaleSelectBinding(),
                                  arguments: {
                                    "machines": machines,
                                    "type": type,
                                    "orderData": orderData,
                                    "addMachines": addMachines,
                                    "aftersaleIdx": aftersaleIdx
                                  });
                            } else if (type == 2) {
                              // 设备订单-卖家发货
                              push(const MachineShipSelect(), null,
                                  binding: MachineShipSelectBinding(),
                                  arguments: {
                                    "machines": machines,
                                    "type": type,
                                    "orderData": orderData,
                                    "addMachines": addMachines
                                  });
                            } else if (type == 3) {
                              // 权益设备 添加权益设备
                              push(const StatisticsMachineEquitiesAddList(),
                                  null,
                                  binding:
                                      StatisticsMachineEquitiesAddListBinding(),
                                  arguments: {
                                    "machines": machines,
                                    "type": type,
                                    "orderData": orderData,
                                    "addMachines": addMachines
                                  });
                            }
                          },
                          child: SizedBox(
                            height: 52.ww,
                            width: 315.ww,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: getSimpleText(
                                  "请选择要${type == 0 ? "换" : type == 1 ? "退" : "发"}货的设备",
                                  14,
                                  AppColor.text3),
                            ),
                          ),
                        )
                  : ghb(0),
              ghb(selectMachines.isEmpty ? 0 : 6),
              type == 2
                  ? shipList(selectMachines,
                      unSelectListAction: unSelectListAction, type: type)
                  : centClm(List.generate(
                      selectMachines.length,
                      (index) => addOrSubMachineCell(
                          index, selectMachines[index],
                          unSelectAction: unSelectAction, type: type))),
              ghb(selectMachines.isEmpty ? 0 : 10),
            ]),
          )
        ],
      ),
    );
  }

  Widget shipList(List commodityList,
      {Function(int index, int listIdx)? unSelectListAction, int type = 0}) {
    List<Widget> widgets = [];
    for (var i = 0; i < commodityList.length; i++) {
      List machines = commodityList[i]["selectMachines"] ?? [];
      for (var j = 0; j < machines.length; j++) {
        widgets.add(addOrSubMachineCell(j, machines[j],
            listIdx: i, unSelectListAction: unSelectListAction, type: type));
      }
    }
    return centClm(widgets);
  }

  Widget addOrSubMachineCell(int index, Map data,
      {Function(int index)? unSelectAction,
      Function(int index, int listIdx)? unSelectListAction,
      int? listIdx,
      int type = 0}) {
    String name = data["tbName"] ?? "";
    switch (type) {
      case 0:
      case 1:
        name = data["name"] ?? "";
        break;
    }

    return Padding(
      padding: EdgeInsets.only(top: 5.ww, bottom: 5.ww),
      child: sbRow([
        centRow([
          type == 0 || type == 1
              ? Image.asset(
                  assetsName("machine/icon_machinelist"),
                  width: 45.ww,
                  height: 45.ww,
                  fit: BoxFit.fill,
                )
              : CustomNetworkImage(
                  src: AppDefault().imageUrl + (data["tImg"] ?? ""),
                  width: 45.ww,
                  height: 45.ww,
                  fit: BoxFit.fill,
                ),
          gwb(15),
          centClm([
            getWidthText(name, 15, AppColor.text, 200, 2),
            ghb(5),
            getWidthText(
                "设备编号：${data["tNo"] ?? ""}", 12, AppColor.text3, 200, 1),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ]),
        CustomButton(
          onPressed: () {
            data["selected"] = false;

            if (unSelectListAction != null && listIdx != null) {
              unSelectListAction(index, listIdx);
            } else if (unSelectAction != null) {
              unSelectAction(index);
            }
          },
          child: SizedBox(
            width: 43.ww,
            height: 52.ww,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 4.ww),
                child: Image.asset(
                  assetsName("machine/btn_sub_machine"),
                  width: 18.ww,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        )
      ], width: 345 - 15 * 2),
    );
  }

  Widget orderMachineListView(List datas) {
    return Container(
      width: 345.ww,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.ww)),
      child: Column(
        children: [
          sbhRow([
            getSimpleText("设备列表", 15, AppColor.text, isBold: true),
          ], height: 50, width: 345 - 15 * 2),
          ...List.generate(
              datas.length,
              (index) =>
                  orderMachineListCell(index, datas[index], datas.length)),
        ],
      ),
    );
  }

  Widget orderMachineListCell(int index, Map data, int length) {
    return centClm([
      sbhRow([
        centRow([
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(4.ww),
          //   child: CustomNetworkImage(
          //     src: AppDefault().imageUrl + (data["img"] ?? ""),
          //     width: 45.ww,
          //     height: 45.ww,
          //     fit: BoxFit.fill,
          //   ),
          // ),
          Image.asset(
            assetsName("machine/icon_machinelist"),
            width: 45.ww,
            height: 45.ww,
            fit: BoxFit.fill,
          ),
          gwb(8),
          centClm([
            getWidthText(data["name"] ?? "", 15, AppColor.text, 200, 1,
                isBold: true, textHeight: 1.3),
            ghb(4),
            getSimpleText("设备编号：${data["tNo"]}", 12, AppColor.text3)
          ], crossAxisAlignment: CrossAxisAlignment.start)
        ]),
        Padding(
          padding: EdgeInsets.only(bottom: 20.ww),
          child: centRow([
            Container(
              width: 7.5.ww,
              height: 7.5.ww,
              decoration: BoxDecoration(
                  color: const Color(0xFF3AD3D2),
                  borderRadius: BorderRadius.circular(7.5.ww / 2)),
            ),
            gwb(5),
            getSimpleText(data["stateStr"] ?? "", 12, AppColor.text2,
                textHeight: 1.3),
          ]),
        )
      ], width: 345 - 15 * 2, height: 74.5),
      index != length - 1 ? gline(315, 0.5) : ghb(0)
    ]);
  }

  loadCancelOrder(dynamic id, {Function(bool succ)? result}) {
    simpleRequest(
      url: Urls.userLevelGiftOrderCancel(id),
      params: {},
      success: (success, json) {
        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }

  loadConfirmTake(dynamic id, {Function(bool succ)? result}) {
    simpleRequest(
      url: Urls.userLevelGiftOrderConfirm(id),
      params: {},
      success: (success, json) {
        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }

  loadInvalidOrder(dynamic id, {Function(bool succ)? result}) {
    simpleRequest(
      url: Urls.userLevelGiftOrderInvalid(id),
      params: {},
      success: (success, json) {
        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }

  loadCheckPayOrder(dynamic id, {Function(bool succ)? result}) {
    simpleRequest(
      url: Urls.userLevelGiftOrderCheckPay(id),
      params: {},
      success: (success, json) {
        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }

  // 删除订单
  loadDeleteOrder(dynamic id, {Function(bool succ)? result}) {
    simpleRequest(
      url: Urls.userLevelGiftDelOrder(id),
      params: {},
      success: (success, json) {
        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }

  // 卖家作废售后订单
  loadAfterSaleDestroy(dynamic id, {Function(bool succ)? result}) {
    simpleRequest(
      url: Urls.userLevelUpAfterSaleDestroy(id),
      params: {},
      success: (success, json) {
        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }

  // 买家撤销售后订单
  loadAfterSaleCancel(dynamic id, {Function(bool succ)? result}) {
    simpleRequest(
      url: Urls.userLevelUpAfterSaleCancel(id),
      params: {},
      success: (success, json) {
        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }

  // 卖家确认回收 售后订单
  loadAfterSaleRecycle(dynamic id, {Function(bool succ)? result}) {
    simpleRequest(
      url: Urls.userLevelUpAfterSaleRecycle(id),
      params: {},
      success: (success, json) {
        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }
}
