import 'package:flutter/material.dart';
import 'dart:math' as math;

class MyTransition {
  Widget animate(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // animation.value;
    // if (page >= index) {
    //   /// _pageController.page > index 向右滑动 划出下一页 下一页可见
    //   alignment = Alignment.centerRight;
    //   value = 1 - aniValue;
    // } else {
    //   /// _pageController.page < index 向左滑动 划出上一页
    //   alignment = Alignment.centerLeft;
    //   value = aniValue - 1;
    // }

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(math.pi * 2 * animation.value),
      alignment: Alignment.centerLeft,
      child: child,
    );

    // SlideTransition(
    //   position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
    //       .animate(animation),
    //   child: child,
    // );
  }
}

class PageAnimationTransition extends PageRouteBuilder {
  final Widget page;
  PageAnimationTransition({required this.page})
      : super(
            pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
                page);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return MyTransition()
        .animate(context, animation, secondaryAnimation, child);
  }
}
