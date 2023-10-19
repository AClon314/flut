import 'package:flutter/material.dart';

void setErrorBuilder() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Scaffold(
        body:
            Center(child: Text("Unexpected error. See console for details.")));
  };
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setErrorBuilder();

    return MaterialApp(
      builder: (BuildContext context, Widget? widget) {
        setErrorBuilder();
        return widget!;
      },
      title: 'Flutter Demo',
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
