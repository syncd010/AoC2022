import 'dart:io';
import 'package:args/args.dart';
import 'package:aoc2022/common.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

class Move {
  final String dir;
  final int steps;

  Move(this.dir, this.steps);

  @override
  String toString() => '$dir, $steps';

  static const changes = {
    'R': [1, 0],
    'L': [-1, 0],
    'U': [0, 1],
    'D': [0, -1],
  };
}

Iterable<Move> convert(Iterable<String> input) {
  return input.map((e) {
    var parts = e.split(' ');
    return Move(parts[0], int.parse(parts[1]));
  });
}

// Executes the moves and returns the tail positions
Set<Position> simulateTail(Iterable<Move> moves, int numKnots) {
  var knots = [for (var i = 0; i < numKnots; i++) Position.origin()];
  var tailPositions = <Position>{};

  for (var m in moves) {
    for (int i = 0; i < m.steps; i++) {
      knots[0].moveBy(Move.changes[m.dir]![0], Move.changes[m.dir]![1]);
      for (int k = 1; k < knots.length; k++) {
        if (knots[k - 1].distanceTo(knots[k]) >= 2) {
          knots[k].moveBy((knots[k - 1].x - knots[k].x).sign,
              (knots[k - 1].y - knots[k].y).sign);
        }
      }
      tailPositions.add(Position.from(knots.last));
    }
  }
  return tailPositions;
}

num solvePart1(Iterable<Move> input) {
  return simulateTail(input, 2).length;
}

num solvePart2(Iterable<Move> input) {
  return simulateTail(input, 10).length;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input9Test"
          : "data/input9";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
