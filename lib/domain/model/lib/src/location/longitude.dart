class Longitude {
  final double value;

  const Longitude(this.value) : assert(value >= -180.0 && value <= 180.0);

  @override
  bool operator ==(Object other) => other is Longitude && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
