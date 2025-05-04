import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../Farm_Crop/Domain_Layer/entities/farm_crop.dart';
import '../../../../Sales/Domain_Layer/entities/sale.dart';
import '../../../../Sales/Presentation_Layer/viewmodels/sale_viewmodel.dart';
import '../../../Domain_Layer/entity/farm.dart';
import '../../viewmodels/farmviewmodel.dart';
import 'FarmMobileManageScreen.dart';

class FarmMobileDetailScreen extends StatefulWidget {
  final Farm farm;

  const FarmMobileDetailScreen({Key? key, required this.farm}) : super(key: key);

  @override
  State<FarmMobileDetailScreen> createState() => _FarmMobileDetailScreenState();
}

class _FarmMobileDetailScreenState extends State<FarmMobileDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load sales related to this farm when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.farm.id != null) {
        Provider.of<SaleViewModel>(context, listen: false)
            .setCurrentFarmMarketId(widget.farm.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final farmViewModel = Provider.of<FarmMarketViewModel>(context);
    final saleViewModel = Provider.of<SaleViewModel>(context);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: farmViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          if (widget.farm.id != null) {
            await saleViewModel.fetchSalesByFarmMarket(widget.farm.id!);
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar with Farm Image
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: widget.farm.farmImage != null && widget.farm.farmImage!.isNotEmpty
                    ? Image.network(
                  widget.farm.farmImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
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
                    child: Center(
                      child: Icon(
                        Icons.store,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                )
                    : Container(
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
                  child: Center(
                    child: Icon(
                      Icons.store,
                      size: 80,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              actions: [

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(context, farmViewModel);
                    } else if (value == 'share') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Share functionality coming soon!"))
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Share Farm'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Farm'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.farm.farmName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.farm.farmLocation,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Rating Badge
                        if (widget.farm.rate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  widget.farm.rate!,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions Cards
                    Row(
                      children: [
                        // Call Card
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.phone,
                            title: 'Call',
                            value: widget.farm.farmPhone ?? 'Not available',
                            iconColor: Colors.blue,
                            onTap: () {
                              if (widget.farm.farmPhone != null && widget.farm.farmPhone!.isNotEmpty) {
                                launchUrl(Uri.parse('tel:${widget.farm.farmPhone}'));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("No phone number available"))
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Email Card
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.email,
                            title: 'Email',
                            value: widget.farm.farmEmail ?? 'Not available',
                            iconColor: Colors.orange,
                            onTap: () {
                              if (widget.farm.farmEmail != null && widget.farm.farmEmail!.isNotEmpty) {
                                launchUrl(Uri.parse('mailto:${widget.farm.farmEmail}'));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("No email available"))
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Directions Card
                    _buildInfoCard(
                      context,
                      icon: Icons.directions,
                      title: 'Directions',
                      value: 'Get directions to this farm',
                      iconColor: Colors.green,
                      onTap: () {
                        final url = Uri.parse(
                            'https://maps.google.com/?q=${Uri.encodeComponent(widget.farm.farmLocation)}'
                        );
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Farm Description
                    if (widget.farm.farmDescription != null && widget.farm.farmDescription!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'About This Farm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.farm.farmDescription!,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Available Items Section
                    if (widget.farm.sales != null && widget.farm.sales!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(context, 'Available Items'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.farm.sales!
                                .map((item) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.eco, size: 16, color: Colors.green.shade700),
                                  const SizedBox(width: 6),
                                  Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                                .toList(),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Products For Sale Section
                    _buildSectionTitle(context, 'Products For Sale'),
                    const SizedBox(height: 12),

                    // Sales List
                    saleViewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : saleViewModel.sales.isEmpty
                        ? _buildEmptyProductList()
                        : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: saleViewModel.sales.length,
                      itemBuilder: (context, index) {
                        final sale = saleViewModel.sales[index];
                        return FutureBuilder<FarmCrop?>(
                          future: saleViewModel.getCropForSale(sale.farmCropId),
                          builder: (context, snapshot) {
                            final cropName = snapshot.data?.productName ?? 'Product';
                            return _buildProductCard(context, sale, cropName);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildEmptyProductList() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No products listed for sale at the moment",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Sale sale, String cropName) {
    // Format currency
    final formatter = NumberFormat.currency(symbol: '\$');
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Icon/Image
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  radius: 30,
                  child: Icon(
                    Icons.spa,
                    color: primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatter.format(sale.pricePerUnit)} per unit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.inventory_2,
                          'Available: ${sale.quantity.toStringAsFixed(1)} units'
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                          Icons.shopping_basket,
                          'Min. Order: ${sale.quantityMin.toStringAsFixed(1)} units'
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notes Section
          if (sale.notes != null && sale.notes!.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sale.notes!,
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.message, size: 18),
                  label: const Text('Contact'),
                  onPressed: () {
                    if (widget.farm.farmPhone != null && widget.farm.farmPhone!.isNotEmpty) {
                      launchUrl(Uri.parse('tel:${widget.farm.farmPhone}'));
                    } else if (widget.farm.farmEmail != null && widget.farm.farmEmail!.isNotEmpty) {
                      launchUrl(Uri.parse('mailto:${widget.farm.farmEmail}'));
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart, size: 18),
                  label: const Text('Order Now'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order functionality coming soon!'))
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, FarmMarketViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
            const SizedBox(width: 12),
            const Text('Delete Farm'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this farm? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.removeFarmMarket(widget.farm.id!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}