import 'package:modular_shelf/modular_shelf.dart';
import 'package:shelf_controller_flow_manager/shelf_controller_flow_manager.dart';
import 'package:shelf_rest_core/src/controller.dart';
import 'package:shelf_rest_core/src/server.dart';
import 'package:shelf_rest_core/src/service.dart';
import 'package:shelf_router/src/router.dart';

void main() async {
  final server = Server(
    (router) => ShelfApp(
      {},
    ),
  );

  await server.start(address: 'localhost', port: 8080);
}


class XModule extends ShelfModule {
  XModule(Router router) : super(
    controllers: {
      (router, dependencyManager) => XController(router: router, service: dependencyManager.get<XService>())
    },
    providers: {
      XService: (_) => XService()
    },
    router: router,
  );

}


class XController extends Controller<XService> {
  XController({
    required Router router,
    required XService service,
  }) : super(
          path: '/x/',
          router: router,
          service: service,
        );

  @override
  Router get router => Router();
}

class XService extends Service {
  XService()
      : super(flowController: ShelfControllerFlowManager(), converters: {});
}
