import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer.dart';
import 'package:cxhighversion2/home/terminalBack/terminal_back_history.dart';
import 'package:cxhighversion2/home/terminalBack/terminal_back_select.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class MachineTransferUserListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MachineTransferUserListController>(
        () => MachineTransferUserListController());
  }
}

class MachineTransferUserListController extends GetxController {
  final _isLoading = false.obs;
  set isLoading(value) => _isLoading.value = value;
  bool get isLoading => _isLoading.value;
  final searchTextCtrl = TextEditingController();
  final scrollCtrl = ScrollController();
  final listController = ExpandableListController();

  // Map userMap = {};
  List<UserSection> userSectionList = [];
  List startWords = [];
  List keys = [];

  String imageUrl = "";

  GlobalKey scrollContentKey = GlobalKey();

  userListFormat(List datas) {
    // userMap = {};
    userSectionList = [];
    startWords = [];
    keys = [];
    if (datas.isNotEmpty || (datas != null && datas.length == 0)) {
      String word = "";
      for (var i = 0; i < datas.length; i++) {
        if (i == 0) {
          userSectionList.add(UserSection(nameUserList: []));
          // userSectionList.add([]);
          word = datas[i]["py"];
          startWords.add(word);
          keys.add(GlobalKey());
          // userMap[word] = [];
          // (userMap[word] as List).add(datas[i]);
        } else {
          if (datas[i]["py"] == datas[i - 1]["py"]) {
            // (userMap[word] as List).add(datas[i]);
          } else {
            word = datas[i]["py"];
            startWords.add(word);
            keys.add(GlobalKey());
            // userMap[word] = [];
            // (userMap[word] as List).add(datas[i]);
            userSectionList.add(UserSection(nameUserList: []));
            // userSectionList.add([]);
          }
        }
        userSectionList.last.getItems().add(datas[i]);
        // (userSectionList.last as List).add(datas[i]);

      }
      update();
    }

    // _getImgTest(url) async {//url为头像链接地址，
    // try {
    //   var request = await httpClient.getUrl(Uri.parse(url));
    //   var response = await request.close();
    //   if (response.statusCode == HttpStatus.ok) {  //链接正常则返回HttpStatus.ok
    //     print('头像加载成功');
    //     // Get.find<LoginController>().showAvatar(true);
    //     return true;
    //   } else {
    //     print("头像加载失败");
    //     // Get.find<LoginController>().showAvatar(false);
    //     return false;
    //   }
    // } catch (e) {
    //   print(e);
    //   // Get.find<LoginController>().showAvatar(false);
    //   return false;
    // }
  }

  loadUser({String? str}) {
    if (userSectionList == null || userSectionList.isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {};
    if (str != null && str.isNotEmpty) {
      params["userInfo"] = str;
    }
    simpleRequest(
      url: Urls.userFindTeam,
      params: params,
      success: (success, json) {
        if (success) {
          userListFormat(json["data"]);
          // userListFormat((json["data"] as List).sublist(0, 3000));
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  @override
  void onInit() {
    loadUser();
    imageUrl = AppDefault().imageUrl;
    super.onInit();
  }

  @override
  void onClose() {
    searchTextCtrl.dispose();
    scrollCtrl.dispose();
    listController.dispose();
    super.onClose();
  }
}

class MachineTransferUserList
    extends GetView<MachineTransferUserListController> {
  final bool isTerminalBack;
  const MachineTransferUserList({Key? key, this.isTerminalBack = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
          backgroundColor: AppColor.pageBackgroundColor,
          appBar: getDefaultAppBar(
              context, "选择${isTerminalBack ? "回拨" : "划拨"}对象",
              action: [
                // Visibility(
                //     visible: isTerminalBack,
                //     child: CustomButton(
                //       onPressed: () {
                //         Get.to(const TerminalBackHistory(),
                //             binding: TerminalBackHistoryBinding());
                //       },
                //       child: SizedBox(
                //         height: kToolbarHeight,
                //         width: 70.w,
                //         child: Center(
                //           child: getSimpleText("回拨记录", 14, AppColor.textBlack),
                //         ),
                //       ),
                //     ))
              ]),
          body: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 80.w,
                  child: Center(
                    child: Container(
                      width: 345.w,
                      height: 50.w,
                      decoration: getDefaultWhiteDec(),
                      child: Center(
                        child: sbRow([
                          CustomInput(
                            width: 247.w,
                            heigth: 50.w,
                            textEditCtrl: controller.searchTextCtrl,
                            placeholder: "请输入姓名或者手机号查询",
                            placeholderStyle: TextStyle(
                                fontSize: 15.sp,
                                color: const Color(0xFFCCCCCC)),
                            style: TextStyle(
                                fontSize: 15.sp, color: AppColor.textBlack),
                          ),
                          CustomButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              controller.loadUser(
                                  str: controller.searchTextCtrl.text);
                            },
                            child: Container(
                              width: 64.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                  color: AppColor.textBlack,
                                  borderRadius: BorderRadius.circular(5.w)),
                              child: Center(
                                child: getSimpleText("搜索", 15, Colors.white),
                              ),
                            ),
                          )
                        ], width: 345 - 15 * 2),
                      ),
                    ),
                  )),
              Positioned(
                  top: 80.w,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GetBuilder<MachineTransferUserListController>(
                    init: controller,
                    initState: (_) {},
                    builder: (_) {
                      return controller.userSectionList.isEmpty
                          ? SingleChildScrollView(
                              child: GetX<MachineTransferUserListController>(
                                builder: (controller) {
                                  return CustomEmptyView(
                                    isLoading: controller.isLoading,
                                  );
                                },
                              ),
                            )
                          : Container(
                              child: ExpandableListView(
                                  controller: controller.scrollCtrl,
                                  physics: const BouncingScrollPhysics(),
                                  builder: SliverExpandableChildDelegate(
                                    controller: controller.listController,
                                    sectionList: controller.userSectionList,
                                    headerBuilder:
                                        (context, sectionIndex, index) {
                                      return Container(
                                        key: controller.keys[sectionIndex],
                                        width: 375.w,
                                        height: 25.w,
                                        color: const Color(0xFFF7FAFF),
                                        child: Center(
                                          child: sbRow([
                                            getSimpleText(
                                                controller
                                                    .startWords[sectionIndex],
                                                15,
                                                AppColor.textBlack,
                                                isBold: true),
                                          ], width: 375 - 23.5 * 2),
                                        ),
                                      );
                                    },
                                    itemBuilder: (context, sectionIndex,
                                        itemIndex, index) {
                                      Map user = controller
                                          .userSectionList[sectionIndex]
                                          .getItems()[itemIndex];

                                      return CustomButton(
                                        onPressed: () {
                                          var userData = controller
                                              .userSectionList[sectionIndex]
                                              .getItems()[itemIndex];
                                          if (isTerminalBack) {
                                            Get.to(
                                                TerminalBackSelect(
                                                  userData: userData,
                                                ),
                                                binding:
                                                    TerminalBackSelectBinding());
                                          } else {
                                            final ctrl = Get.find<
                                                MachineTransferController>();
                                            ctrl.selectUserData = userData;
                                            Get.back();
                                          }
                                        },
                                        child: Container(
                                          width: 375.w,
                                          height: 85.w,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width: 0.5.w,
                                                      color: const Color(
                                                          0xFFEBEBEB)))),
                                          child: Center(
                                              child: sbRow([
                                            centRow([
                                              CustomNetworkImage(
                                                src:
                                                    "${controller.imageUrl}${user["uAvatar"]}",
                                                width: 45.w,
                                                height: 45.w,
                                                fit: BoxFit.fill,
                                              ),
                                              // controller.imageUrl.isNotEmpty
                                              //     ?
                                              //     CustomNetworkImage(
                                              // src:
                                              //     "${controller.imageUrl}${user["uAvatar"]}",
                                              // width: 45.w,
                                              // height: 45.w,
                                              // fit: BoxFit.fill,
                                              //       )
                                              //     :
                                              SizedBox(
                                                width: 45.w,
                                                height: 45.w,
                                              ),
                                              gwb(18),
                                              centClm([
                                                getSimpleText(
                                                    user["uName"] ?? "未实名认证",
                                                    16,
                                                    AppColor.textBlack,
                                                    isBold: true),
                                                ghb(10),
                                                getSimpleText(
                                                    "${user["uNumber"] ?? ""}|${user["uMobile"] ?? ""}",
                                                    14,
                                                    AppColor.textBlack),
                                              ],
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start)
                                            ]),
                                          ], width: 375 - 15 * 2)),
                                        ),
                                      );
                                    },
                                  )),
                            );

                      // CupertinoListView.builder(
                      //   controller: controller.scrollCtrl,
                      //   sectionCount: controller.userSectionList != null &&
                      //           controller.userSectionList.isNotEmpty
                      //       ? controller.userSectionList.length
                      //       : 0,
                      //   sectionBuilder: (context, index, isFloating) {
                      //     return Container(
                      //       key: controller.keys[index.section],
                      //       width: 375.w,
                      //       height: 25.w,
                      //       color: const Color(0xFFF7FAFF),
                      //       child: Center(
                      //         child: sbRow([
                      //           getSimpleText(
                      //               controller.startWords[index.section],
                      //               15,
                      //               AppColor.textBlack,
                      //               isBold: true),
                      //         ], width: 375 - 23.5 * 2),
                      //       ),
                      //     );
                      //   },
                      //   childBuilder: (context, index) {
                      // Map user = controller.userSectionList[index.section]
                      //     [index.absoluteIndex];
                      //     return CustomButton(
                      //       onPressed: () {
                      //         final ctrl =
                      //             Get.find<MachineTransferController>();
                      //         ctrl.selectUserData = user;
                      //         Get.back();
                      //       },
                      //       child: Container(
                      //         width: 375.w,
                      //         height: 85.w,
                      //         decoration: BoxDecoration(
                      //             color: Colors.white,
                      //             border: Border(
                      //                 bottom: BorderSide(
                      //                     width: 0.5.w,
                      //                     color: const Color(0xFFEBEBEB)))),
                      //         child: Center(
                      //             child: sbRow([
                      //           centRow([
                      //             // controller.imageUrl.isNotEmpty
                      //             //     ?
                      //             //     CustomNetworkImage(
                      //             //         src:
                      //             //             "${controller.imageUrl}${user["uAvatar"]}",
                      //             //         width: 45.w,
                      //             //         height: 45.w,
                      //             //         fit: BoxFit.fill,
                      //             //       )
                      //             //     :
                      //             SizedBox(
                      //               width: 45.w,
                      //               height: 45.w,
                      //             ),
                      //             gwb(18),
                      //             centClm([
                      //               getSimpleText(user["uName"] ?? "", 16,
                      //                   AppColor.textBlack,
                      //                   isBold: true),
                      //               ghb(10),
                      //               getSimpleText(
                      //                   "${user["uNumber"] ?? ""}|${user["uMobile"] ?? ""}",
                      //                   13,
                      //                   AppColor.textBlack),
                      //             ],
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start)
                      //           ]),
                      //         ], width: 375 - 15 * 2)),
                      //       ),
                      //     );
                      //   },
                      //   itemInSectionCount: (section) {
                      //     return controller.userSectionList[section] != null &&
                      //             controller.userSectionList[section].isNotEmpty
                      //         ? controller.userSectionList[section].length
                      //         : 0;
                      //   },
                      // );

                      // Column(
                      //     key: controller.scrollContentKey,
                      //     children: controller.startWords
                      //         .asMap()
                      //         .entries
                      //         .map((e) => Column(
                      //               mainAxisSize: MainAxisSize.min,
                      //               children: [
                      //                 Container(
                      //                   key: controller.keys[e.key],
                      //                   width: 375.w,
                      //                   height: 25.w,
                      //                   color: const Color(0xFFF7FAFF),
                      //                   child: Center(
                      //                     child: sbRow([
                      //                       getSimpleText(e.value, 15,
                      //                           AppColor.textBlack,
                      //                           isBold: true),
                      //                     ], width: 375 - 23.5 * 2),
                      //                   ),
                      //                 ),
                      //                 ...(controller.userMap[e.value]
                      //                         as List)
                      //                     .asMap()
                      //                     .entries
                      //                     .map((e2) => CustomButton(
                      //                           onPressed: () {
                      //                             final ctrl = Get.find<
                      //                                 MachineTransferController>();
                      //                             ctrl.selectUserData =
                      //                                 e2.value;
                      //                             Navigator.pop(context);
                      //                           },
                      //                           child: Container(
                      //                             width: 375.w,
                      //                             height: 85.w,
                      //                             decoration: BoxDecoration(
                      //                                 color: Colors.white,
                      //                                 border: Border(
                      //                                     bottom: BorderSide(
                      //                                         width:
                      //                                             0.5.w,
                      //                                         color: const Color(
                      //                                             0xFFEBEBEB)))),
                      //                             child: Center(
                      //                                 child: sbRow([
                      //                               centRow([
                      //                                 controller.imageUrl
                      //                                         .isNotEmpty
                      //                                     ? CustomNetworkImage(
                      //                                         src:
                      //                                             "${controller.imageUrl}${e2.value["uAvatar"]}",
                      //                                         width: 45.w,
                      //                                         height:
                      //                                             45.w,
                      //                                         fit: BoxFit
                      //                                             .fill,
                      //                                       )
                      //                                     : SizedBox(
                      //                                         width: 45.w,
                      //                                         height:
                      //                                             45.w,
                      //                                       ),
                      //                                 gwb(18),
                      //                                 centClm([
                      //                                   getSimpleText(
                      //                                       e2.value[
                      //                                               "uName"] ??
                      //                                           "",
                      //                                       16,
                      //                                       AppColor
                      //                                           .textBlack,
                      //                                       isBold: true),
                      //                                   ghb(10),
                      //                                   getSimpleText(
                      //                                       "${e2.value["uNumber"] ?? ""}|${e2.value["uMobile"] ?? ""}",
                      //                                       13,
                      //                                       AppColor
                      //                                           .textBlack),
                      //                                 ],
                      //                                     crossAxisAlignment:
                      //                                         CrossAxisAlignment
                      //                                             .start)
                      //                               ]),
                      //                             ],
                      //                                     width: 375 -
                      //                                         15 * 2)),
                      //                           ),
                      //                         ))
                      //                     .toList()
                      //               ],
                      //             ))
                      //         .toList());
                    },
                  )),
              Padding(
                padding: EdgeInsets.only(right: 10.5.w),
                child: Align(
                  alignment: const Alignment(1.0, -0.5),
                  child: GetBuilder<MachineTransferUserListController>(
                    init: controller,
                    initState: (_) {},
                    builder: (_) {
                      return SizedBox(
                        child: GetBuilder<MachineTransferUserListController>(
                          init: controller,
                          initState: (_) {},
                          builder: (_) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: controller.startWords
                                  .asMap()
                                  .entries
                                  .map((e) => CustomButton(
                                        onPressed: () {
                                          double sectionHeight = 25.w;
                                          double rowHeight = 85.w;
                                          double toY = 0;
                                          for (var i = 0; i < e.key; i++) {
                                            List l = controller
                                                .userSectionList[i]
                                                .getItems();
                                            toY += sectionHeight;
                                            for (var j = 0; j < l.length; j++) {
                                              toY += rowHeight;
                                            }
                                          }

                                          // controller.listController
                                          //     .switchingSectionIndex = e.key;

                                          // final boxRender = ((controller
                                          //         .keys[e.key] as GlobalKey)
                                          //     .currentContext!
                                          //     .findRenderObject() as RenderBox);

                                          // final ancestorBox = controller
                                          //     .scrollContentKey.currentContext!
                                          //     .findRenderObject();
                                          // final position = boxRender
                                          //     .localToGlobal(Offset.zero,
                                          //         ancestor: ancestorBox);
                                          // controller.scrollCtrl
                                          //     .jumpTo(position.dy);

                                          controller.scrollCtrl.animateTo(
                                              // position.dy,
                                              toY,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.linear);
                                        },
                                        child: SizedBox(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.w),
                                            child: getSimpleText(e.value, 11,
                                                AppColor.textGrey2),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class UserSection extends ExpandableListSection {
  final List nameUserList;
  UserSection({required this.nameUserList});
  bool isExpanded = true;

  @override
  List getItems() {
    return nameUserList;
  }

  @override
  bool isSectionExpanded() {
    return isExpanded;
  }

  @override
  void setSectionExpanded(bool expanded) {
    isExpanded = expanded;
  }
}
