import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:flutter/material.dart';

class CustomListEmptyView extends StatelessWidget {
  final bool isLoading;
  final ScrollPhysics? physics;
  const CustomListEmptyView({
    super.key,
    this.isLoading = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics,
      child: Center(
          child: CustomEmptyView(
        isLoading: isLoading,
        bottomSpace: 200,
      )),
    );
  }
}
