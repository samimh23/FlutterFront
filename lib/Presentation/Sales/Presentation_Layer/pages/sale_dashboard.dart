import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Domain_Layer/entities/sale.dart';
import '../viewmodels/sale_viewmodel.dart';
import '../widgets/sale_cards.dart';
import '../widgets/sale_forms.dart';

class SaleDashboard extends StatefulWidget {
  const SaleDashboard({Key? key}) : super(key: key);

  @override
  State<SaleDashboard> createState() => _SaleDashboardState();
}

class _SaleDashboardState extends State<SaleDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SaleViewModel>(context, listen: false).fetchAllSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SaleViewModel>(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sales Management', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSalesList(context, viewModel),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddSaleDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesList(BuildContext context, SaleViewModel viewModel) {
    if (viewModel.sales.isEmpty) {
      return const Center(child: Text('No sales found'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      padding: const EdgeInsets.all(12),
      itemCount: viewModel.sales.length,
      itemBuilder: (context, index) => buildSaleCard(
        context,
        viewModel.sales[index],
        viewModel,
        onTap: () => _showEditSaleDialog(context, viewModel.sales[index]),
      ),
    );
  }

  void _showAddSaleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const NewSalePopup(),
                );
              },
              child: const Text('Add New Sale'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditSaleDialog(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      builder: (context) => EditSalePopup(sale: sale),
    );
  }
}