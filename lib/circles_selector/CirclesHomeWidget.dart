import 'dart:math';

import 'package:flutter/material.dart';

//Code snips
//              print("""distance == sqrt(2) \n
// | Displacement: $displacement \n
// | currentDistance($currentDistance) = distance($distance) * defaultSpacing($defaultSpacing) \n
// | desiredDistance($desiredDistance) = defaultSpacing($defaultSpacing) * expansionAmount($expansionAmount)
// """);

class CirclesHomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CircleHomeState();
}

class _CircleHomeState extends State<CirclesHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PannableCircleGrid(),
    );
  }
}

class PannableCircleGrid extends StatefulWidget {
  const PannableCircleGrid({Key? key}) : super(key: key);

  @override
  _PannableCircleGridState createState() => _PannableCircleGridState();
}

class _PannableCircleGridState extends State<PannableCircleGrid> {
  Offset _offset = Offset.zero;
  int? _selectedIndex;
  final double _circleSize = 80;
  final double _selectedCircleMultiplier = 2;
  final double _spacing = 10;
  final int _columns = 1000; // Arbitrary large number for columns

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _offset += details.delta;
        });
      },
      child: ClipRect(
        child: CustomPaint(
          painter: CircleGridPainter(
            offset: _offset,
            circleSize: _circleSize,
            selectedCircleMultiplier: _selectedCircleMultiplier,
            spacing: _spacing,
            selectedIndex: _selectedIndex,
            columns: _columns,
          ),
          child: GestureDetector(
            onTapUp: (details) {
              _handleTap(details.localPosition);
            },
          ),
        ),
      ),
    );
  }

  void _handleTap(Offset tapPosition) {
    int col =
        ((tapPosition.dx - _offset.dx) / (_circleSize + _spacing)).floor();
    int row =
        ((tapPosition.dy - _offset.dy) / (_circleSize + _spacing)).floor();
    int index = row * _columns + col;
    setState(() {
      _selectedIndex = (_selectedIndex == index) ? null : index;
    });
  }
}

class CircleGridPainter extends CustomPainter {
  final Offset offset;
  final double circleSize;
  final double selectedCircleMultiplier;
  final double spacing;
  final int? selectedIndex;
  final int columns;
  Map<Point<int>, Offset> displacements = {};

  CircleGridPainter({
    required this.offset,
    required this.circleSize,
    required this.selectedCircleMultiplier,
    required this.spacing,
    required this.columns,
    this.selectedIndex,
  });

  double calculateDisplacement(
      double distance, double expansionAmount, double defaultSpacing) {
    int intDistance = distance.floor();
    double fractionalPart = distance - intDistance;

    if (fractionalPart == 0) {
      // Integer distances (1, 2, 3, ...)
      return expansionAmount;
    } else if (fractionalPart <= 0.5) {
      // Distances like sqrt(2), sqrt(5), sqrt(10), ...
      double currentDistance = distance * defaultSpacing;
      double desiredDistance = intDistance * defaultSpacing + expansionAmount;
      return max(0, desiredDistance - currentDistance);
    } else {
      // Other distances
      return expansionAmount / distance;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final selectedPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final startCol = (-offset.dx / (circleSize + spacing)).floor() - 1;
    final endCol = ((size.width - offset.dx) / (circleSize + spacing)).ceil();
    final startRow = (-offset.dy / (circleSize + spacing)).floor() - 1;
    final endRow = ((size.height - offset.dy) / (circleSize + spacing)).ceil();

    // Calculate displacements for all affected circles
    Map<Point<int>, Offset> displacements = {};
    if (selectedIndex != null) {
      int selectedCol = selectedIndex! % columns;
      int selectedRow = selectedIndex! ~/ columns;
      double expansionAmount = circleSize * (selectedCircleMultiplier - 1) / 2;
      double defaultSpacing = circleSize + spacing;

      for (int row = startRow - 2; row <= endRow + 2; row++) {
        for (int col = startCol - 2; col <= endCol + 2; col++) {
          if (row != selectedRow || col != selectedCol) {
            int dx = col - selectedCol;
            int dy = row - selectedRow;
            double distance = sqrt(dx * dx + dy * dy);
            double angle = atan2(dy.toDouble(), dx.toDouble());

            double displacement = 0;
            if (distance <= 1) {
              // Directly adjacent neighbors
              displacement = expansionAmount;
            } else if (distance <= sqrt(2)) {
              // Diagonal neighbors
              // ### This block seems to be right.
              double currentDistance = distance * defaultSpacing;
              double desiredDistance = defaultSpacing + expansionAmount;
              if (currentDistance < desiredDistance) {
                displacement = desiredDistance - currentDistance;
              }
            } else if (distance == 2) {
              // Directly adjacent neighbors
              displacement = expansionAmount;
            } else if (distance <= sqrt(5)) {
              // Diagonal neighbors
              double currentDistance = distance * defaultSpacing;
              double desiredDistance = defaultSpacing + expansionAmount;
              if (currentDistance < desiredDistance) {
                displacement = desiredDistance - currentDistance;
              }
            } else if (distance == 3) {
              // Directly adjacent neighbors
              displacement = expansionAmount;
            } else if (distance <= sqrt(10)) {
              // Diagonal neighbors
              double currentDistance = distance * defaultSpacing;
              double desiredDistance = defaultSpacing + expansionAmount;
              if (currentDistance < desiredDistance) {
                displacement = desiredDistance - currentDistance;
              }
            } else if (distance == 4) {
              // Directly adjacent neighbors
              displacement = expansionAmount;
            } else if (distance <= sqrt(13)) {
              // Diagonal neighbors
              double currentDistance = distance * defaultSpacing;
              double desiredDistance = defaultSpacing + expansionAmount;
              if (currentDistance < desiredDistance) {
                displacement = desiredDistance - currentDistance;
              }
            }

            if (displacement > 0) {
              displacements[Point(col, row)] = Offset(
                cos(angle) * displacement,
                sin(angle) * displacement,
              );
            }
          }
        }
      }
    }
    // printDisplacements(displacements);

    // Draw circles with calculated displacements
    for (int row = startRow; row <= endRow; row++) {
      for (int col = startCol; col <= endCol; col++) {
        int index = row * columns + col;
        bool isSelected = selectedIndex == index;

        Offset circleOffset = Offset(
          col * (circleSize + spacing) + offset.dx,
          row * (circleSize + spacing) + offset.dy,
        );

        // Apply displacement if exists
        if (!isSelected && displacements.containsKey(Point(col, row))) {
          circleOffset += displacements[Point(col, row)]!;
        }

        double currentCircleSize =
            isSelected ? circleSize * selectedCircleMultiplier : circleSize;

        canvas.drawCircle(
          circleOffset,
          currentCircleSize / 2,
          isSelected ? selectedPaint : paint,
        );
        textPainter.text = TextSpan(
          text: '$index',
          style: TextStyle(
              color: isSelected ? Colors.black : Colors.white, fontSize: 12),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          circleOffset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CircleGridPainter oldDelegate) =>
      offset != oldDelegate.offset ||
      selectedIndex != oldDelegate.selectedIndex;

  void printDisplacements(Map<Point<int>, Offset> displacements) {
    print(
        '============================== Displacements start==============================');
    displacements.forEach((point, offset) {
      print(
          'Point(${point.x}, ${point.y}): Offset(${offset.dx}, ${offset.dy})');
    });
    print(
        '============================== Displacements end ==============================');
  }
}
