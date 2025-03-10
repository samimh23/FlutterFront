import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Domain_Layer/entities/farm_crop.dart';

class CropCard extends StatelessWidget {
  final FarmCrop crop;
  final VoidCallback onTap;

  const CropCard({super.key, required this.crop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double totalExpenses =
    crop.expenses.fold(0, (sum, expense) => sum + expense.value);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (crop.picture != null)
              Image.network(
                crop.picture!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop.productName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Planted: ${DateFormat('MMM d, y').format(crop.implantDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (crop.auditStatus != null)
                    Chip(
                      label: Text(crop.auditStatus!),
                      backgroundColor: _getAuditStatusColor(crop.auditStatus!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAuditStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green[100]!;
      case 'pending':
        return Colors.orange[100]!;
      case 'rejected':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}