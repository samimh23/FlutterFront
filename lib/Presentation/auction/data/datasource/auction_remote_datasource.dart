import 'dart:convert';
import 'package:hanouty/Presentation/auction/data/models/bid_model.dart';
import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/entity/bid.dart';
import 'package:http/http.dart' as http;
import '../../../../Core/Utils/Api_EndPoints.dart';
import '../models/auction_model.dart';

abstract class AuctionRemoteDataSource {
  Future<AuctionModel> createAuction(AuctionModel auctionModel);
  Future<List<AuctionModel>> getActiveAuctions();
  Future<AuctionModel> getAuctionById(String id);
  Future<AuctionModel> placeBid(String auctionId, BidModel bidModel);
  Future<AuctionModel> updateAuctionStatus(String auctionId, AuctionStatus status);
  Future<List<AuctionModel>> getAuctionsByBidderId(String bidderId);
  Future<List<AuctionModel>> getAuctionsByFarmerId(String farmerId);
  Future<List<BidModel>> getBiddersByAuctionId(String auctionId);
}

class AuctionRemoteDataSourceImpl implements AuctionRemoteDataSource {
  final http.Client client;

  AuctionRemoteDataSourceImpl({required this.client});

  final String baseUrl = '${ApiEndpoints.baseUrl}/auctions';

  @override
  Future<AuctionModel> createAuction(AuctionModel auctionModel) async {
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(auctionModel.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuctionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create auction: ${response.statusCode}');
    }
  }

  @override
  Future<List<AuctionModel>> getActiveAuctions() async {
    final response = await client.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> auctionsJson = json.decode(response.body);
      return auctionsJson.map((json) => AuctionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch active auctions');
    }
  }

  @override
  Future<AuctionModel> getAuctionById(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return AuctionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch auction by ID');
    }
  }

  @override
  Future<AuctionModel> placeBid(String auctionId, BidModel bidModel) async {
    final response = await client.post(
      Uri.parse('$baseUrl/bid/$auctionId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bidModel.toJson()),
    );
    if (response.statusCode == 200) {
      return AuctionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to place bid');
    }
  }

  @override
  Future<AuctionModel> updateAuctionStatus(String auctionId, AuctionStatus status) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/status/$auctionId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode == 200) {
      return AuctionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update auction status');
    }
  }

  @override
  Future<List<AuctionModel>> getAuctionsByBidderId(String bidderId) async {
    final response = await client.get(Uri.parse('$baseUrl/bidder/$bidderId'));
    if (response.statusCode == 200) {
      List<dynamic> auctionsJson = json.decode(response.body);
      return auctionsJson.map((json) => AuctionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch auctions by bidder');
    }
  }

  @override
  Future<List<AuctionModel>> getAuctionsByFarmerId(String farmerId) async {
    final response = await client.get(Uri.parse('$baseUrl/farmer/$farmerId'));
    if (response.statusCode == 200) {
      List<dynamic> auctionsJson = json.decode(response.body);
      return auctionsJson.map((json) => AuctionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch auctions by farmer');
    }
  }

  @override
  Future<List<BidModel>> getBiddersByAuctionId(String auctionId) async {
    final response = await client.get(Uri.parse('$baseUrl/bidders/$auctionId'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded.map((e) => BidModel.fromJson(e)).toList();
      } else {
        throw Exception('Unexpected response format for bidders');
      }
    } else {
      throw Exception('Failed to fetch bidders for auction');
    }
  }
}