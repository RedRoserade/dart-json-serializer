part of json_serializer;

class SerializerException {

  dynamic cause;

  SerializerException(this.cause);

  @override
  String toString() {
    return 'SerializerException: Impossible to determine the type of the object ${cause} in which this is to be mapped to. In case the object is a generic (eg.: List), did you specify the type arguments?';
  }
}

class AbstractFieldException {
  TypeMirror _cause;
  
  AbstractFieldException(this._cause);

  @override
  String toString() {
    return 'AbstractFieldException: The type "$_cause" is abstract, and cannot be instantiated.';
  }
}