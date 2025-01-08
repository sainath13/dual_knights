import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  const PauseMenu({
    super.key,
    this.onResumePressed,
    this.onRestartPressed,
    this.onExitPressed,
    this.onLevelSelection,
    required this.musicValueListenable,
    required this.sfxValueListenable,
    this.onMusicValueChanged,
    this.onSfxValueChanged,
    required this.controlTypeListenable,
    this.onControlTypeChanged,
  });

  static const id = 'PauseMenu';

  final VoidCallback? onResumePressed;
  final VoidCallback? onRestartPressed;
  final VoidCallback? onExitPressed;
  final VoidCallback? onLevelSelection;

  final ValueListenable<bool> musicValueListenable;
  final ValueListenable<bool> sfxValueListenable;

  final ValueChanged<bool>? onMusicValueChanged;
  final ValueChanged<bool>? onSfxValueChanged;

  final ValueListenable<bool> controlTypeListenable;
  final ValueChanged<bool>? onControlTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(132, 38, 36, 36), // Dark medieval background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Paused',
              style: TextStyle(
                fontSize: 40,
                fontFamily: "DualKnights",
                color: Color.fromARGB(255, 213, 176, 93), // Gold-like medieval color
                shadows: [
                  Shadow(
                    offset: Offset(3, 3),
                    blurRadius: 6,
                    color: Colors.black, // Shadow for medieval effect
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            medievalButton('Resume', onResumePressed),
            const SizedBox(height: 10),
            medievalButton('Restart', onRestartPressed),
            const SizedBox(height: 10),
            medievalButton('Level Selection', onLevelSelection),
            const SizedBox(height: 10),
            medievalToggleButton('Music', musicValueListenable, onMusicValueChanged),
            const SizedBox(height: 10),
            medievalToggleButton('Sfx', sfxValueListenable, onSfxValueChanged),
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: controlTypeListenable,
              builder: (BuildContext context, bool isAnalogue, Widget? child) {
                return medievalButton(
                  isAnalogue ? 'Analogue Joystick' : 'Arrow Keys',
                  () => onControlTypeChanged?.call(!isAnalogue),
                );
              },
            ),
            const SizedBox(height: 10),
            medievalButton('Exit', onExitPressed),
          ],
        ),
      ),
    );
  }

  /// Helper method for medieval-themed buttons
  Widget medievalButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: 200,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 84, 63, 63), // Wooden-like button
          side: const BorderSide(color: Color.fromARGB(255, 213, 176, 93), width: 2), // Gold border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Slightly rounded corners
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: "DualKnights",
            color: Color.fromARGB(255, 213, 176, 93), // Gold text
            fontSize: 18,
            shadows: [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                color: Colors.black, // Text shadow
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method for medieval toggle buttons (like music and sfx)
  Widget medievalToggleButton(
    String title,
    ValueListenable<bool> valueListenable,
    ValueChanged<bool>? onChanged,
  ) {
    return SizedBox(
      width: 200,
      child: ValueListenableBuilder<bool>(
        valueListenable: valueListenable,
        builder: (BuildContext context, bool value, Widget? child) {
          return SwitchListTile(
            value: value,
            onChanged: onChanged,
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: "DualKnights",
                color: Color.fromARGB(255, 213, 176, 93), // Gold text
                fontSize: 18,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Colors.black, // Text shadow
                  ),
                ],
              ),
            ),
            activeColor: const Color.fromARGB(255, 213, 176, 93), // Gold for active toggle
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[800],
          );
        },
      ),
    );
  }
}
