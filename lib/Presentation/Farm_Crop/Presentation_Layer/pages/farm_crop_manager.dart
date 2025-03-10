import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Domain_Layer/entities/farm_crop.dart';
import '../viewmodels/farm_crop_viewmodel.dart';
import '../widgets/add_crop_form.dart';
import '../widgets/crop_card.dart';
import '../widgets/update_crop_form.dart';


class FarmCropManager extends StatelessWidget {
  const FarmCropManager({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FarmCropViewModel>(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Farm Crops',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calculateCrossAxisCount(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: viewModel.crops.length,
                  itemBuilder: (context, index) => CropCard(
                    crop: viewModel.crops[index],
                    onTap: () => _showUpdateCropDialog(context, viewModel.crops[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddCropDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  void _showAddCropDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600, // Set a maximum width
          height: 600, // Set a fixed height
          child: AddCropForm(farmId: "6601a2b3f4e5d6c7a8b9c0d1"),
        ),
      ),
    );
  }
  void _showUpdateCropDialog(BuildContext context, FarmCrop crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Crop'),
        content: SingleChildScrollView(
          child: UpdateCropForm(crop: crop),
        ),
      ),
    );
  }
}