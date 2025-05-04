import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/image_picker.dart';
import 'package:hanouty/Presentation/product/data/models/product_model.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/app_colors.dart';
import 'package:hanouty/injection_container.dart';
import 'package:hanouty/Core/network/apiconastant.dart'; // Import ApiConstants
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;


class AddEditProductPage extends StatefulWidget {
  final Product? product; // Pass product for edit mode, null for add mode
  final String? marketId; // Optional market ID for new products


  const AddEditProductPage({Key? key, this.product, this.marketId}) : super(key: key);


  @override
  _AddEditProductPageState createState() => _AddEditProductPageState();
}


class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _discountValueController = TextEditingController();


  bool _isLoading = false;
  bool _isDiscounted = false;
  bool _uploadingImage = false;
  ProductCategory _selectedCategory = ProductCategory.Vegetables;
  String? _networkImage; // Single network image
  Map<String, dynamic>? _localImage; // Single local image


  // Get instance of ProductProvider from the dependency injection container
  late final ProductProvider _productProvider = sl<ProductProvider>();


  @override
  void initState() {
    super.initState();
    print("AddEditProductPage initialized - ${widget.product == null ? 'Add mode' : 'Edit mode'}");
    print("Market ID: ${widget.marketId}");
    _initializeFormData();
  }


  void _initializeFormData() {
    if (widget.product != null) {
      // Edit mode - pre-fill form with existing product data
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _originalPriceController.text = widget.product!.originalPrice.toString();
      _stockController.text = widget.product!.stock.toString();
      _discountValueController.text = widget.product!.discountValue.toString();
      _isDiscounted = widget.product!.isDiscounted;
      _selectedCategory = widget.product!.category;


      // Get the existing image if available
      if (widget.product!.image != null && widget.product!.image!.isNotEmpty) {
        _networkImage = widget.product!.image;
      }
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }


  Future<void> _pickImage() async {
    try {
      setState(() {
        _uploadingImage = true;
      });


      final imageData = await ImagePickerHelper.pickImage();


      if (imageData != null) {
        final file = imageData['file'] as html.File;
        final fileSizeMB = file.size / (1024 * 1024);


        print('Picked image: ${file.name}, size: ${fileSizeMB.toStringAsFixed(2)} MB');


        // Show error and abort if the image is too large (e.g., 5MB limit)
        if (file.size > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image is too large (${fileSizeMB.toStringAsFixed(2)} MB). Please select a file under 5MB.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
          setState(() {
            _uploadingImage = false;
          });
          return;
        }


        setState(() {
          _localImage = imageData;
          _networkImage = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _uploadingImage = false;
      });
    }
  }


  void _removeImage() {
    setState(() {
      _networkImage = null;
      _localImage = null;
    });
  }


  Future<void> _submitForm() async {
    final now = DateTime.now().toUtc();
    final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";


    print("\n===== SUBMIT FORM STARTED: $formattedDate =====");


    // Check if we have an image (either network or local)
    if (_networkImage == null && _localImage == null) {
      print("No product image provided");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a product image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }


    setState(() {
      _isLoading = true;
    });


    try {
      bool success;


      if (widget.product == null) {
        // Creating a new product - use ONLY fields from CreateProductDto
        final createProductData = {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'originalPrice': _originalPriceController.text.trim(),
          'category': ProductModel.productCategoryToString(_selectedCategory),
          'stock': _stockController.text.trim(),
          'shop': widget.marketId?.trim() ?? '',
        };


        print("Calling addProductWithImageData on provider with fields: ${createProductData.keys.join(', ')}");
        success = await _productProvider.addProductWithImageData(createProductData, _localImage);
      } else {
        // Updating an existing product - can include additional fields
        final updateProductData = {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'originalPrice': _originalPriceController.text.trim(),
          'price': _priceController.text.trim(),
          'category': ProductModel.productCategoryToString(_selectedCategory),
          'stock': _stockController.text.trim(),
          'shop': widget.product!.shop ?? '',
          'isDiscounted': _isDiscounted,
        };


        if (_isDiscounted) {
          updateProductData['DiscountValue'] = _discountValueController.text.trim();
        }


        print("Calling updateProductWithImageData on provider");
        success = await _productProvider.updateProductWithImageData(
            widget.product!.id,
            updateProductData,
            _localImage,
            _networkImage
        );
      }


      if (success) {
        print("Product operation succeeded, closing form");
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Product added successfully!'
                : 'Product updated successfully!'
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print("Product operation failed, showing error from provider");
        final errorMsg = _productProvider.errorMessage.isNotEmpty
            ? _productProvider.errorMessage
            : 'Operation failed. Please try again.';


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("ERROR IN FORM SUBMISSION: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }


    print("===== SUBMIT FORM COMPLETED =====\n");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Product Image Section
              _buildImageSection(),
              const SizedBox(height: 24),


              // Basic Info Section
              _buildSectionHeader('Basic Information'),
              _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),


              // Category Dropdown
              _buildCategoryDropdown(),
              const SizedBox(height: 24),


              // Price & Stock Section
              _buildSectionHeader('Pricing & Inventory'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _originalPriceController,
                      label: 'Original Price (DT)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.money,
                      validator: (value) {
                        if (value!.isEmpty) return 'Price is required';
                        if (double.tryParse(value.trim()) == null) return 'Enter valid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Selling Price (DT)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: (value) {
                        if (value!.isEmpty) return 'Price is required';
                        if (double.tryParse(value.trim()) == null) return 'Enter valid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _stockController,
                label: 'Stock Quantity',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.inventory_2,
                validator: (value) {
                  if (value!.isEmpty) return 'Stock is required';
                  if (int.tryParse(value.trim()) == null) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),


              // Discount Section - only shown in Edit mode since creating doesn't support these fields
              if (widget.product != null) ...[
                _buildSectionHeader('Discount Settings'),
                _buildDiscountSwitch(),
                if (_isDiscounted) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _discountValueController,
                    label: 'Discount Value (DT)',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.discount,
                    validator: (value) {
                      if (_isDiscounted && (value == null || value.isEmpty)) {
                        return 'Discount value is required';
                      }
                      if (value!.isNotEmpty && double.tryParse(value.trim()) == null) {
                        return 'Enter valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ],
              const SizedBox(height: 32),


              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || _uploadingImage || _productProvider.isLoading || _productProvider.isSubmitting)
                      ? null
                      : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: (_isLoading || _productProvider.isLoading || _productProvider.isSubmitting)
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.product == null ? 'Add Product' : 'Update Product',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),


              // Error message display (for debugging)
              if (_productProvider.errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    "Error: ${_productProvider.errorMessage}",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Product Image'),
        const SizedBox(height: 8),


        // Single image display or picker
        Container(
          height: 200, // Taller for a single image
          child: Center(
            child: _networkImage != null
                ? _buildNetworkImageItem(_networkImage!)
                : _localImage != null
                ? _buildLocalImageItem(_localImage!)
                : _uploadingImage
                ? _buildUploadingIndicator()
                : _buildAddImageButton(),
          ),
        ),


        if (_networkImage == null && _localImage == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please add a product image',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
      ],
    );
  }


  // UPDATED: Network image display with ApiConstants
  Widget _buildNetworkImageItem(String imageUrl) {
    // Process the image URL using ApiConstants
    final String fullImageUrl = ApiConstants.getFullImageUrl(imageUrl);
    print('Loading product image from: $fullImageUrl');


    return Stack(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              fullImageUrl,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading product image: $error');
                // Show error dialog on tap
                return GestureDetector(
                  onTap: () {
                    _showImageErrorDialog(context, fullImageUrl, imageUrl, error);
                  },
                  child: Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey[400], size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Image Error',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          'Tap for details',
                          style: TextStyle(color: Colors.grey[500], fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red[500],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }


  // UPDATED: Local image display with file info
  Widget _buildLocalImageItem(Map<String, dynamic> imageData) {
    // For preview, create an object URL
    final objectUrl = html.Url.createObjectUrl(imageData['file'] as html.Blob);
    final fileName = (imageData['file'] as html.File).name;
    final fileSize = ((imageData['file'] as html.File).size / 1024).toStringAsFixed(1) + ' KB';


    return Stack(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    objectUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    ),
                  ),
                ),
                // File info at the bottom
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: Colors.black.withOpacity(0.6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fileName.length > 20 ? fileName.substring(0, 17) + '...' : fileName,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        fileSize,
                        style: const TextStyle(color: Colors.white70, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              _removeImage();
              // Release the object URL to avoid memory leaks
              html.Url.revokeObjectUrl(objectUrl);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red[500],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildUploadingIndicator() {
    return Container(
      width: 200,
      height: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uploading...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 200,
        height: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'Add Image',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Helper method for displaying detailed image errors
  void _showImageErrorDialog(BuildContext context, String processedUrl, String originalUrl, dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Error'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Failed to load product image:'),
              const SizedBox(height: 8),
              Text('Processed URL:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(processedUrl, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Text('Original path:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(originalUrl, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              const Text('Check that:'),
              const Text('• Backend server is running'),
              const Text('• Image file exists on server'),
              const Text('• Image path is correct'),
              const SizedBox(height: 8),
              Text('Error: $error', style: const TextStyle(fontSize: 12, color: Colors.red)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 0,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }


  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<ProductCategory>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      items: ProductCategory.values
          .map((category) => DropdownMenuItem(
        value: category,
        child: Text(ProductModel.productCategoryToString(category)),
      ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }


  Widget _buildDiscountSwitch() {
    return SwitchListTile(
      title: const Text('Apply Discount'),
      subtitle: Text(
        _isDiscounted
            ? 'Discount is active on this product'
            : 'No discount applied',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      value: _isDiscounted,
      onChanged: (value) {
        setState(() {
          _isDiscounted = value;
          if (!value) {
            _discountValueController.clear();
          }
        });
      },
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}
