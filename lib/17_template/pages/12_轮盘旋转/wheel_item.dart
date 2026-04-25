import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// 奖品类型
enum WheelItemType {
  /// 纯文字（例如"奖品 1"）
  text,

  /// emoji 表情符号（例如 🎁、🍎）
  emoji,

  /// 本地资源图片，value 为 asset 路径
  image,
}

/// 轮盘中的单个奖品
class WheelItem {
  /// 类型
  final WheelItemType type;

  /// 显示内容：
  /// - text / emoji 时为字符串
  /// - image 时为 asset 路径（如 'assets/images/apple.png'）
  final String value;

  /// 可选的副标题 / 文字说明（例如 image 下方显示的名称）
  final String? label;

  const WheelItem.text(this.value, {this.label}) : type = WheelItemType.text;

  const WheelItem.emoji(this.value, {this.label}) : type = WheelItemType.emoji;

  const WheelItem.image(this.value, {this.label}) : type = WheelItemType.image;
}

/// 工具：把 asset 图片加载成 ui.Image，便于在 CustomPainter 中绘制
Future<ui.Image> loadUiImageFromAsset(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  final ui.Codec codec =
  await ui.instantiateImageCodec(data.buffer.asUint8List());
  final ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}