import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

Iterable<String> convert(Iterable<String> input) {
  return input;
}

// Returns the idx of the first sequence of unique chars of the specified length
int firstUniqueSequenceIdx(String s, int length) {
  for (int i = length - 1; i < s.codeUnits.length; i++) {
    var unique = <int>{};
    for (int j = 0; j < length; j++) {
      unique.add(s.codeUnits[i - j]);
    }
    if (unique.length == length) {
      return i + 1;
    }
  }
  return -1;
}

Iterable<num> solvePart1(Iterable<String> input) {
  return input.map((e) => firstUniqueSequenceIdx(e, 4));
}

Iterable<num> solvePart2(Iterable<String> input) {
  return input.map((e) => firstUniqueSequenceIdx(e, 14));
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input6Test"
          : "data/input6";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
