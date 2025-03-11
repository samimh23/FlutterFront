class Farm {
  final String? id;
  final String farmName;
  final String farmLocation;
  final String? farmPhone;
  final String? farmEmail;
  final String? marketImage;
  final List<String>? crops;  // This should be ObjectIDs referencing FarmCrop documents

  // Properties inherited from Markets schema
  final String? marketName;
  final String? marketLocation;
  final String? marketDescription;
  final String? marketCategory;
  final double? marketRating;

  Farm({
    this.id,
    required this.farmName,
    required this.farmLocation,
    this.farmPhone,
    this.farmEmail,
    this.marketImage,
    this.crops,
    this.marketName,
    this.marketLocation,
    this.marketDescription,
    this.marketCategory,
    this.marketRating,
  });



// Other methods remain the same...


  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['_id'] ?? json['id'],
      farmName: json['farmName'],
      farmLocation: json['farmLocation'],
      farmPhone: json['farmPhone'],
      farmEmail: json['farmEmail'],
      marketImage: json['marketImage'],
      crops: json['crops'] != null
          ? List<String>.from(json['crops'])
          : null,
      marketName: json['marketName'],
      marketLocation: json['marketLocation'],
      marketDescription: json['marketDescription'],
      marketCategory: json['marketCategory'],
      marketRating: json['marketRating'] != null
          ? double.parse(json['marketRating'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'farmName': farmName,
      'farmLocation': farmLocation,
    };

    if (id != null) data['_id'] = id;
    if (farmPhone != null) data['farmPhone'] = farmPhone;
    if (farmEmail != null) data['farmEmail'] = farmEmail;
    if (marketImage != null) data['marketImage'] = marketImage;
    if (crops != null) data['crops'] = crops;  // Should be a list of ObjectIDs
    if (marketName != null) data['marketName'] = marketName;
    if (marketLocation != null) data['marketLocation'] = marketLocation;
    if (marketDescription != null) data['marketDescription'] = marketDescription;
    if (marketCategory != null) data['marketCategory'] = marketCategory;
    if (marketRating != null) data['marketRating'] = marketRating;

    return data;
  }
  Farm copyWith({
    String? id,
    String? farmName,
    String? farmLocation,
    String? farmPhone,
    String? farmEmail,
    String? marketImage,
    List<String>? crops,
    String? marketName,
    String? marketLocation,
    String? marketDescription,
    String? marketCategory,
    double? marketRating,
  }) {
    return Farm(
      id: id ?? this.id,
      farmName: farmName ?? this.farmName,
      farmLocation: farmLocation ?? this.farmLocation,
      farmPhone: farmPhone ?? this.farmPhone,
      farmEmail: farmEmail ?? this.farmEmail,
      marketImage: marketImage ?? this.marketImage,
      crops: crops ?? this.crops,
      marketName: marketName ?? this.marketName,
      marketLocation: marketLocation ?? this.marketLocation,
      marketDescription: marketDescription ?? this.marketDescription,
      marketCategory: marketCategory ?? this.marketCategory,
      marketRating: marketRating ?? this.marketRating,
    );
  }
}
