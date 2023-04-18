// import 'package:cxhighversion2/component/custom_button.dart';
// import 'package:cxhighversion2/component/custom_empty_view.dart';
// import 'package:cxhighversion2/component/custom_network_image.dart';
// import 'package:cxhighversion2/home/store/vip_store_detail.dart';
// import 'package:cxhighversion2/service/urls.dart';
// import 'package:cxhighversion2/util/app_default.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

// class VipStoreBinding implements Bindings {
//   @override
//   void dependencies() {
//     Get.put<VipStoreController>(VipStoreController());
//   }
// }

// class VipStoreController extends GetxController {
//   final _topIndex = 0.obs;
//   int get topIndex => _topIndex.value;
//   set topIndex(v) {
//     if (_topIndex.value != v) {
//       _topIndex.value = v;
//       update();
//       loadList();
//     }
//   }

//   final _isLoading = false.obs;
//   bool get isLoading => _isLoading.value;
//   set isLoading(v) => _isLoading.value = v;

//   RefreshController pullCtrl = RefreshController();
//   List pageNos = [];
//   List pageSizes = [];
//   List counts = [];

//   onLoad() {
//     loadList(isLoad: true);
//   }

//   onRefresh() {
//     loadList();
//   }

//   List dataList = [];

//   loadList({bool isLoad = false}) {
//     isLoad ? pageNos[topIndex]++ : pageNos[topIndex] = 1;
//     if (dataList[topIndex].isEmpty) {
//       isLoading = true;
//     }

//     simpleRequest(
//       url: Urls.memberList,
//       params: {
//         "level_Type": 1,
//         "pageSize": pageSizes[topIndex],
//         "pageNo": pageNos[topIndex],
//         "tmId": xhList[topIndex]["enumValue"]
//       },
//       success: (success, json) {
//         if (success) {
//           Map data = json["data"] ?? {};
//           counts[topIndex] = data["count"];
//           isLoad
//               ? dataList[topIndex] = [
//                   ...dataList[topIndex],
//                   ...(data["data"] ?? [])
//                 ]
//               : dataList[topIndex] = data["data"] ?? [];
//           isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
//           update();
//         } else {
//           isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
//         }
//       },
//       after: () {
//         isLoading = false;
//       },
//     );
//   }

//   @override
//   void onInit() {
//     loadXh();
//     loadList();
//     super.onInit();
//   }

//   @override
//   void dispose() {
//     pullCtrl.dispose();
//     super.dispose();
//   }

//   List xhList = [];
//   loadXh() {
//     Map publicHomeData = AppDefault().publicHomeData;

//     // Map userData = await getUserData();
//     // // Map homeData = userData["homeData"];
//     // Map publicHomeData = userData["publicHomeData"];
//     // if (publicHomeData.isNotEmpty &&
//     //     publicHomeData["terminalBrand"].isNotEmpty &&
//     //     publicHomeData["terminalBrand"] is List) {
//     //   ppList = (publicHomeData["terminalBrand"] as List)
//     //       .map((e) => {...e, "selected": false})
//     //       .toList();

//     //   update([ppListBuildId]);
//     // }
//     // if (publicHomeData.isNotEmpty &&
//     //     publicHomeData["terminalConfig"].isNotEmpty &&
//     //     publicHomeData["terminalConfig"] is List) {
//     //   zcList = (publicHomeData["terminalConfig"] as List)
//     //       .map((e) => {...e, "selected": false})
//     //       .toList();
//     //   update([zcListBuildId]);
//     // }
//     if (publicHomeData.isNotEmpty &&
//         publicHomeData["terminalMod"].isNotEmpty &&
//         publicHomeData["terminalMod"] is List) {
//       // xhList = [
//       //   {"enumValue": -1, "enumName": "全部"},
//       //   ...publicHomeData["terminalMod"]
//       // ].map((e) => {...e, "selected": false}).toList();
//       xhList = publicHomeData["terminalMod"] ?? [];
//       dataList = [];
//       pageNos = [];
//       pageSizes = [];
//       counts = [];
//       for (var e in xhList) {
//         dataList.add([]);
//         pageNos.add(1);
//         pageSizes.add(20);
//         counts.add(0);
//       }
//       // update([xhListBuildId]);
//     }
//   }
// }

// class VipStore extends GetView<VipStoreController> {
//   const VipStore({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
//           getDefaultAppBar(context, "VIP礼包", blueBackground: true, white: true),
//       body: Stack(
//         children: [
//           Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               height: 33.w,
//               child: Container(
//                 decoration: const BoxDecoration(
//                     gradient: LinearGradient(colors: [
//                   Color(0xFF6796F5),
//                   Color(0xFF2368F2),
//                 ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
//                 child: Row(
//                   children: List.generate(
//                       controller.xhList.length,
//                       (index) => topBtn(
//                           index, controller.xhList[index]["enumName"] ?? "")),
//                 ),
//               )),
//           Positioned(
//               top: 33.w,
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: GetBuilder<VipStoreController>(
//                 builder: (_) {
//                   int count = controller.counts[controller.topIndex];
//                   List datas = controller.dataList[controller.topIndex];
//                   return SmartRefresher(
//                     controller: controller.pullCtrl,
//                     onLoading: controller.onLoad,
//                     onRefresh: controller.onRefresh,
//                     enablePullUp: count > datas.length,
//                     child: datas.isEmpty
//                         ? GetX<VipStoreController>(
//                             builder: (_) {
//                               return CustomEmptyView(
//                                 isLoading: controller.isLoading,
//                               );
//                             },
//                           )
//                         : ListView.builder(
//                             itemCount: datas.length,
//                             itemBuilder: (context, index) {
//                               return storeCell(index, datas[index]);
//                             },
//                           ),
//                   );
//                 },
//               ))
//         ],
//       ),
//     );
//   }

//   Widget storeCell(int index, Map data) {
//     return Align(
//       child: CustomButton(
//         onPressed: () {
//           push(VipStoreDetail(productData: data), null,
//               binding: VipStoreDetailBinding());
//         },
//         child: Container(
//           width: 345.w,
//           height: 132.w,
//           margin: EdgeInsets.only(top: 12.w),
//           decoration: getDefaultWhiteDec2(radius: 10),
//           child: sbRow([
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10.w),
//               child: CustomNetworkImage(
//                 src: AppDefault().imageUrl + (data["levelGiftImg"] ?? ""),
//                 width: 132.w,
//                 height: 132.w,
//                 fit: BoxFit.fill,
//               ),
//             ),
//             centRow([
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   centClm([
//                     ghb(8),
//                     getWidthText(data["levelName"] ?? "", 14,
//                         const Color(0xFF2D3033), 189, 2),
//                   ]),
//                   getWidthText(data["levelDescribe"] ?? "", 12,
//                       const Color(0xFF525C66), 189, 2),
//                   centClm([
//                     sbRow([
//                       getRichText("￥", priceFormat(data["nowPrice"] ?? 0), 13,
//                           const Color(0xFFFF5A5F), 18, const Color(0xFFFF5A5F)),
//                       Container(
//                         width: 60.w,
//                         height: 24.w,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12.w),
//                             gradient: const LinearGradient(
//                                 colors: [Color(0xFF6796F5), Color(0xFF2368F2)],
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight)),
//                         child: Center(
//                             child: getSimpleText("去购买", 12, Colors.white)),
//                       )
//                     ], width: 189),
//                     ghb(8)
//                   ])
//                 ],
//               ),
//               gwb(12)
//             ])
//           ]),
//         ),
//       ),
//     );
//   }

//   Widget topBtn(int index, String t1) {
//     return GetX<VipStoreController>(
//       initState: (_) {},
//       builder: (_) {
//         return CustomButton(
//           onPressed: () {
//             controller.topIndex = index;
//           },
//           child: SizedBox(
//             width: 375.w / 3 - 0.1,
//             height: 33.w,
//             child: Center(
//               child: centClm([
//                 getSimpleText(t1, 14, Colors.white),
//                 ghb(controller.topIndex == index ? 3 : 0),
//                 controller.topIndex == index
//                     ? Container(
//                         width: 30.w,
//                         height: 4.w,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(2.w)),
//                       )
//                     : ghb(0),
//               ]),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universal_html/js.dart' as js;
// import 'package:store_plugin/cx_store.dart';

class VipStoreController extends GetxController {
  @override
  void onInit() {
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    super.onInit();
  }

  getHomeDataNotify(arg) {
    update();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    super.onClose();
  }
}

class VipStore extends StatelessWidget {
  final Map appData;
  final String title;
  const VipStore({
    super.key,
    this.appData = const {},
    this.title = "VIP礼包",
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VipStoreController>(
      init: VipStoreController(),
      builder: (controller) {
        Map data = appData;
        data["homeData"] = AppDefault().homeData;
        return
            // CXStore(
            //   title: title,
            //   appData: data,
            //   alipayAction: (aliData) {
            //     if (aliData != null && aliData.isNotEmpty) {
            //       js.context.callMethod('alipayAction', [aliData]);
            //     }
            //   },
            //   toErrorPage: (errorCode) {
            //     int? statusCode = int.tryParse("$errorCode");
            //     setUserDataFormat(false, {}, {}, {}).then((value) => toLogin(
            //         isErrorStatus: statusCode != null,
            //         errorCode: statusCode ?? -1));
            //   },
            //   appUpdate: (dynamic data) {
            //     if (data == null || data is! Map || data.isEmpty) {
            //       return;
            //     }
            //     if (isLoginRoute()) {
            //       return;
            //     }
            //     if (!Http.updateAlertExist) {
            //       Http.updateAlertExist = true;
            //       showAppUpdateAlert(
            //         data,
            //         close: () {
            //           Http.updateAlertExist = false;
            //         },
            //       );
            //     }
            //   },
            //   toAddressPage: (getCtrl) {
            //     push(
            //         MineAddressManager(
            //           getCtrl: getCtrl,
            //           addressCallBack: (address) {},
            //         ),
            //         context,
            //         binding: MineAddressManagerBinding());
            //   },
            //   alertPayWarn: () {
            //     showPayPwdWarn(
            //       haveClose: true,
            //       popToRoot: false,
            //       untilToRoot: false,
            //       setSuccess: () {},
            //     );
            //   },
            //   backAction: () {
            //     Get.back();
            //   },
            // )
            Container();
      },
    );
  }
}
