library json_serializer;

import 'dart:convert' show Codec, Converter, JSON;
import 'dart:mirrors';

class JsonCodec<T> extends Codec<T, String> {
  JsonEncoder _encoder;
  JsonDecoder _decoder;

  @override
  JsonDecoder<String, T> get decoder {
    if (_decoder == null) {
      _decoder = new JsonDecoder<String, T>();
    }
    return _decoder;
  }

  @override
  JsonEncoder<T, String> get encoder {
    if (_encoder == null) {
      _encoder = new JsonEncoder<T, String>();
    }
    return _encoder;
  }

  T decode(String json) {
    return decoder.convert(json);
  }

  String encode(T t, {bool allowPrivateFields: false, bool allowGetters: true}) {
    return encoder.convert(t);
  }
}

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
        declarations = type.declarations,
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

      return source.map((i) => _getValue(i, null, typeArg)).toList(growable: false);
    }

    if (source is Map<String, dynamic>) {
      if (key != null) {
        var declarations = type.declarations,
            declaration = declarations[declarations.keys.firstWhere((d) => MirrorSystem.getName(d) == key)] as VariableMirror;

        type = declaration.type;
      }

      var mirror = null;

      try {
        mirror = type.newInstance(new Symbol(''), []);
      } on Error {
        // We can't infer anything on 'dynamic'.
        throw 'Impossible to determine the type of the object ${source} in which this is to be mapped to. In case the object is a generic (eg.: List), did you specify the type arguments?';
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

// Tests whether a field is a String, number, bool or null.
bool _isFieldAtomic(r) => r is String || r is num || r is bool || r == null;
