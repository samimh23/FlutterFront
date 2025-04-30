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

  FarmCrop? _selectedCrop;
  FarmCrop? get selectedCrop => _selectedCrop;

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

  void selectCrop(String id) {
    fetchCropById(id);
  }

  void clearSelectedCrop() {
    _selectedCrop = null;
    notifyListeners();
  }
}