import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/presentation/pages/auction_details_screen.dart';
import 'package:hanouty/Presentation/auction/presentation/provider/auction_provider.dart';
import 'package:hanouty/Presentation/auction/presentation/widgets/auction_card.dart';
import 'package:provider/provider.dart';

class FarmerAuctionsScreen extends StatefulWidget {
  const FarmerAuctionsScreen({Key? key}) : super(key: key);

  @override
  State<FarmerAuctionsScreen> createState() => _FarmerAuctionsScreenState();
}

class _FarmerAuctionsScreenState extends State<FarmerAuctionsScreen> {
  late Future<List<Auction>> _futureAuctions;
  String? farmerId;

  @override
  void initState() {
    super.initState();
    _loadFarmerAuctions();
  }

  Future<void> _loadFarmerAuctions() async {
    final secureStorageService = SecureStorageService();
    final id = await secureStorageService.getUserId();
    setState(() {
      farmerId = id;
      if (farmerId != null) {
        _futureAuctions = Provider.of<AuctionProvider>(context, listen: false)
            .fetchAuctionsByFarmerId(farmerId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Auctions"),
        backgroundColor: Colors.deepPurple,
      ),
      body: farmerId == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await auctionProvider.fetchAuctionsByFarmerId(farmerId!);
          setState(() {
            _futureAuctions = auctionProvider.fetchAuctionsByFarmerId(farmerId!);
          });
        },
        child: FutureBuilder<List<Auction>>(
          future: _futureAuctions,
          builder: (context, snapshot) {
            if (auctionProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || auctionProvider.errorMessage.isNotEmpty) {
              return Center(child: Text("Error: ${auctionProvider.errorMessage}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No auctions found."));
            }
            final auctions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: auctions.length,
              itemBuilder: (context, index) {
                final auction = auctions[index];
                return AuctionCard(
                  auction: auction,
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AuctionDetailsScreen(auction: auction),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}