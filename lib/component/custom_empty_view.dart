import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum CustomEmptyType { networkError, noData, noMessage, pageNone, noContent, carNoData }

class CustomEmptyViewController extends GetxController {
  final _isFirst = true.obs;
  bool get isFirst => _isFirst.value;
  set isFirst(v) => _isFirst.value = v;
}

class CustomEmptyView extends StatelessWidget {
  final CustomEmptyType? type;
  final Function()? retryAction;
  final bool isLoading;
  final String? contentText;
  final double topSpace;
  final double centerSpace;
  final double bottomSpace;
  final double imageWidth;
  const CustomEmptyView({
    Key? key,
    this.type = CustomEmptyType.noData,
    this.retryAction,
    this.topSpace = 82,
    this.centerSpace = 28,
    this.bottomSpace = 0,
    this.imageWidth = 160,
    this.isLoading = false,
    this.contentText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          if (retryAction != null) {
            retryAction!();
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ghb(topSpace),
            Image.asset(
              getImgName(type!),
              width: imageWidth.w,
              fit: BoxFit.fitWidth,
            ),
            ghb(centerSpace),
            getTitle(type!),
            Visibility(visible: type == CustomEmptyType.networkError || type == CustomEmptyType.pageNone, child: ghb(22.w)),
            Visibility(visible: type == CustomEmptyType.networkError || type == CustomEmptyType.pageNone, child: getSimpleText(type == CustomEmptyType.networkError ? "点击重新加载" : "重试", 14, AppColor.buttonTextBlue)),
            ghb(bottomSpace),
          ],
        ),
      ),
    );
  }

  String getImgName(CustomEmptyType type) {
    switch (type) {
      case CustomEmptyType.networkError:
        return assetsName("common/bg_empty0");
      case CustomEmptyType.noData:
        return assetsName("common/bg_empty1");
      case CustomEmptyType.noMessage:
        return assetsName("common/bg_empty2");
      case CustomEmptyType.pageNone:
        return assetsName("common/bg_empty3");
      case CustomEmptyType.noContent:
        return assetsName("common/bg_empty4");
      case CustomEmptyType.carNoData:
        return assetsName("business/mall/bg_empty");
      default:
        return "";
    }
  }

  Widget getTitle(CustomEmptyType type) {
    switch (type) {
      case CustomEmptyType.networkError:
        return getSimpleText(isLoading ? "正在获取数据中，请稍后" : (contentText ?? "网络出错了，加载失败"), 15, AppColor.text3);
      case CustomEmptyType.noData:
      case CustomEmptyType.carNoData:
        // return GetX<CustomEmptyViewController>(
        //   init: CustomEmptyViewController(),
        //   builder: (controller) {
        //     return getSimpleText("暂时没有数据，请呆会再来", 14, const Color(0xFF9A9FB4));
        //   },
        // );
        return getSimpleText(isLoading ? "正在获取数据中，请稍后" : (contentText ?? "暂无记录"), 15, AppColor.text3);
      case CustomEmptyType.noMessage:
        return getSimpleText(isLoading ? "正在获取数据中，请稍后" : (contentText ?? "暂时没有新消息"), 15, AppColor.text3);
      case CustomEmptyType.pageNone:
        return getSimpleText(isLoading ? "正在获取数据中，请稍后" : (contentText ?? "404,您访问的页面不存在"), 15, AppColor.text3);
      case CustomEmptyType.noContent:
        return getSimpleText(isLoading ? "正在获取数据中，请稍后" : (contentText ?? "没有内容，晚点再来"), 15, AppColor.text3);
      default:
        return const SizedBox();
    }
  }
}
