class Market {
  final String id;
  final String name;
  final String marketLocation;
  final String owner;
  // Add other fields as needed

  Market({
    required this.id,
    required this.name,
    required this.marketLocation,
    required this.owner,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['_id'],
      name: json['name'] ?? 'Unnamed Market',
      marketLocation: json['marketLocation'] ?? 'Unknown Location',
      owner: json['owner'] ?? '',
    );
  }
}