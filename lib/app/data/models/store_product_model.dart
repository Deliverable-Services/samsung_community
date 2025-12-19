/// Store Product Model based on Supabase schema

class StoreProductModel {
  final String id;
  final String name;
  final String? description;
  final String? descriptionVideoUrl;
  final int costPoints;
  final int quantityInStock;
  final String? imageUrl;
  final bool isAvailable;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreProductModel({
    required this.id,
    required this.name,
    this.description,
    this.descriptionVideoUrl,
    required this.costPoints,
    required this.quantityInStock,
    this.imageUrl,
    required this.isAvailable,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'description_video_url': descriptionVideoUrl,
      'cost_points': costPoints,
      'quantity_in_stock': quantityInStock,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StoreProductModel.fromJson(Map<String, dynamic> json) {
    return StoreProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      descriptionVideoUrl: json['description_video_url'] as String?,
      costPoints: json['cost_points'] as int,
      quantityInStock: json['quantity_in_stock'] as int,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  StoreProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? descriptionVideoUrl,
    int? costPoints,
    int? quantityInStock,
    String? imageUrl,
    bool? isAvailable,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      descriptionVideoUrl: descriptionVideoUrl ?? this.descriptionVideoUrl,
      costPoints: costPoints ?? this.costPoints,
      quantityInStock: quantityInStock ?? this.quantityInStock,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

