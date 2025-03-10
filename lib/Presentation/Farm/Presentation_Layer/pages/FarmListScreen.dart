import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Domain_Layer/entity/farm.dart';
import '../viewmodels/farmviewmodel.dart';
import '../widgets/FarmDialog.dart';
import 'FarmDetailScreen.dart';

class FarmListScreen extends StatelessWidget {
  const FarmListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Markets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<FarmMarketViewModel>(context, listen: false)
                  .fetchAllFarmMarkets();
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
                    onPressed: () => viewModel.fetchAllFarmMarkets(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.farmMarkets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No farm markets available',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddFarmDialog(context),
                    child: const Text('Add Farm Market'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: viewModel.farmMarkets.length,
            itemBuilder: (context, index) {
              final farm = viewModel.farmMarkets[index];
              return FarmListItem(farm: farm);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFarmDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddFarmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FarmDialog(
        title: 'Add Farm Market',
        isUpdate: false,
      ),
    );
  }
}

class FarmListItem extends StatelessWidget {
  final Farm farm;

  const FarmListItem({Key? key, required this.farm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: farm.marketImage != null
            ? CircleAvatar(
          backgroundImage: NetworkImage(farm.marketImage!),
        )
            : CircleAvatar(
          backgroundColor: Colors.green[100],
          child: const Icon(Icons.eco, color: Colors.green),
        ),
        title: Text(farm.farmName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(farm.farmLocation),
            if (farm.marketRating != null)
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(' ${farm.marketRating!.toStringAsFixed(1)}'),
                ],
              ),
            if (farm.crops != null && farm.crops!.isNotEmpty)
              Wrap(
                spacing: 4,
                children: farm.crops!
                    .map((crop) => Chip(
                  label: Text(crop),
                  labelStyle: const TextStyle(fontSize: 10),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ))
                    .toList(),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Provider.of<FarmMarketViewModel>(context, listen: false)
                    .selectFarmMarket(farm.id!);
                showDialog(
                  context: context,
                  builder: (context) => FarmDialog(
                    title: 'Update Farm Market',
                    isUpdate: true,
                    farm: farm,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, farm),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FarmDetailScreen(farmId: farm.id!),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Farm farm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm Market'),
        content: Text('Are you sure you want to delete ${farm.farmName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<FarmMarketViewModel>(context, listen: false)
                  .removeFarmMarket(farm.id!);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}