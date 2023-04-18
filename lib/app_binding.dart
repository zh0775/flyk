import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/income/income_page.dart';
import 'package:cxhighversion2/mine/mine_page.dart';
import 'package:cxhighversion2/statistics/statistics.dart';
import 'package:cxhighversion2/statistics/statistics_page/statistics_page.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() async {
    // Get.lazyPut<MainPageCtrl>(() => MainPageCtrl());
    // Get.put<EarnMainController>(EarnMainController());
    // Get.lazyPut<InformationMainController>(() => InformationMainController());
    Get.lazyPut<HomeController>(() => HomeController());
    // Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<MinePageController>(() => MinePageController());
    Get.lazyPut<IncomePageController>(() => IncomePageController());
    // Get.lazyPut<BusinessController>(() => BusinessController());
    // Get.lazyPut<StatisticsController>(() => StatisticsController());
    // Get.lazyPut<BounsPoolController>(() => BounsPoolController());
    Get.lazyPut<StatisticsPageController>(() => StatisticsPageController());

    // 金融区
    // Get.lazyPut<FinanceSpaceHomeController>(() => FinanceSpaceHomeController());
    // Get.lazyPut<FinanceSpaceMineController>(() => FinanceSpaceMineController());
  }
}
