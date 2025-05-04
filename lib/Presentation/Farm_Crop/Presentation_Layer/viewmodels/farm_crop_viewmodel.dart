import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../Domain_Layer/entities/farm_crop.dart';
import '../../Domain_Layer/usecases/get_all_farm_crops.dart';
import '../../Domain_Layer/usecases/get_farm_crop_by_farm.dart';
import '../../Domain_Layer/usecases/get_farm_crop_by_id.dart';
import '../../Domain_Layer/usecases/add_farm_crop.dart';
import '../../Domain_Layer/usecases/update_farm_crop.dart';
import '../../Domain_Layer/usecases/delete_farm_crop.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class FarmCropViewModel extends ChangeNotifier {
  final GetAllFarmCrops getAllFarmCrops;
  final GetFarmCropById getFarmCropById;
  final AddFarmCrop addFarmCrop;
  final UpdateFarmCrop updateFarmCrop;
  final DeleteFarmCrop deleteFarmCrop;
  final GetFarmCropsByFarmMarketId getFarmCropsByFarmMarketId;



  FarmCropViewModel({
    required this.getAllFarmCrops,
    required this.getFarmCropById,
    required this.addFarmCrop,
    required this.updateFarmCrop,
    required this.deleteFarmCrop,
    required this.getFarmCropsByFarmMarketId,


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

    // Remove the ID before sending to the update use case
    final sanitizedCrop = farmCrop.copyWith(id: null);

    final result = await updateFarmCrop(sanitizedCrop);
    result.fold(
          (failure) => _setError(failure.toString()),
          (_) {
        fetchAllCrops();
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

  Future<void> auditHarvestedTomatoes({
    required FarmCrop crop,
    required void Function(int current, int total)? onProgress, // to update UI during audit
    void Function(String result)? onResult,
    int? quantityToCheck,
  }) async {
    final int total = quantityToCheck ?? crop.quantity ?? 0;
    if (total == 0) return;

    int accepted = 0;
    int rejected = 0;
    List<String> auditResults = [];

    _setLoading(true);

    for (int i = 0; i < total; i++) {
      try {
        final response = await http.get(Uri.parse('http://127.0.0.1:8002/audit'));
        print('API response: ${response.statusCode} ${response.body}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final statusRaw = data['audit_status'];
          final status = (statusRaw is String) ? statusRaw.trim().toLowerCase() : '';
          print('Audit status: $status, type: ${status.runtimeType}');
          auditResults.add(status);
          if (onResult != null) onResult(status); // <-- Call here!
          if (status == 'fresh') {
            accepted++;
          } else if (status == 'rotten') {
            rejected++;
          }
        } else {
          auditResults.add('unknown');
          if (onResult != null) onResult('unknown'); // <-- Call here!
        }
      } catch (e) {
        print('Audit error: $e');
        auditResults.add('unknown');
        if (onResult != null) onResult('unknown'); // <-- Call here!
      }
      if (onProgress != null) onProgress(i + 1, total);
      await Future.delayed(const Duration(milliseconds: 250));
    }

    // Update the crop
    final AuditStatus newStatus = accepted > 0
        ? (rejected == 0 ? AuditStatus.confirmed : AuditStatus.pending)
        : AuditStatus.rejected;
    final String report = "Accepted: $accepted, Rejected: $rejected\n" +
        "Details: " +
        auditResults.map((s) => s == 'fresh' ? '✔️' : s == 'rotten' ? '❌' : '❓').join(' ');

    final updatedCrop = crop.copyWith(
      quantity: accepted,
      auditReport: report,
      auditStatus: FarmCrop.auditStatusToString(newStatus),
    );
    await modifyFarmCrop(updatedCrop);

    _setLoading(false);
  }

  void clearSelectedCrop() {
    _selectedCrop = null;
    notifyListeners();
  }
}