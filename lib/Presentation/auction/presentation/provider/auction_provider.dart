import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/entity/bid.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/create_auction_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_active_auction_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_auction_by_bidder_id_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_auction_by_farmer_id_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_auction_by_id_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/get_bidders_by_auction_id_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/place_bid_usecase.dart';
import 'package:hanouty/Presentation/auction/domain/usecases/update_auction_status_usecase.dart';

class AuctionProvider extends ChangeNotifier {
  final CreateAuction createAuctionUseCase;
  final GetActiveAuctions getActiveAuctionsUseCase;
  final GetAuctionById getAuctionByIdUseCase;
  final PlaceBid placeBidUseCase;
  final UpdateAuctionStatus updateAuctionStatusUseCase;
  final GetAuctionsByBidderId getAuctionsByBidderIdUseCase;
  final GetBiddersByAuctionId getBiddersByAuctionIdUseCase;
  final GetAuctionsByFarmerId getAuctionsByFarmerIdUseCase;

  AuctionProvider({
    required this.createAuctionUseCase,
    required this.getActiveAuctionsUseCase,
    required this.getAuctionByIdUseCase,
    required this.placeBidUseCase,
    required this.updateAuctionStatusUseCase,
    required this.getAuctionsByBidderIdUseCase,
    required this.getBiddersByAuctionIdUseCase,
    required this.getAuctionsByFarmerIdUseCase,
  });

  List<Auction> _auctions = [];
  List<Auction> _bidderAuctions = [];
  List<Auction> _farmerAuctions = [];
  List<Bid> _bidders = [];
  Auction? _selectedAuction;
  bool _isLoading = false;
  String _errorMessage = '';

  List<Auction> get auctions => _auctions;
  List<Auction> get farmerAuctions => _farmerAuctions;
  List<Auction> get bidderAuctions => _bidderAuctions;
  List<Bid> get bidders => _bidders;
  Auction? get selectedAuction => _selectedAuction;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Create a new auction
  Future<void> createNewAuction(Auction auction) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final createdAuction = await createAuctionUseCase.call(auction);
      _auctions.add(createdAuction);
      _errorMessage = '';
      notifyListeners();
      print('Auction created successfully: ${createdAuction.id}');
    } catch (e) {
      _errorMessage = e.toString();
      print('Error creating auction: $_errorMessage');
      notifyListeners();
    }

    _setLoading(false);
  }

  /// Fetch all active auctions
  Future<List<Auction>> fetchActiveAuctions() async {
    if (_isLoading) return _auctions;
    _setLoading(true);

    try {
      final auctions = await getActiveAuctionsUseCase.call();
      _auctions = auctions;
      _errorMessage = '';
      notifyListeners();
      return _auctions;
    } catch (e, stack) {
      _errorMessage = e.toString();
      print('Error fetching active auctions: $_errorMessage');
      print(stack);
      _auctions = [];
      notifyListeners();
      return _auctions;
    } finally {
      _setLoading(false);
    }
  }

  /// Get an auction by ID
  Future<Auction?> getAuctionById(String id) async {
    if (_isLoading) return null;
    _setLoading(true);

    try {
      final auction = await getAuctionByIdUseCase.call(id);
      _selectedAuction = auction;
      _errorMessage = '';
      notifyListeners();
      return auction;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching auction by ID: $e');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Place a bid on an auction
  Future<void> placeBid(String auctionId, Bid bid) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final updatedAuction = await placeBidUseCase.call(auctionId, bid);
      _updateAuctionInList(updatedAuction);

      if (_selectedAuction != null && _selectedAuction!.id == auctionId) {
        _selectedAuction = updatedAuction;
      }
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('Error placing bid: $_errorMessage');
      notifyListeners();
    }

    _setLoading(false);
  }

  /// Update an auction's status
  Future<void> updateStatus(String auctionId, AuctionStatus status) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final updatedAuction = await updateAuctionStatusUseCase.call(auctionId, status);
      _updateAuctionInList(updatedAuction);

      if (_selectedAuction != null && _selectedAuction!.id == auctionId) {
        _selectedAuction = updatedAuction;
      }
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('Error updating auction status: $_errorMessage');
      notifyListeners();
    }

    _setLoading(false);
  }

  /// Fetch all auctions for a specific bidder
  Future<List<Auction>> fetchAuctionsByBidderId(String bidderId) async {
    if (_isLoading) return _bidderAuctions;
    _setLoading(true);

    try {
      final auctions = await getAuctionsByBidderIdUseCase.call(bidderId);
      _bidderAuctions = auctions;
      _errorMessage = '';
      notifyListeners();
      return _bidderAuctions;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching auctions by bidder: $_errorMessage');
      _bidderAuctions = [];
      notifyListeners();
      return _bidderAuctions;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch all auctions for a specific farmer
  Future<List<Auction>> fetchAuctionsByFarmerId(String farmerId) async {
    if (_isLoading) return _farmerAuctions;
    _setLoading(true);

    try {
      final auctions = await getAuctionsByFarmerIdUseCase.call(farmerId);
      _farmerAuctions = auctions;
      _errorMessage = '';
      notifyListeners();
      return _farmerAuctions;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching auctions by farmer: $_errorMessage');
      _farmerAuctions = [];
      notifyListeners();
      return _farmerAuctions;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch all bidder objects for an auction
  Future<List<Bid>> fetchBiddersByAuctionId(String auctionId) async {
    if (_isLoading) return _bidders;
    _setLoading(true);
    try {
      final bidders = await getBiddersByAuctionIdUseCase.call(auctionId);
      _bidders = bidders;
      _errorMessage = '';
      notifyListeners();
      return _bidders;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching bidders: $_errorMessage');
      _bidders = [];
      notifyListeners();
      return _bidders;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear the current error message.
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Helper method to update an auction in the list
  void _updateAuctionInList(Auction updatedAuction) {
    final index = _auctions.indexWhere((a) => a.id == updatedAuction.id);
    if (index != -1) {
      _auctions[index] = updatedAuction;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = '';
    notifyListeners();
  }
}