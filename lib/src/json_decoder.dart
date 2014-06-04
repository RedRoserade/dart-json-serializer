part of json_serializer;

/// Decodes a String into an instance of [T].
class JsonDecoder<String, T> extends Converter<String, T> {

  ClassMirror _type;

  JsonDecoder() {
    _type = reflect(this).type.typeArguments[1];
  }

  @override
  T convert(String input) {
    // I know I'm using the JSON codec. It works.
    var json = JSON.decode(input);
    var result;

    // Test against String, num, bool, or null.
    // If the reflected type is a Map, return a Map.
    if (_isFieldAtomic(json) || _type.reflectedType is Map) {
      return json;
    }

    // If the Json is a list, we'll return
    // a List containing all the values of it.
    if (json is List) {
      var result = new List(json.length);

      for (var i = 0; i < json.length; i++) {
        result[i] = _getValue(json[i]);
      }
      return result;
    }

    // We can't instantiate abstract classes.
    if (_type.isAbstract) throw 'The type "${_type.reflectedType} is abstract.';

    // Invoke the default construtor on the class.
    // TODO: Probably make this more bullet-proof when constructors
    //       have explicit arguments.
    InstanceMirror mirror = _type.newInstance(new Symbol(''), []);

    if (json is Map) {
      for (var k in json.keys) {
        var s = new Symbol(k);

        if (!(_type.declarations[s] as VariableMirror).isFinal) {
          mirror.setField(s, _getValue(json[k], k, _type));
        }
      }

    } else {
      throw 'Unknown type';
    }

    return mirror.reflectee;
  }

  _getValue(source, [String key = null, ClassMirror type]) {
    // Test against String, num, bool or null.
    if (_isFieldAtomic(source)) return source;

    // Test against a list.
    if (source is List) {
      var typeArg = (type.declarations[new Symbol(key)] as VariableMirror).type.typeArguments[0];

      if (typeArg is! ClassMirror) throw new SerializerException(source);

      var result = new List(source.length);

      for (var i = 0; i < result.length; i++) {
        result[i] = _getValue(source[i], null, typeArg);
      }

      return result;
    }

    if (source is Map<String, dynamic>) {
      if (key != null) {

        var declarations = _getAllFields(type);

        VariableMirror declaration = declarations[new Symbol(key)];

        if (key == null) {
          throw 'Unknown field $key';
        }

        type = declaration.type;
      }

      var mirror = null;

      try {
        // TODO: This needs to allow constructors with parameters.
        mirror = type.newInstance(new Symbol(''), []);
      } on Error {
        // We can't infer anything on 'dynamic'.
        // TODO: Perhaps return a Map?
        throw new SerializerException(source);
      }

      // If the field is a Map, we'll just assign the fields
      // directly to it.
      if (mirror.reflectee is Map) {
        var t = mirror.type.typeArguments[1];

        Map m = mirror.reflectee;

        for (var k in source.keys) {
          // We'll attempt to get a value because the
          // value may not be something as trivial as a String.
          m[k] = _getValue(source[k], null, t);
        }

        return m;
      }

      // We have a regular object.
      for (var k in source.keys) {
        var s = new Symbol(k),
            declaration = type.declarations[s];

        // Do not assign values to final fields.
        if (declaration != null && !declaration.isFinal) {
          mirror.setField(s, _getValue(source[k], k, type));
        }
      }

      return mirror.reflectee;
    }
  }
}
