part of json_serializer;

// Tests whether a field is a String, number, bool or null.
bool _isFieldAtomic(r) => r is String || r is num || r is bool || r == null;