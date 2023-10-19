import 'package:fluent_ui/fluent_ui.dart';
import 'package:flut/common/api/api_client.dart';
import 'package:flut/common/models/controller.dart';
import 'package:flut/common/models/models.dart';
import 'package:flut/common/widgets/postsList.dart';
import 'package:get/get.dart';

import '../common/widgets/newPost.dart';

class PostView extends StatelessWidget {
  final ApiClient api = Get.find();
  PostView({super.key});

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    // final theme = FluentTheme.of(context);
    return NestedScrollView(
      scrollDirection: Axis.vertical,
      floatHeaderSlivers: true,
      headerSliverBuilder: (context, innerBoxIsScrolled) =>
          [SliverToBoxAdapter(child: NewPost())],
      // ignore: prefer_const_literals_to_create_immutables
      body: PostsList({'A': 'time_init', 'a': '-1'}),
    );
  }
}
