
class Histogram {

  final value = <String,int>{};

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
  int get length => value.length;
  Iterable<String> get keys => value.keys;

  void add(String symbol) {
    value.putIfAbsent(symbol, () => 0);
    value[symbol] = value[symbol]! + 1;
  }

  List<String> keysLeastOrder() {
    final en = value.entries.toList();
    en.sort((a,b)  {
      return a.value.compareTo(b.value);
    });

    final result = <String>[];
    while (en.isNotEmpty) {

      final least = en
          .where((e) => e.value == en[0].value)
          .map((e) => e.key)
          .toList();
      least.shuffle();

      result.addAll(least);
      en.removeRange(0, least.length);
    }
    return result;
  }
}
