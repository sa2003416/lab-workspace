void main() {
  int age = 20;

  if (age < 13) {
    print("You are a kid");
  } else if (age > 13 && age < 20) {
    print("You are a teenager");
  } else {
    print("You are an adult");
  }

  var result = switch (age) {
    < 13 => "You are a kid",
    > 13 && < 20 => "You are a teenager",
    _ => "You are an adult",
  };

  print("result : $result");

  String day = "Monday";
  switch (day) {
    case "Monday":
      print("second day of the week");
      break;
    case "Tuesday":
      print("third day of the week");
      break;
    //....
    default:
      print("not a day of the week");
  }

  int x = 10;
  bool isEven = x % 2 == 0 ? true : false;
  print("isEven : $isEven");
}
