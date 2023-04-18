import 'dart:async';

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/third/banner_carousel-1.2.1/banner_model.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BannerData {
  /// The [imagePath] is the path to the image.
  /// That can be assert Path or Network Path
  final String imagePath;

  /// The [id] to indentify the banner.
  final String id;
  final double? imgWidth;
  final double? imgHeight;

  /// The [boxFit] How the image should be inscribed into the [Container].
  /// Default value is [BoxFit.cover]
  final BoxFit boxFit;

  final Map data;

  ///
  /// BannerModel(imagePath: '/assets/banner1.png', id: "1")
  ///
  /// OR
  ///
  /// BannerModel(imagePath: '"https://picjumbo.com/wp-content/uploads/the-golden-gate-bridge-sunset-1080x720.jpg"', id: "2"),
  BannerData(
      {required this.imagePath,
      required this.id,
      this.boxFit = BoxFit.cover,
      this.imgHeight,
      this.imgWidth,
      this.data = const {}});
}

class AppBanner extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isFullScreen;
  // final PageController controller;
  final List<BannerData> banners;
  final Function(Map data)? bannerClick;
  const AppBanner(
      {Key? key,
      this.width = 345,
      this.height = 150,
      // required this.controller,
      this.borderRadius = 0,
      this.banners = const [],
      this.bannerClick,
      this.isFullScreen = true})
      : super(key: key);
  @override
  State<AppBanner> createState() => _AppBannerState();
}

class _AppBannerState extends State<AppBanner> {
  int currentIndex = 0;
  int oldDataLength = 0;
  int allCount = 1000;
  Timer? _timer;
  PageController? _pageController;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    super.dispose();
  }

  // checkData() {
  //   if (widget.banners.isEmpty) {
  //     return;
  //   }
  //   if (widget.banners.length != 0 && widget.banners.length != oldDataLength) {
  //     oldDataLength = widget.banners.length;
  //     int halfCount = (allCount / 2).ceil();

  //     if (widget.controller.position.hasContentDimensions &&
  //         widget.controller.page != null &&
  //         widget.controller.positions.isNotEmpty) {
  //       widget.controller.jumpToPage(halfCount - halfCount % oldDataLength);
  //     }
  //   }
  // }

  @override
  void didUpdateWidget(covariant AppBanner oldWidget) {
    int halfCount = (allCount / 2).ceil();
    _pageController?.dispose();
    _pageController = null;
    _pageController = PageController(
        initialPage: widget.banners.isNotEmpty
            ? halfCount - halfCount % widget.banners.length
            : 0);
    autoScroll(widget.banners != null && widget.banners.isNotEmpty);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // checkData();
    return SizedBox(
      width: widget.width.w,
      height: widget.height.w,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.banners != null && widget.banners.isNotEmpty
                  ? allCount
                  : 0,
              itemBuilder: (context, index) {
                return bannerItem(
                    widget.banners[index % widget.banners.length]);
              },
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value % widget.banners.length;
                });
              },
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              height: 5.w,
              bottom: 5.w,
              child: Center(
                child: bannerTag(),
              ))
        ],
      ),
    );

    // widget.isFullScreen
    //     ? BannerCarousel.fullScreen(
    //         borderRadius: widget.borderRadius,
    //         banners: bannerDataFormat(widget.banners),
    //         height: widget.height,
    //         onTap: widget.bannerClick,
    //         indicatorBottom: false,
    //       )
    //     : BannerCarousel(
    //         borderRadius: widget.borderRadius,
    //         banners: bannerDataFormat(widget.banners),
    //         height: widget.height,
    //         indicatorBottom: false,
    //         onTap: widget.bannerClick,
    //       );
  }

  autoScroll(bool scroll) {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    if (scroll) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController != null && _pageController!.page != null) {
          if (_pageController!.page!.toInt() + 1 >= allCount) {
            int halfCount = (allCount / 2).ceil();
            _pageController!.jumpToPage(
              halfCount - halfCount % widget.banners.length,
            );
          } else {
            _pageController!.animateToPage(_pageController!.page!.toInt() + 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear);
          }
        }
      });
    }
  }

  Widget bannerTag() {
    List<Widget> tags = [];
    if (widget.banners == null || widget.banners.isEmpty) {
      return centRow(tags);
    }
    for (var i = 0; i < widget.banners.length; i++) {
      if (i != 0) {
        tags.add(gwb(5));
      }
      tags.add(AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: i == currentIndex ? 15.w : 5.w,
        height: 5.w,
        decoration: BoxDecoration(
            color: i == currentIndex
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2.5.w)),
      ));
    }
    return centRow(tags);
  }

  Widget bannerItem(BannerData data) {
    return CustomButton(
      onPressed: () {
        if (widget.bannerClick != null) {
          widget.bannerClick!(data.data);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius.w),
        child: data.imagePath.contains("http")
            ? CustomNetworkImage(
                src: data.imagePath,
                width: data.imgWidth?.w ?? widget.width.w,
                height: data.imgHeight?.w ?? widget.height.w,
                fit: data.boxFit,
              )
            : Image.asset(assetsName(data.imagePath),
                width: data.imgWidth?.w ?? widget.width.w,
                height: data.imgHeight?.w ?? widget.height.w,
                fit: data.boxFit),
      ),
      // ClipPath(
      //   clipper: BannerClippper(arc: 40.w),
      //   child: CustomNetworkImage(
      //     src: data.imagePath,
      //     width: widget.width.w,
      //     height: widget.height.w,
      //     fit: data.boxFit,
      //   ),
      // )
    );
  }

  List<BannerModel> bannerDataFormat(List<BannerData> datas) {
    List<BannerModel> list = [];
    if (datas != null && datas.isNotEmpty) {
      for (var e in datas) {
        list.add(BannerModel(imagePath: e.imagePath, id: e.id));
      }
      return list;
    } else {
      return [];
    }
  }
}

class BannerClippper extends CustomClipper<Path> {
  final double arc;
  BannerClippper({required this.arc});
  Path path = Path();

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height - arc);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - arc);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
