import 'dart:math';
import 'package:dual_knights/components/tree.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class AntiPlayerPriorityManager {
  final Set<Tree> interactingTrees = {};
  bool isAheadOfAnyTree = false;
  bool isBehindAnyTree = false;
  Component? _owner;

  AntiPlayerPriorityManager(this._owner);

  set owner(Component component) {
    _owner = component;
  }

  void updateTreeInteraction(Tree tree) {
    if (_owner == null) return;

    interactingTrees.add(tree);

    isAheadOfAnyTree = false;
    isBehindAnyTree = false;

    for (var t in interactingTrees.toList()) {
      if (t.isAntiPlayerAhead) isAheadOfAnyTree = true;
      if (t.isAntiPlayerBehind) isBehindAnyTree = true;
    }

    interactingTrees.removeWhere((t) =>
    !t.isAntiPlayerAhead && !t.isAntiPlayerBehind);

    int newPriority;
    if (isAheadOfAnyTree) {
      newPriority = 15;
    } else if (isBehindAnyTree) {
      newPriority = 5;
    } else {
      newPriority = 10;
    }

    if (_owner!.priority != newPriority) {
      if (_owner!.parent != null) {
        final parent = _owner!.parent!;
        parent.remove(_owner!);
        _owner!.priority = newPriority;
        parent.add(_owner!);
      }
    }
  }
}