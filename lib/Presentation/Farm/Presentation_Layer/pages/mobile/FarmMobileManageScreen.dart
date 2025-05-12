import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../Domain_Layer/entity/farm.dart';
import '../../viewmodels/farmviewmodel.dart';

class AddEditFarmScreen extends StatefulWidget {
  final bool isEditing;
  final Farm? farm;

  const AddEditFarmScreen({
    Key? key,
    required this.isEditing,
    this.farm,
  }) : super(key: key);

  @override
  State<AddEditFarmScreen> createState() => _AddEditFarmScreenState();
}

class _AddEditFarmScreenState extends State<AddEditFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _farmNameController;
  late TextEditingController _farmLocationController;
  late TextEditingController _farmPhoneController;
  late TextEditingController _farmEmailController;
  late TextEditingController _farmDescriptionController;

  final SecureStorageService sc = SecureStorageService();
  String? owner;

  List<File> _selectedImages = [];
  List<String> _existingImages = [];
  bool _isUploading = false;
  final ScrollController _imageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _farmNameController = TextEditingController(text: widget.farm?.farmName ?? '');
    _farmLocationController = TextEditingController(text: widget.farm?.farmLocation ?? '');
    _farmPhoneController = TextEditingController(text: widget.farm?.farmPhone ?? '');
    _farmEmailController = TextEditingController(text: widget.farm?.farmEmail ?? '');
    _farmDescriptionController = TextEditingController(text: widget.farm?.farmDescription ?? '');
    _initializeOwnerId();
    _loadExistingImages();
  }

  Future<void> _initializeOwnerId() async {
    final id = await sc.getUserId();
    setState(() {
      owner = id;
    });
  }

  Future<void> _loadExistingImages() async {
    if (widget.isEditing && widget.farm?.id != null) {
      final viewModel = Provider.of<FarmMarketViewModel>(context, listen: false);
      await viewModel.fetchFarmImages(widget.farm!.id!);
      setState(() {
        _existingImages = List.from(viewModel.farmImages);
      });
    }
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _farmLocationController.dispose();
    _farmPhoneController.dispose();
    _farmEmailController.dispose();
    _farmDescriptionController.dispose();
    _imageScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImages(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();

    if (pickedImages != null && pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(
          pickedImages.map((image) => File(image.path)).toList(),
        );
      });
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Images',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFarm() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<FarmMarketViewModel>(context, listen: false);

      setState(() {
        _isUploading = true;
      });

      try {
        // Start with existing images (if any)
        List<String> allImageUrls = List.from(_existingImages);

        // Create the farm object (without images initially if this is a new farm)
        final farm = Farm(
          id: widget.isEditing ? widget.farm!.id : null,
          owner: owner,
          farmName: _farmNameController.text,
          farmLocation: _farmLocationController.text.trim(),
          farmPhone: _farmPhoneController.text.trim().isEmpty ? null : _farmPhoneController.text.trim(),
          farmEmail: _farmEmailController.text.trim().isEmpty ? null : _farmEmailController.text.trim(),
          farmDescription: _farmDescriptionController.text.trim().isEmpty ? null : _farmDescriptionController.text.trim(),
          farmImage: allImageUrls.isNotEmpty ? allImageUrls.first : null,
          sales: widget.isEditing ? widget.farm!.sales : [],
          crops: widget.isEditing ? widget.farm!.crops : [],
          rate: widget.isEditing ? widget.farm!.rate : null,
        );

        // For an existing farm, upload images first
        if (widget.isEditing) {
          // Upload images if this is an edit operation
          if (_selectedImages.isNotEmpty && widget.farm?.id != null) {
            for (File image in _selectedImages) {
              try {
                final imageUrl = await viewModel.uploadImage(widget.farm!.id!, image.path);
                if (imageUrl != null) {
                  allImageUrls.add(imageUrl);
                }
              } catch (uploadError) {
                print('Warning: Failed to upload image: $uploadError');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Some images failed to upload but farm details will be saved'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            }

            // Update the farm object with the new images
            farm.farmImage = allImageUrls.isNotEmpty ? allImageUrls.first : farm.farmImage;

            // Save the farm with updated images
            await viewModel.modifyFarmMarket(farm);
          } else {
            // Just update the farm without new images
            await viewModel.modifyFarmMarket(farm);
          }
        } else {
          // For a new farm, first create the farm to get an ID
          await viewModel.createFarmMarket(farm);

          // After creation, fetch the newest farm to get its ID
          if (owner != null) {
            await viewModel.fetchFarmsByOwner(owner!);

            // Get the most recently created farm (should be at the end of the list)
            if (viewModel.farmerFarms.isNotEmpty) {
              final newFarmId = viewModel.farmerFarms.last.id;

              // Now upload images with the new farm ID
              if (_selectedImages.isNotEmpty && newFarmId != null) {
                for (File image in _selectedImages) {
                  try {
                    final imageUrl = await viewModel.uploadImage(newFarmId, image.path);
                    if (imageUrl != null) {
                      allImageUrls.add(imageUrl);
                    }
                  } catch (uploadError) {
                    print('Warning: Failed to upload image: $uploadError');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Some images failed to upload but farm was created'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                }

                // If we uploaded images, update the farm with the first image
                if (allImageUrls.isNotEmpty) {
                  final updatedFarm = Farm(
                    id: newFarmId,
                    owner: owner,
                    farmName: _farmNameController.text,
                    farmLocation: _farmLocationController.text.trim(),
                    farmPhone: _farmPhoneController.text.trim().isEmpty ? null : _farmPhoneController.text.trim(),
                    farmEmail: _farmEmailController.text.trim().isEmpty ? null : _farmEmailController.text.trim(),
                    farmDescription: _farmDescriptionController.text.trim().isEmpty ? null : _farmDescriptionController.text.trim(),
                    farmImage: allImageUrls.first,
                    sales: [],
                    crops: [],
                    rate: null,
                  );

                  await viewModel.modifyFarmMarket(updatedFarm);
                }
              }
            }
          }
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Farm updated successfully' : 'Farm created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving farm: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  Widget _buildImageGallery() {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        controller: _imageScrollController,
        scrollDirection: Axis.horizontal,
        children: [
          // Add Image Button
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  width: 2,
                  style: BorderStyle.none,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Images',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Existing Images
          ..._existingImages.asMap().entries.map((entry) {
            final index = entry.key;
            final imageUrl = entry.value;
            return _buildImageContainer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              onDelete: () => _removeExistingImage(index),
            );
          }),

          // Selected Images
          ..._selectedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;
            return _buildImageContainer(
              child: Image.file(
                image,
                fit: BoxFit.cover,
              ),
              onDelete: () => _removeSelectedImage(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImageContainer({
    required Widget child,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: child,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FarmMarketViewModel>(context);
    final primaryColor = Theme.of(context).primaryColor;
    final isLoading = viewModel.isLoading || _isUploading;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.isEditing ? 'Edit Farm' : 'Add New Farm',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (!isLoading)
            IconButton(
              icon: Icon(Icons.check, color: primaryColor),
              onPressed: _saveFarm,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (viewModel.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Farm Images Gallery
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Farm Images'),
                        const SizedBox(height: 16),
                        _buildImageGallery(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Farm Information Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Farm Information'),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _farmNameController,
                          labelText: 'Farm Name',
                          icon: Icons.business,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a farm name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _farmLocationController,
                          labelText: 'Farm Location',
                          icon: Icons.location_on,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a farm location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _farmPhoneController,
                          labelText: 'Farm Phone (Optional)',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _farmEmailController,
                          labelText: 'Farm Email (Optional)',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _farmDescriptionController,
                          labelText: 'Farm Description (Optional)',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: _saveFarm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.isEditing ? Icons.update : Icons.add),
                      const SizedBox(width: 8),
                      Text(
                        widget.isEditing ? 'Update Farm' : 'Add Farm',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}