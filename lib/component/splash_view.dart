import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashView extends StatelessWidget {
  final Function()? closeSplash;
  const SplashView({Key? key, this.closeSplash}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return splashPage(index);
      },
    );
  }

  Widget splashPage(int index) {
    Size imageSize = const Size(540, 941);
    Size imageButtonSize = const Size(175, 50);
    Size screenSize = Size(ScreenUtil().screenWidth, ScreenUtil().screenHeight);

    return index == 2
        ? SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Stack(
              children: [
                Positioned.fill(child: splashImage(index)),
                Positioned(
                  top: screenSize.height / imageSize.height * 843,
                  left: 0,
                  right: 0,
                  height: screenSize.height /
                      imageSize.height *
                      imageButtonSize.height,
                  child: CustomButton(
                      onPressed: () {
                        if (closeSplash != null) {
                          closeSplash!();
                        }
                      },
                      child: Center(
                        child: SizedBox(
                          width: screenSize.width /
                              imageSize.width *
                              imageButtonSize.width,
                          height: screenSize.height /
                              imageSize.height *
                              imageButtonSize.height,
                        ),
                      )),
                )
              ],
            ),
          )
        : splashImage(index);
  }

  Widget splashImage(int index) {
    return Image.asset(
      assetsName(
        "splash/bg_splash_0${index + 1}",
      ),
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight,
      fit: BoxFit.fill,
    );
  }
}
