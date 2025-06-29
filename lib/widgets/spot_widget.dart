// lib/widgets/spot_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/furniture_spot.dart';

typedef VoidCallback = void Function();

class SpotWidget extends StatelessWidget {
  final FurnitureSpot spot;
  final Size canvasSize;
  final bool allowDrag;
  final VoidCallback onUpdate;

  const SpotWidget({
    super.key,
    required this.spot,
    required this.canvasSize,
    required this.allowDrag,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final left = spot.x * canvasSize.width - (spot.w * canvasSize.width) / 2;
    final top = spot.y * canvasSize.height - (spot.h * canvasSize.height) / 2;

    // Common drag handler
    final pan = allowDrag
        ? (DragUpdateDetails d) {
            spot.x = (spot.x + d.delta.dx / canvasSize.width).clamp(0.0, 1.0);
            spot.y = (spot.y + d.delta.dy / canvasSize.height).clamp(0.0, 1.0);
            onUpdate();
          }
        : null;

    // Chair
    if (spot.type == FurnitureType.chair) {
      return Positioned(
        left: left,
        top: top,
        width: spot.w * canvasSize.width,
        height: spot.h * canvasSize.height,
        child: GestureDetector(
          onPanUpdate: pan,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD2A679), Color(0xFF8B5E3C)],
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
                child:
                    Icon(Icons.chair, size: 20, color: Colors.brown.shade900)),
          ),
        ),
      );
    }

    // Table
    final tw = spot.w * canvasSize.width;
    final th = spot.h * canvasSize.height;
    final cx = left + tw / 2;
    final cy = top + th / 2;
    final radius = math.max(tw, th) / 2 + 20;
    const cs = 28.0;

    // Table body (circle vs rect)
    Widget tableBody;
    final commonDeco = BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFB8860B), Color(0xFF8F5E1E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: const [
        BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(3, 3))
      ],
    );

    if (spot.shape == TableShape.circle) {
      tableBody = DecoratedBox(
        decoration: commonDeco.copyWith(shape: BoxShape.circle),
        child: Center(
            child: Text(
          '${spot.capacity} seats',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
      );
    } else {
      // square & rectangle both use rounded rect
      tableBody = DecoratedBox(
        decoration:
            commonDeco.copyWith(borderRadius: BorderRadius.circular(12)),
        child: Center(
            child: Text(
          '${spot.capacity} seats',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
      );
    }

    return Stack(children: [
      Positioned(
        left: left,
        top: top,
        width: tw,
        height: th,
        child: GestureDetector(onPanUpdate: pan, child: tableBody),
      ),
      // chairs around
      for (int i = 0; i < spot.capacity; i++)
        Positioned(
          left:
              cx + radius * math.cos(2 * math.pi * i / spot.capacity) - cs / 2,
          top: cy + radius * math.sin(2 * math.pi * i / spot.capacity) - cs / 2,
          width: cs,
          height: cs,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCD853F), Color(0xFF8B4513)],
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
                child:
                    Icon(Icons.chair, size: 20, color: Colors.brown.shade900)),
          ),
        ),
    ]);
  }
}
