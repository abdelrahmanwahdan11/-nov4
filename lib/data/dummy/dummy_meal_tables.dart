import '../../domain/models/meal_table.dart';

const List<MealTable> dummyMealTables = <MealTable>[
  MealTable(
    id: 'table-1',
    country: 'Morocco',
    mealType: 'Breakfast',
    region: 'North Africa',
    imageUrl:
        'https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=1200&q=80',
    description:
        'A warm sunrise spread with msemen, amlou, and honey served with fresh mint tea.',
    highlights: <String>[
      'Msemen with honey',
      'Amlou almond dip',
      'Boiled eggs with cumin',
    ],
    stats: <String, String>{
      'calories': 'Approx. 520 kcal',
      'main_protein': 'Eggs & almonds',
      'spice_level': 'Fragrant mild',
      'signature_drink': 'Mint tea',
      'sweet_finish': 'Orange blossom jam',
    },
  ),
  MealTable(
    id: 'table-2',
    country: 'Bahrain',
    mealType: 'Breakfast',
    region: 'Gulf',
    imageUrl:
        'https://images.unsplash.com/photo-1525755662778-4d4ebc23f8a0?auto=format&fit=crop&w=1200&q=80',
    description:
        'Hearty balaleet, chebab, and foul medames paired with karak chai for a comforting start.',
    highlights: <String>[
      'Balaleet saffron noodles',
      'Chebab date pancakes',
      'Foul medames with tahini',
    ],
    stats: <String, String>{
      'calories': 'Approx. 610 kcal',
      'main_protein': 'Fava beans & eggs',
      'spice_level': 'Warm spices',
      'signature_drink': 'Karak chai',
      'sweet_finish': 'Silan date syrup',
    },
  ),
  MealTable(
    id: 'table-3',
    country: 'Syria',
    mealType: 'Lunch',
    region: 'Levant',
    imageUrl:
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80',
    description:
        'A vibrant mezze lunch with kibbeh, fattoush, and grilled lamb served family style.',
    highlights: <String>[
      'Kibbeh bil saniyeh',
      'Fattoush salad',
      'Grilled lamb skewers',
    ],
    stats: <String, String>{
      'calories': 'Approx. 840 kcal',
      'main_protein': 'Lamb & bulgur',
      'spice_level': 'Sumac bright',
      'signature_drink': 'Ayran yogurt',
      'sweet_finish': 'Baklava triangles',
    },
  ),
  MealTable(
    id: 'table-4',
    country: 'Qatar',
    mealType: 'Dinner',
    region: 'Gulf',
    imageUrl:
        'https://images.unsplash.com/photo-1543352634-873f17a7a088?auto=format&fit=crop&w=1200&q=80',
    description:
        'Evening majboos feast with slow-cooked lamb, spiced rice, and saffron desserts.',
    highlights: <String>[
      'Lamb majboos',
      'Rosewater salad',
      'Luqaimat with date syrup',
    ],
    stats: <String, String>{
      'calories': 'Approx. 980 kcal',
      'main_protein': 'Slow-cooked lamb',
      'spice_level': 'Cardamom rich',
      'signature_drink': 'Saffron tea',
      'sweet_finish': 'Luqaimat doughnuts',
    },
  ),
  MealTable(
    id: 'table-5',
    country: 'Lebanon',
    mealType: 'Dinner',
    region: 'Levant',
    imageUrl:
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
    description:
        'Garden terrace dinner of grilled halloumi, tabbouleh, and sumac roasted chicken.',
    highlights: <String>[
      'Sumac roasted chicken',
      'Grilled halloumi',
      'Tabbouleh with fresh mint',
    ],
    stats: <String, String>{
      'calories': 'Approx. 760 kcal',
      'main_protein': 'Chicken & halloumi',
      'spice_level': 'Zesty herbal',
      'signature_drink': 'Jallab',
      'sweet_finish': 'Namoura semolina cake',
    },
  ),
  MealTable(
    id: 'table-6',
    country: 'Egypt',
    mealType: 'Lunch',
    region: 'North Africa',
    imageUrl:
        'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=1200&q=80',
    description:
        'Street-food inspired table featuring koshari, taameya, and pickled vegetables.',
    highlights: <String>[
      'Koshari layered bowl',
      'Taameya falafel',
      'Pickled turnips & carrots',
    ],
    stats: <String, String>{
      'calories': 'Approx. 690 kcal',
      'main_protein': 'Lentils & chickpeas',
      'spice_level': 'Garlic chili kick',
      'signature_drink': 'Hibiscus karkadeh',
      'sweet_finish': 'Basbousa squares',
    },
  ),
  MealTable(
    id: 'table-7',
    country: 'Saudi Arabia',
    mealType: 'Breakfast',
    region: 'Gulf',
    imageUrl:
        'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=1200&q=80',
    description:
        'Sunrise spread with aseeda, dates, and labneh alongside aromatic qahwa.',
    highlights: <String>[
      'Aseeda porridge',
      'Dates & nuts platter',
      'Labneh with zaatar oil',
    ],
    stats: <String, String>{
      'calories': 'Approx. 580 kcal',
      'main_protein': 'Labneh & nuts',
      'spice_level': 'Cardamom gentle',
      'signature_drink': 'Arabian qahwa',
      'sweet_finish': 'Date molasses dip',
    },
  ),
  MealTable(
    id: 'table-8',
    country: 'Oman',
    mealType: 'Dinner',
    region: 'Gulf',
    imageUrl:
        'https://images.unsplash.com/photo-1528716321680-815a8cdb8cbe?auto=format&fit=crop&w=1200&q=80',
    description:
        'Coastal dinner with shuwa, spiced rice, and coconut halwa served al fresco.',
    highlights: <String>[
      'Shuwa slow-roasted lamb',
      'Saffron coconut rice',
      'Omani halwa',
    ],
    stats: <String, String>{
      'calories': 'Approx. 920 kcal',
      'main_protein': 'Lamb & nuts',
      'spice_level': 'Smoked & earthy',
      'signature_drink': 'Laban',
      'sweet_finish': 'Coconut halwa',
    },
  ),
];
