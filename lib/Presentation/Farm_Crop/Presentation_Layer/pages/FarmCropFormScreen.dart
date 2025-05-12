import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../Core/Utils/secure_storage.dart';
import '../../../Farm/Domain_Layer/entity/farm.dart';
import '../../../Farm/Presentation_Layer/viewmodels/farmviewmodel.dart';
import '../../Domain_Layer/entities/farm_crop.dart';
import '../../Presentation_Layer/viewmodels/farm_crop_viewmodel.dart';

class FarmCropFormScreen extends StatefulWidget {
  final bool isEditing;
  final FarmCrop? cropToEdit;

  const FarmCropFormScreen({
    Key? key,
    this.isEditing = false,
    this.cropToEdit,
  }) : super(key: key);

  @override
  State<FarmCropFormScreen> createState() => _FarmCropFormScreenState();
}

class _FarmCropFormScreenState extends State<FarmCropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;

  final SecureStorageService sc = SecureStorageService();
  String? owner;
  bool isLoading = true;

  String? _selectedFarmMarketId;
  String _selectedType = 'Beefsteak tomatoes';
  DateTime _implantDate = DateTime.now();
  DateTime? _harvestedDate;
  AuditStatus _auditStatus = AuditStatus.pending;
  bool _isSubmitting = false;
  File? _imageFile;
  String? _existingImageUrl;
  bool _isUploadingImage = false;

  final List<String> _tomatoTypes = [
    'Beefsteak tomatoes',
    'Cherry tomatoes',
    'Grape tomatoes',
    'Roma tomatoes',
    'Heirloom tomatoes',
    'Plum tomatoes',
    'Currant tomatoes',
    'San Marzano tomatoes',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeOwnerId();

    // Initialize controllers with existing data or empty strings
    _nameController = TextEditingController(
        text: widget.isEditing ? widget.cropToEdit!.productName : '');
    _quantityController = TextEditingController(
        text: widget.isEditing && widget.cropToEdit?.quantity != null
            ? widget.cropToEdit!.quantity.toString()
            : '');

    // Initialize other fields if editing
    if (widget.isEditing && widget.cropToEdit != null) {
      _selectedFarmMarketId = widget.cropToEdit!.farmMarketId;
      _selectedType = widget.cropToEdit!.type;
      _implantDate = widget.cropToEdit!.implantDate;
      _harvestedDate = widget.cropToEdit!.harvestedDay;
      _auditStatus = FarmCrop.stringToAuditStatus(widget.cropToEdit!.auditStatus) ?? AuditStatus.pending;

      // Initialize image URL if available
      if (widget.cropToEdit!.picture != null && widget.cropToEdit!.picture!.isNotEmpty) {
        final cropViewModel = Provider.of<FarmCropViewModel>(context, listen: false);
        _existingImageUrl = cropViewModel.getCropFullImageUrl(widget.cropToEdit!.picture);
      }
    }

    if (!widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final farmMarketViewModel = Provider.of<FarmMarketViewModel>(context, listen: false);
        farmMarketViewModel.fetchFarmsByOwner(owner!);
      });
    }
  }

  Future<void> _fetchUserFarms() async {
    if (owner != null) {
      final viewModel = Provider.of<FarmMarketViewModel>(context, listen: false);
      await viewModel.fetchFarmsByOwner(owner!);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _initializeOwnerId() async {
    final id = await sc.getUserId();
    setState(() {
      owner = id;
    });
    if (owner != null) {
      _fetchUserFarms();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectImplantDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _implantDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _implantDate) {
      setState(() {
        _implantDate = picked;

        // Reset harvested date if it's before the implant date
        if (_harvestedDate != null && _harvestedDate!.isBefore(_implantDate)) {
          _harvestedDate = null;
        }
      });
    }
  }

  Future<void> _selectHarvestedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _harvestedDate ?? _implantDate,
      firstDate: _implantDate,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _harvestedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _existingImageUrl = null; // Clear existing URL if a new image is selected
      });

      // If we're editing an existing crop, upload the image immediately
      if (widget.isEditing && widget.cropToEdit?.id != null) {
        _uploadImage(widget.cropToEdit!.id!);
      }
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _existingImageUrl = null; // Clear existing URL if a new image is selected
      });

      // If we're editing an existing crop, upload the image immediately
      if (widget.isEditing && widget.cropToEdit?.id != null) {
        _uploadImage(widget.cropToEdit!.id!);
      }
    }
  }

  Future<void> _uploadImage(String cropId) async {
    if (_imageFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    final viewModel = Provider.of<FarmCropViewModel>(context, listen: false);
    try {
      final result = await viewModel.uploadCropImageFile(cropId, _imageFile!);

      if (result != null && result.containsKey('imageUrl')) {
        setState(() {
          _existingImageUrl = result['imageUrl'] as String?;
          _imageFile = null; // Clear the file reference as it's now uploaded
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      } else {
        _showErrorSnackBar('Failed to upload image: ${viewModel.errorMessage}');
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading image: $e');
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validate that a farm market is selected
      if (_selectedFarmMarketId == null || _selectedFarmMarketId!.isEmpty) {
        _showErrorSnackBar('Please select a farm market');
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      // Handle the crop creation/update
      _handleCropSubmission();
    }
  }

  Future<void> _handleCropSubmission() async {
    final viewModel = Provider.of<FarmCropViewModel>(context, listen: false);

    try {
      // First, create or update the crop
      FarmCrop crop = FarmCrop(
        id: widget.isEditing ? widget.cropToEdit!.id : null,
        farmMarketId: _selectedFarmMarketId!,
        productName: _nameController.text,
        type: _selectedType,
        implantDate: _implantDate,
        harvestedDay: _harvestedDate,
        picture: widget.isEditing && _imageFile == null ? widget.cropToEdit!.picture : null,
        quantity: _quantityController.text.isNotEmpty
            ? int.tryParse(_quantityController.text)
            : null,
        auditStatus: FarmCrop.auditStatusToString(_auditStatus),
        expenses: widget.isEditing
            ? widget.cropToEdit!.expenses
            : [],
      );

      if (widget.isEditing) {
        await viewModel.modifyFarmCrop(crop);
      } else {
        await viewModel.createFarmCrop(crop);

        // For new crops, we need to get the ID after creation to upload the image
        if (_imageFile != null) {
          // Get the latest crops to find the new one
          await viewModel.fetchAllCrops();
          final newCrop = viewModel.crops.firstWhere(
                (c) => c.productName == crop.productName && c.farmMarketId == crop.farmMarketId,
            orElse: () => crop,
          );

          if (newCrop.id != null) {
            await _uploadImage(newCrop.id!);
          }
        }
      }

      // Return to previous screen
      Navigator.pop(context);

    } catch (error) {
      _showErrorSnackBar('Failed to save crop: $error');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text('Are you sure you want to delete ${widget.cropToEdit?.productName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteCrop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteCrop() {
    if (widget.isEditing && widget.cropToEdit?.id != null) {
      setState(() {
        _isSubmitting = true;
      });

      final viewModel = Provider.of<FarmCropViewModel>(context, listen: false);
      viewModel.removeFarmCrop(widget.cropToEdit!.id!).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorSnackBar('Failed to delete crop: $error');
      });
    }
  }

  IconData _getTomatoTypeIcon(String type) {
    // All are tomatoes, so we use the same base icon but could customize if needed
    return Icons.spa;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Colors.green.shade700;
    final farmMarketViewModel = Provider.of<FarmMarketViewModel>(context);
    final cropViewModel = Provider.of<FarmCropViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Crop' : 'Add New Crop'),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(context),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Form Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    widget.isEditing
                        ? 'Update Crop Information'
                        : 'Enter Crop Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Farm Market Dropdown - Modified to use farmerFarms instead of farmMarkets
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: farmMarketViewModel.isLoading
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFarmMarketId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Your Farm',
                        border: InputBorder.none,
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      hint: const Text('Select Your Farm'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a farm';
                        }
                        return null;
                      },
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFarmMarketId = newValue;
                          });
                        }
                      },
                      items: farmMarketViewModel.farmerFarms
                          .map<DropdownMenuItem<String>>((Farm farm) {
                        return DropdownMenuItem<String>(
                          value: farm.id,
                          child: Row(
                            children: [
                              Icon(
                                Icons.store,
                                color: primaryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(farm.farmName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Crop Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Crop Name',
                    hintText: 'Enter crop name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.eco),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a crop name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tomato Type Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedType = newValue;
                          });
                        }
                      },
                      items: _tomatoTypes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(
                                _getTomatoTypeIcon(value),
                                color: primaryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Implant Date Field
                InkWell(
                  onTap: () => _selectImplantDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Implant Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('MMMM d, yyyy').format(_implantDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Image Upload
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crop Image',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: _isUploadingImage ? null : _showImageSourceDialog,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: _isUploadingImage
                                  ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Uploading image...',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : _imageFile != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : _existingImageUrl != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _existingImageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (ctx, error, _) => const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to add image',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add_photo_alternate),
                            label: Text(_isUploadingImage ? 'Uploading...' : 'Select Image'),
                            onPressed: _isUploadingImage ? null : _showImageSourceDialog,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor),
                              foregroundColor: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Divider with label
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Harvest Information',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Harvested Date Field
                InkWell(
                  onTap: () => _selectHarvestedDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Harvest Date (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.agriculture),
                      suffixIcon: _harvestedDate != null
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _harvestedDate = null;
                          });
                        },
                      )
                          : null,
                    ),
                    child: Text(
                      _harvestedDate != null
                          ? DateFormat('MMMM d, yyyy').format(_harvestedDate!)
                          : 'Not harvested yet',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity Field
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity (Optional)',
                    hintText: 'Enter harvest quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.inventory_2),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Audit Status (only shown if editing)
                if (widget.isEditing)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildAuditStatusChip(AuditStatus.pending, 'Pending'),
                          const SizedBox(width: 8),
                          _buildAuditStatusChip(AuditStatus.confirmed, 'Confirmed'),
                          const SizedBox(width: 8),
                          _buildAuditStatusChip(AuditStatus.rejected, 'Rejected'),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Submit Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isSubmitting || _isUploadingImage) ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: primaryColor,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Text(
                      widget.isEditing ? 'Update Crop' : 'Add Crop',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Show errors if any
                if (cropViewModel.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Text(
                      cropViewModel.errorMessage!,
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuditStatusChip(AuditStatus status, String label) {
    Color chipColor;
    switch (status) {
      case AuditStatus.confirmed:
        chipColor = Colors.green;
        break;
      case AuditStatus.rejected:
        chipColor = Colors.red;
        break;
      case AuditStatus.pending:
      default:
        chipColor = Colors.orange;
    }

    return Expanded(
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: _auditStatus == status ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: _auditStatus == status,
        selectedColor: chipColor,
        backgroundColor: chipColor.withOpacity(0.2),
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _auditStatus = status;
            });
          }
        },
      ),
    );
  }
}