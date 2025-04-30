class Farm {
  final String? id;
  final String? owner;
  final String farmName;
  final String farmLocation;
  final String? farmPhone;
  final String? farmEmail;
  final String? farmDescription;
  final double? rate;
  final String? marketImage;
  final List<String>? sale;


  Farm({
    this.id,
     this.owner,
    required this.farmName,
    required this.farmLocation,
    this.farmPhone,
    this.farmEmail,
    this.marketImage,
    this.sale,  // Updated from crops to sale
    this.rate,
    this.farmDescription,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['_id'] ?? json['id'],
      owner: json['owner'],
      farmName: json['farmName'],
      farmLocation: json['farmLocation'],
      farmPhone: json['farmPhone'],
      farmEmail: json['farmEmail'],
      marketImage: json['marketImage'],
      sale: json['Sale'] != null
          ? List<String>.from(json['Sale'])
          : null,  // Updated from crops to Sale
      farmDescription: json['farmDescription'],
      rate: json['rate'] != null
          ? double.parse(json['rate'].toString())
          : null,
    );
  }

  @override
  String toString() {
    return 'Farm{id: $id, farmName: $farmName, farmLocation: $farmLocation, farmPhone: $farmPhone}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'farmName': farmName,
      'farmLocation': farmLocation,
    };
    if (id != null && id != "null") data['_id'] = id;
    if(owner != null) data['owner']=owner;
    if (farmPhone != null) data['farmPhone'] = farmPhone;
    if (farmEmail != null) data['farmEmail'] = farmEmail;
    if (marketImage != null) data['marketImage'] = marketImage;
    if (sale != null) data['sale'] = sale;  // Updated from crops to Sale
    if (farmDescription != null) data['farmDescription'] = farmDescription;
    if (rate != null) data['rate'] = rate;

    return data;
  }

  Farm copyWith({
    String? id,
    String? owner,
    String? farmName,
    String? farmLocation,
    String? farmPhone,
    String? farmEmail,
    String? marketImage,
    List<String>? sale,
    String? farmDescription,
    double? rate,
  }) {
    return Farm(
      id: id ?? this.id,
      owner: owner?? this.owner,
      farmName: farmName ?? this.farmName,
      farmLocation: farmLocation ?? this.farmLocation,
      farmPhone: farmPhone ?? this.farmPhone,
      farmEmail: farmEmail ?? this.farmEmail,
      marketImage: marketImage ?? this.marketImage,
      sale: sale ?? this.sale,  // Updated from crops to sale
      farmDescription: farmDescription ?? this.farmDescription,
      rate: rate ?? this.rate,
    );
  }
}