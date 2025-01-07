import 'dart:math';
import 'package:dual_knights/components/tree.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class PlayerPriorityManager {
  final Set<Tree> interactingTrees = {};
  Component? _owner;

  PlayerPriorityManager(this._owner);

  set owner(Component component) {
    _owner = component;
  }

  void updateTreeInteraction(Tree tree) {
    if (_owner == null) return;

    interactingTrees.add(tree);
    interactingTrees.removeWhere((t) =>
    !t.isPlayerAhead && !t.isPlayerBehind);

    Map<Tree, Vector2> relativePositions = {};

    // Ensure that _owner is a PositionComponent
    if (_owner is PositionComponent) {
      PositionComponent ownerPosition = _owner as PositionComponent;
      for (var t in interactingTrees) {
        Vector2 treePos = t.position + Vector2(0, 48);
        Vector2 relativePos = treePos - ownerPosition.position;
        relativePositions[t] = relativePos;
      }
    }

    int newPriority = _calculatePriority(relativePositions);

    if (_owner!.priority != newPriority) {
      if (_owner!.parent != null) {
        final parent = _owner!.parent!;
        parent.remove(_owner!);
        _owner!.priority = newPriority;
        parent.add(_owner!);
      }
    }
  }

  int _calculatePriority(Map<Tree, Vector2> relativePositions) {
    if (relativePositions.isEmpty) return 10;

    bool hasTreeBehind = false;
    bool hasTreeAhead = false;
    double closestTreeDistance = double.infinity;
    Tree? closestTree;

    for (var entry in relativePositions.entries) {
      Tree tree = entry.key;
      Vector2 relativePos = entry.value;
      double distance = relativePos.length;

      if (distance < closestTreeDistance) {
        closestTreeDistance = distance;
        closestTree = tree;
      }

      if (tree.isPlayerBehind) hasTreeBehind = true;
      if (tree.isPlayerAhead) hasTreeAhead = true;
    }

    if (closestTree != null) {
      if (hasTreeBehind && hasTreeAhead) {
        if (closestTree.isPlayerBehind) {
          return 5;
        } else if (closestTree.isPlayerAhead) {
          return 15;
        }
      }
      else if (hasTreeBehind) {
        return 5;
      }
      else if (hasTreeAhead) {
        return 15;
      }
    }

    return 10;
  }
}
