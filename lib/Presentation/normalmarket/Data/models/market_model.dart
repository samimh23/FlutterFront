


import 'package:hanouty/Core/heritables/Markets.dart';

class MarketsModel extends Markets {
  const MarketsModel({
    required super.id,
    required super.owner,
    required super.products,
    required super.marketType,
  });

  factory MarketsModel.fromJson(Map<String, dynamic> json) {
    return MarketsModel(
      id: json['_id'],
      owner: json['owner'],
      products: List<String>.from(json['products'] ?? []),
      marketType: _parseMarketType(json['marketType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'owner': owner,
      'products': products,
      'marketType': marketType.name,
    };
  }

  static MarketsType _parseMarketType(String type) {
    return type == 'normal' ? MarketsType.normal : MarketsType.farm;
  }
}