

class Sale {
  final String id;
  final String farmCropId;
  final double quantity;
  final double quantityMin;
  final double pricePerUnit;
  final DateTime createdDate;
  String? notes;

  Sale({
    required this.id,
    required this.farmCropId,
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
    double? quantity,
    double? quantityMin,
    double? pricePerUnit,
    DateTime? createdDate,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      farmCropId: farmCropId ?? this.farmCropId,
      quantity: quantity ?? this.quantity,
      quantityMin: quantity ?? this.quantityMin,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      createdDate: createdDate ?? this.createdDate,
      notes: notes ?? this.notes,
    );
  }

  /// Convert Sale instance to JSON
  Map<String, dynamic> toJson({bool isCreateRequest = false}) {
    final data = {
      'farmCropId': farmCropId,
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
      id: json['_id']?.toString() ?? '', // Handle potential null with null-safe operator and provide default
      farmCropId: json['farmCropId']?.toString() ?? '', // Handle potential null
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0, // Handle potential null
      quantityMin: (json['quantityMin'] as num?)?.toDouble() ?? 0.0, // Handle potential null
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0.0, // Handle potential null
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'] as String)
          : DateTime.now(), // Provide default value if null
      notes: json['notes'] as String?, // Already handling null
    );
  }
}


