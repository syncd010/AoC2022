import 'dart:io';
import 'package:args/args.dart';

Iterable<String> readInput(path) {
  return File(path).readAsLinesSync();
}

Iterable<List<int>> convert(Iterable<String> input) {
  final regExp = RegExp(r'(\d+)-(\d+),(\d+)-(\d+)');
  return input.map((e) {
    final match = regExp.firstMatch(e)!;
    return [
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
      int.parse(match[4]!)
    ];
  });
}

num solvePart1(Iterable<List<int>> input) {
  return input
      .where((e) =>
          (e[0] <= e[2] && e[1] >= e[3]) || (e[0] >= e[2] && e[1] <= e[3]))
      .length;
}

num solvePart2(Iterable<List<int>> input) {
  return input.where((e) => !(e[1] < e[2] || e[0] > e[3])).length;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input4Test"
          : "data/input4";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
