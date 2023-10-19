import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:get/get.dart';

class login extends StatelessWidget {
  login({super.key});
  var revealMode=PasswordRevealMode.peekAlways;
  var regisDisabled=false;
  var LoginDisabled=false;


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        const TextBox(
          placeholder: 'username/phone/email',
          expands: false,
        ),
        PasswordBox(
          revealMode: revealMode,
        ),
        Row(children: [
          Obx(() => Button(
                child: const Text('Register'),
                onPressed: regisDisabled ? null : () => debugPrint('pressed button'),
              )),
          Obx(() => Button(
                child: const Text('Login'),
                onPressed: LoginDisabled ? null : () => debugPrint('pressed button'),
              )),
        ])
      ]),
    );
  }
}

class loginController extends GetxController {
  // final MyRepository repository;
  // loginController(this.repository);

  final username = ''.obs;
  final errorText = RxnString(null);
  final submitFunc = Rxn<Function()>(null);

  @override
  void onInit() {
    // fetchApi();
    super.onInit();
    debounce(username, validations, time: const Duration(milliseconds: 500));
  }

  void validations(String val) async {
    errorText.value = null;
    submitFunc.value = null;
    if (val.isNotEmpty) {
      if (isLength(val) && await available(val)) {
        print('ok! enable submit butt');
        submitFunc.value = submitFunction();
        errorText.value = null;
      }
    }
  }

  bool isLength(String val, {int minLen = 5}) {
    if (val.length < minLen) {
      errorText.value = 'Least 5 chars';
      return false;
    }
    return true;
  }

  Future<bool> available(String val) async {
    print('register');
    await Future.delayed(
        const Duration(seconds: 1), () => print('return result'));
    return true;
    //TODO: http
  }

  void usernameChanged(String val) {
    username.value = val;
  }

  Future<bool> Function() submitFunction() {
    return () async {
      print('creating ${username.value} account');
      await Future.delayed(
          const Duration(seconds: 1), () => {print('created!')});
      return true;
    };
  }
  // set obj(value) => this._obj.value = value/;
  // get obj => this._obj.value;
}
