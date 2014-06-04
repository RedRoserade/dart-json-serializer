part of json_serializer;

class JsonEncoder<T, String> extends Converter<T, String> {

  ClassMirror _type;
  bool allowPrivateFields;
  bool allowGetters;

  JsonEncoder({this.allowPrivateFields: false, this.allowGetters: true}) {
    var m = reflect(this),
        t = m.type,
        args = t.typeArguments;

    _type = args[1];
  }

  @override
  String convert(T input) {
    // Test against String, num, bool or null. No need to reflect in this case.
    if (_isFieldAtomic(input)) return JSON.encode(input) as String;

    // For Lists, Maps, and Objects.
    return JSON.encode(_getValue(input)) as String;
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
  _getValue(instance) {
    // Test against String, num, bool or null.
    if (_isFieldAtomic(instance)) return instance;

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
//      ,
//          expectedType = reflect(instance).type.typeArguments[0];

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
  Map _getFields(object, [ClassMirror expectedType = null]) {

    InstanceMirror mirror = reflect(object);

    Map result = {};

    var type = mirror.type,
        // declarations = type.declarations,
        declarations = _getAllFields(type),
        vars = [];

    for (var d in declarations.keys) {
      if (declarations[d] is VariableMirror) {
        vars.add(d);
      }
    }

    // TODO: Deal with subtypes...

    for (var v in vars) {
      result[MirrorSystem.getName(v)] = _getValue(mirror.getField(v).reflectee);
    }

    return result;
  }
}