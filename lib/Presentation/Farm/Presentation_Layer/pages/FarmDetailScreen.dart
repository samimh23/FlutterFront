import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/farmviewmodel.dart';
import '../widgets/FarmDialog.dart';

class FarmDetailScreen extends StatefulWidget {
  final String farmId;

  const FarmDetailScreen({Key? key, required this.farmId}) : super(key: key);

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmMarketViewModel>(context, listen: false)
          .selectFarmMarket(widget.farmId);
    });
  }

  @override
  void dispose() {
    Provider.of<FarmMarketViewModel>(context, listen: false)
        .clearSelectedFarmMarket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final farm = Provider.of<FarmMarketViewModel>(context, listen: false)
                  .selectedFarmMarket;
              if (farm != null) {
                showDialog(
                  context: context,
                  builder: (context) => FarmDialog(
                    title: 'Update Farm Market',
                    isUpdate: true,
                    farm: farm,
                  ),
                );
              }
            },
          ),
        ],
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
                  Text('Error: ${viewModel.errorMessage}',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.selectFarmMarket(widget.farmId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final farm = viewModel.selectedFarmMarket;
          if (farm == null) {
            return const Center(child: Text('Farm not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (farm.marketImage != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        farm.marketImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  farm.farmName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, farm.farmLocation),
                if (farm.farmPhone != null)
                  _buildInfoRow(Icons.phone, farm.farmPhone!),
                if (farm.farmEmail != null)
                  _buildInfoRow(Icons.email, farm.farmEmail!),

                const Divider(height: 32),

                if (farm.marketName != null)
                  _buildSectionTitle(context, 'Market Details'),
                if (farm.marketName != null)
                  _buildInfoRow(Icons.store, farm.marketName!),
                if (farm.marketLocation != null)
                  _buildInfoRow(Icons.place, farm.marketLocation!),
                if (farm.marketRating != null)
                  _buildRatingRow(farm.marketRating!),
                if (farm.marketDescription != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(farm.marketDescription!),
                  ),

                if (farm.crops != null && farm.crops!.isNotEmpty) ...[
                  const Divider(height: 32),
                  _buildSectionTitle(context, 'Available Crops'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: farm.crops!
                        .map((crop) => Chip(
                      label: Text(crop),
                      backgroundColor: Colors.green[100],
                    ))
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildRatingRow(double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.star, size: 20, color: Colors.amber),
          const SizedBox(width: 8),
          Text('$rating / 5.0'),
        ],
      ),
    );
  }
}