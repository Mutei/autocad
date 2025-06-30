// lib/widgets/spot_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/furniture_spot.dart';

typedef VoidCallback = void Function();

class SpotWidget extends StatelessWidget {
  final FurnitureSpot spot;
  final Size canvasSize;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const SpotWidget({
    super.key,
    required this.spot,
    required this.canvasSize,
    required this.onUpdate,
    required this.onDelete,
  });

  Future<void> _pickColor(BuildContext context) async {
    final color = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Colors.primaries.map((c) {
              return GestureDetector(
                onTap: () => Navigator.of(ctx).pop(c),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: c,
                    border: Border.all(color: Colors.black26),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
    if (color != null) {
      spot.color = color;
      onUpdate();
    }
  }

  void _showOptions(BuildContext context, TapDownDetails details) async {
    final choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: [
        const PopupMenuItem(value: 'color', child: Text('Change Color')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
    if (choice == 'color') {
      await _pickColor(context);
    } else if (choice == 'delete') {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tw = spot.w * canvasSize.width;
    final th = spot.h * canvasSize.height;
    final left = spot.x * canvasSize.width - tw / 2;
    final top = spot.y * canvasSize.height - th / 2;

    // center of table
    final cx = left + tw / 2;
    final cy = top + th / 2;
    // chair size and spacing
    const double cs = 28.0;
    final double radius = math.max(tw, th) / 2 + cs / 2 + 8;

    final pan = (DragUpdateDetails d) {
      spot.x = (spot.x + d.delta.dx / canvasSize.width).clamp(0.0, 1.0);
      spot.y = (spot.y + d.delta.dy / canvasSize.height).clamp(0.0, 1.0);
      onUpdate();
    };

    Widget tableOrChair;
    if (spot.type == FurnitureType.chair) {
      tableOrChair = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [spot.color.withOpacity(0.7), spot.color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
          ],
        ),
        child: Center(
          child: Icon(
            Icons.chair,
            size: 20,
            color: spot.color.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
          ),
        ),
      );
    } else {
      final commonDeco = BoxDecoration(
        gradient: LinearGradient(
          colors: [spot.color.withOpacity(0.7), spot.color],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(3, 3))
        ],
      );
      tableOrChair = spot.shape == TableShape.circle
          ? DecoratedBox(
              decoration: commonDeco.copyWith(shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '${spot.capacity} seats',
                  style: TextStyle(
                    color: spot.color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : DecoratedBox(
              decoration:
                  commonDeco.copyWith(borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  '${spot.capacity} seats',
                  style: TextStyle(
                    color: spot.color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
    }

    return Stack(children: [
      // the spot itself (table or chair)
      Positioned(
        left: left,
        top: top,
        width: tw,
        height: th,
        child: GestureDetector(
          onPanUpdate: pan,
          onTapDown: (d) => _showOptions(context, d),
          child: tableOrChair,
        ),
      ),

      // if it's a table, draw chairs around it
      if (spot.type == FurnitureType.table)
        for (int i = 0; i < spot.capacity; i++)
          Positioned(
            left: cx +
                radius * math.cos(2 * math.pi * i / spot.capacity) -
                cs / 2,
            top: cy +
                radius * math.sin(2 * math.pi * i / spot.capacity) -
                cs / 2,
            width: cs,
            height: cs,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [spot.color.withOpacity(0.7), spot.color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2))
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.chair,
                  size: 20,
                  color: spot.color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          ),
    ]);
  }
}
