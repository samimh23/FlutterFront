import 'package:hanouty/Core/heritables/Markets.dart';

class NormalMarket extends Markets {
  final String marketName;
  final String marketLocation;
  final String? marketPhone;
  final String? marketEmail;
  final String? marketImage;
  final String marketWalletPublicKey;
  final String marketWalletSecretKey;
  final String? fractionalNFTAddress;
  final int fractions;
  final int? rating;
   // Changed from constant to final

  const NormalMarket({
    required super.id,
    required super.products,
    required this.marketName,
    required this.marketLocation,
    this.marketPhone,
    this.marketEmail,
    this.marketImage,
    this.rating,
    required this.marketWalletPublicKey,
    required this.marketWalletSecretKey,
    this.fractionalNFTAddress,
    this.fractions = 100, // Set default value here
  }) : super(marketType: MarketsType.normal);

  @override
  List<Object?> get props => [
        ...super.props,
        marketName,
        marketLocation,
        marketPhone,
        marketEmail,
        marketImage,
        rating,
        marketWalletPublicKey,
        marketWalletSecretKey,
        fractionalNFTAddress,
        fractions,
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
    String? fractionalNFTAddress,
    int? rating,
    int? fractions, // Added fractions as a parameter
  }) {
    return NormalMarket(
      id: id ?? this.id,
      products: products ?? this.products,
      marketName: marketName ?? this.marketName,
      marketLocation: marketLocation ?? this.marketLocation,
      marketPhone: marketPhone ?? this.marketPhone,
      marketEmail: marketEmail ?? this.marketEmail,
      marketImage: marketImage ?? this.marketImage,
      marketWalletPublicKey:
          marketWalletPublicKey ?? this.marketWalletPublicKey,
      rating: rating ?? this.rating,
      marketWalletSecretKey:
          marketWalletSecretKey ?? this.marketWalletSecretKey,
      fractions:
          fractions ?? this.fractions, // Properly use the fractions parameter
      fractionalNFTAddress: fractionalNFTAddress ?? this.fractionalNFTAddress,
    );
  }
}
