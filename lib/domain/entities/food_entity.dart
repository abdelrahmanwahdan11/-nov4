class FoodEntity {
  FoodEntity({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.grams,
    required this.kcal,
    required this.price,
    required this.imageUrl,
    required this.tags,
    required this.isVegan,
    required this.isNew,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final double grams;
  final double kcal;
  final double price;
  final String imageUrl;
  final List<String> tags;
  final bool isVegan;
  final bool isNew;
}
