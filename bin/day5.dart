import 'dart:io';
import 'package:args/args.dart';
import 'package:tuple/tuple.dart';
import 'package:aoc2022/common.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

typedef CrateSpec = List<List<String>>;
typedef MoveSpec = List<List<int>>;

Tuple2<CrateSpec, MoveSpec> convert(Iterable<String> input) {
  CrateSpec crates = input
      .where((line) => line.contains('['))
      .map((line) => line
          .slices(4)
          .map((e) => e.trim().replaceAll('[', '').replaceAll(']', ''))
          .toList())
      .toList()
      .transpose()
      .map((e) => e.reversed.where((e) => e.isNotEmpty).toList())
      .toList();

  final regExp = RegExp(r'move (\d+) from (\d+) to (\d+)');
  MoveSpec moves = input.where((line) => regExp.hasMatch(line)).map((line) {
    final match = regExp.firstMatch(line)!;
    return [int.parse(match[1]!), int.parse(match[2]!), int.parse(match[3]!)];
  }).toList();

  return Tuple2(crates, moves);
}

String solvePart1(Tuple2<CrateSpec, MoveSpec> puzzle) {
  // We're going to change the list, so make sure its a clone
  var crates = puzzle.item1.clone();

  for (var move in puzzle.item2) {
    var howMany = move[0],
        from = move[1] - 1,
        to = move[2] - 1,
        lastIdx = crates[from].length;
    crates[to].addAll(
        crates[from].getRange(lastIdx - howMany, lastIdx).toList().reversed);
    crates[from].removeRange(lastIdx - howMany, lastIdx);
  }

  return crates.map((e) => e.isEmpty ? ' ' : e.last).join();
}

String solvePart2(Tuple2<CrateSpec, MoveSpec> puzzle) {
  // We're going to change the list, so make sure its a clone
  var crates = puzzle.item1.clone();

  for (var move in puzzle.item2) {
    var howMany = move[0],
        from = move[1] - 1,
        to = move[2] - 1,
        lastIdx = crates[from].length;
    crates[to].addAll(crates[from].getRange(lastIdx - howMany, lastIdx));
    crates[from].removeRange(lastIdx - howMany, lastIdx);
  }

  return crates.map((e) => e.isEmpty ? ' ' : e.last).join();
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input5Test"
          : "data/input5";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
