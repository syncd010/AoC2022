import 'dart:io';
import 'package:args/args.dart';
import 'package:tuple/tuple.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

List<int> convert(List<String> input) {
  return input.first.split('').map((e) => e == '<' ? -1 : 1).toList();
}

var blocks = [
  [int.parse('000111100', radix: 2)],
  [
    int.parse('000010000', radix: 2),
    int.parse('000111000', radix: 2),
    int.parse('000010000', radix: 2)
  ],
  [
    int.parse('000001000', radix: 2),
    int.parse('000001000', radix: 2),
    int.parse('000111000', radix: 2)
  ],
  [
    int.parse('000100000', radix: 2),
    int.parse('000100000', radix: 2),
    int.parse('000100000', radix: 2),
    int.parse('000100000', radix: 2)
  ],
  [int.parse('000110000', radix: 2), int.parse('000110000', radix: 2)],
];

// Check if we can move block in the direction (left -1, right 1 or down 0)
bool canMoveBlock(
    List<int> well, List<int> block, int blockLocation, int direction) {
  for (var i = 0; i < block.length; i++) {
    var newLine = (direction == -1)
        ? block[i] << 1
        : (direction == 1)
            ? block[i] >> 1
            : block[i];
    if ((newLine & well[blockLocation - i]) > 0) {
      return false;
    }
  }

  return true;
}

// Moves a block in the given direction. Changes the block
void moveBlock(List<int> block, int direction) {
  if (direction == 0) return;
  for (var i = 0; i < block.length; i++) {
    block[i] = (direction == -1) ? block[i] << 1 : block[i] >> 1;
  }
}

final EMPTY_ROW = int.parse('100000001', radix: 2);

// Simulate block dropping for a maximum of numBlocks or until a loop is
// detected. Changes the well and returns a tuple containing the number or
// blocks dropped and the index on the input where stopped
Tuple2<int, int> simulateDrops(
    List<int> well, List<int> input, int inputIdx, int numBlocks,
    {breakAfterLoop = false}) {
  var inputIdxOnFirstBlock = <int>{};

  for (var count = 0; count < numBlocks; count++) {
    // If asked to detect loops and on the first block
    if (breakAfterLoop && count % blocks.length == 0) {
      // Have we been on this input index before?
      if (inputIdxOnFirstBlock.contains(inputIdx)) {
        return Tuple2(count, inputIdx);
      }
      inputIdxOnFirstBlock.add(inputIdx);
    }

    var block = [...blocks[count % blocks.length]]; // Copy
    // Add empty space to the well
    well.addAll(List.generate(3 + block.length, (_) => EMPTY_ROW));

    for (var loc = well.length - 1; loc > 0; loc--) {
      // Move block according to input
      if (canMoveBlock(well, block, loc, input[inputIdx])) {
        moveBlock(block, input[inputIdx]);
      }
      inputIdx = (inputIdx + 1) % input.length;
      // Move block down and check for collision
      if (!canMoveBlock(well, block, loc - 1, 0)) {
        // Place block
        for (var row = 0; row < block.length; row++) {
          well[loc - row] |= block[row];
        }
        // Remove extra empty rows
        while (well.last == EMPTY_ROW) {
          well.removeLast();
        }
        break;
      }
    }
  }
  return Tuple2(numBlocks, inputIdx);
}

num solvePart1(List<int> input) {
  var well = [int.parse('111111111', radix: 2)];
  simulateDrops(well, input, 0, 2022);
  return well.length - 1;
}

num solvePart2(List<int> input) {
  var well = [int.parse('111111111', radix: 2)];
  var maxBlocks = 1000000000000;

  // Do a first dry run until a loop is detected
  var firstRun = simulateDrops(well, input, 0, maxBlocks, breakAfterLoop: true);

  var prevLoopCount = 0, loopCount = -1;
  var inputIdx = firstRun.item2;
  var totalCount = firstRun.item1;
  var loopHeight = 0;
  // Find a loop with the same size
  while (prevLoopCount != loopCount) {
    prevLoopCount = loopCount;
    var prevHeight = well.length;
    var run =
        simulateDrops(well, input, inputIdx, maxBlocks, breakAfterLoop: true);
    loopCount = run.item1;
    totalCount += loopCount;
    inputIdx = run.item2;
    loopHeight = well.length - prevHeight;
  }
  // Final run
  simulateDrops(well, input, inputIdx, (maxBlocks - totalCount) % loopCount);
  // Add loops bypassed to height
  var totalHeight =
      well.length + ((maxBlocks - totalCount) ~/ loopCount) * loopHeight;
  return totalHeight - 1;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input17Test"
          : "data/input17";

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
