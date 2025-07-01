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
  SeatType _selectedSeatType = SeatType.chair;
  DecorationType _selectedDecorationType = DecorationType.door;
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
    switch (_selectedType) {
      case FurnitureType.table:
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
        break;

      case FurnitureType.seat:
        w = h = 0.1;
        break;

      case FurnitureType.toilet:
        w = h = 0.08;
        break;

      case FurnitureType.decoration:
        switch (_selectedDecorationType) {
          case DecorationType.door:
            w = 0.1;
            h = 0.2;
            break;
          case DecorationType.window:
            w = 0.15;
            h = 0.1;
            break;
          case DecorationType.view:
            w = 0.2;
            h = 0.12;
            break;
        }
        break;
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
      seatType: _selectedSeatType,
      decorationType: _selectedType == FurnitureType.decoration
          ? _selectedDecorationType
          : null,
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
              'seatStyle': s.seatType.name,
              'decoration': s.decorationType?.name,
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
          switch (_selectedType) {
            FurnitureType.table => '${_defaultCapacity}-seat '
                '${_selectedShape.name.capitalize()} Table',
            FurnitureType.seat =>
              _selectedSeatType == SeatType.chair ? 'Chair' : 'Sofa',
            FurnitureType.toilet => 'Toilet',
            FurnitureType.decoration =>
              _selectedDecorationType.name.capitalize(),
          },
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
            child: LayoutBuilder(builder: (ctx, box) {
              final canvas = Size(box.maxWidth, box.maxHeight);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) {
                  final pos = d.localPosition;
                  final hit = _spots.any((s) {
                    final center = Offset(
                      s.x * canvas.width,
                      s.y * canvas.height,
                    );
                    final halfW = s.w * canvas.width / 2;
                    final halfH = s.h * canvas.height / 2;
                    return Rect.fromCenter(
                            center: center, width: halfW * 2, height: halfH * 2)
                        .contains(pos);
                  });
                  if (!hit) _addSpot(pos, canvas);
                },
                child: Stack(
                  children: _spots.map((spot) {
                    return SpotWidget(
                      spot: spot,
                      canvasSize: canvas,
                      onUpdate: () => setState(() {}),
                      onDelete: () => setState(() => _spots.remove(spot)),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
          ToolBar(
            selectedType: _selectedType,
            selectedSeatType: _selectedSeatType,
            selectedDecorationType: _selectedDecorationType,
            selectedCapacity: _defaultCapacity,
            selectedShape: _selectedShape,
            selectedColor: _selectedColor,
            onTypeSelected: (t) => setState(() => _selectedType = t),
            onSeatTypeSelected: (st) => setState(() => _selectedSeatType = st),
            onDecorationTypeSelected: (dt) =>
                setState(() => _selectedDecorationType = dt),
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
