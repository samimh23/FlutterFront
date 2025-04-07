



import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Data/datasources/market_remote_datasources.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/normalmarket_model.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/share_fractions_model.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/share_fraction.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/repositories/normamarket_domain_repository.dart';

class NormalMarketRepositoryImpl implements NormalMarketRepository {
  final NormalMarketRemoteDataSource remoteDataSource;

  NormalMarketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Markets>> getNormalMarkets() async {
    try {
      final markets = await remoteDataSource.getNormalMarkets();
      return markets;
    } catch (e) {
      throw Exception('Failed to get markets: ${e.toString()}');
    }
  }

  @override
  Future<Markets> getNormalMarketById(String id) async {
    try {
      return await remoteDataSource.getNormalMarketById(id);
    } catch (e) {
      throw Exception('Failed to get market: ${e.toString()}');
    }
  }
  @override
  Future<Markets> createNormalMarket(Markets market, String imagePath) async {
    try {
      print("🔍 Repository: Converting market entity to model");
      print("📦 Market entity type: ${market.runtimeType}");
      print("📦 Market entity data: ${market.toString()}");
      print("📦 Image path: $imagePath");

      // Check if market is the correct type
      if (market is! NormalMarket) {
        print("❌ Invalid market type: ${market.runtimeType}");
        throw Exception('Invalid market type: ${market.runtimeType}');
      }

      // Convert to model and pass image path
      final marketModel = NormalMarketModel.fromEntity(market, imagePath);

      print("✅ Model created successfully: ${marketModel.marketName}");
      print("📦 Model data for API: ${marketModel.toJson()}");

      // Send to data source
      return await remoteDataSource.createNormalMarket(marketModel, imagePath);
    } catch (e, stackTrace) {
      print("❌ Error in createNormalMarket repository method: $e");
      print("📚 Stack trace: $stackTrace");
      throw Exception('Failed to create market: ${e.toString()}');
    }
  }

  @override
  Future<Markets> updateNormalMarket(String id, Markets market, String? imagePath) async {
    try {
      final marketModel = NormalMarketModel.fromEntity(market as NormalMarket, imagePath);
      return await remoteDataSource.updateNormalMarket(id, marketModel, imagePath);
    } catch (e) {
      throw Exception('Failed to update market: ${e.toString()}');
    }
  }


  @override
  Future<Markets> deleteNormalMarket(String id) async {
    try {
      return await remoteDataSource.deleteNormalMarket(id);
    } catch (e) {
      throw Exception('Failed to delete market: ${e.toString()}');
    }
  }

  @override
  Future<Markets> createNFTForMarket(String id) async {
    try {
      return await remoteDataSource.createNFTForMarket(id);
    } catch (e) {
      throw Exception('Failed to create NFT for market: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> shareFractionalNFT(String id, ShareFractionRequest request) async {
    try {
      print('🔄 Repository: Sharing fractional NFT for market $id');
      print('📦 Share request: recipient=${request.recipientAddress}, percentage=${request.percentage}, type=${request.recipientType}');

      // Convert entity to model and pass to data source
      final requestModel = ShareFractionRequestModel.fromEntity(request);
      final result = await remoteDataSource.shareFractionalNFT(id, requestModel);

      print('✅ Share operation completed with result: $result');
      return result;
    } catch (e) {
      print('❌ Repository error sharing fractional NFT: $e');
      throw Exception('Failed to share fractional NFT: ${e.toString()}');
    }
  }
  @override
  Future<List<Markets>> getMyNormalMarkets() async {
    try {
      print("🔍 Repository: Fetching markets for authenticated user");
      final markets = await remoteDataSource.getMyNormalMarkets();
      print("✅ Successfully fetched ${markets.length} markets for current user");
      return markets;
    } catch (e) {
      print("❌ Error fetching user's markets: $e");
      throw Exception('Failed to get user\'s markets: ${e.toString()}');
    }
  }
}