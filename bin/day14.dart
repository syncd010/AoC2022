import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:aoc2022/common.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

const String EMPTY = '.', WALL = '#', SAND = 'o', FOUNTAIN = '+';

// Create a map of the cave
List<List<String>> convert(Iterable<String> input) {
  RegExp exp = RegExp(r"(\d+),(\d+)");
  var wallPos = <List<int>>[];
  for (var line in input) {
    var matches = exp
        .allMatches(line)
        .map((m) => [int.parse(m.group(1)!), int.parse(m.group(2)!)])
        .toList();
    for (var i = 0; i < matches.length - 1; i++) {
      var x1 = min(matches[i][0], matches[i + 1][0]),
          x2 = max(matches[i][0], matches[i + 1][0]),
          y1 = min(matches[i][1], matches[i + 1][1]),
          y2 = max(matches[i][1], matches[i + 1][1]);
      // Fill wall positions
      for (var x = x1; x <= x2; x++) {
        for (var y = y1; y <= y2; y++) {
          wallPos.add([x, y]);
        }
      }
    }
  }
  var maxX = wallPos.fold(0, (p, e) => max(p, e[0])) + 1,
      minX = wallPos.fold(maxX, (p, e) => min(p, e[0])) - 1,
      maxY = wallPos.fold(0, (p, e) => max(p, e[1])) + 1;
  // Create map of the full cave
  var cave = List<List<String>>.generate(
      maxY, (_) => List<String>.generate(maxX - minX + 1, (_) => EMPTY));
  for (var e in wallPos) {
    cave[e[1]][e[0] - minX] = WALL;
  }
  cave[0][500 - minX] = FOUNTAIN;
  return cave;
}

void printCave(List<List<String>> cave) {
  for (var l in cave) {
    print(l.join(''));
  }
}

// Fills down one step
bool fillDown(List<List<String>> cave, int y, int x) {
  bool isEmpty(List<List<String>> cave, int y, int x) =>
      y.between(0, cave.length - 1) &&
      x.between(0, cave[0].length - 1) &&
      cave[y][x] == EMPTY;
  var initialY = y;
  while (isEmpty(cave, y + 1, x) ||
      isEmpty(cave, y + 1, x - 1) ||
      isEmpty(cave, y + 1, x + 1)) {
    // Fill down
    y++;
    if (!isEmpty(cave, y, x)) {
      x += (isEmpty(cave, y, x - 1)) ? -1 : 1;
    }
  }
  if (y > initialY && y < cave.length - 1) {
    cave[y][x] = SAND;
    return true;
  } else {
    return false;
  }
}

num solvePart1(List<List<String>> cave) {
  var out = 0, workCave = cave.clone();
  while (fillDown(workCave, 0, workCave[0].indexOf(FOUNTAIN))) {
    out++;
  }
  return out;
}

num solvePart2(List<List<String>> cave) {
  var maxSz = max((cave.length + 1) * 2 + cave[0].length ~/ 2, cave[0].length),
      center = (maxSz - cave[0].length - 1) ~/ 2;
  var fullCave = List<List<String>>.generate(
      cave.length + 1,
      (y) => List<String>.generate(
          maxSz,
          (x) =>
              (y >= cave.length || x < center || x >= cave[0].length + center)
                  ? EMPTY
                  : cave[y][x - center]));
  fullCave.add(List<String>.generate(maxSz, (_) => WALL));
  var out = 0;
  while (fillDown(fullCave, 0, fullCave[0].indexOf(FOUNTAIN))) {
    out++;
  }
  return out + 1;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input14Test"
          : "data/input14";

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
