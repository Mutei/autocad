// lib/widgets/tool_bar.dart

import 'package:flutter/material.dart';
import '../models/furniture_spot.dart';

class ToolBar extends StatelessWidget {
  final FurnitureType selectedType;
  final SeatType selectedSeatType;
  final DecorationType selectedDecorationType;
  final int selectedCapacity;
  final TableShape selectedShape;
  final Color selectedColor;

  final ValueChanged<FurnitureType> onTypeSelected;
  final ValueChanged<SeatType> onSeatTypeSelected;
  final ValueChanged<DecorationType> onDecorationTypeSelected;
  final ValueChanged<int> onCapacitySelected;
  final ValueChanged<TableShape> onShapeSelected;
  final VoidCallback onDefaultColorPick;
  final VoidCallback onClear;

  const ToolBar({
    super.key,
    required this.selectedType,
    required this.selectedSeatType,
    required this.selectedDecorationType,
    required this.selectedCapacity,
    required this.selectedShape,
    required this.selectedColor,
    required this.onTypeSelected,
    required this.onSeatTypeSelected,
    required this.onDecorationTypeSelected,
    required this.onCapacitySelected,
    required this.onShapeSelected,
    required this.onDefaultColorPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          // Table + Chair
          _toolButton(
            icon: Icons.table_restaurant,
            label: 'Table + Chair',
            isSelected: selectedType == FurnitureType.table &&
                selectedSeatType == SeatType.chair,
            onTap: () {
              onTypeSelected(FurnitureType.table);
              onSeatTypeSelected(SeatType.chair);
            },
          ),
          const SizedBox(width: 12),

          // Table + Sofa
          _toolButton(
            icon: Icons.weekend,
            label: 'Table + Sofa',
            isSelected: selectedType == FurnitureType.table &&
                selectedSeatType == SeatType.sofa,
            onTap: () {
              onTypeSelected(FurnitureType.table);
              onSeatTypeSelected(SeatType.sofa);
            },
          ),
          const SizedBox(width: 12),

          // Standalone Chair
          _toolButton(
            icon: Icons.event_seat,
            label: 'Chair',
            isSelected: selectedType == FurnitureType.seat &&
                selectedSeatType == SeatType.chair,
            onTap: () {
              onTypeSelected(FurnitureType.seat);
              onSeatTypeSelected(SeatType.chair);
            },
          ),
          const SizedBox(width: 12),

          // Standalone Sofa
          _toolButton(
            icon: Icons.weekend,
            label: 'Sofa',
            isSelected: selectedType == FurnitureType.seat &&
                selectedSeatType == SeatType.sofa,
            onTap: () {
              onTypeSelected(FurnitureType.seat);
              onSeatTypeSelected(SeatType.sofa);
            },
          ),
          const SizedBox(width: 12),

          // Toilet
          _toolButton(
            icon: Icons.wc_outlined,
            label: 'Toilet',
            isSelected: selectedType == FurnitureType.toilet,
            onTap: () => onTypeSelected(FurnitureType.toilet),
          ),
          const SizedBox(width: 12),

          // Decorations: Door, Window, View
          _toolButton(
            icon: Icons.door_back_door,
            label: 'Door',
            isSelected: selectedType == FurnitureType.decoration &&
                selectedDecorationType == DecorationType.door,
            onTap: () {
              onTypeSelected(FurnitureType.decoration);
              onDecorationTypeSelected(DecorationType.door);
            },
          ),
          const SizedBox(width: 12),
          _toolButton(
            icon: Icons.window,
            label: 'Window',
            isSelected: selectedType == FurnitureType.decoration &&
                selectedDecorationType == DecorationType.window,
            onTap: () {
              onTypeSelected(FurnitureType.decoration);
              onDecorationTypeSelected(DecorationType.window);
            },
          ),
          const SizedBox(width: 12),
          _toolButton(
            icon: Icons.landscape,
            label: 'View',
            isSelected: selectedType == FurnitureType.decoration &&
                selectedDecorationType == DecorationType.view,
            onTap: () {
              onTypeSelected(FurnitureType.decoration);
              onDecorationTypeSelected(DecorationType.view);
            },
          ),

          // Only for tables
          if (selectedType == FurnitureType.table) ...[
            const SizedBox(width: 12),
            PopupMenuButton<int>(
              icon: const Icon(Icons.format_list_numbered),
              tooltip: 'Seats',
              onSelected: onCapacitySelected,
              itemBuilder: (_) => [2, 4, 6, 8]
                  .map((c) => PopupMenuItem(value: c, child: Text('$c')))
                  .toList(),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<TableShape>(
              icon: const Icon(Icons.crop_square),
              tooltip: 'Shape',
              onSelected: onShapeSelected,
              itemBuilder: (_) => TableShape.values.map((shape) {
                IconData icon;
                switch (shape) {
                  case TableShape.circle:
                    icon = Icons.circle;
                    break;
                  case TableShape.square:
                    icon = Icons.crop_square;
                    break;
                  case TableShape.rectangle:
                  default:
                    icon = Icons.rectangle;
                }
                return PopupMenuItem(
                  value: shape,
                  child: Row(
                    children: [
                      Icon(icon),
                      const SizedBox(width: 8),
                      Text(shape.name.capitalize()),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.color_lens, color: selectedColor),
            tooltip: 'Default Color',
            onPressed: onDefaultColorPick,
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All',
            onPressed: onClear,
          ),
        ]),
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color:
                  isSelected ? Colors.deepPurple.shade100 : Colors.transparent,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.deepPurple : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.deepPurple : Colors.black54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

extension _Cap on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
