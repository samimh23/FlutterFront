import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/entity/bid.dart';
import 'package:hanouty/Presentation/auction/data/models/bid_model.dart';

class AuctionModel extends Auction {
  AuctionModel({
    required super.id,
    required super.cropId,
    required super.description,
    required super.farmerId,
    required super.bids,
    required super.startingPrice,
    required super.startTime,
    required super.endTime,
    required super.status,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      id: json['_id'] as String,
      cropId: json['cropId'] as String,
      description: json['description'] as String,
      farmerId: json['farmerId'] as String,
      bids: (json['bids'] as List<dynamic>?)
          ?.map((b) => BidModel.fromJson(b as Map<String, dynamic>))
          .toList() ??
          [],
      startingPrice: (json['startingPrice'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: _parseAuctionStatus(json['status']),
    );
  }

  static AuctionStatus? _parseAuctionStatus(dynamic status) {
    if (status == null) return null;
    if (status is int && status >= 0 && status < AuctionStatus.values.length) {
      return AuctionStatus.values[status];
    } else if (status is String) {
      return auctionStatusFromString(status);
    }
    return null;
  }

  static AuctionStatus? auctionStatusFromString(String value) {
    return AuctionStatus.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => AuctionStatus.active,
    );
  }

  static String? auctionStatusToString(AuctionStatus? status) =>
      status?.toString().split('.').last;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'cropId': cropId,
      'description': description,
      'farmerId': farmerId,
      'bids': bids.map((b) => b.toJson()).toList(),
      'startingPrice': startingPrice,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': auctionStatusToString(status),
    };
  }
}