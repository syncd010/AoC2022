import 'dart:collection';
import 'dart:math';
import 'package:collection/collection.dart';

int calculate() {
  return 6 * 7;
}

int lcm(int a, int b) {
  if ((a == 0) || (b == 0)) {
    return 0;
  }

  return ((a ~/ a.gcd(b)) * b).abs();
}

extension StringCommon on String {
  Iterable<String> slices(int length) sync* {
    if (length < 1) throw RangeError.range(length, 1, null, 'length');
    for (var i = 0; i < this.length; i += length) {
      yield substring(i, min(i + length, this.length));
    }
  }
}

extension NestedListCommon<R> on List<List<R>> {
  List<List<R>> transpose() {
    int nRows = length;
    if (isEmpty) return this;

    int nCols = this[0].length;
    if (nCols == 0) throw StateError('Degenerate matrix');
    // Check for rectangle matrix
    if (any((e) => e.length != nCols)) {
      throw FormatException('Not a rectangle Matrix');
    }

    // Transpose
    List<List<R>> rowsInCols = List.generate(nCols, ((index) => []));
    for (int row = 0; row < nRows; row++) {
      for (int col = 0; col < nCols; col++) {
        rowsInCols[col].add(this[row][col]);
      }
    }
    return rowsInCols;
  }

  List<List<R>> clone() => map((e) => [...e]).toList();
}

extension IterableCommon<T> on Iterable<T> {
  List<int> allIndexWhere(bool Function(T) test) {
    var i = 0;
    var indexes = <int>[];
    for (var elem in this) {
      if (test(elem)) {
        indexes.add(i);
      }
      i++;
    }
    return indexes;
  }
}

extension SetCommon<T> on Set<T> {
  Set<T> without(T element) {
    var newSet = this.toSet();
    newSet.remove(element);
    return newSet;
  }
}

extension BoolCommon on bool {
  int toInt() => this ? 1 : 0;
}

extension NumCommon on num {
  bool between(num min, num max) => this >= min && this <= max;
}

class Position {
  int x, y, z;

  Position(this.x, this.y, [this.z = 0]);
  Position.from(Position other)
      : x = other.x,
        y = other.y,
        z = other.z;
  Position.origin()
      : x = 0,
        y = 0,
        z = 0;

  @override
  bool operator ==(Object other) =>
      other is Position && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => '[$x, $y, $z]';

  Position operator +(Position v) => Position(x + v.x, y + v.y, z + v.z);
  Position operator -(Position v) => Position(x - v.x, y - v.y, z - v.z);
  Position operator *(int v) => Position(x * v, y * v, z * v);

  Position projectTo(int axis) {
    switch (axis) {
      case 0:
        return Position(x, 0, 0);
      case 1:
        return Position(0, y, 0);
      case 2:
        return Position(0, 0, z);
    }
    return this;
  }

  void moveBy(int x, int y, [int z = 0]) {
    this.x += x;
    this.y += y;
    this.z += z;
  }

  double distanceTo(Position other) {
    var dx = x - other.x, dy = y - other.y, dz = z - other.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }

  int manhattanDistanceTo(Position other) {
    var dx = x - other.x, dy = y - other.y, dz = z - other.z;
    return dx.abs() + dy.abs() + dz.abs();
  }
}

/// Generic Breadth First Search Function
/// @param start Start state
/// @param successors Function to generate successors from a state
/// @param isGoal Test for goal state
/// @param stateKey Function that provides a unique key for a state
/// @returns Array with the visited states or null if no path found
List<T> breadthFirstSearch<T>(T start, List<T> Function(T) successors,
    bool Function(T) isGoal, String Function(T) stateKey) {
  if (isGoal(start)) return [start];
  var frontier = ListQueue.of([start]);
  // Explored will save the parents of the node
  var explored = <String, T?>{};
  explored[stateKey(start)] = null;
  while (frontier.isNotEmpty) {
    var current = frontier.removeFirst();
    for (var next in successors(current)) {
      var nextKey = stateKey(next);
      if (explored.containsKey(nextKey)) continue;
      if (isGoal(next)) {
        // Reconstruct the path till here
        var path = [next, current];
        while (explored[stateKey(path[path.length - 1])] != null) {
          path.add(explored[stateKey(path[path.length - 1])] as T);
        }
        return path;
      }
      // Save the parent so we can reconstruct the path
      explored[nextKey] = current;
      frontier.add(next);
    }
  }
  return [];
}

T? aStarSearch<T>(T start, List<T> Function(T) successors,
    bool Function(T) isGoal, int Function(T, T) comparison) {
  if (isGoal(start)) return start;

  var frontier = PriorityQueue<T>(comparison)..add(start);
  var explored = {start.hashCode};

  while (frontier.isNotEmpty) {
    var current = frontier.removeFirst();
    if (isGoal(current)) return current;
    for (var next in successors(current)) {
      if (explored.contains(next.hashCode)) continue;
      explored.add(next.hashCode);
      frontier.add(next);
    }
  }
  return null;
}
