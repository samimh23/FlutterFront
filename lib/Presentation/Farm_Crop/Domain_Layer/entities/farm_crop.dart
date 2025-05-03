// Domain_Layer/entities/farm_crop.dart
import 'package:equatable/equatable.dart';

enum AuditStatus {
  confirmed,
  pending,
  rejected
}

class Expense extends Equatable {
  final String id;
  final String description;
  final double value;
  final DateTime date;

  const Expense({
    required this.id,
    required this.description,
    required this.value,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      description: json['description'] as String,
      value: (json['value'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'date': date.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, description, value, date];
}

class FarmCrop extends Equatable {
  final String? id;
  final String farmMarketId;
  final String productName;
  final String type;
  final DateTime implantDate;
  final DateTime? harvestedDay;
  final List<Expense> expenses;
  final int? quantity;
  final String? auditStatus;
  final String? auditReport;
  final String? auditProofImage;
  final String? picture;

  const FarmCrop({
    this.id,
    required this.farmMarketId,
    required this.productName,
    required this.type,
    required this.implantDate,
    this.harvestedDay,
    this.expenses = const [],
    this.quantity,
    this.auditStatus,
    this.auditReport,
    this.auditProofImage,
    this.picture,
  });

  // Convert AuditStatus enum to string value for API
  static String? auditStatusToString(AuditStatus? status) {
    if (status == null) return null;

    switch (status) {
      case AuditStatus.confirmed:
        return 'confirmed';
      case AuditStatus.pending:
        return 'pending';
      case AuditStatus.rejected:
        return 'rejected';
      default:
        return 'pending';
    }
  }

  // Convert string value from API to AuditStatus enum
  static AuditStatus? stringToAuditStatus(String? status) {
    if (status == null) return null;

    switch (status.toLowerCase()) {
      case 'confirmed':
        return AuditStatus.confirmed;
      case 'pending':
        return AuditStatus.pending;
      case 'rejected':
        return AuditStatus.rejected;
      default:
        return AuditStatus.pending;
    }
  }

  factory FarmCrop.fromJson(Map<String, dynamic> json) {
    return FarmCrop(
      id: json['_id'] as String? ?? json['id'] as String?,
      farmMarketId: json['farmMarketId'] as String,
      productName: json['productName'] as String,
      type: json['type'] as String,
      implantDate: DateTime.parse(json['implantDate'] as String),
      harvestedDay: json['harvestedDay'] != null ? DateTime.parse(json['harvestedDay'] as String) : null,
      expenses: (json['expenses'] as List<dynamic>?)
          ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      quantity: json['quantity'] as int?,
      auditStatus: json['auditStatus'] as String?,
      auditReport: json['auditReport'] as String?,
      auditProofImage: json['auditProofImage'] as String?,
      picture: json['picture'] as String?,
    );
  }

  Map<String, dynamic> toJson({bool forUpdate = false}) {
    final Map<String, dynamic> data = {
      'farmMarketId': farmMarketId,
      'productName': productName,
      'type': type,
      'implantDate': implantDate.toIso8601String(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
    };

    if (!forUpdate && id != null && id!.isNotEmpty) {
      data['_id'] = id;
    }

    if (harvestedDay != null) {
      data['harvestedDay'] = harvestedDay!.toIso8601String();
    }
    if (quantity != null) {
      data['quantity'] = quantity;
    }
    if (auditStatus != null) {
      data['auditStatus'] = auditStatus;
    }
    if (auditReport != null) {
      data['auditReport'] = auditReport;
    }
    if (auditProofImage != null) {
      data['auditProofImage'] = auditProofImage;
    }
    if (picture != null) {
      data['picture'] = picture;
    }

    return data;
  }

  FarmCrop copyWith({
    String? id,
    String? farmMarketId,
    String? productName,
    String? type,
    DateTime? implantDate,
    DateTime? harvestedDay,
    List<Expense>? expenses,
    int? quantity,
    String? auditStatus,
    String? auditReport,
    String? auditProofImage,
    String? picture,
  }) {
    return FarmCrop(
      id: id ?? this.id,
      farmMarketId: farmMarketId ?? this.farmMarketId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      implantDate: implantDate ?? this.implantDate,
      harvestedDay: harvestedDay ?? this.harvestedDay,
      expenses: expenses ?? this.expenses,
      quantity: quantity ?? this.quantity,
      auditStatus: auditStatus ?? this.auditStatus,
      auditReport: auditReport ?? this.auditReport,
      auditProofImage: auditProofImage ?? this.auditProofImage,
      picture: picture ?? this.picture,
    );
  }

  @override
  List<Object?> get props => [
    id,
    farmMarketId,
    productName,
    type,
    implantDate,
    harvestedDay,
    expenses,
    quantity,
    auditStatus,
    auditReport,
    auditProofImage,
    picture
  ];
}