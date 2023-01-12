import 'dart:math';
import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

Iterable<String> convert(Iterable<String> input) {
  return input;
}

// Returns the pair order according to the specified rules
int getPairOrder(String item1, String item2) {
  // Finds the closing token, either a ']' or a ',', accounting for nested lists
  int findEndIdx(String s) {
    var level = 0;
    for (var i = 0; i < s.length; i++) {
      if (s[i] == ',' && level == 0) {
        return i - 1;
      } else if (s[i] == ']') {
        level--;
        if (level <= 0) {
          return i;
        }
      } else if (s[i] == '[') {
        level++;
      }
    }
    return s.length - 1;
  }

  while (item1.isNotEmpty && item2.isNotEmpty) {
    // Process each list/element separately
    var subItem1 = item1.substring(0, findEndIdx(item1) + 1),
        subItem2 = item2.substring(0, findEndIdx(item2) + 1);
    if (subItem1[0] != '[' && subItem2[0] != '[') {
      // Both numbers
      var val1 = int.parse(subItem1), val2 = int.parse(subItem2);
      if (val1 < val2) return -1;
      if (val1 > val2) return 1;
    } else {
      // At least one list, recurse
      var subItem1Bracketed = (subItem1[0] != '[') ? '[$subItem1]' : subItem1;
      var subItem2Bracketed = (subItem2[0] != '[') ? '[$subItem2]' : subItem2;

      var order = getPairOrder(
          subItem1Bracketed.substring(1, subItem1Bracketed.length - 1),
          subItem2Bracketed.substring(1, subItem2Bracketed.length - 1));
      if (order != 0) return order;
    }
    // Equal list/element, remove it from the input to proceed to the next
    item1 = item1.substring(min(subItem1.length + 1, item1.length));
    item2 = item2.substring(min(subItem2.length + 1, item2.length));
  }
  // Process all input, check if any remaining
  return (item1.isEmpty && item2.isEmpty)
      ? 0
      : (item1.isEmpty)
          ? -1
          : 1;
}

num solvePart1(Iterable<String> input) {
  var out = 0;
  // Process pairs
  for (var i = 0; i < input.length; i += 3) {
    out += (getPairOrder(input.elementAt(i), input.elementAt(i + 1)) == -1)
        ? (i ~/ 3 + 1)
        : 0;
  }
  return out;
}

num solvePart2(Iterable<String> input) {
  // Clean blank lines, add elements, sort and return the desired indexes
  var allPairs = input.where((e) => e.isNotEmpty).toList();
  allPairs.addAll(['[[2]]', '[[6]]']);
  allPairs.sort((a, b) => getPairOrder(a, b));
  return allPairs.foldIndexed(
      1,
      (idx, acc, element) =>
          (element == '[[2]]' || element == '[[6]]') ? acc * (idx + 1) : acc);
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input13Test"
          : "data/input13";

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
