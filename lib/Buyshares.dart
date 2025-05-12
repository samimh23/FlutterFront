import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class CustomerMarketListingsPage extends StatefulWidget {
  const CustomerMarketListingsPage({Key? key}) : super(key: key);

  @override
  State<CustomerMarketListingsPage> createState() => _CustomerMarketListingsPageState();
}

class _CustomerMarketListingsPageState extends State<CustomerMarketListingsPage> {
  bool _loading = false;
  List<dynamic> _listings = [];
  String? _error;

  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchListings());
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found. Please login again.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchListings() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('http://192.168.128.4:3000/normal/shares-for-sale'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          if (decoded is List) {
            _listings = decoded;
          } else if (decoded is Map && decoded.containsKey('listings')) {
            _listings = decoded['listings'];
          } else {
            _listings = [decoded];
          }
        });
      } else {
        setState(() {
          _error = 'Failed to load listings (status ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _listings = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _showBuyDialog(Map<String, dynamic> entry) async {
    final id = entry['_id']?.toString() ?? '';
    final availableShares = entry['sharesForSale'] ?? 0;
    final pricePerShare = entry['pricePerShare'] ?? 0;
    final totalPrice = pricePerShare;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buy Shares'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available Shares: $availableShares'),
            Text('Total Price for All Shares: $totalPrice'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text('Buy All'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _buyShares(id, totalPrice);
    }
  }

  Future<void> _buyShares(String listingId, int amountPaid) async {
    final url = 'http://192.168.128.4:3000/normal/buy-shares/$listingId';
    try {
      final headers = await _getAuthHeaders();

      // LOG: Print what you are sending
      debugPrint('Sending buy request for listing: $listingId');
      debugPrint('Amount Paid: $amountPaid');
      debugPrint('POST URL: $url');
      debugPrint('Headers: $headers');

      final body = jsonEncode({'amountPaid': amountPaid});
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      // LOG: Print the raw response
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      bool success = false;
      String message = 'Unknown response from server';

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          success = decoded['success'] == true;
          message = decoded['message']?.toString() ?? message;
        }
      } catch (_) {}

      if (response.statusCode == 200 || success) {
        await _fetchListings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.isNotEmpty ? message : 'Shares purchased successfully!')),
        );
      } else {
        print('Buy failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.isNotEmpty ? message : 'Failed to buy (status ${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Exception in _buyShares: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Buy error: $e')),
      );
    }
  }

  Widget _buildListingCard(Map<String, dynamic> entry) {
    final market = entry['market'] ?? {};
    final seller = entry['seller'] ?? {};
    final marketName = market['marketName']?.toString() ?? 'Unknown Market';
    final sellerName = seller['name']?.toString() ?? 'Unknown Seller';
    final shares = entry['sharesForSale'] ?? entry['shares'] ?? '-';
    final price = entry['pricePerShare'] ?? '-';
    final isSold = entry['isSold'] == true;
    final date = entry['createdAt'] ?? '';
    final int rawShares = entry['sharesForSale'] ?? entry['shares'] ?? 0;
    final double percent = ((rawShares / 10000) * 100).clamp(0, 100);
    final String percentStr = percent.toStringAsFixed(percent % 1 == 0 ? 0 : 2) + '%';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[200],
                  child: const Icon(Icons.storefront, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    marketName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF224B0C)),
                  ),
                ),
                if (isSold)
                  const Chip(
                    label: Text('Sold', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.redAccent,
                  )
                else
                  const Chip(
                    label: Text('Available', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey, size: 18),
                const SizedBox(width: 4),
                Text(
                  sellerName,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.confirmation_num, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text("Shares: $percentStr", style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, color: Colors.teal, size: 18),
                const SizedBox(width: 4),
                Text("Total Price: $price", style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(date.toString().split('T').first, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isSold)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Buy Shares"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showBuyDialog(entry),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      appBar: AppBar(
        title: const Text('Market Listings For Sale'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchListings,
            tooltip: "Refresh Listings",
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : _listings.isEmpty
          ? const Center(child: Text("No market listings for sale."))
          : ListView.builder(
        itemCount: _listings.length,
        itemBuilder: (context, index) {
          final entry = _listings[index];
          if (entry is Map<String, dynamic>) {
            return _buildListingCard(entry);
          } else {
            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(entry.toString()),
              ),
            );
          }
        },
      ),
    );
  }
}