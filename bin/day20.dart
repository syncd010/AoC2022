import 'dart:io';
import 'package:args/args.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

List<int> convert(List<String> input) {
  return input.map((e) => int.parse(e)).toList();
}

extension ListSwap<T> on List<T> {
  void swap(int idx1, int idx2) {
    var tmp = this[idx1];
    this[idx1] = this[idx2];
    this[idx2] = tmp;
  }
}

List<int> mix(List<int> input, [int times = 1]) {
  var indexes = [for (var i = 0; i < input.length; i++) i];

  for (var t = 0; t < times; t++) {
    // Swap indexes according to input
    for (var i = 0; i < input.length; i++) {
      var idx = indexes.indexOf(i);
      for (var j = 0; j < input[i].abs() % (input.length - 1); j++) {
        indexes.swap((idx + input[i].sign * (j + 1)) % indexes.length,
            (idx + input[i].sign * j) % indexes.length);
      }
    }
  }
  // Retrieve input according to indexes
  return indexes.map((i) => input[i]).toList();
}

num solvePart1(List<int> input) {
  var mixed = mix(input);
  return [1000, 2000, 3000]
      .fold(0, (acc, e) => acc + mixed[(mixed.indexOf(0) + e) % mixed.length]);
}

num solvePart2(List<int> input) {
  var mixed = mix(input.map((e) => e * 811589153).toList(), 10);
  return [1000, 2000, 3000]
      .fold(0, (acc, e) => acc + mixed[(mixed.indexOf(0) + e) % mixed.length]);
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input20Test"
          : "data/input20";

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
