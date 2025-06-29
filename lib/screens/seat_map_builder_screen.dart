// lib/screens/seat_map_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/furniture_spot.dart';
import '../widgets/spot_widget.dart';
import '../widgets/tool_bar.dart';

class SeatMapBuilderScreen extends StatefulWidget {
  const SeatMapBuilderScreen({super.key});
  @override
  State<SeatMapBuilderScreen> createState() => _SeatMapBuilderScreenState();
}

class _SeatMapBuilderScreenState extends State<SeatMapBuilderScreen> {
  final _spots = <FurnitureSpot>[];
  final uuid = const Uuid();

  // interaction state
  bool _moveMode = false;
  FurnitureType _selectedType = FurnitureType.table;
  int _defaultCapacity = 4;
  TableShape _selectedShape = TableShape.rectangle;

  // relative sizes for rectangle tables
  final _tableSizes = {
    2: const Size(0.2, 0.1),
    4: const Size(0.3, 0.15),
    6: const Size(0.4, 0.2),
    8: const Size(0.45, 0.25),
  };

  void _addSpot(Offset pos, Size canvas) {
    if (_moveMode) return;
    final x = (pos.dx / canvas.width).clamp(0.0, 1.0);
    final y = (pos.dy / canvas.height).clamp(0.0, 1.0);

    if (_selectedType == FurnitureType.table) {
      final base = _tableSizes[_defaultCapacity]!;
      double w, h;
      switch (_selectedShape) {
        case TableShape.square:
          w = h = base.width;
          break;
        case TableShape.circle:
          w = h = (base.width + base.height) / 2;
          break;
        case TableShape.rectangle:
        default:
          w = base.width;
          h = base.height;
      }
      _spots.add(FurnitureSpot(
        id: uuid.v4().substring(0, 4),
        x: x,
        y: y,
        w: w,
        h: h,
        type: FurnitureType.table,
        capacity: _defaultCapacity,
        shape: _selectedShape,
      ));
    } else {
      _spots.add(FurnitureSpot(
        id: uuid.v4().substring(0, 4),
        x: x,
        y: y,
        w: 0.05,
        h: 0.05,
        type: FurnitureType.chair,
      ));
    }
    setState(() {});
  }

  void _toggleMove() {
    setState(() => _moveMode = !_moveMode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_moveMode ? 'Move Mode' : 'Add Mode'),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _selectType(FurnitureType t) {
    setState(() {
      _selectedType = t;
      _moveMode = false;
    });
  }

  void _selectCapacity(int c) => setState(() => _defaultCapacity = c);
  void _selectShape(TableShape s) => setState(() => _selectedShape = s);

  void _saveLayout() {
    debugPrint(_spots
        .map((s) => {
              'id': s.id,
              'type': s.type.name,
              'shape': s.shape.name,
              'capacity': s.capacity,
              'x': s.x,
              'y': s.y,
              'w': s.w,
              'h': s.h,
            })
        .toString());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Layout saved (console)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _moveMode
              ? 'Move Mode'
              : 'Add: ${_selectedType == FurnitureType.table ? '${_defaultCapacity}-seat ${_selectedShape.name.capitalize()} Table' : 'Chair'}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Layout',
            onPressed: _saveLayout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, box) {
                final canvas = Size(box.maxWidth, box.maxHeight);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _addSpot(d.localPosition, canvas),
                  child: Stack(
                    children: _spots
                        .map(
                          (spot) => SpotWidget(
                            spot: spot,
                            canvasSize: canvas,
                            allowDrag: _moveMode,
                            onUpdate: () => setState(() {}),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
          ToolBar(
            moveMode: _moveMode,
            selectedType: _selectedType,
            selectedCapacity: _defaultCapacity,
            selectedShape: _selectedShape,
            onMoveToggle: _toggleMove,
            onTypeSelected: _selectType,
            onCapacitySelected: _selectCapacity,
            onShapeSelected: _selectShape,
            onClear: () => setState(() => _spots.clear()),
          ),
        ],
      ),
    );
  }
}

extension _Capitalize on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
