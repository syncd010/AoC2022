import 'dart:io';
import 'package:args/args.dart';

List<String> readInput(path) {
  var lines = File(path).readAsLinesSync();
  return lines;
}

List<String> convert(List<String> input) {
  return input;
}

// Score for each play
const playScore = {'A': 1, 'B': 2, 'C': 3};
// Map with the winner move for each original move
const winnerMove = {'A': 'B', 'B': 'C', 'C': 'A'};
final looserMove = winnerMove.map((k, v) => MapEntry(v, k));

// Gets the score of a play
int scorePlay(String play) {
  int s = (play[0] == play[2]
      ? 3
      : play[2] == winnerMove[play[0]]
          ? 6
          : 0);
  return playScore[play[2]]! + s;
}

num solvePart1(List<String> input) {
  // Replace the X, Y, Z for the move and score each one
  const replacementMoves = {'X': 'A', 'Y': 'B', 'Z': 'C'};
  return input
      .map((e) => e.substring(0, 2) + replacementMoves[e[2]]!)
      .map((e) => scorePlay(e))
      .reduce((a, b) => a + b);
}

num solvePart2(List<String> input) {
  // Calculate which move to make
  String getMove(String play) {
    switch (play[2]) {
      case 'X': // Loose
        return looserMove[play[0]]!;
      case 'Z': // Win
        return winnerMove[play[0]]!;
      default: // Draw
        return play[0];
    }
  }

  return input
      .map((e) => e.substring(0, 2) + getMove(e))
      .map((e) => scorePlay(e))
      .reduce((a, b) => a + b);
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input2Test"
          : "data/input2";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
