import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  
  const Failure([this.message]);
  
  @override
  List<Object?> get props => [message];
}

class OfflineFailure extends Failure {
  const OfflineFailure([String? message]) : super(message ?? 'No internet connection');
}

class ServerFailure extends Failure {
  const ServerFailure([String? message]) : super(message ?? 'Server error occurred');
}

class EmptyCachedFailure extends Failure {
  const EmptyCachedFailure([String? message]) : super(message ?? 'No cached data available');
}