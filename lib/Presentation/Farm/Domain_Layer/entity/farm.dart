class Farm {
  final String? id;
  final String? owner;
  final String farmName;
  final String farmLocation;
  final String? farmPhone;
  final String? farmEmail;
  final String? farmDescription;
  final String? rate;
  final String? farmImage;
  final List<String>? sales;
  final List<String>? crops;

  Farm({
    this.id,
    this.owner,
    required this.farmName,
    required this.farmLocation,
    this.farmPhone,
    this.farmEmail,
    this.farmImage,
    this.sales,
    this.crops,
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
      farmImage: json['farmImage'],
      sales: json['sales'] != null
          ? List<String>.from(json['sales'])
          : null,
      crops: json['crops'] != null
          ? List<String>.from(json['crops'])
          : null,
      farmDescription: json['farmDescription'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson({bool forUpdate = false}) {
    final Map<String, dynamic> data = {
      'farmName': farmName,
      'farmLocation': farmLocation,
    };

    // Only include ID if not for an update operation and if it exists
    if (!forUpdate && id != null && id!.isNotEmpty && id != "null") {
      data['_id'] = id;
    }

    if (owner != null) data['owner'] = owner;
    if (farmPhone != null) data['farmPhone'] = farmPhone;
    if (farmEmail != null) data['farmEmail'] = farmEmail;
    if (farmImage != null) data['farmImage'] = farmImage;
    if (sales != null) data['sales'] = sales;
    if (crops != null) data['crops'] = crops;
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
    String? farmDescription,
    String? rate,
    String? farmImage,
    List<String>? sales,
    List<String>? crops,
  }) {
    return Farm(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      farmName: farmName ?? this.farmName,
      farmLocation: farmLocation ?? this.farmLocation,
      farmPhone: farmPhone ?? this.farmPhone,
      farmEmail: farmEmail ?? this.farmEmail,
      farmDescription: farmDescription ?? this.farmDescription,
      rate: rate ?? this.rate,
      farmImage: farmImage ?? this.farmImage,
      sales: sales ?? this.sales,
      crops: crops ?? this.crops,
    );
  }
}