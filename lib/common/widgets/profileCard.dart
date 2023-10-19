// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:ui' show ImageFilter;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flut/common/api/api_client.dart';
import 'package:flut/common/models/models.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileCard extends StatelessWidget {
  ProfileCard(this.userinfo, this.profilePost, {super.key,this.headHeight});
  final Userinfo userinfo;
  final Post profilePost;
  final ApiClient api = Get.find();
  final double? headHeight;
  double blurR = 20;

  lastOnline() {
    if (userinfo.last_online != null) {
      return "${timeago.format(userinfo.last_online!, locale: 'zh')}上线";
    } else
      return '';
  }

  @override
  Widget build(BuildContext context) {
    // 一旦使用FutureBuilder，与Reorder的疯狂重绘搭配，就会鬼畜
    // 读取缓存
    try {
      // userinfo = postsController.asyncDatas[post.owner_url];
    } catch (err) {
      // userinfo = Userinfo.fromJson(
      //     {'userinfo_id': post.owner_url, 'username': post.owner_url});
      // throw "用户加载失败 ${post.owner_url}";
    } finally {
      // ignore: control_flow_in_finally
      return Stack(
        alignment: Alignment.topLeft,
        fit: StackFit.passthrough,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImageFiltered(
                imageFilter: (blurR == 0)
                    ? ImageFilter.dilate()
                    : ImageFilter.blur(
                        sigmaX: blurR, sigmaY: blurR, tileMode: TileMode.decal),
                child: Image.network(userinfo.avatar ?? '',
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    height: (headHeight!=null)?headHeight:100,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/niko_huh.png',
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          height: 100,
                        )),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              colors: [
                                Colors.orange,
                                ...Colors.accentColors,
                              ],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Text(
                            '${userinfo.nick}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SelectableText('  @${userinfo.username}  '),
                        Text(userinfo.status == 'O' ? '在线' : '离线'),
                      ],
                    ),
                    Text(lastOnline()),
                    Text('关注 ${userinfo.following} | 粉丝 ${profilePost.favor}'),
                    MarkdownBody(
                      data: '${userinfo.intro}',
                      shrinkWrap: true,
                      selectable: true,
                    ),
                    Row(
                      children: [
                        Icon(Icons.email),
                        SelectableText(' ${userinfo.email}'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_pin),
                        SelectableText(' ${userinfo.pos}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  child: IconButton(
                    icon: Image.network(userinfo.avatar ?? '',
                        width: 90,
                        height: 90,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              'assets/niko_huh.png',
                              width: 90,
                              height: 90,
                            )),
                    onPressed: () => throw "希望下一次不是用flutter写东西了",
                    style: ButtonStyle(
                        padding: ButtonState.all(EdgeInsets.all(0))),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: userinfo.status == 'O'
                        ? Colors.blue
                        : Color.fromARGB(255, 199, 199, 199),
                    borderRadius: BorderRadius.circular(20),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }
  }
}
