import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/17_template/pages/00_Widget%E4%BD%BF%E7%94%A8%E6%A1%88%E4%BE%8B/02_tabBar_tabBarView/02_tabBar_tabbarView.dart';
import 'package:my_app/17_template/pages/00_Widget%E4%BD%BF%E7%94%A8%E6%A1%88%E4%BE%8B/03_sliver%E5%AE%B6%E6%97%8F/03_sliver%E5%AE%B6%E6%97%8F.dart';
import 'package:my_app/17_template/pages/00_Widget%E4%BD%BF%E7%94%A8%E6%A1%88%E4%BE%8B/04_IntrinsicHeight%E5%AD%90%E7%BB%84%E4%BB%B6%E7%A1%AE%E5%AE%9A%E9%AB%98%E5%BA%A6/04_IntrinsicHeight%E7%94%B1%E5%AD%90%E7%BB%84%E4%BB%B6%E7%A1%AE%E5%AE%9A%E9%AB%98%E5%BA%A6.dart';
import '../00_Widget使用案例/01_组件显示隐藏/01_visibility_page显隐组件.dart';
import '../00_Widget使用案例/03_sliver家族/03_sliver_group_page.dart';
import '../00_Widget使用案例/05_自定义三角形/05_绘制三角形.dart';
import '../00_Widget使用案例/05_自定义三角形/triangle_painter.dart';
import 'home_drawer.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('组件使用案例'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildElevatedButton(
                context: context,
                title: "Visibility显隐组件",
                onPressed: () {
                  Get.to(const VisibilityPage());
                }),
            _buildElevatedButton(
                context: context,
                title: "tabbar_tabbarview使用",
                onPressed: () {
                  Get.to(const MyTabBarPage());
                }),
            _buildElevatedButton(
                context: context,
                title: "Sliver使用",
                onPressed: () {
                  Get.to(const SliverPage());
                }),
            _buildElevatedButton(
                context: context,
                title: "Sliver实现分组列表吸顶效果",
                onPressed: () {
                  Get.to( DynamicStickyList());
                }),
            _buildElevatedButton(
                context: context,
                title: "IntrinsicHeight使用",
                onPressed: () {
                  Get.to(const ETIntrinsicHeightPage());
                }),
            _buildElevatedButton(
                context: context,
                title: "绘制三角形",
                onPressed: () {
                  Get.to(const TrianglePage());
                }),
          ],
        ),
      ),
      drawer: const HomeDrawer(),
    );
  }
}

Widget _buildElevatedButton(
    {required BuildContext context,
    required String title,
    required Function onPressed}) {
  return ElevatedButton(
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    onPressed: () {
      onPressed();
    },
  );
}
