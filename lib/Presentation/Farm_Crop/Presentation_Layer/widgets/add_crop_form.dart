import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Domain_Layer/entities/farm_crop.dart';
import '../viewmodels/farm_crop_viewmodel.dart';

class AddCropForm extends StatefulWidget {
  final String farmId;

  const AddCropForm({Key? key, required this.farmId}) : super(key: key);

  @override
  State<AddCropForm> createState() => _AddCropFormState();
}

class _AddCropFormState extends State<AddCropForm> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _auditReportController = TextEditingController();
  DateTime? _implantDate;
  DateTime? _harvestedDay;
  String? _selectedImageUrl;
  String? _selectedAuditProofUrl;
  String _auditStatus = 'pending'; // Use string directly to match backend

  // List to store expenses
  List<Expense> _expenses = [];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FarmCropViewModel>(context, listen: false);

    // This creates a scaffold with a fixed body height - key fix for the issue
    return Material(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add New Crop'),
          ),
          // Set a fixed height for the body using MediaQuery
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      // Product Name
                      TextFormField(
                        controller: _productNameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          prefixIcon: Icon(Icons.eco),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                      ),
                      const SizedBox(height: 12),

                      // Type
                      TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          prefixIcon: Icon(Icons.category),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                      ),
                      const SizedBox(height: 12),

                      // Quantity
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: Icon(Icons.scale),
                          suffixText: 'kg',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                      ),
                      const SizedBox(height: 12),

                      // Implant Date
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Implant Date'),
                          subtitle: Text(_implantDate == null
                              ? 'Select date'
                              : DateFormat('MMM d, y').format(_implantDate!)),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _implantDate = date);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Harvested Day
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_month),
                          title: const Text('Harvest Date'),
                          subtitle: Text(_harvestedDay == null
                              ? 'Select date'
                              : DateFormat('MMM d, y').format(_harvestedDay!)),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _implantDate?.add(const Duration(days: 90)) ?? DateTime.now(),
                              firstDate: _implantDate ?? DateTime(2000),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() => _harvestedDay = date);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),

                      // Audit Status - Using string values directly
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.verified),
                              title: const Text('Audit Status'),
                              subtitle: Text(_auditStatus.substring(0, 1).toUpperCase() + _auditStatus.substring(1)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: DropdownButtonFormField<String>(
                                value: _auditStatus,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _auditStatus = newValue;
                                    });
                                  }
                                },
                                items: ['pending', 'confirmed', 'rejected']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value.substring(0, 1).toUpperCase() + value.substring(1)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Audit Report
                      TextFormField(
                        controller: _auditReportController,
                        decoration: const InputDecoration(
                          labelText: 'Audit Report',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      // Image Picker
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.image),
                              title: const Text('Crop Picture'),
                              subtitle: const Text('Tap to select an image'),
                              onTap: () {
                                // In a real app, implement image picking logic here
                                setState(() {
                                  _selectedImageUrl = 'http://example.com/wheat.jpg';
                                });
                              },
                            ),
                            if (_selectedImageUrl != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _selectedImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(child: Icon(Icons.broken_image, size: 50));
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Audit Proof Image
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.assignment_turned_in),
                              title: const Text('Audit Proof Image'),
                              subtitle: const Text('Tap to select an image'),
                              onTap: () {
                                // In a real app, implement image picking logic here
                                setState(() {
                                  _selectedAuditProofUrl = 'http://example.com/wheat-proof.jpg';
                                });
                              },
                            ),
                            if (_selectedAuditProofUrl != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _selectedAuditProofUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(child: Icon(Icons.broken_image, size: 50));
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Expenses Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Expenses',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),

                              // List of expenses
                              ..._expenses.map(_buildExpenseItem).toList(),

                              // Add Expense Button
                              Center(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Expense'),
                                  onPressed: () => _showAddExpenseDialog(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle),
                          label: const Text('Add Crop'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (_implantDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select an implant date')),
                                );
                                return;
                              }

                              final newCrop = FarmCrop(
                             //   id: DateTime.now().millisecondsSinceEpoch.toString(),
                                farmId: widget.farmId,
                                productName: _productNameController.text,
                                type: _typeController.text,
                                implantDate: _implantDate!,
                                harvestedDay: _harvestedDay,
                                expenses: _expenses,
                                quantity: int.tryParse(_quantityController.text),
                                auditStatus: _auditStatus,
                                auditReport: _auditReportController.text.isEmpty ? null : _auditReportController.text,
                                auditProofImage: _selectedAuditProofUrl,
                                picture: _selectedImageUrl,
                              );

                              // Call ViewModel to create the crop
                              viewModel.createFarmCrop(newCrop);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20), // Extra padding at the bottom for scrolling comfort
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  }

  // Build expense list item
  Widget _buildExpenseItem(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(expense.description),
        subtitle: Text(
            '${NumberFormat.currency(symbol: '\$').format(expense.value)} - ${DateFormat('MMM d, y').format(expense.date)}'
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _expenses.remove(expense);
            });
          },
        ),
      ),
    );
  }

  // Show dialog to add new expense
  void _showAddExpenseDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final valueController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                    builder: (context, setState) {
                      return ListTile(
                        title: const Text('Date'),
                        subtitle: Text(DateFormat('MMM d, y').format(selectedDate)),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                      );
                    }
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (descriptionController.text.isEmpty || valueController.text.isEmpty) {
                  return;
                }

                setState(() {
                  _expenses.add(Expense(
                    id: 'exp${DateTime.now().millisecondsSinceEpoch}',
                    description: descriptionController.text,
                    value: double.tryParse(valueController.text) ?? 0,
                    date: selectedDate,
                  ));
                });

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _typeController.dispose();
    _quantityController.dispose();
    _auditReportController.dispose();
    super.dispose();
  }
}