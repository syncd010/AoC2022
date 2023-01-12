import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';
import 'package:aoc2022/common.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

const EMPTY = -1;

List<List<int>> convert(List<String> input) {
  var i = 0;
  final empty = '.'.codeUnitAt(0);
  return input
      .map((l) => l.codeUnits.map((e) => e == empty ? EMPTY : i++).toList())
      .toList();
}

// Creates a buffer around the edges of the map if necessary
List<List<int>> expandMap(List<List<int>> map) {
  if (map.first.every((e) => e == EMPTY) &&
      map.last.every((e) => e == EMPTY) &&
      map.every((e) => e.first == EMPTY) &&
      map.every((e) => e.last == EMPTY)) return map;
  var expanded = map.map((e) => [EMPTY, ...e, EMPTY]).toList();
  return expanded
    ..insert(0, [for (var i = 0; i < expanded[0].length; i++) EMPTY])
    ..add([for (var i = 0; i < expanded[0].length; i++) EMPTY]);
}

// Directions
List<List<Position>> dirs = [
  [Position(-1, -1), Position(0, -1), Position(1, -1)],
  [Position(-1, 1), Position(0, 1), Position(1, 1)],
  [Position(-1, -1), Position(-1, 0), Position(-1, 1)],
  [Position(1, -1), Position(1, 0), Position(1, 1)]
];

// // Simulates one step of the CA, returns changed positions
// List<Position> evolve(List<Position> positions, Iterable<List<Position>> dirs) {
//   var proposed = <Position?>[];
//   var posSet = positions.toSet();
//   for (var pos in positions) {
//     proposed.add(null);
//     // If all empty, don't propose
//     if (!dirs.any((adj) => adj.any((p) => posSet.contains(pos + p)))) {
//       continue;
//     }

//     for (var adj in dirs) {
//       if (adj.every((p) => !posSet.contains(pos + p))) {
//         proposed.last = pos + adj[1];
//         break;
//       }
//     }
//   }
//   // Check duplicates
//   proposed.forEachIndexed((idx, pos) {
//     var duplicate = false;
//     for (var otherIdx = idx + 1; otherIdx < proposed.length; otherIdx++) {
//       if (pos == proposed[otherIdx]) {
//         proposed[otherIdx] = null;
//         duplicate = true;
//       }
//     }
//     if (duplicate) proposed[idx] = null;
//   });

//   return proposed.mapIndexed((idx, p) => p ?? positions[idx]).toList();
// }

// num solvePart1(List<List<int>> map) {
//   var dirIdx = 0;

//   var positions = map
//       .expandIndexed((y, l) => l
//           .mapIndexed((x, e) => e == EMPTY ? null : Position(x, y))
//           .whereNotNull())
//       .toList();

//   for (var c = 0; c < 10; c++) {
//     positions = evolve(
//         positions, dirs.slice(dirIdx).followedBy(dirs.sublist(0, dirIdx)));
//     dirIdx = (dirIdx + 1) % dirs.length;
//   }

//   var bounds = Tuple4(
//       positions.map((e) => e.x).min,
//       positions.map((e) => e.y).min,
//       positions.map((e) => e.x).max,
//       positions.map((e) => e.y).max);
//   return (bounds.item3 - bounds.item1 + 1) * (bounds.item4 - bounds.item2 + 1) -
//       positions.length;
// }

// num solvePart2(List<List<int>> map) {
//   var dirIdx = 0, count = 0;
//   var moving = true;

//   var positions = map
//       .expandIndexed((y, l) => l
//           .mapIndexed((x, e) => e == EMPTY ? null : Position(x, y))
//           .whereNotNull())
//       .toList();

//   while (moving) {
//     var newPositions = evolve(
//         positions, dirs.slice(dirIdx).followedBy(dirs.sublist(0, dirIdx)));
//     moving = newPositions
//         .mapIndexed((idx, p) => p != positions[idx])
//         .any((element) => element);
//     positions = newPositions;
//     dirIdx = (dirIdx + 1) % dirs.length;
//     count++;
//   }

//   return count;
// }

// Simulates one step of the CA, returns changed positions
Tuple2<List<List<int>>, List<Position?>> evolve(
    List<List<int>> map, Iterable<List<Position>> dirs) {
  map = expandMap(map);

  var positions = map
      .expandIndexed((y, l) => l
          .mapIndexed((x, e) => e == EMPTY ? null : Position(x, y))
          .whereNotNull())
      .toList();
  var proposed = <Position?>[];
  for (var pos in positions) {
    proposed.add(null);
    // If all empty, don't propose
    if (dirs.every(
        (adj) => adj.every((p) => map[pos.y + p.y][pos.x + p.x] == EMPTY))) {
      continue;
    }

    for (var adj in dirs) {
      if (adj.every((p) => map[pos.y + p.y][pos.x + p.x] == EMPTY)) {
        proposed.last = pos + adj[1];
        break;
      }
    }
  }

  // Check duplicates
  proposed.forEachIndexed((idx, pos) {
    var duplicate = false;
    for (var otherIdx = idx + 1; otherIdx < proposed.length; otherIdx++) {
      if (pos == proposed[otherIdx]) {
        proposed[otherIdx] = null;
        duplicate = true;
      }
    }
    if (duplicate) proposed[idx] = null;
  });

  // Back to map
  proposed.forEachIndexed((idx, pos) {
    if (pos == null) return;
    map[pos.y][pos.x] = idx;
    map[positions[idx].y][positions[idx].x] = EMPTY;
  });

  return Tuple2(map, proposed);
}

num solvePart1(List<List<int>> map) {
  var dirIdx = 0;

  for (var c = 0; c < 10; c++) {
    map = evolve(map, dirs.sublist(dirIdx).followedBy(dirs.sublist(0, dirIdx)))
        .item1;
    dirIdx = (dirIdx + 1) % dirs.length;
  }

  var positions = map
      .expandIndexed((y, l) => l
          .mapIndexed((x, e) => e == EMPTY ? null : Position(x, y))
          .whereNotNull())
      .toList();

  var bounds = Tuple4(
      positions.map((e) => e.x).min,
      positions.map((e) => e.y).min,
      positions.map((e) => e.x).max,
      positions.map((e) => e.y).max);
  return (bounds.item3 - bounds.item1 + 1) * (bounds.item4 - bounds.item2 + 1) -
      positions.length;
}

num solvePart2(List<List<int>> map) {
  var dirIdx = 0, count = 0;
  var moving = true;

  while (moving) {
    var res =
        evolve(map, dirs.sublist(dirIdx).followedBy(dirs.sublist(0, dirIdx)));
    map = res.item1;
    moving = res.item2.any((p) => p != null);
    dirIdx = (dirIdx + 1) % dirs.length;
    count++;
  }

  return count;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input23Test"
          : "data/input23";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  var stopwatch = Stopwatch()..start();
  print('First part is ${solvePart1(convertedInput)} (${stopwatch.elapsed})');
  stopwatch.reset();
  print('Second part is ${solvePart2(convertedInput)} (${stopwatch.elapsed})');
  stopwatch.stop();
}
