import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../Domain_Layer/entities/farm_crop.dart';
import '../../Presentation_Layer/viewmodels/farm_crop_viewmodel.dart';

class FarmCropTransformScreen extends StatefulWidget {
  final String? cropId; // Optional - if provided, show specific crop transform options

  const FarmCropTransformScreen({
    Key? key,
    this.cropId,
  }) : super(key: key);

  @override
  State<FarmCropTransformScreen> createState() => _FarmCropTransformScreenState();
}

class _FarmCropTransformScreenState extends State<FarmCropTransformScreen> {
  final TextEditingController _auditReportController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _conversionResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // If a specific crop ID is provided, load it
    if (widget.cropId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<FarmCropViewModel>(context, listen: false)
            .fetchCropById(widget.cropId!);
      });
    } else {
      // Otherwise load all crops
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<FarmCropViewModel>(context, listen: false).fetchAllCrops();
      });
    }
  }

  @override
  void dispose() {
    _auditReportController.dispose();
    super.dispose();
  }

  Future<void> _convertToProduct(FarmCropViewModel viewModel, String cropId) async {
    setState(() {
      _isLoading = true;
      _conversionResult = null;
      _errorMessage = null;
    });

    try {
      final result = await viewModel.convertCropToProduct(cropId);
      setState(() {
        _conversionResult = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndConvert(FarmCropViewModel viewModel, String cropId) async {
    if (_auditReportController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please provide an audit report for confirmation";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _conversionResult = null;
      _errorMessage = null;
    });

    try {
      final result = await viewModel.confirmAndConvertCrop(
          cropId,
          _auditReportController.text
      );
      setState(() {
        _conversionResult = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processAllCrops(FarmCropViewModel viewModel) async {
    setState(() {
      _isLoading = true;
      _conversionResult = null;
      _errorMessage = null;
    });

    try {
      final result = await viewModel.processAllConfirmedCrops();
      setState(() {
        _conversionResult = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildResultWidget() {
    if (_conversionResult == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Conversion Successful',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Display conversion result details
          ..._conversionResult!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_errorMessage!),
        ],
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, FarmCrop crop, FarmCropViewModel viewModel) {
    final theme = Theme.of(context);

    // Check if crop is ready for conversion
    final bool isHarvested = crop.harvestedDay != null;
    final bool isConfirmed = FarmCrop.stringToAuditStatus(crop.auditStatus) == AuditStatus.confirmed;
    final bool isPending = FarmCrop.stringToAuditStatus(crop.auditStatus) == AuditStatus.pending;
    final bool canConvert = isHarvested && (isConfirmed || isPending);

    // Calculate total expenses
    double totalExpenses = 0;
    for (var expense in crop.expenses) {
      totalExpenses += expense.value;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop Header with Status Badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        crop.type,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, crop),
              ],
            ),
          ),

          // Crop Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Key Information
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Quantity',
                        crop.quantity != null ? '${crop.quantity}' : 'Not set',
                        Icons.inventory_2,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Expenses',
                        '\$${totalExpenses.toStringAsFixed(2)}',
                        Icons.attach_money,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Implant Date',
                        DateFormat('MM/dd/yyyy').format(crop.implantDate),
                        Icons.calendar_today,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Harvest Date',
                        crop.harvestedDay != null
                            ? DateFormat('MM/dd/yyyy').format(crop.harvestedDay!)
                            : 'Not harvested',
                        Icons.agriculture,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),

                // Transformation Actions
                if (!canConvert)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Not Ready for Conversion',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                !isHarvested
                                    ? 'Crop needs to be harvested first'
                                    : 'Crop needs confirmation',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (canConvert) ...[
                  // Transform actions for valid crops
                  if (isPending)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Confirm & Convert',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _auditReportController,
                          decoration: const InputDecoration(
                            labelText: 'Audit Report',
                            hintText: 'Enter audit confirmation details...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _confirmAndConvert(viewModel, crop.id!),
                          icon: const Icon(Icons.verified),
                          label: const Text('Confirm & Convert to Product'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),

                  if (isConfirmed)
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _convertToProduct(viewModel, crop.id!),
                      icon: const Icon(Icons.transform),
                      label: const Text('Convert to Product'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, FarmCrop crop) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    switch (FarmCrop.stringToAuditStatus(crop.auditStatus)) {
      case AuditStatus.confirmed:
        badgeColor = Colors.green;
        statusText = 'Confirmed';
        statusIcon = Icons.check_circle;
        break;
      case AuditStatus.rejected:
        badgeColor = Colors.red;
        statusText = 'Rejected';
        statusIcon = Icons.cancel;
        break;
      case AuditStatus.pending:
      default:
        badgeColor = Colors.orange;
        statusText = 'Pending';
        statusIcon = Icons.hourglass_empty;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: badgeColor, size: 16),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transform Farm Crops'),
        elevation: 0,
      ),
      body: Consumer<FarmCropViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading crops',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(viewModel.errorMessage ?? 'Unknown error'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (widget.cropId != null) {
                        viewModel.fetchCropById(widget.cropId!);
                      } else {
                        viewModel.fetchAllCrops();
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // Check if we're showing a specific crop or all crops
          final List<FarmCrop> cropsToShow = widget.cropId != null && viewModel.selectedCrop != null
              ? [viewModel.selectedCrop!]
              : viewModel.crops;

          // Filter for crops that have been harvested (ready for processing)
          final List<FarmCrop> harvestedCrops = cropsToShow
              .where((crop) => crop.harvestedDay != null)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card explaining the transformation process
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Farm Crop to Product Transformation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Transform your harvested farm crops into marketable products. '
                            'The system will calculate the product price based on your recorded expenses plus a profit margin.',
                      ),
                    ],
                  ),
                ),

                // Show result or error if present
                _buildResultWidget(),
                _buildErrorWidget(),

                const SizedBox(height: 16),

                // Process all confirmed crops button
                if (widget.cropId == null) // Only show on the main screen, not for individual crops
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.batch_prediction, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Batch Processing',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Process all confirmed farm crops at once to convert them into products.',
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _processAllCrops(viewModel),
                          icon: const Icon(Icons.sync),
                          label: const Text('Process All Confirmed Crops'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // List of crops
                Text(
                  harvestedCrops.isEmpty
                      ? 'No Harvested Crops Available'
                      : 'Harvested Crops',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (harvestedCrops.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No harvested crops found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crops must be harvested before they can be transformed into products',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...harvestedCrops.map((crop) => _buildCropCard(context, crop, viewModel)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}