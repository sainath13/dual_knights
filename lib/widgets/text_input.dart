// lib/widgets/text_input.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameTextInput extends PositionComponent with TapCallbacks {
  final String placeholder;
  final bool isPassword;
  String value = '';
  bool isFocused = false;
  late final TextComponent textDisplay;
  late final RectangleComponent background;

  GameTextInput({
    required Vector2 position,
    required Vector2 size,
    required this.placeholder,
    this.isPassword = false,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF333333),
    );
    add(background);

    // Text Display
    textDisplay = TextComponent(
      text: placeholder,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 20,
          color: Color(0xFF999999),
        ),
      ),
      anchor: Anchor.centerLeft,
      position: Vector2(10, size.y / 2),
    );
    add(textDisplay);
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (background.containsPoint(event.canvasPosition)) {
      isFocused = true;
      RawKeyboard.instance.addListener(_handleKeyEvent);
      return true;
    }
    return false;
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (!isFocused) return;

    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace && value.isNotEmpty) {
        value = value.substring(0, value.length - 1);
      } else if (event.character != null && 
                 event.character!.isNotEmpty && 
                 !event.isControlPressed) {
        value += event.character!;
      }

      textDisplay.text = isPassword ? '•' * value.length : value;
      if (value.isEmpty) {
        textDisplay.text = placeholder;
      }
    }
  }

  @override
  void onRemove() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.onRemove();
  }
}
