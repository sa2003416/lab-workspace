import 'dart:math';

import 'package:my_library/my_library.dart' as my_library;

void main(List<String> arguments) {
  print('Hello world: ${my_library.calculate()}!');

  List<int> numbers = [1, 2, 3, 4, 5, 6];

  var mapped = numbers.map((n) => "-$n");
  var mapped2 = numbers.map((n) => pow(n, 2));
  print(mapped);
  print(mapped2);
}
