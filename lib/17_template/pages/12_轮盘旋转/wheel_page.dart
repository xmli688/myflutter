import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'wheel_controller.dart';
import 'wheel_item.dart';

/// 轮盘抽奖页面（GetX 版本，支持 emoji / 图片 / 文字 混合）
class WheelPage extends GetView<WheelController> {
  const WheelPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WheelController());

    return Scaffold(
      backgroundColor: const Color(0xFF1F1147),
      appBar: AppBar(
        title: const Text('幸运大转盘'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 旋转轮盘
                  AnimatedBuilder(
                    animation: controller.animationController,
                    builder: (context, child) {
                      final angle = controller.isSpinning.value
                          ? controller.animation.value
                          : controller.currentAngle.value;
                      return Transform.rotate(
                        angle: angle,
                        // 图片加载后要重绘
                        child: Obx(
                              () => CustomPaint(
                            size: const Size(320, 320),
                            painter: _WheelPainter(
                              items: controller.items,
                              colors: controller.sectorColors,
                              imageCache:
                              Map<String, ui.Image>.from(controller.imageCache),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // 固定指针
                  const Positioned(
                    top: 0,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.redAccent,
                      size: 60,
                    ),
                  ),
                  // 中心 GO 按钮
                  GestureDetector(
                    onTap: controller.spin,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Colors.white, Color(0xFFFFC107)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Obx(
                            () => Text(
                          controller.isSpinning.value ? '…' : 'GO',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD84315),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Obx(
                  () => ElevatedButton.icon(
                onPressed:
                controller.isSpinning.value ? null : controller.spin,
                icon: const Icon(Icons.refresh),
                label: Text(
                  controller.isSpinning.value ? '旋转中...' : '开始抽奖',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// GetX 路由绑定
class WheelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WheelController>(() => WheelController());
  }
}

/// 自定义绘制轮盘（支持 emoji / 图片 / 文字）
class _WheelPainter extends CustomPainter {
  final List<WheelItem> items;
  final List<Color> colors;
  final Map<String, ui.Image> imageCache;

  _WheelPainter({
    required this.items,
    required this.colors,
    required this.imageCache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;
    final double sectorAngle = 2 * math.pi / items.length;

    // 让第 0 个扇区中心朝向 -π/2（正上方）
    final double startBase = -math.pi / 2 - sectorAngle / 2;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final double start = startBase + i * sectorAngle;

      // 1. 填充扇区
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sectorAngle,
        true,
        paint,
      );

      // 2. 分隔线
      final Paint linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2;
      final double endX = center.dx + radius * math.cos(start);
      final double endY = center.dy + radius * math.sin(start);
      canvas.drawLine(center, Offset(endX, endY), linePaint);

      // 3. 内容（emoji / 图片 / 文字）
      final double contentAngle = start + sectorAngle / 2;
      final double contentRadius = radius * 0.65;
      final double cx = center.dx + contentRadius * math.cos(contentAngle);
      final double cy = center.dy + contentRadius * math.sin(contentAngle);

      canvas.save();
      canvas.translate(cx, cy);
      // 让内容 "头朝外"：指向圆心外侧
      canvas.rotate(contentAngle + math.pi / 2);

      switch (item.type) {
        case WheelItemType.emoji:
          _drawEmoji(canvas, item.value);
          break;
        case WheelItemType.text:
          _drawText(canvas, item.value);
          break;
        case WheelItemType.image:
          _drawImage(canvas, item);
          break;
      }

      // 如果有 label，在主体下方再画一行文字
      if (item.label != null &&
          item.type != WheelItemType.text &&
          item.label!.isNotEmpty) {
        _drawLabel(canvas, item.label!);
      }

      canvas.restore();
    }

    // 外边框
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFFB71C1C);
    canvas.drawCircle(center, radius - 2, borderPaint);
  }

  void _drawEmoji(Canvas canvas, String emoji) {
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: 36),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2 - 8));
  }

  void _drawText(Canvas canvas, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }

  void _drawImage(Canvas canvas, WheelItem item) {
    final ui.Image? img = imageCache[item.value];
    const double displaySize = 48;
    if (img == null) {
      // 图片还没加载完，用占位符
      _drawEmoji(canvas, '🖼️');
      return;
    }
    final Rect src = Rect.fromLTWH(
      0,
      0,
      img.width.toDouble(),
      img.height.toDouble(),
    );
    final Rect dst = Rect.fromCenter(
      center: const Offset(0, -8),
      width: displaySize,
      height: displaySize,
    );
    canvas.drawImageRect(img, src, dst, Paint()..isAntiAlias = true);
  }

  void _drawLabel(Canvas canvas, String label) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, 24));
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.imageCache.length != imageCache.length;
  }
}