/// 不用Getx：StatelessWidget，传入已请求的参数，一口气渲染完
/// 用Getx：模型除1个id外其余可null，初始化.obs，build包一个Obs
/// api请求尽量在Stateless的上一级，避免重绘（某些插件+Getx会疯狂刷新）
/// 懒加载：
/// 1. 父widget“第1次”api请求完成的数据传给（Obx包裹的）widget
/// 2. widget初始化GetxController，赋null值.obs，开始其余异步请求
/// 3. Obx更新数据


import 'dart:async';

import 'package:flut/common/api/api_client.dart' show ApiClient, ShowInfoBar;
import 'package:flut/pages/index.dart';
import 'package:flut/pages/msg.dart';
import 'package:get/get.dart';

import 'dart:ui';
import 'common/models/controller.dart';
import 'common/models/models.dart';
import 'theme.dart';
import './common/widgets/deferred_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/link.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart' show Icons, MaterialScrollBehavior;

import './common/routers/forms.dart' deferred as forms;
import './common/routers/inputs.dart' deferred as inputs;

// import 'package:flut/pages/msg.dart' deferred as msg;
// import 'package:flut/pages/profile.dart.bak' deferred as profile;
import 'package:timeago/timeago.dart' as timeago;
import 'package:flut/common/i18n/timeago.dart';

const String appTitle = 'eDonut';
ApiClient api=Get.put(ApiClient());

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if it's not on the web, windows or android, load the accent color
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    await flutter_acrylic.Window.hideWindowControls();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setMinimumSize(const Size(350, 200));
      await windowManager.setSize(const Size(700, 500));
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }

  api.putUpd('userinfo', {'status':'O'}, {'u':globalUserId});
  // runApp(const MyApp());
  ShowInfoBar().run(const MyApp());
  timeago.setLocaleMessages('zh', zhTimeago());
  timeago.setDefaultLocale('zh');

  Future.wait([
    DeferredWidget.preload(forms.loadLibrary),
    DeferredWidget.preload(inputs.loadLibrary),
  ]);
}

final _appTheme = AppTheme();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appTheme,
      builder: (context, child) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp.router(
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('zh', 'CN'),
          ],
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
              PointerDeviceKind.trackpad,
            },
          ),
          color: appTheme.color,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          theme: FluentThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          locale: appTheme.locale,
          builder: (context, child) {
            return Directionality(
              textDirection: appTheme.textDirection,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!,
              ),
            );
          },
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}
late MyHomePageState myHomePageState;
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.child,
    required this.shellContext,
  });

  final Widget child;
  final BuildContext? shellContext;

  @override
  State<MyHomePage> createState() {
    myHomePageState=MyHomePageState();
    return myHomePageState;
  }
}

class MyHomePageState extends State<MyHomePage> with WindowListener {
  bool value = false;
  static const double _iconsize = 24;

  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  setOnTap(String path) {
    if (GoRouterState.of(context).uri.toString() != path) {
      context.go(path);
    }
  }

  late final List<NavigationPaneItem> originalItems = [
    PaneItem(
      key: const ValueKey('/'),
      onTap: () => setOnTap('/'),
      icon: const Icon(Icons.home, size: _iconsize),
      title: const Text('主页'),
      body: const SizedBox.shrink(),
      infoBadge: const InfoBadge(source: Text('8')),
    ),
    PaneItem(
      key: const ValueKey('/msg'),
      onTap: () => setOnTap('/msg'),
      icon: const Icon(Icons.chat_bubble, size: _iconsize),
      title: const Text('消息'),
      body: const SizedBox.shrink(),
      infoBadge: const InfoBadge(source: Text('99+')),
    ),
    PaneItem(
      key: ValueKey('/profile/${globalUserId}'),
      onTap: () => setOnTap('/profile/${globalUserId}'),
      icon: const Icon(Icons.person, size: _iconsize),
      title: const Text('我的'),
      body: const SizedBox.shrink(),
      infoBadge: const InfoBadge(source: Text('聆听者+9')),
    ),
    // PaneItemHeader(header: const Text('快捷操作')),
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey('/home/newpost'),
      onTap: () => setOnTap('/home/newpost'),
      icon: const Icon(Icons.add, size: _iconsize),
      title: const Text('发帖'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/msg/contacts'),
      onTap: () => setOnTap('/msg/contacts'),
      icon: const Icon(Icons.people, size: _iconsize),
      title: const Text('联系人'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/profile/favor'),
      onTap: () => setOnTap('/profile/favor'),
      icon: const Icon(Icons.star, size: _iconsize),
      title: const Text('收藏'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/profile/likes'),
      onTap: () => setOnTap('/profile/favor'),
      icon: const Icon(Icons.thumb_up, size: _iconsize),
      title: const Text('点赞'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/profile/history'),
      onTap: () => setOnTap('/profile/favor'),
      icon: const Icon(Icons.history, size: _iconsize),
      title: const Text('历史'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/profile/works'),
      onTap: () => setOnTap('/profile/favor'),
      icon: const Icon(Icons.play_circle, size: _iconsize),
      title: const Text('作品'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/profile/replies'),
      onTap: () => setOnTap('/profile/favor'),
      icon: const Icon(Icons.reply_all, size: _iconsize),
      title: const Text('回复'),
      body: const SizedBox.shrink(),
    ),
    PaneItemExpander(
        key: const ValueKey('/pay/all'),
        onTap: () => setOnTap('/pay/all'),
        icon: const Icon(Icons.done_all, size: _iconsize),
        title: const Text('所有订单'),
        body: const SizedBox.shrink(),
        initiallyExpanded: true,
        items: [
          PaneItem(
            key: const ValueKey('/pay/1topay'),
            onTap: () => setOnTap('/pay/1topay'),
            icon: const Icon(Icons.credit_card, size: _iconsize),
            title: const Text('待付款'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            key: const ValueKey('/pay/2receive'),
            onTap: () => setOnTap('/pay/2receive'),
            icon: const Icon(Icons.send, size: _iconsize),
            title: const Text('待收货'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            key: const ValueKey('/pay/3comment'),
            onTap: () => setOnTap('/pay/3comment'),
            icon: const Icon(Icons.mode_comment, size: _iconsize),
            title: const Text('待评价'),
            body: const SizedBox.shrink(),
          ),
        ]),

    PaneItemHeader(header: const Text('最近常看')),
    PaneItem(
      key: const ValueKey('/profile/...'),
      onTap: () => setOnTap('/profile/...'),
      icon: const Icon(Icons.person, size: _iconsize),
      title: const Text('某用户'),
      body: const SizedBox.shrink(),
    ),
    PaneItemHeader(header: const Text('热搜趋势')),
    PaneItem(
      key: const ValueKey('/post/...'),
      onTap: () => setOnTap('/post/...'),
      icon: const Icon(Icons.tag, size: _iconsize),
      title: const Text('1. 某话题'),
      body: const SizedBox.shrink(),
    ),

    // TODO: Scrollbar, RatingBar
  ];
  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey('/settings'),
      icon: const Icon(Icons.settings, size: _iconsize),
      title: const Text('设置'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != '/settings') {
          context.go('/settings');
        }
      },
    ),
    _LinkPaneItemAction(
      icon: const Icon(Icons.code, size: _iconsize),
      title: const Text('源代码'),
      link: 'https://github.com/bdlukaa/fluent_ui',
      body: const SizedBox.shrink(),
    ),
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int indexOriginal = originalItems
        .where((item) => item.key != null)
        .toList()
        .indexWhere((item) => item.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = footerItems
          .where((element) => element.key != null)
          .toList()
          .indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
      }
      return originalItems
              .where((element) => element.key != null)
              .toList()
              .length +
          indexFooter;
    } else {
      return indexOriginal;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ShowInfoBar().context = context;
    final localizations = FluentLocalizations.of(context);

    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    if (widget.shellContext != null) {
      if (router.canPop() == false) {
        setState(() {});
      }
    }
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        height: 30,
        automaticallyImplyLeading: false,
        leading: () {
          final enabled = widget.shellContext != null && router.canPop();

          final onPressed = enabled
              ? () {
                  if (router.canPop()) {
                    context.pop();
                    setState(() {});
                  }
                }
              : null;
          return NavigationPaneTheme(
            data: NavigationPaneTheme.of(context).merge(NavigationPaneThemeData(
              unselectedIconColor: ButtonState.resolveWith((states) {
                if (states.isDisabled) {
                  return ButtonThemeData.buttonColor(context, states);
                }
                return ButtonThemeData.uncheckedInputColor(
                  FluentTheme.of(context),
                  states,
                ).basedOnLuminance();
              }),
            )),
            child: Builder(
              builder: (context) => PaneItem(
                icon: const Icon(Icons.arrow_back, size: 20),
                title: Text(localizations.backButtonTooltip),
                body: const SizedBox.shrink(),
                enabled: enabled,
              ).build(
                context,
                false,
                onPressed,
                displayMode: PaneDisplayMode.compact,
              ),
            ),
          );
        }(),
        title: () {
          if (kIsWeb) {
            return const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(appTitle),
            );
          }
          return const DragToMoveArea(
            child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(appTitle)),
          );
        }(),
        actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          ToggleSwitch(
            content: const Icon(
              Icons.dark_mode,
            ),
            checked: FluentTheme.of(context).brightness.isDark,
            onChanged: (v) {
              if (v) {
                appTheme.mode = ThemeMode.dark;
              } else {
                appTheme.mode = ThemeMode.light;
              }
            },
          ),
          if (isDesktop) const WindowButtons(),
        ]),
      ),
      paneBodyBuilder: (item, child) {
        final name =
            item?.key is ValueKey ? (item!.key as ValueKey).value : null;
        return FocusTraversalGroup(
          key: ValueKey('body$name'),
          child: widget.child,
        );
      },
      pane: NavigationPane(
        size: const NavigationPaneSize(openWidth: 250),
        selected: _calculateSelectedIndex(context),
        header: SizedBox(
          height: kOneLineTileHeight,
          child: ShaderMask(
            shaderCallback: (rect) {
              final color = appTheme.color.defaultBrushFor(
                theme.brightness,
              );
              return LinearGradient(
                colors: [
                  color,
                  color,
                ],
              ).createShader(rect);
            },
            child: const FlutterLogo(
              style: FlutterLogoStyle.horizontal,
              size: 100.0,
              textColor: Colors.white,
              duration: Duration.zero,
            ),
          ),
        ),
        displayMode: appTheme.displayMode,
        indicator: () {
          switch (appTheme.indicator) {
            case NavigationIndicators.end:
              return const EndNavigationIndicator();
            case NavigationIndicators.sticky:
            default:
              return const StickyNavigationIndicator();
          }
        }(),
        items: originalItems,
        autoSuggestBox: Builder(builder: (context) {
          return AutoSuggestBox(
            key: searchKey,
            focusNode: searchFocusNode,
            controller: searchController,
            unfocusedColor: Colors.transparent,
            items: originalItems.whereType<PaneItem>().map((item) {
              assert(item.title is Text);
              final text = (item.title as Text).data!;
              return AutoSuggestBoxItem(
                label: text,
                value: text,
                onSelected: () {
                  item.onTap?.call();
                  searchController.clear();
                  searchFocusNode.unfocus();
                  final view = NavigationView.of(context);
                  if (view.compactOverlayOpen) {
                    view.compactOverlayOpen = false;
                  } else if (view.minimalPaneOpen) {
                    view.minimalPaneOpen = false;
                  }
                },
              );
            }).toList(),
            trailingIcon: IgnorePointer(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, size: _iconsize),
              ),
            ),
            placeholder: '搜索一切...',
          );
        }),
        autoSuggestBoxReplacement: const Icon(Icons.search, size: _iconsize),
        footerItems: footerItems,
      ),
      onOpenSearch: searchFocusNode.requestFocus,
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      api.putUpd('userinfo', {'status':'o'}, {'u':globalUserId});
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('是否退出'),
            content: const Text('请检查未保存的工作'),
            actions: [
              FilledButton(
                child: const Text('退出'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              Button(
                child: const Text('等会儿'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 35,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _LinkPaneItemAction extends PaneItem {
  _LinkPaneItemAction({
    required super.icon,
    required this.link,
    required super.body,
    super.title,
  });

  final String link;

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
    int? itemIndex,
  }) {
    return Link(
      uri: Uri.parse(link),
      builder: (context, followLink) => Semantics(
        link: true,
        child: super.build(
          context,
          selected,
          followLink,
          displayMode: displayMode,
          showTextOnTop: showTextOnTop,
          itemIndex: itemIndex,
          autofocus: autofocus,
        ),
      ),
    );
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

FutureOr<bool> closeController<T extends GetxController>() {
  return Get.delete<T>();
}

final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    builder: (context, state, child) {
      ShowInfoBar().context = context;
      return MyHomePage(
        shellContext: _shellNavigatorKey.currentContext,
        child: child,
      );
    },
    routes: [
      /// Home
      GoRoute(
        path: '/',
        builder: (context, state) => PostView(),
        onExit: (context) => closeController<ListViewController<Post>>(),
      ),

      GoRoute(path: '/settings', builder: (context, state) => const Settings()),

      GoRoute(
        path: '/msg',
        builder: (context, state) => DeferredWidget(
          inputs.loadLibrary,
          () => Msg(),
        ),
        onExit: (context) => closeController<MsgController>(),
      ),

      GoRoute(
        path: '/profile/:user_id',
        builder: (context, state) =>
            Profile(state.pathParameters['user_id'] ?? globalUserId),
        onExit: (context) => closeController<ListViewController<Post>>(),
      ),

      /// Slider
      GoRoute(
        path: '/home/newpost',
        builder: (context, state) => NewPost(),
      ),

      /// ToggleSwitch
      GoRoute(
        path: '/msg/contacts',
        builder: (context, state) => DeferredWidget(
          inputs.loadLibrary,
          () => inputs.ToggleSwitchPage(),
        ),
      ),

      /// /// Form
      /// TextBox
      GoRoute(
        path: '/forms/text_box',
        builder: (context, state) => DeferredWidget(
          forms.loadLibrary,
          () => forms.TextBoxPage(),
        ),
      ),
    ],
  ),
]);
