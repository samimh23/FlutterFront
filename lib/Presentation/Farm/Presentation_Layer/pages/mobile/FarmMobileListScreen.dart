import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Domain_Layer/entity/farm.dart';
import '../../viewmodels/farmviewmodel.dart';
import 'FarmMobileDetailScreen.dart';
import 'FarmMobileManageScreen.dart';

class FarmListScreen extends StatelessWidget {
  const FarmListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Farm Markets'),
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
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
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
            return const Center(
              child: Text(
                'No farms available.\nAdd a new farm to get started!',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: viewModel.farmMarkets.length,
            itemBuilder: (context, index) {
              final farm = viewModel.farmMarkets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    child: Text(farm.farmName.isNotEmpty ? farm.farmName[0].toUpperCase() : 'F'),
                  ),
                  title: Text(
                    farm.farmName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    farm.farmLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditFarmScreen(
                                isEditing: true,
                                farm: farm,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (farm.id != null) {
                            _showDeleteConfirmation(context, viewModel, farm.id!);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    if (farm.id != null) {
                      viewModel.selectFarmMarket(farm.id!);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FarmMobileDetailScreen(farm: farm),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditFarmScreen(isEditing: false),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, FarmMarketViewModel viewModel, String farmId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm'),
        content: const Text('Are you sure you want to delete this farm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.removeFarmMarket(farmId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}