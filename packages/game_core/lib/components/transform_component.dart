import 'package:game_core/ecs/component.dart';

class TransformComponent implements Component {
  TransformComponent({this.x = 0.0, this.y = 0.0});

  factory TransformComponent.fromJson(Map<String, dynamic> json) =>
      TransformComponent(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
  double x;
  double y;

  @override
  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}
