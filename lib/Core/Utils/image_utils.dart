import 'dart:io' as io;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanouty/Core/network/apiconastant.dart';

class ImageUtils {
  /// Builds an appropriate image widget based on the image data and platform
  static Widget buildImage({
    required BuildContext context,
    required dynamic imageSource,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Color? placeholderColor,
    Color? errorColor,
    Widget? loadingWidget,
    Widget? errorWidget,
    String? imageKey,
  }) {
    placeholderColor ??= Colors.grey[200];
    errorColor ??= Colors.grey[300];

    // Default loading widget
    loadingWidget ??= Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).primaryColor,
      ),
    );

    // Default error widget
    errorWidget ??= Container(
      color: errorColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.grey[400], size: 24),
            const SizedBox(height: 4),
            Text(
              'Image not found',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );

    // Null or empty check
    if (imageSource == null) {
      return Container(
        width: width,
        height: height,
        color: placeholderColor,
        child: Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
        ),
      );
    }

    // Default placeholder
    Widget placeholder = Container(
      width: width,
      height: height,
      color: placeholderColor,
      child: loadingWidget,
    );

    try {
      // CASE 1: String URL from network
      if (imageSource is String) {
        if (imageSource.isEmpty) return placeholder;

        // Get full image URL via ApiConstants
        final String fullImageUrl = kIsWeb
            ? ApiConstants.getImageUrlWithCacheBusting(imageSource)
            : ApiConstants.getFullImageUrl(imageSource);

        return CachedNetworkImage(
          imageUrl: fullImageUrl,
          fit: fit,
          width: width,
          height: height,
          key: ValueKey(imageKey ?? fullImageUrl),
          placeholder: (context, url) => placeholder,
          errorWidget: (context, url, error) {
            print('Error loading network image: $url - $error');
            return errorWidget!;
          },
          memCacheHeight: height?.toInt() ?? 400,
          memCacheWidth: width?.toInt() ?? 400,
          maxHeightDiskCache: height?.toInt() != null ? height!.toInt() * 2 : 800,
          maxWidthDiskCache: width?.toInt() != null ? width!.toInt() * 2 : 800,
        );
      }

      // CASE 2: Map with image data (from image picker)
      else if (imageSource is Map<String, dynamic>) {
        if (kIsWeb) {
          // Web platform: use data URL
          if (imageSource.containsKey('dataUrl') && imageSource['dataUrl'] != null) {
            return Image.network(
              imageSource['dataUrl'] as String,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (_, __, ___) => errorWidget!,
            );
          }
        } else {
          // Mobile platform: use bytes directly if available
          if (imageSource.containsKey('bytes') && imageSource['bytes'] != null) {
            return Image.memory(
              imageSource['bytes'] as Uint8List,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (_, __, ___) => errorWidget!,
            );
          }
          // Fall back to file path
          else if (imageSource.containsKey('path') && imageSource['path'] != null) {
            return Image.file(
              io.File(imageSource['path'] as String),
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (_, __, ___) => errorWidget!,
            );
          }
        }
      }

      // CASE 3: Byte data directly
      else if (imageSource is Uint8List) {
        return Image.memory(
          imageSource,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => errorWidget!,
        );
      }

      // CASE 4: File object
      else if (imageSource is io.File) {
        return Image.file(
          imageSource,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => errorWidget!,
        );
      }

      // Unknown type - return placeholder
      return placeholder;
    } catch (e) {
      print('Error displaying image: $e');
      return errorWidget;
    }
  }

  /// Shows detailed error dialog for image loading failures
  static void showImageErrorDialog(
      BuildContext context, {
        required String imageUrl,
        String? originalPath,
        dynamic error,
        bool isDarkMode = false,
      }) {
    final accentColor = isDarkMode ? const Color(0xFF81C784) : Colors.green;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF252525) : Colors.white,
        title: Text('Image Error',
            style: TextStyle(color: isDarkMode ? Colors.white : null)
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Failed to load image:',
                  style: TextStyle(color: isDarkMode ? Colors.white : null)
              ),
              const SizedBox(height: 8),
              Text(imageUrl,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[300] : null
                  )
              ),
              if (originalPath != null) ...[
                const SizedBox(height: 8),
                Text('Original path: $originalPath',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[300] : null
                    )
                ),
              ],
              const SizedBox(height: 12),
              if (error != null)
                Text('Error: ${error.toString()}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[isDarkMode ? 400 : 600]
                    )
                ),
              const SizedBox(height: 12),
              Text('Check that:',
                  style: TextStyle(color: isDarkMode ? Colors.white : null)
              ),
              Text('• Backend server is running',
                  style: TextStyle(color: isDarkMode ? Colors.grey[300] : null)
              ),
              Text('• File exists on server',
                  style: TextStyle(color: isDarkMode ? Colors.grey[300] : null)
              ),
              Text('• Path is correct',
                  style: TextStyle(color: isDarkMode ? Colors.grey[300] : null)
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close',
                style: TextStyle(color: accentColor)
            ),
          ),
          // Add option to retry loading
          if (imageUrl.startsWith('http') || imageUrl.startsWith('data:'))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Force a refresh by clearing the cache for this URL
                CachedNetworkImage.evictFromCache(imageUrl);
              },
              child: Text('Retry',
                  style: TextStyle(color: accentColor)
              ),
            ),
        ],
      ),
    );
  }
}