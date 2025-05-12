import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/order/domain/entities/order.dart';
import 'package:hanouty/Presentation/order/presentation/Widgets/EmptyOrdersView.dart';
import 'package:hanouty/Presentation/order/presentation/Widgets/OrderCard.dart';
import 'package:hanouty/Presentation/order/presentation/Widgets/OrderDetailsSheet.dart';
import 'package:hanouty/Presentation/order/presentation/Widgets/TimeFrameSelector.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' show min;

import '../../../../Core/Utils/Api_EndPoints.dart';
import '../../../../Core/theme/AppColors.dart'; // Import AppColors

class MarketOrdersPage extends StatefulWidget {
  final NormalMarket market;

  const MarketOrdersPage({
    Key? key,
    required this.market,
  }) : super(key: key);

  @override
  State<MarketOrdersPage> createState() => _MarketOrdersPageState();
}

class _MarketOrdersPageState extends State<MarketOrdersPage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;
  List<Order> _orders = [];
  String _selectedTimeFrame = 'All Time';
  List<String> timeFrames = ['Today', 'This Week', 'This Month', 'All Time'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load orders when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get orders from provider
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final orders = await orderProvider.findOrdersByShopId(widget.market.id);

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load orders: ${e.toString()}'),
          backgroundColor: Colors.red, // Keep red for error messages
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      // Use MarketOwnerColors for background
      backgroundColor: isDarkMode
          ? Color(0xFF0D2D4A) // Dark blue background for dark mode
          : MarketOwnerColors.background,
      appBar: AppBar(
        // Use MarketOwnerColors for AppBar
        backgroundColor: MarketOwnerColors.surface,
        elevation: 0,
        title: Text(
          '${widget.market.marketName} Orders',
          style: TextStyle(
            color: MarketOwnerColors.primary, // Use primary blue
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MarketOwnerColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: MarketOwnerColors.primary, // Use primary blue
          unselectedLabelColor: MarketOwnerColors.textLight, // Use lighter text color
          indicatorColor: MarketOwnerColors.primary, // Use primary blue for indicator
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(MarketOwnerColors.primary),
        ),
      )
          : Column(
        children: [
          TimeFrameSelector(
            timeFrames: timeFrames,
            selectedTimeFrame: _selectedTimeFrame,
            onTimeFrameSelected: (timeFrame) {
              setState(() {
                _selectedTimeFrame = timeFrame;
              });
            },
          ),
          // Withdraw Money Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  // Use MarketOwnerColors for button
                  backgroundColor: MarketOwnerColors.primary,
                  foregroundColor: MarketOwnerColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: _onWithdrawMoneyPressed,
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text(
                  'Withdraw Money',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All orders
                _buildOrdersList(_filterOrdersByTab('all')),
                // Pending orders
                _buildOrdersList(_filterOrdersByTab('pending')),
                _buildOrdersList(_filterOrdersByTab('completed')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onWithdrawMoneyPressed() async {
    final amountController = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MarketOwnerColors.surface, // Use surface color
        title: Text(
          "Withdraw Money",
          style: TextStyle(
            color: MarketOwnerColors.text, // Use text color
          ),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: "Amount",
            labelStyle: TextStyle(
              color: MarketOwnerColors.textLight, // Use lighter text color
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: MarketOwnerColors.primary), // Use primary blue
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: MarketOwnerColors.textLight, // Use lighter text color
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MarketOwnerColors.primary, // Use primary blue
              foregroundColor: MarketOwnerColors.onPrimary, // Use on primary color
            ),
            onPressed: () {
              final entered = double.tryParse(amountController.text);
              if (entered == null || entered <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid amount")),
                );
                return;
              }
              Navigator.of(context).pop(entered);
            },
            child: const Text("Withdraw"),
          ),
        ],
      ),
    );

    if (amount != null) {
      try {
        final dio = Dio();
        final secureStorageService = SecureStorageService();
        final token = await secureStorageService.getAccessToken();

        final response = await dio.post(
          '${ApiEndpoints.baseUrl}/normal/${widget.market.id}/transfer-tokens',
          data: {'amount': amount},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Withdraw successful"),
              backgroundColor: MarketOwnerColors.primary, // Use primary blue for success
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Withdraw failed: ${response.statusMessage}"),
              backgroundColor: Colors.red, // Keep red for errors
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red, // Keep red for errors
          ),
        );
      }
    }
  }

  List<Order> _filterOrdersByTab(String tabName) {
    if (_orders.isEmpty) return [];

    // First filter by time frame
    final filteredByTime = _filterOrdersByTimeFrame(_orders);

    // Then filter by tab
    switch (tabName) {
      case 'pending':
        return filteredByTime.where((order) => order.isConfirmed == false).toList();
      case 'completed':
        return filteredByTime.where((order) => order.isConfirmed == true).toList();
      case 'all':
      default:
        return filteredByTime;
    }
  }

  // Helper function to safely get DateTime from order
  DateTime _getOrderDate(Order order) {
    try {
      if (order.dateOrder is DateTime) {
        return order.dateOrder as DateTime;
      } else if (order.dateOrder is String) {
        return DateTime.parse(order.dateOrder as String);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now(); // Fallback
  }

  List<Order> _filterOrdersByTimeFrame(List<Order> orders) {
    if (orders.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    switch (_selectedTimeFrame) {
      case 'Today':
        return orders.where((order) {
          final orderDate = _getOrderDate(order);
          return _isSameDay(orderDate, today);
        }).toList();
      case 'This Week':
        return orders.where((order) {
          final orderDate = _getOrderDate(order);
          return orderDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) ||
              _isSameDay(orderDate, startOfWeek);
        }).toList();
      case 'This Month':
        return orders.where((order) {
          final orderDate = _getOrderDate(order);
          return orderDate.year == startOfMonth.year &&
              orderDate.month == startOfMonth.month;
        }).toList();
      case 'All Time':
      default:
        return orders;
    }
  }

  // Helper method to check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
      return EmptyOrdersView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onViewDetails: () => _showOrderDetails(order),
        );
      },
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MarketOwnerColors.surface, // Use surface color
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OrderDetailsSheet(order: order),
    );
  }
}