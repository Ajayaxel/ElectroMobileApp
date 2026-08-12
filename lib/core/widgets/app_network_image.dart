import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.loadingBuilder,
  });

  static bool hasImage(String? value) =>
      value != null && value.trim().isNotEmpty;

  static Widget placeholder({
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) {
    return Image.asset(
      AppAssets.batteryPlaceholder,
      fit: fit,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!hasImage(url)) {
      return placeholder(fit: fit, width: width, height: height);
    }

    return Image.network(
      url!.trim(),
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: loadingBuilder,
      errorBuilder: (context, error, stackTrace) =>
          placeholder(fit: fit, width: width, height: height),
    );
  }
}
