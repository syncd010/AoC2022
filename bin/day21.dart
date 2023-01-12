import 'dart:io';
import 'package:args/args.dart';

List<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

class Operation {
  String? lhs, op, rhs;
  int? val;

  Operation(this.lhs, this.op, this.rhs, this.val);

  @override
  String toString() => lhs != null ? '$lhs $op $rhs' : '$val';
}

Map<String, Operation> convert(List<String> input) {
  return Map.fromEntries(input.map((line) {
    var parts = line.split(': ');
    var valDef = int.tryParse(parts[1]);
    var opDef = (valDef == null) ? parts[1].split(' ') : [null, null, null];
    return MapEntry(parts[0], Operation(opDef[0], opDef[1], opDef[2], valDef));
  }));
}

double calc(Map<String, Operation> map, String key) {
  var node = map[key]!;
  if (node.val != null) return node.val!.toDouble();
  switch (node.op!) {
    case '+':
      return calc(map, node.lhs!) + calc(map, node.rhs!);
    case '-':
      return calc(map, node.lhs!) - calc(map, node.rhs!);
    case '*':
      return calc(map, node.lhs!) * calc(map, node.rhs!);
    case '/':
      return calc(map, node.lhs!) / calc(map, node.rhs!);
  }
  return 0;
}

// Calc the differentials of the input operations map
Map<String, Operation> diff(Map<String, Operation> map, String variable) {
  var out = <String, Operation>{};

  map.forEach((key, value) {
    out[key] = value;
    if (key == variable) {
      out['d_$key'] = Operation(null, null, null, 1);
    } else if (value.val != null) {
      out['d_$key'] = Operation(null, null, null, 0);
    } else {
      switch (value.op) {
        case '+':
        case '-':
          out['d_$key'] =
              Operation('d_${value.lhs}', value.op, 'd_${value.rhs}', null);
          break;
        case '*':
          out['d_${key}_1'] = Operation('d_${value.lhs}', '*', value.rhs, null);
          out['d_${key}_2'] = Operation('d_${value.rhs}', '*', value.lhs, null);
          out['d_$key'] = Operation('d_${key}_1', '+', 'd_${key}_2', null);
          break;
        case '/':
          out['d_${key}_1'] = Operation('d_${value.lhs}', '*', value.rhs, null);
          out['d_${key}_2'] = Operation('d_${value.rhs}', '*', value.lhs, null);
          out['d_${key}_3'] = Operation('d_${key}_1', '-', 'd_${key}_2', null);
          out['d_${key}_4'] = Operation(value.rhs, '*', value.rhs, null);
          out['d_$key'] = Operation('d_${key}_3', '/', 'd_${key}_4', null);
          break;
      }
    }
  });
  return out;
}

num solvePart1(Map<String, Operation> input) {
  return calc(input, 'root').toInt();
}

num solvePart2(Map<String, Operation> input) {
  var diffMap = diff(input, 'humn');

  // Check which side has the variable
  var rootOp = diffMap['root']!;
  var rootLHS = calc(diffMap, rootOp.lhs!);
  var keyDiff = rootLHS != 0 ? rootOp.lhs! : rootOp.rhs!,
      keyVal = keyDiff == rootOp.lhs ? rootOp.rhs! : rootOp.lhs!;

  return diffMap['humn']!.val! +
      (calc(diffMap, keyVal) - calc(diffMap, keyDiff)) ~/
          calc(diffMap, 'd_$keyDiff');
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input21Test"
          : "data/input21";

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
