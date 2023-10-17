import 'package:dio/dio.dart';

import 'consts.dart';

class LoginInterceptor extends Interceptor{
  static var _token = "";
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if(options.path == "${loginUrl}signInWithPassword"||options.path == "${loginUrl}signUp"){
      options.queryParameters.addAll({
            "key":key,
      });
    }else{
      options.queryParameters.addAll({
        "auth": _token
      });
    }
  super.onRequest(options, handler);
  }
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if(response.data["idToken"]!=null){
     _token = response.data["idToken"];
    }
    super.onResponse(response, handler);
  }

  static void logout() {
    _token = "";
  }
}