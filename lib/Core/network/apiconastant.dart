class ApiConstants {
  // Base API URL - change this when deploying to production
  static const String baseUrl = 'http://localhost:3000';

  // Method to convert image paths to correct URLs
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Return empty for null/empty paths
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Handle Windows-style backslashes
    final String normalizedPath = imagePath.replaceAll('\\', '/');

    // For paths already starting with uploads/ or /uploads/
    if (normalizedPath.startsWith('/uploads/')) {
      return '$baseUrl$normalizedPath';
    } else if (normalizedPath.startsWith('uploads/')) {
      return '$baseUrl/$normalizedPath';
    }

    // Default case - assume it's just a filename
    return '$baseUrl/uploads/$normalizedPath';
  }

  // Helper method to append cache-busting parameter to defeat CORS caching issues
  // You can use this for Flutter Web specifically if needed
  static String getImageUrlWithCacheBusting(String? imagePath) {
    final String url = getFullImageUrl(imagePath);
    if (url.isEmpty) return url;

    // Add timestamp to prevent caching
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (url.contains('?')) {
      return '$url&_cb=$timestamp';
    } else {
      return '$url?_cb=$timestamp';
    }
  }
}
