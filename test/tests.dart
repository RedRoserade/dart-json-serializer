import '../lib/json_serializer.dart';
import 'models.dart';

main() {
  var iters = 50000;

  var p = new Person('Some person', 20);

  var persons = [new Person('Another person', 45), new Person('Yet another person', 45)];
  p.persons.addAll(persons);

  Student s = new Student('A Student', 10, 5);

  p.persons.add(s);

  p.pets.addAll([new Pet('Pirolito', 10, 'Cat'), new Pet('Guida', 8, 'Cat')]);
  p.ints = [1,2,3,4,5];

  p.tools['pen'] = new Tool('Some BIC', 0.65);
  p.tools['laptop'] = new Tool('Insys GameForce 8761SU', 860.00);

//  print(p);

  var c = new JsonCodec<Person>();

  var json = c.encode(p, allowGetters: true, allowPrivateFields: false);

//  c.encoder.printTimes();

  print(json);

  Stopwatch stopwatch = new Stopwatch();

  Person decodedPerson;

  stopwatch.start();

  for (var i = 0; i < iters; i++) {
    decodedPerson = c.decode(json);
  }

  stopwatch.stop();

  print(stopwatch.elapsed);



  print('$iters took ${stopwatch.elapsed}. Iterations/second: ${iters * 1000.0 / stopwatch.elapsed.inMilliseconds}');

  print(decodedPerson.name);
  print(decodedPerson.pets.map((p) => p.name).toList());
  print(decodedPerson.ints);

  print((p.persons[2] as Student).grade);

  print(decodedPerson.tools.keys.map((k) => '$k: ${p.tools[k].title} with price ${p.tools[k].price}'));
}