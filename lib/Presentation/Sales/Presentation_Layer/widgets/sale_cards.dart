import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Farm_Crop/Domain_Layer/entities/farm_crop.dart';
import '../../Domain_Layer/entities/sale.dart';
import '../viewmodels/sale_viewmodel.dart';

Widget buildSaleCard(
  BuildContext context, 
  Sale sale, 
  SaleViewModel viewModel, 
  {required Function() onTap}
) {
  return FutureBuilder(
    future: viewModel.getCropForSale(sale.farmCropId),
    builder: (context, snapshot) {
      final FarmCrop? crop = snapshot.data;
      
      return Card(
        elevation: 3,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Image
                AspectRatio(
                  aspectRatio: 16/9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: crop?.picture != null
                        ? Image.network(
                            crop!.picture!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(Icons.image_not_supported, size: 40)),
                          )
                        : const Center(child: Icon(Icons.agriculture, size: 40)),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Crop name
                Text(
                  crop?.productName ?? 'Unknown Crop',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Crop type
                Text(
                  'Type: ${crop?.type ?? 'Unknown'}',
                  style: TextStyle(color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Quantity and price
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${sale.quantity} kg'),
                      Text('\$${sale.pricePerUnit.toStringAsFixed(2)}/kg'),
                    ],
                  ),
                ),
                
                // Total value
                Text(
                  'Total: \$${sale.pricePerUnit.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Date
                Text(
                  DateFormat.yMMMd().format(sale.createdDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),


                
                const Spacer(),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onTap,
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _confirmDeleteSale(context, sale, viewModel),
                      tooltip: 'Delete',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}



// Helper function to confirm deletion
void _confirmDeleteSale(BuildContext context, Sale sale, SaleViewModel viewModel) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Are you sure you want to delete this sale?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            viewModel.deleteSale(sale.id);
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

String _getRemainingTime(DateTime endTime) {
  final remaining = endTime.difference(DateTime.now());
  if (remaining.inDays > 0) {
    return '${remaining.inDays}d ${remaining.inHours % 24}h';
  } else if (remaining.inHours > 0) {
    return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
  } else {
    return '${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
  }
}

