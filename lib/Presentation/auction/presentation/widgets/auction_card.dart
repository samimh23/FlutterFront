import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';

class AuctionCard extends StatelessWidget {
  final Auction auction;
  final VoidCallback onTap;

  const AuctionCard({
    Key? key,
    required this.auction,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.gavel, color: Colors.amber, size: 36),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction.description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.deepPurple[900],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start: ${auction.startTime.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                    Text(
                      'End: ${auction.endTime.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            auction.status.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          backgroundColor: auction.status.toString().contains("active")
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${auction.startingPrice}',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      shadows: [
                        Shadow(
                          color: Colors.deepPurple.shade100,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(Icons.arrow_forward, color: Colors.deepPurple, size: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}