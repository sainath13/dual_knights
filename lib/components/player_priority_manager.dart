import 'dart:math';
import 'package:dual_knights/components/tree.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class PlayerPriorityManager {
  final Set<Tree> interactingTrees = {};
  bool isAheadOfAnyTree = false;
  bool isBehindAnyTree = false;
  Component? _owner;  // Make nullable

  PlayerPriorityManager(this._owner);

  // Add setter for owner
  set owner(Component component) {
    _owner = component;
  }

  void updateTreeInteraction(Tree tree) {
    if (_owner == null) return;  // Safety check

    interactingTrees.add(tree);

    // Reset flags
    isAheadOfAnyTree = false;
    isBehindAnyTree = false;

    // Check all current tree interactions
    for (var t in interactingTrees.toList()) {
      if (t.isPlayerAhead) isAheadOfAnyTree = true;
      if (t.isPlayerBehind) isBehindAnyTree = true;
    }

    // Clean up trees that are no longer interacting
    interactingTrees.removeWhere((t) =>
    !t.isPlayerAhead && !t.isPlayerBehind);

    // Update priority based on current state
    int newPriority;
    if (isAheadOfAnyTree) {
      newPriority = 15;
    } else if (isBehindAnyTree) {
      newPriority = 5;
    } else {
      newPriority = 10;
    }

    // Only update if priority has changed
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