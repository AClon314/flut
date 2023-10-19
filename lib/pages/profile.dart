import 'package:fluent_ui/fluent_ui.dart';
import 'package:flut/common/api/api_client.dart';
import 'package:flut/common/models/models.dart';
import 'package:flut/common/widgets/postsList.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/widgets/profileCard.dart';

class Profile extends StatelessWidget {
  Profile(this.userinfoId, {super.key}) {
    api.getThem<Userinfo>({'u': userinfoId}).then((b) => userinfo.value = b[0]);
    api.getThem<Post>({'o': userinfoId}).then((v) => profilePost.value = v[0]);
  }
  final ApiClient api = Get.find();
  late final userinfo = Userinfo(userinfo_id: '',username: '').obs;
  late final profilePost =
      Post(owner_url: '', post_id: '', status: '', time_init: DateTime.now())
          .obs;
  final String userinfoId;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    // final theme = FluentTheme.of(context);
    return NestedScrollView(
      scrollDirection: Axis.vertical,
      floatHeaderSlivers: false,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Obx(() => ProfileCard(userinfo.value, profilePost.value,headHeight: 500,)),
        ),
      ],
      body: PostsList({'u': userinfoId, 'A': 'time_init', 'a': '-1'}),
    );
  }
}
