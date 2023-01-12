import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'dart:math';
import 'package:aoc2022/common.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

List<Position> convert(List<String> input) {
  return input.map((line) {
    var coords = line.split(',').map(int.parse).toList();
    return Position(coords[0], coords[1], coords[2]);
  }).toList();
}

int getExposedSidesCount(List<Position> input) {
  return 6 * input.length -
      input
          .map((p1) =>
              input.where((p2) => p1.manhattanDistanceTo(p2) == 1).length)
          .sum;
}

num solvePart1(List<Position> input) {
  return getExposedSidesCount(input);
}

num solvePart2(List<Position> input) {
  var minPos = Position.from(input.first), maxPos = Position.from(input.first);
  // Get bounding cube
  for (var pos in input.skip(1)) {
    minPos.x = min(minPos.x, pos.x);
    minPos.y = min(minPos.y, pos.y);
    minPos.z = min(minPos.z, pos.z);
    maxPos.x = max(maxPos.x, pos.x);
    maxPos.y = max(maxPos.y, pos.y);
    maxPos.z = max(maxPos.z, pos.z);
  }
  minPos.moveBy(-1, -1, -1);
  maxPos.moveBy(1, 1, 1);

  var frontier = [minPos], flooded = <Position>{};
  var movs = [
    Position(1, 0, 0),
    Position(-1, 0, 0),
    Position(0, 1, 0),
    Position(0, -1, 0),
    Position(0, 0, 1),
    Position(0, 0, -1)
  ];
  var inputSet = Set.from(input);

  // Flood cube
  while (frontier.isNotEmpty) {
    var pos = frontier.removeLast();
    flooded.add(pos);
    for (var m in movs) {
      var newPos = pos + m;
      if (newPos.x >= minPos.x &&
          newPos.x <= maxPos.x &&
          newPos.y >= minPos.y &&
          newPos.y <= maxPos.y &&
          newPos.z >= minPos.z &&
          newPos.z <= maxPos.z &&
          !inputSet.contains(newPos) &&
          !flooded.contains(newPos) &&
          !frontier.contains(newPos)) {
        frontier.add(newPos);
      }
    }
  }

  var dx = (maxPos.x - minPos.x).abs() + 1,
      dy = (maxPos.y - minPos.y).abs() + 1,
      dz = (maxPos.z - minPos.z).abs() + 1;
  // Return the count less the outer faces of the cube
  return getExposedSidesCount(flooded.toList()) -
      (2 * dx * dy + 2 * dx * dz + 2 * dy * dz);
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input18Test"
          : "data/input18";

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
