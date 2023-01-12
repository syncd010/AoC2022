import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';

List<String> readInput(path) {
  return File(path).readAsLinesSync();
}

Iterable<Iterable<int>> convert(List<String> input) {
  return input.map((e) => e.codeUnits);
}

// Returns the first integer that is present in all iterables
num findCommon(Iterable<Iterable<int>> sets) {
  var common = sets.reduce((s1, s2) => s1.where((e) => s2.contains(e)));
  return common.isEmpty ? -1 : common.first;
}

final runeLimits = "azAZ".codeUnits;

// Returns the priority of the character
num getPriority(num char) {
  return (char >= runeLimits[0] && char <= runeLimits[1])
      ? char - runeLimits[0] + 1
      : char - runeLimits[2] + 27;
}

num solvePart1(Iterable<Iterable<int>> input) {
  // Find the common char in the first and second half of each string,
  // get its priority and sum
  return input
      .map((e) => findCommon([e.take(e.length ~/ 2), e.skip(e.length ~/ 2)]))
      .where((e) => e != -1)
      .map(getPriority)
      .reduce((a, b) => a + b);
}

num solvePart2(Iterable<Iterable<int>> input) {
  // Find the common char in each set of 3 of the input strings,
  // get its priority and sum
  return input
      .slices(3)
      .map((e) => findCommon(e))
      .where((e) => e != -1)
      .map(getPriority)
      .reduce((a, b) => a + b);
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input3Test"
          : "data/input3";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
