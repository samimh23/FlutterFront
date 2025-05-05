import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/domain/entity/bid.dart'; // Import your Bid model
import 'package:provider/provider.dart';
import 'package:hanouty/Presentation/auction/presentation/provider/auction_provider.dart';

class AuctionDetailsScreen extends StatelessWidget {
  final Auction auction;
  const AuctionDetailsScreen({Key? key, required this.auction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auction Details'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Auction ID',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: auction.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auction ID copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Bid>>(
        future: auctionProvider.fetchBiddersByAuctionId(auction.id),
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auction.description,
                        style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.deepPurple[800]),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text('Start: ${auction.startTime}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text('End: ${auction.endTime}'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.flag, size: 16, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Text(
                            'Status: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            auction.status.toString().split('.').last,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: auction.status.toString().contains('active')
                                  ? Colors.green
                                  : Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          text: "Starting Price: ",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "\$${auction.startingPrice}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Bidders:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Failed to load bidders"),
                )
              else if (!snapshot.hasData || snapshot.data!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "No bidders yet.",
                      style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  ...snapshot.data!
                      .asMap()
                      .entries
                      .map(
                        (entry) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: Colors.deepPurple.shade50,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple[200],
                          child: Icon(Icons.person, color: Colors.deepPurple[900]),
                        ),
                        title: Text(
                          "Bidder #${entry.key + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Bid Amount: \$${entry.value.bidAmount}"), // Show the bid amount!
                      ),
                    ),
                  )
                      .toList(),
            ],
          );
        },
      ),
    );
  }
}