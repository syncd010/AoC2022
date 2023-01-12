import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';
import 'package:aoc2022/common.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

class SensorInfo {
  Position sensorPos, beaconPos;
  SensorInfo(this.sensorPos, this.beaconPos);
}

List<SensorInfo> convert(List<String> input) {
  return input.map((line) {
    var points = RegExp(r'x=(-?\d+), y=(-?\d+)')
        .allMatches(line)
        .map((m) => Position(int.parse(m.group(1)!), int.parse(m.group(2)!)))
        .toList();

    return SensorInfo(points[0], points[1]);
  }).toList();
}

// Used to represent a range/interval
typedef Range = Tuple2<int, int>;

// Merges the input ranges where they overlap, returning only continuous ranges
List<Range> mergeRanges(List<Range> ranges) {
  if (ranges.isEmpty) return ranges;

  var sortedRanges = ranges.sorted((a, b) => a.item1 - b.item1);

  var out = <Range>[sortedRanges[0]];
  for (var next in sortedRanges.skip(1)) {
    if (next.item1 <= out.last.item2 + 1) {
      var last = out.removeLast();
      out.add(last.withItem2(max(next.item2, last.item2)));
    } else {
      out.add(next);
    }
  }
  return out;
}

// Returns the continuous ranges that cover a specific line
List<Range> getRowCoverage(List<SensorInfo> sensors, int targetRow) {
  var ranges = <Range>[];
  for (var s in sensors) {
    var dist = s.sensorPos.manhattanDistanceTo(s.beaconPos),
        horizDist = dist - (targetRow - s.sensorPos.y).abs();
    // Add positions from the sensor x pos to the horizontal distance calculated
    if (horizDist >= 0) {
      ranges.add(Tuple2(s.sensorPos.x - horizDist, s.sensorPos.x + horizDist));
    }
  }
  return mergeRanges(ranges);
}

num solvePart1(List<SensorInfo> sensors, bool test) {
  var targetRow = test ? 10 : 2000000;
  // Get coverage for the row and subtract the beacons that are on that row
  var ranges = getRowCoverage(sensors, targetRow);
  var beaconsOnTargetRow = {sensors.where((s) => s.beaconPos.y == targetRow)};
  return (ranges.fold(0, (acc, r) => acc + (r.item2 - r.item1) + 1) -
      beaconsOnTargetRow.length);
}

num solvePart2(List<SensorInfo> sensors, bool test) {
  var maxRow = test ? 20 : 4000000, maxCol = maxRow;

  for (var row = 0; row <= maxRow; row++) {
    // Get coverage for the row and truncate to [0, maxCol]
    var ranges = getRowCoverage(sensors, row)
        .where((r) => (r.item2 >= 0 && r.item1 <= maxCol));
    // Bug here: if either the 0 or maxCol position are empty, they aren't
    // reported, eg [1, maxCol] has space on 0 but isn't reported. Ignored...
    if (ranges.length > 1) {
      return (min(maxCol, ranges.first.item2) + 1) * 4000000 + row;
    }
  }
  return -1;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input15Test"
          : "data/input15";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  var stopwatch = Stopwatch()..start();
  print(
      'First part is ${solvePart1(convertedInput, argResults[testFlag])} (${stopwatch.elapsed})');
  stopwatch.reset();
  print(
      'Second part is ${solvePart2(convertedInput, argResults[testFlag])} (${stopwatch.elapsed})');
  stopwatch.stop();
}
