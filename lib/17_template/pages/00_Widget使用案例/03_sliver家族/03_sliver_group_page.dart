import 'package:flutter/material.dart';
class DynamicStickyList extends StatefulWidget {
  const DynamicStickyList({super.key});

  @override
   createState() => _DynamicStickyListState();
}

class _DynamicStickyListState extends State<DynamicStickyList> {
  final ScrollController _scrollController = ScrollController();
  final List<DynamicSection> _sections = [];


  @override
  void initState() {
    super.initState();
    _loadData();
    _setupScrollListener();
  }

  void _loadData() {
    // 模拟加载数据
    setState(() {
      _sections.addAll([
        DynamicSection('最新动态', Icons.new_releases, [
          '用户A发布了新内容',
          '系统更新通知',
          '活动预告',
        ]),
        DynamicSection('热门话题', Icons.trending_up, [
          '#今日热门话题1',
          '#大家都在讨论这个',
          '#热门事件追踪',
        ]),
        DynamicSection('推荐关注', Icons.people, [
          '推荐用户1',
          '推荐用户2',
          '推荐用户3',
        ]),

      ]);
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // 这里可以实现更复杂的交互逻辑
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态分组列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _sections.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                '共有${_sections.length}个分组',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          ..._sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            return StickySection(
              title: section.title,
              headerColor: _getSectionColor(index),
              headerHeight: 60,
              children: section.items.map((item) => _buildListItem(item, section.icon)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(text),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击: $text')),
          );
        },
      ),
    );
  }

  Color _getSectionColor(int index) {
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


class DynamicSection {
  final String title;
  final IconData icon;
  final List<String> items;

  DynamicSection(this.title, this.icon, this.items);
}



class StickySection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color headerColor;
  final double headerHeight;

  const StickySection({
    Key? key,
    required this.title,
    required this.children,
    this.headerColor = Colors.blue,
    this.headerHeight = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        // 吸顶头部
        SliverPersistentHeader(
          pinned: true,
          delegate: _SectionHeaderDelegate(
            height: headerHeight,
            color: headerColor,
            title: title,
          ),
        ),
        // 内容列表
        SliverList(
          delegate: SliverChildListDelegate(children),
        ),
      ],
    );
  }
}

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Color color;
  final String title;

  _SectionHeaderDelegate({
    required this.height,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {

    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return title != oldDelegate.title || color != oldDelegate.color;
  }
}