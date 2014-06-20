import '../lib/json_serializer.dart';

class Person {
  String name;
  int age;
  
  Person([this.name, this.age]);
  
  Person.fromJson(Map json) {
    name = json['name'];
    age = json['age'];
  }
  
  Map toJson() {
    return {
      'name': name,
      'age': age
    };
  }

  @override String toString() {
    return 'This person has name $name and is $age years old.';
  }
}


main() {
  var codec = new JsonCodec<Person>();
  
  var p = new Person('Test', 20);
  
  var str = codec.encode(p);
  
  print(str);
  
  var pDecoded = codec.decode(str);
  
  print(pDecoded);
}