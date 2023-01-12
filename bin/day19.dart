import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:aoc2022/common.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

class Blueprint {
  int id, oreOre, clayOre, obsidianOre, obsidianClay, geodeOre, geodeObsidian;
  int maxOre = 0;

  Blueprint(this.id, this.oreOre, this.clayOre, this.obsidianOre,
      this.obsidianClay, this.geodeOre, this.geodeObsidian) {
    maxOre = [oreOre, clayOre, obsidianOre, geodeOre].max;
  }

  @override
  String toString() => '[id: $id, Ore Ore: $oreOre, Clay Ore: $clayOre, '
      'Obsidian Ore: $obsidianOre, Obsidian Clay: $obsidianClay, '
      'Geode Ore: $geodeOre, Geode Obsidian: $geodeObsidian]';
}

List<Blueprint> convert(List<String> input) {
  return input.map((line) {
    var matches =
        RegExp(r'(\d+)').allMatches(line).map((m) => int.parse(m[0]!)).toList();
    return Blueprint(matches[0], matches[1], matches[2], matches[3], matches[4],
        matches[5], matches[6]);
  }).toList();
}

class State {
  int time;
  int ore, clay, obsidian, geode;
  int oreRobots, clayRobots, obsidianRobots, geodeRobots;

  State(this.time, this.ore, this.clay, this.obsidian, this.geode,
      this.oreRobots, this.clayRobots, this.obsidianRobots, this.geodeRobots);
  State.from(State other)
      : time = other.time,
        ore = other.ore,
        clay = other.clay,
        obsidian = other.obsidian,
        geode = other.geode,
        oreRobots = other.oreRobots,
        clayRobots = other.clayRobots,
        obsidianRobots = other.obsidianRobots,
        geodeRobots = other.geodeRobots;

  State evolve() {
    return State(
        time + 1,
        ore + oreRobots,
        clay + clayRobots,
        obsidian + obsidianRobots,
        geode + geodeRobots,
        oreRobots,
        clayRobots,
        obsidianRobots,
        geodeRobots);
  }

  @override
  String toString() =>
      'Time: $time - Res: [$ore $clay $obsidian $geode] - Robots: [$oreRobots $clayRobots $obsidianRobots $geodeRobots]';

  @override
  int get hashCode => Object.hash(time, ore, clay, obsidian, geode, oreRobots,
      clayRobots, obsidianRobots, geodeRobots);
}

List<State> Function(State) successorsFn(Blueprint blueprint) {
  return (state) {
    var out = <State>[];
    var evolved = state.evolve();

    // Stop expanding states with more resources than we need to build something
    if ((state.ore <= blueprint.oreOre) ||
        (state.ore <= blueprint.clayOre) ||
        (state.ore <= blueprint.obsidianOre &&
            state.clay <= blueprint.obsidianClay) ||
        (state.ore <= blueprint.geodeOre &&
            state.obsidian <= blueprint.geodeObsidian)) {
      out.add(evolved);
    }

    // Geode robots
    if (state.ore >= blueprint.geodeOre &&
        state.obsidian >= blueprint.geodeObsidian) {
      var robotState = State.from(evolved);
      robotState.ore -= blueprint.geodeOre;
      robotState.obsidian -= blueprint.geodeObsidian;
      robotState.geodeRobots++;
      out.add(robotState);
    }

    // Obsidian robots, only if max not reached
    if (state.ore >= blueprint.obsidianOre &&
        state.clay >= blueprint.obsidianClay &&
        state.obsidianRobots <= blueprint.geodeObsidian) {
      var robotState = State.from(evolved);
      robotState.ore -= blueprint.obsidianOre;
      robotState.clay -= blueprint.obsidianClay;
      robotState.obsidianRobots++;
      out.add(robotState);
    }

    // Clay robots, only if max not reached
    if (state.ore >= blueprint.clayOre &&
        state.clayRobots <= blueprint.obsidianClay) {
      var robotState = State.from(evolved);
      robotState.ore -= blueprint.clayOre;
      robotState.clayRobots++;
      out.add(robotState);
    }

    // Ore robots, only if max not reached
    if (state.ore >= blueprint.oreOre && state.oreRobots <= blueprint.maxOre) {
      var robotState = State.from(evolved);
      robotState.ore -= blueprint.oreOre;
      robotState.oreRobots++;
      out.add(robotState);
    }

    return out;
  };
}

// Score for A*
int Function(State) getScoreFn(int maxTime) => (state) {
      var timeRemaining = maxTime + 1 - state.time;
      // Current geodes + what will definitely be built + best case scenario
      return state.geode +
          state.geodeRobots * timeRemaining +
          (timeRemaining - 1) * timeRemaining ~/ 2;
    };

bool Function(State) getGoalFn(int maxTime) => (state) {
      return state.time > maxTime;
    };

num solvePart1(List<Blueprint> input) {
  var out = 0, maxTime = 24;
  var initial = State(1, 0, 0, 0, 0, 1, 0, 0, 0);
  var scoreFn = getScoreFn(maxTime);
  for (var i = 0; i < input.length; i++) {
    var max = aStarSearch(initial, successorsFn(input[i]), getGoalFn(maxTime),
        (p0, p1) => scoreFn(p1) - scoreFn(p0));
    out += (i + 1) * max!.geode;
  }
  return out;
}

num solvePart2(List<Blueprint> input) {
  var out = 1, maxTime = 32;
  var initial = State(1, 0, 0, 0, 0, 1, 0, 0, 0);
  var scoreFn = getScoreFn(maxTime);
  for (var i = 0; i < min(input.length, 3); i++) {
    var max = aStarSearch(initial, successorsFn(input[i]), getGoalFn(maxTime),
        (p0, p1) => scoreFn(p1) - scoreFn(p0));
    out *= max!.geode;
  }
  return out;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input19Test"
          : "data/input19";

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
