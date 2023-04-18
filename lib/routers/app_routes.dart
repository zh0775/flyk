part of 'app_pages.dart';

//  [_earnMain, _infomation, _home, _product, _minePage];
abstract class Routes {
  static const main = '/';
  static const splash = '/splash';
  static const auth = '/auth';
  static const login = '/login';
  static const register = '/register';
  static const userAccept = '/userAccept';
  static const userPrivacy = '/userPrivacy';

  static const earn = '/earn';
  static const earnDetail = '/earn/detail';

  static const infomation = '/infomation';

  static const home = '/home';

  static const product = '/product';

  static const minePage = '/minePage';

  static const shareImage = '/home/share';

  //商户列表
  static const merchantList = '/merchant/merchantList';
  //身份证识别
  static const IdentificationCart = '/Identification/cart';
}
