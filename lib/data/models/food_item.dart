import '../../domain/entities/food_entity.dart';

class FoodItem extends FoodEntity {
  FoodItem({
    required super.id,
    required super.titleAr,
    required super.titleEn,
    required super.descAr,
    required super.descEn,
    required super.grams,
    required super.kcal,
    required super.price,
    required super.imageUrl,
    required super.tags,
    required super.isVegan,
    required super.isNew,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      titleAr: json['titleAr'] as String,
      titleEn: json['titleEn'] as String,
      descAr: json['descAr'] as String,
      descEn: json['descEn'] as String,
      grams: (json['grams'] as num).toDouble(),
      kcal: (json['kcal'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      isVegan: json['isVegan'] as bool,
      isNew: json['isNew'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'descAr': descAr,
        'descEn': descEn,
        'grams': grams,
        'kcal': kcal,
        'price': price,
        'imageUrl': imageUrl,
        'tags': tags,
        'isVegan': isVegan,
        'isNew': isNew,
      };
}
