import 'dart:async';

import 'package:jsonable_object/jsonable_object.dart';
import 'package:modular_shelf/modular_shelf.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_request_response_2_jsonable_object_utility/shelf_request_response_2_jsonable_object_utility.dart';
import 'package:shelf_rest_core/shelf_rest_core.dart';
import 'package:shelf_rest_core/src/global_converters.dart';
import 'package:shelf_rest_core/src/server.dart';
import 'package:shelf_rest_core/src/service.dart';
import 'package:shelf_router/src/router.dart';

import 'x.controller.dart';

void main() async {
  final server = ShelfServer(
    (router) => ShelfApp(
      {XModule(router)},
    ),
    configSingletons: () async {
      GlobalConverters.I.add(
        {
          XEntity: ShelfRequestResponse2JsonUtility<XEntity>(
            XFactory(),
          ),
        },
      );
    },
  );

  await server.start(address: 'localhost', port: 8080);
}

class XModule extends ShelfModule {
  XModule(Router router)
      : super(
          controllers: {
            (router, dependencyManager) => XController(
                  router: router,
                  service: dependencyManager.get<XService>(),
                )
          },
          providers: {
            XMockDatabase: (_) => XMockDatabase(),
            XService: (dependencyManager) =>
                XService(database: dependencyManager.get<XMockDatabase>())
          },
          router: router,
        );
}

class XService extends Service {
  final XMockDatabase database;

  XService({required this.database})
      : super(
          flowController: FlowManager.DEFAULT,
          converters: GlobalConverters.I.to({XEntity}),
        );

  FutureOr<Response> add(Request request) async {
    return flowController(
        request: request,
        normalExecutionFlow: (request) async {
          final converter = getConverter<XEntity>();
          final xEntity = await converter.body(request);
          final toSaveEntity = xEntity;
          final savedEntity = database.add(toSaveEntity);
          final response = converter.ok(savedEntity);
          return response;
        });
  }

  FutureOr<Response> findOne(Request request, int id) async {
    return flowController(
        request: request,
        normalExecutionFlow: (request) async {
          final converter = getConverter<XEntity>();
          final foundedEntity = await database.findOne(id);
          return converter.ok(foundedEntity);
        });
  }
}

class XEntity extends IConvertToJson {
  final int id;

  const XEntity(this.id);

  @override
  FutureOr<Map<String, dynamic>> toJson() {
    return {'id': id};
  }
}

class XFactory extends IFactoryObjectFromJson<XEntity> {
  @override
  FutureOr<XEntity> fromJson(FutureOr<Map<String, dynamic>> json) async {
    final jsonEntity = await json;
    return XEntity(jsonEntity['id']);
  }
}

class XMockDatabase {
  final Set<XEntity> entities = {};

  FutureOr<XEntity> add(XEntity entity) async {
    entities.add(entity);
    return entity;
  }

  FutureOr<XEntity> findOne(int id) async {
    return entities.singleWhere((element) => element.id == id);
  }
}
