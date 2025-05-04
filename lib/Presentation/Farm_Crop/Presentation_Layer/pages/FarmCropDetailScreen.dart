import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../Domain_Layer/entities/farm_crop.dart';
import '../../Presentation_Layer/viewmodels/farm_crop_viewmodel.dart';
import 'FarmCropFormScreen.dart';

class FarmCropDetailScreen extends StatefulWidget {
  final String cropId;

  const FarmCropDetailScreen({
    Key? key,
    required this.cropId,
  }) : super(key: key);

  @override
  State<FarmCropDetailScreen> createState() => _FarmCropDetailScreenState();
}

class _FarmCropDetailScreenState extends State<FarmCropDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load crop details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmCropViewModel>(context, listen: false)
          .fetchCropById(widget.cropId);
    });
  }

  IconData _getCropTypeIcon(String type) {
    switch(type.toLowerCase()) {
      case 'vegetable':
        return Icons.eco;
      case 'fruit':
        return Icons.apple;
      case 'grain':
        return Icons.grass;
      case 'flower':
        return Icons.local_florist;
      default:
        return Icons.spa;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: Consumer<FarmCropViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading crop details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(viewModel.errorMessage ?? 'Unknown error'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.fetchCropById(widget.cropId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final crop = viewModel.selectedCrop;
          if (crop == null) {
            return const Center(child: Text('Crop not found'));
          }

          final dateFormat = DateFormat('MMMM d, yyyy');
          final implantDateFormatted = dateFormat.format(crop.implantDate);
          final harvestedDateFormatted = crop.harvestedDay != null
              ? dateFormat.format(crop.harvestedDay!)
              : 'Not harvested yet';

          // Calculate total expenses
          double totalExpenses = 0;
          for (var expense in crop.expenses) {
            totalExpenses += expense.value;
          }

          // Get audit status color and text
          Color statusColor;
          String statusText;
          IconData statusIcon;

          switch(FarmCrop.stringToAuditStatus(crop.auditStatus)) {
            case AuditStatus.confirmed:
              statusColor = Colors.green;
              statusText = 'Confirmed';
              statusIcon = Icons.check_circle;
              break;
            case AuditStatus.rejected:
              statusColor = Colors.red;
              statusText = 'Rejected';
              statusIcon = Icons.cancel;
              break;
            case AuditStatus.pending:
            default:
              statusColor = Colors.orange;
              statusText = 'Pending Audit';
              statusIcon = Icons.hourglass_empty;
              break;
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Crop Image
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: crop.picture != null && crop.picture!.isNotEmpty
                      ? Image.network(
                    crop.picture!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.green.shade700,
                            primaryColor,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getCropTypeIcon(crop.type),
                          size: 80,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.green.shade700,
                          primaryColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCropTypeIcon(crop.type),
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FarmCropFormScreen(
                            isEditing: true,
                            cropToEdit: crop,
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, viewModel, crop);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Crop'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Type
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  crop.productName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      _getCropTypeIcon(crop.type),
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      crop.type,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Audit Status
                          if (crop.auditStatus != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: statusColor, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, color: statusColor, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Key Information Cards
                      Row(
                        children: [
                          // Implant Date Card
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              icon: Icons.calendar_today,
                              title: 'Implant Date',
                              value: implantDateFormatted,
                              iconColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Harvest Date Card
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              icon: Icons.agriculture,
                              title: 'Harvested',
                              value: harvestedDateFormatted,
                              iconColor: crop.harvestedDay != null ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          // Quantity Card
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              icon: Icons.inventory_2,
                              title: 'Quantity',
                              value: crop.quantity != null ? '${crop.quantity}' : 'Not specified',
                              iconColor: Colors.amber,
                            ),
                          ),

                          const SizedBox(width: 12),
                          // Expenses Card
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              icon: Icons.attach_money,
                              title: 'Total Expenses',
                              value: '\$${totalExpenses.toStringAsFixed(2)}',
                              iconColor: totalExpenses > 0 ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Expenses Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Expenses',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _showAddExpenseDialog(context, viewModel, crop);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Expenses List
                          crop.expenses.isEmpty
                              ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No expenses recorded yet',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: crop.expenses.length,
                            itemBuilder: (context, index) {
                              final expense = crop.expenses[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: primaryColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.receipt,
                                      color: primaryColor,
                                    ),
                                  ),
                                  title: Text(expense.description),
                                  subtitle: Text(
                                    DateFormat('MMM d, yyyy').format(expense.date),
                                  ),
                                  trailing: Text(
                                    '\$${expense.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  onLongPress: () {
                                    _showDeleteExpenseDialog(
                                        context, viewModel, crop, expense);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Harvest Information Section
                      if (crop.harvestedDay != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Harvest Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    context,
                                    icon: Icons.calendar_month,
                                    label: 'Harvested Date',
                                    value: harvestedDateFormatted,
                                  ),
                                  if (crop.quantity != null) const SizedBox(height: 12),
                                  if (crop.quantity != null)
                                    _buildInfoRow(
                                      context,
                                      icon: Icons.shopping_basket,
                                      label: 'Quantity Harvested',
                                      value: '${crop.quantity}',
                                    ),
                                  if (crop.auditReport != null && crop.auditReport!.isNotEmpty)
                                    const SizedBox(height: 12),
                                  if (crop.auditReport != null && crop.auditReport!.isNotEmpty)
                                    _buildInfoRow(
                                      context,
                                      icon: Icons.note,
                                      label: 'Harvest Notes',
                                      value: crop.auditReport!,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                      // Not harvested yet section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Harvest Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showHarvestDialog(context, viewModel, crop);
                                  },
                                  icon: const Icon(Icons.agriculture),
                                  label: const Text('Record Harvest'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.agriculture_outlined,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Crop has not been harvested yet',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required Color iconColor,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.green.shade700,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context,
      FarmCropViewModel viewModel,
      FarmCrop crop,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text(
          'Are you sure you want to delete ${crop.productName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.removeFarmCrop(crop.id!);
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to crops list
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(
      BuildContext context,
      FarmCropViewModel viewModel,
      FarmCrop crop,
      ) {
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
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Amount (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  selectedDate = pickedDate;
                  (context as Element).markNeedsBuild();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (descriptionController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                try {
                  final value = double.parse(valueController.text);

                  // Generate a unique ID for the expense (UUID would be better)
                  final expenseId = DateTime.now().millisecondsSinceEpoch.toString();

                  final expense = Expense(
                    id: expenseId,
                    description: descriptionController.text,
                    value: value,
                    date: selectedDate,
                  );

                  // Create updated crop with new expense
                  final updatedExpenses = List<Expense>.from(crop.expenses)
                    ..add(expense);
                  final updatedCrop = crop.copyWith(expenses: updatedExpenses);

                  // Update the crop
                  viewModel.modifyFarmCrop(updatedCrop);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteExpenseDialog(
      BuildContext context,
      FarmCropViewModel viewModel,
      FarmCrop crop,
      Expense expense,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Are you sure you want to delete the expense "${expense.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Create updated crop without the expense
              final updatedExpenses = List<Expense>.from(crop.expenses)
                ..removeWhere((e) => e.id == expense.id);

              final updatedCrop = crop.copyWith(expenses: updatedExpenses);

              // Update the crop
              viewModel.modifyFarmCrop(updatedCrop);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showHarvestDialog(
      BuildContext context,
      FarmCropViewModel viewModel,
      FarmCrop crop,
      ) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    DateTime harvestDate = DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isAuditing = false;
          double progress = 0;
          int total = 0;
          int current = 0;
          List<String> auditResults = []; // <-- track results

          Future<void> startAudit(FarmCrop initialCrop, int quantity) async {
            setState(() {
              isAuditing = true;
              total = quantity;
              current = 0;
              progress = 0;
              auditResults.clear();
            });

            await viewModel.auditHarvestedTomatoes(
              crop: initialCrop,
              quantityToCheck: quantity,
              onProgress: (cur, tot) {
                setState(() {
                  current = cur;
                  total = tot;
                  progress = tot > 0 ? cur / tot : 0;
                });
              },
              onResult: (status) { // <-- NEW!
                setState(() {
                  auditResults.add(status); // 'fresh', 'rotten', 'unknown'
                });
              },
            );

            setState(() {
              isAuditing = false;
              progress = 1;
            });

            // Optionally show a summary message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Audit finished! Accepted: ${viewModel.selectedCrop?.quantity ?? 0}')),
            );
          }

          return AlertDialog(
            title: const Text('Record Harvest'),
            content: isAuditing
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Auditing tomatoes, please wait...'),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 10),
                Text('Checked $current of $total'),
                const SizedBox(height: 12),
                // Show a row of icons for each tomato
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: auditResults.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        s == 'fresh'
                            ? '✔️'
                            : s == 'rotten'
                            ? '❌'
                            : '❓',
                        style: const TextStyle(fontSize: 20),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Harvest Date: ${DateFormat('MMM d, yyyy').format(harvestDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: harvestDate,
                      firstDate: crop.implantDate,
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null && pickedDate != harvestDate) {
                      setState(() {
                        harvestDate = pickedDate;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity Harvested',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Harvest Notes (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: isAuditing
                ? []
                : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (quantityController.text.isNotEmpty) {
                    try {
                      final quantity = int.parse(quantityController.text);
                      final updatedCrop = crop.copyWith(
                        harvestedDay: harvestDate,
                        quantity: quantity,
                        auditReport: notesController.text.isNotEmpty
                            ? notesController.text
                            : null,
                      );
                      await viewModel.modifyFarmCrop(updatedCrop);
                      // Start the audit after saving the harvest
                      await startAudit(updatedCrop, quantity);

                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid quantity'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save & Audit'),
              ),
            ],
          );
        },
      ),
    );
  }
}