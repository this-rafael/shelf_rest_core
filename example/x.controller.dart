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