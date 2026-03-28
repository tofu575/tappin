class Latitude {
  final double value;

  const Latitude(this.value) : assert(value >= -90.0 && value <= 90.0);
}
