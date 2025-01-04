import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  const PauseMenu({
    super.key,
    this.onResumePressed,
    this.onRestartPressed,
    this.onExitPressed,
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

   final ValueListenable<bool> musicValueListenable;
  final ValueListenable<bool> sfxValueListenable;

  final ValueChanged<bool>? onMusicValueChanged;
  final ValueChanged<bool>? onSfxValueChanged;

  final ValueListenable<bool> controlTypeListenable;
  final ValueChanged<bool>? onControlTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(210, 229, 238, 238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Paused',
              style: TextStyle(fontSize: 30,fontFamily: "DualKnights"),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onResumePressed,
                child: const Text('Resume',style: TextStyle(fontFamily: "DualKnights")),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onRestartPressed,
                child: const Text('Restart',style: TextStyle(fontFamily: "DualKnights")),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: ValueListenableBuilder<bool>(
                valueListenable: musicValueListenable,
                builder: (BuildContext context, bool value, Widget? child) {
                  return SwitchListTile(
                    value: value,
                    onChanged: onMusicValueChanged,
                    title: child,
                  );
                },
                child: const Text('Music',style: TextStyle(fontFamily: "DualKnights")),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: ValueListenableBuilder<bool>(
                valueListenable: sfxValueListenable,
                builder: (BuildContext context, bool value, Widget? child) {
                  return SwitchListTile(
                    value: value,
                    onChanged: onSfxValueChanged,
                    title: child,
                  );
                },
                child: const Text('Sfx',style: TextStyle(fontFamily: "DualKnights")),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: ValueListenableBuilder<bool>(
                valueListenable: controlTypeListenable,
                builder: (BuildContext context, bool isAnalogue, Widget? child) {
                  return OutlinedButton(
                    onPressed: () {
                      onControlTypeChanged?.call(!isAnalogue);
                    },
                    child: Text(
                      isAnalogue ? 'Analogue Joystick' : 'Arrow Keys ',
                      style: const TextStyle(fontFamily: "DualKnights"),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onExitPressed,
                child: const Text('Exit',style: TextStyle(fontFamily: "DualKnights")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
