
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/domain/usecases/get_all_product.dart';


class ProductProvider extends ChangeNotifier {
  final GetAllProductUseCase getAllProductUseCase;

  ProductProvider({required this.getAllProductUseCase});

  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Fetches products and updates state.
  Future<void> fetchProducts() async {
    // Prevent concurrent requests
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = ''; // Clear previous errors
    notifyListeners();

    final Either<Failure, List<Product>> result = await getAllProductUseCase();

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        // Optionally keep old data: comment next line to preserve previous products
        _products = [];
      },
      (products) {
        _products = products;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Maps specific failure types to error messages.
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server Error';
    } else if (failure is ServerException) {
      return 'Network Error: Check your internet connection.';
    } else if (failure is EmptyCachedFailure) {
      return 'Cache Error: Failed to load local data.';
    } else {
      return 'Failed to fetch products. Please try again.';
    }
  }
 



 
  /// Clears the current error message.
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}