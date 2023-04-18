import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';

import 'package:get/get.dart';

class CustomMessageController extends GetxController {
  late Timer? _timer;
  PageController? _pageController;

  @override
  void onInit() {
    _pageController = PageController(initialPage: 0, keepPage: true);
    super.onInit();
  }

  List messages = [];
  dataInit(List datas) {
    messages = datas;
    autoScroll(messages != null && messages.isNotEmpty);
  }

  autoScroll(bool scroll) {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    if (scroll) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController != null && _pageController!.page != null) {
          _pageController!.animateToPage(_pageController!.page!.toInt() + 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        }
      });
    }
  }

  @override
  void onClose() {
    _pageController!.dispose();
    _timer?.cancel();
    _timer = null;
    super.onClose();
  }
}

class CustomMessage extends StatefulWidget {
  final List datas;
  final double width;
  final double height;
  const CustomMessage(
      {Key? key, this.datas = const [], this.height = 100, this.width = 50})
      : super(key: key);

  @override
  State<CustomMessage> createState() => _CustomMessageState();
}

class _CustomMessageState extends State<CustomMessage> {
  Timer? _timer;
  PageController? _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0, keepPage: true);
    if (mounted) {
      autoScroll(widget.datas != null && widget.datas.isNotEmpty);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomMessage oldWidget) {
    autoScroll(widget.datas != null && widget.datas.isNotEmpty);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pageController!.dispose();
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  autoScroll(bool scroll) {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    if (scroll) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController != null && _pageController!.page != null) {
          if ((_pageController!.page!.toInt() + 1) >= 1000) {
            _pageController!.jumpToPage(0);
          } else {
            _pageController!.animateToPage(_pageController!.page!.toInt() + 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        height: widget.height,
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.datas.isEmpty ? 0 : 200,
          itemBuilder: (context, index) {
            Map data = widget.datas[index % widget.datas.length];
            return getContentText(
                data["n_Meta"] ?? "",
                14,
                AppDefault().getThemeColor() ?? AppColor.theme,
                widget.width,
                widget.height,
                1,
                overflow: TextOverflow.ellipsis,
                textHeight: 1.4);
          },
        ));
  }
}

// class CustomMessage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//         width: width,
//         height: height,
//         child: GetBuilder<CustomMessageController>(
//           initState: (state) {
//             state.controller?.dataInit(datas);
//           },
//           init: CustomMessageController(),
//           builder: (_) {
//             // _.dataInit(datas);
//             return PageView.builder(
//               scrollDirection: Axis.vertical,
//               controller: _._pageController,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: datas.isEmpty ? 0 : 200,
//               itemBuilder: (context, index) {
//                 Map data = datas[index % datas.length];
//                 return getContentText(
//                   "${data["title"] != null ? "${data["title"]}：" : ""}${data["n_Meta"]}",
//                   14,
//                   AppColor.theme,
//                   width,
//                   height,
//                   1,
//                   overflow: TextOverflow.ellipsis,
//                 );
//               },
//             );
//           },
//         ));
//   }
// }
