part of json_serializer;

class JsonCodec<T> extends Codec<T, String> {
  JsonSerializer _encoder;
  JsonDeserializer _decoder;

  @override
  JsonDeserializer<String, T> get decoder {
    if (_decoder == null) {
      _decoder = new JsonDeserializer<String, T>();
    }
    return _decoder;
  }

  @override
  JsonSerializer<T, String> get encoder {
    if (_encoder == null) {
      _encoder = new JsonSerializer<T, String>();
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