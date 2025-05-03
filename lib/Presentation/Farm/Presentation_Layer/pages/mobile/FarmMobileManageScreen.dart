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

  File? _selectedImage;
  String? _existingImagePath;
  bool _isUploading = false;

  Future<void> _initializeOwnerId() async {
    final id = await sc.getUserId();
    setState(() {
      owner = id;
    });
  }

  @override
  void initState() {
    super.initState();
    _farmNameController = TextEditingController(text: widget.farm?.farmName ?? '');
    _farmLocationController = TextEditingController(text: widget.farm?.farmLocation ?? '');
    _farmPhoneController = TextEditingController(text: widget.farm?.farmPhone ?? '');
    _farmEmailController = TextEditingController(text: widget.farm?.farmEmail ?? '');
    _farmDescriptionController = TextEditingController(text: widget.farm?.farmDescription ?? '');
    _existingImagePath = widget.farm?.farmImage;
    _initializeOwnerId();

  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _farmLocationController.dispose();
    _farmPhoneController.dispose();
    _farmEmailController.dispose();
    _farmDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _isUploading = false;
      });
    }
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
              'Select Image Source',
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
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
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

      // Set uploading state
      setState(() {
        _isUploading = true;
      });

      // In a real app, you would upload the image to storage and get the URL
      // This is a placeholder for the image upload logic
      String? imageUrl;
      if (_selectedImage != null) {
        // Simulate image upload delay
        await Future.delayed(const Duration(seconds: 1));
        imageUrl = _selectedImage!.path; // In real app, this would be the URL from storage
      } else {
        imageUrl = _existingImagePath;
      }

      final farm = Farm(
        owner: owner,
        farmName: _farmNameController.text,
        farmLocation: _farmLocationController.text.trim(),
        farmPhone: _farmPhoneController.text.trim().isEmpty ? null : _farmPhoneController.text.trim(),
        farmEmail: _farmEmailController.text.trim().isEmpty ? null : _farmEmailController.text.trim(),
        farmDescription: _farmDescriptionController.text.trim().isEmpty ? null : _farmDescriptionController.text.trim(),
        farmImage: imageUrl,

        // Removed: sale and rate fields
      );

      if (widget.isEditing) {
        viewModel.modifyFarmMarket(farm);
      } else {
        viewModel.createFarmMarket(farm);
      }

      setState(() {
        _isUploading = false;
      });

      Navigator.pop(context);
    }
  }

  @override
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

                // Farm Image Section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: _selectedImage != null
                                    ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                )
                                    : _existingImagePath != null
                                    ? Image.network(
                                  _existingImagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                )
                                    : const Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Farm Image',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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