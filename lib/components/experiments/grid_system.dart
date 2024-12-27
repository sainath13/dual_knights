import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'dart:collection';
import 'dart:developer' as developer;

// Represents a position in the grid
class GridPosition {
  final int x;
  final int y;

  const GridPosition(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'GridPosition($x, $y)';
}

// Types of entities that can be in a grid
enum GridEntityType {
  player,
  antiPlayer,
  archer,
  barrel,
  empty,
}

mixin GridObserver {
  void onEntityEntered(GridPosition position, GridEntityType entityType);
  void onEntityLeft(GridPosition position, GridEntityType entityType);
}

class GridManager extends SpriteAnimationComponent {
  final int rows;
  final int columns;
  final double tileSize;

  // Store what's in each grid position
  final Map<GridPosition, GridEntityType> _grid = {};

  // Store observers interested in specific grid positions
  final Map<GridPosition, Set<GridObserver>> _observers = {};

  GridManager({
    required this.rows,
    required this.columns,
    required this.tileSize,
  });

  // Convert world position to grid position
  GridPosition worldToGrid(Vector2 position) {
    developer.log("GridSystem : position is $position");
    developer.log("x = ${(position.x / tileSize).ceil() -4}");
    developer.log("y = ${(position.y / tileSize).ceil()- 4} ");
    return GridPosition(
      (position.x / tileSize).ceil() - 4,
      (position.y / tileSize).ceil() - 4,
    );
  }

  // Convert grid position to world position (center of tile)
  Vector2 gridToWorld(GridPosition gridPos) {
    return Vector2(
      (gridPos.x * tileSize) + (tileSize / 2),
      (gridPos.y * tileSize) + (tileSize / 2),
    );
  }

  // Register an observer for specific grid positions
  void addObserver(GridObserver observer, List<GridPosition> positions) {
    for (final pos in positions) {
      _observers.putIfAbsent(pos, () => HashSet<GridObserver>()).add(observer);
    }
  }

  // Remove an observer
  void removeObserver(GridObserver observer) {
    _observers.values.forEach((observers) => observers.remove(observer));
  }

  // Update entity position in grid
  void updateEntityPosition(Vector2 worldPosition, GridEntityType entityType) {
    final newGridPos = worldToGrid(worldPosition);
    developer.log("putting someone at $newGridPos");
    // Find old position if it exists
    GridPosition? oldGridPos;
    _grid.forEach((pos, type) {
      if (type == entityType) {
        oldGridPos = pos;
      }
    });

    // If position changed
    if (oldGridPos != newGridPos) {
      // Remove from old position
      if (oldGridPos != null) {
        _grid.remove(oldGridPos);
        _notifyObservers(oldGridPos!, entityType, false);
      }

      // Add to new position
      _grid[newGridPos] = entityType;
      _notifyObservers(newGridPos, entityType, true);
    }
  }

  // Notify observers of changes
  void _notifyObservers(GridPosition position, GridEntityType entityType, bool entered) {
    // developer.log("Notifying observers");
    final observers = _observers[position];
    developer.log("GridSystem : here observers are $observers");
    if (observers != null) {
      for (final observer in observers) {
        if (entered) {
          observer.onEntityEntered(position, entityType);
        } else {
          observer.onEntityLeft(position, entityType);
        }
      }
    }
  }

  // Check if a grid position is occupied
  bool isOccupied(GridPosition position) {
    return _grid.containsKey(position);
  }

  // Get entity at a grid position
  GridEntityType? getEntityAt(GridPosition position) {
    return _grid[position];
  }
}
