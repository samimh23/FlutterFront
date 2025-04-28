// farm_crops_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../Domain_Layer/entities/farm_crop.dart';
import '../../Presentation_Layer/viewmodels/farm_crop_viewmodel.dart';
import 'FarmCropDetailScreen.dart';
import 'FarmCropFormScreen.dart';


class FarmCropsListScreen extends StatefulWidget {
  const FarmCropsListScreen({Key? key}) : super(key: key);

  @override
  State<FarmCropsListScreen> createState() => _FarmCropsListScreenState();
}

class _FarmCropsListScreenState extends State<FarmCropsListScreen> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Refresh crops list when screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmCropViewModel>(context, listen: false).fetchAllCrops();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FarmCropFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<FarmCropViewModel>(
        builder: (context, viewModel, child) {
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 180.0,
                  pinned: true,
                  floating: false,
                  backgroundColor: primaryColor,
                  elevation: _isScrolled ? 4 : 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                    title: _isScrolled
                        ? const Text(
                      'Farm Crops',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                        : null,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background gradient
                        Container(
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
                        ),

                        // Decorative elements
                        Positioned(
                          right: -50,
                          top: -20,
                          child: Opacity(
                            opacity: 0.2,
                            child: Icon(
                              Icons.spa,
                              size: 180,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Header content
                        Positioned(
                          left: 20,
                          bottom: 70,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Farm Crops',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Manage your plantations and harvests',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        boxShadow: _isScrolled ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search crop name, type...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: _buildContent(viewModel, context),
          );
        },
      ),
    );
  }

  Widget _buildContent(FarmCropViewModel viewModel, BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorView(viewModel, context);
    }

    // Filter crops based on search query
    final filteredCrops = viewModel.crops.where((crop) {
      final matchesSearch = crop.productName.toLowerCase().contains(_searchQuery) ||
          crop.type.toLowerCase().contains(_searchQuery);
      return matchesSearch;
    }).toList();

    if (filteredCrops.isEmpty) {
      return _buildEmptyView(context);
    }

    return _buildCropsGrid(filteredCrops, context);
  }

  Widget _buildErrorView(FarmCropViewModel viewModel, BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${viewModel.errorMessage}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.fetchAllCrops(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.grass : Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty
                  ? 'No crops available yet'
                  : 'No crops match your search',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Start by adding your first crop'
                  : 'Try adjusting your search or explore other options',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_searchQuery.isEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FarmCropFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Crop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropsGrid(List<FarmCrop> crops, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          return _buildCropCard(context, crop);
        },
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, FarmCrop crop) {
    // Calculate total expenses
    double totalExpenses = 0;
    for (var expense in crop.expenses) {
      totalExpenses += expense.value;
    }

    // Format dates
    final dateFormat = DateFormat('MMM d, yyyy');
    final implantDateFormatted = dateFormat.format(crop.implantDate);
    final harvestedDateFormatted = crop.harvestedDay != null
        ? dateFormat.format(crop.harvestedDay!)
        : 'Not harvested';

    // Get audit status color
    Color statusColor;
    IconData statusIcon;

    switch(FarmCrop.stringToAuditStatus(crop.auditStatus)) {
      case AuditStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case AuditStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case AuditStatus.pending:
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
    }

    // Get crop type icon
    IconData getCropIcon() {
      switch(crop.type.toLowerCase()) {
        case 'vegetable':
          return Icons.food_bank;
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

    return GestureDetector(
      onTap: () {
        Provider.of<FarmCropViewModel>(context, listen: false)
            .selectCrop(crop.id!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmCropDetailScreen(cropId: crop.id!),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop image with overlay
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  child: crop.picture != null && crop.picture!.isNotEmpty
                      ? Image.network(
                    crop.picture!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _cropImagePlaceholder(crop);
                    },
                  )
                      : _cropImagePlaceholder(crop),
                ),

                // Audit status badge
                if (crop.auditStatus != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            crop.auditStatus ?? 'Pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Type badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(getCropIcon(), color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          crop.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Crop details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Implant date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            implantDateFormatted,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Quantity and Expenses
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (crop.quantity != null)
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 14,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${crop.quantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 14,
                              color: totalExpenses > 0 ? Colors.red.shade400 : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '\$${totalExpenses.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: totalExpenses > 0 ? Colors.red.shade400 : Colors.grey.shade700,
                                fontWeight: totalExpenses > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cropImagePlaceholder(FarmCrop crop) {
    Color bgColor;

    // Different background colors based on crop type
    switch(crop.type.toLowerCase()) {
      case 'vegetable':
        bgColor = Colors.green.shade100;
        break;
      case 'fruit':
        bgColor = Colors.red.shade100;
        break;
      case 'grain':
        bgColor = Colors.amber.shade100;
        break;
      case 'flower':
        bgColor = Colors.purple.shade100;
        break;
      default:
        bgColor = Colors.teal.shade100;
    }

    return Container(
      color: bgColor,
      child: Center(
        child: Icon(
          _getCropTypeIcon(crop.type),
          color: Colors.grey.shade700,
          size: 50,
        ),
      ),
    );
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
}