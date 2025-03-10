
import 'package:hanouty/Core/heritables/Markets.dart';

class NormalMarket extends Markets {
  final String marketName;
  final String marketLocation;
  final String? marketPhone;
  final String? marketEmail;
  final String? marketImage;
  final String marketWalletPublicKey;
  final String marketWalletSecretKey;
  final int fractions;
  final String? fractionalNFTAddress;

  const NormalMarket({
    required super.id,
    required super.owner,
    required super.products,
    required this.marketName,
    required this.marketLocation,
    this.marketPhone,
    this.marketEmail,
    this.marketImage,
    required this.marketWalletPublicKey,
    required this.marketWalletSecretKey,
    required this.fractions,
    this.fractionalNFTAddress,
  }) : super(marketType: MarketsType.normal);

  @override
  List<Object?> get props => [
        ...super.props,
        marketName,
        marketLocation,
        marketPhone,
        marketEmail,
        marketImage,
        marketWalletPublicKey,
        marketWalletSecretKey,
        fractions,
        fractionalNFTAddress,
      ];

  NormalMarket copyWith({
    String? id,
    String? owner,
    List<String>? products,
    String? marketName,
    String? marketLocation,
    String? marketPhone,
    String? marketEmail,
    String? marketImage,
    String? marketWalletPublicKey,
    String? marketWalletSecretKey,
    int? fractions,
    String? fractionalNFTAddress,
  }) {
    return NormalMarket(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      products: products ?? this.products,
      marketName: marketName ?? this.marketName,
      marketLocation: marketLocation ?? this.marketLocation,
      marketPhone: marketPhone ?? this.marketPhone,
      marketEmail: marketEmail ?? this.marketEmail,
      marketImage: marketImage ?? this.marketImage,
      marketWalletPublicKey:
          marketWalletPublicKey ?? this.marketWalletPublicKey,
      marketWalletSecretKey:
          marketWalletSecretKey ?? this.marketWalletSecretKey,
      fractions: fractions ?? this.fractions,
      fractionalNFTAddress: fractionalNFTAddress ?? this.fractionalNFTAddress,
    );
  }
}
