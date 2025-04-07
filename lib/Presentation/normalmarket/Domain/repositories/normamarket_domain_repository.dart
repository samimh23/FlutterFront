



import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/share_fraction.dart';

abstract class NormalMarketRepository {
  Future<List<Markets>> getNormalMarkets();
  Future<Markets> getNormalMarketById(String id);
  Future<List<Markets>> getMyNormalMarkets();
  Future<Markets> createNormalMarket(Markets market, String imagePath);
  Future<Markets> updateNormalMarket(String id, Markets market, String? imagePath);
  Future<Markets> deleteNormalMarket(String id);
  Future<Markets> createNFTForMarket(String id);
  Future<Map<String, dynamic>> shareFractionalNFT(String id, ShareFractionRequest request);
}