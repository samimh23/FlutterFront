import '../../Domain/entities/normalmarket_entity.dart';

class NormalMarketModel extends NormalMarket {
  const NormalMarketModel({
    super.id = '',  // Default to empty string for new markets
    required super.marketName,
    required super.marketLocation,
    super.marketPhone,
    super.marketEmail,
    super.marketImage,
    super.products = const [],  // Default to empty list
    super.marketWalletPublicKey = '',  // Default to empty for new markets
    super.marketWalletSecretKey = '',  // Default to empty for new markets
    super.fractions = 100,  // Default to 100
    super.fractionalNFTAddress,
  });

  factory NormalMarketModel.fromJson(Map<String, dynamic> json) {
    //('Processing JSON: ${json['marketName']} (id: ${json['_id'] ?? json['id']})');

    try {
      return NormalMarketModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        products: List<String>.from(json['products'] ?? []),
        marketName: json['marketName']?.toString() ?? '',
        marketLocation: json['marketLocation']?.toString() ?? '',
        marketPhone: json['marketPhone']?.toString(),
        marketEmail: json['marketEmail']?.toString(),
        marketImage: json['marketImage']?.toString(),
        marketWalletPublicKey: json['marketWalletPublicKey']?.toString() ?? '',
        marketWalletSecretKey: json['marketWalletSecretKey']?.toString() ?? '',
        fractions: json['fractions'] is int
            ? json['fractions']
            : (json['fractions'] != null
            ? int.tryParse(json['fractions'].toString()) ?? 100
            : 100),
        fractionalNFTAddress: json['fractionalNFTAddress']?.toString(),
      );
    } catch (e, stackTrace) {
      //('Error creating NormalMarketModel from JSON: $e');
      //('JSON data: $json');
      //('Stack trace: $stackTrace');
      throw Exception('Failed to parse market: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'products': products,
      'marketType': 'normal',
      'marketName': marketName,
      'marketLocation': marketLocation,
      if (marketPhone != null) 'marketPhone': marketPhone,
      if (marketEmail != null) 'marketEmail': marketEmail,
      if (marketImage != null) 'marketImage': marketImage,
      if (marketWalletPublicKey.isNotEmpty) 'marketWalletPublicKey': marketWalletPublicKey,
      if (marketWalletSecretKey.isNotEmpty) 'marketWalletSecretKey': marketWalletSecretKey,
      'fractions': fractions,
      if (fractionalNFTAddress != null) 'fractionalNFTAddress': fractionalNFTAddress,
    };
  }

  factory NormalMarketModel.fromEntity(NormalMarket entity, String? imagePath) {
    // Add debug logs
    //("🔍 Creating model from entity:");
    //("📦 Entity ID: ${entity.id}");
    //("📦 Entity Name: ${entity.marketName}");
    //("📦 Entity Location: ${entity.marketLocation}");
    //("📦 Image Path: $imagePath");

    return NormalMarketModel(
      id: entity.id,
      products: entity.products,
      marketName: entity.marketName,
      marketLocation: entity.marketLocation,
      marketPhone: entity.marketPhone,
      marketEmail: entity.marketEmail,
      marketImage: imagePath ?? entity.marketImage, // Use the provided imagePath
      marketWalletPublicKey: entity.marketWalletPublicKey,
      marketWalletSecretKey: entity.marketWalletSecretKey,
      fractions: entity.fractions,
      fractionalNFTAddress: entity.fractionalNFTAddress,
    );
  }
}