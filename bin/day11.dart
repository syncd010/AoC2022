import 'dart:io';
import 'package:args/args.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

class Monkey {
  final int id;
  List<int> items = [];
  List<String> operation = [];
  int divisibilityTest = 0;
  int monkeyIdTrue = 0, monkeyIdFalse = 0;

  Monkey(this.id);

  @override
  String toString() =>
      '[Monkey $id:, Items: $items, Operation: $operation, Test: $divisibilityTest, True: $monkeyIdTrue, False: $monkeyIdFalse]';
}

List<Monkey> convert(Iterable<String> input) {
  var monkeys = <Monkey>[];
  for (var line in input) {
    if (line.startsWith('Monkey ')) {
      monkeys.add(Monkey(int.parse(line.substring(7, line.length - 1))));
    } else if (line.contains('Starting items:')) {
      monkeys.last.items =
          line.substring(18).split(', ').map(int.parse).toList();
    } else if (line.contains('Operation:')) {
      monkeys.last.operation = line.substring(19).split(' ');
    } else if (line.contains('Test:')) {
      monkeys.last.divisibilityTest = int.parse(line.substring(21));
    } else if (line.contains('If true:')) {
      monkeys.last.monkeyIdTrue = int.parse(line.substring(29));
    } else if (line.contains('If false:')) {
      monkeys.last.monkeyIdFalse = int.parse(line.substring(30));
    }
  }
  return monkeys;
}

int applyOp(int item, List<String> operation) {
  var op2 = (operation[2] == 'old') ? item : int.parse(operation[2]);
  var ret = (operation[1] == '+') ? item + op2 : item * op2;
  return ret;
}

// Thows items, making sure to divide the 'worry level' by divideBy and
// modding it by modBy, so that we don't overflow
num throwItems(List<Monkey> monkeys, int divideBy, int modBy, int rounds) {
  var ret = [for (var i = 0; i < monkeys.length; i++) 0];
  var monkeyItems = [
    for (var m in monkeys) [...m.items]
  ];

  for (var round = 0; round < rounds; round++) {
    for (var i = 0; i < monkeys.length; i++) {
      // In case the monkey throws to himself
      var items = monkeyItems[i];
      monkeyItems[i] = [];
      ret[i] += items.length;
      for (var item in items) {
        var newItem = (applyOp(item, monkeys[i].operation) ~/ divideBy) % modBy;
        if (newItem < 0) print('Overflow!!');
        assert(newItem >= 0);
        var monkeyId = (newItem % monkeys[i].divisibilityTest == 0)
            ? monkeys[i].monkeyIdTrue
            : monkeys[i].monkeyIdFalse;
        monkeyItems[monkeyId].add(newItem);
      }
    }
  }
  ret.sort(((a, b) => b - a));
  return ret[0] * ret[1];
}

num solvePart1(List<Monkey> monkeys) {
  // divideBy 3, don't mod
  return throwItems(monkeys, 3, 1, 20);
}

num solvePart2(List<Monkey> monkeys) {
  int modBy = monkeys.fold(1, (val, m) => val * m.divisibilityTest);
  // Don't divide, mod by the product of the monkey tests, which are prime
  return throwItems(monkeys, 1, modBy, 10000);
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input11Test"
          : "data/input11";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
