// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flut/common/api/api_client.dart';
import 'package:flut/common/models/controller.dart';
import 'package:flut/common/models/models.dart';
import 'package:flut/common/widgets/profileCard.dart';
import 'package:flut/main.dart';
import 'package:flut/pages/index.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/link.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

extension NullableWidget on Widget {
  Widget iF(bool if_not_true_then_return_null) {
    return if_not_true_then_return_null ? this : SizedBox(width: 0, height: 0);
  }
}

///难点，根据父级传入的owner_url，再次获取一次对应的userinfo，并缓存
///一般来说，使用Getx的目的就是要将数据与Widget隔离，这样子在widget中调用能返回数据的api，会使得代码复杂
///正确来说，每个dart文件都会有一个widget，一个controller
///规范：widget中只能使用Get.put(...)，不能使用Get.find()，请将widget中所有动态方法写在put出来的controller
class PostWidget extends StatelessWidget {
  PostWidget({super.key, required this.post, required this.index}) {
    // userinfo = postsController.asyncDatas[post.owner_url];
    api.getThem<Post>({'o': post.owner_url}).then(
        (v) => profilePost = v[0]);
  }
  final Post post;
  late final Post profilePost;
  late Userinfo userinfo;
  final int index;
  final liked = false.obs;

  final ApiClient api = Get.find(); //这种写法是错误的，但没时间了
  final ListViewController<Post> postsController = Get.find();
  final menuController = FlyoutController();
  final usermenuController = FlyoutController();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // 一旦使用FutureBuilder，与Reorder的疯狂重绘搭配，就会鬼畜
    // 读取缓存
    try {
      userinfo = postsController.asyncDatas[post.owner_url];
    } catch (err) {
      //dart的语言设计很蠢，还分字典参数和顺序参数
      userinfo = Userinfo.fromJson(
          {'userinfo_id': post.owner_url, 'username': post.owner_url});
      throw "用户加载失败 ${post.owner_url}";
    } finally {
      // ignore: control_flow_in_finally
      return Column(
        children: [
          Row(children: [
            Stack(alignment: AlignmentDirectional.bottomEnd, children: [
              FlyoutTarget(
                // Target提供上下文
                controller: usermenuController,
                child: MouseRegion(
                  onHover: (event) {
                    // debugPrint('$event');
                    usermenuController.showFlyout(
                      barrierColor: Colors.transparent,
                      autoModeConfiguration: FlyoutAutoConfiguration(
                        preferredMode: FlyoutPlacementMode.topCenter,
                      ),
                      barrierDismissible: true,
                      dismissOnPointerMoveAway: true,
                      dismissWithEsc: true,
                      // navigatorKey保证导航生成key不变
                      navigatorKey: rootNavigatorKey.currentState,
                      builder: (context) {
                        return Acrylic(
                          tintAlpha: 0.8,
                          luminosityAlpha: 0.8,
                          blurAmount: 5,
                          elevation: 8,
                          // tint: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            constraints: BoxConstraints.tight(Size(250, 300)),
                            child: ProfileCard(userinfo, profilePost),
                          ),
                        );
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: IconButton(
                      icon: Image.network(userinfo.avatar ?? '',
                          width: 44,
                          height: 44,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/niko_huh.png',
                                width: 44,
                                height: 44,
                              )),
                      onPressed: () => myHomePageState
                          .setOnTap('/profile/${userinfo.userinfo_id}'),
                      onLongPress: () => debugPrint('LONG ICON button'),
                      style: ButtonStyle(
                          padding: ButtonState.all(EdgeInsets.all(0))),
                    ),
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: userinfo.status == 'O'
                      ? Colors.blue
                      : Color.fromARGB(255, 199, 199, 199),
                  borderRadius: BorderRadius.circular(20),
                ),
              )
            ]),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HyperlinkButton(
                        onPressed: () => myHomePageState
                            .setOnTap('/profile/${userinfo.userinfo_id}'),
                        child: Text('${userinfo.nick} @${userinfo.username}')),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                          '${timeago.format(post.time_init, locale: 'zh')} ${DateFormat('yyyy-MM-dd kk:mm').format(post.time_init)}'),
                    ),
                  ]),
            ),
            FlyoutTarget(

                /// 子组件key与父组件key没有同步更新时会报错
                /// 解决：移除子组件的key
                // key: menuAttachKey,
                controller: menuController,
                child: IconButton(
                    icon: const Icon(Icons.more_horiz, size: 24.0),
                    onPressed: () {
                      menuController.showFlyout(
                          autoModeConfiguration: FlyoutAutoConfiguration(
                            preferredMode: FlyoutPlacementMode.bottomRight,
                          ),
                          barrierColor: Color(0x00000000),
                          barrierDismissible: true,
                          dismissOnPointerMoveAway: false,
                          dismissWithEsc: true,
                          navigatorKey: rootNavigatorKey.currentState,
                          builder: (context) {
                            return MenuFlyout(
                                items: dynamicMenuFlyoutList(context));
                          });
                    })),
          ]),
          Expanded(
              child: Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              controller: scrollController,
              child: Obx(() => MarkdownBody(
                    data:
                        '${post.url ?? '向您推荐用户：${userinfo.nick}'} ${postsController.selectable.value ? '' : ' '}',
                    shrinkWrap: true,
                    selectable: postsController.selectable.value,
                    onTapLink: (text, href, title) => visitUrl(href),
                  )),
            ),
          )),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ToggleButton(
                    checked: liked.value,
                    child: Row(children: [
                      const Icon(Icons.thumb_up_outlined),
                      Text('${post.likes}'),
                    ]),
                    onChanged: (ON) {
                      if (ON) {
                        api.postIns('interact', {
                          'userinfo_id': globalUserId,
                          'post_id': post.post_id,
                          'act': 'L'
                        }).then((v) {
                          liked.value = true;
                          if (v['rowcount'] > 0) {
                          } else {
                            debugPrint('$v点赞失败');
                          }
                          throw "点赞失败";
                        });
                      } else {
                        api.del('interact', {
                          'userinfo_id': globalUserId,
                          'post_id': post.post_id,
                          'act': 'L'
                        }).then((v) {
                          liked.value = false;
                          if (v['rowcount'] > 0) {
                          } else {
                            debugPrint('$v取赞失败');
                          }
                          throw "取赞失败";
                        });
                      }
                    },
                  ),
                  Button(
                    child: Row(children: [
                      const Icon(Icons.chat_bubble_outline),
                      Text('${post.replys}'),
                    ]),
                    onPressed: () {
                      throw "暂未完工";
                    },
                  ),
                ],
              )),
        ],
      );
    }
  }

  dynamicMenuFlyoutList(context) {
    // debugPrint('dynamicMenuFlyoutList REBUILD');
    void removePageItem(Post element) {
      postsController.datas.removeAt(index);
      postsController.update();
    }

    var items = [
      MenuFlyoutItem(
        selected: postsController.selectable.value,
        text: const Text('选择'),
        onPressed: () {
          Flyout.of(context).close();
          postsController.selectable.value = !postsController.selectable.value;
        },
      ),
      const MenuFlyoutSeparator(),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.share),
        text: const Text('分享'),
        onPressed: Flyout.of(context).close,
      ),
      MenuFlyoutSubItem(
        text: const Text('发送到'),
        items: (_) => [
          MenuFlyoutItem(
            text: const Text('Bluetooth'),
            onPressed: Flyout.of(context).close,
          ),
          MenuFlyoutItem(
            text: const Text('Desktop (shortcut)'),
            onPressed: Flyout.of(context).close,
          ),
          MenuFlyoutSubItem(
            text: const Text('Compressed file'),
            items: (context) => [
              MenuFlyoutItem(
                text: const Text('Compress and email'),
                onPressed: Flyout.of(context).close,
              ),
              MenuFlyoutItem(
                text: const Text('Compress to .7z'),
                onPressed: Flyout.of(context).close,
              ),
              MenuFlyoutItem(
                text: const Text('Compress to .zip'),
                onPressed: Flyout.of(context).close,
              ),
            ],
          ),
        ],
      ),
    ];
    if (post.owner_url == globalUserId) {
      items.insertAll(1, [
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.edit),
          text: const Text('编辑'),
          onPressed: Flyout.of(context).close,
        ),
        MenuFlyoutItem(
            leading: const Icon(FluentIcons.delete),
            text: const Text('删除'),
            onPressed: () {
              Flyout.of(context).close();

              api.del('post', {'o': post.post_id}).then(
                  (v) => v['rowcount'] > 0 ? removePageItem(post) : null);
            }),
      ]);
    } else {
      items.insertAll(3, [
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.blocked),
          text: const Text('屏蔽此用户'),
          onPressed: Flyout.of(context).close,
        ),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.hands_free),
          text: const Text('举报'),
          onPressed: Flyout.of(context).close,
        ),
      ]);
      //不感兴趣
    }
    return items;
  }
}

class PostEachController extends GetxController {}
