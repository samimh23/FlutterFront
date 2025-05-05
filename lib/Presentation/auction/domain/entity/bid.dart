import 'package:equatable/equatable.dart';

abstract class Bid extends Equatable {
  final String bidderId;
  final double bidAmount;
  final DateTime bidTime;

  const Bid({
    required this.bidderId,
    required this.bidAmount,
    required this.bidTime,
  });
  Map<String, dynamic> toJson();
  @override
  List<Object?> get props => [bidderId, bidAmount, bidTime];
}