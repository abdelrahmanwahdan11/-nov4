import '../../domain/entities/car_entity.dart';

class CarItem extends CarEntity {
  CarItem({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.powerHp,
    required super.torqueNm,
    required super.zeroTo100,
    required super.rangeKmOrConsumption,
    required super.price,
    required super.imageUrl,
    super.model3DUrl,
    required super.tags,
  });

  factory CarItem.fromJson(Map<String, dynamic> json) {
    return CarItem(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      powerHp: (json['powerHp'] as num).toInt(),
      torqueNm: (json['torqueNm'] as num).toInt(),
      zeroTo100: (json['zeroTo100'] as num).toDouble(),
      rangeKmOrConsumption: json['rangeKmOrConsumption'] as num,
      price: json['price'] as num,
      imageUrl: json['imageUrl'] as String,
      model3DUrl: json['model3DUrl'] as String?,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'powerHp': powerHp,
        'torqueNm': torqueNm,
        'zeroTo100': zeroTo100,
        'rangeKmOrConsumption': rangeKmOrConsumption,
        'price': price,
        'imageUrl': imageUrl,
        'model3DUrl': model3DUrl,
        'tags': tags,
      };
}
