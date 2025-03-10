class ServerException implements Exception {
  final String? message;
  final int? statusCode;
  
  ServerException({this.message, this.statusCode});
  
  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class EmptyCacheException implements Exception {}

class OfflineException implements Exception {}