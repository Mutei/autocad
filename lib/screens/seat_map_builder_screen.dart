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

  FurnitureType _selectedType = FurnitureType.table;
  int _defaultCapacity = 4;
  TableShape _selectedShape = TableShape.rectangle;
  Color _selectedColor = Colors.brown;

  final _tableSizes = {
    2: const Size(0.2, 0.1),
    4: const Size(0.3, 0.15),
    6: const Size(0.4, 0.2),
    8: const Size(0.45, 0.25),
  };

  void _addSpot(Offset pos, Size canvas) {
    final x = (pos.dx / canvas.width).clamp(0.0, 1.0);
    final y = (pos.dy / canvas.height).clamp(0.0, 1.0);

    double w, h;
    if (_selectedType == FurnitureType.table) {
      final base = _tableSizes[_defaultCapacity]!;
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
    } else {
      w = h = 0.05;
    }

    _spots.add(FurnitureSpot(
      id: uuid.v4().substring(0, 4),
      x: x,
      y: y,
      w: w,
      h: h,
      type: _selectedType,
      capacity: _selectedType == FurnitureType.table ? _defaultCapacity : 1,
      shape: _selectedType == FurnitureType.table
          ? _selectedShape
          : TableShape.rectangle,
      color: _selectedColor,
    ));

    setState(() {});
  }

  Future<void> _pickDefaultColor() async {
    final color = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick default color'),
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
    if (color != null) setState(() => _selectedColor = color);
  }

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
              'color': s.color.value,
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
          'Add: ${_selectedType == FurnitureType.table ? '${_defaultCapacity}-seat ${_selectedShape.name.capitalize()} Table' : 'Chair'}',
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
                  onTapDown: (d) {
                    final tapPos = d.localPosition;

                    // don’t add if tapping an existing spot
                    bool hitExisting = _spots.any((spot) {
                      final center = Offset(
                        spot.x * canvas.width,
                        spot.y * canvas.height,
                      );
                      final halfW = spot.w * canvas.width / 2;
                      final halfH = spot.h * canvas.height / 2;
                      final rect = Rect.fromCenter(
                          center: center, width: halfW * 2, height: halfH * 2);
                      return rect.contains(tapPos);
                    });

                    if (!hitExisting) {
                      _addSpot(tapPos, canvas);
                    }
                  },
                  child: Stack(
                    children: _spots.map((spot) {
                      return SpotWidget(
                        spot: spot,
                        canvasSize: canvas,
                        onUpdate: () => setState(() {}),
                        onDelete: () {
                          setState(() => _spots.remove(spot));
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          ToolBar(
            selectedType: _selectedType,
            selectedCapacity: _defaultCapacity,
            selectedShape: _selectedShape,
            selectedColor: _selectedColor,
            onTypeSelected: (t) => setState(() => _selectedType = t),
            onCapacitySelected: (c) => setState(() => _defaultCapacity = c),
            onShapeSelected: (s) => setState(() => _selectedShape = s),
            onDefaultColorPick: _pickDefaultColor,
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
