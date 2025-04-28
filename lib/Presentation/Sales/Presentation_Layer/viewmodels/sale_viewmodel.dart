import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../../Farm_Crop/Domain_Layer/entities/farm_crop.dart';
import '../../../Farm_Crop/Domain_Layer/usecases/get_farm_crop_by_id.dart';
import '../../Domain_Layer/entities/sale.dart';
import '../../Domain_Layer/usecases/getSalesByFarmMarket.dart';
import '../../Domain_Layer/usecases/get_all_sales.dart';
import '../../Domain_Layer/usecases/get_sale_by_id.dart';
import '../../Domain_Layer/usecases/add_sale.dart';
import '../../Domain_Layer/usecases/update_sale.dart';
import '../../Domain_Layer/usecases/delete_sale.dart';
import '../../Domain_Layer/usecases/get_sales_by_crop_id.dart';

class SaleViewModel extends ChangeNotifier {
  final GetAllSales getAllSales;
  final GetSaleById getSaleById;
  final AddSale addSale;
  final UpdateSale updateSale;
  final DeleteSale deleteSale;
  final GetSalesByCropId getSalesByCropId;
  final GetSalesByFarmMarket getSalesByFarmMarket;
  final GetFarmCropById getFarmCropById;

  SaleViewModel({
    required this.getAllSales,
    required this.getSaleById,
    required this.addSale,
    required this.updateSale,
    required this.deleteSale,
    required this.getSalesByCropId,
    required this.getSalesByFarmMarket,
    required this.getFarmCropById,
  }) {
    fetchAllSales();
  }

  List<Sale> _sales = [];
  List<Sale> get sales => _sales;

  Sale? _selectedSale;
  Sale? get selectedSale => _selectedSale;

  Map<String, FarmCrop> _cropCache = {};

  // Used for creating a new sale
  FarmCrop? _selectedCropForSale;
  FarmCrop? get selectedCropForSale => _selectedCropForSale;

  // Current farm market id for filtering sales
  String? _currentFarmMarketId;

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

  // Set the selected crop for creating a new sale
  void setSelectedCropForSale(FarmCrop crop) {
    _selectedCropForSale = crop;
    _cropCache[crop.id!] = crop;
    notifyListeners();
  }

  // Set current farm market ID to filter sales
  void setCurrentFarmMarketId(String farmMarketId) {
    _currentFarmMarketId = farmMarketId;
    fetchSalesByFarmMarket(farmMarketId);
  }

  Future<void> fetchAllSales() async {
    _setLoading(true);
    final result = await getAllSales();

    result.fold(
          (failure) => _setError(failure.toString()),
          (data) {
        if (data == null) {
          _setError("No sales data available");
        } else {
          _sales = data;
          _setError(null);
        }
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  Future<void> fetchSaleById(String id) async {
    _setLoading(true);
    final result = await getSaleById(id);
    result.fold(
          (failure) => _setError(failure.toString()),
          (sale) {
        _selectedSale = sale;
        // Update the sale in the list if it exists
        final index = _sales.indexWhere((s) => s.id == sale.id);
        if (index != -1) {
          _sales[index] = sale;
        } else {
          _sales.add(sale);
        }
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  Future<void> fetchSalesByCropId(String cropId) async {
    _setLoading(true);
    final result = await getSalesByCropId(cropId);
    result.fold(
          (failure) => _setError(failure.toString()),
          (sales) {
        _sales = sales;
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  Future<void> fetchSalesByFarmMarket(String farmMarketId) async {
    _setLoading(true);
    final result = await getSalesByFarmMarket(farmMarketId);
    result.fold(
          (failure) => _setError(failure.toString()),
          (sales) {
        _sales = sales;
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  Future<FarmCrop?> getCropForSale(String cropId) async {
    if (_cropCache.containsKey(cropId)) {
      return _cropCache[cropId];
    }

    final result = await getFarmCropById(cropId);
    return result.fold(
          (failure) {
        _setError(failure.toString());
        return null;
      },
          (crop) {
        _cropCache[cropId] = crop;
        return crop;
      },
    );
  }

  Future<void> createSale(Sale sale) async {
    _setLoading(true);
    final result = await addSale(sale);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) {
        // Refresh the appropriate list based on the current context
        if (_currentFarmMarketId != null) {
          fetchSalesByFarmMarket(_currentFarmMarketId!);
        } else {
          fetchAllSales();
        }
      },
    );
    _setLoading(false);
  }

  // Helper method to create a sale directly from a crop
  Future<void> createSaleFromCrop(FarmCrop crop, String farmMarketId, double quantity,
      double quantityMin, double pricePerUnit, {String? notes}) async {

    if (crop.id == null) {
      _setError("Crop ID is missing");
      return;
    }

    final sale = Sale(
      id: '', // Will be generated by backend
      farmCropId: crop.id!,
      farmMarketId: farmMarketId,
      quantity: quantity,
      quantityMin: quantityMin,
      pricePerUnit: pricePerUnit,
      createdDate: DateTime.now(),
      notes: notes,
    );

    await createSale(sale);
  }

  Future<void> modifySale(Sale sale) async {
    _setLoading(true);
    final result = await updateSale(sale);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) {
        // Refresh the appropriate list based on the current context
        if (_currentFarmMarketId != null) {
          fetchSalesByFarmMarket(_currentFarmMarketId!);
        } else {
          fetchAllSales();
        }

        // Update selected sale if it's the one being modified
        if (_selectedSale != null && _selectedSale!.id == sale.id) {
          _selectedSale = sale;
        }
      },
    );
    _setLoading(false);
  }

  Future<void> removeSale(String id) async {
    _setLoading(true);
    final result = await deleteSale(id);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) {
        // Refresh the appropriate list based on the current context
        if (_currentFarmMarketId != null) {
          fetchSalesByFarmMarket(_currentFarmMarketId!);
        } else {
          fetchAllSales();
        }

        // Clear selected sale if it's the one being deleted
        if (_selectedSale != null && _selectedSale!.id == id) {
          _selectedSale = null;
        }
      },
    );
    _setLoading(false);
  }

  void selectSale(String id) {
    fetchSaleById(id);
  }

  void clearSelectedSale() {
    _selectedSale = null;
    notifyListeners();
  }

  void clearSelectedCropForSale() {
    _selectedCropForSale = null;
    notifyListeners();
  }
}