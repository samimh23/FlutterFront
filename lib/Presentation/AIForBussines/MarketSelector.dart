import 'package:flutter/material.dart';
import 'market.dart';

class MarketSelector extends StatelessWidget {
  final List<String> markets;
  final List<Market>? userMarkets;
  final String? selectedMarketId;
  final Function(String?) onMarketSelected;
  final bool isLoading;

  const MarketSelector({
    Key? key,
    required this.markets,
    this.userMarkets,
    this.selectedMarketId,
    required this.onMarketSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Markets',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading && (userMarkets == null || userMarkets!.isEmpty))
              const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Loading your markets...'),
                  )
              )
            else if (userMarkets == null || userMarkets!.isEmpty)
              const Text('No markets available')
            else
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: 'Select Market',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedMarketId,
                      hint: const Text('All My Markets'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All My Markets'),
                        ),
                        ...userMarkets!.map((market) {
                          return DropdownMenuItem<String?>(
                            value: market.id,
                            child: Text('${market.name} (${market.marketLocation})'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        onMarketSelected(value);
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}