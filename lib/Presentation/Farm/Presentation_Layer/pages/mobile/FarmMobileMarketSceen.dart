import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hanouty/Core/theme/AppColors.dart'; // Import for MarketOwnerColors

import '../../../../Sales/Presentation_Layer/viewmodels/sale_viewmodel.dart';
import '../../../Domain_Layer/entity/farm.dart';
import '../../viewmodels/farmviewmodel.dart';
import 'FarmMobileDetailScreen.dart';
import 'FarmMobileManageScreen.dart';

class FarmMarketplaceScreen extends StatefulWidget {
  const FarmMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<FarmMarketplaceScreen> createState() => _FarmMarketplaceScreenState();
}

class _FarmMarketplaceScreenState extends State<FarmMarketplaceScreen> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    return Scaffold(
      backgroundColor: MarketOwnerColors.background,
      body: Consumer<FarmMarketViewModel>(
        builder: (context, viewModel, child) {
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 170.0,
                  pinned: true,
                  backgroundColor: MarketOwnerColors.primary,
                  elevation: _isScrolled ? 2 : 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                    title: _isScrolled
                        ? const Text(
                      'Farm Marketplace',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    )
                        : null,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background using MarketOwnerColors
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                MarketOwnerColors.primary,
                                MarketOwnerColors.primary.withOpacity(0.8),
                                MarketOwnerColors.secondary,
                              ],
                            ),
                          ),
                        ),
                        // Decorative icon
                        Positioned(
                          right: -30,
                          top: -10,
                          child: Opacity(
                            opacity: 0.15,
                            child: Icon(
                              Icons.eco,
                              size: 150,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Header content
                        Positioned(
                          left: 24,
                          bottom: 60,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Farm Marketplace',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Discover local farms and fresh produce',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
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
                      height: 56,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search farms, products, locations...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.search, color: MarketOwnerColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.filter_list, color: MarketOwnerColors.primary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Filters coming soon!"),
                                  backgroundColor: MarketOwnerColors.primary,
                                ),
                              );
                            },
                          ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: MarketOwnerColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditFarmScreen(isEditing: false),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(FarmMarketViewModel viewModel, BuildContext context) {
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: MarketOwnerColors.primary),
      );
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorView(viewModel, context);
    }

    // Filter farms based on search query
    final filteredFarms = viewModel.farmMarkets.where((farm) {
      final matchesSearch = farm.farmName.toLowerCase().contains(_searchQuery) ||
          (farm.farmDescription?.toLowerCase().contains(_searchQuery) ?? false) ||
          farm.farmLocation.toLowerCase().contains(_searchQuery) ||
          (farm.sales?.any((item) => item.toLowerCase().contains(_searchQuery)) ?? false);

      return matchesSearch;
    }).toList();

    if (filteredFarms.isEmpty) {
      return _buildEmptyView(context);
    }

    return _buildFarmGrid(filteredFarms, context);
  }

  Widget _buildErrorView(FarmMarketViewModel viewModel, BuildContext context) {
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
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MarketOwnerColors.text,
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
              onPressed: () => viewModel.fetchAllFarmMarkets(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MarketOwnerColors.primary,
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
              _searchQuery.isEmpty ? Icons.eco_outlined : Icons.search_off,
              size: 80,
              color: MarketOwnerColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty
                  ? 'No farms available yet'
                  : 'No farms match your search',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MarketOwnerColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Be the first to add your farm to our marketplace!'
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
                      builder: (context) => AddEditFarmScreen(isEditing: false),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Your Farm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MarketOwnerColors.primary,
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

  Widget _buildFarmGrid(List<Farm> farms, BuildContext context) {
    // Check if we're on a very small device
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isSmallScreen ? 1 : 2, // Switch to single column on small screens
          childAspectRatio: isSmallScreen ? 1.2 : 0.78,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: farms.length,
        itemBuilder: (context, index) {
          final farm = farms[index];
          return _buildFarmCard(context, farm);
        },
      ),
    );
  }

  Widget _buildFarmCard(BuildContext context, Farm farm) {
    return GestureDetector(
      onTap: () {
        Provider.of<FarmMarketViewModel>(context, listen: false)
            .selectFarmMarket(farm.id!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: context.read<SaleViewModel>(),
              child: FarmMobileDetailScreen(farm: farm),
            ),
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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farm image with overlay
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MarketOwnerColors.primary.withOpacity(0.05),
                  ),
                  child: farm.farmImage != null && farm.farmImage!.isNotEmpty
                      ? Image.network(
                    farm.farmImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: MarketOwnerColors.background,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: MarketOwnerColors.primary.withOpacity(0.3),
                            size: 40,
                          ),
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Icon(
                      Icons.landscape,
                      color: MarketOwnerColors.primary.withOpacity(0.3),
                      size: 40,
                    ),
                  ),
                ),

                // Rating badge
                if (farm.rate != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MarketOwnerColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            farm.rate!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Available items badge
                if (farm.sales != null && farm.sales!.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MarketOwnerColors.secondary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shopping_basket, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${farm.sales!.length} items',
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

            // Farm details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.farmName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: MarketOwnerColors.text,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: MarketOwnerColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            farm.farmLocation,
                            style: TextStyle(
                              fontSize: 12,
                              color: MarketOwnerColors.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Expanded(
                      child: Text(
                        farm.farmDescription ?? 'No description available',
                        style: TextStyle(
                          fontSize: 12,
                          color: MarketOwnerColors.text.withOpacity(0.7),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // View Products Button for larger cards
                    if (MediaQuery.of(context).size.width >= 360 && farm.sales != null && farm.sales!.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: TextButton(
                            onPressed: () {
                              Provider.of<FarmMarketViewModel>(context, listen: false)
                                  .selectFarmMarket(farm.id!);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider.value(
                                    value: context.read<SaleViewModel>(),
                                    child: FarmMobileDetailScreen(farm: farm),
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              foregroundColor: MarketOwnerColors.primary,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('View Products', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 12),
                              ],
                            ),
                          ),
                        ),
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
}