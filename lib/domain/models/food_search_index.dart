import 'food_item.dart';

class FoodSearchIndexResult {
  FoodSearchIndexResult({
    required this.itemId,
    required this.matchedFields,
    required this.matchedTags,
    required this.score,
  });

  final String itemId;
  final Set<String> matchedFields;
  final Set<String> matchedTags;
  final double score;
}

class FoodSearchIndex {
  FoodSearchIndex._(this._tokenMap, this._tokenFrequency, this._tokenDisplayValues);

  final Map<String, List<_IndexEntry>> _tokenMap;
  final Map<String, int> _tokenFrequency;
  final Map<String, Set<String>> _tokenDisplayValues;

  static final RegExp _tokenPattern = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  factory FoodSearchIndex.build(List<FoodItem> items) {
    final map = <String, List<_IndexEntry>>{};
    final frequency = <String, int>{};
    final displayValues = <String, Set<String>>{};

    for (final item in items) {
      void registerField(String field, String value) {
        final seenTokens = <String>{};
        final tokens = _tokenize(value);
        for (final token in tokens) {
          final normalized = _normalize(token);
          if (normalized.isEmpty || !seenTokens.add(normalized)) {
            continue;
          }
          map.putIfAbsent(normalized, () => <_IndexEntry>[]).add(
                _IndexEntry(
                  itemId: item.id,
                  field: field,
                  value: value,
                ),
              );
          frequency[normalized] = (frequency[normalized] ?? 0) + 1;
          displayValues.putIfAbsent(normalized, () => <String>{}).add(value);
        }
      }

      registerField('name', item.name);
      registerField('description', item.description);
      registerField('kcal', item.kcal.toString());
      registerField('price', item.defaultSize.priceFor(item).toStringAsFixed(2));
      for (final tag in item.tags) {
        registerField('tags', tag);
      }
    }

    return FoodSearchIndex._(map, frequency, displayValues);
  }

  List<FoodSearchIndexResult> search(String rawQuery) {
    final tokens = _tokenize(rawQuery).toSet().toList();
    if (tokens.isEmpty) {
      return <FoodSearchIndexResult>[];
    }
    final Map<String, _ResultAccumulator> results = <String, _ResultAccumulator>{};
    for (final token in tokens) {
      final normalized = _normalize(token);
      if (normalized.isEmpty) {
        continue;
      }
      final candidates = _matchingEntries(normalized);
      for (final entry in candidates) {
        final accumulator = results.putIfAbsent(entry.itemId, _ResultAccumulator.new);
        accumulator.fields.add(entry.field);
        if (entry.field == 'tags') {
          accumulator.tags.add(entry.value);
        }
        final tokenWeight = entry.token == normalized
            ? 2.0
            : entry.token.startsWith(normalized)
                ? 1.5
                : 1.0;
        double fieldWeight = 1.0;
        if (entry.field == 'name') {
          fieldWeight = 2.0;
        } else if (entry.field == 'description') {
          fieldWeight = 1.2;
        }
        accumulator.score += tokenWeight * fieldWeight;
      }
    }

    return results.entries
        .map(
          (entry) => FoodSearchIndexResult(
            itemId: entry.key,
            matchedFields: entry.value.fields,
            matchedTags: entry.value.tags,
            score: entry.value.score,
          ),
        )
        .toList()
      ..sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return a.itemId.compareTo(b.itemId);
      });
  }

  List<String> suggestions(String rawQuery, {int limit = 6}) {
    final normalized = _normalize(rawQuery);
    List<MapEntry<String, int>> entries;
    if (normalized.isEmpty) {
      entries = _tokenFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    } else {
      entries = _tokenFrequency.entries
          .where((entry) => entry.key.startsWith(normalized))
          .toList();
      if (entries.isEmpty) {
        entries = _tokenFrequency.entries
            .where((entry) => entry.key.contains(normalized))
            .toList();
      }
      entries.sort((a, b) {
        final frequencyCompare = b.value.compareTo(a.value);
        if (frequencyCompare != 0) {
          return frequencyCompare;
        }
        return a.key.compareTo(b.key);
      });
    }
    final suggestions = <String>[];
    for (final entry in entries) {
      final display = _tokenDisplayValues[entry.key];
      if (display == null || display.isEmpty) {
        continue;
      }
      final value = display.first;
      if (!suggestions.contains(value)) {
        suggestions.add(value);
      }
      if (suggestions.length >= limit) {
        break;
      }
    }
    return suggestions;
  }

  Iterable<_IndexEntry> _matchingEntries(String normalizedToken) sync* {
    final directMatches = _tokenMap[normalizedToken];
    if (directMatches != null) {
      for (final entry in directMatches) {
        yield entry.copyWith(token: normalizedToken);
      }
    }
    for (final token in _tokenMap.keys) {
      if (token == normalizedToken) {
        continue;
      }
      if (token.contains(normalizedToken)) {
        final entries = _tokenMap[token];
        if (entries == null) {
          continue;
        }
        for (final entry in entries) {
          yield entry.copyWith(token: token);
        }
      }
    }
  }

  static Iterable<String> _tokenize(String value) {
    return _tokenPattern
        .allMatches(value.toLowerCase())
        .map((match) => match.group(0) ?? '')
        .where((token) => token.isNotEmpty);
  }

  static String _normalize(String token) => token.toLowerCase().trim();
}

class _IndexEntry {
  const _IndexEntry({
    required this.itemId,
    required this.field,
    required this.value,
    this.token,
  });

  final String itemId;
  final String field;
  final String value;
  final String? token;

  _IndexEntry copyWith({String? token}) {
    return _IndexEntry(
      itemId: itemId,
      field: field,
      value: value,
      token: token ?? this.token,
    );
  }
}

class _ResultAccumulator {
  _ResultAccumulator()
      : fields = <String>{},
        tags = <String>{},
        score = 0;

  final Set<String> fields;
  final Set<String> tags;
  double score;
}
