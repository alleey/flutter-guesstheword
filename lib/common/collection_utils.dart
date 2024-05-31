
class CollectionUtils {

  static T getAdjacentItem<T>(List<T> array, T currentItem, bool moveRight) {
    if (array.isEmpty) {
      return currentItem;
    }
    final currentIndex = array.indexOf(currentItem);
    if (currentIndex == -1) {
      throw ArgumentError("Current item not found in the array");
    }
    if (moveRight) {
      return array[(currentIndex + 1) % array.length];
    } else {
      return array[(currentIndex - 1 + array.length) % array.length];
    }
  }

  static (List<T>, List<T>) splitList<T>(List<T> list, int Function(T) comparator) {
    List<T> lower = [];
    List<T> higher = [];

    for (final item in list) {
      if (comparator(item) < 0) {
        lower.add(item);
      } else if (comparator(item) > 0) {
        higher.add(item);
      }
    }

    return (lower, higher);
  }
}
