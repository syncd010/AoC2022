import 'dart:io';
import 'package:args/args.dart';
import 'dart:math';

List<String> readInput(path) {
  var lines = File(path).readAsLinesSync();
  return lines;
}

/// Create a list of the sums of consecutive elements that are not empty
List<int> convert(List<String> input) {
  return input.fold([0], (prev, element) {
    if (element.isEmpty) {
      prev.add(0);
    } else {
      prev[prev.length - 1] = prev.last + int.parse(element);
    }
    return prev;
  });
}

num solvePart1(List<int> input) {
  // Get the max
  return input.reduce((value, element) => max(value, element));
}

num solvePart2(List<int> input) {
  // Sort, take the first 3 and sum
  input.sort((a, b) => b - a);
  return input.take(3).reduce((value, element) => value + element);
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag('test', abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input1Test"
          : "data/input1";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
