import '../ecs/component.dart';

class TransformComponent extends Component {
  double x;
  double y;

  TransformComponent({this.x = 0.0, this.y = 0.0});

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory TransformComponent.fromJson(Map<String, dynamic> json) =>
      TransformComponent(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}
