part of json_serializer;

// Tests whether a field is a String, number, bool or null.
bool _isFieldAtomic(r) => r is String || r is num || r is bool || r == null;

Map<Symbol, VariableMirror> _getAllFields(ClassMirror m) {
  var vars = {};

  // vars = _populateMapWithFields(vars, m);

  vars = _getSuperclassFields(m, vars);

  return vars;
}

Map _getSuperclassFields(ClassMirror m, Map<Symbol, VariableMirror> existingFields) {
  while (m.superclass != null) {
    existingFields = _populateMapWithFields(existingFields, m);

    return _getSuperclassFields(m.superclass, existingFields);
  }
  return existingFields;
}

Map _populateMapWithFields(Map<Symbol, VariableMirror> fields, ClassMirror m) {
  m.declarations.keys.where((k) => m.declarations[k] is VariableMirror)
                     .forEach((k) => fields[k] = m.declarations[k]);

  return fields;
}