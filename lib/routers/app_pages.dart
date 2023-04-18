// part of 'app_routes.dart';

import 'package:cxhighversion2/app_binding.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/information/information_main.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/mine/mine_page.dart';
import 'package:cxhighversion2/product/product.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

//  [_earnMain, _infomation, _home, _product, _minePage];
class AppPages {
  static const initial = Routes.main;
  static final routes = [
    GetPage(
      name: Routes.main,
      page: () => const MainPage(),
      binding: AppBinding(),
      // children: [
      //   GetPage(name: Routes.shareImage, page: () => CardsScreen()),
      // ]
    ),
    GetPage(
      name: Routes.home,
      page: () => const Home(),
      binding: HomeBinding(),
      // children: [
      //   GetPage(name: Routes.shareImage, page: () => CardsScreen()),
      // ]
    ),
    GetPage(
      name: Routes.infomation,
      page: () => const InformationMain(),
      binding: InformationBinding(),
    ),
    GetPage(
      name: Routes.minePage,
      page: () => const MinePage(),
      binding: MineBinding(),
    ),
    GetPage(
      name: Routes.product,
      page: () => const Product(),
      binding: ProductBinding(),
    ),
  ];
}
