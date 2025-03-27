
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';

class NormalMarketModel extends NormalMarket {
  const NormalMarketModel({
    required super.id,
    required super.owner,
    required super.products,
    required super.marketName,
    required super.marketLocation,
    required super.rating,
    super.deliveryCost,
    super.deliveryTime,
    super.description,
    super.marketPhone,
    super.marketEmail,
    super.marketImage,
    required super.marketWalletPublicKey,
    required super.marketWalletSecretKey,
    required super.fractions,
    super.fractionalNFTAddress,
  });
  factory NormalMarketModel.fromJson(Map<String, dynamic> json) {
    // Print the problematic JSON to help debug the specific field
    print(
        'Processing JSON: ${json['marketName']} (id: ${json['_id'] ?? json['id']})');

    try {
      return NormalMarketModel(
        id: json['_id']?.toString() ??
            json['id']?.toString() ??
            '', // Handle both _id and id formats
        owner: json['owner']?.toString() ??
            '', // Make nullable fields have fallbacks
        products: List<String>.from(json['products'] ?? []),
        rating: json['rating'] ,
        deliveryCost: json['deliveryCost']?.toString(),
        deliveryTime: json['deliveryTime']?.toString(),
        description: json['description']?.toString(),
        marketName: json['marketName']?.toString() ?? '',
        marketLocation: json['marketLocation']?.toString() ?? '',
        marketPhone:
            json['marketPhone']?.toString(), // Optional fields remain nullable
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
      // Add better error handling to identify the problematic field
      print('Error creating NormalMarketModel from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      // Return a fallback model or rethrow based on your error handling strategy
      throw Exception('Failed to parse market: $e');
    }
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'owner': owner,
      'products': products,
      'marketType': 'normal',
      'marketName': marketName,
      'marketLocation': marketLocation,
      'deliveryCost': deliveryCost,
      'deliveryTime': deliveryTime,
      'description': description,
      'marketPhone': marketPhone,
      'rating': rating,
      'marketEmail': marketEmail,
      'marketImage': marketImage,
      'marketWalletPublicKey': marketWalletPublicKey,
      'marketWalletSecretKey': marketWalletSecretKey,
      'fractions': fractions,
      'fractionalNFTAddress': fractionalNFTAddress,
    };
  }

  factory NormalMarketModel.fromEntity(NormalMarket entity, String imagePath) {
    return NormalMarketModel(
      id: entity.id,
      owner: entity.owner,
      products: entity.products,
      marketName: entity.marketName,
      marketLocation: entity.marketLocation,
      rating: entity.rating,
      deliveryCost: entity.deliveryCost,
      deliveryTime: entity.deliveryTime,
      description: entity.description,
      marketPhone: entity.marketPhone,
      marketEmail: entity.marketEmail,
      marketImage: entity.marketImage,
      marketWalletPublicKey: entity.marketWalletPublicKey,
      marketWalletSecretKey: entity.marketWalletSecretKey,
      fractions: entity.fractions,
      fractionalNFTAddress: entity.fractionalNFTAddress,
    );
  }
}
