import 'dart:async';
import 'dart:io';

import 'package:modular_shelf/modular_shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

class ShelfServer {
  final ShelfApp Function(Router) app;
  final Router router;
  final Future<void> Function()? configSingletons;
  ShelfServer(this.app, {this.configSingletons}) : router = Router();

  FutureOr<void> start({
    required String address,
    required int port,
    SecurityContext? securityContext,
    int? backlog,
    bool shared = false,
  }) async {
    if(configSingletons != null){
      await configSingletons!();
    }

    await app(router).mount();
    final httpServer = await io.serve(
      router,
      address,
      port,
      backlog: backlog,
      shared: shared,
      securityContext: securityContext,
    );

    print('server run on: http://$address:$port');
  }
}
