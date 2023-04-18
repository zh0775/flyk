import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TerminalBinding extends StatefulWidget {
  final Map machineData;
  const TerminalBinding({super.key, this.machineData = const {}});

  @override
  State<TerminalBinding> createState() => _TerminalBindingState();
}

class _TerminalBindingState extends State<TerminalBinding> {
  final nameTextCtrl = TextEditingController();
  final snTextCtrl = TextEditingController();

  bool submitEnable = true;

  late BottomPayPassword bottomPayPassword;

  bindingAction() {
    if (nameTextCtrl.text.isEmpty) {
      ShowToast.normal("请输入代理姓名/手机号");
      return;
    }
    if (snTextCtrl.text.isEmpty) {
      ShowToast.normal("请输入设备SN号");
      return;
    }

    takeBackKeyboard(context);

    setState(() {
      submitEnable = false;
    });

    simpleRequest(
      url: Urls.terminalAssociate,
      params: {
        "businessNo": nameTextCtrl.text,
        "terminal_No": snTextCtrl.text,
      },
      success: (success, json) {
        if (success &&
            json["messages"] != null &&
            json["messages"].isNotEmpty) {
          ShowToast.normal(json["messages"]);
        }
      },
      after: () {
        setState(() {
          submitEnable = true;
        });
      },
    );
  }

  scanSnAction() {
    toScanBarCode(((barCode) => snTextCtrl.text = barCode));
  }

  @override
  void initState() {
    if (widget.machineData.isNotEmpty) {
      Map homeData = AppDefault().homeData;
      Map authentication = homeData["authentication"] ?? {};
      nameTextCtrl.text = (authentication["isCertified"] ?? false)
          ? authentication["u_Name"]
          : homeData["u_Mobile"] ?? "";
      snTextCtrl.text = widget.machineData["tNo"] ?? "";
    }
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {},
    );
    super.initState();
  }

  @override
  void dispose() {
    nameTextCtrl.dispose();
    snTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "关联设备", color: Colors.white),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                ghb(30),
                gwb(375),
                getSimpleText("关联已有设备每笔交易可获得积分", 15, AppColor.textBlack),
                Container(
                  width: 345.w,
                  padding: EdgeInsets.only(bottom: 25.w),
                  margin: EdgeInsets.only(top: 25.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                  child: Column(
                    children: [
                      input(
                        0,
                      ),
                      input(1),
                    ],
                  ),
                ),
                ghb(50),
                getSubmitBtn("开始关联", () {
                  bindingAction();
                },
                    enable: submitEnable,
                    height: 45,
                    color: AppColor.theme,
                    fontSize: 15),
              ],
            )),
      ),
    );
  }

  Widget input(int type) {
    double width = (345 - 10 * 2).w;
    return SizedBox(
      width: width,
      child: centClm([
        SizedBox(
          height: 50.w,
          child: Center(
            child: getSimpleText(type == 0 ? "填写代理姓名/手机号" : "填写SN号/扫描SN号", 13,
                AppColor.textBlack),
          ),
        ),
        Container(
            width: width,
            height: 50.w,
            decoration: BoxDecoration(color: AppColor.pageBackgroundColor),
            child: Row(
              children: [
                gwb(15),
                CustomInput(
                  textEditCtrl: type == 0 ? nameTextCtrl : snTextCtrl,
                  width: width - 25.w - (type == 0 ? 0 : 51.5.w),
                  heigth: 50.w,
                  placeholder: type == 0 ? "填写代理姓名/手机号" : "填写设备SN号",
                ),
                gwb(10),
                type == 0
                    ? gwb(0)
                    : centRow([
                        gline(1, 30),
                        CustomButton(
                          onPressed: () => scanSnAction(),
                          child: SizedBox(
                            width: 50.w,
                            height: 50.w,
                            child: Center(
                              child: Image.asset(
                                assetsName("home/machinemanage/tiaoxingma"),
                                width: 20.w,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        )
                      ])
              ],
            ))
        //
      ]),
    );
  }
}
