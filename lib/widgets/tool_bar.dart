// lib/widgets/tool_bar.dart

import 'package:flutter/material.dart';
import '../models/furniture_spot.dart';

class ToolBar extends StatelessWidget {
  final bool moveMode;
  final FurnitureType selectedType;
  final int selectedCapacity;
  final TableShape selectedShape;
  final VoidCallback onMoveToggle;
  final ValueChanged<FurnitureType> onTypeSelected;
  final ValueChanged<int> onCapacitySelected;
  final ValueChanged<TableShape> onShapeSelected;
  final VoidCallback onClear;

  const ToolBar({
    super.key,
    required this.moveMode,
    required this.selectedType,
    required this.selectedCapacity,
    required this.selectedShape,
    required this.onMoveToggle,
    required this.onTypeSelected,
    required this.onCapacitySelected,
    required this.onShapeSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _toolButton(
            icon: Icons.open_with,
            label: 'Move',
            isSelected: moveMode,
            onTap: onMoveToggle,
          ),
          _toolButton(
            icon: Icons.table_restaurant,
            label: 'Table',
            isSelected: !moveMode && selectedType == FurnitureType.table,
            onTap: () => onTypeSelected(FurnitureType.table),
          ),
          _toolButton(
            icon: Icons.event_seat,
            label: 'Chair',
            isSelected: !moveMode && selectedType == FurnitureType.chair,
            onTap: () => onTypeSelected(FurnitureType.chair),
          ),
          if (!moveMode && selectedType == FurnitureType.table) ...[
            PopupMenuButton<int>(
              icon: const Icon(Icons.format_list_numbered),
              tooltip: 'Seats',
              onSelected: onCapacitySelected,
              itemBuilder: (_) => [2, 4, 6, 8]
                  .map((c) => PopupMenuItem(value: c, child: Text('$c seats')))
                  .toList(),
            ),
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
                        Text(shape.name.capitalize())
                      ],
                    ));
              }).toList(),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All',
            onPressed: onClear,
          ),
        ],
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
            child: Icon(icon,
                size: 28,
                color: isSelected ? Colors.deepPurple : Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.deepPurple : Colors.black54)),
        ],
      ),
    );
  }
}

extension _Cap on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
