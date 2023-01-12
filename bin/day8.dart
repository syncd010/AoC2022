import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:aoc2022/common.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

List<List<int>> convert(Iterable<String> input) {
  return input
      .where((l) => l.isNotEmpty)
      .map((l) => l.split('').map(int.parse).toList())
      .toList();
}

// Returns whether the element at [row, col] has visibility to any of the
// 4 directions
bool isVisible(int row, int col, List<List<int>> input) {
  bool allSmaller(Iterable<int> lst, int value) =>
      lst.isEmpty || lst.every((element) => element < value);

  var currentRow = input[row],
      currentCol = input.map((e) => e[col]).toList(),
      treeHeight = currentRow[col];
  var visibility = [
    allSmaller(currentRow.getRange(0, col), treeHeight),
    allSmaller(currentRow.getRange(col + 1, currentRow.length), treeHeight),
    allSmaller(currentCol.getRange(0, row), treeHeight),
    allSmaller(currentCol.getRange(row + 1, currentCol.length), treeHeight),
  ];
  return visibility.any((e) => e);
}

num solvePart1(List<List<int>> input) {
  var visible = 0;
  for (int row = 0; row < input.length; row++) {
    for (int col = 0; col < input[row].length; col++) {
      visible += isVisible(row, col, input).toInt();
    }
  }
  return visible;
}

// Returns the tree value of the element at [row, col]
int treeValue(int row, int col, List<List<int>> input) {
  int countSmaller(Iterable<int> lst, int value) {
    var smaller = lst.takeWhile((element) => element < value);
    // Careful to add 1 if the last element if the same height
    return smaller.length + (smaller.length == lst.length ? 0 : 1);
  }

  var currentRow = input[row],
      currentCol = input.map((e) => e[col]).toList(),
      treeHeight = currentRow[col];
  var visibleCount = [
    countSmaller(currentRow.getRange(0, col).toList().reversed, treeHeight),
    countSmaller(currentRow.getRange(col + 1, currentRow.length), treeHeight),
    countSmaller(currentCol.getRange(0, row).toList().reversed, treeHeight),
    countSmaller(currentCol.getRange(row + 1, currentCol.length), treeHeight),
  ];
  return visibleCount.reduce((a, b) => a * b);
}

num solvePart2(List<List<int>> input) {
  var treeValues = <int>[];

  for (int row = 0; row < input.length; row++) {
    for (int col = 0; col < input[row].length; col++) {
      treeValues.add(treeValue(row, col, input));
    }
  }
  return treeValues.reduce((a, b) => max(a, b));
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input8Test"
          : "data/input8";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
