import 'dart:io';
import 'package:args/args.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';
import 'package:aoc2022/common.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

Tuple3<Position, Position, List<List<int>>> convert(Iterable<String> input) {
  var lowestCodeUnit = 'a'.codeUnits[0],
      startCodeUnit = 'S'.codeUnits[0],
      endCodeUnit = 'E'.codeUnits[0];
  var heightMap = input
      .map((line) => line
          .replaceAllMapped(
              RegExp(r'S|E'), (Match m) => m[0] == 'S' ? 'a' : 'z')
          .codeUnits
          .map((e) => e - lowestCodeUnit)
          .toList())
      .toList();
  var startPos = Position.origin(), endPos = Position.origin();
  for (var r = 0; r < input.length; r++) {
    var lineCodeUnits = input.elementAt(r).codeUnits;
    for (var c = 0; c < lineCodeUnits.length; c++) {
      if (lineCodeUnits[c] == startCodeUnit) {
        startPos = Position(r, c);
      } else if (lineCodeUnits[c] == endCodeUnit) {
        endPos = Position(r, c);
      }
    }
  }
  return Tuple3(startPos, endPos, heightMap);
}

List<Position> Function(Position) getSuccessorsFn(List<List<int>> heightMap) {
  return ((p) {
    var dirs = [
      Position(1, 0),
      Position(0, -1),
      Position(-1, 0),
      Position(0, 1)
    ];
    var length = heightMap.length, width = heightMap.first.length;
    var height = heightMap[p.x][p.y];
    var succ = <Position>[];

    for (var d in dirs) {
      var newP = p + d;
      if (newP.x >= 0 &&
          newP.x < length &&
          newP.y >= 0 &&
          newP.y < width &&
          (heightMap[newP.x][newP.y] - height) < 2) {
        succ.add(newP);
      }
    }
    return succ;
  });
}

num solvePart1(Tuple3<Position, Position, List<List<int>>> input) {
  var startPos = input.item1, endPos = input.item2, heightMap = input.item3;
  var path = breadthFirstSearch(startPos, getSuccessorsFn(heightMap),
      (p) => p == endPos, (p) => p.toString());
  return path.length - 1;
}

num solvePart2(Tuple3<Position, Position, List<List<int>>> input) {
  var endPos = input.item2, heightMap = input.item3;
  var startPositions = heightMap.mapIndexed((rowIdx, row) {
    var colIdx = row.indexOf(0);
    return (colIdx != -1) ? Position(rowIdx, colIdx) : null;
  }).where((e) => e != null);

  return startPositions
          .map((startPos) => breadthFirstSearch(
              startPos!,
              getSuccessorsFn(heightMap),
              (p) => p == endPos,
              (p) => p.toString()))
          .reduce((a, b) => (a.length <= b.length) ? a : b)
          .length -
      1;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input12Test"
          : "data/input12";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
