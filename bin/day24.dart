import 'dart:io';
import 'package:aoc2022/common.dart';
import 'package:args/args.dart';
import 'package:collection/collection.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

// Convert input to board, removing the border
Board convert(List<String> input) {
  var inner = input
      .getRange(1, input.length - 1)
      .map((l) => l.substring(1, l.length - 1).codeUnits);
  var layers = [
    for (var dir in ['<', '>', '^', 'v'])
      inner
          .map((row) => row.map((e) => e == dir.codeUnitAt(0) ? 1 : 0).toList())
          .toList()
  ];
  return Board(
      input.first.indexOf('.') - 1, input.last.indexOf('.') - 1, layers);
}

typedef BoardLayer = List<List<int>>;

// A board, with the start/end positions and a matrix for each direction isolated
class Board {
  int start, end;
  // Isolated directions
  List<BoardLayer> layers;

  Board(this.start, this.end, this.layers);

  @override
  String toString() {
    var reprs = [
      for (var dir in layers)
        dir.map((row) => row.map((e) => e == 0 ? '.' : '#').join('')).join('\n')
    ];
    return '\nLefts:\n${reprs[0]}\nRights:\n${reprs[1]}\nUps:\n${reprs[2]}\nDowns:\n${reprs[3]}\n';
  }

  // Evolves the board one time step
  Board evolve() {
    var up = layers[2].clone(), down = layers[3].clone();
    return Board(start, end, [
      layers[0].map((row) => [...row.skip(1), row.first]).toList(),
      layers[1].map((row) => [row.last, ...row.take(row.length - 1)]).toList(),
      [...up.skip(1), up.first],
      [down.last, ...down.take(down.length - 1)]
    ]);
  }
}

// State for search, just position and time
class State {
  Position position;
  int time;

  State(this.time, this.position);

  @override
  int get hashCode => Object.hash(time, position.x, position.y);
}

// Movs, Stay put, E,W,N,S
var movs = [
  Position(0, 0),
  Position(1, 0),
  Position(-1, 0),
  Position(0, 1),
  Position(0, -1),
];

List<State> Function(State) getSuccessorsFn(List<Board> boards) {
  var width = boards.first.layers[0].first.length,
      height = boards.first.layers[0].length;

  // Successors of a state, apply movs and check if board is empty on the
  // resulting position
  return (State state) {
    bool isEmpty(Board board, Position p) =>
        board.layers.every((dir) => dir[p.y][p.x] == 0);

    var successors = <State>[];
    var currTime = state.time + 1;
    // Evolve boards to the desired time
    while (boards.length < currTime + 1) {
      boards.add(boards.last.evolve());
    }
    var currBoard = boards[state.time + 1];

    // Stay put initially
    if (state.position.y == -1 || state.position.y == height) {
      successors.add(State(currTime, state.position));
    }

    // Try movs
    for (var m in movs) {
      var p = state.position + m;
      if (p.x < 0 || p.x >= width || p.y < 0 || p.y >= height) continue;
      if (isEmpty(currBoard, p)) {
        successors.add(State(currTime, p));
      }
    }
    return successors;
  };
}

// is Goal?, top or bottom, depending on the dir
bool Function(State) getGoalFn(Board board, int dir) => dir == 0
    ? (State state) =>
        state.position.y == board.layers[0].length - 1 &&
        state.position.x == board.end
    : (State state) => state.position.y == 0 && state.position.x == board.start;

// Priority fn for A*, depends on the dir
int Function(State, State) getPriority(Board board, int dir) {
  int xGoal = (dir == 0) ? board.end : board.start,
      yGoal = (dir == 0) ? board.layers[0].length : -1;
  // Time + manhattan distance to goal
  int score(State state) =>
      state.time +
      (xGoal - state.position.x).abs() +
      (yGoal - state.position.y).abs();

  return (p0, p1) => score(p0) - score(p1);
}

num solvePart1(Board board) {
  var res = aStarSearch(State(0, Position(board.start, -1)),
      getSuccessorsFn([board]), getGoalFn(board, 0), getPriority(board, 0))!;
  return res.time + 1;
}

num solvePart2(Board board) {
  List<Board> boards = [board];

  // Down
  var state = State(0, Position(board.start, -1));
  var res = aStarSearch(state, getSuccessorsFn(boards), getGoalFn(board, 0),
      getPriority(board, 0))!;

  // Up
  state = State(res.time + 1, Position(board.end, board.layers[0].length));
  res = aStarSearch(state, getSuccessorsFn(boards), getGoalFn(board, 1),
      getPriority(board, 1))!;

  // Down
  state = State(res.time + 1, Position(board.start, -1));
  res = aStarSearch(state, getSuccessorsFn(boards), getGoalFn(board, 0),
      getPriority(board, 0))!;

  return res.time + 1;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input24Test"
          : "data/input24";

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
