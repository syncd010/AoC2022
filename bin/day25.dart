import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'dart:math';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

List<String> convert(List<String> input) {
  return input;
}

var snafuDecoder = {'=': -2, '-': -1, '0': 0, '1': 1, '2': 2},
    snafuEncoder = snafuDecoder.map((k, v) => MapEntry(v, k));

int fromSnafu(String snafu) {
  var val = 0;
  for (var i = 0; i < snafu.length; i++) {
    val += snafuDecoder[snafu[i]]! * pow(5, snafu.length - 1 - i).toInt();
  }
  return val;
}

String toSnafu(int val) {
  // How many digits will be necessary
  var maxDigits = 1, div = val;
  while (div ~/ 5 > 0) {
    maxDigits++;
    div = div ~/ 5;
  }
  // Need to add one if bigger than 1/2 the base 5 equivalent
  if (val > pow(5, maxDigits) ~/ 2) maxDigits++;

  var snafu = <String>[];
  // "shift" val by 5^maxDigits / 2
  var shifted = val + pow(5, maxDigits) ~/ 2;
  for (var i = 0; i < maxDigits; i++) {
    snafu.add(snafuEncoder[(shifted ~/ pow(5, i)) % 5 - 2]!);
  }
  return snafu.reversed.join('');
}

String solvePart1(List<String> input) {
  var sum = input.map((line) => fromSnafu(line)).sum;
  return toSnafu(sum);
}

num solvePart2(List<String> input) {
  return 0;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input25Test"
          : "data/input25";

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
