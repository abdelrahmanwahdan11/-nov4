class CarEntity {
  CarEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.powerHp,
    required this.torqueNm,
    required this.zeroTo100,
    required this.rangeKmOrConsumption,
    required this.price,
    required this.imageUrl,
    this.model3DUrl,
    required this.tags,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final int powerHp;
  final int torqueNm;
  final double zeroTo100;
  final num rangeKmOrConsumption;
  final num price;
  final String imageUrl;
  final String? model3DUrl;
  final List<String> tags;
}
