library api;

// export './xxxx.dart';
import 'package:flutter/material.dart';



// String hexColor =
//                         '#${index.toRadixString(16).padLeft(8, '0')}';
//                     Color color =
//                         Color(int.parse(hexColor.substring(1), radix: 16));
//                     return Container(
//                         color: color,
//                         child: Text(index.toString()));




class GridViewLazyLoadDemo extends StatefulWidget {
  @override
  _GridViewLazyLoadDemoState createState() => _GridViewLazyLoadDemoState();
}

class _GridViewLazyLoadDemoState extends State<GridViewLazyLoadDemo> {
// 模拟数据源
  List<int> items = List.generate(20, (index) => index);

// 滚动控制器
  ScrollController _controller = ScrollController();

// 是否正在加载更多
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
// 添加滚动监听
    _controller.addListener(() {
// 如果滚动到底部
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
// 加载更多数据
        loadMore();
      }
    });
  }

  @override
  void dispose() {
// 移除滚动监听
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GridView Lazy Load Demo'),
      ),
      body: GridView.builder(
        controller: _controller,
        itemCount: items.length + 1, // 多一个用于显示加载提示
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 每行两列
          childAspectRatio: 1.0, // 宽高比为1
        ),
        itemBuilder: (context, index) {
// 如果是最后一个，则显示加载提示
          if (index == items.length) {
            return _buildLoadMore();
          } else {
// 否则显示正常的子组件
            return _buildItem(index);
          }
        },
      ),
    );
  }

// 构建加载提示组件
  Widget _buildLoadMore() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '正在加载更多...',
              style: TextStyle(fontSize: 16.0),
            ),
            CircularProgressIndicator(
              strokeWidth: 1.0,
            )
          ],
        ),
      ),
    );
  }

// 构建正常的子组件
  Widget _buildItem(int index) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Item $index',
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
      color: Colors.blue[300],
      margin: EdgeInsets.all(5.0),
    );
  }

// 模拟加载更多数据的方法
  void loadMore() async {
// 如果正在加载，则直接返回
    if (_isLoading) return;
// 设置状态为正在加载
    setState(() {
      _isLoading = true;
    });
// 模拟延时操作
    await Future.delayed(Duration(seconds: 2), () {
// 添加新的数据
      setState(() {
        items.addAll(List.generate(10, (index) => items.length + index));
      });
// 设置状态为加载完成
      setState(() {
        _isLoading = false;
      });
    });
  }
}
