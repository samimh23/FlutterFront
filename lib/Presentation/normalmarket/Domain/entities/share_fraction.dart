import 'package:equatable/equatable.dart';

class ShareFractionRequest extends Equatable {
  final String recipientAddress;
  final int percentage;

  const ShareFractionRequest({
    required this.recipientAddress,
    required this.percentage,
  });

  @override
  List<Object?> get props => [recipientAddress, percentage];
}
