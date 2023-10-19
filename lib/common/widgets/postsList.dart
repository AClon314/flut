import 'package:fluent_ui/fluent_ui.dart';
import 'package:flut/common/models/controller.dart';
import 'package:flut/common/models/models.dart';
import 'package:flut/common/widgets/postEach.dart';
import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:get/get.dart';

class PostsList extends StatelessWidget {
  PostsList(this.query, {super.key}) {
    postsController =
        Get.put(ListViewController<Post>(query));
  }
  late ListViewController<Post> postsController;
  // final userinfoController = Get.put(UserinfoController({'userinfo_id':globalUserId,'S':'10'}));
  final _gridViewKey = GlobalKey();
  Map<String,dynamic> query;

  get gridViewKey => _gridViewKey;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    // final theme = FluentTheme.of(context);
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => postsController.reset(),
      ),
      child: GetBuilder<ListViewController<Post>>(
        initState: (_) {
          postsController.col = 'owner_url';
          // postsController.afterGetPage=postsController.getSyncPage2;
        },
        builder: (_) {
          return ReorderableBuilder.builder(
            fadeInDuration: Duration.zero,
            key: Key(_gridViewKey.toString()),
            enableDraggable: true,
            onReorder: postsController.reorder,
            scrollController: postsController.scrollController,
            childBuilder: (itemBuilder) {
              return GridView.builder(
                key: _gridViewKey,
                // scrollController的滚动数据来源于此Widget(controller)
                controller: postsController.scrollController,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      (MediaQuery.of(context).size.width / 450).round(),
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                // itemCount控制index范围，必填
                itemCount: postsController.length,
                itemBuilder: (context, index) {
                  // debugPrint('itembuilder re-render costly');
                  return itemBuilder(
                      Card(
                        key: ValueKey(
                            postsController.datas[index].post_id.toString()),
                        padding: const EdgeInsets.all(0.0),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22)),
                        child: PostWidget(
                            post: postsController.datas[index], index: index),
                      ),
                      index);
                  // index);
                },
              );
            },
          );
        },
      ),
    );
  }
}
