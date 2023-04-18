import 'package:flutter/material.dart';

class CustomDropDownController extends ChangeNotifier {
  /// [dropDownMenuTop] that the GZXDropDownMenu top edge is inset from the top of the stack.
  ///
  /// Since the GZXDropDownMenu actually returns a Positioned widget, the GZXDropDownMenu must be inside the Stack
  /// vertically.
  double? dropDownMenuTop;

  /// Current or last dropdown menu index, default is 0.
  // int? menuIndex = 0;

  /// Whether to display a dropdown menu.
  bool isShow = false;

  /// Whether to display animations when hiding dropdown menu.
  bool isShowHideAnimation = false;

  /// Use to display GZXDropdownMenu specified dropdown menu index.
  // void show(int index) {
  //   isShow = true;
  //   menuIndex = index;
  //   notifyListeners();
  // }
  void show(GlobalKey boxKey, GlobalKey headKey) {
    isShow = true;
    final RenderBox? overlay =
        boxKey.currentContext!.findRenderObject() as RenderBox?;

    final RenderBox dropDownItemRenderBox =
        headKey.currentContext!.findRenderObject() as RenderBox;

    var position =
        dropDownItemRenderBox.localToGlobal(Offset.zero, ancestor: overlay);
//        print("POSITION : $position ");
    var size = dropDownItemRenderBox.size;
//        print("SIZE : $size");

    dropDownMenuTop = size.height + position.dy;
    // menuIndex = index;
    notifyListeners();
  }

  /// Use to hide GZXDropdownMenu. If you don't need to show the hidden animation, [isShowHideAnimation] pass in false, Like when you click on another GZXDropdownHeaderItem.
  void hide({bool isShowHideAnimation = true}) {
    this.isShowHideAnimation = isShowHideAnimation;
    isShow = false;
    notifyListeners();
  }
}

typedef DropdownMenuChange = void Function(bool isShow);

class CustomDropDownView extends StatefulWidget {
  final CustomDropDownController? dropDownCtrl;
  final double height;
  final Widget? dropWidget;
  final DropdownMenuChange? dropdownMenuChange;
  final int? animationDuration;
  final double? top;
  final double? maskColorOpacity;
  final Function()? tapMaskHide;
  const CustomDropDownView(
      {Key? key,
      this.dropDownCtrl,
      this.top = 100,
      this.height = 100,
      this.dropWidget,
      this.tapMaskHide,
      this.dropdownMenuChange,
      this.maskColorOpacity = 0.2,
      this.animationDuration = 300})
      : super(key: key);

  @override
  State<CustomDropDownView> createState() => _CustomDropDownViewState();
}

class _CustomDropDownViewState extends State<CustomDropDownView>
    with SingleTickerProviderStateMixin {
  Animation<double>? _animation;
  AnimationController? _controller;
  bool _isShowMask = false;
  bool _isShowDropDownItemWidget = false;
  bool _isControllerDisposed = false;
  // double? _dropDownHeight;
  double _maskColorOpacity = 0.7;

  @override
  void initState() {
    super.initState();
    widget.dropDownCtrl?.addListener(_onController);
    _controller = AnimationController(
        duration: Duration(milliseconds: widget.animationDuration!),
        vsync: this);
  }

  _onController() {
//    print('_GZXDropDownMenuState._onController ${widget.controller.menuIndex}');

    _showDropDownItemWidget();
  }

  @override
  Widget build(BuildContext context) {
    _controller!.duration = Duration(milliseconds: widget.animationDuration!);
    return _buildDropDownWidget();
  }

  Widget _mask() {
    if (_isShowMask) {
      return GestureDetector(
        onTap: () {
          widget.dropDownCtrl?.hide();
          if (widget.tapMaskHide != null) {
            widget.tapMaskHide!();
          }
        },
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(_maskColorOpacity),
//          color: widget.maskColor,
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget _buildDropDownWidget() {
    return Positioned(
        top: widget.dropDownCtrl?.dropDownMenuTop,
        left: 0,
        right: 0,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: double.infinity,
              height: _animation == null ? 0 : _animation!.value,
              child: widget.dropWidget,
            ),
            _mask(),
          ],
        ));
  }

  void _animationListener() {
    var heightScale =
        _animation!.value / (widget.height <= 0 ? 100 : widget.height);
    _maskColorOpacity = widget.maskColorOpacity! * heightScale;
//    print('$_maskColorOpacity');
    //这行如果不写，没有动画效果
    setState(() {});
  }

  void _animationStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
//        print('dismissed');
        _isShowMask = false;
        if (widget.dropdownMenuChange != null) {
          widget.dropdownMenuChange!(false);
        }
        break;
      case AnimationStatus.forward:
        // TODO: Handle this case.
        break;
      case AnimationStatus.reverse:
        // TODO: Handle this case.
        break;
      case AnimationStatus.completed:
//        print('completed');
        if (widget.dropdownMenuChange != null) {
          widget.dropdownMenuChange!(true);
        }
        break;
    }
  }

  @override
  dispose() {
    _animation?.removeListener(_animationListener);
    _animation?.removeStatusListener(_animationStatusListener);
    widget.dropDownCtrl?.removeListener(_onController);
    _controller?.dispose();
    _isControllerDisposed = true;
    super.dispose();
  }

  _showDropDownItemWidget() {
    _isShowDropDownItemWidget = !_isShowDropDownItemWidget;
    if (widget.dropdownMenuChange != null) {
      widget.dropdownMenuChange!(_isShowDropDownItemWidget);
    }
    if (!_isShowMask) {
      _isShowMask = true;
    }

    // _dropDownHeight = widget.height ?? 0;

    _animation?.removeListener(_animationListener);
    _animation?.removeStatusListener(_animationStatusListener);
    _animation = Tween(begin: 0.0, end: widget.height).animate(_controller!)
      ..addListener(_animationListener)
      ..addStatusListener(_animationStatusListener);

    if (_isControllerDisposed) return;

//    print('${widget.controller.isShow}');
    if (widget.dropDownCtrl == null) return;

    if (widget.dropDownCtrl!.isShow) {
      _controller!.forward();
    } else if (widget.dropDownCtrl!.isShowHideAnimation) {
      _controller!.reverse();
    } else {
      _controller!.value = 0;
    }
  }
}
