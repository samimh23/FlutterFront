import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../../Sales/Domain_Layer/entities/sale.dart';
import '../../Domain_Layer/entity/farm.dart';
import '../../Domain_Layer/usescases/GetSalesByFarmMarketId.dart';
import '../../Domain_Layer/usescases/addfarm.dart';
import '../../Domain_Layer/usescases/delete_farm_market.dart';
import '../../Domain_Layer/usescases/get_all_farm_markets.dart';
import '../../Domain_Layer/usescases/get_farm_market_by_id.dart';
import '../../Domain_Layer/usescases/update_farm_market.dart';

class FarmMarketViewModel extends ChangeNotifier {
  final GetAllFarmMarkets getAllFarmMarkets;
  final GetFarmMarketById getFarmMarketById;
  final AddFarmMarket addFarmMarket;
  final UpdateFarmMarket updateFarmMarket;
  final DeleteFarmMarket deleteFarmMarket;
  final GetSalesByFarmMarketId getSalesByFarmMarketId;

  FarmMarketViewModel({
    required this.getAllFarmMarkets,
    required this.getFarmMarketById,
    required this.addFarmMarket,
    required this.updateFarmMarket,
    required this.deleteFarmMarket,
    required this.getSalesByFarmMarketId,
  }) {
    fetchAllFarmMarkets();
  }

  List<Farm> _farmMarkets = [];
  List<Farm> get farmMarkets => _farmMarkets;

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
    print("Farm Market Data: ${farmMarket.toString()}");  // Add this line to log farmMarket data
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
        // Also update selected farm market if it's the one being modified
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

  void selectFarmMarket(String id) {
    fetchFarmMarketById(id);
  }

  void clearSelectedFarmMarket() {
    _selectedFarmMarket = null;
    _farmSales = [];
    notifyListeners();
  }
}