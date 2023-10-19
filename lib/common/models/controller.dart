import 'package:fluent_ui/fluent_ui.dart';
import 'package:flut/common/api/api_client.dart';
import 'package:flut/common/models/models.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart'
    show ReorderedListFunction;
import 'package:get/get.dart';

// post,put,delete请通过全局状态api.putUpd()调用

class InfoController<T> extends GetxController {
  // 向父级暴露controller以便关闭时释放
  final Map<String, dynamic> query;
  final ApiClient api = Get.find(); //一个Ctrl专门控制请求发送
  late T data;
  InfoController(this.query);

  @override
  void onInit() {
    api.getThem<T>(query).then((v) => data = v[0]);
    super.onInit();
  }
}

class ListViewController<T> extends GetxController {
  ListViewController(this.query);
  // 创建时自动获取一定数量的data，仅获取，批量状态更新未实现
  late Map<String, dynamic> query; //无限滚动时，不允许传页面参数
  final _limit = 20.obs;
  final selectable = false.obs;
  final path = Generic.getPath<T>();
  List<T> datas = [];
  Map asyncDatas = {};

  bool allowScrollListener = true;
  late final FocusNode focusNode;
  late final ScrollController scrollController;
  late final ApiClient api;
  late BuildContext context;
  late final Function(List b) afterGetPage=getSyncPage2;
  String? col;

  int get limit => _limit.value;
  int get length => datas.length;
  int get page => (length / limit).floor();

  getPage() {
    debugPrint('$query');
    query['P'] = '$page';
    query['S'] = '$limit';
    api.getSelect(path: path, query: query).then((body) {
      if (body == null || body.isEmpty) {
        // null值处理：从逻辑层返回空值[]给Widget，容错性（请求数据层，逻辑层，渲染层）
        debugPrint('controller.dart: 服务器未响应或已达最后一页');
        scrollController.removeListener(loadNextPage);
      } else {
        datas += Generic.fromJson<List<T>, T>(body);
        debugPrint(
            'controller.getPage(): ${body.length} ${body.isEmpty} $length $page ${datas.length} ${allowScrollListener}');
      }

      return body; //不要在Future内改变状态，异步-return-异步，异步-直接改变类内变量-同步
    }).then((b) {
      return afterGetPage(b);
    }).then((b) {
      // if (!allowScrollListener) {
        // debugPrint('UPDATE😡${b}');
        update();
        allowScrollListener = true;
      // }
      return b;
    });
  }
  // 失败的设计，耦合的代码

  getSyncPage2(List b) {
    if (col == null) {
      // 啥事不做
      return Future(() => true);
    } else {
      return Future.forEach(b, (i) {
        if (asyncDatas[i[col]] == null) {
          // debugPrint('🤢${i[col]}');
          return api.getThem<Userinfo>({'u': i[col]}).then((b) {
            // debugPrint('🥸${b == null ? b.runtimeType : b[0].userinfo_id}');
            if (b != null) {
              asyncDatas[b[0].userinfo_id] = b[0];
            }
            return true;
          });
        }
      });
    }
  }

  reorder(ReorderedListFunction func) {
    debugPrint(
        '${MediaQuery.of(context).size.height} ${MediaQuery.of(ShowInfoBar().context).size.height}');
    datas = func(datas) as List<T>;
  }

  reset() {
    debugPrint('RESET');
    datas = [];
    asyncDatas = {};
    selectable.value = false;
    allowScrollListener = true;
    if (!hasListeners) {
      scrollController.addListener(loadNextPage);
    }
    return getPage();
  }

  loadNextPage() {
    // debugPrint('${scrollController.position.pixels} ${scrollController.position.maxScrollExtent}');
    if (allowScrollListener &&
        (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 150)) {
      allowScrollListener = false; //上锁
      return getPage();
    }
  }

  @override
  void onInit() {
    super.onInit();
    api = Get.find();
    focusNode = FocusNode();
    scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
    reset();
  }

  @override
  void onClose() {
    super.onClose();
    focusNode.dispose();
    scrollController.dispose();
  }
}
