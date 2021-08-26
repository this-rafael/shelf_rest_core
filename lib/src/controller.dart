import 'package:modular_shelf/modular_shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'service.dart';

abstract class Controller<S extends Service> extends ShelfController {
  final S service;

  Controller({required this.service, required Router router, required String path}) : super(router, path);
}


