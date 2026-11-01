import 'package:game_core/ecs/component.dart';

class VelocityComponent extends Component {
  VelocityComponent({this.vx = 0.0, this.vy = 0.0});

  factory VelocityComponent.fromJson(Map<String, dynamic> json) =>
      VelocityComponent(
        vx: (json['vx'] as num).toDouble(),
        vy: (json['vy'] as num).toDouble(),
      );
  double vx;
  double vy;

  Map<String, dynamic> toJson() => {'vx': vx, 'vy': vy};
}
