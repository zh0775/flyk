import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/size_config.dart';
import 'package:flutter_screenutil/src/size_extension.dart';

typedef void OnTabItemClick(int index);

class MyTabBar extends StatefulWidget {
  final OnTabItemClick? tabItemClick;
  final List? tabbarData;
  MyTabBar({Key? key, this.tabItemClick, this.tabbarData}) : super(key: key);
  @override
  _MyTabBarState createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar> {
  double? widthScale;
  double? margin;
  int _currentIndex = 0;
  int waitClientCount = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    widthScale = SizeConfig.blockSizeHorizontal;
    margin = widthScale! * 3;
    return BottomNavigationBar(
      selectedFontSize: 13.sp,
      unselectedFontSize: 13.sp,
      selectedItemColor: const Color(0xFFDA5059),
      unselectedItemColor: const Color(0xFFACAFBE),
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      items: createItems(widget.tabbarData!),
      onTap: (index) {
        if (widget.tabItemClick != null) {
          widget.tabItemClick!(index);
        }
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  List<BottomNavigationBarItem> createItems(List datas) {
    List<BottomNavigationBarItem> items = [];
    if (datas != null && datas.isNotEmpty) {
      int i = 0;
      for (Map e in datas) {
        items.add(createItem(e["normaIcon"], e['activeIcon'], e['title']));
        i++;
      }
    }
    return items;
  }

  Widget tabBarItem({String title = "", IconData? icons, int index = -1}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index != _currentIndex) {
          setState(() {
            _currentIndex = index;
          });

          if (widget.tabItemClick != null) {
            widget.tabItemClick!(index);
          }
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widthScale! * 15,
          ),
          Text(title,
              style: index == _currentIndex
                  ? TextStyle(color: const Color(0xFFDA5059), fontSize: 13.sp)
                  : TextStyle(color: const Color(0xFFACAFBE), fontSize: 13.sp)),
        ],
      ),
    );
  }

  BottomNavigationBarItem createItem(
      String iconName, String activeIconName, String title,
      {bool have = false, int count = 0}) {
    return BottomNavigationBarItem(
        icon: SizedBox(
          height: 30.w,
          width: 30.w,
          child: Stack(
            // overflow: Overflow.visible,
            children: [
              Positioned.fill(
                  child: Center(
                child: Image.asset(
                  iconName,
                  width: 24.w,
                  fit: BoxFit.fill,
                ),
              )),
              have && count != null && count > 0
                  ? Positioned(
                      top: -2.5.w,
                      right: -2.5.w,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(9.w)),
                        child: Text(
                          count > 99 ? '99' : count.toString(),
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                      ))
                  : const SizedBox(
                      width: 0,
                      height: 0,
                    )
            ],
          ),
        ),
        activeIcon: SizedBox(
          width: 30.w,
          height: 30.w,
          child: Stack(
            // overflow: Overflow.visible,
            children: [
              Positioned.fill(
                  child: Center(
                child: Image.asset(
                  activeIconName,
                  width: 24.w,
                  fit: BoxFit.fitWidth,
                ),
              )),
              have && count != null && count > 0
                  ? Positioned(
                      top: -2.5.w,
                      right: -2.5.w,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(9.w)),
                        child: Text(
                          count.toString(),
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                      ))
                  : const SizedBox()
            ],
          ),
        ),
        label: title);
  }
}
