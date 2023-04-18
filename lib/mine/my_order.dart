import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({Key? key}) : super(key: key);

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, "详情"),
      body: SingleChildScrollView(
        child: Column(
          children: [Container()],
        ),
      ),
    );
  }
}
