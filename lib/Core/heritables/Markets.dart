import 'package:equatable/equatable.dart';

enum MarketsType {
  farm,
  normal,
}

class Markets extends Equatable {
  final String id;
  final String owner;
  final List<String> products;
  final MarketsType marketType;

  const Markets({
    required this.id,
    required this.owner,
    required this.products,
    required this.marketType,
  });

  @override
  List<Object?> get props => [id, owner, products, marketType];
}
