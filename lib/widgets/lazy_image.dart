import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LazyImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final Duration placeholderFadeInDuration;

  const LazyImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholderFadeInDuration: placeholderFadeInDuration,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      memCacheHeight: height?.toInt(),
      memCacheWidth: width?.toInt(),
      maxHeightDiskCache: 1000,
      maxWidthDiskCache: 1000,
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.image,
              size: (width ?? 100) * 0.3,
              color: Colors.grey[400],
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: (width ?? 100) * 0.3,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 4),
                Text(
                  'No Image',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

class LazyImageBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ImageProvider) imageBuilder;
  final String imageUrl;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LazyImageBuilder({
    Key? key,
    required this.imageBuilder,
    required this.imageUrl,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return placeholder ?? const SizedBox.shrink();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      placeholder: (context, url) => placeholder ?? const SizedBox.shrink(),
      errorWidget: (context, url, error) => errorWidget ?? const SizedBox.shrink(),
      imageBuilder: imageBuilder,
      memCacheHeight: height?.toInt(),
      memCacheWidth: width?.toInt(),
      maxHeightDiskCache: 1000,
      maxWidthDiskCache: 1000,
    );
  }
}
