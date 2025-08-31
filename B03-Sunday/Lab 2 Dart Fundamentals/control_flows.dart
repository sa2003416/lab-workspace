void main() {
  int x = 10;
  if (x > 5) {
    print("x is greater than 5");
  } else if (x == 5) {
    print("x is equal to 5");
  } else {
    print("x is less than or equal to 5");
  }

  switch (x) {
    case 5:
      print("x is 5");
      break;
    case 10:
      print("x is 10");
      break;
    default:
      print("x is neither 5 nor 10");
  }

  x = 40;

  String result = switch (x) {
    > 20 && < 40 => "x is between 20 and 40",
    _ => "x is not greater than 40",
  };

  print(result);
}
