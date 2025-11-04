import '../models/car_item.dart';
import '../models/food_item.dart';

class SearchHit<T> {
  SearchHit({required this.item, required this.matchText});

  final T item;
  final String matchText;
}

class ParsedQuery {
  ParsedQuery({required this.text, required this.filters, required this.highlightTerms});

  final String text;
  final Map<String, dynamic> filters;
  final List<String> highlightTerms;
}

class SearchService {
  SearchService({required List<FoodItem> foods, required List<CarItem> cars})
      : _foodsIndex = foods,
        _carsIndex = cars;

  final List<FoodItem> _foodsIndex;
  final List<CarItem> _carsIndex;

  static final RegExp _tokenizer = RegExp(r'"[^"\\]+"|[^\s]+');
  static const List<String> _arabicDiacritics = [
    '\u0610',
    '\u0611',
    '\u0612',
    '\u0613',
    '\u0614',
    '\u0615',
    '\u0616',
    '\u0617',
    '\u0618',
    '\u0619',
    '\u061A',
    '\u064B',
    '\u064C',
    '\u064D',
    '\u064E',
    '\u064F',
    '\u0650',
    '\u0651',
    '\u0652',
    '\u0653',
    '\u0654',
    '\u0655',
  ];

  static ParsedQuery parse(String raw) {
    if (raw.trim().isEmpty) {
      return ParsedQuery(text: '', filters: const {}, highlightTerms: const []);
    }

    final filters = <String, dynamic>{};
    final searchTokens = <String>[];

    for (final match in _tokenizer.allMatches(raw)) {
      final token = match.group(0)!;
      final unquoted = _stripQuotes(token).trim();
      if (unquoted.isEmpty) {
        continue;
      }
      final normalized = unquoted.toLowerCase();
      if (_tryParseRangeFilter(normalized, filters, key: 'price')) {
        continue;
      }
      if (_tryParseRangeFilter(normalized, filters, key: 'kcal')) {
        continue;
      }
      if (_tryParseRangeFilter(normalized, filters, key: 'grams')) {
        continue;
      }
      if (_tryParseRangeFilter(normalized, filters, key: 'power')) {
        continue;
      }
      if (_tryParseRangeFilter(normalized, filters, key: 'torque')) {
        continue;
      }
      if (_tryParseRangeFilter(normalized, filters, key: 'range')) {
        continue;
      }
      if (normalized.startsWith('vegan:')) {
        filters['vegan'] = normalized.endsWith('false') ? false : true;
        continue;
      }
      if (normalized.startsWith('new:') || normalized.startsWith('newitem:')) {
        filters['isNew'] = normalized.endsWith('true');
        continue;
      }
      if (normalized.startsWith('tag:')) {
        final tagValue = unquoted.substring(unquoted.indexOf(':') + 1).trim();
        if (tagValue.isNotEmpty) {
          final tags = filters.putIfAbsent('tags', () => <String>{}) as Set<String>;
          tags.add(tagValue.toLowerCase());
        }
        continue;
      }
      searchTokens.add(unquoted);
    }

    final text = searchTokens.join(' ').trim();
    return ParsedQuery(text: text, filters: filters, highlightTerms: searchTokens);
  }

  static String normalize(String input) {
    var result = input.toLowerCase();
    for (final mark in _arabicDiacritics) {
      result = result.replaceAll(RegExp(mark), '');
    }
    return result;
  }

  static Iterable<String> tokenize(String text) {
    return text
        .split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty);
  }

  static bool containsAllTokens(Iterable<String> fields, Iterable<String> tokens) {
    if (tokens.isEmpty) {
      return true;
    }
    final normalizedFields = fields.map(normalize).toList();
    for (final token in tokens) {
      final normalizedToken = normalize(token);
      if (normalizedToken.isEmpty) {
        continue;
      }
      final hasMatch = normalizedFields.any((field) => field.contains(normalizedToken));
      if (!hasMatch) {
        return false;
      }
    }
    return true;
  }

  static bool _tryParseRangeFilter(String normalizedToken, Map<String, dynamic> filters, {required String key}) {
    final match = RegExp('^$key:(<=|>=|<|>|=)?([0-9]+(?:\\.[0-9]+)?)').firstMatch(normalizedToken);
    if (match == null) {
      return false;
    }
    final operator = match.group(1) ?? '=';
    final value = double.tryParse(match.group(2)!);
    if (value == null) {
      return false;
    }

    String minKey;
    String maxKey;
    switch (key) {
      case 'price':
        minKey = 'minPrice';
        maxKey = 'maxPrice';
        break;
      case 'kcal':
        minKey = 'minKcal';
        maxKey = 'maxKcal';
        break;
      case 'grams':
        minKey = 'minGrams';
        maxKey = 'maxGrams';
        break;
      case 'power':
        minKey = 'minPower';
        maxKey = 'maxPower';
        break;
      case 'torque':
        minKey = 'minTorque';
        maxKey = 'maxTorque';
        break;
      case 'range':
        minKey = 'minRange';
        maxKey = 'maxRange';
        break;
      default:
        minKey = 'min$key';
        maxKey = 'max$key';
    }

    switch (operator) {
      case '<':
      case '<=':
        final current = filters[maxKey] as double?;
        filters[maxKey] = current == null ? value : value < current ? value : current;
        break;
      case '>':
      case '>=':
        final current = filters[minKey] as double?;
        filters[minKey] = current == null ? value : value > current ? value : current;
        break;
      default:
        filters[minKey] = value;
        filters[maxKey] = value;
    }
    return true;
  }

  static String _stripQuotes(String token) {
    if (token.length >= 2 && token.startsWith('"') && token.endsWith('"')) {
      return token.substring(1, token.length - 1);
    }
    return token;
  }

  List<SearchHit<dynamic>> query(String text) {
    final parsed = parse(text);
    final searchTokens = tokenize(parsed.text).toList();
    final results = <SearchHit<dynamic>>[];

    for (final food in _foodsIndex) {
      if (containsAllTokens([
        food.titleEn,
        food.titleAr,
        food.descEn,
        food.descAr,
        food.tags.join(' '),
      ], searchTokens)) {
        results.add(SearchHit(item: food, matchText: food.titleEn));
      }
    }

    for (final car in _carsIndex) {
      if (containsAllTokens([
        car.nameEn,
        car.nameAr,
        car.tags.join(' '),
      ], searchTokens)) {
        results.add(SearchHit(item: car, matchText: car.nameEn));
      }
    }

    return results.take(20).toList(growable: false);
  }
}
