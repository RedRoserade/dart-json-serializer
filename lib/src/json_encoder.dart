part of json_serializer;

class JsonSerializer<T, String> extends Converter<T, String> {

  ClassMirror _type;
  bool allowPrivateFields;
  bool allowGetters;
  
  final Logger _log = new Logger('JsonSerializer');

  JsonSerializer({this.allowPrivateFields: false, this.allowGetters: true}) {
    var m = reflect(this),
        t = m.type,
        args = t.typeArguments;

    _type = args[1];
  }
  @override
  String convert(T input) {
    return JSON.encode(_getValue(input));
  }

  /**
   * Gets a field for an instance.
   * If the field is a String, num, bool, or null, then that field
   * is returned.
   *
   * If the field is a List, then a List is returned.
   * If the field is an object or a map, then it's reflected
   * again and a Map is returned.
   */
  _getValue(dynamic instance) {
    // Test against String, num, bool or null.
    if (_isFieldAtomic(instance)) return instance;
    
    
    // Check if the instance has a "toJson()" method.
    try {
      _log.finest('Attempting to use toJson()');
      return instance.toJson();
    } on NoSuchMethodError { 
      /* NO-OP */
      _log.finest('toJson() unsuccessful.');
    }

    // Test against a list.
    if (instance is List) {
      var result = new List(instance.length),
          expectedType = reflect(instance).type.typeArguments[0];

      for (var i = 0; i < result.length; i++) {
        result[i] = _getValue(instance[i]);
      }

      return result;
    }

    
    if (instance is Map<String, Object>) {
      var result = {};

      for (var k in instance.keys) {
        result[k] = _getValue(instance[k]);
      }

      return result;
    }

    return _getFields(instance);
  }

  /**
   * Gets the fields for an instance.
   */
  Map _getFields(dynamic object, [ClassMirror expectedType = null]) {

    InstanceMirror mirror = reflect(object);

    Map result = {};

    var type = mirror.type,
        declarations = _getAllFields(type);

    for (var d in declarations.keys) {
      if (declarations[d] is VariableMirror) {
        result[MirrorSystem.getName(d)] = _getValue(mirror.getField(d).reflectee);
      }
    }

    return result;
  }
}
