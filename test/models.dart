class Person {
  final String SOME_CONSTANT = 'dowehf';

  String name;
  num age;

  List<Person> persons;

  List<int> ints;

  List<Pet> pets;
  Map<String, Tool> tools;

  Person([this.name, this.age]) {
    persons = [];
    pets = [];
    tools = {};
    ints = [];
  }
}

class Pet {
  String name;
  int age;

  String race;

  Pet([this.name, this.age, this.race]);
}

class Tool {
  String title;
  double price;

  Tool([this.title, this.price]);
}