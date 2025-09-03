void main() {
  List<int> list = [1, 12, 31, 14, 51];

  list.forEach((n) => print(n));

  var mulBy10 = list.map((n) => n * 10);
  print(mulBy10);

  print("---- $list ----");

  var sum = list.reduce((acc, curr) => acc + curr);
  var smallest = list.reduce((acc, curr) => acc < curr ? acc : curr);
  var mulAll = list.reduce((acc, curr) => acc * curr);

  var evenNumbers = list.where((n) => n % 2 == 0);

  print(list);
  print(evenNumbers);

  /*
  acc =  1 : curr = 12
  acc = 13 : curr = 31
  acc = 44 : curr = 14
  acc = 58 : curr = 51
  acc = 110 : curr = null
  */
}
