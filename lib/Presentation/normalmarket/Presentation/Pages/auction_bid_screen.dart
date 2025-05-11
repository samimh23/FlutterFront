import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hanouty/Core/Utils/auction_socket.dart';
import 'package:hanouty/Presentation/Farm_Crop/Presentation_Layer/viewmodels/farm_crop_viewmodel.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:provider/provider.dart';

class AuctionBidScreen extends StatefulWidget {
  final String auctionId;
  final String bidderId;
  final String? cropId;
  final String? endTime;

  const AuctionBidScreen({
    required this.auctionId,
    required this.bidderId,
    this.cropId,
    this.endTime,
  });

  @override
  State<AuctionBidScreen> createState() => _AuctionBidScreenState();
}

class _AuctionBidScreenState extends State<AuctionBidScreen> {
  final _bidController = TextEditingController();
  final socketClient = AuctionSocketClient();

  List<dynamic> bids = [];
  bool hasJoined = false;
  Timer? _timer;
  Duration? _timeLeft;
  double? _startingPrice;

  @override
  void initState() {
    super.initState();

    _initTimer();

    socketClient.connect();

    // Join the auction room
    socketClient.socket.emit('joinAuction', {
      'auctionId': widget.auctionId,
      'bidderId': widget.bidderId
    });

    // Listen for own join confirmation
    socketClient.socket.on('joinedAuction', (data) {
      setState(() {
        hasJoined = true;
        // Add my own join as a special record in the bid/join history
        bids.add({
          'type': 'join',
          'bidderId': widget.bidderId,
          'bidTime': DateTime.now().toIso8601String(),
        });
        if (data['auction'] != null) {
          if (data['auction']['bids'] != null) {
            bids.addAll(data['auction']['bids']);
          }
          if (data['auction']['startingPrice'] != null) {
            _startingPrice = (data['auction']['startingPrice'] as num).toDouble();
          }
        }
        if (data['auction']?['endTime'] != null) {
          _setEndTime(data['auction']['endTime']);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You joined the auction!'))
      );
    });

    // Listen for when another user joins (broadcast from backend)
    socketClient.socket.on('bidderJoinedAuction', (data) {
      if (data['bidderId'] != widget.bidderId) {
        setState(() {
          bids.add({
            'type': 'join',
            'bidderId': data['bidderId'],
            'bidTime': data['time'],
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data['bidderId']} joined the auction'))
        );
      }
    });

    // Listen for when another user leaves (disconnect)
    socketClient.socket.on('bidderLeft', (data) {
      if (data['bidderId'] != widget.bidderId) {
        setState(() {
          bids.add({
            'type': 'leave',
            'bidderId': data['bidderId'],
            'bidTime': data['time'],
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data['bidderId']} left the auction'))
        );
      }
    });

    // Listen for auction updates (bid placed, etc)
    socketClient.socket.on('auctionUpdated', (data) {
      if (data != null && data['auction'] != null && data['auction']['bids'] != null) {
        setState(() {
          bids = [
            ...bids.where((b) => b['type'] == 'join' || b['type'] == 'leave'),
            ...data['auction']['bids']
          ];
        });
      } else if (data != null && data['bids'] != null) {
        setState(() {
          bids = [
            ...bids.where((b) => b['type'] == 'join' || b['type'] == 'leave'),
            ...data['bids']
          ];
        });
      }
      if (data?['auction']?['endTime'] != null) {
        _setEndTime(data['auction']['endTime']);
      } else if (data?['endTime'] != null) {
        _setEndTime(data['endTime']);
      }
    });

    socketClient.socket.on('bidSuccess', (data) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bid placed successfully!'))
      );
      _bidController.clear();
      if (data != null && data['auction'] != null && data['auction']['bids'] != null) {
        setState(() {
          bids = [
            ...bids.where((b) => b['type'] == 'join' || b['type'] == 'leave'),
            ...data['auction']['bids']
          ];
        });
      } else if (data != null && data['bids'] != null) {
        setState(() {
          bids = [
            ...bids.where((b) => b['type'] == 'join' || b['type'] == 'leave'),
            ...data['bids']
          ];
        });
      }
      if (data?['endTime'] != null) {
        _setEndTime(data['endTime']);
      }
    });

    socketClient.socket.on('bidError', (data) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bid failed: ${data['error']}'))
      );
    });

    // Join user-specific room for user-level notifications (optional)
    socketClient.socket.emit('joinUserRoom', {
      'userId': widget.bidderId
    });

    socketClient.socket.on('marketSelectionRequired', (data) async {
      String? selectedMarket = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Select Market"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: (data['markets'] as List)
                  .map((marketId) => ListTile(
                title: Text(marketId),
                onTap: () => Navigator.of(ctx).pop(marketId),
              ))
                  .toList(),
            ),
          );
        },
      );
      if (selectedMarket != null) {
        socketClient.socket.emit('marketSelected', {
          'auctionId': data['auctionId'],
          'marketId': selectedMarket,
        });
      }
    });

    socketClient.socket.on('orderCreated', (data) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order created for market: ${data['marketId']}'))
      );
    });
    socketClient.socket.on('orderError', (data) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order error: ${data['error']}'))
      );
    });
  }

  void _initTimer() {
    if (widget.endTime != null) {
      _setEndTime(widget.endTime!);
    }
  }

  void _setEndTime(String isoEndTime) {
    final end = DateTime.tryParse(isoEndTime);
    if (end != null) {
      _timer?.cancel();
      _updateTimeLeft(end);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimeLeft(end));
    }
  }

  void _updateTimeLeft(DateTime end) {
    final now = DateTime.now().toUtc();
    final remaining = end.difference(now);
    setState(() {
      _timeLeft = remaining.isNegative ? Duration.zero : remaining;
    });
    if (_timeLeft == Duration.zero) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bidController.dispose();
    socketClient.socket.off('joinedAuction');
    socketClient.socket.off('auctionUpdated');
    socketClient.socket.off('bidSuccess');
    socketClient.socket.off('bidError');
    socketClient.socket.off('bidderJoinedAuction');
    socketClient.socket.off('bidderLeftAuction');
    socketClient.socket.disconnect();
    super.dispose();
  }

  num get _highestBid {
    final bidAmounts = bids
        .where((b) => b['type'] != 'join' && b['type'] != 'leave' && b['bidAmount'] != null)
        .map<num>((b) => b['bidAmount'] as num);
    if (bidAmounts.isEmpty) return _startingPrice ?? 0;
    return bidAmounts.reduce((a, b) => a > b ? a : b);
  }

  void _placeBid() {
    final amount = num.tryParse(_bidController.text);
    final highest = _highestBid;

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid bid amount'))
      );
      return;
    }
    if (amount <= highest) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your bid must be higher than the current highest bid (\$$highest)'))
      );
      return;
    }
    socketClient.placeBid(widget.auctionId, widget.bidderId, amount);
  }

  Widget _buildMarketBackgroundImage(String? imagePath, bool isSmallScreen, bool isDarkMode) {
    if (imagePath == null || imagePath.isEmpty || imagePath == 'image_url_here') {
      return Container(
        color: isDarkMode
            ? const Color(0xFF1A2E1A)
            : const Color(0xFFEEF7ED),
        child: Center(
          child: Image.asset(
            'assets/images/vegetable_placeholder.png',
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            fit: BoxFit.contain,
            color: isDarkMode ? Colors.white.withOpacity(0.7) : null,
          ),
        ),
      );
    }

    final String normalizedPath = imagePath.replaceAll('\\', '/');
    final String imageUrl = ApiConstants.getFullImageUrl(normalizedPath);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: isDarkMode
              ? const Color(0xFF1A2E1A)
              : const Color(0xFFEEF7ED),
        ),
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: isDarkMode
                  ? const Color(0xFF1A2E1A)
                  : const Color(0xFFEEF7ED),
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  size: isSmallScreen ? 40 : 50,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                color: isDarkMode
                    ? const Color(0xFF81C784)
                    : const Color(0xFF4CAF50),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: isSmallScreen ? 2.5 : 3.5,
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "--:--:--";
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    final s = duration.inSeconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Live Auction"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder(
        future: Provider.of<FarmCropViewModel>(context, listen: false)
            .fetchCropById(widget.cropId ?? ''),
        builder: (context, snapshot) {
          final crop = Provider.of<FarmCropViewModel>(context, listen: false).selectedCrop;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Crop details card...
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 18),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: isSmallScreen ? 70 : 100,
                          height: isSmallScreen ? 70 : 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _buildMarketBackgroundImage(
                              crop?.picture,
                              isSmallScreen,
                              isDarkMode,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: crop != null
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crop.productName ?? "No Name",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple[800],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Quantity: ${crop.quantity ?? "--"}",
                                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Starting Bid: \$${_startingPrice?.toStringAsFixed(2) ?? '--'}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                              : const Center(child: Text("Loading crop details...")),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.deepPurple[900],
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Time Left: ${_formatDuration(_timeLeft)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_highestBid > (_startingPrice ?? 0))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Current Highest Bid: \$${_highestBid}',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.deepPurple[50],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AnimatedOpacity(
                          opacity: hasJoined ? 1.0 : 0.4,
                          duration: Duration(milliseconds: 500),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _bidController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Enter your bid",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: hasJoined ? _placeBid : null,
                                icon: Icon(Icons.gavel),
                                label: Text("Bid"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Bidding History",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.deepPurple[800],
                      fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: bids.isEmpty
                      ? Center(child: Text("No bids yet. Be the first bidder!"))
                      : ListView.separated(
                    itemCount: bids.length,
                    separatorBuilder: (context, idx) => Divider(),
                    itemBuilder: (context, idx) {
                      final bid = bids[bids.length - 1 - idx];
                      if (bid['type'] == 'join') {
                        final isMe = bid['bidderId'] == widget.bidderId;
                        final joinTime = bid['bidTime'] != null
                            ? DateFormat('HH:mm:ss').format(DateTime.tryParse(bid['bidTime']) ?? DateTime.now())
                            : '--:--';
                        return ListTile(
                          leading: Icon(Icons.login, color: isMe ? Colors.deepPurple : Colors.green),
                          title: Text(
                            isMe ? "You joined the auction" : "${bid['bidderId']} joined the auction",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMe ? Colors.deepPurple : Colors.black,
                            ),
                          ),
                          subtitle: Text("at $joinTime"),
                          tileColor: isMe ? Colors.deepPurple.shade50 : null,
                        );
                      } else if (bid['type'] == 'leave') {
                        final leaveTime = bid['bidTime'] != null
                            ? DateFormat('HH:mm:ss').format(DateTime.tryParse(bid['bidTime']) ?? DateTime.now())
                            : '--:--';
                        return ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text("${bid['bidderId']} left the auction", style: TextStyle(color: Colors.red)),
                          subtitle: Text("at $leaveTime"),
                          tileColor: Colors.red.shade50,
                        );
                      } else {
                        final isMe = bid['bidderId'] == widget.bidderId;
                        final bidTime = bid['bidTime'] != null
                            ? DateFormat('HH:mm:ss').format(DateTime.tryParse(bid['bidTime']) ?? DateTime.now())
                            : '--:--';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isMe ? Colors.deepPurple : Colors.grey[400],
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            isMe ? "You" : (bid['bidderId'] ?? 'Unknown'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMe ? Colors.deepPurple : Colors.black,
                            ),
                          ),
                          subtitle: Text("Bid: \$${bid['bidAmount']}\n$bidTime"),
                          tileColor: isMe ? Colors.deepPurple.shade50 : null,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}