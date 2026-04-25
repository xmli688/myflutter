import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'wheel_item.dart';

/// 轮盘控制器（GetX）
class WheelController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // 8 个奖品：支持 emoji 和 图片 混合
  // 如需改成图片，把对应项改成 WheelItem.image('assets/images/xxx.png', label: 'xxx') 即可
  final List<WheelItem> items = const [
    WheelItem.emoji('🎁', label: '礼物'),
    WheelItem.emoji('🍎', label: '苹果'),
    WheelItem.image('assets/images/coin.webp', label: '金币'),
    WheelItem.emoji('🍔', label: '汉堡'),
    WheelItem.emoji('🎮', label: '游戏'),
    WheelItem.image('assets/images/crown.webp', label: '皇冠'), // 目标（索引 5）
    WheelItem.emoji('⭐', label: '星星'),
    WheelItem.emoji('🍩', label: '甜甜圈'),
  ];

  // 扇区填充色（交替）
  final List<Color> sectorColors = const [
    Color(0xFFFFD54F),
    Color(0xFFFF8A65),
    Color(0xFFFFD54F),
    Color(0xFFFF8A65),
    Color(0xFFFFD54F),
    Color(0xFFFF8A65),
    Color(0xFFFFD54F),
    Color(0xFFFF8A65),
  ];

  // 固定中奖索引（第 6 个）
  static const int targetIndex = 5;

  // 动画
  late final AnimationController animationController;
  late Animation<double> animation;

  // 响应式状态
  final RxDouble currentAngle = 0.0.obs;
  final RxBool isSpinning = false.obs;

  // 图片资源缓存：key 为 asset 路径，value 为已解码图片
  final RxMap<String, ui.Image> imageCache = <String, ui.Image>{}.obs;

  // 音频
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    animation = Tween<double>(begin: 0, end: 0).animate(animationController);

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isSpinning.value = false;
        currentAngle.value = animation.value;
        _sfxPlayer.stop();
        _showResultDialog();
      }
    });

    _preloadImages();
    _playBgm();
  }

  /// 预加载所有图片类型的奖品资源
  Future<void> _preloadImages() async {
    for (final item in items) {
      if (item.type == WheelItemType.image &&
          !imageCache.containsKey(item.value)) {
        try {
          final img = await loadUiImageFromAsset(item.value);
          imageCache[item.value] = img;
        } catch (e) {
          debugPrint('加载图片失败 ${item.value}: $e');
        }
      }
    }
  }

  Future<void> _playBgm() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.4);
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
    } catch (e) {
      debugPrint('播放背景音乐失败: $e');
    }
  }

  Future<void> _playSpinSfx() async {
    try {
      await _sfxPlayer.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayer.setVolume(0.8);
      await _sfxPlayer.play(AssetSource('audio/spin.mp3'));
    } catch (e) {
      debugPrint('播放旋转音效失败: $e');
    }
  }

  /// 开始旋转，固定落在目标索引
  void spin() {
    if (isSpinning.value) return;
    isSpinning.value = true;

    _playSpinSfx();

    final double sectorAngle = 2 * math.pi / items.length;
    final double targetCenter =
        -math.pi / 2 + (targetIndex ) * sectorAngle;
    double targetAngle = -math.pi / 2 - targetCenter;
    targetAngle = targetAngle % (2 * math.pi);
    if (targetAngle < 0) targetAngle += 2 * math.pi;

    const int extraTurns = 6;
    final double endAngle = currentAngle.value +
        extraTurns * 2 * math.pi +
        (targetAngle - (currentAngle.value % (2 * math.pi)));

    animation = Tween<double>(
      begin: currentAngle.value,
      end: endAngle,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    animationController
      ..reset()
      ..forward();
  }

  void _showResultDialog() {
    final item = items[targetIndex];
    final String resultText = item.label ??
        (item.type == WheelItemType.image ? '图片奖品' : item.value);

    Get.dialog(
      AlertDialog(
        title: const Text('🎉 恭喜中奖'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildResultPreview(item),
            const SizedBox(width: 12),
            Flexible(child: Text('您抽中了：$resultText')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildResultPreview(WheelItem item) {
    switch (item.type) {
      case WheelItemType.emoji:
      case WheelItemType.text:
        return Text(item.value, style: const TextStyle(fontSize: 36));
      case WheelItemType.image:
        return Image.asset(item.value, width: 48, height: 48);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    for (final img in imageCache.values) {
      img.dispose();
    }
    super.onClose();
  }
}