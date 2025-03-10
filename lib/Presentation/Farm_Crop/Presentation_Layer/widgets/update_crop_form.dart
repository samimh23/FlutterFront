import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Domain_Layer/entities/farm_crop.dart';
import '../viewmodels/farm_crop_viewmodel.dart';

class UpdateCropForm extends StatefulWidget {
  final FarmCrop crop;

  const UpdateCropForm({super.key, required this.crop});

  @override
  State<UpdateCropForm> createState() => _UpdateCropFormState();
}

class _UpdateCropFormState extends State<UpdateCropForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productNameController;
  late TextEditingController _typeController;
  late TextEditingController _quantityController;
  late TextEditingController _auditReportController;
  late DateTime _implantDate;
  DateTime? _harvestedDay;
  String? _selectedImageUrl;
  String? _selectedAuditProofUrl;
  String? _selectedAuditStatus;
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing crop data
    _productNameController = TextEditingController(text: widget.crop.productName);
    _typeController = TextEditingController(text: widget.crop.type);
    _quantityController =
        TextEditingController(text: widget.crop.quantity?.toString() ?? '');
    _auditReportController =
        TextEditingController(text: widget.crop.auditReport ?? '');
    _implantDate = widget.crop.implantDate;
    _harvestedDay = widget.crop.harvestedDay;
    _selectedImageUrl = widget.crop.picture;
    _selectedAuditProofUrl = widget.crop.auditProofImage;
    _selectedAuditStatus = widget.crop.auditStatus;
    _expenses = List.from(widget.crop.expenses);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FarmCropViewModel>(context, listen: false);

    return Form(
      key: _formKey,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
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
            ),
            const SizedBox(height: 12),

            // Implant Date (display only since it shouldn't be modified after creation)
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Implant Date'),
              subtitle: Text(DateFormat('MMM d, y').format(_implantDate)),
            ),
            const SizedBox(height: 12),

            // Harvested Day
            ListTile(
              leading: const Icon(Icons.grass),
              title: const Text('Harvested Day'),
              subtitle: Text(_harvestedDay == null
                  ? 'Not harvested yet'
                  : DateFormat('MMM d, y').format(_harvestedDay!)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: _implantDate,
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _harvestedDay = date);
                }
              },
            ),
            const Divider(),

            // Audit Status
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('Audit Status'),
              subtitle: _selectedAuditStatus == null
                  ? const Text('Not selected')
                  : Text(_selectedAuditStatus!),
              trailing: DropdownButton<String>(
                value: _selectedAuditStatus,
                hint: const Text('Select'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAuditStatus = newValue;
                  });
                },
                items: ['confirmed', 'pending', 'rejected'].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Audit Report
            TextFormField(
              controller: _auditReportController,
              decoration: const InputDecoration(
                labelText: 'Audit Report',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Image Picker (Placeholder for actual implementation)
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Crop Picture'),
              subtitle: _selectedImageUrl == null
                  ? const Text('No image selected')
                  : Image.network(
                _selectedImageUrl!,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
              onTap: () {
                // In a real app, implement image picking logic here
                // For now, set a placeholder URL or use a file picker
                setState(() {
                  _selectedImageUrl = 'https://example.com/placeholder.jpg';
                });
              },
            ),
            const SizedBox(height: 12),

            // Audit Proof Image (Placeholder for actual implementation)
            ListTile(
              leading: const Icon(Icons.assignment_turned_in),
              title: const Text('Audit Proof Image'),
              subtitle: _selectedAuditProofUrl == null
                  ? const Text('No image selected')
                  : Image.network(
                _selectedAuditProofUrl!,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
              onTap: () {
                // In a real app, implement image picking logic here
                // For now, set a placeholder URL or use a file picker
                setState(() {
                  _selectedAuditProofUrl = 'https://example.com/placeholder.jpg';
                });
              },
            ),
            const SizedBox(height: 20),

            // Expenses Section
            ExpansionTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Expenses'),
              subtitle: Text(
                  '${_expenses.length} expenses - Total: \$${calculateTotalExpenses().toStringAsFixed(2)}'),
              children: [
                ..._expenses.map((expense) => ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(expense.description),
                  subtitle:
                  Text('${DateFormat('MMM d, y').format(expense.date)}'),
                  trailing: Text('\$${expense.value.toStringAsFixed(2)}'),
                )),
                ListTile(
                  leading: const Icon(Icons.add_circle),
                  title: const Text('Add Expense'),
                  onTap: () => _showAddExpenseDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Update Crop'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Parse quantity to integer (changed from double)
                        int? quantity;
                        if (_quantityController.text.isNotEmpty) {
                          quantity = int.tryParse(_quantityController.text);
                        }

                        // Create updated crop
                        final updatedCrop = widget.crop.copyWith(
                          productName: _productNameController.text,
                          type: _typeController.text,
                          harvestedDay: _harvestedDay,
                          quantity: quantity,
                          auditStatus: _selectedAuditStatus,
                          auditReport: _auditReportController.text.isNotEmpty
                              ? _auditReportController.text
                              : null,
                          auditProofImage: _selectedAuditProofUrl,
                          picture: _selectedImageUrl,
                          expenses: _expenses,
                        );

                        // Call ViewModel to update the crop
                        viewModel.modifyFarmCrop(updatedCrop);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Crop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // Call ViewModel to delete the crop
                     // viewModel.removeFarmCrop(widget.crop.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double calculateTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.value);
  }

  void _showAddExpenseDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final valueController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMM d, y').format(selectedDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: _implantDate,
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (descriptionController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                final newExpense = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  description: descriptionController.text,
                  value: double.tryParse(valueController.text) ?? 0,
                  date: selectedDate,
                );

                setState(() {
                  _expenses.add(newExpense);
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
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