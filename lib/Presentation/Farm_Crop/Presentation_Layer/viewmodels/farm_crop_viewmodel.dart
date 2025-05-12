import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';
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
import '../../Domain_Layer/usecases/UploadCropImage.dart';
import '../../Domain_Layer/usecases/GetCropImageUrl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final UploadCropImage uploadCropImage;
  final GetCropImageUrl getCropImageUrl;

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
    required this.uploadCropImage,
    required this.getCropImageUrl,
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

  // For tracking image upload results
  Map<String, dynamic>? _imageUploadResult;
  Map<String, dynamic>? get imageUploadResult => _imageUploadResult;

  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setUploadingImage(bool value) {
    _isUploadingImage = value;
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

  void _setImageUploadResult(Map<String, dynamic>? result) {
    _imageUploadResult = result;
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
    final result = await addFarmCrop(farmCrop);

    result.fold(
          (failure) {
        _setError(failure.toString());
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
        final index = _crops.indexWhere((c) => c.id == crop.id);
        if (index != -1) {
          _crops[index] = crop;
        } else {
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

  /// Helper to update audit status, report, and quantity from audit results.
  Future<void> updateCropAuditFromResults({
    required FarmCrop crop,
    required List<String> auditResults,
    String? notes,
    DateTime? harvestedDay,
  }) async {
    int accepted = auditResults.where((s) => s == 'fresh').length;
    int rejected = auditResults.where((s) => s == 'rotten').length;
    int unknown = auditResults.where((s) => s == 'unknown').length;

    String newStatus;
    if (accepted > 0 && rejected == 0 && unknown == 0) {
      newStatus = 'confirmed';
    } else if (rejected > 0) {
      newStatus = 'rejected';
    } else {
      newStatus = 'pending';
    }

    String report = 'Accepted: $accepted, Rejected: $rejected, Unknown: $unknown';
    if (notes != null && notes.isNotEmpty) {
      report += '\n$notes';
    }

    final updatedCrop = crop.copyWith(
      auditStatus: newStatus,
      auditReport: report,
      quantity: accepted,
      harvestedDay: harvestedDay ?? crop.harvestedDay,
    );
    await modifyFarmCrop(updatedCrop);
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

  /// Upload an image for a specific crop
  Future<Map<String, dynamic>?> uploadCropImageFile(String cropId, File imageFile) async {
    _setUploadingImage(true);
    _setImageUploadResult(null);
    _setError(null);

    Map<String, dynamic>? uploadResult;

    try {
      final result = await uploadCropImage(cropId, imageFile);

      result.fold(
            (failure) {
          _setError(failure.toString());
          print("Error uploading crop image: ${failure.toString()}");
        },
            (data) {
          _setError(null);
          _setImageUploadResult(data);
          uploadResult = data;

          // Refresh the crop data to get updated image path
          fetchCropById(cropId);
        },
      );
    } catch (e) {
      _setError("Failed to upload image: $e");
      print("Exception during image upload: $e");
    }

    _setUploadingImage(false);
    return uploadResult;
  }

  /// Get the full image URL for a crop image path
  String getCropFullImageUrl(String? imagePath) {
    return getCropImageUrl(imagePath);
  }

  /// Main audit method (used for initial and retry audits)
  Future<List<String>> auditHarvestedTomatoes({
    required FarmCrop crop,
    required void Function(int current, int total)? onProgress,
    void Function(String result)? onResult,
    int? quantityToCheck,
    int maxRetries = 2,
    CancelAuditController? cancelController,
  }) async {
    final int total = quantityToCheck ?? crop.quantity ?? 0;
    if (total == 0) return [];

    List<String> auditResults = [];
    _setLoading(true);

    for (int i = 0; i < total; i++) {
      String status = 'unknown';
      int attempts = 0;
      while (attempts <= maxRetries) {
        if (cancelController?.isCancelled == true) {
          _setLoading(false);
          return auditResults;
        }
        attempts++;
        try {
          final response = await http.get(Uri.parse('http://127.0.0.1:8002/audit'));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final statusRaw = data['audit_status'];
            status = (statusRaw is String) ? statusRaw.trim().toLowerCase() : '';
            if (status == 'fresh' || status == 'rotten') break;
          }
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 200));
      }
      auditResults.add(status);
      if (onResult != null) onResult(status);
      if (onProgress != null) onProgress(i + 1, total);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _setLoading(false);
    return auditResults;
  }

  void clearSelectedCrop() {
    _selectedCrop = null;
    notifyListeners();
  }

  void clearConversionResult() {
    _conversionResult = null;
    notifyListeners();
  }

  void clearImageUploadResult() {
    _imageUploadResult = null;
    notifyListeners();
  }
}

class CancelAuditController {
  bool isCancelled = false;
  void cancel() => isCancelled = true;
}