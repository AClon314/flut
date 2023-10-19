import 'package:fluent_ui/fluent_ui.dart';
import 'package:flut/common/api/api_client.dart';
import 'package:flut/common/models/controller.dart';
import 'package:flut/common/models/models.dart' show Post, globalUserId;
import 'package:get/get.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

// 要捕获同一函数中 同步return 与异步return，做消息队列(管道)，若队列空则等待10秒判超时，队列最多有1个元素
class NewPost extends StatelessWidget {
  NewPost({super.key});
  final submitButtonText = '发布'.obs;
  late final controller;
  //Get.put在Widget只能在这里声明

  @override
  Widget build(BuildContext context) {
    controller = Get.put(NewPostController());
    return Column(
      children: [
        RawKeyboardListener(
          focusNode: controller.focusNode,
          onKey: (event) => controller._isCtrlEnter(event),
          child: Obx(() => TextBox(
                controller: controller.textController,
                placeholder: controller.placeholderText.value,
                expands: true,
                maxLines: null,
              )),
        ),
        Button(
          onPressed: controller.isSubmitting.value
              ? null
              : () {
                  controller._submit();
                },
          child: controller._submitButtonChild.value,
        )
      ],
    );
  }
}

class NewPostController extends GetxController {
  final url = ''.obs;
  late final ApiClient api;
  static const _SUBMIT_BUTTON_CHILD = Text(
    '发布',
    style: TextStyle(fontSize: 16),
  );
  static const _SUBMIT_BUTTON_CHILD_1 = ProgressRing();
  final _submitButtonChild = Rx<Widget>(_SUBMIT_BUTTON_CHILD);
  final isSubmitting = false.obs;
  bool _isCtrlPressed = false;
  final textController = TextEditingController();
  final placeholderText = '填写内容...'.obs;
  final focusNode = FocusNode();
  late final ListViewController<Post> postsController;

  _submit() {
    if (textController.text.isNotEmpty) {
      isSubmitting.value = true;
      _submitButtonChild.value = _SUBMIT_BUTTON_CHILD_1;
      final post = {'url': textController.text, 'owner_url': globalUserId};
      api.postIns('post', post).then((v) {
        debugPrint('v1: $v');
        if (v['rowcount'] > 0) {
          isSubmitting.value = false;
          _submitButtonChild.value = _SUBMIT_BUTTON_CHILD;
          placeholderText.value = '填写内容...';
          textController.clear();
          focusNode.unfocus();

          return api.getThem<Post>({'o': v['id']});
        }
      }).then((v) {
        postsController.datas.insert(0, v[0]);
        return postsController.update();
      });
    } else {
      throw "输入不可为空";
    }
  }

  _isCtrlEnter(event) {
    if (event.isControlPressed) {
      _isCtrlPressed = true;
    } else {
      _isCtrlPressed = false;
    }
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      if (_isCtrlPressed) {
        _submit();
      }
    }
  }

  @override
  void onInit() {
    api = Get.find();
    postsController = Get.find();
    super.onInit();
    // ever(updateBuggyValue, updateBuggy());
  }

  @override
  void onClose() {
    textController.dispose();
    isSubmitting.close();
    super.onClose();
  }
}
