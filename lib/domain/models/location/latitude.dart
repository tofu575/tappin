class Latitude {
  final double value;

  const Latitude(this.value) : assert(value >= -90.0 && value <= 90.0);

  @override
  bool operator ==(Object other) => other is Latitude && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
