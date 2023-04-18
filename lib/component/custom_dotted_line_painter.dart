import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:path_drawing/path_drawing.dart';

class CustomDottedPinePainter extends CustomPainter {
  final Path path;
  final Color color;
  final double strokeWidth;
  final double dashSingleWidth;
  final double dashSingleGap;

  const CustomDottedPinePainter({
    required this.path,
    required this.color,
    this.strokeWidth = 1.5,
    this.dashSingleWidth = 6,
    this.dashSingleGap = 3,
  });
  @override
  void paint(Canvas canvas, Size size) {
    // print("path === ${path.toString()}");

    canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(
              <double>[dashSingleWidth.w, dashSingleGap.w]),
        ),
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth.w
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(CustomDottedPinePainter oldDelegate) =>
      oldDelegate.path != path || oldDelegate.color != color;

  @override
  bool hitTest(Offset position) => path.contains(position);
}
