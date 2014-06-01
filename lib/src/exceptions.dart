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
  Type cause;


}