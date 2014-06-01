part of json_serializer;

/// Decodes a String into an object.
class JsonDecoder<String, T> extends Converter<String, T> {

  ClassMirror _type;

  JsonDecoder() {
    _type = reflect(this).type.typeArguments[1];
  }

  @override
  T convert(input) {
    var json = JSON.decode(input);
    var result;

    // Test against String, num, bool, or null.
    if (_isFieldAtomic(json)) {
      return json;
    }

    // If the Json is a list, we'll return
    // a List containing all the values of it.
    if (json is List) {
      return json.map(_getValue);
    }

    // We have a Map, and need to decode it.

    // We can't instantiate abstract classes.
    if (_type.isAbstract) throw 'The type "${_type.reflectedType} is abstract.';

    // Invoke the default construtor on the class.
    // TODO: Probably make this more bullet-proof when constructors
    //       have explicit arguments.
    InstanceMirror mirror = _type.newInstance(new Symbol(''), []);

    (json as Map).keys.forEach((String k) {
      var s = new Symbol(k);

      // Only assign values to non-final fields.
      if (!(_type.declarations[s] as VariableMirror).isFinal) {
        mirror.setField(s, _getValue(json[k], k, _type));
      }
    });

    return mirror.reflectee;
  }

  _getValue(source, [String key = null, ClassMirror type]) {
    // Test against String, num, bool or null.
    if (_isFieldAtomic(source)) return source;

    // Test against a list.
    if (source is List) {
      var typeArg = (type.declarations[new Symbol(key)] as VariableMirror).type.typeArguments[0];

      if (typeArg is! ClassMirror) throw new SerializerException(source);

      return source.map((i) => _getValue(i, null, typeArg)).toList(growable: false);
    }

    if (source is Map<String, dynamic>) {
      if (key != null) {
        // var declarations = type.declarations,
        var declarations = _getAllFields(type),
            declaration = declarations[declarations.keys.firstWhere((d) => MirrorSystem.getName(d) == key)] as VariableMirror;

        type = declaration.type;
      }

      var mirror = null;

      try {
        mirror = type.newInstance(new Symbol(''), []);
      } on Error {
        // We can't infer anything on 'dynamic'.
        throw new SerializerException(source);
      }

      // If the field is a Map, we'll just assign the fields
      // directly to it.
      if (mirror.reflectee is Map) {
        Map m = mirror.reflectee;
        source.keys.forEach((k) {
          var t = mirror.type.typeArguments[1];

          m[k] = _getValue(source[k], null, t);
        });

        return m;
      }

      // We have an object.
      source.keys.forEach((k) {
        var s = new Symbol(k),
            declaration = type.declarations[s];

        // Do not assign values to final fields.
        if (declaration != null && !(declaration as VariableMirror).isFinal) {
          mirror.setField(s, _getValue(source[k], k, type));
        }
      });

      return mirror.reflectee;
    }
  }
}
