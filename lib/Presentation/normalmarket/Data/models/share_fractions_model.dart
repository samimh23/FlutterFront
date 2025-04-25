import 'package:hanouty/Presentation/normalmarket/Domain/entities/share_fraction.dart';

class ShareFractionRequestModel extends ShareFractionRequest {
  const ShareFractionRequestModel({
    required String recipientAddress,
    required int percentage,
    String? recipientType, // Add optional recipient type
  }) : super(
    recipientAddress: recipientAddress,
    percentage: percentage,
    recipientType: recipientType,
  );

  factory ShareFractionRequestModel.fromJson(Map<String, dynamic> json) {
    return ShareFractionRequestModel(
      recipientAddress: json['recipientAddress'] as String,
      percentage: json['percentage'] as int,
      recipientType: json['recipientType'] as String?, // Parse recipientType if available
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'recipientAddress': recipientAddress,
      'percentage': percentage,
    };

    // Only include recipientType if it's not null
    if (recipientType != null) {
      data['recipientType'] = recipientType;
    }

    return data;
  }

  factory ShareFractionRequestModel.fromEntity(ShareFractionRequest entity) {
    if (entity is ShareFractionRequestModel) {
      return entity;
    }

    return ShareFractionRequestModel(
      recipientAddress: entity.recipientAddress,
      percentage: entity.percentage,
      recipientType: entity.recipientType,
    );
  }
}