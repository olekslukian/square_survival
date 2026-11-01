typedef UpdateCallback = void Function(double dt);

class FixedStepAccumulator {
  FixedStepAccumulator({
    this.fixedDelta = 1.0 / 60.0,
    this.maxAccumulator = 0.25,
  });
  final double fixedDelta;
  final double maxAccumulator;
  double _accumulator = 0;

  void advance(double frameDt, UpdateCallback onUpdate) {
    var dt = frameDt;
    if (dt > maxAccumulator) {
      dt = maxAccumulator;
    }
    _accumulator += dt;

    while (_accumulator >= fixedDelta) {
      onUpdate(fixedDelta);
      _accumulator -= fixedDelta;
    }
  }

  double get alpha => _accumulator / fixedDelta;

  void reset() {
    _accumulator = 0.0;
  }
}
