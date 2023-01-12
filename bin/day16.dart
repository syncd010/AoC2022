import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';
import 'package:aoc2022/common.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

// Represents a valve with its rate and direct connections
class Valve {
  String id;
  int rate;
  // Connections from this valve to others with rate > 0 and steps to
  // reach them and open them
  Map<String, int> connections;

  Valve(this.id, this.rate, this.connections);

  @override
  String toString() => '[$id, $rate, $connections]';
}

// Simplifies valves connections, keeping only the connections to valves whose
// rate > 0, and calculating the time needed to reach and open each of them
Map<String, Valve> simplifyConnections(Map<String, Valve> valves) {
  // Ignore valves with rate = 0
  var relevant = valves.values.where((v) => v.rate > 0);
  var out = <String, Valve>{};
  for (var start in [valves['AA']!, ...relevant]) {
    var startConnections = <String, int>{};
    for (var end in relevant.where((e) => e.id != start.id)) {
      // Do a BFS from the start valve to each of the relevant valves
      var path = breadthFirstSearch(
          start.id,
          (v) => valves[v]!.connections.keys.toList(),
          (v) => v == end.id,
          (v) => v);
      startConnections[end.id] = path.length - 1 + 1;
    }
    out[start.id] = Valve(start.id, start.rate, startConnections);
  }
  return out;
}

// Returns a map of valve's id to its representation
Map<String, Valve> convert(List<String> input) {
  var regExp = RegExp(
      r'Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)');
  return simplifyConnections(Map.fromEntries(input.map((line) {
    var m = regExp.allMatches(line).first;
    var connections =
        Map.fromEntries(m.group(3)!.split(', ').map((e) => MapEntry(e, 1)));
    return MapEntry(
        m.group(1)!, Valve(m.group(1)!, int.parse(m.group(2)!), connections));
  })));
}

// Returns all the possible paths, stating from `path` with `remaining` as the
// possible steps in a maximum of `time`
Iterable<List<String>> allPossiblePaths(Map<String, Valve> valves,
    List<String> path, Set<String> remaining, int time) sync* {
  for (var next in remaining) {
    var newTime = time - valves[path.last]!.connections[next]!;
    if (newTime > 0) {
      yield* allPossiblePaths(
          valves, [...path, next], remaining.without(next), newTime);
    }
  }
  yield path;
}

// Returns a path score
int pathScore(Map<String, Valve> valves, List<String> path, int maxTime) {
  var score = 0, time = maxTime;
  for (var i = 1; i < path.length; i++) {
    var current = path[i - 1], next = path[i];
    time -= valves[current]!.connections[next]!;
    score += max(0, time) * valves[next]!.rate;
  }
  return score;
}

num solvePart1(Map<String, Valve> valves) {
  final maxTime = 30;
  var start = 'AA';
  var remaining = valves[start]!.connections.keys.toSet();
  // Get all possible paths, their score and the max
  return allPossiblePaths(valves, ['AA'], remaining, maxTime)
      .map((path) => pathScore(valves, path, maxTime))
      .max;
}

num solvePart2(Map<String, Valve> valves) {
  final maxTime = 26;
  var start = 'AA';
  var remaining = valves[start]!.connections.keys.toSet();
  // Get all possible paths and their scores, sorted descending
  var paths = allPossiblePaths(valves, ['AA'], remaining, maxTime);
  var scores = paths
      .map((path) => Tuple2(path.toSet(), pathScore(valves, path, maxTime)))
      .sorted((a, b) => b.item2 - a.item2);

  // Loop on each pair of paths, check if they don't have valves in common,
  // and keep track of the best score of disjoint paths
  var bestScore = 0;
  for (var fst in scores.take(scores.length - 1)) {
    // This optimization is very important.
    // Scores are sorted, so when reaching a score that is less than half the
    // current best, break, as its not possible to beat the best from here on
    if (fst.item2 < bestScore / 2) break;
    for (var snd in scores.skip(1)) {
      // If paths are disjoint, only the start node is common
      if (fst.item1.intersection(snd.item1).length == 1) {
        var score = fst.item2 + snd.item2;
        if (score > bestScore) {
          bestScore = score;
        }
      }
    }
  }
  return bestScore;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input16Test"
          : "data/input16";

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
