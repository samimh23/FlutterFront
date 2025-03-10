



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
      final marketModel = NormalMarketModel.fromEntity(market as NormalMarket, imagePath);
      return await remoteDataSource.createNormalMarket(marketModel, imagePath);
    } catch (e) {
      throw Exception('Failed to create market: ${e.toString()}');
    }
  }

  @override
  Future<Markets> updateNormalMarket(String id, Markets market, String? imagePath) async {
    try {
      final marketModel = NormalMarketModel.fromEntity(market as NormalMarket, imagePath!);
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
      final requestModel = ShareFractionRequestModel.fromEntity(request);
      return await remoteDataSource.shareFractionalNFT(id, requestModel);
    } catch (e) {
      throw Exception('Failed to share fractional NFT: ${e.toString()}');
    }
  }
}