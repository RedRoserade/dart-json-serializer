part of json_serializer;

// Tests whether a field is a String, number, bool or null.
bool _isFieldAtomic(r) => r is String || r is num || r is bool || r == null;

Map<Symbol, VariableMirror> _getAllFields(ClassMirror m) {
  var vars = {};

  vars = _getSuperclassFields(m, vars);

  return vars;
}

_getSuperclassFields(ClassMirror m, Map<Symbol, VariableMirror> existingFields) {
  while (m.superclass != null) {
    existingFields = _populateMapWithFields(existingFields, m);

    return _getSuperclassFields(m.superclass, existingFields);
  }
  return existingFields;
}

Map _populateMapWithFields(Map<Symbol, VariableMirror> fields, ClassMirror m) {
  for (var k in m.declarations.keys) {
    if (m.declarations[k] is VariableMirror) {
      fields[k] = m.declarations[k];
    }
  }

  return fields;
}