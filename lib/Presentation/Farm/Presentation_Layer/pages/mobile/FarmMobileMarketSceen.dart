import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  // Theme colors as in DashboardPage
  static const Color _backgroundColor = Color(0xFFF9F5EC);
  static const Color _accentGreen = Color(0xFFA8CF6A);
  static const Color _deepBrown = Color(0xFF6A4D24);

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
    // Use the custom theme colors
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Consumer<FarmMarketViewModel>(
        builder: (context, viewModel, child) {
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 170.0,
                  pinned: true,
                  backgroundColor: _accentGreen,
                  elevation: _isScrolled ? 2 : 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                    title: _isScrolled
                        ? const Text(
                      'Farm Marketplace',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: _deepBrown,
                        letterSpacing: 0.2,
                      ),
                    )
                        : null,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background to match DashboardPage
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFDF6ED),
                                Color(0xFFE2C79E),
                                Color(0xFFA8CF6A),
                              ],
                            ),
                          ),
                        ),
                        // Decorative icon
                        Positioned(
                          right: -30,
                          top: -10,
                          child: Opacity(
                            opacity: 0.13,
                            child: Icon(
                              Icons.eco,
                              size: 150,
                              color: _accentGreen,
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
                                  color: _deepBrown,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Discover local farms and fresh produce',
                                style: TextStyle(
                                  color: Colors.brown[300],
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
                          prefixIcon: Icon(Icons.search, color: _accentGreen),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.filter_list, color: _accentGreen),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Filters coming soon!")),
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
    );
  }

  Widget _buildContent(FarmMarketViewModel viewModel, BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _accentGreen),
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
              color: _accentGreen,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _deepBrown,
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
                backgroundColor: _accentGreen,
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
              color: _accentGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty
                  ? 'No farms available yet'
                  : 'No farms match your search',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _deepBrown,
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
                  backgroundColor: _accentGreen,
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
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                    color: _accentGreen.withOpacity(0.12),
                  ),
                  child: farm.farmImage != null && farm.farmImage!.isNotEmpty
                      ? Image.network(
                    farm.farmImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: _accentGreen.withOpacity(0.08),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: _accentGreen,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Icon(
                      Icons.landscape,
                      color: _accentGreen.withOpacity(0.6),
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
                        color: _accentGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
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
                        color: _deepBrown.withOpacity(0.82),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _deepBrown,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: _accentGreen,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            farm.farmLocation,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.brown[400],
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
                          color: Colors.grey[800],
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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