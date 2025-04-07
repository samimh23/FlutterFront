import 'package:equatable/equatable.dart';

enum MarketsType {
  farm,
  normal,
}

class Markets extends Equatable {
  final String id;
  final List<String> products;
  final MarketsType marketType;

  const Markets({
    required this.id,
    required this.products,
    required this.marketType,
  });

  @override
  List<Object?> get props => [id, products, marketType];
}
