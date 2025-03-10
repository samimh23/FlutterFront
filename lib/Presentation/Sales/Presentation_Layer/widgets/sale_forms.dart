import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../Domain_Layer/entities/sale.dart';
import '../viewmodels/sale_viewmodel.dart';
import '../../../Farm_Crop/Domain_Layer/entities/farm_crop.dart';
import '../../../Farm_Crop/Presentation_Layer/viewmodels/farm_crop_viewmodel.dart';

class NewSalePopup extends StatefulWidget {
  const NewSalePopup({Key? key}) : super(key: key);

  @override
  _NewSalePopupState createState() => _NewSalePopupState();
}

class _NewSalePopupState extends State<NewSalePopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedCropId;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cropViewModel = Provider.of<FarmCropViewModel>(context);
    final saleViewModel = Provider.of<SaleViewModel>(context, listen: false);

    return AlertDialog(
      title: const Text('New Sale'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Crop Selector Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Crop'),
                value: _selectedCropId,
                items: cropViewModel.crops.map((crop) {
                  return DropdownMenuItem<String>(
                    value: crop.id,
                    child: Text('${crop.productName} (${crop.type})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCropId = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a crop' : null,
              ),
              const SizedBox(height: 16),

              // Quantity Field
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per unit (\$)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final newSale = Sale(
                id: '',
                farmCropId: _selectedCropId!,
                quantity: double.parse(_quantityController.text),
                quantityMin: double.parse(_quantityController.text),
                pricePerUnit: double.parse(_priceController.text),
                createdDate: DateTime.now(),
                notes: _notesController.text.isNotEmpty ? _notesController.text : null,
              );

              await saleViewModel.createSale(newSale);
              if (!mounted) return;
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EditSalePopup extends StatefulWidget {
  final Sale sale;
  const EditSalePopup({Key? key, required this.sale}) : super(key: key);

  @override
  _EditSalePopupState createState() => _EditSalePopupState();
}

class _EditSalePopupState extends State<EditSalePopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _quantityMinController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  late String? _selectedCropId;


  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.sale.quantity.toString());
    _quantityMinController = TextEditingController(text: widget.sale.quantityMin.toString());
    _priceController = TextEditingController(text: widget.sale.pricePerUnit.toString());
    _notesController = TextEditingController(text: widget.sale.notes ?? '');
    _selectedCropId = widget.sale.farmCropId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityMinController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saleViewModel = Provider.of<SaleViewModel>(context, listen: false);

    return AlertDialog(
      title: const Text('Edit Sale'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Crop display (read-only)
              FutureBuilder<FarmCrop?>(
                  future: saleViewModel.getCropForSale(_selectedCropId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final crop = snapshot.data;
                    return InputDecorator(
                      decoration: const InputDecoration(labelText: 'Crop'),
                      child: Text(
                        crop != null
                            ? '${crop.productName} (${crop.type})'
                            : 'Unknown Crop',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }
              ),
              const SizedBox(height: 16),


              const SizedBox(height: 8),

              // Quantity Field
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Minimum Quantity Field
              TextFormField(
                controller: _quantityMinController,
                decoration: const InputDecoration(labelText: 'Minimum Quantity (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter minimum quantity';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per unit (\$)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updatedSale = widget.sale.copyWith(
                  quantity: double.parse(_quantityController.text),
                  quantityMin: double.parse(_quantityMinController.text),
                  pricePerUnit: double.parse(_priceController.text),
                  notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                );

                await saleViewModel.modifySale(updatedSale);
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Complete Sale'),
          ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final updatedSale = widget.sale.copyWith(
                quantity: double.parse(_quantityController.text),
                quantityMin: double.parse(_quantityMinController.text),
                pricePerUnit: double.parse(_priceController.text),
                notes: _notesController.text.isNotEmpty ? _notesController.text : null,
              );

              await saleViewModel.modifySale(updatedSale);
              if (!mounted) return;
              Navigator.pop(context);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}