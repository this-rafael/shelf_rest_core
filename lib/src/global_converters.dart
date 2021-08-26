import 'package:jsonable_object/jsonable_object.dart';
import 'package:shelf_request_response_2_jsonable_object_utility/shelf_request_response_2_jsonable_object_utility.dart';


class GlobalConverters {
  final Map<Type, ShelfRequestResponse2JsonUtility<IConvertToJson>> converters;

  static final GlobalConverters instance = GlobalConverters({});

  GlobalConverters(this.converters);

  static GlobalConverters get I => instance;

  void add(
    Map<Type, ShelfRequestResponse2JsonUtility<IConvertToJson>> converters,
  ) {
    this.converters.addAll(converters);
  }

  Map<Type, ShelfRequestResponse2JsonUtility<IConvertToJson>> to(
      Set<Type> keys) {
    final response = <Type, ShelfRequestResponse2JsonUtility<IConvertToJson>>{};

    for (var key in keys) {
      final converterCandidate = converters[key];
      if (converterCandidate == null) {
        throw Error();
      }
      response.addAll({key: converterCandidate});
    }
    return response;
  }
}
