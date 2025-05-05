import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/farmviewmodel.dart';

class FarmProductsScreen extends StatefulWidget {
  final String farmId;

  const FarmProductsScreen({Key? key, required this.farmId}) : super(key: key);

  @override
  State<FarmProductsScreen> createState() => _FarmProductsScreenState();
}

class _FarmProductsScreenState extends State<FarmProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch farm products when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmMarketViewModel>().fetchFarmProducts(widget.farmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Products'),
      ),
      body: Consumer<FarmMarketViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchFarmProducts(widget.farmId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = viewModel.farmProducts;

          if (products.isEmpty) {
            return const Center(
              child: Text('No products available for this farm'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              // Adjust the UI based on your product data structure
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.eco, color: Colors.green),
                ),
                title: Text(product['name'] ?? 'Unknown Product'),
                subtitle: Text('${product['quantity'] ?? 'N/A'} | \$${product['price']?.toStringAsFixed(2) ?? 'N/A'}'),
                trailing: product['available'] == true
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
                onTap: () {
                  // Handle product selection
                  // Navigate to product details or show a dialog
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add product screen
          // This would depend on your app's navigation structure
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Product',
      ),
    );
  }
}