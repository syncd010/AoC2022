import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

class Instruction {
  final String op;
  final int val;

  Instruction(this.op, [this.val = 0]);

  @override
  String toString() => '$op $val';
}

Iterable<Instruction> convert(Iterable<String> input) {
  return input.map((e) {
    var parts = e.split(' ');
    return Instruction(parts[0], (parts.length > 1) ? int.parse(parts[1]) : 0);
  });
}

num solvePart1(Iterable<Instruction> program) {
  var regX = 1, cycle = 1, strength = 0;

  for (var inst in program) {
    if (cycle >= 20) {
      if ((cycle - 20) % 40 == 0) {
        strength += cycle * regX;
      } else if ((inst.op == 'addx') && (cycle - 19) % 40 == 0) {
        strength += (cycle + 1) * regX;
      }
    }
    switch (inst.op) {
      case 'noop':
        cycle++;
        break;
      case 'addx':
        regX += inst.val;
        cycle += 2;
    }
  }
  return strength;
}

num solvePart2(Iterable<Instruction> program) {
  var regX = 1, cycle = 0;
  var crt = [for (var i = 0; i < 240; i++) '.'];

  void updateCrt(int cycle, int regX) {
    crt[cycle] = ((regX - (cycle % 40)).abs() < 2) ? '#' : '.';
  }

  for (var inst in program) {
    switch (inst.op) {
      case 'noop':
        updateCrt(cycle, regX);
        cycle++;
        break;
      case 'addx':
        updateCrt(cycle, regX);
        updateCrt(cycle + 1, regX);
        regX += inst.val;
        cycle += 2;
    }
  }
  crt.slices(40).forEach((e) => print(e.join('')));
  return 0;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input10Test"
          : "data/input10";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
