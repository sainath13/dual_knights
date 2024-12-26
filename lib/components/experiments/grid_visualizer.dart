import 'package:dual_knights/components/experiments/grid_system.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GridVisualizer extends Component with HasGameRef {
  final GridManager gridManager;
  final Paint _gridLinePaint;
  final Paint _occupiedCellPaint;
  final Paint _interestedCellPaint;
  final TextPaint _textPaint;
  final Map<GridPosition, Color> _highlightedCells = {};
  bool showCoordinates = false;

  GridVisualizer({
    required this.gridManager,
    Color gridLineColor = const Color(0x44FFFFFF),
    Color occupiedCellColor = const Color(0x44FF0000),
    Color interestedCellColor = const Color(0x4400FF00),
  }) : _gridLinePaint = Paint()
         ..color = gridLineColor
         ..style = PaintingStyle.stroke
         ..strokeWidth = 1.0,
       _occupiedCellPaint = Paint()
         ..color = occupiedCellColor
         ..style = PaintingStyle.fill,
       _interestedCellPaint = Paint()
         ..color = interestedCellColor
         ..style = PaintingStyle.fill,
       _textPaint = TextPaint(
         style: const TextStyle(
           color: Color(0xFFFFFFFF),
           fontSize: 10,
         ),
       );

  // Add highlight for interested cells
  void highlightInterestedCells(List<GridPosition> positions, [Color? color]) {
    for (final pos in positions) {
      _highlightedCells[pos] = color ?? _interestedCellPaint.color;
    }
  }

  // Clear specific highlights
  void clearHighlights(List<GridPosition> positions) {
    for (final pos in positions) {
      _highlightedCells.remove(pos);
    }
  }

  // Clear all highlights
  void clearAllHighlights() {
    _highlightedCells.clear();
  }

  @override
  void render(Canvas canvas) {
    // Draw filled cells first
    _drawFilledCells(canvas);
    
    // Draw grid lines
    _drawGridLines(canvas);
    
    // Draw coordinates if enabled
    if (showCoordinates) {
      _drawCoordinates(canvas);
    }
  }

  void _drawFilledCells(Canvas canvas) {
    // Draw highlighted cells
    for (final entry in _highlightedCells.entries) {
      final rect = Rect.fromLTWH(
        entry.key.x * gridManager.tileSize,
        entry.key.y * gridManager.tileSize,
        gridManager.tileSize,
        gridManager.tileSize,
      );
      canvas.drawRect(rect, Paint()..color = entry.value);
    }

    // Draw occupied cells
    for (int x = 0; x < gridManager.columns; x++) {
      for (int y = 0; y < gridManager.rows; y++) {
        final pos = GridPosition(x, y);
        if (gridManager.isOccupied(pos)) {
          final rect = Rect.fromLTWH(
            x * gridManager.tileSize,
            y * gridManager.tileSize,
            gridManager.tileSize,
            gridManager.tileSize,
          );
          canvas.drawRect(rect, _occupiedCellPaint);
        }
      }
    }
  }

  void _drawGridLines(Canvas canvas) {
    // Draw vertical lines
    for (int x = 0; x <= gridManager.columns; x++) {
      final xPos = x * gridManager.tileSize;
      canvas.drawLine(
        Vector2(xPos, 0).toOffset(),
        Vector2(xPos, gridManager.rows * gridManager.tileSize).toOffset(),
        _gridLinePaint,
      );
    }

    // Draw horizontal lines
    for (int y = 0; y <= gridManager.rows; y++) {
      final yPos = y * gridManager.tileSize;
      canvas.drawLine(
        Vector2(0, yPos).toOffset(),
        Vector2(gridManager.columns * gridManager.tileSize, yPos).toOffset(),
        _gridLinePaint,
      );
    }
  }

  void _drawCoordinates(Canvas canvas) {
    for (int x = 0; x < gridManager.columns; x++) {
      for (int y = 0; y < gridManager.rows; y++) {
        final text = '($x,$y)';
        _textPaint.render(
          canvas,
          text,
          Vector2(
            x * gridManager.tileSize + 5,
            y * gridManager.tileSize + 5,
          ),
        );
      }
    }
  }
}