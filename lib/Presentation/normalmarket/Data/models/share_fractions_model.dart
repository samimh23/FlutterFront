

import 'package:hanouty/Presentation/normalmarket/Domain/entities/share_fraction.dart';

class ShareFractionRequestModel extends ShareFractionRequest {
  const ShareFractionRequestModel({
    required String recipientAddress,
    required int percentage,
  }) : super(recipientAddress: recipientAddress, percentage: percentage);

  factory ShareFractionRequestModel.fromJson(Map<String, dynamic> json) {
    return ShareFractionRequestModel(
      recipientAddress: json['recipientAddress'] as String,
      percentage: json['percentage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipientAddress': recipientAddress,
      'percentage': percentage,
    };
  }

  factory ShareFractionRequestModel.fromEntity(ShareFractionRequest entity) {
    if (entity is ShareFractionRequestModel) {
      return entity;
    }

    return ShareFractionRequestModel(
      recipientAddress: entity.recipientAddress,
      percentage: entity.percentage,
    );
  }
}
