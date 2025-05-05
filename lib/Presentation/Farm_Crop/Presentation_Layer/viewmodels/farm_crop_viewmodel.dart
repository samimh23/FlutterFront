import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../Domain_Layer/entities/farm_crop.dart';
import '../../Domain_Layer/usecases/TransformCropProd/ConfirmAndConvertFarmCrop.dart';
import '../../Domain_Layer/usecases/TransformCropProd/ConvertFarmCropToProduct.dart';
import '../../Domain_Layer/usecases/TransformCropProd/ProcessAllConfirmedFarmCrops.dart';
import '../../Domain_Layer/usecases/get_all_farm_crops.dart';
import '../../Domain_Layer/usecases/get_farm_crop_by_farm.dart';
import '../../Domain_Layer/usecases/get_farm_crop_by_id.dart';
import '../../Domain_Layer/usecases/add_farm_crop.dart';
import '../../Domain_Layer/usecases/update_farm_crop.dart';
import '../../Domain_Layer/usecases/delete_farm_crop.dart';


class FarmCropViewModel extends ChangeNotifier {
  final GetAllFarmCrops getAllFarmCrops;
  final GetFarmCropById getFarmCropById;
  final AddFarmCrop addFarmCrop;
  final UpdateFarmCrop updateFarmCrop;
  final DeleteFarmCrop deleteFarmCrop;
  final GetFarmCropsByFarmMarketId getFarmCropsByFarmMarketId;
  final ConfirmAndConvertFarmCrop confirmAndConvertFarmCrop;
  final ConvertFarmCropToProduct convertFarmCropToProduct;
  final ProcessAllConfirmedFarmCrops processAllConfirmedFarmCrops;

  FarmCropViewModel({
    required this.getAllFarmCrops,
    required this.getFarmCropById,
    required this.addFarmCrop,
    required this.updateFarmCrop,
    required this.deleteFarmCrop,
    required this.getFarmCropsByFarmMarketId,
    required this.confirmAndConvertFarmCrop,
    required this.convertFarmCropToProduct,
    required this.processAllConfirmedFarmCrops,
  }) {
    fetchAllCrops();
  }

  List<FarmCrop> _crops = [];
  List<FarmCrop> get crops => _crops;

  FarmCrop? _selectedCrop;
  FarmCrop? get selectedCrop => _selectedCrop;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // For tracking conversion results
  Map<String, dynamic>? _conversionResult;
  Map<String, dynamic>? get conversionResult => _conversionResult;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setConversionResult(Map<String, dynamic>? result) {
    _conversionResult = result;
    notifyListeners();
  }

  Future<void> fetchAllCrops() async {
    _setLoading(true);
    final result = await getAllFarmCrops();
    result.fold(
          (failure) => _setError(failure.toString()),
          (data) {
        _crops = data;
        _setError(null);
      },
    );
    _setLoading(false);
  }

  Future<void> fetchCropsByFarmMarketId(String farmMarketId) async {
    _setLoading(true);
    final result = await getFarmCropsByFarmMarketId(farmMarketId);
    result.fold(
          (failure) => _setError(failure.toString()),
          (data) {
        _crops = data;
        _setError(null);
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  Future<void> createFarmCrop(FarmCrop farmCrop) async {
    _setLoading(true);

    // Call the use case to add the crop
    final result = await addFarmCrop(farmCrop);

    result.fold(
          (failure) {
        _setError(failure.toString());
        print("Error adding crop: ${failure.runtimeType}, Message: $failure");
      },
          (_) {
        _setError(null);
        fetchAllCrops();
      },
    );

    _setLoading(false);
  }

  Future<void> modifyFarmCrop(FarmCrop farmCrop) async {
    _setLoading(true);
    final result = await updateFarmCrop(farmCrop);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) {
        fetchAllCrops();
        // Update selected crop if it's the one being modified
        if (_selectedCrop != null && _selectedCrop!.id == farmCrop.id) {
          _selectedCrop = farmCrop;
          notifyListeners();
        }
      },
    );
    _setLoading(false);
  }

  Future<void> removeFarmCrop(String id) async {
    _setLoading(true);
    final result = await deleteFarmCrop(id);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) {
        fetchAllCrops();
        // Clear selected crop if it's the one being deleted
        if (_selectedCrop != null && _selectedCrop!.id == id) {
          _selectedCrop = null;
          notifyListeners();
        }
      },
    );
    _setLoading(false);
  }

  Future<void> fetchCropById(String id) async {
    _setLoading(true);
    final result = await getFarmCropById(id);
    result.fold(
          (failure) => _setError(failure.toString()),
          (crop) {
        _selectedCrop = crop;
        // Find the index of the crop in the list
        final index = _crops.indexWhere((c) => c.id == crop.id);
        if (index != -1) {
          // Update the crop in the list
          _crops[index] = crop;
        } else {
          // Add to list if not found
          _crops.add(crop);
        }
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  // New methods for farm crop conversion

  Future<Map<String, dynamic>?> convertCropToProduct(String cropId) async {
    _setLoading(true);
    _setConversionResult(null);

    final result = await convertFarmCropToProduct(cropId);

    Map<String, dynamic>? conversionData;

    result.fold(
          (failure) {
        _setError(failure.toString());
        print("Error converting crop to product: ${failure.toString()}");
      },
          (data) async {
        _setError(null);
        _setConversionResult(data);
        conversionData = data;

        // Delete the crop after successful conversion
        await removeFarmCrop(cropId);
      },
    );

    _setLoading(false);
    return conversionData;
  }

  Future<Map<String, dynamic>?> confirmAndConvertCrop(String cropId, String auditReport) async {
    _setLoading(true);
    _setConversionResult(null);

    final result = await confirmAndConvertFarmCrop(cropId, auditReport);

    Map<String, dynamic>? conversionData;

    result.fold(
          (failure) {
        _setError(failure.toString());
        print("Error confirming and converting crop: ${failure.toString()}");
      },
          (data) async {
        _setError(null);
        _setConversionResult(data);
        conversionData = data;

        // Delete the crop after successful confirmation and conversion
        await removeFarmCrop(cropId);
      },
    );

    _setLoading(false);
    return conversionData;
  }

  Future<Map<String, dynamic>?> processAllConfirmedCrops() async {
    _setLoading(true);
    _setConversionResult(null);

    final result = await processAllConfirmedFarmCrops();

    Map<String, dynamic>? processData;

    result.fold(
          (failure) {
        _setError(failure.toString());
        print("Error processing confirmed crops: ${failure.toString()}");
      },
          (data) {
        _setError(null);
        _setConversionResult(data);
        processData = data;

        // Note: The ProcessAllConfirmedFarmCrops use case should handle deleting
        // all processed crops internally, or return their IDs so we can delete them here
        // For now, we'll just refresh the crop list, assuming they're deleted on the backend
        fetchAllCrops();
      },
    );

    _setLoading(false);
    return processData;
  }

  void selectCrop(String id) {
    fetchCropById(id);
  }

  void clearSelectedCrop() {
    _selectedCrop = null;
    notifyListeners();
  }

  void clearConversionResult() {
    _conversionResult = null;
    notifyListeners();
  }
}