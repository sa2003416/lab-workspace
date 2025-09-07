import 'package:library_app/library_app.dart' as library_app;

void main(List<String> arguments) {
  print('Hello world: ${library_app.calculate()}!');

  Pigeon p = Pigeon();
  p.canFly();
}

// class Animal {}


// class Cat extends Animal {}

// class Eagle extends Animal with Flyable {}

// class Pigeon extends Animal with Flyable {}

// class Penguin extends Animal with Flyable {}


// mixin Flyable {
//   void canFly() {
//     print("I can fly");
//   }
// }
