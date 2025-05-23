import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../../Sales/Domain_Layer/entities/sale.dart';
import '../../Domain_Layer/entity/farm.dart';
import '../../Domain_Layer/usescases/GetSalesByFarmMarketId.dart';
import '../../Domain_Layer/usescases/addfarm.dart';
import '../../Domain_Layer/usescases/delete_farm_market.dart';
import '../../Domain_Layer/usescases/get_all_farm_markets.dart';
import '../../Domain_Layer/usescases/get_farm_by_owner.dart';
import '../../Domain_Layer/usescases/get_farm_market_by_id.dart';
import '../../Domain_Layer/usescases/get_farm_products.dart';
import '../../Domain_Layer/usescases/update_farm_market.dart';

class FarmMarketViewModel extends ChangeNotifier {
  final GetAllFarmMarkets getAllFarmMarkets;
  final GetFarmMarketById getFarmMarketById;
  final AddFarmMarket addFarmMarket;
  final UpdateFarmMarket updateFarmMarket;
  final DeleteFarmMarket deleteFarmMarket;
  final GetSalesByFarmMarketId getSalesByFarmMarketId;
  final GetFarmsByOwner getFarmsByOwner;
  final GetFarmProducts getFarmProducts;

  FarmMarketViewModel({
    required this.getAllFarmMarkets,
    required this.getFarmMarketById,
    required this.addFarmMarket,
    required this.updateFarmMarket,
    required this.deleteFarmMarket,
    required this.getSalesByFarmMarketId,
    required this.getFarmsByOwner,
    required this.getFarmProducts,


  }) {
    fetchAllFarmMarkets();
  }


  List<dynamic> _farmProducts = [];
  List<dynamic> get farmProducts => _farmProducts;

  List<Farm> _farmMarkets = [];
  List<Farm> get farmMarkets => _farmMarkets;

  List<Farm> _farmerFarms = [];
  List<Farm> get farmerFarms => _farmerFarms;

  Farm? _selectedFarmMarket;
  Farm? get selectedFarmMarket => _selectedFarmMarket;

  // Sales related to the selected farm market
  List<Sale> _farmSales = [];
  List<Sale> get farmSales => _farmSales;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchAllFarmMarkets() async {
    _setLoading(true);
    final result = await getAllFarmMarkets();
    result.fold(
          (failure) => _setError(failure.toString()),
          (data) {
        _farmMarkets = data;
        _setError(null);
      },
    );
    _setLoading(false);
  }

  Future<void> fetchFarmMarketById(String id) async {
    _setLoading(true);
    final result = await getFarmMarketById(id);
    result.fold(
          (failure) => _setError(failure.toString()),
          (farmMarket) {
        _selectedFarmMarket = farmMarket;
        // Update the farm market in the list if it exists
        final index = _farmMarkets.indexWhere((fm) => fm.id == farmMarket.id);
        if (index != -1) {
          _farmMarkets[index] = farmMarket;
        } else {
          // Add to list if not found
          _farmMarkets.add(farmMarket);
        }
        _setError(null);

        // Fetch sales for this farm market
        fetchSalesForSelectedFarm();
      },
    );
    _setLoading(false);
  }

  Future<void> fetchFarmsByOwner(String owner) async {
    _setLoading(true);
    final result = await getFarmsByOwner(owner);
    result.fold(
          (failure) => _setError(failure.toString()),
          (farms) {
        _farmerFarms = farms;
        _setError(null);
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  Future<void> fetchSalesForSelectedFarm() async {
    if (_selectedFarmMarket == null || _selectedFarmMarket!.id == null) {
      _farmSales = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    final result = await getSalesByFarmMarketId(_selectedFarmMarket!.id!);
    result.fold(
          (failure) => _setError(failure.toString()),
          (sales) {
        _farmSales = sales;
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  Future<void> createFarmMarket(Farm farmMarket) async {
    _setLoading(true);
    final result = await addFarmMarket(farmMarket);
    result.fold(
          (failure) {
        _setError(failure.toString());
        print("Error adding farm market: ${failure.runtimeType}, Message: $failure");
      },
          (_) {
        _setError(null);
        fetchAllFarmMarkets();
      },
    );
    _setLoading(false);
  }

  Future<void> modifyFarmMarket(Farm farmMarket) async {
    _setLoading(true);
    final result = await updateFarmMarket(farmMarket);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) {
        fetchAllFarmMarkets();
        if (_selectedFarmMarket != null && _selectedFarmMarket!.id == farmMarket.id) {
          _selectedFarmMarket = farmMarket;
          // Refresh sales after farm update
          fetchSalesForSelectedFarm();
        }
      },
    );
    _setLoading(false);
  }

  Future<void> removeFarmMarket(String id) async {
    _setLoading(true);
    final result = await deleteFarmMarket(id);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) {
        fetchAllFarmMarkets();
        // Clear selected farm market if it's the one being deleted
        if (_selectedFarmMarket != null && _selectedFarmMarket!.id == id) {
          _selectedFarmMarket = null;
          _farmSales = []; // Clear sales as well
          notifyListeners();
        }
      },
    );
    _setLoading(false);
  }

  Future<void> fetchFarmProducts(String farmId) async {
    _setLoading(true);
    final result = await getFarmProducts(farmId);
    result.fold(
          (failure) => _setError(failure.toString()),
          (products) {
        _farmProducts = products;
        _setError(null);
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  void selectFarmMarket(String id) {
    fetchFarmMarketById(id);
    fetchFarmProducts(id);
  }

  void clearSelectedFarmMarket() {
    _selectedFarmMarket = null;
    _farmSales = [];
    _farmProducts = [];
    notifyListeners();
  }
}