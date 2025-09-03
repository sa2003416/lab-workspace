void main() {
  int x = 2;
  int y = 3;
  print(add(x, y));
  print(add(2, 3));
  // print(add3(2, 3));
  print(add4(2, 3));

  print(operation(2, 3, sub1));
  print(operation(2, 3, (a, b) => a - b));
  print(operation(2, 3, (a, b) => a + b));
  print(operation(2, 3, (a, b) => a * b));
  print(operation(2.0, 3.0, (a, b) => a / b));
}

operation(a, b, fun) {
  // A LOT OF CODE BEFORE THIS
  return fun(a, b);
}

var add4 = (a, b) => a + b;
var sub1 = (a, b) => a - b;

int sub(a, b) {
  return a - b;
}

int add(int a, int b) {
  return a + b;
}

int add2(a, b) {
  return a + b;
}

int add3(a, b) => a + b;
