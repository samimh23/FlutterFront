import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class MarketListingsPage extends StatefulWidget {
  const MarketListingsPage({Key? key}) : super(key: key);

  @override
  State<MarketListingsPage> createState() => _MarketListingsPageState();
}

class _MarketListingsPageState extends State<MarketListingsPage> {
  bool _loading = false;
  List<dynamic> _listings = [];
  String? _error;
  String? _userMarketId;

  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndFetch());
  }

  Future<void> _initAndFetch() async {
    await _loadUserMarketId();
    await _fetchListings();
  }

  // Helper method to get auth headers
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

  // Load user's market id from secure storage or user profile endpoint
  Future<void> _loadUserMarketId() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('http://192.168.128.4:3000/normal/profile'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Change this path according to your backend's user-market mapping
        final userMarketId = decoded['marketId'] ??
            decoded['market']?['_id'] ??
            decoded['market_id'] ??
            decoded['market'] ??
            null;
        setState(() {
          _userMarketId = userMarketId?.toString();
        });
      }
    } catch (e) {
      // In case of error, leave _userMarketId as null, fallback to show nothing
      setState(() {
        _userMarketId = null;
      });
    }
  }

  Future<void> _fetchListings() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_userMarketId == null) {
        await _loadUserMarketId();
      }
      print('User Market ID: $_userMarketId');
      final response = await http.get(
        Uri.parse('http://192.168.128.4:3000/normal/shares-for-sale'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> allListings;
        if (decoded is List) {
          allListings = decoded;
        } else if (decoded is Map && decoded.containsKey('listings')) {
          allListings = decoded['listings'];
        } else {
          allListings = [decoded];
        }
        // Print all market IDs for debugging
        for (final entry in allListings) {
          final market = entry['market'];
          final marketId = market is Map ? market['_id']?.toString() : market?.toString();
          print('Listing: ${entry['_id']}, Market ID: $marketId');
        }
        // Filter
        if (_userMarketId != null) {
          allListings = allListings.where((entry) {
            final market = entry['market'];
            final marketId = market is Map ? market['_id']?.toString() : market?.toString();
            print('Comparing $marketId with $_userMarketId');
            return marketId == _userMarketId;
          }).toList();
        }
        setState(() {
          _listings = allListings;
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

  Future<void> _showUpdateDialog(Map<String, dynamic> entry) async {
    final id = entry['_id']?.toString() ?? '';
    final TextEditingController sharesController = TextEditingController(
        text: (entry['sharesForSale'] ?? entry['shares'] ?? '').toString());
    final TextEditingController priceController = TextEditingController(
        text: (entry['pricePerShare'] ?? '').toString());

    bool isSold = entry['isSold'] == true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sharesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Shares For Sale'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price Per Share'),
            ),
            Row(
              children: [
                const Text('Is Sold:'),
                Checkbox(
                  value: isSold,
                  onChanged: (val) {
                    setState(() {
                      isSold = val ?? false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Update'),
            onPressed: () async {
              Navigator.pop(context);
              await _updateListing(
                id,
                {
                  "sharesForSale": int.tryParse(sharesController.text),
                  "pricePerShare": int.tryParse(priceController.text),
                  "isSold": isSold,
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteListing(String id) async {
    final url = 'http://192.168.128.4:3000/normal/shares-for-sale/$id';
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _listings.removeWhere((element) => element['_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted')),
        );
      } else {
        print('Delete failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete (status ${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete error: $e')),
      );
    }
  }

  Future<void> _updateListing(String id, Map<String, dynamic> updateData) async {
    final url = 'http://192.168.128.4:3000/normal/shares-for-sale/$id';
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(updateData),
      );
      if (response.statusCode == 200) {
        await _fetchListings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated')),
        );
      } else {
        print('Update failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update (status ${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update error: $e')),
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
    final id = entry['_id']?.toString() ?? '';

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
                Text("Shares: $shares", style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, color: Colors.teal, size: 18),
                const SizedBox(width: 4),
                Text("Price: $price", style: const TextStyle(fontSize: 14)),
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
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Update"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                  onPressed: () => _showUpdateDialog(entry),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text("Delete"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Listing"),
                        content: const Text("Are you sure you want to delete this listing?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _deleteListing(id);
                    }
                  },
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