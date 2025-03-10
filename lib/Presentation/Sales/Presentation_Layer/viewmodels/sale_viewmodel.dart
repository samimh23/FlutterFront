// In Presentation_Layer/viewmodels/sale_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../../Farm_Crop/Domain_Layer/entities/farm_crop.dart';
import '../../../Farm_Crop/Domain_Layer/usecases/get_farm_crop_by_id.dart';
import '../../Domain_Layer/entities/sale.dart';
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
  final GetFarmCropById getFarmCropById;

  SaleViewModel({
    required this.getAllSales,
    required this.getSaleById,
    required this.addSale,
    required this.updateSale,
    required this.deleteSale,
    required this.getSalesByCropId,
    required this.getFarmCropById,
  });

  List<Sale> _sales = [];
  List<Sale> get sales => _sales;

  Map<String, FarmCrop> _cropCache = {};

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

  Future<void> fetchAllSales() async {
    _setLoading(true);
    final result = await getAllSales();

    result.fold(
          (failure) => _setError(failure.toString()),
          (data) {
        if (data == null) {
          _setError("No sales data available");
          _setLoading(false);
          return;
        }
        _sales = data;
        _setError(null);
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
          (_) => fetchAllSales(),
    );
    _setLoading(false);
  }

  Future<void> modifySale(Sale sale) async {
    _setLoading(true);
    final result = await updateSale(sale);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) => fetchAllSales(),
    );
    _setLoading(false);
  }

  Future<void> removeSale(String id) async {
    _setLoading(true);
    final result = await deleteSale(id);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) => fetchAllSales(),
    );
    _setLoading(false);
  }
}