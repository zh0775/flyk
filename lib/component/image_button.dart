import 'package:flutter/material.dart';

class CustomImageButton extends StatefulWidget {
  final Function()? onPressed;
  final String? img;
  final Widget? title;
  final double? width;
  final double? height;
  const CustomImageButton(
      {Key? key,
      this.onPressed,
      this.img = "",
      this.title,
      this.width,
      this.height})
      : super(key: key);

  @override
  State<CustomImageButton> createState() => _CustomImageButtonState();
}

class _CustomImageButtonState extends State<CustomImageButton> {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        onPressed: widget.onPressed,
        child: SizedBox(
          width: widget.width ?? 335,
          height: widget.height ?? 46,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  widget.img ?? "assets/images/login/btn_login.png",
                  fit: BoxFit.fill,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: widget.title ?? const SizedBox(),
              )
            ],
          ),
        ));
  }
}
