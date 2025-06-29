// lib/models/furniture_spot.dart

enum FurnitureType { table, chair }

enum TableShape { rectangle, square, circle }

class FurnitureSpot {
  final String id;
  double x; // normalized
  double y;
  double w; // normalized width
  double h; // normalized height
  FurnitureType type;
  int capacity;
  TableShape shape;

  FurnitureSpot({
    required this.id,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.type,
    this.capacity = 1,
    this.shape = TableShape.rectangle,
  });
}
