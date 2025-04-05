
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Core/errors/failuresconection.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/domain/usecases/add_product.dart';
import 'package:hanouty/Presentation/product/domain/usecases/get_all_product.dart';
import 'package:hanouty/Presentation/product/domain/usecases/get_product_by_id.dart';


class ProductProvider extends ChangeNotifier {
  final GetAllProductUseCase getAllProductUseCase;
  final GetProductById getProductById;
  final AddProductUseCase addProductUseCase;
  ProductProvider({required this.getAllProductUseCase ,required this.getProductById, required this.addProductUseCase});

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

  Future<Product?> fetchProductById(String id) async {
    _isLoading = true;
    _errorMessage = ''; // Clear previous errors
    notifyListeners();

    final Either<Failure, Product> result = await getProductById(id);

    Product? product;
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        product = null;
      },
      (fetchedProduct) {
        product = fetchedProduct;
      },
    );

    _isLoading = false;
    notifyListeners();
    return product;
  }
  Future<bool> addProduct(Product product) async {
  _isLoading = true;
  _errorMessage = ''; // Clear previous errors
  notifyListeners();

  final Either<Failure, Unit> result = await addProductUseCase(product);

  bool success = false;
  result.fold(
    (failure) {
      _errorMessage = _mapFailureToMessage(failure);
      success = false;
    },
    (_) {
      // Unit doesn't contain a value, just indicates success
      success = true;
    },
  );

  _isLoading = false;
  notifyListeners();
  return success;
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