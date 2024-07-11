import 'package:flutter/material.dart';

class BottomRoundedClipper extends CustomClipper<Path> {
  final double radius;

  BottomRoundedClipper(this.radius);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - radius);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
