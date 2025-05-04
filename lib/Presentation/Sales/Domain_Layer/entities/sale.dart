class Sale {
  final String id;
  final String farmCropId;
  final String farmMarketId;
  final double quantity;
  final double quantityMin;
  final double pricePerUnit;
  final DateTime createdDate;
  String? notes;

  Sale({
    required this.id,
    required this.farmCropId,
    required this.farmMarketId,
    required this.quantity,
    required this.quantityMin,
    required this.pricePerUnit,
    required this.createdDate,
    this.notes,
  });

  /// Create a copy of this Sale with modified values
  Sale copyWith({
    String? id,
    String? farmCropId,
    String? farmMarketId,
    double? quantity,
    double? quantityMin,
    double? pricePerUnit,
    DateTime? createdDate,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      farmCropId: farmCropId ?? this.farmCropId,
      farmMarketId: farmMarketId ?? this.farmMarketId,
      quantity: quantity ?? this.quantity,
      quantityMin: quantityMin ?? this.quantityMin,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      createdDate: createdDate ?? this.createdDate,
      notes: notes ?? this.notes,
    );
  }

  /// Convert Sale instance to JSON
  Map<String, dynamic> toJson({bool isCreateRequest = false}) {
    final data = {
      'farmCropId': farmCropId,
      'farmMarketId': farmMarketId,
      'quantity': quantity,
      'quantityMin': quantityMin,
      'pricePerUnit': pricePerUnit,
      'createdDate': createdDate.toIso8601String(),
    };

    // Include id only if it's not a create request
    if (!isCreateRequest && id.isNotEmpty) {
      data['_id'] = id; // Use '_id' to match the API's expected format
    }

    // Include optional fields
    if (notes != null) {
      data['notes'] = notes as Object;
    }

    return data;
  }

  // Create Sale instance from JSON
  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['_id']?.toString() ?? '',
      farmCropId: json['farmCropId']?.toString() ?? '',
      farmMarketId: json['farmMarketId']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      quantityMin: (json['quantityMin'] as num?)?.toDouble() ?? 0.0,
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }
}