// lib/screens/login_screen.dart

import 'dart:async';
import 'dart:ui';
import 'package:dual_knights/widgets/text_input.dart';
import 'package:dual_knights/routes/routes.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide TextStyle;
import 'package:flame/text.dart';

class LoginScreen extends PositionComponent with TapCallbacks {
  late final TextComponent titleText;
  late final GameTextInput usernameInput;
  late final GameTextInput passwordInput;
  late final TextComponent loginButton;
  late final TextComponent registerButton;
  late final TextComponent guestButton;
  late final RectangleComponent loginButtonBg;
  late final RectangleComponent registerButtonBg;
  late final RectangleComponent guestButtonBg;

  @override
  FutureOr<void> onLoad() async {
    // Title
    titleText = TextComponent(
      text: 'Dual Knights',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          color: Color(0xFFFFFFFF),
          fontFamily: 'Arial',
        ),
      ),
    );
    titleText.position = Vector2(640, 200);
    titleText.anchor = Anchor.center;
    add(titleText);

    // Username Input
    usernameInput = GameTextInput(
      position: Vector2(490, 300),
      size: Vector2(300, 40),
      placeholder: 'Username',
    );
    add(usernameInput);

    // Password Input
    passwordInput = GameTextInput(
      position: Vector2(490, 360),
      size: Vector2(300, 40),
      placeholder: 'Password',
      isPassword: true,
    );
    add(passwordInput);

    // Login Button Background
    loginButtonBg = RectangleComponent(
      position: Vector2(640, 440),
      size: Vector2(300, 50),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF4CAF50),
    );
    add(loginButtonBg);

    // Login Button Text
    loginButton = TextComponent(
      text: 'Login',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Color(0xFFFFFFFF),
          fontFamily: 'Arial',
        ),
      ),
    );
    loginButton.position = Vector2(640, 440);
    loginButton.anchor = Anchor.center;
    add(loginButton);

    // Register Button Background
    registerButtonBg = RectangleComponent(
      position: Vector2(640, 510),
      size: Vector2(300, 50),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF2196F3),
    );
    add(registerButtonBg);

    // Register Button Text
    registerButton = TextComponent(
      text: 'Register Now',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Color(0xFFFFFFFF),
          fontFamily: 'Arial',
        ),
      ),
    );
    registerButton.position = Vector2(640, 510);
    registerButton.anchor = Anchor.center;
    add(registerButton);

    // Guest Button Background
    guestButtonBg = RectangleComponent(
      position: Vector2(640, 580),
      size: Vector2(300, 50),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF757575), // Gray color for guest button
    );
    add(guestButtonBg);

    // Guest Button Text
    guestButton = TextComponent(
      text: 'Continue as Guest',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Color(0xFFFFFFFF),
          fontFamily: 'Arial',
        ),
      ),
    );
    guestButton.position = Vector2(640, 580);
    guestButton.anchor = Anchor.center;
    add(guestButton);
  }

  @override
  bool onTapDown(TapDownEvent event) {
    final loginBounds = loginButtonBg.toRect();
    final registerBounds = registerButtonBg.toRect();
    final guestBounds = guestButtonBg.toRect();

    if (loginBounds.contains(event.canvasPosition.toOffset())) {
      handleLogin();
    } else if (registerBounds.contains(event.canvasPosition.toOffset())) {
      handleRegister();
    } else if (guestBounds.contains(event.canvasPosition.toOffset())) {
      handleGuestLogin();
    }
    return true; // Ensure events are properly processed
  }

  void handleLogin() {
    if (usernameInput.value.isNotEmpty && passwordInput.value.isNotEmpty) {
      findParent<RouterComponent>()?.pushNamed(Routes.levelSelection);
    }
  }

  void handleRegister() {
    findParent<RouterComponent>()?.pushNamed(Routes.register);
  }

  void handleGuestLogin() {
    print("Clicked on guest button");
    findParent<RouterComponent>()?.pushNamed(Routes.levelSelection);
  }
}