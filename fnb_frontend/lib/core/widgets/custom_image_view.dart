import 'dart:convert';
import 'package:flutter/material.dart';

class CustomImageView extends StatelessWidget {
  final String imageString;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget fallback;

  const CustomImageView({
    super.key,
    required this.imageString,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallback = const Icon(Icons.image),
  });

  @override
  Widget build(BuildContext context) {
    if (imageString.isEmpty) {
      return fallback;
    }

    try {
      if (imageString.startsWith('http://') || imageString.startsWith('https://')) {
        return Image.network(
          imageString,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => fallback,
        );
      } else {
        // Base64
        String base64Str = imageString;
        if (imageString.contains(',')) {
          base64Str = imageString.split(',').last;
        }
        return Image.memory(
          base64Decode(base64Str),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => fallback,
        );
      }
    } catch (e) {
      return fallback;
    }
  }
}
