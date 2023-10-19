import 'package:fluent_ui/fluent_ui.dart';
import 'package:flut/common/api/api_client.dart';
import 'package:flut/common/models/models.dart' show globalUserId;
import 'package:get/get.dart';

// 要捕获同一函数中 同步return 与异步return，做消息队列(管道)，若队列空则等待10秒判超时，队列最多有1个元素
class Msg extends StatelessWidget {
  Msg({super.key});
  final ApiClient api = Get.find();
  final msgController = Get.put(MsgController());
  final placeholderText = '填写内容...'.obs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() => Text(
              msgController.errMsg.value,
              style: const TextStyle(fontSize: 20),
            )),
        TextBox(
          controller: msgController.textController,
          placeholder: '域名更改...',
          expands: true,
          maxLines: null,
        ),
        Button(
          onPressed: () {
            msgController.reset();
          },
          child: const Text('重置'),
        )
      ],
    );
  }
}

class MsgController extends GetxController {
  final ApiClient api = Get.find();
  final textController = TextEditingController(); // 创建一个textcontroller
  final backend = ''.obs; // 创建一个RxString变量，用来存储后端的值
  late String initBackend;
  final errMsg = '更改域名'.obs;

  @override
  void onInit() {
    textController.text = api.endpoint;
    initBackend = ApiClient.initEndpoint;
    textController.addListener(() {
      backend.value = textController.text;
    });
    debounce(backend, (_) {
      api.endpoint = textController.value.text;
      return api.getSelect(path: '').then((v) => errMsg.value = '$v')
        .catchError((err) {
          errMsg.value = err.toString();
        });
    }, time: const Duration(seconds: 1)); // 设置延迟时间为1秒

    super.onInit();
  }

  @override
  onClose() {
    textController.dispose();
    super.dispose();
  }

  reset() {
    textController.text = initBackend;
    backend.value = initBackend;
  }
}
