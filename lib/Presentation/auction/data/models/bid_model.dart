import 'package:hanouty/Presentation/auction/domain/entity/bid.dart';

class BidModel extends Bid {
  const BidModel({
    required super.bidderId,
    required super.bidAmount,
    required super.bidTime,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      bidderId: json['bidderId'] ?? '',
      bidAmount: (json['bidAmount'] as num).toDouble(),
      bidTime: DateTime.parse(json['bidTime']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'bidderId': bidderId,
    'bidAmount': bidAmount,
    'bidTime': bidTime.toIso8601String()
  };
}