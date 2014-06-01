import '../lib/json_serializer.dart';

class Person {
  String name;
  int age;

  List<Pet> pets;
  List<Person> relatives;

  Person([this.name, this.age]) {
    pets = [];
    relatives = [];
  }

  String toString() {
    return '$name is $age-years old.';
  }
}

class Student extends Person {

  Student([String name, int age, this.grade]) : super(name, age);

  int grade;

  String toString() {
    return '$name is $age-years old and is on year ${grade}';
  }
}

class Pet {
  String name;
  int age;
  String species;

  Pet([this.name, this.age, this.species]);

  String toString() {
    return '${name} is a ${age}-year old ${species}.';
  }
}

main() {
  // Instantiate the codec
  var codec = new JsonCodec<Person>();

  var p = new Person('A Person', 20);

  p.pets.add(new Pet('Garfield', 5, 'Cat'));

  p.relatives.add(new Person('Another Person', 45));

  p.relatives.add(new Student('Another Person which is a Student', 15, 9));

  // Encode an object to a String
  var json = codec.encode(p);

  print(json);
  // Yields {"name":"A Person","age":20,"pets":[{"name":"Garfield","age":5,"species":"Cat"}],"relatives":[{"name":"Another Person","age":45,"pets":[],"relatives":[]},{"grade":9,"name":"Another Person which is a Student","age":15,"pets":[],"relatives":[]}]}

  // Decode the string back into an object.
  var decodedPerson = codec.decode(json);

  print(decodedPerson.relatives);
  // Another Person is 45-years old.




  print(decodedPerson.pets);
  // [Garfield is a 5-year old cat.]
}