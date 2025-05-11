



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
  Future<NormalMarket> getNormalMarketById(String id) async {
    try {
      return await remoteDataSource.getNormalMarketById(id);
    } catch (e) {
      throw Exception('Failed to get market: ${e.toString()}');
    }
  }
  @override
  Future<Markets> createNormalMarket(Markets market, String imagePath) async {
    try {
      //("🔍 Repository: Converting market entity to model");
      //("📦 Market entity type: ${market.runtimeType}");
      //("📦 Market entity data: ${market.toString()}");
      //("📦 Image path: $imagePath");

      // Check if market is the correct type
      if (market is! NormalMarket) {
        //("❌ Invalid market type: ${market.runtimeType}");
        throw Exception('Invalid market type: ${market.runtimeType}');
      }

      // Convert to model and pass image path
      final marketModel = NormalMarketModel.fromEntity(market, imagePath);

      //("✅ Model created successfully: ${marketModel.marketName}");
      //("📦 Model data for API: ${marketModel.toJson()}");

      // Send to data source
      return await remoteDataSource.createNormalMarket(marketModel, imagePath);
    } catch (e, stackTrace) {
      //("❌ Error in createNormalMarket repository method: $e");
      //("📚 Stack trace: $stackTrace");
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
      //('🔄 Repository: Sharing fractional NFT for market $id');
      //('📦 Share request: recipient=${request.recipientAddress}, percentage=${request.percentage}, type=${request.recipientType}');

      // Convert entity to model and pass to data source
      final requestModel = ShareFractionRequestModel.fromEntity(request);
      final result = await remoteDataSource.shareFractionalNFT(id, requestModel);

      //('✅ Share operation completed with result: $result');
      return result;
    } catch (e) {
      //('❌ Repository error sharing fractional NFT: $e');
      throw Exception('Failed to share fractional NFT: ${e.toString()}');
    }
  }
  @override
  Future<List<Markets>> getMyNormalMarkets() async {
    try {
      //("🔍 Repository: Fetching markets for authenticated user");
      final markets = await remoteDataSource.getMyNormalMarkets();
      //("✅ Successfully fetched ${markets.length} markets for current user");
      return markets;
    } catch (e) {
      //("❌ Error fetching user's markets: $e");
      throw Exception('Failed to get user\'s markets: ${e.toString()}');
    }
  }
}