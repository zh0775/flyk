import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final String? image;
  final Widget? child;
  const CustomBackground({super.key, this.image, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      // height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fitWidth,
              repeat: ImageRepeat.repeatY,
              image: AssetImage(assetsName(image ?? "common/bg_page")))),
      child: child,
    );
  }
}
