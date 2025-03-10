import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Domain_Layer/entity/farm.dart';
import '../viewmodels/farmviewmodel.dart';

class FarmDialog extends StatefulWidget {
  final String title;
  final bool isUpdate;
  final Farm? farm;

  const FarmDialog({
    Key? key,
    required this.title,
    required this.isUpdate,
    this.farm,
  }) : super(key: key);

  @override
  State<FarmDialog> createState() => _FarmDialogState();
}

class _FarmDialogState extends State<FarmDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _farmNameController;
  late final TextEditingController _farmLocationController;
  late final TextEditingController _farmPhoneController;
  late final TextEditingController _farmEmailController;
  late final TextEditingController _marketNameController;
  late final TextEditingController _marketLocationController;
  late final TextEditingController _marketDescriptionController;
  late final TextEditingController _cropController;

  String? _marketCategory;
  double _marketRating = 3.0;
  final List<String> _crops = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values if updating
    final farm = widget.farm;
    _farmNameController = TextEditingController(text: farm?.farmName ?? '');
    _farmLocationController = TextEditingController(text: farm?.farmLocation ?? '');
    _farmPhoneController = TextEditingController(text: farm?.farmPhone ?? '');
    _farmEmailController = TextEditingController(text: farm?.farmEmail ?? '');
    _marketNameController = TextEditingController(text: farm?.marketName ?? '');
    _marketLocationController = TextEditingController(text: farm?.marketLocation ?? '');
    _marketDescriptionController = TextEditingController(text: farm?.marketDescription ?? '');
    _cropController = TextEditingController();

    // Initialize other values
    _marketCategory = farm?.marketCategory;
    _marketRating = farm?.marketRating ?? 3.0;

    // Initialize crops list
    if (farm?.crops != null) {
      _crops.addAll(farm!.crops!);
    }
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _farmLocationController.dispose();
    _farmPhoneController.dispose();
    _farmEmailController.dispose();
    _marketNameController.dispose();
    _marketLocationController.dispose();
    _marketDescriptionController.dispose();
    _cropController.dispose();
    super.dispose();
  }

  void _addCrop() {
    if (_cropController.text.trim().isNotEmpty) {
      setState(() {
        _crops.add(_cropController.text.trim());
        _cropController.clear();
      });
    }
  }

  void _removeCrop(String crop) {
    setState(() {
      _crops.remove(crop);
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final farmMarket = Farm(
      id: widget.isUpdate ? widget.farm!.id : null,
      farmName: _farmNameController.text,
      farmLocation: _farmLocationController.text,
      farmPhone: _farmPhoneController.text.isNotEmpty ? _farmPhoneController.text : null,
      farmEmail: _farmEmailController.text.isNotEmpty ? _farmEmailController.text : null,
      marketImage: widget.isUpdate ? widget.farm!.marketImage : null,
      crops: _crops.isEmpty ? null : _crops,
      marketName: _marketNameController.text.isNotEmpty ? _marketNameController.text : null,
      marketLocation: _marketLocationController.text.isNotEmpty ? _marketLocationController.text : null,
      marketDescription: _marketDescriptionController.text.isNotEmpty ? _marketDescriptionController.text : null,
      marketCategory: _marketCategory,
      marketRating: _marketRating,
    );

    final viewModel = Provider.of<FarmMarketViewModel>(context, listen: false);

    if (widget.isUpdate) {
      viewModel.modifyFarmMarket(farmMarket);
    } else {
      viewModel.createFarmMarket(farmMarket);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Farm Information'),

              TextFormField(
                controller: _farmNameController,
                decoration: const InputDecoration(labelText: 'Farm Name *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Farm name is required';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _farmLocationController,
                decoration: const InputDecoration(labelText: 'Farm Location *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Farm location is required';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _farmPhoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),

              TextFormField(
                controller: _farmEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Market Details (Optional)'),

              TextFormField(
                controller: _marketNameController,
                decoration: const InputDecoration(labelText: 'Market Name'),
              ),

              TextFormField(
                controller: _marketLocationController,
                decoration: const InputDecoration(labelText: 'Market Location'),
              ),

              TextFormField(
                controller: _marketDescriptionController,
                decoration: const InputDecoration(labelText: 'Market Description'),
                maxLines: 3,
              ),

              DropdownButtonFormField<String>(
                value: _marketCategory,
                decoration: const InputDecoration(labelText: 'Market Category'),
                items: ['Organic', 'Local', 'Wholesale', 'Community', 'Other']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _marketCategory = value;
                  });
                },
              ),

              const SizedBox(height: 8),
              const Text('Market Rating'),
              Slider(
                value: _marketRating,
                min: 0.0,
                max: 5.0,
                divisions: 10,
                label: _marketRating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _marketRating = value;
                  });
                },
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Available Crops'),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cropController,
                      decoration: const InputDecoration(
                        labelText: 'Add Crop',
                        hintText: 'e.g., Tomatoes',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addCrop,
                  ),
                ],
              ),

              if (_crops.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: _crops.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(_crops[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _removeCrop(_crops[index]),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(widget.isUpdate ? 'UPDATE' : 'SAVE'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}