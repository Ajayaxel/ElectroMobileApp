import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomLoader extends StatelessWidget {
  final Color? color;
  final double radius;

  const CustomLoader({super.key, this.color, this.radius = 10});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(color: color, radius: radius);
    } else {
      return SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.black),
        ),
      );
    }
  }
}
