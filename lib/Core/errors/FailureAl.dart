import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

class offlineFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class serverFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class cacheFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class wrongInputFailure extends Failure {
  @override
  List<Object?> get props => [];
}

