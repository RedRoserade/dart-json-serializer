part of json_serializer;

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