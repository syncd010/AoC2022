import 'dart:io';
import 'package:args/args.dart';
import 'package:tuple/tuple.dart';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:aoc2022/common.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

final NONE = ' '.codeUnitAt(0),
    EMPTY = '.'.codeUnitAt(0),
    WALL = '#'.codeUnitAt(0);

Tuple2<List<List<int>>, String> convert(List<String> input) {
  return Tuple2(
      input
          .takeWhile((line) => line.isNotEmpty)
          .map((line) => line.codeUnits)
          .toList(),
      input.last);
}

// Directions
List<Position> dirs = [
  Position(1, 0),
  Position(0, 1),
  Position(-1, 0),
  Position(0, -1)
];

// Squares and surrounds a map with none cells to facilitate manipulations
List<List<int>> squareAndSurround(List<List<int>> map) {
  var maxLen = 2 + map.fold(0, ((acc, e) => max(acc, e.length)));
  var surrounded = map
      .map((e) => [
            NONE,
            ...e,
            ...[for (var i = 0; i < maxLen - e.length - 1; i++) NONE]
          ])
      .toList();

  var emptyRow = [for (var i = 0; i < maxLen; i++) NONE];
  return surrounded
    ..insert(0, emptyRow)
    ..add(emptyRow);
}

// Follow the path through the map, using wrapAround when reaching limits
Tuple2<Position, int> walk(List<List<int>> map, String path,
    Tuple2<Position, int> Function(List<List<int>>, Position, int) wrapAround) {
  var regExp = RegExp(r'R|L');
  var pos = Position(map[1].indexOf(EMPTY), 1), dir = 0;

  // Separate the path
  var stepsList = path.split(regExp).map((e) => int.parse(e)).toList();
  var dirsList = regExp.allMatches(path).map((e) => e[0]!).toList();

  for (var i = 0; i < stepsList.length; i++) {
    for (var s = 0; s < stepsList[i]; s++) {
      var nextPos = pos + dirs[dir];
      var cell = map[nextPos.y][nextPos.x];
      if (cell == EMPTY) {
        pos = nextPos;
      } else if (cell == NONE) {
        var aux = wrapAround(map, pos, dir);
        pos = aux.item1;
        dir = aux.item2;
      } else {
        break;
      }
    }

    // Rotate
    if (i < dirsList.length) {
      dir = (dirsList[i] == 'R' ? dir + 1 : dir - 1) % dirs.length;
    }
  }
  return Tuple2(pos, dir);
}

num solvePart1(Tuple2<List<List<int>>, String> input) {
  var mapSz =
      sqrt(input.item1.map((l) => l.where((e) => e != NONE).length).sum ~/ 6)
          .toInt();

  Tuple2<Position, int> wrapAround(List<List<int>> map, Position pos, int dir) {
    // Walk back until a limit is found
    var backPos = pos;
    while (map[backPos.y][backPos.x] != NONE) {
      backPos = backPos - dirs[dir] * mapSz;
    }
    // Walked one too much
    var nextPos = backPos + dirs[dir];
    // Check if possible
    if (map[nextPos.y][nextPos.x] == EMPTY) pos = nextPos;
    return Tuple2(pos, dir);
  }

  var res = walk(squareAndSurround(input.item1), input.item2, wrapAround);
  return 1000 * res.item1.y + 4 * res.item1.x + res.item2;
}

// Very simple complex number representation, suitable for rotations
class Complex {
  int real, imag;

  Complex(this.real, this.imag);

  Complex operator +(Complex other) =>
      Complex(real + other.real, imag + other.imag);
  Complex operator *(Complex other) => Complex(
      real * other.real - imag * other.imag,
      real * other.imag + imag * other.real);

  @override
  String toString() => real != 0 && imag != 0
      ? "$real + ${imag}i"
      : real != 0
          ? "$real"
          : imag == 1
              ? "i"
              : imag == -1
                  ? "-i"
                  : "${imag}i";
}

extension PositionAux on Position {
  Position rotate(Complex? rot) {
    if (rot == null) return this;
    var aux = Complex(x, y) * rot;
    return Position(aux.real.toInt(), aux.imag.toInt());
  }
}

// Face representation
class Face {
  int id;
  var neighbors = <int?>[null, null, null, null];
  var rotations = <Complex?>[null, null, null, null];
  var position = Position.origin();

  Face(this.id);

  @override
  String toString() =>
      'Face $id, position: $position, neighbors: $neighbors, rotations: $rotations]';
}

// Folds the cube, returning its face specifications
Map<int, Face> foldCube(List<List<int>> map, int mapSz) {
  var faces = <int, Face>{};
  var auxDirs = <Position>[
    Position(mapSz, 0),
    Position(0, mapSz),
    Position(-1, 0),
    Position(0, -1)
  ];
  var width = (map[0].length - 2) ~/ mapSz, height = (map.length - 2) ~/ mapSz;

  // Get faces from map
  for (var row = 0; row < height; row++) {
    for (var col = 0; col < width; col++) {
      var mapRow = 1 + row * mapSz, mapCol = 1 + col * mapSz;
      if (map[mapRow][mapCol] != NONE) {
        var face = Face(row * width + col);
        for (var i = 0; i < auxDirs.length; i++) {
          if (map[mapRow + auxDirs[i].y][mapCol + auxDirs[i].x] != NONE) {
            face.neighbors[i] = (row + dirs[i].y) * width + col + dirs[i].x;
            face.rotations[i] = Complex(1, 0);
            face.position = Position(mapCol, mapRow);
          }
        }
        faces[face.id] = face;
      }
    }
  }

  // Fold map faces
  var unfilled = faces.values.where((f) => f.neighbors.any((n) => n == null));
  while (unfilled.isNotEmpty) {
    for (var face in unfilled) {
      for (var idx = 0; idx < dirs.length; idx++) {
        // Try to find this dir's face based on the previous dir face
        var prev = (idx - 1) % dirs.length;
        var prevDir = dirs.indexOf(dirs[idx].rotate(face.rotations[prev]));
        if (face.neighbors[idx] == null &&
            face.neighbors[prev] != null &&
            faces[face.neighbors[prev]]!.neighbors[prevDir] != null) {
          face.neighbors[idx] = faces[face.neighbors[prev]]!.neighbors[prevDir];
          face.rotations[idx] = face.rotations[prev]! *
              faces[face.neighbors[prev]]!.rotations[prevDir]! *
              Complex(0, -1);
        }
      }
    }
    unfilled = faces.values.where((f) => f.neighbors.any((n) => n == null));
  }

  return faces;
}

num solvePart2(Tuple2<List<List<int>>, String> input) {
  var map = squareAndSurround(input.item1);
  var mapSz =
      sqrt(map.map((l) => l.where((e) => e != NONE).length).sum ~/ 6).toInt();
  var faces = foldCube(map, mapSz);

  // Wraps around the cube with the info in the folded faces
  Tuple2<Position, int> wrapAround(List<List<int>> map, Position pos, int dir) {
    var width = (map[0].length - 2) ~/ mapSz;

    var face = faces[((pos.y - 1) ~/ mapSz) * width + (pos.x - 1) ~/ mapSz]!;
    var rotation = face.rotations[dir]!;
    var nextDir = dirs.indexOf(dirs[dir].rotate(rotation));

    // Check whether x or y will be inverted
    var invertedX = (nextDir == 1 || nextDir == 3) &&
            (rotation.real == -1 || rotation.imag == 1),
        invertedY = (nextDir == 0 || nextDir == 2) &&
            (rotation.real == -1 || rotation.imag == -1);
    var offset = Position(nextDir == 2 || invertedX ? mapSz - 1 : 0,
        nextDir == 3 || invertedY ? mapSz - 1 : 0);

    // Project pos onto x-y axis centered on face (0, 0) position, rotate and
    // translate to next face start
    var nextPos = (pos - face.position)
            .projectTo(dirs[dir].y != 0 ? 0 : 1)
            .rotate(rotation) +
        faces[face.neighbors[dir]]!.position +
        offset;

    // Check if possible
    if (map[nextPos.y][nextPos.x] == EMPTY) {
      // print('Wrapping from $pos to $nextPos, new dir $nextDir');
      pos = nextPos;
      dir = nextDir;
    }

    return Tuple2(pos, dir);
  }

  // faces.values.forEach(print);
  var res = walk(squareAndSurround(input.item1), input.item2, wrapAround);
  return 1000 * res.item1.y + 4 * res.item1.x + res.item2;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input22Test"
          : "data/input22";

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
