import '../ecs/component.dart';

class VelocityComponent extends Component {
  double vx;
  double vy;

  VelocityComponent({this.vx = 0.0, this.vy = 0.0});

  Map<String, dynamic> toJson() => {'vx': vx, 'vy': vy};

  factory VelocityComponent.fromJson(Map<String, dynamic> json) =>
      VelocityComponent(
        vx: (json['vx'] as num).toDouble(),
        vy: (json['vy'] as num).toDouble(),
      );
}
