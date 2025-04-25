import 'package:equatable/equatable.dart';

class ShareFractionRequest extends Equatable {
  final String recipientAddress;
  final int percentage;
  final String? recipientType; // Add optional recipient type field

  const ShareFractionRequest({
    required this.recipientAddress,
    required this.percentage,
    this.recipientType, // Optional parameter for specifying 'user' or 'market'
  });

  @override
  List<Object?> get props => [recipientAddress, percentage, recipientType];
}