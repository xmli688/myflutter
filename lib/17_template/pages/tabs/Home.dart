import 'package:flutter/material.dart';
import 'package:my_app/17_template/pages/01_%E4%B8%8B%E6%8B%89%E5%88%B7%E6%96%B0_%E4%B8%8A%E6%8B%89%E5%8A%A0%E8%BD%BD/News.dart';
import 'package:my_app/17_template/pages/02_%E8%A7%86%E9%A2%91%E6%92%AD%E6%94%BEvideoplayer/et_videoplayer_custom.dart';
import 'package:my_app/17_template/pages/03_%E5%9B%BE%E7%89%87%E8%BD%AE%E6%92%AD/swipe_page.dart';
import 'package:my_app/17_template/pages/04_%E6%9C%AC%E5%9C%B0%E5%AD%98%E5%82%A8/storage_page.dart';
import 'package:my_app/17_template/pages/05_dialog/dialog.dart';
import 'package:my_app/17_template/pages/06_%E8%87%AA%E5%AE%9A%E4%B9%89dialog/et_custom_dialog.dart';
import 'package:my_app/17_template/pages/07_eventbus%E4%BD%BF%E7%94%A8/eventbus_page.dart';
import 'package:get/get.dart';
import 'package:my_app/17_template/pages/08_GetX%E7%9A%84%E4%BD%BF%E7%94%A8/getx_page_demo.dart';
import 'package:my_app/17_template/pages/09_webPage%E9%A1%B5%E9%9D%A2%E5%8A%A0%E8%BD%BD/web_page.dart';
import 'package:my_app/17_template/pages/tabs/home_drawer.dart';

import '../10_Flow流式布局动画圆形菜单/bottom_5_page.dart';
import '../11_path_provider使用/path_provider_page.dart';
import '../12_轮盘旋转/wheel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildElevatedButton(
                context, "01:跳转到下拉刷新，上拉分页加载更多页面", NewsPage.routeName),
            _buildElevatedButton(
                context, "02:跳转视频播放页面", ETVideoPlayerView.routeName),
            _buildElevatedButton(
                context, "03:轮播图card_swiper的使用", ETSwiperPage.routeName),
            _buildElevatedButton(context, "04:数据本地存储", ETStoragePage.routeName),
            _buildElevatedButton(
                context, "05:Dialog页面", ETDialogPage.routeName),
            _buildButton(
                title: "06:自定义Dialog页面",
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return ETCustomDialog("关于我们", "内容是很多很西");
                      });
                }),
            _buildElevatedButton(
                context, "07:eventbus使用", EventBusPage.routeName),
            // 导航使用GetX的方式跳转
            _buildElevatedButton(
                context, "08:GetX使用", ETGetXPageDemo.routeName),
            _buildButton(
                title: "09：加载web页面",
                onPressed: () {
                  Get.to(const WebPage());
                }),
            _buildButton(
                title: "10：加载半圆形菜单",
                onPressed: () {
                  Get.to(const Bottom5Page());
                }),
            _buildButton(
                title: "11：文件、文件夹操作 path_provider的使用",
                onPressed: () {
                  Get.to(const PathProviderPage());
                }),
            _buildButton(
                title: '12：轮盘旋转动画',
                onPressed: () {
                  Get.to(const WheelPage());
                }),

          ],
        ),
      ),
      drawer: const HomeDrawer(),
      endDrawer: const Drawer(
        child: Center(child: Text('endDrawer')),
      ),
    );
  }

  Widget _buildElevatedButton(
      BuildContext context, String title, String routeName) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          // Navigator.pushNamed(context, routeName);
          // 使用GetX命名路由的方式跳转
          Get.toNamed(routeName);
        },
      ),
    );
  }

  Widget _buildButton({required String title, required Function onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          onPressed();
        },
      ),
    );
  }
}
