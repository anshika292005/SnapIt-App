import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholderColor = const Color(0xFFE7ECEF),
    super.key,
  });

  final String imageUrl;
  final BoxFit fit;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _ErrorImage(
          color: placeholderColor,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (context, url) => ColoredBox(color: placeholderColor),
      errorWidget: (context, url, error) => _ErrorImage(
        color: placeholderColor,
      ),
    );
  }
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: const Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}
