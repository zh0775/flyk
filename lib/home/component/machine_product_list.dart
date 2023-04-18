import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/app_bottom_tips.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/home/component/machine_product_cell.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineProductList extends StatefulWidget {
  final bool isList;
  final Function(int idx)? toPay;
  final List? machineDatas;
  final Function()? onRefresh;
  final Function()? onLoading;
  final bool enablePullUp;
  final RefreshController pullCtrl;
  final Function()? retryAction;
  final CustomEmptyType emptyType;
  final double paddingBottom;
  const MachineProductList(
      {Key? key,
      this.isList = true,
      this.machineDatas,
      this.toPay,
      this.onLoading,
      this.onRefresh,
      this.paddingBottom = 0,
      required this.emptyType,
      required this.pullCtrl,
      this.retryAction,
      this.enablePullUp = false})
      : super(key: key);

  @override
  State<MachineProductList> createState() => _MachineProductListState();
}

class _MachineProductListState extends State<MachineProductList> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 345.w,
        color: AppColor.pageBackgroundColor,
        child: SmartRefresher(
            onRefresh: widget.onRefresh,
            onLoading: widget.onLoading,
            enablePullDown: true,
            enablePullUp: widget.enablePullUp,
            physics: const BouncingScrollPhysics(),
            controller: widget.pullCtrl,
            child: widget.machineDatas == null || widget.machineDatas!.isEmpty
                ? CustomEmptyView(
                    type: widget.emptyType, retryAction: widget.retryAction)
                : (widget.isList
                    ? ListView.builder(
                        padding: EdgeInsets.only(bottom: widget.paddingBottom),
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.machineDatas != null
                            ? widget.machineDatas!.length
                            : 0,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(top: 12.w),
                            child: MachineProductCell(
                              cellData: widget.machineDatas![index],
                              isList: widget.isList,
                              index: index,
                              toPay: (idx) {
                                if (widget.toPay != null) {
                                  widget.toPay!(idx);
                                }
                              },
                            ),
                          );
                        },
                      )
                    : Padding(
                        padding: EdgeInsets.only(
                            top: 12.w,
                            left: 15.w,
                            bottom: widget.paddingBottom),
                        child: Wrap(
                          spacing: 9.w,
                          runSpacing: 12.w,
                          children: cells(),
                        ),
                      ))));
  }

  List<Widget> cells() {
    List<Widget> items = [];

    for (var i = 0; i < widget.machineDatas!.length; i++) {
      items.add(MachineProductCell(
        index: i,
        cellData: widget.machineDatas![i],
        isList: false,
        toPay: (idx) {
          if (widget.toPay != null) {
            widget.toPay!(idx);
          }
        },
      ));
    }
    return items;
  }
}
