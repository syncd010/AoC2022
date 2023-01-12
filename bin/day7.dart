import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:aoc2022/common.dart';

Iterable<String> readInput(String path) {
  return File(path).readAsLinesSync();
}

Map<String, int> convert(Iterable<String> input) {
  var files = <String, int>{};
  var pwd = '';
  var cdRootRegExp = RegExp(r'\$ cd \/'),
      cdParentRegExp = RegExp(r'\$ cd \.\.'),
      cdDirRegExp = RegExp(r'\$ cd (\w+)'),
      fileRegExp = RegExp(r'(\d+) (.+)'),
      lastParentRegExp = RegExp(r'\/.+\/');
  for (var line in input) {
    if (cdRootRegExp.hasMatch(line)) {
      pwd = r'/';
    } else if (cdParentRegExp.hasMatch(line)) {
      pwd = pwd.substring(0, pwd.lastIndexOf(lastParentRegExp) + 1);
    } else if (cdDirRegExp.hasMatch(line)) {
      pwd += cdDirRegExp.firstMatch(line)![1]! + r"/";
    } else if (fileRegExp.hasMatch(line)) {
      var match = fileRegExp.firstMatch(line)!;
      files[pwd + match[2]!] = int.parse(match[1]!);
    }
  }
  return files;
}

Map<String, int> getDirsSize(Map<String, int> files) {
  var dirs = <String, int>{};
  files.forEach((key, value) {
    var path = '';
    key.substring(0, key.lastIndexOf('/')).split('/').forEach((d) {
      path += '$d/';
      dirs[path] = (dirs[path] ?? 0) + value;
    });
  });
  return dirs;
}

num solvePart1(Map<String, int> files) {
  return getDirsSize(files)
      .values
      .where((v) => v <= 100000)
      .reduce((a, b) => a + b);
}

num solvePart2(Map<String, int> files) {
  var dirsSize = getDirsSize(files);
  var unusedSz = 70000000 - dirsSize['/']!, neededSz = 30000000 - unusedSz;

  return dirsSize.values
      .sorted((a, b) => a - b)
      .where((v) => v >= neededSz)
      .first;
}

void main(List<String> arguments) {
  const testFlag = 'test';
  final parser = ArgParser()..addFlag(testFlag, abbr: 't', defaultsTo: false);
  ArgResults argResults = parser.parse(arguments);

  final filename = argResults.rest.isNotEmpty
      ? argResults.rest[0]
      : argResults[testFlag]
          ? "data/input7Test"
          : "data/input7";

  if (!FileSystemEntity.isFileSync(filename)) {
    stderr.writeln("File $filename doesn't exist.");
    exit(1);
  }

  var input = readInput(filename);
  var convertedInput = convert(input);

  print('First part is ${solvePart1(convertedInput)}');
  print('Second part is ${solvePart2(convertedInput)}');
}
