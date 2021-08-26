import 'package:jsonable_object/jsonable_object.dart';
import 'package:shelf_controller_flow_manager/shelf_controller_flow_manager.dart';
import 'package:shelf_request_response_2_jsonable_object_utility/shelf_request_response_2_jsonable_object_utility.dart';

abstract class Service {
  final Map<Type, ShelfRequestResponse2JsonUtility<IConvertToJson>> converters;
  final ShelfControllerFlowManager flowController;

  Service({
    required this.converters,
    required this.flowController,
  });

  ShelfRequestResponse2JsonUtility<T> getConverter<T extends IConvertToJson>() {
    final converter = converters[T];
    return converter as ShelfRequestResponse2JsonUtility<T>;
  }
}
