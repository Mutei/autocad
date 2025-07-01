// lib/widgets/spot_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/furniture_spot.dart';

typedef VoidCallback = void Function();

class SpotWidget extends StatelessWidget {
  final FurnitureSpot spot;
  final Size canvasSize;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const SpotWidget({
    Key? key,
    required this.spot,
    required this.canvasSize,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

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
    final double tw = spot.w * canvasSize.width;
    final double th = spot.h * canvasSize.height;
    final double left = spot.x * canvasSize.width - tw / 2;
    final double top = spot.y * canvasSize.height - th / 2;

    final pan = (DragUpdateDetails d) {
      spot.x = (spot.x + d.delta.dx / canvasSize.width).clamp(0.0, 1.0);
      spot.y = (spot.y + d.delta.dy / canvasSize.height).clamp(0.0, 1.0);
      onUpdate();
    };

    // Decoration (door, window, view)
    if (spot.type == FurnitureType.decoration) {
      IconData iconData;
      switch (spot.decorationType!) {
        case DecorationType.window:
          iconData = MdiIcons.windowOpenVariant;
          break;
        case DecorationType.view:
          iconData = MdiIcons.panorama;
          break;
        case DecorationType.door:
        default:
          iconData = MdiIcons.doorOpen;
      }
      return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onPanUpdate: pan,
          onTapDown: (d) => _showOptions(context, d),
          child: Material(
            elevation: 4,
            shape: const CircleBorder(),
            color: Colors.white,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                iconData,
                size: 32,
                color: spot.color,
              ),
            ),
          ),
        ),
      );
    }

    // Toilet
    if (spot.type == FurnitureType.toilet) {
      return Positioned(
        left: left,
        top: top,
        width: tw,
        height: th,
        child: GestureDetector(
          onPanUpdate: pan,
          onTapDown: (d) => _showOptions(context, d),
          child: Material(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            shadowColor: Colors.black26,
            child: Center(
              child: Icon(
                MdiIcons.toilet,
                size: 28,
                color: spot.color,
              ),
            ),
          ),
        ),
      );
    }

    // Standalone seat (chair or sofa)
    if (spot.type == FurnitureType.seat) {
      return Positioned(
        left: left,
        top: top,
        width: tw,
        height: th,
        child: GestureDetector(
          onPanUpdate: pan,
          onTapDown: (d) => _showOptions(context, d),
          child: Material(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            color: spot.color,
            shadowColor: Colors.black26,
            child: Center(
              child: Icon(
                spot.seatType == SeatType.chair
                    ? Icons.event_seat
                    : MdiIcons.sofa,
                size: 24,
                color: spot.color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    // Table + seats around
    final commonDeco = Material(
      elevation: 4,
      shape: spot.shape == TableShape.circle
          ? const CircleBorder()
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: spot.color,
      shadowColor: Colors.black26,
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

    final tablePos = Positioned(
      left: left,
      top: top,
      width: tw,
      height: th,
      child: GestureDetector(
        onPanUpdate: pan,
        onTapDown: (d) => _showOptions(context, d),
        child: commonDeco,
      ),
    );

    const double cs = 36.0;
    final double cx = left + tw / 2;
    final double cy = top + th / 2;
    final double radius = math.max(tw, th) / 2 + cs / 2 + 8;

    final seats = [
      for (int i = 0; i < spot.capacity; i++)
        Positioned(
          left:
              cx + radius * math.cos(2 * math.pi * i / spot.capacity) - cs / 2,
          top: cy + radius * math.sin(2 * math.pi * i / spot.capacity) - cs / 2,
          width: cs,
          height: cs,
          child: GestureDetector(
            onPanUpdate: pan,
            onTapDown: (d) => _showOptions(context, d),
            child: Material(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              color: spot.color,
              shadowColor: Colors.black26,
              child: Center(
                child: Icon(
                  spot.seatType == SeatType.chair
                      ? MdiIcons.chairSchool
                      : MdiIcons.sofa,
                  size: 24,
                  color: spot.color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
    ];

    return Stack(
      children: [tablePos, ...seats],
    );
  }
}
