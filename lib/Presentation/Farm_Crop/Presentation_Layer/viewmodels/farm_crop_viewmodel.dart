import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../Domain_Layer/entities/farm_crop.dart';
import '../../Domain_Layer/usecases/get_all_farm_crops.dart';
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

  FarmCropViewModel({
    required this.getAllFarmCrops,
    required this.getFarmCropById,
    required this.addFarmCrop,
    required this.updateFarmCrop,
    required this.deleteFarmCrop,
  }) {
    fetchAllCrops();
  }

  List<FarmCrop> _crops = [];
  List<FarmCrop> get crops => _crops;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Current farm ID (should be set when user selects a farm)
  String _currentFarmId = '';
  String get currentFarmId => _currentFarmId;

  void setCurrentFarm(String farmId) {
    _currentFarmId = farmId;
    notifyListeners();
    // Fetch crops for this farm
    fetchAllCrops();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchAllCrops() async {
    _setLoading(true);
    final result = await getAllFarmCrops();
    result.fold(
          (failure) => _setError(failure.toString()),
          (data) {
        // If currentFarmId is set, filter crops for that farm
        if (_currentFarmId.isNotEmpty) {
          _crops = data.where((crop) => crop.farmId == _currentFarmId).toList();
        } else {
          _crops = data;
        }
        _setError(null);
      },
    );
    _setLoading(false);
  }

  Future<void> createFarmCrop(FarmCrop farmCrop) async {
    _setLoading(true);

    // Ensure farmId is set - if it's not provided in the form, use currentFarmId
    final String useFarmId = farmCrop.farmId.isEmpty
        ? _currentFarmId
        : farmCrop.farmId;

    // Create a new FarmCrop with the correct farmId
    final cropToAdd = farmCrop.copyWith(farmId: useFarmId);

    // Call the use case to add the crop
    final result = await addFarmCrop(cropToAdd);

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
          (_) => fetchAllCrops(),
    );
    _setLoading(false);
  }

  Future<void> removeFarmCrop(String id) async {
    _setLoading(true);
    final result = await deleteFarmCrop(id);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) => fetchAllCrops(),
    );
    _setLoading(false);
  }

  Future<void> fetchCropById(String id) async {
    _setLoading(true);
    final result = await getFarmCropById(id);
    result.fold(
          (failure) => _setError(failure.toString()),
          (crop) {
        // Find the index of the crop in the list
        final index = _crops.indexWhere((c) => c.id == crop.id);
        if (index != -1) {
          // Update the crop in the list
          _crops[index] = crop;
          notifyListeners();
        }
      },
    );
    _setLoading(false);
  }
}