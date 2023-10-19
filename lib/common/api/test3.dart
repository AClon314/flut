import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

void main() {
  // AppCatchError().run(MineApp());
}

//全局异常的捕捉
class AppCatchError {
  run(Widget app) {
    ///Flutter 框架异常
    FlutterError.onError = (FlutterErrorDetails details) async {
      ///线上环境
      ///TODO
      if (kReleaseMode) {
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      } else {
        //开发期间 print
        FlutterError.dumpErrorToConsole(details);
      }
    };

    runZonedGuarded(() {
      //受保护的代码块
      runApp(app);
    }, (error, stack) => catchError(error, stack));
  }

  ///对搜集的 异常进行处理  上报等等
  catchError(Object error, StackTrace stack) {
    print("AppCatchError>>>>>>>>>>: $kReleaseMode"); //是否是 Release版本
    print('AppCatchError message:$error,stack$stack');
  }
}
