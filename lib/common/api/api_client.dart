import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flut/common/models/models.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

//优先级 ?? > ?
// 传数据层，异步的传染性，异步转同步，代码更简单：设置Lisenter→emit_Event→同步函数，异步执行后Listener报告以执行同步函数
class ApiClient extends GetConnect implements GetxService {
  static const initEndpoint='http://192.168.137.1:8080/v1/';
  final _endpoint = initEndpoint.obs;
  String get endpoint => _endpoint.value;
  set endpoint(String s){
    _endpoint.value=s;
  }

  universeRequest(response) {
    try {
      // debugPrint('${response.body} ${response.headers}');
      if (response.body==null || response.body == 'Internal Server Error' || response.statusCode>=400) {
        debugPrint('api请求失败');
        return {'rowcount': -1};
      }
      return response.body;
    } catch (err) {
      debugPrint('ApiClient_ERR:${response.body}😭${err}');
      rethrow;
    }
  }

  // 全局函数
  getSelect({required String path, query}) {
    debugPrint('getSelect ${query.toString()}');
    return get('$endpoint$path', query: query)
        .then((response) => universeRequest(response));
  }

  putUpd(String path, body, query) {
    return put('$endpoint$path', body, query: query)
        .then((response) => universeRequest(response));
  }

  postIns(String path, body) {
    return post('$endpoint$path', body)
        .then((response) => universeRequest(response));
  }

  del(String path, query) {
    return delete('$endpoint$path', query: query)
        .then((response) => universeRequest(response));
  }

  getThem<T>(query) async {
    if (query is Map) {
      query['P'] = '0';
      query['S'] = '1';
    }
    var b = await getSelect(path: Generic.getPath<T>(), query: query);
    // debugPrint('getThem: ${b[0]}');

    // var tmp = Generic.fromJson<List<T>, T>(b);
    // debugPrint('🔁${tmp}');
    return Generic.fromJson<List<T>, T>(b);
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   //修改请求
  //   httpClient.addRequestModifier<void>((request) {
  //     // request.headers['Authorization'] = '123';
  //     return request;
  //   });
  //   //修改响应
  //   httpClient.addResponseModifier((request, response) {
  //     return response;
  //   });
  // }
}

class Generic {
  /// If T is a List, K is the subtype of the list.
  /// return type T
  static T fromJson<T, K>(dynamic json) {
    if (json is Iterable) {
      return _fromJsonList<K>(json as List<dynamic>) as T;
    } else if (T == Userinfo) {
      return Userinfo.fromJson(json) as T;
    } else if (T == Post) {
      return Post.fromJson(json) as T;
    } else if (T == Interact) {
      return Interact.fromJson(json) as T;
    } else if (T == Relation) {
      return Relation.fromJson(json) as T;
    } else if (T == Cart) {
      return Cart.fromJson(json) as T;
    } else if (T == Pay) {
      return Pay.fromJson(json) as T;
    } else if (T == bool || T == String || T == int || T == double) {
      // primitives
      return json;
    } else {
      throw Exception("Unknown ${json} for Generic.fromJson()");
    }
  }

  static List<K> _fromJsonList<K>(List<dynamic> jsonList) {
    return jsonList.map<K>((dynamic json) => fromJson<K, void>(json)).toList();
  }

  static String getPath<T>() {
    if (T == Userinfo) {
      return 'userinfo';
    } else if (T == Post) {
      return 'post';
    } else if (T == Interact) {
      return 'interact';
    } else if (T == Relation) {
      return 'relation';
    } else if (T == Cart) {
      return 'cart';
    } else if (T == Pay) {
      return 'pay';
    }
    throw 'Undified ${T} for getPath()';
  }
}

class ShowInfoBar {
  // 单例模式
  //  构造函数
  ShowInfoBar._internal();
  static final ShowInfoBar _singleton = ShowInfoBar._internal();
  factory ShowInfoBar() => _singleton;
  late BuildContext context;

  run(Widget app) {
    // override
    FlutterError.onError = (FlutterErrorDetails details) async {
      if (kReleaseMode) {
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      } else {
        FlutterError.dumpErrorToConsole(details);
      }
      catchError(details.exception, details.stack);
    };
    runZonedGuarded(() {
      //受保护的代码块
      runApp(app);
    }, (error, stack) => catchError(error, stack));
  }

  ///对搜集的 异常进行处理  上报等等
  catchError(Object error, StackTrace? stack) {
    // debugPrint('Err:$error,stack$stack,$kReleaseMode');
    // debugPrint('😋${error.runtimeType}');
    if (error is String) {
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
          title: Text(error),
          // content: Text(error),
          isLong: error.length > 25,
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.error,
        );
      });
    }
  }
}

visitUrl(String? url) async {
  if (url == null) throw "空链接";
  var uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw "不可达的链接";
  }
}
