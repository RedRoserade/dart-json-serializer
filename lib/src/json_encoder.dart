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
  _getValue(r) {
    // Test against String, num, bool or null.
    if (_isFieldAtomic(r)) return r;

    // Test against a list.
    if (r is List) {
      return r.map((i) => _getValue(i)).toList(growable: false);
    }

    if (r is Map<String, dynamic>) {
      var result = {};

      r.keys.forEach((k) => result[k] = _getValue(r[k]));

      return result;
    }

    return _getFields(r);
  }

  /**
   * Gets the fields for an instance.
   */
  Map _getFields(object) {

    InstanceMirror mirror = reflect(object);

    Map result = {};

    var type = mirror.type,
        // declarations = type.declarations,
        declarations = _getAllFields(type),
        vars = declarations.keys.where((d) => declarations[d] is VariableMirror).toList();

    //    if (!_allowPrivateFields) {
    //      vars = vars.where((d) => !declarations[d].isPrivate).toList();
    //    }
    //
    //    if (_allowGetters) {
    //      vars.addAll(declarations.
    //          keys.where(
    //              (d) => declarations[d] is MethodMirror && (declarations[d] as MethodMirror).isGetter));
    //    }

    vars.forEach((v) => result[MirrorSystem.getName(v)] = _getValue(mirror.getField(v).reflectee));

    return result;
  }

}