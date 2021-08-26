# shelf_rest_core
A concise core shelf for creating monolithic dart API's based on shelf

## Installing
    You must stick to dependencies for this package: 
    build_runner  & shelf_router_generator

## How to use
    For example, let's assume an XEntity that is stored in a MockDatabase, added via XController post , and retrieved via a getOne,
    both methods are called XService to perform these actions to the database
### Creating a controller
```dart
import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_rest_core/shelf_rest_core.dart';
import 'package:shelf_router/shelf_router.dart';

import 'shelf_rest_core_example.dart';


part 'x.controller.g.dart';
class XController extends Controller<XService> {
  XController({
    required Router router,
    required XService service,
  }) : super(
    path: '/x/',
    router: router,
    service: service,
  );

  @Route.post('/')
  FutureOr<Response> add(Request request) async {
    return service.add(request);
  }


  @Route.get('/<id>')
  FutureOr<Response> getOne(Request request, String id) async {
    final convertedId = int.parse(id);
    return service.findOne(request, convertedId);
  }

  @override
  Router get router => _$XControllerRouter(this);
}
```
Make sure that after your controller created you run the command to generate the code present in x.controller.g.dart (In other words, the _$XControllerRouter class)
> dart pub run build_runner build
    
    You may have noticed that we have extended the Controller class ( which requires us to implement the get router method )
    and that we pass it in its XService generic argument, this is so that our constructor 
    can receive the data to be able to inject this data into our XModule

### Creating a Service
```dart
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
```

### Creating database
```dart
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

```

### Creating XEntity
```dart
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
```


### Creating Module
```dart
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
```

### Create App
```dart
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
```